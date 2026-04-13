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
