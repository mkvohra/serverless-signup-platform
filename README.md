# 🚀 Serverless Multi-Environment Infrastructure (AWS + Terraform)

## 📌 Overview

This project implements a fully serverless, production-style backend system using AWS and Terraform, designed with multiple environments (**dev, stage, prod**) and a structured CI/CD pipeline.

The system supports a user signup workflow, where:

* Frontend (CloudFront + S3)
* API Gateway
* Lambda (Python)
* RDS (MySQL)

work together end-to-end.

The infrastructure is modular, reproducible, and environment-isolated, with secure networking and automated deployments.

---

## 🧠 Core Architecture

```
CloudFront → S3 (Frontend)
        ↓
   API Gateway
        ↓
     Lambda (VPC)
        ↓
      RDS (Private DB)
```

---

## 🧩 Key Concepts & What Was Learned

### 1. Multi-Environment Infrastructure Design

* Separate environments: **dev, stage, prod**
* Independent infrastructure per environment
* Avoids accidental cross-environment impact

**Learning:**
Understanding how real systems isolate environments for safe testing and deployment.

---

### 2. Terraform Modular Architecture

* Each component isolated:

  * networking
  * iam
  * lambda
  * database
  * s3
* Separate `.tfstate` per component

**Learning:**

* State isolation prevents large blast radius
* Easier debugging and targeted deployments

---

### 3. Remote State Usage

* Used `terraform_remote_state` to fetch outputs across components and environments

Example:

* Stage DB accessed by Prod Lambda

**Learning:**

* Decoupled infrastructure can still communicate
* Cross-component dependency without tight coupling

---

### 4. VPC Design & Networking

* Private subnets for Lambda and RDS
* No public access to database
* Controlled communication via security groups

**Learning:**

* Difference between public and private networking
* Importance of controlled access in production systems

---

### 5. VPC Peering (Cross-Environment Communication)

* Enabled **Prod Lambda → Stage RDS** access
* Route tables + CIDR-based access control

**Learning:**

* How separate VPCs communicate securely
* Real-world networking constraints and solutions

---

### 6. VPC Endpoints (Private AWS Access)

* Created endpoints for:

  * Secrets Manager
  * CloudWatch Logs

**Why:**
Lambda had **no internet access (no NAT)**

**Learning:**

* Difference between:

  * IAM permissions (authorization)
  * Network reachability (connectivity)
* Private AWS service access without internet

---

### 7. IAM Role Design

* Separate IAM roles per environment
* Least-privilege access
* Lambda execution roles with logging + secrets permissions

**Learning:**

* Fine-grained access control
* Avoiding over-permissioned roles

---

### 8. Serverless Backend (Lambda + API Gateway)

* Stateless backend
* Event-driven architecture

**Learning:**

* How backend logic runs without servers
* Request → Lambda → Response flow

---

### 9. Secrets Management

* Credentials stored in **AWS Secrets Manager**
* Not hardcoded in code

**Learning:**

* Secure handling of sensitive data
* Separation of code and secrets

---

### 10. CloudWatch Logging

* Automatic log capture via Lambda runtime
* Structured logging using `logger.info`

**Learning:**

* Logging flow:

  ```
  Lambda → stdout → CloudWatch Logs
  ```
* Importance of observability

---

### 11. CI/CD Pipeline (GitHub Actions)

#### Features:

* Separate workflows for:

  * Plan
  * Apply
* Reusable workflows
* Environment-based deployments
* Dependency-based job execution
* `workflow_dispatch` for manual control

**Learning:**

* Infrastructure automation
* Controlled deployments across environments
* Handling conditional execution

---

### 12. Lambda Artifact Versioning

* Artifacts stored in S3 with versioned keys:

  ```
  <env>/<commit-sha>.zip
  ```

**Learning:**

* Avoid overwriting builds
* Traceability of deployments

---

### 13. Dynamic Frontend Configuration

* API endpoint selected dynamically based on CloudFront URL

**Learning:**

* Decoupling frontend from hardcoded backend URLs
* Environment-aware frontend behavior

---

### 14. Infrastructure Lifecycle Management

* Full cycle:

  ```
  build → debug → deploy → test → document → destroy
  ```

**Learning:**

* Cost awareness (RDS, networking)
* Safe teardown strategies
* Managing dependencies during destroy

---

## 🧪 First-Time Challenges Faced

* Understanding Lambda deployment via artifacts
* Debugging missing logs vs code execution
* Handling pipeline job dependencies blocking deployment
* Resolving outdated Lambda artifacts across environments
* Designing VPC peering across environments
* Managing Terraform variable mismatches during destroy
* Dealing with S3 bucket deletion constraints (`force_destroy`)
* Debugging "Missing Authentication Token" errors in API Gateway
* Understanding difference between:

  * API route vs Lambda logic
* Fixing environment drift between branches and deployments

---
## 🧠 Design Decisions

### 1. Multi-Environment Isolation (dev / stage / prod)

Instead of sharing infrastructure, each environment was provisioned independently.

**Why:**

* Prevent accidental impact across environments
* Enable safe testing before production
* Mirror real-world deployment pipelines

**Trade-off:**

* Higher resource usage
* More complex pipeline orchestration

---

### 2. Component-Based Terraform Architecture (One State per Component)

Infrastructure was divided into components such as networking, IAM, Lambda, database, and frontend, each maintaining its own `.tfstate`.

**Why:**

* Reduces blast radius of changes
* Enables targeted deployments and debugging
* Improves maintainability and clarity

**Trade-off:**

* Requires explicit handling of dependencies
* Introduces complexity in cross-component communication

---

### 3. Use of Terraform Remote State for Cross-Component Access

Instead of tightly coupling components, outputs were shared using `terraform_remote_state`.

**Why:**

* Keeps components loosely coupled
* Enables reuse of infrastructure outputs (VPC IDs, CIDRs, etc.)
* Supports independent deployments

**Trade-off:**

* Requires careful management of state consistency
* Adds cognitive overhead in understanding data flow

---

### 4. Private Networking (No Public DB Access)

RDS was deployed in private subnets with no public exposure.

**Why:**

* Enhances security posture
* Prevents direct external access to database
* Aligns with production-grade architecture

**Trade-off:**

* Requires additional setup for connectivity (Lambda in VPC, endpoints, etc.)

---

### 5. Lambda Inside VPC

Lambda functions were placed inside private subnets.

**Why:**

* Required to access private RDS
* Ensures backend operates within controlled network boundaries

**Trade-off:**

* Loss of default internet access
* Requires VPC endpoints for AWS services

---

### 6. VPC Endpoints Instead of NAT Gateway

Endpoints were created for services like Secrets Manager and CloudWatch Logs.

**Why:**

* Avoid NAT Gateway costs
* Maintain fully private architecture
* Enable Lambda to access AWS services without internet

**Trade-off:**

* Requires explicit configuration per service
* Adds networking complexity

---

### 7. VPC Peering for Cross-Environment Communication

Prod Lambda was allowed to access Stage RDS via VPC peering.

**Why:**

* Overcame free-tier limitation (no separate prod DB)
* Enabled controlled cross-VPC communication

**Trade-off:**

* Breaks strict environment isolation
* Requires route table + security group coordination

---

### 8. Environment-Specific IAM Roles (Least Privilege)

Each environment had its own IAM roles with scoped permissions.

**Why:**

* Prevent cross-environment access
* Follow least privilege principle
* Improve security and auditability

---

### 9. Lambda Artifact Versioning (S3-Based)

Artifacts were stored in S3 using versioned keys:

```
<env>/<commit-sha>.zip
```

**Why:**

* Prevent overwriting deployments
* Enable traceability between code and deployment
* Support rollback capability

---

### 10. CI/CD Pipeline with Controlled Execution

Pipeline included:

* Separate plan and apply workflows
* Conditional execution based on changes
* Job dependencies (`needs`)
* Manual triggers (`workflow_dispatch`)

**Why:**

* Avoid unnecessary deployments
* Ensure proper order of resource creation
* Provide manual control when needed

**Trade-off:**

* Complex dependency chains can block execution

---

### 11. Dynamic API Selection in Frontend

Frontend dynamically selects API endpoint based on CloudFront URL.

**Why:**

* Avoid hardcoding environment-specific APIs
* Enable single frontend codebase for all environments

---

### 12. Secrets Management via AWS Secrets Manager

Database credentials were stored securely instead of hardcoding.

**Why:**

* Prevent credential exposure
* Centralize secret management
* Align with secure practices

---

### 13. Observability via Structured Logging

Used structured logs inside Lambda for better traceability.

**Why:**

* Easier debugging
* Clear visibility into request flow
* Helps in identifying failures quickly

---

## 🔧 Real Problems Solved

### 1. Lambda Not Updating Despite New Deployments

**Problem:**
Lambda continued using old code even after deployment.

**Cause:**
Pipeline was generating new artifacts, but Lambda was still referencing older artifact keys due to job dependency issues.

**Solution:**

* Fixed pipeline logic
* Ensured Lambda job runs correctly
* Verified artifact key consistency

---

### 2. Pipeline Skipping Critical Jobs

**Problem:**
Lambda deployment job was skipped unexpectedly.

**Cause:**
Strict `needs` dependencies caused Lambda job to skip when unrelated jobs (IAM, networking) didn’t run.

**Solution:**

* Identified mismatch between `if` conditions and `needs`
* Adjusted pipeline structure to ensure Lambda runs independently when needed

---

### 3. Inconsistent Logs Across Environments

**Problem:**
Same code behaved differently in logs across dev, stage, and prod.

**Cause:**
Different environments were running different Lambda artifacts.

**Solution:**

* Verified artifact uploads
* Re-deployed Lambda explicitly
* Ensured environments use correct artifact versions

---

### 4. Prod Lambda Unable to Reach Stage RDS

**Problem:**
Database connection failed from prod Lambda.

**Cause:**

* Separate VPCs with no connectivity
* Missing network path

**Solution:**

* Implemented VPC peering
* Updated route tables
* Modified security group rules

---

### 5. Confusion Between API Gateway Routes and Lambda Logic

**Problem:**
API requests failing despite correct Lambda code.

**Cause:**
Mismatch between API Gateway routes and expected Lambda paths.

**Solution:**

* Inspected API Gateway configuration
* Matched routes with Lambda logic
* Tested endpoints using Postman

---

### 6. Terraform Destroy Failing Due to Dependencies

**Problem:**
Resources like S3 buckets, VPCs, and security groups failed to delete.

**Cause:**

* S3 bucket not empty
* VPC peering still active
* Resources still attached

**Solution:**

* Used `force_destroy` for S3
* Destroyed resources in dependency order
* Understood provider-level constraints

---

### 7. Terraform Variable Issues During Destroy

**Problem:**
Terraform demanded variables (like `artifact_key`) during destroy.

**Cause:**
Variables defined without defaults.

**Solution:**

* Added default values in component-level variables
* Ensured smooth local destroy without pipeline

---

### 8. CloudWatch Logs Not Appearing Initially

**Problem:**
Logs were missing or inconsistent.

**Cause:**
Lambda inside private VPC lacked network path to CloudWatch.

**Solution:**

* Added VPC endpoints for logging
* Ensured IAM permissions were correct

---

### 9. S3 Bucket Deletion Failure

**Problem:**
Terraform failed to delete non-empty bucket.

**Cause:**
AWS restriction on deleting non-empty buckets.

**Solution:**

* Enabled `force_destroy`
* Allowed Terraform to clean up automatically

---

### 10. Understanding Environment vs Deployment Confusion

**Problem:**
Frontend, API, and backend behavior didn’t align across environments.

**Cause:**
Mismatch between deployed frontend and backend APIs.

**Solution:**

* Understood that CloudFront determines frontend
* API URL determines backend
* Implemented dynamic API selection

---

## 🎯 What This Project Taught

* Infrastructure problems are often **not obvious from code alone**
* Debugging requires understanding:

  * pipeline flow
  * deployment artifacts
  * runtime behavior
* Networking is as important as application logic
* Automation introduces complexity that must be carefully managed
* Real learning comes from fixing things that don’t work the first time

## ⚙️ Technologies Used

* AWS (Lambda, API Gateway, RDS, S3, CloudFront, IAM, VPC, Secrets Manager, CloudWatch)
* Terraform
* GitHub Actions (CI/CD)
* Branch Protection enabled
* Merge On Pull Request Only
* Python (Lambda)
* JavaScript (Frontend)

---

## 🎯 Key Takeaways

* Infrastructure is not just creation—it’s **lifecycle management**
* Networking and IAM are equally important
* Pipelines introduce complexity beyond local development
* Debugging real systems requires patience and observation
* Clean architecture comes from separation and clarity

---

## 📸 Proof of Work

* End-to-end working demo (CloudFront → DB)
* CloudWatch logs showing execution flow
* Postman testing (GET, POST, PUT)
* Database verification via API

---

## 🧾 Final Note

This project was built independently, focusing on understanding not just *how* systems work, but *why* they are designed this way in real-world production environments.
