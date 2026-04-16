# PRD 03 - AWS Pipeline Architecture

**Version:** 1.0  
**Date:** 2026-04-16  
**Related To:** Master PRD, Frontend PRD, Backend PRD  
**Status:** Draft

---

## 1. AWS Pipeline Overview

### 1.1 What Are We Building?

This PRD covers the complete AWS pipeline implementation with:
- Full VPC networking with multiple subnets
- ECS Fargate for containerized workloads
- RDS PostgreSQL for data persistence
- SageMaker for ML training and inference
- PrivateLink endpoints for secure service access
- ALB with TLS for load balancing
- Google ADK agent for AI capabilities

### 1.2 AWS Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                              AWS VPC - ML PLATFORM                                                │
│                                              10.0.0.0/16 (Class B Private)                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                                     │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                                              PUBLIC SUBNETS                                                    │  │
│  │                                              10.0.1.0/24 (US-EAST-1A)                                         │  │
│  │                                              10.0.2.0/24 (US-EAST-1B) - HA                                    │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                     │  │
│  │  │   NAT GW    │  │  INTERNET   │  │     WAF     │  │  CLOUDWATCH  │  │   CLOUDFRONT │                     │  │
│  │  │  (EIP)      │  │  GATEWAY    │  │  (Firewall) │  │  (Logs)      │  │  (CDN)      │                     │  │
│  │  │             │  │             │  │             │  │             │  │             │                     │  │
│  │  │ Allow: Out  │  │ Allow: Both │  │ Rate Limit  │  │ Metrics     │  │ SSL/TLS     │                     │  │
│  │  │             │  │             │  │ IP Block    │  │ Logs        │  │ Caching     │                     │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘                     │  │
│  └───────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                                     │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                                           PRIVATE SUBNET - APP (AZ-1)                                       │  │
│  │                                           10.0.10.0/24                                                       │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                                            APPLICATION LOAD BALANCER                                       │ │  │
│  │  │                                                                                                               │ │  │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐│ │  │
│  │  │  │                                    LISTENER RULES                                                         ││ │  │
│  │  │  │                                                                                                             ││ │  │
│  │  │  │  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐        ││ │  │
│  │  │  │  │ Path: /admin/*  │      │ Path: /api/*   │      │ Path: /ws/*    │      │ Path: /*        │        ││ │  │
│  │  │  │  │ → Admin TG      │      │ → API TG       │      │ → WebSocket TG │      │ → Frontend TG  │        ││ │  │
│  │  │  │  │ (HTTPS:8443)    │      │ (HTTPS:8080)   │      │ (HTTPS:8081)   │      │ (HTTPS:3000)   │        ││ │  │
│  │  │  │  └─────────────────┘      └─────────────────┘      └─────────────────┘      └─────────────────┘        ││ │  │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────┘│ │  │
│  │  │                                                                                                               │ │  │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐│ │  │
│  │  │  │                                     TLS CERTIFICATE (ACM)                                                 ││ │  │
│  │  │  │                                     *.aws-pipeline.company.com                                            ││ │  │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────┘│ │  │
│  │  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                                    │                                                            │ │  │
│  │  ┌─────────────────────────────────────────────────┼───────────────────────────────────────────────────────┐ │  │
│  │  │                                                  │                                                        │ │  │
│  │  │  ┌───────────────────────────────────────────────▼───────────────────────────────────────────────────────┐ │  │
│  │  │  │                                       ECS TASKS (FARGATE)                                               │ │  │
│  │  │  │                                                                                                           │ │  │
│  │  │  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                     │ │  │
│  │  │  │  │        ECS - ADMIN API              │  │         ECS - USER API              │                     │ │  │
│  │  │  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                     │ │  │
│  │  │  │  │  │ Service: admin-api             │  │  │  │ Service: user-api              │  │                     │ │  │
│  │  │  │  │  │ Image: 123456.dkr.ecr.region... │  │  │  │ Image: 123456.dkr.ecr.region...│  │                     │ │  │
│  │  │  │  │  │ Port: 8080                     │  │  │  │ Port: 8080                     │  │                     │ │  │
│  │  │  │  │  │ CPU: 1024                      │  │  │  │ CPU: 512                       │  │                     │ │  │
│  │  │  │  │  │ Memory: 2048                   │  │  │  │ Memory: 1024                   │  │                     │ │  │
│  │  │  │  │  │ Env: ADMIN_MODE=true           │  │  │  │ Env: USER_MODE=true           │  │                     │ │  │
│  │  │  │  │  │ Health: /health                │  │  │  │ Health: /health                │  │                     │ │  │
│  │  │  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                     │ │  │
│  │  │  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                     │ │  │
│  │  │  │                                                                                                           │ │  │
│  │  │  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                     │ │  │
│  │  │  │  │       ECS - ML INFERENCE             │  │         ECS - AI AGENT               │                     │ │  │
│  │  │  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                     │ │  │
│  │  │  │  │  │ Service: ml-inference         │  │  │  │ Service: ai-agent             │  │                     │ │  │
│  │  │  │  │  │ Image: ml-inference:v1        │  │  │  │ Image: ai-agent:v1            │  │                     │ │  │
│  │  │  │  │  │ Port: 8081                    │  │  │  │ Port: 8082                    │  │                     │ │  │
│  │  │  │  │  │ CPU: 2048 (GPU optional)      │  │  │  │ CPU: 1024                     │  │                     │ │  │
│  │  │  │  │  │ Memory: 4096                  │  │  │  │ Memory: 2048                  │  │                     │ │  │
│  │  │  │  │  │ Env: SAGEMAKER_ENDPOINT=...   │  │  │  │ Env: ADK_MODEL=gemini-2.0    │  │                     │ │  │
│  │  │  │  │  │ Health: /health/inference     │  │  │  │ Health: /health/agent        │  │                     │ │  │
│  │  │  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                     │ │  │
│  │  │  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                     │ │  │
│  │  │  │                                                                                                           │ │  │
│  │  │  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                     │ │  │
│  │  │  │  │       ECS - FRONTEND                 │  │         ECS - ETL WORKER             │                     │ │  │
│  │  │  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                     │ │  │
│  │  │  │  │  │ Service: frontend              │  │  │  │ Service: etl-worker          │  │                     │ │  │
│  │  │  │  │  │ Image: frontend:v1            │  │  │  │ Image: etl-worker:v1         │  │                     │ │  │
│  │  │  │  │  │ Port: 3000                     │  │  │  │ Port: 8083                   │  │                     │ │  │
│  │  │  │  │  │ CPU: 512                       │  │  │  │ CPU: 2048                    │  │                     │ │  │
│  │  │  │  │  │ Memory: 1024                   │  │  │  │ Memory: 4096                  │  │                     │ │  │
│  │  │  │  │  │ Env: NODE_ENV=production     │  │  │  │ Env: GLUE_JOB_NAME=...       │  │                     │ │  │
│  │  │  │  │  │ Health: /                     │  │  │  │ Health: /health              │  │                     │ │  │
│  │  │  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                     │ │  │
│  │  │  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                     │ │  │
│  │  │  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘ │  │
│  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                                          SECURITY GROUPS                                                    │ │  │
│  │  │                                                                                                               │ │  │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐│ │  │
│  │  │  │ SG-ALB (ALB Security Group)                                                                                 ││ │  │
│  │  │  │   Inbound: 443 (HTTPS) from 0.0.0.0/0                                                                       ││ │  │
│  │  │  │   Inbound: 80 (HTTP) redirect to 443                                                                       ││ │  │
│  │  │  │   Outbound: All to SG-ECS                                                                                  ││ │  │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────┘│ │  │
│  │  │                                                                                                               │ │  │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐│ │  │
│  │  │  │ SG-ECS (ECS Tasks Security Group)                                                                           ││ │  │
│  │  │  │   Inbound: From SG-ALB (all ports)                                                                          ││ │  │
│  │  │  │   Inbound: From VPC (8080, 8081, 8082)                                                                     ││ │  │
│  │  │  │   Outbound: To SG-RDS (5432)                                                                               ││ │  │
│  │  │  │   Outbound: To SG-REDIS (6379)                                                                            ││ │  │
│  │  │  │   Outbound: To VPC Endpoints                                                                               ││ │  │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────┘│ │  │
│  │  │                                                                                                               │ │  │
│  │  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                                     │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                                           PRIVATE SUBNET - DATA (AZ-1)                                        │  │
│  │                                           10.0.20.0/24                                                        │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                             │  │
│  │  │        RDS POSTGRESQL AURORA        │  │           ELASTICACHE REDIS          │                             │  │
│  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                             │  │
│  │  │  │ Cluster: mlops-db-cluster      │  │  │  │ Cluster: mlops-redis          │  │                             │  │
│  │  │  │ Engine: Aurora PostgreSQL 15   │  │  │  │ Engine: Redis 7               │  │                             │  │
│  │  │  │ Instances: 1 Writer + 2 Reader │  │  │  │ Nodes: 2 (Cluster Mode)        │  │                             │  │
│  │  │  │ Storage: 100GB (Auto Scaling)   │  │  │  │ Memory: db.r6g.large          │  │                             │  │
│  │  │  │ Backup: 7 days retention       │  │  │  │ Encryption: KMS               │  │                             │  │
│  │  │  │ Multi-AZ: Yes                  │  │  │  │ Auth: Yes                     │  │                             │  │
│  │  │  │ SSL: Required                  │  │  │  │ TTL: Configured per key       │  │                             │  │
│  │  │  │                                          │  │                               │  │                             │  │
│  │  │  │ SG-RDS Security Group:                  │  │ SG-REDIS Security Group:      │  │                             │  │
│  │  │  │   Inbound: 5432 from SG-ECS only         │  │   Inbound: 6379 from SG-ECS   │  │                             │  │
│  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                             │  │
│  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                             │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                             │  │
│  │  │                 S3 BUCKET              │  │             DYNAMODB                 │                             │  │
│  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                             │  │
│  │  │  │ Bucket: mlops-data-123456789  │  │  │  │ Table: mlops-cache            │  │                             │  │
│  │  │  │ Type: Versioned              │  │  │  │ Keys: PipelineId, Timestamp   │  │                             │  │
│  │  │  │ Encryption: SSE-KMS          │  │  │  │ RCU: 100                     │  │                             │  │
│  │  │  │ Lifecycle: Gold→30d→IA→90d→Glacier││  │  │ WCU: 50                      │  │                             │  │
│  │  │  │ Access: Via Gateway Endpoint │  │  │  │ TTL: 7 days                   │  │                             │  │
│  │  │  │ Logging: Enabled             │  │  │  │ DAX: Enabled (optional)        │  │                             │  │
│  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                             │  │
│  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                             │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  │                                     EFS MOUNT TARGETS                                                      │  │
│  │  │   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐               │  │
│  │  │   │ Mount: az-1a   │    │ Mount: az-1b    │    │ Mount: az-1a    │    │ Mount: az-1b    │               │  │
│  │  │   │ IP: 10.0.20.x  │    │ IP: 10.0.21.x   │    │ For ML Tasks    │    │ For ML Tasks    │               │  │
│  │  │   └─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘               │  │
│  │  │                                                                                                               │  │
│  │  │   Access via: Mount Target → EFS File System (shared storage for ML workloads)                           │  │
│  │  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│  │                                                                                                                   │  │
│  └───────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                                     │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                                           PRIVATE SUBNET - ML (AZ-1)                                          │  │
│  │                                           10.0.30.0/24                                                        │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                             │  │
│  │  │         SAGEMAKER STUDIO           │  │         SAGEMAKER ENDPOINTS         │                             │  │
│  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                             │  │
│  │  │  │ Domain: mlops-studio         │  │  │  │ Endpoint: inference-ep        │  │                             │  │
│  │  │  │ VirtualCluster: enabled      │  │  │  │ Config: ml.m5.xlarge         │  │                             │  │
│  │  │  │ IAM: SageMakerExecutionRole  │  │  │  │ Variants: 2 (Blue/Green)      │  │                             │  │
│  │  │  │ VPC: Only Private Subnet    │  │  │  │ AutoScaling: Enabled          │  │                             │  │
│  │  │  │ Encryption: KMS             │  │  │  │ Production Traffic: 100%       │  │                             │  │
│  │  │  │ FileSystem: EFS             │  │  │  │ Monitoring: CloudWatch        │  │                             │  │
│  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                             │  │
│  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                             │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────┐  ┌─────────────────────────────────────┐                             │  │
│  │  │         SAGEMAKER TRAINING          │  │         SAGEMAKER PROCESSING        │                             │  │
│  │  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────────┐  │                             │  │
│  │  ││ Cluster: GPU (ml.g5.xlarge) │  │  │  │  │ Processing Job: batch-transform│  │                             │  │
│  │  │  │ Instances: 4                │  │  │  │  │ Instance: ml.m5.xlarge        │  │                             │  │
│  │  │  │ Volume: 500GB               │  │  │  │  │ Volume: 100GB                 │  │                             │  │
│  │  │  │ Strategy: MultiDataParallel │  │  │  │  │ Preprocessing Script: ...      │  │                             │  │
│  │  │  │ Debugger: Enabled          │  │  │  │  │ Feature Engineering: Enabled   │  │                             │  │
│  │  │  │ Network: VPC Only          │  │  │  │  │ Network: VPC Only             │  │                             │  │
│  │  │  └───────────────────────────────┘  │  │  └───────────────────────────────┘  │                             │  │
│  │  └─────────────────────────────────────┘  └─────────────────────────────────────┘                             │  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  │                                  VPC INTERFACE ENDPOINTS (PrivateLink)                                    │  │
│  │  │                                                                                                               │  │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐│ │
│  │  │  │ Endpoint Type: Interface Endpoints (ENI + Private IP)                                                   ││ │
│  │  │  │ Security Group: SG-VPC-ENDPOINTS (Inbound: HTTPS from VPC)                                               ││ │
│  │  │  │                                                                                                           ││ │
│  │  │  │ ┌────────────────────────┐  ┌────────────────────────┐  ┌────────────────────────┐                        ││ │
│  │  │  │ │ com.amazonaws         │  │ com.amazonaws          │  │ com.amazonaws          │                        ││ │
│  │  │  │ │ .us-east-1            │  │ .us-east-1            │  │ .us-east-1             │                        ││ │
│  │  │  │ │ .sagemaker.api       │  │ .sagemaker.runtime    │  │ .ecr.api               │                        ││ │
│  │  │  │ │ (Management)         │  │ (Inference)           │  │ (Container Registry)   │                        ││ │
│  │  │  │ └────────────────────────┘  └────────────────────────┘  └────────────────────────┘                        ││ │
│  │  │  │                                                                                                           ││ │
│  │  │  │ ┌────────────────────────┐  ┌────────────────────────┐  ┌────────────────────────┐                        ││ │
│  │  │  │ │ com.amazonaws         │  │ com.amazonaws          │  │ com.amazonaws          │                        ││ │
│  │  │  │ │ .us-east-1            │  │ .us-east-1            │  │ .us-east-1             │                        ││ │
│  │  │  │ │ .ecr.dkr              │  │ .secretsmanager       │  │ .ssm                   │                        ││ │
│  │  │  │ │ (Docker Login)        │  │ (Secrets)             │  │ (Systems Manager)      │                        ││ │
│  │  │  │ └────────────────────────┘  └────────────────────────┘  └────────────────────────┘                        ││ │
│  │  │  │                                                                                                           ││ │
│  │  │  │ ┌────────────────────────┐  ┌────────────────────────┐  ┌────────────────────────┐                        ││ │
│  │  │  │ │ com.amazonaws         │  │ com.amazonaws          │  │ com.amazonaws          │                        ││ │
│  │  │  │ │ .us-east-1            │  │ .us-east-1            │  │ .us-east-1             │                        ││ │
│  │  │  │ │ .ssm messages         │  │ .cloudwatch.metrics   │  │ .logs                  │                        ││ │
│  │  │  │ │ (Session Manager)     │  │ (Monitoring)          │  │ (Logging)              │                        ││ │
│  │  │  │ └────────────────────────┘  └────────────────────────┘  └────────────────────────┘                        ││ │
│  │  │  │                                                                                                           ││ │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────┘│ │
│  │  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│  │                                                                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  │                                  VPC GATEWAY ENDPOINTS (S3 + DynamoDB)                                     │  │
│  │  │                                                                                                               │  │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐│ │
│  │  │  │ Endpoint Type: Gateway Endpoints (Route Table Entry)                                                      ││ │
│  │  │  │ Routing: Via AWS Private Network (No ENI, No Additional Cost)                                              ││ │
│  │  │  │                                                                                                           ││ │
│  │  │  │ ┌────────────────────────┐    ┌────────────────────────┐                                                ││ │
│  │  │  │ │ com.amazonaws          │    │ com.amazonaws          │                                                ││ │
│  │  │  │ │ .us-east-1            │    │ .us-east-1             │                                                ││ │
│  │  │  │ │ .s3                    │    │ .dynamodb              │                                                ││ │
│  │  │  │ │                        │    │                        │                                                ││ │
│  │  │  │ │ Policy: Restrict to    │    │ Policy: Restrict to    │                                                ││ │
│  │  │  │ │ mlops-data-bucket      │    │ mlops-cache-table      │                                                ││ │
│  │  │  │ │                        │    │                        │                                                ││ │
│  │  │  │ │ Bucket Policy:         │    │ Table Policy:          │                                                ││ │
│  │  │  │ │ - Allow from VPC EP   │    │ - Allow from VPC EP   │                                                ││ │
│  │  │  │ │ - Deny outside VPC    │    │ - Deny outside VPC    │                                                ││ │
│  │  │  │ └────────────────────────┘    └────────────────────────┘                                                ││ │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────────────────┘│ │
│  │  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│  │                                                                                                                   │  │
│  └───────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Network Design Decisions

### 2.1 Why Multiple Subnets?

**Q: Why not use a single VPC with all resources?**

**A:** Network segmentation is critical for security and compliance:

| Design | Security | Scalability | Complexity | Cost |
|--------|----------|-------------|------------|------|
| Single Subnet | ❌ Poor | ❌ Limited | ✅ Simple | ✅ Low |
| **Multi-Subnet (Chosen)** | ✅ Excellent | ✅ High | ⚠️ Medium | ⚠️ Medium |
| Multiple VPCs | ✅ Excellent | ✅ High | ❌ Complex | ❌ High |

### 2.2 Subnet Allocation

```
VPC CIDR: 10.0.0.0/16 (Class B Private)

┌─────────────────────────────────────────────────────────────────┐
│ PUBLIC SUBNETS (Internet-facing)                                │
├─────────────────────────────────────────────────────────────────┤
│ 10.0.0.0/24 - us-east-1a (NAT Gateway, WAF, CloudFront)        │
│ 10.0.1.0/24 - us-east-1b (HA NAT Gateway)                       │
│ Purpose: Outbound traffic, CDN, WAF termination                 │
│ Why: NAT GW must be in public subnet to have EIP               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PRIVATE SUBNET - APP (Application workloads)                    │
├─────────────────────────────────────────────────────────────────┤
│ 10.0.10.0/24 - us-east-1a (ECS Tasks, ALB, API)                │
│ 10.0.11.0/24 - us-east-1b (HA for ECS)                         │
│ Purpose: ECS Fargate tasks, containers                         │
│ Why: App-tier should not be directly internet-accessible       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PRIVATE SUBNET - DATA (Database, Cache, Storage)                │
├─────────────────────────────────────────────────────────────────┤
│ 10.0.20.0/24 - us-east-1a (RDS, ElastiCache, S3 Endpoint)     │
│ 10.0.21.0/24 - us-east-1b (HA for RDS)                         │
│ Purpose: Databases, caches, file systems                        │
│ Why: Data layer should be most restricted                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PRIVATE SUBNET - ML (SageMaker, ML workloads)                  │
├─────────────────────────────────────────────────────────────────┤
│ 10.0.30.0/24 - us-east-1a (SageMaker Studio, Training)         │
│ 10.0.31.0/24 - us-east-1b (HA for ML)                           │
│ Purpose: SageMaker, ML training, inference                      │
│ Why: ML needs specific VPC configuration for SageMaker         │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Why Interface Endpoints vs Gateway Endpoints?

**Q: Why use Interface Endpoints for some services and Gateway for others?**

**A:** Different traffic patterns require different endpoint types:

| Service | Endpoint Type | Why |
|---------|---------------|-----|
| **S3** | Gateway | ✅ Free, routes through AWS backbone, NAT not needed |
| **DynamoDB** | Gateway | ✅ Free, routes through AWS backbone |
| **SageMaker API** | Interface | ⚠️ No Gateway option available |
| **ECR API/DKR** | Interface | ⚠️ No Gateway option available |
| **Vault** | Interface | ✅ Cloud-agnostic secrets via Vault agent |
| **SSM** | Interface | ⚠️ No Gateway option available |
| **CloudWatch** | Interface | ✅ Better integration, logs stay in VPC |

---

## 3. Infrastructure Components

### 3.1 Terraform Directory Structure

```
infrastructure/
├── aws/
│   ├── main.tf                 # Main Terraform config
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── versions.tf             # Terraform version constraints
│   ├── providers.tf            # Provider configuration
│   │
│   ├── modules/
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── alb/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── ecs/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── rds/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── elasticache/
│   │   ├── sagemaker/
│   │   ├── vpc-endpoints/
│   │   └── iam/
│   │
│   └── environments/
│       ├── dev/
│       │   ├── main.tf
│       │   └── terraform.tfvars
│       ├── staging/
│       │   ├── main.tf
│       │   └── terraform.tfvars
│       └── prod/
│           ├── main.tf
│           └── terraform.tfvars
```

### 3.2 VPC Module

```hcl
# modules/vpc/main.tf

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ═══════════════════════════════════════════════════════════════════════════
# VPC
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc"
      Type = "MLOps-Platform"
    }
  )
}

# ═══════════════════════════════════════════════════════════════════════════
# PUBLIC SUBNETS (NAT Gateway, Internet Gateway attachment)
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false  # No EC2 instances in public subnet
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

# Route Table Association (Public)
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-eip-${count.index + 1}"
    }
  )
  
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (one per AZ for HA)
resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)
  
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-gw-${count.index + 1}"
    }
  )
  
  depends_on = [aws_internet_gateway.main]
}

# ═══════════════════════════════════════════════════════════════════════════
# PRIVATE SUBNETS (APP - Application workloads)
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_subnet" "app" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10 + count.index)  # 10.0.10.0/24, 10.0.11.0/24
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-app-subnet-${count.index + 1}"
      Type = "Private-APP"
    }
  )
}

# Route Table for APP Subnets (via NAT Gateway) - One per AZ
resource "aws_route_table" "app" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-app-rt-${count.index + 1}"
      Type = "Private-APP"
    }
  )
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# ═══════════════════════════════════════════════════════════════════════════
# PRIVATE SUBNETS (DATA - Database, Cache)
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_subnet" "data" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 20 + count.index)  # 10.0.20.0/24, 10.0.21.0/24
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-data-subnet-${count.index + 1}"
      Type = "Private-DATA"
    }
  )
}

# Route Table for DATA Subnets (via NAT Gateway) - One per AZ
resource "aws_route_table" "data" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-data-rt-${count.index + 1}"
      Type = "Private-DATA"
    }
  )
}

resource "aws_route_table_association" "data" {
  count = length(aws_subnet.data)

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data[count.index].id
}

# ═══════════════════════════════════════════════════════════════════════════
# PRIVATE SUBNETS (ML - SageMaker, ML workloads)
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_subnet" "ml" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 30 + count.index)  # 10.0.30.0/24, 10.0.31.0/24
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ml-subnet-${count.index + 1}"
      Type = "Private-ML"
    }
  )
}

# Route Table for ML Subnets (via NAT Gateway) - One per AZ
resource "aws_route_table" "ml" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ml-rt-${count.index + 1}"
      Type = "Private-ML"
    }
  )
}

resource "aws_route_table_association" "ml" {
  count = length(aws_subnet.ml)

  subnet_id      = aws_subnet.ml[count.index].id
  route_table_id = aws_route_table.ml[count.index].id
}

# ═══════════════════════════════════════════════════════════════════════════
# VPC ENDPOINTS (PrivateLink)
# ═══════════════════════════════════════════════════════════════════════════

# Security Group for Interface Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-endpoints-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_from_vpc" {
  security_group_id = aws_security_group.vpc_endpoints.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description        = "Allow HTTPSfrom within VPC"
}

# IAM Policy for Endpoints (restrict access to specific services)
data "aws_caller_identity" "current" {}

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  
  route_table_ids = tolist(concat(
    aws_route_table.data[*].id,
    aws_route_table.ml[*].id
  ))

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.data_bucket_name}",
          "arn:aws:s3:::${var.data_bucket_name}/*"
        ]
        # Note: Gateway endpoints use route table associations for access control
        # No condition needed - access is controlled via route table associations
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-s3-endpoint"
    }
  )
}

# DynamoDB Gateway Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  
  route_table_ids = tolist(concat(
    aws_route_table.data[*].id,
    aws_route_table.ml[*].id
  ))

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-dynamodb-endpoint"
    }
  )
}

# SageMaker API Interface Endpoint
resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.sagemaker.api"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.ml[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-sagemaker-api-endpoint"
    }
  )
}

# SageMaker Runtime Interface Endpoint
resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.sagemaker.runtime"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.ml[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-sagemaker-runtime-endpoint"
    }
  )
}

# ECR API Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ecr-api-endpoint"
    }
  )
}

# ECR DKR Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ecr-dkr-endpoint"
    }
  )
}

# Secrets Manager Interface Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-secretsmanager-endpoint"
    }
  )
}

# SSM Interface Endpoints
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ssm-endpoint"
    }
  )
}

# SSM Messages (for Session Manager)
resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ssm-messages-endpoint"
    }
  )
}

# CloudWatch Logs Interface Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-logs-endpoint"
    }
  )
}

# CloudWatch Metrics Interface Endpoint
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.monitoring"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.app[*].id
  
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-cloudwatch-endpoint"
    }
  )
}

# ═══════════════════════════════════════════════════════════════════════════
# SECURITY GROUPS
# ═══════════════════════════════════════════════════════════════════════════

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP redirect to HTTPS"
  }

  # Allow ALB to send traffic to ECS tasks (for proxying requests)
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups  = [aws_security_group.ecs.id]
    description     = "To ECS Tasks for proxying"
  }

  # Allow all outbound for general traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-alb-sg"
    }
  )
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs" {
  name        = "${var.environment}-ecs-sg"
  description = "Security group for ECS Tasks"
  vpc_id      = aws_vpc.main.id
  
  # Allow from ALB
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
    description     = "From ALB Security Group"
  }
  
  # Allow from VPC (for internal communication)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "From VPC"
  }
  
  # Allow to RDS
  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds.id]
    description     = "To RDS"
  }
  
  # Allow to ElastiCache
  egress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.elasticache.id]
    description     = "To ElastiCache"
  }
  
  # Allow to VPC endpoints
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "To VPC Endpoints"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ecs-sg"
    }
  )
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS Aurora"
  vpc_id      = aws_vpc.main.id
  
  # Only allow from ECS Tasks
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "From ECS Tasks"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-rds-sg"
    }
  )
}

# ElastiCache Security Group
resource "aws_security_group" "elasticache" {
  name        = "${var.environment}-elasticache-sg"
  description = "Security group for ElastiCache"
  vpc_id      = aws_vpc.main.id
  
  # Only allow from ECS Tasks
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "From ECS Tasks"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-elasticache-sg"
    }
  )
}
```

### 3.3 ECS Module

```hcl
# modules/ecs/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# ECS CLUSTER
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-mlops-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = var.tags
}

# ECS Cluster Capacity Providers (Fargate)
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ═══════════════════════════════════════════════════════════════════════════
# ECS TASK DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════

# Admin API Task Definition
resource "aws_ecs_task_definition" "admin_api" {
  family                   = "${var.environment}-admin-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "admin-api"
      image     = "${var.ecr_repository_url}/admin-api:${var.image_tag}"
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "LOG_LEVEL"
          value = "INFO"
        }
      ]
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${aws_secretsmanager_secret.database.arn}:endpoint::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "admin-api"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
  
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  
  depends_on = [aws_cloudwatch_log_group.ecs]
}

# User API Task Definition
resource "aws_ecs_task_definition" "user_api" {
  family                   = "${var.environment}-user-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "user-api"
      image     = "${var.ecr_repository_url}/user-api:${var.image_tag}"
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "LOG_LEVEL"
          value = "INFO"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "user-api"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

# ML Inference Task Definition
resource "aws_ecs_task_definition" "ml_inference" {
  family                   = "${var.environment}-ml-inference"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "ml-inference"
      image     = "${var.ecr_repository_url}/ml-inference:${var.image_tag}"
      portMappings = [
        {
          containerPort = 8081
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SAGEMAKER_ENDPOINT"
          value = aws_sagemaker_endpoint.inference.endpoint_name
        },
        {
          name  = "MODEL_NAME"
          value = "default-model"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ml-inference"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8081/health/inference || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 120
      }
    }
  ])
}

# AI Agent Task Definition
resource "aws_ecs_task_definition" "ai_agent" {
  family                   = "${var.environment}-ai-agent"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "ai-agent"
      image     = "${var.ecr_repository_url}/ai-agent:${var.image_tag}"
      portMappings = [
        {
          containerPort = 8082
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ADK_MODEL"
          value = "gemini-2.0-flash"
        },
        {
          name  = "GOOGLE_API_KEY"
          valueFrom = "${aws_secretsmanager_secret.google_api.arn}:api_key::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ai-agent"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8082/health/agent || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

# ═══════════════════════════════════════════════════════════════════════════
# ECS SERVICES
# ═══════════════════════════════════════════════════════════════════════════

# Admin API Service
resource "aws_ecs_service" "admin_api" {
  name            = "${var.environment}-admin-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.admin_api.arn
  desired_count   = var.admin_api_desired_count
  launch_type     = "FARGATE"
  
  deployment_controller {
    type = "ECS"
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  
  network_configuration {
    subnets          = var.app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.admin_api.arn
    container_name   = "admin-api"
    container_port   = 8080
  }
  
  health_check_grace_period_seconds = 60
  
  lifecycle {
    ignore_changes = [task_definition]
  }
  
  depends_on = [aws_lb_target_group.admin_api]
}

# User API Service
resource "aws_ecs_service" "user_api" {
  name            = "${var.environment}-user-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.user_api.arn
  desired_count   = var.user_api_desired_count
  launch_type     = "FARGATE"
  
  deployment_controller {
    type = "ECS"
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  
  network_configuration {
    subnets          = var.app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.user_api.arn
    container_name   = "user-api"
    container_port   = 8080
  }
  
  lifecycle {
    ignore_changes = [task_definition]
  }
}

# Auto Scaling for ECS Services
resource "aws_appautoscaling_target" "admin_api" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.admin_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "admin_api_cpu" {
  name               = "${var.environment}-admin-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.admin_api.resource_id
  scalable_dimension = aws_appautoscaling_target.admin_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.admin_api.service_namespace
  
  target_tracking_scaling_policy_configuration {
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
```

### 3.4 RDS Module (Aurora PostgreSQL)

```hcl
# modules/rds/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# AURORA POSTGRESQL CLUSTER
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_rds_cluster" "main" {
  cluster_identifier  = "${var.environment}-mlops-db-cluster"
  engine             = "aurora-postgresql"
  engine_version      = "15.4"
  engine_mode        = "provisioned"
  
  master_username    = "dbadmin"
  master_password    = aws_secretsmanager_secret_version.db_password.secret_string
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  
  storage_encrypted   = true
  kms_key_id          = var.kms_key_id
  
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "mon:04:00-mon:05:00"
  
  # Serverless v2 configuration
  serverlessv2_scaling_configuration {
    min_capacity = 2
    max_capacity = 16
  }
  
  skip_final_snapshot       = var.environment == "dev"
  final_snapshot_identifier = var.environment == "dev" ? null : "${var.environment}-final-snapshot"
  
  enable_http_endpoint = true
  
  tags = var.tags
}

# DB Cluster Instance (Writer)
resource "aws_rds_cluster_instance" "writer" {
  count              = 1
  identifier         = "${var.environment}-mlops-db-writer"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine            = aws_rds_cluster.main.engine
  engine_version    = aws_rds_cluster.main.engine_version
  
  publicly_accessible = false
  
  performance_insights_enabled = true
  performance_insights_kms_key_id = var.kms_key_id
  
  tags = var.tags
}

# DB Cluster Instance (Reader)
resource "aws_rds_cluster_instance" "reader" {
  count              = 2
  identifier         = "${var.environment}-mlops-db-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine            = aws_rds_cluster.main.engine
  engine_version    = aws_rds_cluster.main.engine_version
  
  publicly_accessible = false
  
  performance_insights_enabled = true
  performance_insights_kms_key_id = var.kms_key_id
  
  # Enable reader routing for Aurora Replicas
  promotion_tier = count.index + 1
  
  tags = var.tags
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-mlops-db-subnet-group"
  subnet_ids = var.data_subnet_ids
  
  tags = var.tags
}

# ═══════════════════════════════════════════════════════════════════════════
# HASHICORP VAULT INTEGRATION (Cloud-Agnostic Secrets)
# ═══════════════════════════════════════════════════════════════════════════

# Note: AWS Secrets Manager resources removed - using HashiCorp Vault instead
# Vault provider configuration for AWS secrets

data "vault_aws_access_credentials" "aws_secrets" {
  backend = "aws"
  role    = "mlops-aws-role"  # Vault AWS secrets engine role
}

# Database credentials stored in Vault
resource "vault_generic_secret" "database_credentials" {
  path = "mlops/aws/database"

  data_json = jsonencode({
    username = var.db_username
    password = var.db_password  # Should use random_password resource
    endpoint = aws_rds_cluster.mlops.endpoint
    port     = 5432
  })
}

# Google API key stored in Vault
resource "vault_generic_secret" "google_api_credentials" {
  path = "mlops/aws/google-api"

  data_json = jsonencode({
    api_key = var.google_api_key
  })
}

# Kubernetes admin credentials
resource "vault_generic_secret" "kubernetes_admin" {
  path = "mlops/aws/k8s-admin"

  data_json = jsonencode({
    token = var.k8s_admin_token
    cluster_ca = aws_eks_cluster.mlops.certificate_authority[0].data
    endpoint = aws_eks_cluster.mlops.endpoint
  })
}
```

### 3.5 ALB Module

```hcl
# modules/alb/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION LOAD BALANCER
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_lb" "main" {
  name               = "${var.environment}-mlops-alb"
  internal           = false
  load_balancer_type = "application"
  
  subnets = var.public_subnet_ids
  
  security_groups = [var.alb_security_group_id]
  
  enable_deletion_protection = var.environment == "prod" ? true : false
  
  enable_http2            = true
  idle_timeout            = 60
  drop_invalid_header_fields = true
  
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb-logs"
    enabled = true
  }
  
  tags = var.tags
  
  depends_on = [aws_s3_bucket.alb_logs]
}

# S3 Bucket for ALB Access Logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.environment}-mlops-alb-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBToPutLogs"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Sid    = "AllowALBToAccessLogs"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ═══════════════════════════════════════════════════════════════════════════
# TLS CERTIFICATE (ACM)
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_acm_certificate" "main" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
  
  subject_alternative_names = [
    var.domain_name
  ]
  
  tags = var.tags
}

# Route53 for DNS Validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  zone_id         = var.route53_zone_id
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ═══════════════════════════════════════════════════════════════════════════
# LISTENERS
# ═══════════════════════════════════════════════════════════════════════════

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ═══════════════════════════════════════════════════════════════════════════
# TARGET GROUPS
# ═══════════════════════════════════════════════════════════════════════════

# Admin API Target Group
resource "aws_lb_target_group" "admin_api" {
  name     = "${var.environment}-admin-api-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  deregistration_delay = 30
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }
  
  tags = var.tags
}

# User API Target Group
resource "aws_lb_target_group" "user_api" {
  name     = "${var.environment}-user-api-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  deregistration_delay = 30
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }
  
  tags = var.tags
}

# Listener Rules
resource "aws_lb_listener_rule" "admin_api" {
  listener_arn = aws_lb_listener.https.arn
  priority    = 100
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin_api.arn
  }
  
  condition {
    path_pattern {
      values = ["/admin/*"]
    }
  }
}

resource "aws_lb_listener_rule" "user_api" {
  listener_arn = aws_lb_listener.https.arn
  priority    = 200
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_api.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Default Target Group (for unmatched paths)
resource "aws_lb_target_group" "default" {
  name     = "${var.environment}-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}
```

---

## 4. Complete Terraform Root Module

```hcl
# aws/main.tf

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Remote State Backend
  backend "s3" {
    bucket         = "mlops-terraform-state"
    key            = "aws/mlops/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "mlops-terraform-locks"
  }
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "MLOps-Platform"
      ManagedBy   = "Terraform"
    }
  }
}

# ═══════════════════════════════════════════════════════════════════════════
# MODULES
# ═══════════════════════════════════════════════════════════════════════════

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  region      = var.region
  vpc_cidr    = "10.0.0.0/16"
  
  availability_zones = [
    "${var.region}a",
    "${var.region}b"
  ]
  
  data_bucket_name = "${var.environment}-mlops-data-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Project = "MLOps-Platform"
  }
}

# ALB Module
module "alb" {
  source = "./modules/alb"
  
  environment = var.environment
  domain_name = var.domain_name
  route53_zone_id = var.route53_zone_id
  
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_security_group_id
  
  providers = {
    aws = aws
  }
  
  depends_on = [module.vpc]
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  environment = var.environment
  region      = var.region
  
  vpc_id                = module.vpc.vpc_id
  app_subnet_ids        = module.vpc.app_subnet_ids
  ecs_security_group_id = module.vpc.ecs_security_group_id
  
  ecr_repository_url = aws_ecr_repository.mlops[0].repository_url
  image_tag          = "latest"
  
  admin_api_desired_count = var.environment == "prod" ? 3 : 1
  user_api_desired_count   = var.environment == "prod" ? 3 : 1
  
  alb_target_group_arns = {
    admin_api = module.alb.admin_api_target_group_arn
    user_api  = module.alb.user_api_target_group_arn
  }
  
  depends_on = [module.vpc, module.alb, aws_ecr_repository.mlops]
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  environment = var.environment
  
  data_subnet_ids         = module.vpc.data_subnet_ids
  rds_security_group_id   = module.vpc.rds_security_group_id
  kms_key_id             = aws_kms_key.main.arn
  db_password             = var.db_password
  
  depends_on = [module.vpc]
}

# SageMaker Module
module "sagemaker" {
  source = "./modules/sagemaker"
  
  environment = var.environment
  
  ml_subnet_ids            = module.vpc.ml_subnet_ids
  vpc_security_group_ids   = [module.vpc.vpc_endpoints_security_group_id]
  
  depends_on = [module.vpc]
}
```

---

## 5. 💰 Cost-Saving Tips for AWS Pipeline

### After Completing AWS Setup:

```
⚠️  IMPORTANT: Stop These Resources After Testing!

To save costs when not actively developing:

1. ECS SERVICES (~$0.05/hour per task)
   aws ecs update-service --cluster mlops-dev-cluster --desired-count 0 --region us-east-1

2. SAGEMAKER ENDPOINTS (~$0.10+/hour)
   aws sagemaker delete-endpoint --endpoint-name inference-ep --region us-east-1

3. RDS AURORA (~$0.12/hour serverless)
   Modify DB cluster: Set min capacity to 0

4. ELASTICACHE (~$0.08/hour)
   Delete cluster or stop it (if available)

5. NAT GATEWAYS ($0.045/hour + data processing)
   Cannot stop, but minimize usage

6. LOAD BALANCER ($0.0225/hour)
   Cannot stop, but this is relatively cheap

COST CALCULATION (Dev Environment - Idle):
- ECS Tasks (0): $0
- RDS Serverless (min): ~$0.02/hour
- ElastiCache: ~$0.08/hour
- ALB: ~$0.02/hour
- NAT GW: ~$0.045/hour
- Total: ~$0.17/hour ≈ $120/month (if running 24/7)

TO FULLY STOP:
1. Set ECS desired count to 0
2. Set RDS min capacity to 0
3. Delete SageMaker endpoints
4. Delete ElastiCache (or keep if needed)

TO RESTART:
1. Increase ECS desired count
2. Set RDS min capacity back
3. Recreate SageMaker endpoints
4. Recreate ElastiCache
```

---

## 6. Baby Steps Implementation

### Step 3.1: Setup AWS Account & Prerequisites

```
TASKS:
□ Create AWS Account (if not exists)
□ Create IAM User with Admin permissions
□ Configure AWS CLI locally
□ Create S3 bucket for Terraform state
□ Create DynamoDB table for state locks
□ Install Terraform 1.6+
□ Test: aws sts get-caller-identity
□ Test: terraform version
```

### Step 3.2: Create VPC & Networking

```
TASKS:
□ Create modules/vpc directory
□ Write VPC module (public/private subnets)
□ Create NAT Gateways
□ Create VPC Endpoints (S3, DynamoDB, SageMaker, etc.)
□ Create Security Groups
□ Test: terraform plan
□ Apply: terraform apply
□ Verify: Check VPC in AWS Console
```

### Step 3.3: Create ALB & TLS

```
TASKS:
□ Create modules/alb directory
□ Write ALB module
□ Configure HTTPS listener with ACM
□ Create target groups
□ Setup Route53 DNS
□ Test: terraform plan
□ Apply: terraform apply
□ Verify: Access ALB DNS name
□ Cost Check: ~$0.02/hour
```

### Step 3.4: Create ECS Cluster & Tasks

```
TASKS:
□ Create modules/ecs directory
□ Write ECS module
□ Create task definitions
□ Create ECS services
□ Configure IAM roles
□ Setup observability (Grafana + Prometheus)
□ Test: docker build locally
□ Push to ECR
□ Deploy via terraform
□ Verify: ECS tasks running
```

### Step 3.5: Create RDS Aurora

```
TASKS:
□ Create modules/rds directory
□ Write RDS module
□ Configure Aurora Serverless v2
□ Setup Vault integration (HashiCorp Vault)
□ Configure backup policy
□ Test: terraform plan
□ Apply: terraform apply
□ Cost Check: ~$0.02/hour (min capacity)
```

### Step 3.6: Setup SageMaker

```
TASKS:
□ Create modules/sagemaker directory
□ Create SageMaker Domain
□ Create training job definition
□ Create inference endpoint
□ Configure VPC-only mode
□ Test: terraform plan
□ Apply: terraform apply
□ Cost Check: ~$0.10/hour (when running)
```

### Step 3.7: Create Docker Images & CI/CD

```
TASKS:
□ Create Dockerfiles for each service
□ Push images to ECR
□ Create GitHub Actions workflow
□ Setup automated deployments
□ Configure ECS task updates
□ Test: Push to GitHub → Deploys to ECS
```

### Step 3.8: Add AI Agent (Google ADK)

```
TASKS:
□ Install Google ADK
□ Create agent code with input sanitization (prompt injection defense)
□ Implement Vault auth for agent credentials
□ Create ECS task definition
□ Deploy agent service
□ Connect to Frontend
□ Test: Chat with agent (including adversarial input test)
```

---

## 7. Success Criteria

| Criterion | Target | Verification |
|-----------|--------|--------------|
| VPC Created | All subnets reachable | VPC Reachability Analyzer |
| ALB Routing | Correct path → target | Access each path |
| ECS Tasks | Health checks passing | ECS console |
| RDS Connection | Can connect from ECS | Run psql from task |
| PrivateLink | S3/DDB via endpoint | Test S3 access |
| Agent Chat | Responds correctly | Manual test |
| CI/CD | Full pipeline working | GitHub Actions logs |

---

## 8. Next Steps

1. **Review and approve AWS Pipeline PRD**
2. Move to **Step 3.1: Setup AWS Account & Prerequisites**
3. Build each section with tests
4. **Turn off AWS resources** before moving to GCP Pipeline
5. Proceed to GCP Pipeline PRD

---

**Document Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-16 | Platform Team | Initial draft |
