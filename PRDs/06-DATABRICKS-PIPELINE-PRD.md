# PRD 06 - Databricks Pipeline Architecture

**Version:** 1.0  
**Date:** 2026-04-16  
**Related To:** Master PRD  
**Status:** Draft

---

## 1. Databricks Pipeline Overview

### 1.1 What Makes Databricks Unique?

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        DATABRICKS - MULTI-CLOUD PLATFORM                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│   ┌─────────────────────────────────────────────────────────────────────────────┐   │
│   │                           DATABRICKS CONTROL PLANE                             │   │
│   │                                                                                │   │
│   │  ┌───────────────────────────────────────────────────────────────────────┐  │   │
│   │  │                   Account Console (Unified Management)                    │  │   │
│   │  └───────────────────────────────────────────────────────────────────────┘  │   │
│   │                                                                                │   │
│   │   Can run on:                                                                 │   │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                          │   │
│   │   │   AWS       │  │   Azure    │  │   GCP       │                          │   │
│   │   │  E2 Deploy  │  │  Deploy    │  │   Deploy    │                          │   │
│   │   └─────────────┘  └─────────────┘  └─────────────┘                          │   │
│   │                                                                                │   │
│   └─────────────────────────────────────────────────────────────────────────────┘   │
│                                       │                                              │
│  ┌────────────────────────────────────┼────────────────────────────────────────────┐ │
│  │                                    ▼                                             │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                      UNITY CATALOG (Cross-Cloud Data)                     │   │ │
│  │  │                                                                              │   │ │
│  │  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │   │ │
│  │  │   │ AWS Data   │  │Azure Data  │  │ GCP Data   │  │ DB Data    │        │   │ │
│  │  │   │ (S3)      │  │ (ADLS)     │  │ (GCS)      │  │ (Delta)   │        │   │ │
│  │  │   └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │   │ │
│  │  └─────────────────────────────────────────────────────────────────────────┘   │ │
│  │                                                                                │ │
│  └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           DATA INTELLIGENCE LAYER                               │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │ Delta Lake  │  │  MLflow     │  │  Spark      │  │  Photon     │           │  │
│  │  │ (Tables)    │  │  (MLOps)    │  │  (Compute)  │  │  (Vectorized)│           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Bronze      │  │ Experiments │  │ Jobs        │  │ Faster SQL  │           │  │
│  │  │ Silver      │  │ Models      │  │ Pipelines   │  │ Faster ML   │           │  │
│  │  │ Gold        │  │ Registry    │  │ Notebooks   │  │             │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │ DBSQL       │  │ Foundation  │  │ Feature    │  │  Serverless │           │  │
│  │  │ (Warehouse) │  │ Models API  │  │ Store      │  │  (No infra) │           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Serverless  │  │ DBRX        │  │ Real-time   │  │ Auto-scale  │           │  │
│  │  │ Warehousing  │  │ Llama-2    │  │ Features    │  │ Pay per use │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                        AI AGENT (Custom + MLflow)                               │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                         LangServe Deployment                               │  │  │
│  │  │                                                                              │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │  │
│  │  │  │ Model      │  │ Feature    │  │ MLflow     │  │ Vector DB   │       │  │  │
│  │  │  │ Serving    │  │ Lookup     │  │ Tracking   │  │ (Pinecone) │       │  │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │  │  │
│  │  │                                                                              │  │  │
│  │  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │                    Custom Agent Orchestrator                          │  │  │  │
│  │  │  │                                                                              │  │  │  │
│  │  │  │  • RAG with Delta Lake                                                │  │  │  │
│  │  │  │  • Tool calling via LangChain                                         │  │  │  │
│  │  │  │  • Model serving via MLflow                                           │  │  │  │
│  │  │  │  • Observability with LangSmith                                       │  │  │  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Key Differences from Other Clouds

### 2.1 Databricks vs Other Pipelines

| Aspect | AWS/GCP/Azure | Databricks |
|--------|---------------|------------|
| **Focus** | General compute + ML | Data + ML first |
| **ML Platform** | SageMaker/Vertex AI/Azure ML | Native Databricks Runtime |
| **Data Format** | Various | Delta Lake (native) |
| **ETL** | Glue/Dataflow/DataFactory | Delta Live Tables |
| **SQL** | Separate warehouse | DBSQL (integrated) |
| **Notebooks** | External | First-class |
| **Multi-cloud** | Per-cloud | Works on all clouds |

### 2.2 Why Databricks is Different?

**Q: Why treat Databricks as a separate pipeline when it can run on AWS/GCP/Azure?**

**A:** Databricks has unique capabilities:

| Capability | Value |
|------------|-------|
| **Unity Catalog** | Single view of data across clouds |
| **Delta Lake** | Open-source table format, ACID transactions |
| **MLflow Integration** | Native ML lifecycle management |
| **Delta Live Tables** | ETL without writing Spark code |
| **Photon Engine** | 10x faster SQL/ML |
| **Foundation Models** | Access to DBRX, Llama-2 via API |
| **Serverless** | No cluster management |

---

## 3. Infrastructure Components

### 3.1 Terraform Structure

```
infrastructure/
├── databricks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── modules/
│   │   ├── workspace/
│   │   ├── unity-catalog/
│   │   ├── mlflow/
│   │   ├── dlt-pipeline/
│   │   └── jobs/
```

### 3.2 Workspace Module

```hcl
# modules/workspace/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# DATABRICKS WORKSPACE (AWS E2)
# ═══════════════════════════════════════════════════════════════════════════

# AWS E2 Workspace
resource "databricks_mws_workspaces" "this" {
  provider         = databricks.aws
  account_id       = var.databricks_account_id
  workspace_name   = "${var.environment}-mlops"
  
  deployment_name  = "${var.environment}mlops"
  
  # AWS Configuration
  aws_region      = var.region
  
  # Network configuration (VPC)
  network_configuration {
    vpc_id             = var.vpc_id
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
    
    # Private service endpoints
    dataplane_placement {
      availability_zone = "${var.region}a"
    }
  }
  
  # Storage Configuration
  storage_configuration_id = databricks_mws_storage.this.id
  
  # Managed services
  managed_services_customer_managed_key_id = aws_kms_key.main.id
  
  # SSO (optional)
  # sso_config { ... }
  
  token {
    comment = "Terraform deployment token"
  }
  
  depends_on = [
    databricks_mws_storage.this,
    databricks_mws_networking.this
  ]
}

# Storage Configuration (S3)
resource "databricks_mws_storage" "this" {
  provider         = databricks.aws
  account_id       = var.databricks_account_id
  bucket_name      = "${var.environment}-dbw-storage-${data.aws_caller_identity.current.account_id}"
  
  # Storage is encrypted with CMK
  managed_customer_managed_key_id = aws_kms_key.main.id
}

# Network Configuration
resource "databricks_mws_networking" "this" {
  provider           = databricks.aws
  account_id         = var.databricks_account_id
  
  # VPC info
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.security_group_id]
  
  # Private Link (recommended)
  private_link        = true
  vpc_endpoint_id     = aws_vpc_endpoint.databricks.id
  
  # Transit Gateway (for cross-account)
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

# KMS Key for encryption
resource "aws_kms_key" "main" {
  description             = "Databricks managed key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow Databricks"
        Effect = "Allow"
        Principal = {
          Service = "databricks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
```

### 3.3 Unity Catalog Module

```hcl
# modules/unity-catalog/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# UNITY CATALOG
# ═══════════════════════════════════════════════════════════════════════════

# Metastore (global)
resource "databricks_metastore" "this" {
  provider         = databricks.aws
  name            = "${var.environment}-metastore"
  storage_root    = "s3://${var.storage_bucket}/unity-metastore"
  
  # Owner
  owner           = var.admin_user
  
  # Delta Sharing
  delta_sharing {
    enabled                        = true
    delta_sharing_recipient_token_lifetime_in_minutes = 60
  }
  
  # Privilege validation
  privilege_validation {
    enabled = true
  }
}

# Assign to workspace
resource "databricks_metastore_assignment" "this" {
  provider         = databricks.aws
  workspace_id     = var.workspace_id
  metastore_id     = databricks_metastore.this.id
  default_catalog_name = "main"
}

# Catalogs
resource "databricks_catalog" "bronze" {
  provider = databricks.aws
  name     = "bronze"
  comment  = "Raw ingested data"
  
  storage_root    = "s3://${var.storage_bucket}/bronze"
  
  isolation_mode = "ISOLATED"
  
  properties = {
    environment = var.environment
  }
}

resource "databricks_catalog" "silver" {
  provider = databricks.aws
  name     = "silver"
  comment  = "Cleansed and enriched data"
  
  storage_root    = "s3://${var.storage_bucket}/silver"
  
  isolation_mode = "ISOLATED"
}

resource "databricks_catalog" "gold" {
  provider = databricks.aws
  name     = "gold"
  comment  = "Business-ready data"
  
  storage_root    = "s3://${var.storage_bucket}/gold"
  
  isolation_mode = "ISOLATED"
}

# Schemas
resource "databricks_schema" "ml_schema" {
  provider = databricks.aws
  name     = "ml"
  catalog  = databricks_catalog.gold.name
  
  comment = "ML models and features"
  
  properties = {
    team = "ml_engineering"
  }
}

resource "databricks_schema" "analytics_schema" {
  provider = databricks.aws
  name     = "analytics"
  catalog  = databricks_catalog.gold.name
  
  comment = "Analytics and reporting"
}

# External Locations (for cross-cloud access)
resource "databricks_external_location" "adls_silver" {
  provider = databricks.aws
  name     = "adls_silver"
  
  url            = "abfss://container@storage.dfs.core.windows.net/silver"
  storage_credential_id = databricks_storage_credential.adls_credential.id
  
  skip_validation = false
}

resource "databricks_external_location" "gcs_gold" {
  provider = databricks.aws
  name     = "gcs_gold"
  
  url            = "gs://gcp-bucket/gold"
  storage_credential_id = databricks_storage_credential.gcs_credential.id
  
  skip_validation = false
}
```

### 3.4 MLflow Module

```hcl
# modules/mlflow/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# MLFLOW CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

# MLflow Experiment
resource "databricks_mlflow_experiment" "cnn_experiment" {
  provider  = databricks.aws
  name      = "/${var.environment}/cnn-image-classification"
  
  artifact_location = "s3://${var.artifacts_bucket}/experiments/cnn"
  
  tags = {
    model_type = "CNN"
    use_case   = "image_classification"
  }
}

resource "databricks_mlflow_experiment" "rnn_experiment" {
  provider  = databricks.aws
  name      = "/${var.environment}/rnn-time-series"
  
  artifact_location = "s3://${var.artifacts_bucket}/experiments/rnn"
  
  tags = {
    model_type = "RNN"
    use_case   = "time_series_forecasting"
  }
}

# Registered Models
resource "databricks_mlflow_model" "cnn_model" {
  provider = databricks.aws
  name     = "${var.environment}_cnn_classifier"
  
  description = "CNN Image Classifier"
  
  tags = {
    framework = "tensorflow"
    task      = "image_classification"
  }
}

resource "databricks_mlflow_model" "rnn_model" {
  provider = databricks.aws
  name     = "${var.environment}_rnn_forecaster"
  
  description = "RNN Time Series Forecaster"
  
  tags = {
    framework = "pytorch"
    task      = "forecasting"
  }
}

# Webhooks for model events
resource "databricks_mlflow_webhook" "model_webhook" {
  provider = databricks.aws
  
  model_name    = databricks_mlflow_model.cnn_model.name
  webhook_scope = "MODEL_REGISTRATION"
  
  http_url      = var.notification_webhook_url
  http_authorization_header = "Bearer ${var.webhook_secret}"
}
```

### 3.5 Delta Live Tables Pipeline

```python
# pipelines/dlt_pipeline.py

"""
Delta Live Tables Pipeline for ETL
"""

import dlt
from pyspark.sql import functions as F
from pyspark.sql.types import *

@dlt.table(
    name="bronze_transactions",
    comment="Raw transaction data from Kafka",
    table_properties={
        "pipelines.autoOptimize.enabled": "true"
    }
)
@dlt.expect_or_drop("valid_transaction_id", "transaction_id IS NOT NULL")
def bronze_transactions():
    return (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", "kafka:9092")
        .option("subscribe", "transactions")
        .option("startingOffsets", "earliest")
        .load()
        .select(
            F.from_json(F.col("value").cast("string"), build_transaction_schema()).alias("data")
        )
        .select("data.*")
        .withColumn("ingest_timestamp", F.current_timestamp())
    )

@dlt.table(
    name="silver_transactions",
    comment="Cleansed transactions with customer context",
    table_properties={
        "pipelines.autoOptimize.enabled": "true",
        "pipelines.delta.autoCompact.enabled": "true"
    }
)
def silver_transactions():
    bronze = dlt.read("bronze_transactions")
    customers = dlt.read("silver_customers")
    
    return (
        bronze
        .withColumn("amount", F.col("amount").cast("double"))
        .withColumn("quantity", F.col("quantity").cast("int"))
        .withColumn("transaction_date", F.to_timestamp("transaction_date"))
        .join(
            customers.select("customer_id", "segment", "lifetime_value"),
            on="customer_id",
            how="left"
        )
        .withColumn("is_high_value", F.when(F.col("amount") > 1000, True).otherwise(False))
        .withColumn("year", F.year("transaction_date"))
        .withColumn("month", F.month("transaction_date"))
    )

@dlt.table(
    name="gold_customer_analytics",
    comment="Aggregated customer analytics",
    table_properties={
        "pipelines.autoOptimize.enabled": "true"
    }
)
def gold_customer_analytics():
    transactions = dlt.read("silver_transactions")
    
    return (
        transactions
        .groupBy("customer_id")
        .agg(
            F.count("transaction_id").alias("total_transactions"),
            F.sum("amount").alias("lifetime_value"),
            F.avg("amount").alias("avg_order_value"),
            F.min("transaction_date").alias("first_purchase"),
            F.max("transaction_date").alias("last_purchase"),
            F.stddev("amount").alias("spending_variance")
        )
        .withColumn(
            "churn_risk",
            F.when(
                F.datediff(F.current_date(), F.col("last_purchase")) > 90, "HIGH"
            ).when(
                F.datediff(F.current_date(), F.col("last_purchase")) > 60, "MEDIUM"
            ).otherwise("LOW")
        )
        .join(
            dlt.read("silver_customers").select("customer_id", "segment", "email"),
            on="customer_id"
        )
    )
```

---

## 4. AI Agent (Custom + LangServe)

**Note:** The Databricks **Backend API** uses **Python + FastAPI** (like all other pipelines).
The AI Agent remains Python-based due to LangServe/LangChain ecosystem.

```python
# backends/databricks-backend/src/api/routes/agent.py

"""
Databricks Backend API (Python + FastAPI)
AI Agent integration via LangServe
"""

from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel
from typing import Optional
from ..agents.langserve_client import call_langserve_agent

router = APIRouter()


class AgentChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None


class AgentChatResponse(BaseModel):
    response: str
    session_id: str


@router.post("/agent/chat", response_model=AgentChatResponse)
async def chat_with_agent(
    request: AgentChatRequest,
    x_user_id: str = Header(..., alias="x-user-id"),
):
    """
    Chat with the Databricks AI Agent via LangServe.
    """
    try:
        response = await call_langserve_agent(
            url=f"http://localhost:8084/langserve",
            message=request.message,
            session_id=request.session_id or x_user_id,
        )
        return AgentChatResponse(
            response=response,
            session_id=request.session_id or x_user_id,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

```python
# AI Agent remains Python (LangServe)
# backends/databricks-backend/src/agents/langserve_agent.py

"""
Databricks AI Agent
Custom orchestration using LangChain + MLflow + Delta Lake
"""

from langchain.pydantic_v1 import BaseModel, Field
from langchain.tools import tool
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage
from mlflow.tracking import MlflowClient
import databricks.sdk as dbx
from databricks.sdk.service.serving import EndpointCoreConfig
import logging

logger = logging.getLogger(__name__)

# ═══════════════════════════════════════════════════════════════════════════
# MLflow Tool
# ═══════════════════════════════════════════════════════════════════════════

@tool
def get_model_metrics(model_name: str, version: int = None) -> str:
    """
    Get model metrics from MLflow registry.
    
    Args:
        model_name: Name of the registered model
        version: Optional version number (latest if not specified)
    
    Returns:
        JSON string with model metrics
    """
    client = MlflowClient()
    
    if version:
        model = client.get_model_version(model_name, version)
    else:
        # Get latest version
        versions = client.search_model_versions(f"name = '{model_name}'")
        model = versions[0]
    
    # Get metrics from latest run
    run = client.get_run(model.run_id)
    metrics = run.data.metrics
    
    return f"""
    Model: {model.name}
    Version: {model.version}
    Stage: {model.current_stage}
    Metrics:
    {metrics}
    """

@tool
def deploy_model(model_name: str, version: int, compute: str = "CPU") -> str:
    """
    Deploy a model from MLflow registry to Databricks serving.
    
    Args:
        model_name: Name of the registered model
        version: Model version to deploy
        compute: Compute type (CPU or GPU)
    
    Returns:
        Deployment status
    """
    ws = dbx.workspace()
    
    # Create serving endpoint
    config = EndpointCoreConfig(
        name=f"{model_name}-endpoint",
        served_entities=[
            {
                "entity_name": model_name,
                "entity_version": str(version),
                "workload_size": "Small" if compute == "CPU" else "Medium",
                "workload_type": "CPU" if compute == "CPU" else "GPU"
            }
        ],
        traffic_config={
            "routes": [
                {
                    "served_model_name": f"{model_name}-{version}",
                    "traffic_percentage": 100
                }
            ]
        }
    )
    
    try:
        ws.serving_endpoints.create(config)
        return f"Model {model_name} v{version} deployed successfully"
    except Exception as e:
        return f"Deployment failed: {str(e)}"

# ═══════════════════════════════════════════════════════════════════════════
# Delta Lake / Spark Tools
# ═══════════════════════════════════════════════════════════════════════════

@tool
def query_delta_table(table_name: str, limit: int = 100) -> str:
    """
    Query data from a Delta Lake table.
    
    Args:
        table_name: Full table name (catalog.schema.table)
        limit: Maximum rows to return
    
    Returns:
        Tabular data as string
    """
    from pyspark.sql import SparkSession
    
    spark = SparkSession.builder.getOrCreate()
    
    df = spark.sql(f"SELECT * FROM {table_name} LIMIT {limit}")
    
    return df.toPandas().to_string()

@tool
def get_feature_value(feature_name: str, entity_id: str) -> str:
    """
    Get a feature value from Databricks Feature Store.
    
    Args:
        feature_name: Name of the feature table
        entity_id: Entity identifier
    
    Returns:
        Feature value
    """
    from databricks.feature_engineering import FeatureEngineeringClient
    
    fe = FeatureEngineeringClient()
    
    table = f"ml.{feature_name}"
    
    features_df = fe.get_features(
        table_name=table,
        lookup_features=[
            {"table_name": table, "names": [feature_name]}
        ],
        key=entity_id
    )
    
    return features_df.toPandas().to_string()

# ═══════════════════════════════════════════════════════════════════════════
# Agent Orchestrator
# ═══════════════════════════════════════════════════════════════════════════

class DatabricksAgentOrchestrator:
    """
    Custom agent orchestrator for Databricks
    Combines LangChain tools with MLflow and Delta Lake
    """
    
    def __init__(self, openai_api_key: str):
        # Initialize LLM (could use DBRX via Databricks Foundation Models API)
        self.llm = ChatOpenAI(
            model="gpt-4",
            api_key=openai_api_key,
            temperature=0
        )
        
        # Define tools
        self.tools = [
            get_model_metrics,
            deploy_model,
            query_delta_table,
            get_feature_value,
        ]
        
        # Create system prompt
        self.system_message = SystemMessage(content="""
        You are a Databricks ML platform assistant.
        You have access to:
        - MLflow for model management
        - Delta Lake for data querying
        - Databricks Feature Store
        - Foundation Models API
        
        Always provide accurate, data-driven responses.
        """)
    
    def create_agent(self):
        """Create the agent"""
        return create_openai_functions_agent(
            llm=self.llm,
            tools=self.tools,
            prompt=[self.system_message]
        )
    
    def run(self, query: str) -> str:
        """Run the agent"""
        agent = self.create_agent()
        agent_executor = AgentExecutor(
            agent=agent,
            tools=self.tools,
            verbose=True,
            max_iterations=10
        )
        
        result = agent_executor.invoke({"input": query})
        return result["output"]
```

---

## 5. 💰 Cost-Saving Tips for Databricks Pipeline

```
⚠️  IMPORTANT: Stop These Resources After Testing!

1. DBSQL WAREHOUSE (~$0.22/DBU)
   Stop the warehouse when not in use:
   - Unity Catalog: Stop SQL warehouse in workspace settings
   
2. ALL-PURPOSE CLUSTERS
   Terminate all-purpose clusters:
   - Databricks Console > Compute > All-purpose > Terminate
   
3. JOB CLUSTERS
   Job clusters auto-terminate after job completion.
   Configure: "Terminate after X minutes of inactivity"
   
4. MLflow TRACKING SERVER
   Built into workspace, minimal cost when not querying.
   
COST CALCULATION (Dev Environment - Idle):
- DBSQL Serverless: $0 (stopped)
- All-Purpose Clusters: $0 (terminated)
- Jobs (when running): ~$0.05/job
- MLflow: ~$0 (included)
- Unity Catalog: ~$0 (included)
- Total: ~$0-5/month (when not actively testing)

COST CALCULATION (Active Development - 4 hours/day):
- DBSQL Serverless (4 hours/day): ~$5/month
- All-Purpose Clusters (4 hours/day): ~$10/month
- Jobs: ~$10/month
- Total: ~$25/month

TO FULLY STOP:
1. Stop all DBSQL warehouses
2. Terminate all all-purpose clusters
3. Pause scheduled jobs (or set to disabled)

TO RESTART:
1. Start DBSQL warehouse
2. Recreate clusters (if using interactive)
3. Enable scheduled jobs
```

---

## 6. Baby Steps Implementation

### Step 5.1: Setup Databricks Account

```
TASKS:
□ Create Databricks Account (E2 if enterprise)
□ Configure identity providers (SSO)
□ Setup account admin
□ Install Databricks CLI
□ Install Terraform provider
□ Test: databricks account show
```

### Step 5.2: Deploy Workspace

```
TASKS:
□ Create AWS VPC with private subnets
□ Create IAM roles
□ Create S3 storage bucket
□ Deploy Databricks Workspace via Terraform
□ Configure Private Link
□ Test: Access workspace URL
```

### Step 5.3: Setup Unity Catalog

```
TASKS:
□ Create metastore
□ Create catalogs (bronze, silver, gold)
□ Configure storage locations
□ Create schemas
□ Set up external locations (for cross-cloud)
□ Test: Query from Unity Catalog
```

### Step 5.4: Create Delta Live Tables

```
TASKS:
□ Create DLT pipeline definition
□ Define bronze/silver/gold tables
□ Configure quality expectations
□ Deploy pipeline
□ Test: Data flows through pipeline
```

### Step 5.5: Setup MLflow

```
TASKS:
□ Configure MLflow tracking
□ Create experiments
□ Register first model
□ Setup model serving endpoints
□ Test: Log and retrieve metrics
```

### Step 5.6: Add AI Agent

```
TASKS:
□ Install LangChain
□ Create custom tools (MLflow, Delta Lake)
□ Create agent code with input sanitization (prompt injection defense)
□ Deploy agent via LangServe
□ Connect to Foundation Models API
□ Setup HashiCorp Vault integration (cloud-agnostic secrets)
□ Test: Agent can query data and models (including adversarial input test)
```

### Step 5.7: Create Jobs

```
TASKS:
□ Create training job
□ Create ETL job
□ Create inference job
□ Configure schedules
□ Setup job alerting
□ Setup observability (Grafana + Prometheus)
```

---

## 7. Next Steps

1. **Review and approve Databricks Pipeline PRD**
2. **Turn off Databricks resources**
3. Move to **Cross-Platform PRD**
