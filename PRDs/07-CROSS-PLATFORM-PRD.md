# PRD 07 - Cross-Platform Integration

**Version:** 1.0  
**Date:** 2026-04-16  
**Related To:** Master PRD, All Pipeline PRDs  
**Status:** Draft

---

## 1. Cross-Platform Architecture Overview

### 1.1 What Are We Building?

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        CROSS-PLATFORM INTEGRATION LAYER                               │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                    UNIFIED DATA LAYER                                           │  │
│  │                                                                                │  │
│  │   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐                 │  │
│  │   │    AWS      │      │    GCP      │      │   Azure     │                 │  │
│  │   │   S3        │◄────►│   GCS        │◄────►│   ADLS     │                 │  │
│  │   │  (Bronze)   │      │  (Bronze)   │      │  (Bronze)   │                 │  │
│  │   └──────┬──────┘      └──────┬──────┘      └──────┬──────┘                 │  │
│  │          │                    │                    │                        │  │
│  │          └────────────────────┼────────────────────┘                        │  │
│  │                               ▼                                               │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐    │  │
│  │   │                     DATA FEDERATION (Presto/Trino)                    │    │  │
│  │   │                                                                              │    │  │
│  │   │   • Cross-cloud SQL queries                                            │    │  │
│  │   │   • Unified data catalog                                               │    │  │
│  │   │   • Federated joins                                                    │    │  │
│  │   │   • Cost-based optimization                                             │    │  │
│  │   └─────────────────────────────────────────────────────────────────────┘    │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           EVENT BUS LAYER                                      │  │
│  │                                                                                │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐    │  │
│  │   │                     EVENT MESH (Kafka/MQ)                             │    │  │
│  │   │                                                                              │    │  │
│  │   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │    │  │
│  │   │  │ AWS EventBridge│ │ GCP Pub/Sub │  │ Azure Event │  │ DB Spark    │  │    │  │
│  │   │  │              │  │             │  │  Hubs       │  │ Streaming   │  │    │  │
│  │   │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │    │  │
│  │   │         └────────────────┼─────────────────┼────────────────┘         │    │  │
│  │   │                          ▼                   ▼                        │    │  │
│  │   │   ┌───────────────────────────────────────────────────────────────┐  │    │  │
│  │   │   │              Unified Event Schema (CloudEvents)                 │  │    │  │
│  │   │   │                                                                              │  │    │
│  │   │   │  {                                                               │  │    │  │
│  │   │   │    "specversion": "1.0",                                        │  │    │  │
│  │   │   │    "type": "ml.pipeline.completed",                            │  │    │  │
│  │   │   │    "source": "aws-sagemaker",                                  │  │    │  │
│  │   │   │    "datacontenttype": "application/json",                       │  │    │  │
│  │   │   │    "data": {                                                    │  │    │  │
│  │   │   │      "pipeline_id": "...",                                      │  │    │  │
│  │   │   │      "model_version": "v2",                                    │  │    │  │
│  │   │   │      "metrics": {...}                                          │  │    │  │
│  │   │   │    }                                                            │  │    │  │
│  │   │   │  }                                                               │  │    │  │
│  │   │   └───────────────────────────────────────────────────────────────┘  │    │  │
│  │   └─────────────────────────────────────────────────────────────────────┘    │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           SHARED SERVICES LAYER                                │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │ LangSmith  │  │   Vault     │  │  Pact      │  │ MLflow     │           │  │
│  │  │(Observability│  │(Secrets)   │  │(Contracts) │  │ Registry   │           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Agent traces│  │ Cross-cloud│  │ API compat │  │ Model      │           │  │
│  │  │ Cross-pipe  │  │ secrets     │  │ validation │  │ versioning │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Cross-Platform Components

### 2.1 Unified API Gateway

```yaml
# unified-gateway/routes.yaml

routes:
  # AWS Pipeline Routes
  - path: /api/v1/aws/*
    upstream: http://aws-backend:8081
    methods: [GET, POST, PUT, DELETE]
    
  - path: /api/v1/aws/ml
    upstream: http://aws-backend:8081/ml
    methods: [POST]
    
  # GCP Pipeline Routes
  - path: /api/v1/gcp/*
    upstream: http://gcp-backend:8082
    methods: [GET, POST, PUT, DELETE]
    
  # Azure Pipeline Routes
  - path: /api/v1/azure/*
    upstream: http://azure-backend:8083
    methods: [GET, POST, PUT, DELETE]
    
  # Databricks Pipeline Routes
  - path: /api/v1/databricks/*
    upstream: http://databricks-backend:8084
    methods: [GET, POST, PUT, DELETE]

  # Cross-Platform Routes
  - path: /api/v1/federated/*
    upstream: http://trino-gateway:8080
    methods: [GET]
```

### 2.2 Federated Query (Trino)

```sql
-- federated-queries/cross_cloud_analytics.sql

-- Example: Aggregate customer data across all clouds
SELECT 
    'AWS' as source,
    customer_id,
    SUM(transaction_amount) as total_spend,
    COUNT(*) as transaction_count
FROM aws_catalog.silver.transactions
GROUP BY customer_id

UNION ALL

SELECT 
    'GCP' as source,
    customer_id,
    SUM(transaction_amount) as total_spend,
    COUNT(*) as transaction_count
FROM gcp_catalog.silver.transactions
GROUP BY customer_id

UNION ALL

SELECT 
    'Azure' as source,
    customer_id,
    SUM(transaction_amount) as total_spend,
    COUNT(*) as transaction_count
FROM azure_catalog.silver.transactions
GROUP BY customer_id

-- Join with Databricks gold layer for final aggregation
WITH all_cloud_data AS (
    -- Union all above
)

SELECT 
    c.customer_id,
    c.source,
    c.total_spend,
    c.transaction_count,
    g.segment,
    g.churn_risk
FROM all_cloud_data c
LEFT JOIN databricks_catalog.gold.customer_analytics g
    ON c.customer_id = g.customer_id
ORDER BY c.total_spend DESC;
```

### 2.3 Event Schema (CloudEvents)

```python
# cross-platform/events/schemas.py

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime
from enum import Enum

class PipelineSource(str, Enum):
    AWS = "aws"
    GCP = "gcp"
    AZURE = "azure"
    DATABRICKS = "databricks"

class EventType(str, Enum):
    # ML Events
    TRAINING_STARTED = "ml.training.started"
    TRAINING_COMPLETED = "ml.training.completed"
    MODEL_DEPLOYED = "ml.model.deployed"
    MODEL_PREDICTION = "ml.prediction.requested"
    
    # Data Events
    DATA_INGESTED = "data.ingested"
    DATA_TRANSFORMED = "data.transformed"
    DATA_QUALITY_CHECK = "data.quality.check"
    
    # Deployment Events
    DEPLOYMENT_STARTED = "deployment.started"
    DEPLOYMENT_COMPLETED = "deployment.completed"
    DEPLOYMENT_ROLLED_BACK = "deployment.rolled_back"

class CloudEvent(BaseModel):
    """CloudEvents specification"""
    specversion: str = Field(default="1.0")
    type: EventType
    source: PipelineSource
    subject: Optional[str] = None
    id: str
    time: datetime = Field(default_factory=datetime.utcnow)
    datacontenttype: str = "application/json"
    data: Dict[str, Any]
    
    class Config:
        use_enum_values = True

class TrainingEvent(CloudEvent):
    """Training pipeline event"""
    data: Dict[str, Any] = Field(default_factory=lambda: {
        "pipeline_id": "",
        "job_id": "",
        "model_type": "",
        "hyperparameters": {},
        "dataset_info": {}
    })

class DeploymentEvent(CloudEvent):
    """Deployment event"""
    data: Dict[str, Any] = Field(default_factory=lambda: {
        "model_name": "",
        "version": "",
        "environment": "",
        "endpoint": "",
        "traffic_percentage": 100
    })

class DataEvent(CloudEvent):
    """Data pipeline event"""
    data: Dict[str, Any] = Field(default_factory=lambda: {
        "table_name": "",
        "row_count": 0,
        "schema_hash": "",
        "quality_score": 0.0
    })
```

---

## 3. Shared Services Integration

### 3.1 LangSmith for Cross-Platform Observability

```python
# cross-platform/observability/langsmith_setup.py

from langsmith import Client
from typing import Dict, Any, List
import os

class CrossPlatformObservability:
    """
    Unified observability across all 4 pipeline agents
    """
    
    def __init__(self, api_key: str = None):
        self.client = Client(api_key=api_key or os.environ.get("LANGCHAIN_API_KEY"))
        self.project_name = "enterprise-mlops-platform"
    
    def create_pipeline_project(self, pipeline: str):
        """Create project for each pipeline"""
        self.client.create_project(
            project_name=f"{pipeline}-agent",
            description=f"AI Agent for {pipeline.upper()} Pipeline",
            metadata={
                "cloud": pipeline,
                "framework": self._get_framework(pipeline)
            }
        )
    
    def _get_framework(self, pipeline: str) -> str:
        frameworks = {
            "aws": "Google ADK",
            "gcp": "LangChain + LangGraph",
            "azure": "CrewAI",
            "databricks": "Custom + LangServe"
        }
        return frameworks.get(pipeline, "Unknown")
    
    def trace_agent_run(
        self,
        pipeline: str,
        input_text: str,
        output_text: str,
        tools_used: List[str],
        latency_ms: float
    ):
        """Trace agent execution"""
        self.client.create_run(
            project_name=f"{pipeline}-agent",
            run_type="chain",
            inputs={"text": input_text},
            outputs={"text": output_text},
            metadata={
                "tools_used": tools_used,
                "latency_ms": latency_ms,
                "cloud": pipeline
            }
        )
    
    def get_cross_platform_metrics(self) -> Dict[str, Any]:
        """Aggregate metrics across all pipelines"""
        metrics = {}
        for pipeline in ["aws", "gcp", "azure", "databricks"]:
            project = f"{pipeline}-agent"
            runs = self.client.list_runs(
                project_name=project,
                run_type="chain"
            )
            metrics[pipeline] = {
                "total_runs": len(runs),
                "avg_latency": sum(r.latency_ms for r in runs) / len(runs) if runs else 0,
                "success_rate": self._calc_success_rate(runs)
            }
        return metrics
    
    def _calc_success_rate(self, runs: List) -> float:
        if not runs:
            return 0.0
        successful = sum(1 for r in runs if r.status == "completed")
        return successful / len(runs) * 100
```

### 3.2 HashiCorp Vault for Cross-Cloud Secrets

```hcl
# infrastructure/shared/vault/main.tf

# Vault Configuration for Cross-Cloud Secrets

resource "vault_mount" "secret" {
  path = "secret"
  type = "kv-v2"
  description = "Generic secrets for cross-platform"
}

# AWS Secrets
resource "vault_aws_secret_backend" "aws" {
  path = "aws"
  region = "us-east-1"
}

# GCP Secrets (requires GCP provider)
resource "vault_generic_secret" "gcp-sa-key" {
  path = "gcp/service-account-key"
  data_json = jsonencode({
    "type" = "service_account"
    "project_id" = var.gcp_project_id
    # ... other fields
  })
}

# Azure Secrets
resource "vault_azure_secret_backend" "azure" {
  path = "azure"
  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_tenant_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
}

# Databricks Secrets Scope
resource "vault_databricks_secret_backend" "databricks" {
  path = "databricks"
  # Configure Databricks scope
}
```

---

## 3.5 Cross-Cloud Network Security

**Q: How do we secure data in transit between clouds?**

**A:** Private connectivity via cloud-native Private Link services:

| Cloud Pair | Connection Method | Service |
|------------|------------------|---------|
| AWS ↔ GCP | AWS PrivateLink + GCP Private Service Connect | Transit between VPCs |
| AWS ↔ Azure | AWS PrivateLink + Azure Private Link | Transit via VPN gateway |
| AWS ↔ Databricks | AWS PrivateLink + Databricks Private Link | Direct cloud connection |
| GCP ↔ Azure | GCP Private Service Connect + Azure Private Link | Direct cross-cloud |

**Architecture:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CROSS-CLOUD PRIVATE CONNECTIVITY                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   │      AWS        │         │       GCP       │         │     Azure       │
│   │                 │         │                 │         │                 │
│   │  ┌───────────┐  │         │  ┌───────────┐  │         │  ┌───────────┐  │
│   │  │ Private   │  │         │  │ Private   │  │         │  │ Private   │  │
│   │  │   Link    │  │◄──────►│  │ Service  │  │◄──────►│  │   Link    │  │
│   │  │ Endpoint  │  │         │  │ Connect  │  │         │  │ Endpoint  │  │
│   │  └───────────┘  │         │  └───────────┘  │         │  └───────────┘  │
│   │       │        │         │       │         │         │       │        │
│   │       └────────┼─────────┼───────┼─────────┼─────────┼───────┘        │
│   │                 │         │       │         │         │                 │
│   │                 └─────────┼───────┴─────────┼─────────┘                 │
│   │                           │                   │                           │
│   │                 ┌─────────┴───────────────────┴─────────┐              │
│   │                 │      Cross-Cloud VPN / Transit        │              │
│   │                 │  (AWS Transit Gateway / Azure VWAN)    │              │
│   │                 └────────────────────────────────────────┘              │
│   │                                        │                                │
│   │                                        ▼                                │
│   │                              ┌─────────────────┐                        │
│   │                              │   Databricks    │                        │
│   │                              │  Private Link   │                        │
│   │                              └─────────────────┘                        │
│   └─────────────────────────────────────────────────────────────────────────┘
```

**Terraform Configuration per Cloud:**

```hcl
# AWS Side (PrivateLink for Databricks)
resource "aws_vpc_endpoint" "databricks_private" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.vpce.us-east-1.vpce-xxx"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.private_endpoint.id]
  subnet_ids         = var.private_subnet_ids

  # Enable DNS resolution for cross-cloud access
  private_dns_enabled = true
}
```

**Security Groups:**
```hcl
# Allow only encrypted traffic between clouds
resource "aws_security_group_rule" "cross_cloud_mtls" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cross_cloud.id
  description              = "mTLS from cross-cloud services"
}
```

---

## 3.6 Unified MLflow Registry

**Q: How do we track ML experiments across 4 clouds?**

**A:** Centralized MLflow tracking server with per-cloud experiment registration:

| Component | Technology | Purpose |
|-----------|------------|---------|
| Tracking Server | MLflow (self-hosted on AWS) | Central experiment registry |
| Artifact Storage | S3 + cross-cloud access | Model storage, cross-pipeline access |
| Metadata | PostgreSQL | Experiment metadata, metrics |
| UI | MLflow UI | Unified dashboard for all experiments |

**Architecture:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        UNIFIED MLFLOW REGISTRY                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                   MLflow Tracking Server (AWS)                        │  │
│   │                                                                        │  │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │  │
│   │   │     AWS     │  │     GCP     │  │   Azure     │  │  Databricks │ │  │
│   │   │  Experiments│  │  Experiments│  │  Experiments│  │  Experiments│ │  │
│   │   │  SageMaker  │  │  Vertex AI  │  │  Azure ML   │  │  Databricks │ │  │
│   │   │     │       │  │     │       │  │     │       │  │     │       │ │  │
│   │   │     ▼       │  │     ▼       │  │     ▼       │  │     ▼       │ │  │
│   │   │  mlflow.   │  │  mlflow.    │  │  mlflow.    │  │  mlflow.    │ │  │
│   │   │  log()      │  │  log()      │  │  log()      │  │  log()      │ │  │
│   │   └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │  │
│   │                             │                                             │  │
│   │                             ▼                                             │  │
│   │                  ┌─────────────────────┐                                  │  │
│   │                  │  Central MLflow    │                                  │  │
│   │                  │  Server + S3       │                                  │  │
│   │                  │  Artifact Store    │                                  │  │
│   │                  └─────────────────────┘                                  │  │
│   │                                                                        │  │
│   └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│   Experiments logged from all clouds → Compare → Register best model         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Configuration:**

```python
# Per-cloud MLflow configuration
import mlflow

# All clouds point to central MLflow server
MLFLOW_TRACKING_URI = "https://mlflow.behemoth.internal"

# AWS Pipeline
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
mlflow.set_experiment("aws-sagemaker-experiments")

# GCP Pipeline
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
mlflow.set_experiment("gcp-vertex-ai-experiments")

# Azure Pipeline
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
mlflow.set_experiment("azure-ml-experiments")

# Databricks Pipeline
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
mlflow.set_experiment("databricks-experiments")
```

**Model Promotion Workflow:**
```
1. Experiment completes in cloud (SageMaker/Vertex/AI/Azure/DB)
2. Metrics logged to central MLflow
3. Compare all model versions across clouds
4. Register "best of breed" model in model registry
5. Promote to cross-platform inference endpoint
```

---

## 3.7 LLM Provider Abstraction Layer

**Q: How do we avoid vendor lock-in and enable fallback for AI agents?**

**A:** Unified LLM provider abstraction with retry logic and fallback:

| Component | Implementation | Purpose |
|-----------|----------------|---------|
| Provider Interface | Abstract base class | Vendor-agnostic |
| Retry Logic | Tenacity (exponential backoff) | Resilience |
| Fallback Chain | Primary → Secondary → Tertiary | Continuity |
| Cost Tracking | Per-request token counting | Budget control |
| Output Validation | Pydantic models | Reliability |

**Architecture:**
```python
# backends/shared/src/llm/providers/base.py

from abc import ABC, abstractmethod
from tenacity import retry, stop_after_attempt, wait_exponential
from pydantic import BaseModel, validator
import logging

logger = logging.getLogger(__name__)


class LLMResponse(BaseModel):
    """Validated LLM response"""
    content: str
    model: str
    tokens_used: int
    cost: float

    @validator('content')
    def sanitize_output(cls, v):
        # Reject empty or malformed responses
        if not v or len(v.strip()) == 0:
            raise ValueError("Empty response from LLM")
        return v.strip()


class LLMProvider(ABC):
    """Abstract base for all LLM providers"""

    def __init__(self, fallback_providers: list["LLMProvider"] = None):
        self.fallback_providers = fallback_providers or []

    @abstractmethod
    def complete(self, prompt: str, **kwargs) -> LLMResponse:
        """Send prompt and get response"""
        pass

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10)
    )
    def complete_with_retry(self, prompt: str, **kwargs) -> LLMResponse:
        """Complete with automatic retry on failure"""
        try:
            return self.complete(prompt, **kwargs)
        except Exception as e:
            logger.warning(f"LLM call failed: {e}, trying fallback")
            for fallback in self.fallback_providers:
                try:
                    return fallback.complete(prompt, **kwargs)
                except Exception:
                    continue
            raise Exception("All LLM providers failed")


# Provider implementations per cloud
class BedrockProvider(LLMProvider):
    """AWS - Anthropic Claude via Bedrock"""
    def __init__(self, model: str = "anthropic.claude-3-sonnet"):
        super().__init__()
        self.model = model

    def complete(self, prompt: str, **kwargs) -> LLMResponse:
        # Bedrock API call with token counting
        ...


class VertexAIProvider(LLMProvider):
    """GCP - Gemini via Vertex AI"""
    def __init__(self, model: str = "gemini-1.5-pro"):
        super().__init__()
        self.model = model

    def complete(self, prompt: str, **kwargs) -> LLMResponse:
        # Vertex AI API call
        ...


class AzureOpenAIProvider(LLMProvider):
    """Azure - OpenAI GPT-4"""
    def __init__(self, model: str = "gpt-4"):
        super().__init__()
        self.model = model

    def complete(self, prompt: str, **kwargs) -> LLMResponse:
        # Azure OpenAI API call
        ...


class DatabricksProvider(LLMProvider):
    """Databricks - Llama via Foundation Models API"""
    def __init__(self, model: str = "llama-3-70b-instruct"):
        super().__init__()
        self.model = model

    def complete(self, prompt: str, **kwargs) -> LLMResponse:
        # Databricks API call
        ...
```

**Fallback Chain Configuration:**
```python
# AWS Agent uses: Bedrock (primary) → Vertex AI (fallback)
aws_agent_llm = BedrockProvider(
    fallback_providers=[
        VertexAIProvider(),  # GCP fallback
        AzureOpenAIProvider(),  # Azure fallback
    ]
)

# GCP Agent uses: Vertex AI (primary) → Bedrock (fallback)
gcp_agent_llm = VertexAIProvider(
    fallback_providers=[
        BedrockProvider(),  # AWS fallback
        AzureOpenAIProvider(),  # Azure fallback
    ]
)
```

**Cost Tracking:**
```python
# Track cost per request
def track_llm_cost(provider: str, input_tokens: int, output_tokens: int):
    COST_PER_1K_TOKENS = {
        "bedrock-claude": {"input": 0.003, "output": 0.015},
        "vertex-gemini": {"input": 0.00125, "output": 0.005},
        "azure-gpt4": {"input": 0.03, "output": 0.06},
        "databricks-llama": {"input": 0.0008, "output": 0.0024},
    }

    rates = COST_PER_1K_TOKENS.get(provider, {"input": 0, "output": 0})
    total_cost = (input_tokens / 1000 * rates["input"]) + \
                 (output_tokens / 1000 * rates["output"])

    # Log to Prometheus for observability
    prometheus_client.Counter(
        "llm_cost_total",
        "Total LLM cost",
        ["provider"]
    ).inc(total_cost)

    return total_cost
```

---

## 4. Cross-Platform CI/CD

### 4.1 Unified Pipeline Trigger

```yaml
# .github/workflows/cross-platform-cicd.yml

name: Cross-Platform CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  TERRAFORM_VERSION: 1.6.0
  NODE_VERSION: '20'
  PYTHON_VERSION: '3.11'

jobs:
  # ═══════════════════════════════════════════════════
  # ALL PLATFORMS: Lint & Security
  # ═══════════════════════════════════════════════════
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
      
      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
      
      - name: Check dependencies
        uses: snyk/actions/node@master

  # ═══════════════════════════════════════════════════
  # TERRAFORM VALIDATION (All Clouds)
  # ═══════════════════════════════════════════════════
  terraform-validate:
    needs: security-scan
    runs-on: ubuntu-latest
    strategy:
      matrix:
        cloud: [aws, gcp, azure, databricks]
    steps:
      - uses: actions/checkout@v4
      
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}
      
      - name: Terraform Init
        working-directory: ./infrastructure/${{ matrix.cloud }}
        run: terraform init -backend=false
      
      - name: Terraform Validate
        working-directory: ./infrastructure/${{ matrix.cloud }}
        run: terraform validate
      
      - name: Terraform Format Check
        working-directory: ./infrastructure/${{ matrix.cloud }}
        run: terraform fmt -check -recursive

  # ═══════════════════════════════════════════════════
  # FRONTEND TESTS (All Pipelines)
  # ═══════════════════════════════════════════════════
  frontend-tests:
    needs: security-scan
    runs-on: ubuntu-latest
    strategy:
      matrix:
        pipeline: [aws, gcp, azure, databricks, unified]
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Enable pnpm
        run: corepack enable && pnpm install --version 9

      - name: Install dependencies
        working-directory: ./frontends/${{ matrix.pipeline }}-frontend
        run: pnpm install

      - name: Type check
        working-directory: ./frontends/${{ matrix.pipeline }}-frontend
        run: pnpm run type-check

      - name: Lint
        working-directory: ./frontends/${{ matrix.pipeline }}-frontend
        run: pnpm run lint

      - name: Unit tests
        working-directory: ./frontends/${{ matrix.pipeline }}-frontend
        run: pnpm run test:unit
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./frontends/${{ matrix.pipeline }}-frontend/coverage/lcov.info

  # ═══════════════════════════════════════════════════
  # BACKEND TESTS (All Pipelines - Python)
  # ═══════════════════════════════════════════════════
  backend-tests:
    needs: security-scan
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - pipeline: aws
            language: python
            version: '3.11'
          - pipeline: gcp
            language: python
            version: '3.11'
          - pipeline: azure
            language: python
            version: '3.11'
          - pipeline: databricks
            language: python
            version: '3.11'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          node-version: ${{ matrix.version }}

      - name: Install dependencies
        working-directory: ./backends/${{ matrix.pipeline }}-backend
        run: pip install -r requirements.txt

      - name: Type check
        working-directory: ./backends/${{ matrix.pipeline }}-backend
        run: pip install mypy && mypy src

      - name: Lint
        working-directory: ./backends/${{ matrix.pipeline }}-backend
        run: pip install ruff && ruff check src

      - name: Unit tests
        working-directory: ./backends/${{ matrix.pipeline }}-backend
        run: pip install pytest pytest-cov && pytest tests/unit -v --cov=src

  # ═══════════════════════════════════════════════════
  # CONTRACT TESTS (Pact)
  # ═══════════════════════════════════════════════════
  contract-tests:
    needs: [frontend-tests, backend-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Pact Broker
        run: docker-compose up -d pact-broker
      
      - name: Verify contracts
        run: |
          for pipeline in aws gcp azure databricks; do
            make test:contracts PIPELINE=$pipeline
          done

  # ═══════════════════════════════════════════════════
  # DEPLOY TO DEVELOPMENT (on merge to develop)
  # ═══════════════════════════════════════════════════
  deploy-dev:
    needs: contract-tests
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: dev
    strategy:
      matrix:
        cloud: [aws, gcp, azure, databricks]
    steps:
      - uses: actions/checkout@v4
      
      # Cloud-specific deployment
      - name: Deploy to AWS
        if: matrix.cloud == 'aws'
        run: make deploy SECTION=aws ENV=dev
      
      - name: Deploy to GCP
        if: matrix.cloud == 'gcp'
        run: make deploy SECTION=gcp ENV=dev
      
      - name: Deploy to Azure
        if: matrix.cloud == 'azure'
        run: make deploy SECTION=azure ENV=dev
      
      - name: Deploy to Databricks
        if: matrix.cloud == 'databricks'
        run: make deploy SECTION=databricks ENV=dev
      
      - name: Smoke tests
        run: make test:smoke ENV=dev

  # ═══════════════════════════════════════════════════
  # DEPLOY TO PRODUCTION (on merge to main)
  # ═══════════════════════════════════════════════════
  deploy-prod:
    needs: contract-tests
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: prod
    concurrency:
      group: deploy-prod
      cancel-in-progress: false
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy All Platforms
        run: make deploy ENV=prod
      
      - name: E2E Tests
        run: make test:e2e ENV=prod
      
      - name: Notify
        if: always()
        uses: slackapi/slack-github-action@v1.25
        with:
          payload: |
            {
              "text": "${{ job.status == 'success' && '✅' || '❌' }} Deployment to Production",
              "blocks": [{
                "type": "section",
                "text": {
                  "type": "mrkdwn",
                  "text": "*Deployment Status:* ${{ job.status == 'success' && 'SUCCESS' || 'FAILED' }}"
                }
              }]
            }
```

---

## 5. Cross-Platform Makefile

```makefile
# Makefile for Cross-Platform Operations

# ═══════════════════════════════════════════════════════════════════════════
# GLOBAL VARIABLES
# ═══════════════════════════════════════════════════════════════════════════

SHELL := /bin/bash
TERRAFORM := terraform
DOCKER := docker
KUBECTL := kubectl

CLOUDS := aws gcp azure databricks
ENVIRONMENTS := dev staging prod

.PHONY: help

# ═══════════════════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════════════════

help: ## Show this help
	@echo "Cross-Platform MLOps Platform - Available Commands"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make deploy ENV=dev                    # Deploy all to dev"
	@echo "  make deploy SECTION=aws ENV=staging     # Deploy AWS to staging"
	@echo "  make test SECTION=frontend              # Test all frontends"
	@echo "  make destroy SECTION=gcp ENV=dev        # Destroy GCP dev resources"

# ═══════════════════════════════════════════════════════════════════════════
# TERRAFORM COMMANDS
# ═══════════════════════════════════════════════════════════════════════════

terraform-init: ## Initialize Terraform for all clouds
	@for cloud in $(CLOUDS); do \
		echo "Initializing Terraform for $$cloud..."; \
		$(TERRAFORM) -chdir=infrastructure/$$cloud init; \
	done

terraform-plan: ## Plan Terraform changes for all clouds
	@for cloud in $(CLOUDS); do \
		echo "Planning Terraform for $$cloud..."; \
		$(TERRAFORM) -chdir=infrastructure/$$cloud plan; \
	done

terraform-validate: ## Validate Terraform for all clouds
	@for cloud in $(CLOUDS); do \
		echo "Validating Terraform for $$cloud..."; \
		$(TERRAFORM) -chdir=infrastructure/$$cloud validate; \
	done

# ═══════════════════════════════════════════════════════════════════════════
# DEPLOYMENT
# ═══════════════════════════════════════════════════════════════════════════

deploy: ## Deploy to specified environment
	@if [ -z "$(SECTION)" ]; then \
		echo "Deploying all pipelines to $(ENV)..."; \
		for cloud in $(CLOUDS); do \
			$(MAKE) deploy SECTION=$$cloud ENV=$(ENV); \
		done; \
	else \
		echo "Deploying $(SECTION) to $(ENV)..."; \
		$(MAKE) deploy-infra SECTION=$(SECTION) ENV=$(ENV); \
		$(MAKE) deploy-apps SECTION=$(SECTION) ENV=$(ENV); \
		$(MAKE) deploy-ml SECTION=$(SECTION) ENV=$(ENV); \
	fi

deploy-infra: ## Deploy infrastructure
	@echo "Deploying $(SECTION) infrastructure to $(ENV)..."
	cd infrastructure/$(SECTION) && \
		$(TERRAFORM) workspace select $(ENV) || $(TERRAFORM) workspace new $(ENV); \
		$(TERRAFORM) apply -auto-approve

deploy-apps: ## Deploy applications
	@echo "Deploying $(SECTION) applications..."
	cd backends/$(SECTION)-backend && docker build -t $(SECTION)-backend:latest . && \
		$(MAKE) deploy:$(SECTION) IMAGE=$(SECTION)-backend:latest
	cd frontends/$(SECTION)-frontend && docker build -t $(SECTION)-frontend:latest . && \
		$(MAKE) deploy:frontend IMAGE=$(SECTION)-frontend:latest

deploy-ml: ## Deploy ML models
	@echo "Deploying $(SECTION) ML models..."
	$(MAKE) deploy-model:$(SECTION)

# ═══════════════════════════════════════════════════════════════════════════
# TESTING
# ═══════════════════════════════════════════════════════════════════════════

test: ## Run tests
	@if [ -z "$(SECTION)" ]; then \
		$(MAKE) test SECTION=frontend; \
		$(MAKE) test SECTION=backend; \
		$(MAKE) test SECTION=contracts; \
	else \
		$(MAKE) test-$(SECTION); \
	fi

test-frontend: ## Test all frontends
	@for cloud in $(CLOUDS); do \
		$(MAKE) test-frontend:$$cloud; \
	done

test-frontend:dev: ## Test frontend for specific cloud
	@cd frontends/$(PIPELINE)-frontend && npm run test:unit
	@cd frontends/$(PIPELINE)-frontend && npm run test:e2e

test-backend: ## Test all backends
	@for cloud in $(CLOUDS); do \
		$(MAKE) test-backend:$$cloud; \
	done

test-backend:dev: ## Test backend for specific cloud
	@cd backends/$(PIPELINE)-backend && pytest tests/unit -v
	@cd backends/$(PIPELINE)-backend && pytest tests/integration -v

test-contracts: ## Run contract tests
	@for cloud in $(CLOUDS); do \
		$(MAKE) test-contract:$$cloud; \
	done

test-contract:dev: ## Run contract tests for specific cloud
	@cd backends/$(PIPELINE)-backend && pact-broker test \
		--broker-base-url=http://localhost \
		--consumer-app-name=$(PIPELINE)-frontend \
		--provider-app-name=$(PIPELINE)-backend

test:e2e: ## Run E2E tests
	@echo "Running E2E tests..."
	@cd tests/e2e && playwright test --reporter=list

test:smoke: ## Run smoke tests
	@for cloud in $(CLOUDS); do \
		$(MAKE) smoke-test:$$cloud; \
	done

smoke-test:dev: ## Run smoke test for specific cloud
	@echo "Smoke testing $(SECTION) on $(ENV)..."
	@curl -f https://$(SECTION).api.$(ENV).example.com/health || exit 1

# ═══════════════════════════════════════════════════════════════════════════
# DOCKER
# ═══════════════════════════════════════════════════════════════════════════

docker:build: ## Build all Docker images
	@for cloud in $(CLOUDS); do \
		$(MAKE) docker:build:$$cloud; \
	done

docker:build:dev: ## Build Docker image for specific cloud
	@cd backends/$(SECTION)-backend && docker build -t $(SECTION)-backend:latest .
	@cd frontends/$(SECTION)-frontend && docker build -t $(SECTION)-frontend:latest .

docker:push: ## Push all Docker images
	@for cloud in $(CLOUDS); do \
		$(MAKE) docker:push:$$cloud; \
	done

docker:push:dev: ## Push Docker image for specific cloud
	@$(call get-ecr-url,$(SECTION))/$(SECTION)-backend:latest | docker push
	@$(call get-ecr-url,$(SECTION))/$(SECTION)-frontend:latest | docker push

# ═══════════════════════════════════════════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════════════════════════════════════════

destroy: ## Destroy resources
	@echo "Destroying $(SECTION) on $(ENV)..."
	@cd infrastructure/$(SECTION) && \
		$(TERRAFORM) workspace select $(ENV) && \
		$(TERRAFORM) destroy -auto-approve

destroy:all: ## Destroy all resources
	@for cloud in $(CLOUDS); do \
		for env in $(ENVIRONMENTS); do \
			$(MAKE) destroy SECTION=$$cloud ENV=$$env; \
		done \
	done

# ═══════════════════════════════════════════════════════════════════════════
# UTILITIES
# ═══════════════════════════════════════════════════════════════════════════

cost:estimate: ## Estimate costs
	@echo "Estimating costs for $(SECTION) on $(ENV)..."
	@cd infrastructure/$(SECTION) && \
		$(TERRAFORM) init -backend=false && \
		$(TERRAFORM) apply -dry-run

cost:breakdown: ## Show cost breakdown
	@for cloud in $(CLOUDS); do \
		echo "=== $$cloud ==="; \
		$(MAKE) cost:estimate SECTION=$$cloud ENV=$(ENV); \
	done

logs: ## Get logs
	@$(KUBECTL) logs -l app=$(SECTION) --tail=100

ssh: ## SSH to bastion
	@aws ssm start-session --target i-xxxxx

# ═══════════════════════════════════════════════════════════════════════════
# DOCUMENTATION
# ═══════════════════════════════════════════════════════════════════════════

docs: ## Generate documentation
	@cd docs && make generate

docs:openapi: ## Generate OpenAPI specs
	@for cloud in $(CLOUDS); do \
		$(MAKE) docs:openapi:$$cloud; \
	done
```

---

## 6. Baby Steps Implementation

### Step 6.1: Cross-Platform API Gateway

```
TASKS:
□ Deploy unified API Gateway
□ Configure routes for all 4 pipelines
□ Setup TLS termination
□ Configure rate limiting
□ Test: Route to each backend
```

### Step 6.2: Federated Query Setup

```
TASKS:
□ Deploy Trino coordinator
□ Add catalogs for each cloud
□ Configure cross-cloud joins
□ Test: Federated queries
```

### Step 6.3: Event Bus Integration

```
TASKS:
□ Configure Event Bridge/Pub/Sub/Hub
□ Define CloudEvents schema
□ Create event consumers
□ Test: Cross-platform events
```

### Step 6.4: Shared Observability

```
TASKS:
□ Setup Grafana + Prometheus + Loki + Tempo
□ Configure trace export from all agents
□ Setup cross-cloud dashboards
□ Setup drift detection alerts
□ Test: Cross-platform metrics and traces
```

### Step 6.5: Contract Testing

```
TASKS:
□ Setup Pact Broker
□ Define contracts for all pipeline APIs
□ Implement consumer tests
□ Implement provider tests
□ Test: Contract validation
```

### Step 6.6: Cross-Cloud Network Security

```
TASKS:
□ Configure AWS PrivateLink for GCP/Databricks
□ Setup GCP Private Service Connect
□ Configure Azure Private Link
□ Enable mTLS between all cloud services
□ Test: Secure cross-cloud connectivity
```

### Step 6.7: Unified MLflow Registry

```
TASKS:
□ Deploy central MLflow server (AWS)
□ Configure S3 artifact storage
□ Setup per-cloud tracking URIs
□ Implement cross-cloud model comparison
□ Test: Log experiments from all clouds
```

### Step 6.8: LLM Provider Abstraction

```
TASKS:
□ Implement base LLM provider interface
□ Add retry logic with exponential backoff
□ Configure fallback chains per agent
□ Add cost tracking to Prometheus
□ Test: Fallback when primary LLM fails
```

---

## 7. Next Steps

1. **Review and approve Cross-Platform PRD**
2. **Begin Monorepo Structure setup**
3. **Start with Step 1.1: Frontend - Unified Dashboard**
