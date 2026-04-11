import json
import os
import pymysql
import hashlib
import boto3
import logging
from datetime import datetime
import re

# ---------------------------------------------------
# Logging
# ---------------------------------------------------
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------------------------------------------------
# Globals (cached across invocations)
# ---------------------------------------------------
_db_creds = None
_db_conn = None

# ---------------------------------------------------
# Helpers
# ---------------------------------------------------
def is_valid_email(email: str) -> bool:
    pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
    return re.match(pattern, email) is not None

def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, default=str)   # IMPORTANT FIX
    }

# ---------------------------------------------------
# Secrets Manager
# ---------------------------------------------------
def get_db_creds():
    global _db_creds

    if _db_creds:
        return _db_creds

    secret_name = os.environ.get("DB_SECRET_NAME")
    if not secret_name:
        raise Exception("DB_SECRET_NAME not set")

    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=secret_name)

    _db_creds = json.loads(response["SecretString"])
    return _db_creds

# ---------------------------------------------------
# DB Connection
# ---------------------------------------------------
def get_connection():
    global _db_conn

    if _db_conn and _db_conn.open:
        return _db_conn

    creds = get_db_creds()

    logger.info("Connecting to DB...")

    _db_conn = pymysql.connect(
        host=creds["DB_HOST"],
        user=creds["DB_USER"],
        password=creds["DB_PASSWORD"],
        database=creds["DB_NAME"],
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor
    )

    logger.info("DB connection successful")

    return _db_conn

# ---------------------------------------------------
# Lambda Handler
# ---------------------------------------------------
def lambda_handler(event, context):
    request_id = context.aws_request_id

    logger.info(f"[{request_id}] Lambda invoked")
    logger.info(f"[{request_id}] Event: {json.dumps(event)}")

    method = event["requestContext"]["http"]["method"]
    path_params = event.get("pathParameters") or {}

    # -------------------------
    # DB connection (SAFE)
    # -------------------------
    try:
        conn = get_connection()
        cursor = conn.cursor()
    except Exception as e:
        logger.error(f"[{request_id}] DB connection error: {str(e)}")
        return response(500, {"error": "Database connection failed"})

    # -------------------------
    # GET
    # -------------------------
    if method == "GET":
        try:
            if "id" in path_params:
                user_id = int(path_params["id"])
                cursor.execute(
                    "SELECT id, username, email, created_at FROM users WHERE id=%s",
                    (user_id,)
                )
                user = cursor.fetchone()

                if not user:
                    return response(404, {"error": "User not found"})

                return response(200, user)

            cursor.execute("SELECT id, username, email, created_at FROM users")
            users = cursor.fetchall()
            return response(200, users)

        except Exception as e:
            logger.error(f"[{request_id}] GET error: {str(e)}")
            return response(500, {"error": "Internal server error"})

    # -------------------------
    # POST (signup)
    # -------------------------
    if method == "POST":
        try:
            # Safe body parsing
            body = event.get("body")
            if isinstance(body, str):
                body = json.loads(body)
            elif body is None:
                body = {}

            logger.info(f"[{request_id}] Parsed body → {body}")

            username = body.get("username")
            email = body.get("email")
            password = body.get("password")

            if not username or not email or not password:
                return response(400, {"error": "username, email and password are required"})

            if not is_valid_email(email):
                return response(400, {"error": "Invalid email format"})

            if len(password) < 8:
                return response(400, {"error": "Password must be at least 8 characters"})

            password_hash = hashlib.sha256(password.encode()).hexdigest()

            logger.info(f"[{request_id}] Inserting user into DB")

            cursor.execute(
                """
                INSERT INTO users (username, email, password_hash)
                VALUES (%s, %s, %s)
                """,
                (username, email, password_hash)
            )
            conn.commit()
            #logger.info(f"[{request_id}] User created successfully") 
            return response(201, {"message": "User created"})
        

        except pymysql.err.IntegrityError as e:
            logger.error(f"Integrity error: {str(e)}")
            return response(400, {"error": "Email already exists"})

        except Exception as e:
            logger.error(f"[{request_id}] POST error: {str(e)}")
            return response(500, {"error": "Internal server error"})

    # -------------------------
    # PUT
    # -------------------------
    if method == "PUT":
        try:
            if "id" not in path_params:
                return response(400, {"error": "ID required"})

            user_id = int(path_params["id"])
            body = json.loads(event["body"])

            cursor.execute(
                """
                UPDATE users
                SET username=%s, email=%s
                WHERE id=%s
                """,
                (body["username"], body["email"], user_id)
            )
            conn.commit()

            return response(200, {"message": "User updated"})

        except Exception as e:
            logger.error(f"[{request_id}] PUT error: {str(e)}")
            return response(500, {"error": "Internal server error"})

    # -------------------------
    # DELETE
    # -------------------------
    if method == "DELETE":
        try:
            if "id" not in path_params:
                return response(400, {"error": "ID required"})

            user_id = int(path_params["id"])

            cursor.execute(
                "DELETE FROM users WHERE id=%s",
                (user_id,)
            )
            conn.commit()

            return response(200, {"message": "User deleted"})

        except Exception as e:
            logger.error(f"[{request_id}] DELETE error: {str(e)}")
            return response(500, {"error": "Internal server error"})

    return response(405, {"error": "Method not allowed"})