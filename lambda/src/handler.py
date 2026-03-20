import json
import os
import pymysql
import hashlib
import boto3
import logging
from datetime import datetime
import re

def is_valid_email(email: str) -> bool:
    pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
    return re.match(pattern, email) is not None




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
# DB Connection (reuse)
# ---------------------------------------------------
def get_connection():
    global _db_conn

    if _db_conn and _db_conn.open:
        return _db_conn

    creds = get_db_creds()

    _db_conn = pymysql.connect(
        host=creds["DB_HOST"],
        user=creds["DB_USER"],
        password=creds["DB_PASSWORD"],
        database=creds["DB_NAME"],
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor
    )
    return _db_conn


# ---------------------------------------------------
# Helpers
# ---------------------------------------------------
def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, default=str)
    }


# ---------------------------------------------------
# Lambda Handler
# ---------------------------------------------------
def lambda_handler(event, context):
    logger.info("Lambda invoked")
    logger.info(event)

    method = event["requestContext"]["http"]["method"]
    path_params = event.get("pathParameters") or {}

    conn = get_connection()
    cursor = conn.cursor()

    # -------------------------
    # GET (all / by id)
    # -------------------------
    if method == "GET":
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

        cursor.execute(
            "SELECT id, username, email, created_at FROM users"
        )
        users = cursor.fetchall()
        return response(200, users)

    # -------------------------
    # POST (create)
    # -------------------------
    if method == "POST":
        body = json.loads(event["body"])

        username = body["username"]
        email = body["email"]
        password = body["password"]
        
        if not username or not email or not password:
            return response(400, {"error": "username, email and password are required"})

        if not is_valid_email(email):
            return response(400, {"error": "Invalid email format"})

        if len(password) < 8:
            return response(400, {"error": "Password must be at least 8 characters"})
        password_hash = hashlib.sha256(password.encode()).hexdigest()

        cursor.execute(
            """
            INSERT INTO users (username, email, password_hash)
            VALUES (%s, %s, %s)
            """,
            (username, email, password_hash)
        )
        conn.commit()

        return response(201, {"message": "User created"})

    # -------------------------
    # PUT (update)
    # -------------------------
    if method == "PUT":
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

    # -------------------------
    # DELETE
    # -------------------------
    if method == "DELETE":
        if "id" not in path_params:
            return response(400, {"error": "ID required"})

        user_id = int(path_params["id"])

        cursor.execute(
            "DELETE FROM users WHERE id=%s",
            (user_id,)
        )
        conn.commit()

        return response(200, {"message": "User deleted"})

    # -------------------------
    # Unsupported
    # -------------------------
    return response(405, {"error": "Method not allowed"})
