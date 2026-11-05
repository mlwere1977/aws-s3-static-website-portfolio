# AWS Storage & Security Architecture Analysis

## 1. Amazon S3 Global Namespace Principles
Amazon S3 bucket names are globally unique across all AWS accounts and AWS regions due to:
* **Global DNS Integration:** Every bucket translates directly to an internet-routable domain name (`<bucket-name>.s3.<region>.amazonaws.com`). Since DNS names are unique on the Internet, two S3 buckets can never share a name.
* **ARN Uniformity:** S3 ARNs are globally structured (`arn:aws:s3:::bucket-name`) without requiring an embedded account ID or region code.

## 2. Hardening High-Value Archives (Amazon S3 Glacier)
When storing sensitive or compliance-regulated archives:
* **Glacier Vault Lock / S3 Object Lock (WORM):** Enforces Write-Once-Read-Many policies in compliance mode, preventing archive deletion or overwriting even by the root account.
* **SSE-KMS Encryption:** Uses customer-managed keys (CMK) with segregated key administration and automated rotation.
* **VPC Endpoints & PrivateLink:** Prevents public internet transit by restricting access exclusively to internal VPC CIDRs via `aws:sourceVpce` conditions.
* **MFA Delete & CloudTrail / GuardDuty:** Requires hardware MFA tokens for deletion APIs and audits anomalous bulk retrieval events.

## 3. Concurrent Multi-Instance Mounting on AWS Compute
* **Amazon EFS (Elastic File System):** POSIX/NFSv4 managed file system mountable concurrently by thousands of Amazon EC2 instances across multiple Availability Zones.
* **Amazon FSx Family:** Multi-instance shared storage for Windows/SMB, Lustre (HPC), and ONTAP.
* **Amazon EBS Multi-Attach:** Mounts provisioned IOPS (`io1`/`io2`) volumes to up to 16 Nitro EC2 instances simultaneously within the **same AZ**, requiring a cluster-aware file system (GFS2/OCFS2).
