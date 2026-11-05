# AWS Storage Comparison Matrix

| Feature | Amazon S3 | Amazon EFS | Amazon EBS Multi-Attach |
| :--- | :--- | :--- | :--- |
| **Storage Type** | Object Storage | Distributed File System | Block Storage |
| **Protocol** | REST / HTTP(S) | NFSv4.0 / NFSv4.1 | Block Device Protocol (NVMe) |
| **Mountable to EC2?** | No (API/SDK access only) | Yes (as native Linux directory) | Yes (as raw block device) |
| **Concurrent EC2 Access** | Unlimited API clients | Thousands of EC2 instances | Up to 16 Nitro instances |
| **Availability Zone Scope** | Regional / Multi-AZ | Regional / Multi-AZ | Single Availability Zone |
| **Best Used For** | Static web hosting, media, backups, data lakes | Shared web clusters, developer home directories | Clustered databases (Oracle RAC, GFS2) |
