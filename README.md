# AWS S3 Static Website Hosting & Dynamic DNS Masking Showcase

![AWS S3](https://img.shields.io/badge/AWS-S3%20Static%20Hosting-232F3E?logo=amazon-aws&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Frontend-Bootstrap%205-7952B3?logo=bootstrap&logoColor=white)
![DNS](https://img.shields.io/badge/DNS-No--IP%20DDNS-46A342)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)

An enterprise-ready cloud architecture and deployment showcase demonstrating secure static web hosting on **Amazon Simple Storage Service (S3)**, Write-Once-Read-Many (WORM) lifecycle concepts, automated CI/CD deployment, and domain cloaking via **No-IP Dynamic DNS**.

---

##  Architectural Overview

This project implements a scalable, high-availability, serverless web hosting solution on AWS without requiring dedicated web servers (EC2 / Apache / Nginx), significantly reducing operational overhead and hosting costs.

```
                  +-----------------------------------+
                  |        End User / Recruiter       |
                  +-----------------+-----------------+
                                    |
                        HTTP / Masked Domain Request
                                    v
                  +-----------------------------------+
                  |         No-IP Dynamic DNS         |
                  |     (mlwere-resume.ddns.net)      |
                  +-----------------+-----------------+
                                    |
                       DNS URL Redirect / Masking
                                    v
+-----------------------------------------------------------------------+
| AWS Cloud (us-east-1)                                                 |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | Root Website S3 Bucket (Public Read via Policy)                 |  |
|  | - index.html (Digital Resume, Portfolio, HTML5 Video player)    |  |
|  | - error.html (Custom HTTP 404 routing document)                |  |
|  | - Media & Assets (Potrait_1MB.png, Intro Video .mp4)            |  |
|  +--------------------------------+--------------------------------+  |
|                                   | Server Access Logs                |
|                                   v                                   |
|  +-----------------------------------------------------------------+  |
|  | Logging S3 Bucket (Private / Encrypted)                         |  |
|  | - logs.<bucket-name> (Encrypted access logs & analytics)        |  |
|  +-----------------------------------------------------------------+  |
+-----------------------------------------------------------------------+
```

---

##  Key Technical Competencies Demonstrated

### 1. Amazon S3 Architecture & Global Namespace
* **Bucket Naming & DNS Resolution:** Understands why S3 bucket names must be globally unique across all AWS accounts and regions (rooted in global DNS naming standards and ARN routing: `arn:aws:s3:::bucket-name`).
* **S3 Static Web Hosting vs. REST API Endpoints:** Differentiates between:
  * **S3 Website Endpoint:** `http://<bucket-name>.s3-website-<region>.amazonaws.com` (supports default index/error routing and clean HTTP web delivery).
  * **S3 REST API Endpoint:** `https://<bucket-name>.s3.<region>.amazonaws.com/<object-key>` (requires exact object keys; returns XML error documents for missing keys).

### 2. Cloud Security & Least Privilege Access
* **Scoped S3 Bucket Policy:** Bypasses legacy insecure ACLs by using modern JSON-based IAM resource policies allowing public `s3:GetObject` on root website assets only.
* **Block Public Access (BPA) Management:** Granular evaluation of account-level vs. bucket-level Block Public Access controls.
* **Separation of Concerns:** Isolated private audit logging bucket (`logs.<bucket-name>`) prevents log tampering and public exposure.

### 3. Media Streaming & MIME Type Handling
* **S3 System Metadata Configuration:** Ensured modern browser compatibility by resolving MIME type mismatches (`Content-Type: video/mp4` and `image/png`) to prevent media decoding failures.

### 4. Custom DNS & Endpoint Masking (No-IP)
* Configured dynamic DNS masking and URL cloaking to deliver human-readable domains without incurring Amazon Route 53 private hosted zone fees.

---

##  Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── s3-deploy.yml          # Automated CI/CD pipeline to sync assets to S3
├── docs/
│   ├── ARCHITECTURE.md            # Deep dive into AWS storage & security architecture
│   └── S3_VS_EFS_EBS.md           # AWS storage concurrency comparison matrix
├── terraform/
│   ├── main.tf                    # Complete IaC: S3 website bucket, logging, and policy
│   ├── variables.tf               # Configurable project inputs
│   └── outputs.tf                 # Bucket website endpoints and ARNs
├── website/
│   ├── index.html                 # Bootstrap 5 responsive executive digital resume
│   ├── error.html                 # S3-compatible custom 404 handler
│   └── Potrait_1MB.png            # Profile headshot
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🛠️ Step-by-Step Deployment Guide

### Option A: Automated Infrastructure as Code (Terraform)

1. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init
   ```

2. **Plan & Apply:**
   ```bash
   terraform apply -var="bucket_name=my-unique-resume-bucket-2026"
   ```

3. **Deploy Website Assets:**
   ```bash
   aws s3 sync ../website s3://$(terraform output -raw website_bucket_name) --delete
   ```

---

### Option B: Manual AWS Console Setup

1. **Create the Logging Bucket:**
   * Create bucket `logs.my-unique-resume-bucket` in `us-east-1`.
   * Keep **Block All Public Access** turned **ON**.

2. **Create the Root Website Bucket:**
   * Create bucket `my-unique-resume-bucket` in `us-east-1`.
   * Uncheck **Block all public access** and acknowledge.

3. **Attach Public Read Policy:**
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "PublicReadGetObject",
               "Effect": "Allow",
               "Principal": "*",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::my-unique-resume-bucket/*"
           }
       ]
   }
   ```

4. **Enable Static Website Hosting:**
   * In **Properties** > **Static website hosting**, choose **Enable**.
   * Index document: `index.html`
   * Error document: `error.html`

5. **Upload Web Assets & Set MIME Types:**
   * Upload `index.html`, `error.html`, `Potrait_1MB.png`, and video `.mp4`.
   * Verify under **Properties > Metadata** that `.mp4` files have `Content-Type: video/mp4`.

---

##  Dynamic DNS Masking (No-IP Setup)

1. Register a free hostname at [No-IP](https://www.noip.com/) (e.g. `my-resume.ddns.net`).
2. Select Record Type: **URL / Web Redirect**.
3. Target URL: Set to your S3 website endpoint (`http://<bucket-name>.s3-website-us-east-1.amazonaws.com`).
4. Protocol: Set to **`HTTP`** (standard S3 website endpoints do not listen on port 443 SSL directly).
5. Enable **Mask URL / Cloaking** so the browser URL bar retains your custom domain.

---

##  Verification & Health Check

* **Direct S3 Endpoint:** `http://<bucket-name>.s3-website-us-east-1.amazonaws.com`
* **Masked Domain:** `http://<custom-hostname>.ddns.net`
* **Custom 404 Check:** `http://<custom-hostname>.ddns.net/nonexistent-page` -> renders `error.html`

---

## 👤 Author

**Mukwaya Lwere**  
*Senior IT Program Manager | Scrum Master | GRC & Cloud Security Leader*  
* M.S. Cybersecurity Candidate, University of Arizona (GPA: 4.0)
* PMP® | PMI-ACP® | CISM | CRISC | CISA | CompTIA SecurityX | AWS Solutions Architect Pro | Azure Security Engineer

---
