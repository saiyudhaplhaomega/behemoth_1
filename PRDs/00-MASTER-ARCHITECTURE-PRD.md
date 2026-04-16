# MASTER PRD - Financial Markets Intelligence Platform (FMIP)

**Version:** 2.0
**Date:** 2026-04-16
**Author:** Saiyudh Mannan
**Status:** Draft

---

## 1. Executive Summary

### 1.1 Project Overview

**Project Name:** Financial Markets Intelligence Platform (FMIP)

**What Are We Building?**
An AI-powered financial markets prediction platform that combines multi-cloud ML infrastructure with swarm intelligence, real-time sentiment analysis, and prediction market data to generate actionable trading signals across stocks, crypto, forex, commodities, and Polymarket prediction markets.

**Core Capabilities:**
1. **Algorithmic Trading** - Price direction prediction with backtesting
2. **Risk Management** - VaR, stress testing, portfolio optimization
3. **Time Series Forecasting** - Volatility, revenue, multi-asset prediction
4. **Sentiment Analysis** - News + social → trading signals
5. **Prediction Markets** - Polymarket data integration with swarm intelligence
6. **Paper Trading** - Train without financial risk

### 1.2 Business Case

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BUSINESS VALUE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  VALUE PROPOSITION                          │    METRICS                   │
│  ───────────────────────────────────────────┼─────────────────────────────  │
│  • Multi-cloud resilience                   │  99.99% uptime               │
│  • Cost optimization via cloud arbitrage    │  30-40% cost savings         │
│  • ML innovation velocity                   │  5x faster model deployment  │
│  • Unified observability                    │  Single pane of glass        │
│  • Talent flexibility                       │  Cloud-agnostic skills       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Key Stakeholders

| Stakeholder | Role | Interest |
|-------------|------|----------|
| Platform Team | Build & Maintain | Technical excellence |
| ML Engineers | Consume pipelines | Fast iteration |
| Data Scientists | Train models | Infrastructure abstracted |
| DevOps Team | CI/CD | Unified workflows |
| Business | ROI | Cost & velocity |

---

## 2. Architecture Overview

### 2.1 High-Level Architecture

```mermaid
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           ENTERPRISE ML PLATFORM                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐    │
│  │                        UNIFIED EXPERIENCE LAYER                                │    │
│  │                                                                                │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │    │
│  │  │   Unified   │  │    Cross-   │  │   Meta      │  │   BI        │       │    │
│  │  │  Dashboard  │  │   Platform  │  │  Orchestr.  │  │   Embed     │       │    │
│  │  │  (Next.js)  │  │   Router    │  │   Agent     │  │  (Power BI/ │       │    │
│  │  │             │  │             │  │             │  │   Tableau)  │       │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │    │
│  └───────────────────────────────────────────────────────────────────────────────┘    │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           CLOUD PIPELINES                                      │  │
│  │                                                                                │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐│  │
│  │  │     AWS         │  │      GCP        │  │     Azure       │  │ Databricks││  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │┌────────┐││  │
│  │  │  │Frontend   │  │  │  │Frontend   │  │  │  │Frontend   │  │  ││Frontend│││  │
│  │  │  │(React)    │  │  │  │(React)    │  │  │  │(React)    │  │  ││(React) │││  │
│  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │  │└────────┘││  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │┌────────┐││  │
│  │  │  │Backend    │  │  │  │Backend    │  │  │  │Backend    │  │  ││Backend │││  │
│  │  │  │(Python)  │  │  │  │(Python)       │  │  │  │(Python)     │  │  ││(Python)│││  │
│  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │  │└────────┘│  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │┌────────┐││  │
│  │  │  │ ML Agent  │  │  │  │ ML Agent  │  │  │  │ ML Agent  │  │  ││ ML     │││  │
│  │  │  │ (Google   │  │  │  │(LangChain │  │  │  │ (CrewAI)  │  │  ││ Agent  │││  │
│  │  │  │  ADK)     │  │  │  │+LangGraph)│  │  │  │           │  │  ││(Custom)│││  │
│  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │  │└────────┘││  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │┌────────┐││  │
│  │  │  │Data Lake  │  │  │  │Data Lake  │  │  │  │Data Lake  │  │  ││Delta   │││  │
│  │  │  │(S3)       │  │  │  │(GCS)      │  │  │  │(ADLS)     │  │  ││Lake    │││  │
│  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │  │└────────┘││  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │┌────────┐││  │
│  │  │  │ ML Pipeline│  │  │  │ML Pipeline│  │  │  │ML Pipeline│  │  ││ ML     │││  │
│  │  │  │(SageMaker)│  │  │  │(Vertex AI)│  │  │  │(Azure ML) │  │  ││Pipeline│││  │
│  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │  ││(DB    │││  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │  ││Runtime)│││  │
│  │  │  │ETL/ELT    │  │  │  │ETL/ELT    │  │  │  │ETL/ELT    │  │  ││        │││  │
│  │  │  │(Glue)     │  │  │  │(Dataflow) │  │  │  │(DataFact.)│  │  ││(DLT)  │││  │
│  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │  │└────────┘││  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘  └──────────┘│  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           SHARED SERVICES                                       │  │
│  │                                                                                │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │  │
│  │  │   Feature Store │  │  Model Registry │  │  Observability  │                │  │
│  │  │   (Feast)       │  │   (MLflow)      │  │  (LangSmith)    │                │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘                │  │
│  │                                                                                │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │  │
│  │  │  Contract Reg.  │  │   Artifact      │  │  Secrets Mgmt   │                │  │
│  │  │   (Pact)        │  │   Store         │  │   (Vault)        │                │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘                │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Technology Stack Summary

| Layer | Technology | Justification |
|-------|------------|---------------|
| **Frontend** | Next.js 14, React 18, TypeScript | SEO, SSR, Type safety |
| **Backend** | Python + FastAPI | Best ML ecosystem, unified stack |
| **AI Agents** | Google ADK, LangChain, CrewAI | Specialized per pipeline |
| **ML Platforms** | SageMaker, Vertex AI, Azure ML, Databricks | Cloud-native ML |
| **Data Lakes** | S3, GCS, ADLS Gen2, Delta Lake | Scalable storage |
| **ETL** | Glue, Dataflow, Data Factory, DLT | Cloud-specific optimized |
| **IaC** | Terraform | Multi-cloud consistent |
| **CI/CD** | GitHub Actions, ArgoCD | Industry standard |
| **Observability** | Grafana + Prometheus + Loki + Tempo | Unified multi-cloud |
| **Contract Testing** | Pact | API contract validation |

---

## 3. Pipeline Specifications

### 3.1 AWS Pipeline

| Component | Technology | Framework |
|-----------|------------|-----------|
| Frontend | Next.js | React |
| Backend | **Python + FastAPI** | AsyncIO + Pydantic |
| AI Agent | Google ADK | Agent Development Kit |
| ML Platform | SageMaker | Built-in algorithms, custom |
| ETL | AWS Glue | Spark |
| Data Lake | S3 | Parquet, Delta |
| Database | RDS PostgreSQL | Primary DB |
| Cache | ElastiCache Redis | Session, cache |
| IaC | Terraform | AWS-native modules |
| Agent Framework | **Google ADK** | Cloud-agnostic agents |

### 3.2 GCP Pipeline

| Component | Technology | Framework |
|-----------|------------|-----------|
| Frontend | Next.js | React |
| Backend | **Python + FastAPI** | AsyncIO + Pydantic |
| AI Agent | LangChain + LangGraph | Graph-based orchestration |
| ML Platform | Vertex AI | AutoML, custom |
| ETL | Dataflow | Apache Beam |
| Data Lake | GCS + BigQuery | External tables |
| Database | Cloud SQL | PostgreSQL |
| Cache | Memorystore | Redis |
| IaC | Terraform | GCP modules |
| Agent Framework | **LangChain + LangGraph** | Composable agents |

### 3.3 Azure Pipeline

| Component | Technology | Framework |
|-----------|------------|-----------|
| Frontend | Next.js | React |
| Backend | **Python + FastAPI** | AsyncIO + Pydantic |
| AI Agent | CrewAI | Multi-agent orchestration |
| ML Platform | Azure ML | AutoML, Designer |
| ETL | Data Factory | Pipeline orchestration |
| Data Lake | ADLS Gen2 | Delta Lake |
| Database | Azure SQL | PostgreSQL compatible |
| Cache | Azure Cache | Redis |
| IaC | Terraform | Azure modules |
| Agent Framework | **CrewAI** | Team-based agents |

### 3.4 Databricks Pipeline

| Component | Technology | Framework |
|-----------|------------|-----------|
| Frontend | Next.js | React |
| Backend | **Python + FastAPI** | AsyncIO + Pydantic |
| AI Agent | Custom Framework | MLflow + LangServe |
| ML Platform | Databricks Runtime | Spark ML, TensorFlow, PyTorch |
| ETL | Delta Live Tables | Spark SQL |
| Data Lake | Delta Lake | Multi-cloud |
| Database | Databricks SQL | Unity Catalog |
| Cache | Photon | Vectorized engine |
| IaC | Terraform + Databricks Terraform | Workspace provisioning |
| Agent Framework | **Custom + MLflow** | Native integration |

---

## 4. Agent System Architecture

### 4.1 Hybrid Agent Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         AGENT ORCHESTRATION LAYER                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                      UNIFIED META ORCHESTRATOR                               │ │
│  │                                                                               │ │
│  │  • Routes queries to appropriate pipeline agent                              │ │
│  │  • Aggregates responses from multiple agents                                 │ │
│  │  • Maintains conversation context across pipelines                           │ │
│  │  • LangSmith integration for observability                                   │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                            │
│          ┌───────────────────────────┼───────────────────────────┐                 │
│          │                           │                           │                 │
│          ▼                           ▼                           ▼                 │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐       │
│  │    AWS AGENT         │  │    GCP AGENT        │  │    Azure AGENT      │       │
│  │  ┌────────────────┐  │  │  ┌────────────────┐  │  │  ┌────────────────┐  │       │
│  │  │ • Tool: Bedrock│  │  │  │ • Tool: Gemini│  │  │  │ • Tool: AOAI  │  │       │
│  │  │ • Tool: Lambda │  │  │  │ • Tool: Cloud │  │  │  │ • Tool: Azure │  │       │
│  │  │ • Tool: SageMk │  │  │  │   Functions   │  │  │  │   Functions  │  │       │
│  │  │ • RAG: Aurora  │  │  │  │ • RAG: BigQ   │  │  │  │ • RAG: Cosmos │  │       │
│  │  │ • Memory: Redis│  │  │  │ • Memory:Mem. │  │  │  │ • Memory: Redis│  │       │
│  │  │ Framework: ADK │  │  │  │Framework:LC+LG│  │  │  │ Framework:Crew│  │       │
│  │  └────────────────┘  │  │  └────────────────┘  │  │  └────────────────┘  │       │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘       │
│                                      │                                            │
│                                      ▼                                            │
│                          ┌─────────────────────┐                                 │
│                          │  DATABRICKS AGENT   │                                 │
│                          │  ┌────────────────┐  │                                 │
│                          │  │ • Tool: Llama  │  │                                 │
│                          │  │ • Tool: Spark  │  │                                 │
│                          │  │ • RAG: Delta   │  │                                 │
│                          │  │ • Memory: DBSQL│  │                                 │
│                          │  │Framework:Custom│  │                                 │
│                          │  └────────────────┘  │                                 │
│                          └─────────────────────┘                                 │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Per-Pipeline Agent Specifications

| Pipeline | Framework | Backend | AI Agent | ML Platform |
|---------|-----------|---------|----------|-------------|
| **AWS** | Next.js 14 | **Python + FastAPI** | Google ADK | SageMaker |
| **GCP** | Next.js 14 | **Python + FastAPI** | LangChain + LangGraph | Vertex AI |
| **Azure** | Next.js 14 | **Python + FastAPI** | CrewAI | Azure ML |
| **Databricks** | Next.js 14 | **Python + FastAPI** | Custom + MLflow | Databricks Runtime |

---

## 5. Repository Structure

### 5.1 Monorepo Architecture

```
enterprise-mlops-platform/
│
├── PRDs/                                    # All Product Requirements
│   ├── 00-MASTER-ARCHITECTURE-PRD.md
│   ├── 01-FRONTEND-PRD.md
│   ├── 02-BACKEND-PRD.md
│   ├── 03-AWS-PIPELINE-PRD.md
│   ├── 04-GCP-PIPELINE-PRD.md
│   ├── 05-AZURE-PIPELINE-PRD.md
│   ├── 06-DATABRICKS-PIPELINE-PRD.md
│   └── 07-CROSS-PLATFORM-PRD.md
│
├── Makefile                                 # Root Makefile
├── Makefile.common                          # Shared Makefile includes
│
├── .github/
│   └── workflows/                           # GitHub Actions
│       ├── ci.yml                          # Common CI
│       ├── aws-cicd.yml
│       ├── gcp-cicd.yml
│       ├── azure-cicd.yml
│       └── databricks-cicd.yml
│
├── packages/                                # Shared packages (npm/pip)
│   ├── shared/
│   │   ├── types/                          # Shared TypeScript types
│   │   ├── utils/                          # Shared utilities
│   │   ├── constants/                       # Shared constants
│   │   └── config/                         # Shared config schemas
│   │
│   ├── frontend-ui/                         # Shared UI components
│   │   ├── components/
│   │   ├── hooks/
│   │   └── lib/
│   │
│   └── contracts/                           # Pact contract definitions
│       ├── api-contracts.json
│       └── consumer-pacts/
│
├── frontends/                               # Separate Frontend Repos (Professional Practice)
│   │
│   ├── unified-dashboard/                   # MASTER Dashboard (connects all)
│   │   ├── src/
│   │   │   ├── components/bi-embed/       # Power BI & Tableau
│   │   │   ├── pages/
│   │   │   └── services/
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   └── package.json
│   │
│   ├── aws-frontend/
│   │   ├── src/
│   │   │   ├── pages/aws/
│   │   │   └── components/
│   │   ├── Dockerfile
│   │   └── Makefile
│   │
│   ├── gcp-frontend/
│   ├── azure-frontend/
│   └── databricks-frontend/
│
├── backends/                                # Separate Backend Repos (Professional Practice)
│   │
│   ├── unified-api/                         # MASTER API Gateway
│   │   ├── src/
│   │   │   ├── routers/
│   │   │   ├── services/
│   │   │   └── middleware/
│   │   ├── Dockerfile
│   │   └── Makefile
│   │
│   ├── aws-backend/
│   │   ├── src/
│   │   │   ├── api/                        # FastAPI routes
│   │   │   ├── ml/                         # ML inference client
│   │   │   ├── agents/                     # Google ADK agent
│   │   │   └── db/                         # Database connections
│   │   ├── Dockerfile
│   │   └── Makefile
│   │
│   ├── gcp-backend/
│   │   ├── src/
│   │   │   ├── api/                        # FastAPI routes
│   │   │   ├── ml/
│   │   │   ├── agents/                     # LangChain + LangGraph
│   │   │   └── db/
│   │   ├── Dockerfile
│   │   └── Makefile
│   │
│   ├── azure-backend/
│   │   ├── src/
│   │   │   ├── api/                        # FastAPI routes
│   │   │   ├── ml/
│   │   │   ├── agents/                     # CrewAI agents
│   │   │   └── db/
│   │   ├── Dockerfile
│   │   └── Makefile
│   │
│   └── databricks-backend/
│       ├── src/
│       │   ├── api/
│       │   ├── ml/
│       │   ├── agents/                     # Custom MLflow agent
│       │   └── db/
│       ├── Dockerfile
│       └── Makefile
│
├── infrastructure/                          # Terraform IaC
│   │
│   ├── modules/                            # Shared Terraform modules
│   │   ├── vpc/
│   │   ├── ecs-cluster/
│   │   ├── eks-cluster/
│   │   ├── aks-cluster/
│   │   ├── rds/
│   │   ├── alb/
│   │   ├── iam/
│   │   └── secrets/
│   │
│   ├── aws/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── prod/
│   │   └── modules/
│   │
│   ├── gcp/
│   ├── azure/
│   └── databricks/
│
└── mlops/                                   # MLOps configurations
    ├── feature-store/
    │   ├── aws-feast/
    │   ├── gcp-feast/
    │   └── azure-feast/
    │
    ├── model-registry/                      # MLflow server
    │   └── mlflow-server/
    │
    └── monitoring/
        ├── prometheus/
        └── grafana/
```

### 5.2 Why Separate Frontend and Backend Repos?

**Q: Why not a single repository for frontend + backend?**

**A:** Monorepo with independent deployable units:

| Reason | Explanation |
|--------|-------------|
| **Independent Deployments** | Frontend and backend have different release cycles |
| **Team Autonomy** | Frontend team and backend team can work independently |
| **Technology Diversity** | Each can use different tools, languages, CI/CD |
| **Security** | Separate repo = separate permissions, access controls |
| **Scaling** | Each can be scaled, monitored, and debugged independently |
| **Microservices Ready** | Easy to extract individual services later |

---

## 6. Development Workflow

### 6.1 Baby Steps Learning Path

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DEVELOPMENT ROADMAP                                    │
│                           (Per-Cloud Sequential Build)                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  PHASE 1: FOUNDATION (Weeks 1-4)                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Step 1.1: Frontend - Unified Dashboard (Next.js + TypeScript)          │    │
│  │  Step 1.2: Frontend - Pipeline-specific UIs (React + TypeScript)         │    │
│  │  Step 1.3: Backend - Unified API Gateway (Python FastAPI)                 │    │
│  │  Step 1.4: Backend - AWS Backend (Python FastAPI)                        │    │
│  │  Step 1.5: Backend - GCP Backend (Python FastAPI)                        │    │
│  │  Step 1.6: Backend - Azure Backend (Python FastAPI)                      │    │
│  │  Step 1.7: Backend - Databricks Backend (Python FastAPI)                  │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  PHASE 2: AWS PIPELINE (Weeks 5-8)                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Step 2.1: AWS VPC, ECS, RDS (Terraform)                                │    │
│  │  Step 2.2: AWS SageMaker Pipeline (CNN, RNN)                             │    │
│  │  Step 2.3: AWS AI Agent (Google ADK)                                    │    │
│  │  Step 2.4: AWS CI/CD (GitHub Actions)                                   │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  PHASE 3: GCP PIPELINE (Weeks 9-11)                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Step 3.1: GCP VPC, GKE, Cloud SQL (Terraform)                          │    │
│  │  Step 3.2: GCP Vertex AI Pipeline (CNN, RNN)                           │    │
│  │  Step 3.3: GCP AI Agent (LangChain + LangGraph)                         │    │
│  │  Step 3.4: GCP CI/CD (Cloud Build)                                     │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  PHASE 4: AZURE PIPELINE (Weeks 12-14)                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Step 4.1: Azure VNet, AKS, Azure SQL (Terraform)                     │    │
│  │  Step 4.2: Azure ML Pipeline (CNN, RNN)                                │    │
│  │  Step 4.3: Azure AI Agent (CrewAI)                                     │    │
│  │  Step 4.4: Azure CI/CD (Azure DevOps)                                  │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  PHASE 5: DATABRICKS PIPELINE (Weeks 15-17)                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Step 5.1: Databricks Workspace, Unity Catalog (Terraform)               │    │
│  │  Step 5.2: Databricks ML Pipeline (CNN, RNN, LLM)                        │    │
│  │  Step 5.3: Databricks AI Agent (Custom + MLflow)                        │    │
│  │  Step 5.4: Databricks CI/CD                                            │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  PHASE 6: CROSS-PLATFORM INTEGRATION (Weeks 18-20)                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Step 6.1: Federated Query (Trino/Presto)                               │    │
│  │  Step 6.2: Cross-Cloud Event Bus (Kafka/MQ)                           │    │
│  │  Step 6.3: Contract Testing (Pact)                                     │    │
│  │  Step 6.4: E2E Testing (Playwright)                                     │    │
│  │  Step 6.5: Performance & Security Testing                              │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Per-Section Testing Strategy

```makefile
# After each section, run:
# make test SECTION=<section-name>

# Example:
# make test SECTION=frontend      # Tests all frontend
# make test SECTION=backend      # Tests all backend
# make test SECTION=aws-infra    # Tests AWS infrastructure
# make test SECTION=contracts    # Runs contract tests
```

---

## 7. Cost Management Strategy

### 7.1 Cost Optimization Per Pipeline

| Pipeline | Key Cost Drivers | Optimization Strategy |
|----------|------------------|----------------------|
| AWS | SageMaker, ECS, RDS | Spot instances, reserved capacity |
| GCP | Vertex AI, GKE | Committed use discounts |
| Azure | Azure ML, AKS | Hybrid benefits |
| Databricks | DBUs | Auto-scaling, spot instances |

### 7.2 Cost-Saving Tips Per Section

**After each pipeline section, we'll include:**
```
💰 COST-SAVING CHECKPOINTS

After completing AWS Pipeline:
□ Turn off SageMaker endpoints when not in use
□ Stop ECS tasks during off-hours
□ Delete test RDS instances
□ Remove unused S3 buckets
□ Disable CloudWatch detailed monitoring
```

---

## 8. Success Metrics

### 8.1 Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Pipeline Build Time | < 10 min | GitHub Actions duration |
| Deployment Frequency | Multiple/day | Deployments/week |
| Lead Time for Changes | < 1 hour | Commit to production |
| Change Failure Rate | < 5% | Failed deploys/total |
| MTTR | < 1 hour | Incident to resolution |
| Test Coverage | > 80% | Code coverage tools |
| Contract Test Coverage | 100% | Pact broker coverage |

### 8.2 Business Metrics

| Metric | Target |
|--------|--------|
| Model Deployment Time | < 15 min |
| Cost per ML Job | < $0.50/GB |
| Cross-Cloud Query Latency | < 500ms |
| Agent Response Time | < 3 sec |

---

## 8.3 Shared Infrastructure Services

### Why HashiCorp Vault Over Cloud-Native Secrets Managers?

**Q: Why use HashiCorp Vault instead of AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault?**

**A:** Vault provides cloud-agnostic secrets management essential for multi-cloud platforms:

| Aspect | AWS Secrets Manager | GCP Secret Manager | Azure Key Vault | HashiCorp Vault (Chosen) |
|--------|---------------------|--------------------| ----------------|-------------------------|
| Cloud-Agnostic | AWS only | GCP only | Azure only | All clouds |
| Multi-Cloud Support | Requires separate setup | Requires separate setup | Requires separate setup | Single backend, all clouds |
| Secret Rotation | Built-in | Built-in | Built-in | Built-in + dynamic secrets |
| Policy Engine | IAM-based | IAM-based | RBAC-based | Fine-grained ACLs |
| Encryption | AWS-managed | GCP-managed | Azure-managed | Customer-managed (BYOK) |
| Cost | Per-secret fees | Per-secret fees | Per-vault fees | Single self-hosted or HaaS |

**Key advantages for this project:**
- **Single secrets management** across AWS, GCP, Azure, and Databricks
- **Dynamic secrets** - generate temporary credentials per pipeline
- **Encryption as a service** -统一 encryption layer across all clouds
- **Policy-as-code** - Vault policies in Terraform for audit compliance
- **No per-secret egress costs** - predictable self-hosted cost

**Architecture:**
```
                    ┌──────────────────────────────────────┐
                    │        HashiCorp Vault Cluster         │
                    │   (Self-hosted or HaaS on any cloud)  │
                    └─────────────┬────────────────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         ▼
┌───────────────┐         ┌───────────────┐         ┌───────────────┐
│  AWS Pipeline │         │  GCP Pipeline │         │ Azure Pipeline│
│  • RDS creds  │         │  • Cloud SQL  │         │  • Azure SQL  │
│  • SageMaker  │         │  • Vertex AI  │         │  • Azure ML   │
│  • S3 keys    │         │  • GCS keys  │         │  • Blob keys  │
└───────────────┘         └───────────────┘         └───────────────┘
                                  │
                                  ▼
                        ┌───────────────┐
                        │Databricks Pipe│
                        │  • PAT tokens  │
                        │  • UC scopes  │
                        └───────────────┘
```

**Implementation:** Vault deployed via Terraform using the official HashiCorp provider. Each pipeline gets its own Vault namespace with policies restricting cross-pipeline access.

---

### Observability Stack

**Q: Why choose a unified observability stack over cloud-native tools?**

**A:** Multi-cloud requires centralized logging, metrics, and tracing:

| Component | Cloud-Native Option | Unified Option (Chosen) |
|-----------|--------------------|-------------------------|
| **Logs** | CloudWatch, Stackdriver, Azure Monitor | Grafana Loki + Promtail |
| **Metrics** | CloudWatch, Stackdriver, Azure Monitor | Prometheus + Grafana |
| **Traces** | X-Ray, Cloud Trace, Application Insights | Grafana Tempo + OpenTelemetry |
| **Dashboards** | CloudWatch Dashboards, GCP Dashboard | Grafana Dashboards |
| **Alerting** | CloudWatch Alerts, AlertManager | Grafana Alerting + PagerDuty |

**Why unified over cloud-native:**
- Single query language (PromQL) across all clouds
- One dashboard per pipeline, not per cloud
- Consistent alerting rules regardless of cloud provider
- Cost predictability (self-hosted or Grafana Cloud)

---

### API Gateway Decision

**Q: How do we unify the 4 backends (AWS, GCP, Azure, Databricks)?**

**A:** We'll use **Kong Gateway** (cloud-agnostic) as the API gateway:

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| AWS API Gateway | Managed, AWS-native | AWS-only | ❌ |
| Kong Gateway | Cloud-agnostic, plugins, K8s native | Self-managed | ✅ **Chosen** |
| Azure API Gateway | Azure-native | Azure-only | ❌ |
| Custom FastAPI aggregation | Full control | Dev time, maintenance | ❌ |

**Kong chosen because:**
- Works on all clouds (AWS, GCP, Azure, self-hosted)
- Plugin ecosystem (auth, rate-limiting, transforms)
- Kubernetes-native with Ingress controller
- Declarative configuration via deck/YAML

**ADR to create:** Document the Kong decision with alternatives considered and rationale.

---

### RBAC/ABAC Access Control Model

**Q: How do we manage access control across 4 cloud providers?**

**A:** Unified access control using HashiCorp Vault Identity + Kubernetes auth:

| Layer | Technology | Purpose |
|-------|------------|---------|
| Identity Provider | Vault Identity (OIDC) | Unified identity across clouds |
| Authentication | Vault Kubernetes Auth | All 4 clouds use K8s service accounts |
| Authorization | Vault Policies (RBAC) | Least-privilege policies per pipeline |
| Audit | Vault Audit + Grafana Loki | All access logged and traceable |

**Access Control Matrix:**

| Role | Frontend | AWS Backend | GCP Backend | Azure Backend | Databricks | Secrets |
|------|----------|-------------|-------------|---------------|------------|---------|
| Developer | Read | Read | Read | Read | - | - |
| ML Engineer | - | Full | Full | Full | Full | - |
| Data Engineer | - | Write | Write | Write | Write | - |
| SecOps | Full | Full | Full | Full | Full | Full |

**Vault Policy Example:**
```hcl
# mlops-aws-policy.hcl
path "mlops/aws/*" {
  capabilities = ["read", "list"]
}

path "mlops/aws/database" {
  capabilities = ["read"]  # Developers can read, not write
}

# ML Engineers can create dynamic credentials
path "mlops/aws/creds/ml-engineer-role" {
  capabilities = ["read", "create"]
}
```

**Why not cloud-native IAM?**
- AWS IAM, GCP IAM, Azure AD are cloud-specific
- Cross-cloud access requires separate configuration per cloud
- Vault provides single policy language across all clouds
- Easier audit trail: one place to check "who accessed what"

---

### Prompt Injection Mitigation

**Q: How do we prevent prompt injection attacks on AI agents?**

**A:** Defense-in-depth approach for RAG systems:

| Layer | Mitigation | Implementation |
|-------|------------|----------------|
| Input Validation | Sanitize user input before embedding | Strip special characters, limit length |
| Context Management | Truncate context to prevent overflow | Max 8K tokens per LLM call |
| Output Validation | Pydantic schema validation on responses | Reject malformed outputs |
| Query Filtering | Block dangerous query patterns | Regex: SQL injection, shell commands |

**Agent Security Patterns:**
```python
# Prompt injection defense in agent code
from pydantic import BaseModel, validator

class AgentQuery(BaseModel):
    user_input: str

    @validator('user_input')
    def sanitize_input(cls, v):
        # Remove potential prompt injection patterns
        dangerous_patterns = [
            r'\bignore\s+(previous|above|all)\b',
            r'\{\{.*\}\}',  # Template injection
            r'<script.*>.*</script>',  # XSS
        ]
        for pattern in dangerous_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("Potentially malicious input detected")

        # Limit input length (prevent context overflow)
        if len(v) > 2000:
            raise ValueError("Input exceeds maximum length")

        return v.strip()
```

---

### 8.4 A/B Testing for Model Selection

**Q: How do we objectively compare models across clouds and select the best one?**

**A:** Centralized A/B testing infrastructure with statistical rigor:

| Component | Technology | Purpose |
|-----------|------------|---------|
| Traffic Splitting | Kong plugin | Route % of traffic to each model |
| Metrics Collection | Prometheus | Capture predictions, latency, errors |
| Statistical Analysis | Python/SciPy | Compute significance, confidence intervals |
| Model Registry | MLflow | Track all model versions and their performance |

**Architecture:**
```
                    ┌────────────────────────────────────────────┐
                    │           A/B Test Controller              │
                    │  (Kong Plugin + Prometheus + MLflow)       │
                    └──────────────────┬─────────────────────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
        ▼                              ▼                              ▼
┌───────────────┐            ┌───────────────┐            ┌───────────────┐
│ Model A (v1)  │            │ Model B (v2)  │            │ Model C (v3)  │
│   SageMaker   │            │   Vertex AI   │            │   Azure ML    │
│   33% traffic │            │   33% traffic │            │   34% traffic │
└───────────────┘            └───────────────┘            └───────────────┘
        │                              │                              │
        └──────────────────────────────┼──────────────────────────────┘
                                       ▼
                        ┌─────────────────────────────┐
                        │     MLflow (Comparison)      │
                        │  ROC-AUC, Latency, Error Rate│
                        └─────────────────────────────┘
```

**Statistical Test Implementation:**
```python
# mlops/ab_testing/statistical_analysis.py

import numpy as np
from scipy import stats

def analyze_ab_test(control_results: list, treatment_results: list,
                   metric: str = "auc_roc") -> dict:
    """
    Analyze A/B test results using two-proportion z-test.
    Returns lift, p-value, confidence interval, and recommendation.
    """
    control = np.array(control_results)
    treatment = np.array(treatment_results)

    # Compute means
    control_mean = np.mean(control)
    treatment_mean = np.mean(treatment)

    # Two-proportion z-test
    n_control = len(control)
    n_treatment = len(treatment)
    pooled_p = (np.sum(control) + np.sum(treatment)) / (n_control + n_treatment)
    se = np.sqrt(pooled_p * (1 - pooled_p) * (1/n_control + 1/n_treatment))
    z = (treatment_mean - control_mean) / se
    p_value = 2 * (1 - stats.norm.cdf(abs(z)))

    # Confidence interval
    ci_95 = (
        (treatment_mean - control_mean) - 1.96 * se,
        (treatment_mean - control_mean) + 1.96 * se
    )

    # Lift calculation
    lift = (treatment_mean - control_mean) / control_mean * 100

    return {
        "metric": metric,
        "control_mean": control_mean,
        "treatment_mean": treatment_mean,
        "lift_percent": lift,
        "p_value": p_value,
        "significant": p_value < 0.05,
        "ci_95": ci_95,
        "recommendation": "promote" if p_value < 0.05 and lift > 0 else "reject"
    }

def calculate_sample_size(baseline_rate: float, mde: float,
                         alpha: float = 0.05, power: float = 0.8) -> int:
    """
    Calculate required sample size per variant.
    baseline_rate: current conversion rate (e.g. 0.10)
    mde: minimum detectable effect (relative, e.g. 0.05 = 5% lift)
    """
    p1 = baseline_rate
    p2 = baseline_rate * (1 + mde)
    effect_size = abs(p2 - p1) / np.sqrt((p1 * (1 - p1) + p2 * (1 - p2)) / 2)
    z_alpha = stats.norm.ppf(1 - alpha / 2)
    z_beta = stats.norm.ppf(power)
    n = ((z_alpha + z_beta) / effect_size) ** 2
    return int(np.ceil(n))
```

**A/B Test Checklist:**
1. Define ONE primary metric pre-registration (e.g., AUC-ROC)
2. Calculate sample size BEFORE starting test
3. Randomize at user level (not session) to avoid leakage
4. Run for at least 1 full business cycle (typically 2 weeks)
5. Check for sample ratio mismatch: `|n_control - n_treatment| / expected < 0.01`
6. Report lift + CI, not just p-value
7. Apply Bonferroni correction if testing multiple metrics: `alpha / n_metrics`

---

### 8.5 Data Drift Detection Implementation

**Q: How do we detect when our model's input data has shifted significantly?**

**A:** Population Stability Index (PSI) monitoring with automated alerts:

| Metric | Warning Threshold | Critical Threshold | Action |
|--------|------------------|--------------------|--------|
| PSI (feature drift) | > 0.1 | > 0.2 | Retrain model |
| Prediction distribution | > 5% shift | > 10% shift | Alert + investigate |
| Data quality | > 1% nulls | > 5% nulls | Block inference |

**Drift Detection Implementation:**
```python
# mlops/monitoring/drift_detector.py

import numpy as np
from scipy.stats import ks_2samp
from prometheus_client import Counter, Histogram, Gauge

drift_alerts = Counter(
    "drift_alerts_total",
    "Total drift detection alerts",
    ["pipeline", "feature"]
)

class DriftDetector:
    def __init__(self, reference_data: np.ndarray, threshold: float = 0.2):
        self.reference_data = reference_data
        self.threshold = threshold
        self.reference_stats = {
            "mean": np.mean(reference_data),
            "std": np.std(reference_data),
            "median": np.median(reference_data),
            "p5": np.percentile(reference_data, 5),
            "p95": np.percentile(reference_data, 95),
        }

    def compute_psi(self, expected: np.ndarray, actual: np.ndarray,
                    bins: int = 10) -> float:
        """
        Compute Population Stability Index (PSI).
        PSI < 0.1: No significant drift
        0.1 <= PSI < 0.2: Moderate drift, monitor
        PSI >= 0.2: Significant drift, retrain needed
        """
        # Create bins from expected distribution
        breakpoints = np.histogram_bin_edges(expected, bins=bins)
        expected_counts = np.histogram(expected, bins=breakpoints)[0]
        actual_counts = np.histogram(actual, bins=breakpoints)[0]

        # Calculate proportions
        expected_pct = expected_counts / len(expected)
        actual_pct = actual_counts / len(actual)

        # Avoid division by zero
        expected_pct = np.where(expected_pct == 0, 1e-6, expected_pct)
        actual_pct = np.where(actual_pct == 0, 1e-6, actual_pct)

        # Compute PSI
        psi = np.sum(
            (actual_pct - expected_pct) * np.log(actual_pct / expected_pct)
        )
        return psi

    def detect_drift(self, current_data: np.ndarray) -> dict:
        """Detect drift and return alert + metrics."""
        psi = self.compute_psi(self.reference_data, current_data)

        # KS test for additional validation
        ks_stat, p_value = ks_2samp(self.reference_data, current_data)

        drift_detected = psi > self.threshold

        if drift_detected:
            drift_alerts.labels(pipeline=self.pipeline, feature="all").inc()

        return {
            "drift_detected": drift_detected,
            "psi": psi,
            "ks_statistic": ks_stat,
            "ks_p_value": p_value,
            "recommendation": "retrain" if psi > 0.2 else "monitor" if psi > 0.1 else "ok"
        }
```

**Alert Configuration (Prometheus + Grafana):**
```yaml
# prometheus/drift-alerts.yml
groups:
  - name: drift_detection
    rules:
      - alert: ModelFeatureDriftWarning
        expr: psi_feature > 0.1 and psi_feature < 0.2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Feature drift detected in {{ $labels.pipeline }}"
          description: "PSI is {{ $value }}, consider retraining soon"

      - alert: ModelFeatureDriftCritical
        expr: psi_feature >= 0.2
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Critical feature drift in {{ $labels.pipeline }}"
          description: "PSI is {{ $value }}, immediate retrain required"
```

---

### 8.6 Security Configuration (SAST/DAST + Incident Response)

**Q: How do we continuously test for vulnerabilities in our CI/CD pipeline?**

**A:** Layered security testing at every stage:

| Stage | Tool | Checks |
|-------|------|--------|
| Pre-commit | Semgrep | Static analysis, secrets scanning |
| CI/CD | Trivy | Container image vulnerabilities |
| CI/CD | OWASP ZAP | DAST (dynamic scanning) |
| Production | WAF | Real-time attack blocking |

**SAST Configuration (Semgrep):**
```yaml
# .github/workflows/sast.yml

name: SAST Security Scan

on: [push, pull_request]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: returntocorp/semgrep-action@v1
        with:
          config: >
            p/owasp-top-ten
            p/nodejsscan
            p/python
          generateSarif: true
      - name: Upload to GitHub Advanced Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: semgrep.sarif
```

**DAST Configuration (OWASP ZAP):**
```yaml
# .github/workflows/dast.yml

name: DAST Security Scan

on: [push, pull_request]

jobs:
  zap_scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run ZAP scan
        uses: zaproxy/action-baseline@v0.9.0
        with:
          target: 'https://api.staging.behemoth.ai/api/v2/health'
          docker_name: 'owasp/zap2docker-stable'
          cmd: 'zap-baseline.py -t https://api.staging.behemoth.ai -J zap_output.json'

      - name: Upload results
        uses: upload-artifact@v3
        with:
          name: zap-report
          path: zap_output.json
```

**Incident Response Plan:**
```markdown
# Security Incident Response Runbook

## Severity Levels

| Level | Description | Response Time | Examples |
|-------|-------------|---------------|----------|
| P1 - Critical | Active breach, data exfiltration | Immediate | Ransomware, unauthorized access |
| P2 - High | Confirmed vulnerability, no active exploitation | 1 hour | Critical CVE, exposed credentials |
| P3 - Medium | Potential vulnerability | 4 hours | XSS, injection (low impact) |
| P4 - Low | Informational | 24 hours | Configuration issue, informational |

## Response Workflow

1. **Identification** (0-15 min)
   - Validate alert is genuine (not false positive)
   - Assess initial scope and severity
   - Activate incident channel in Slack (#security-incidents)

2. **Containment** (15-60 min)
   - Isolate affected systems (kill credentials, block IPs)
   - Preserve evidence (logs, memory dumps)
   - Update WAF rules to block attack vector

3. **Eradication** (1-4 hours)
   - Patch or mitigate vulnerability
   - Rotate all potentially compromised credentials
   - Scan for backdoors or persistence mechanisms

4. **Recovery** (4-24 hours)
   - Restore from clean backups
   - Verify system integrity
   - Gradual resume of services with increased monitoring

5. **Post-Incident** (1-7 days)
   - Timeline reconstruction
   - Root cause analysis (RCA)
   - Update detection rules
   - Update runbooks
```

---

## 9. Next Steps

1. **Review and approve this PRD**
2. **Proceed to create Frontend PRD** (01-FRONTEND-PRD.md)
3. **Begin Frontend implementation** with Baby Steps 1.1-1.2
4. **Create API Gateway ADR** documenting Kong decision

---

**Document Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-16 | Saiyudh | Initial draft |
