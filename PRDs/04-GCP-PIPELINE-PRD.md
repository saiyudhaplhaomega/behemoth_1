# PRD 04 - GCP Pipeline Architecture

**Version:** 1.0  
**Date:** 2026-04-16  
**Related To:** Master PRD  
**Status:** Draft

---

## 1. GCP Pipeline Overview

### 1.1 Architecture Summary

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              GCP ML PLATFORM                                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                              GCP VPC NETWORK                                    │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                          PUBLIC SUBNETS (for GCLB)                        │  │  │
│  │  │  us-central1-a: 10.0.1.0/24 | us-central1-b: 10.0.2.0/24                   │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                          PRIVATE SUBNETS (APP)                           │  │  │
│  │  │  us-central1-a: 10.0.10.0/24 | us-central1-b: 10.0.11.0/24              │  │  │
│  │  │                                                                            │  │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │  │  │
│  │  │  │GKE Pods │  │ Cloud Run│  │Cloud SQL│  │Memory-  │  │ GCS     │         │  │  │
│  │  │  │         │  │ Services │  │         │  │store    │  │ Mount   │         │  │  │
│  │  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘         │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           GCP SERVICES LAYER                                   │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │  GKE        │  │ Cloud Run   │  │ Cloud SQL   │  │ Vertex AI   │           │  │
│  │  │ (K8s)       │  │ (Containers)│  │ (PostgreSQL│  │ (ML)        │           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Backend API │  │ Microservices│  │ Primary DB  │  │ Training   │           │  │
│  │  │ Frontend    │  │ AI Agent    │  │ Replicas    │  │ Inference  │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │  Memorystore│  │   GCS       │  │ BigQuery    │  │ Dataflow    │           │  │
│  │  │  (Redis)    │  │ (Storage)   │  │ (Analytics) │  │ (ETL)       │           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Cache       │  │ Data Lake   │  │ Data        │  │ Apache Beam │           │  │
│  │  │ Sessions    │  │ ML Assets   │  │ Warehouse   │  │ Jobs        │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                              AI AGENT (LangChain + LangGraph)                   │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                         LangGraph Orchestrator                            │  │  │
│  │  │                                                                            │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │  │
│  │  │  │  Vertex AI  │  │   Gemini    │  │ BigQuery    │  │ Cloud       │       │  │  │
│  │  │  │  Tools      │  │   Model     │  │ Tools       │  │ Functions   │       │  │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Key Differences from AWS

### 2.1 Cloud-Native Service Mapping

| AWS Service | GCP Equivalent | Key Difference |
|-------------|-----------------|-----------------|
| ECS Fargate | Cloud Run / GKE | Cloud Run = serverless containers |
| RDS Aurora | Cloud SQL | Managed PostgreSQL/MySQL |
| ElastiCache | Memorystore | GCP managed Redis |
| ALB | Cloud Load Balancing | Global load balancing |
| SageMaker | Vertex AI | Unified ML platform |
| S3 | Cloud Storage | Object storage |
| DynamoDB | Firestore / Bigtable | NoSQL options |
| ECR | Artifact Registry | Container registry |
| IAM | IAM + Workload Identity | Better K8s integration |
| CloudWatch | Cloud Monitoring | Integrated observability |

### 2.2 Why Python + FastAPI for GCP Backend?

**Q: Why use Python for GCP Backend?**

**A:** Python unifies the stack across all pipelines:

| Factor | Python | Go |
|--------|--------|-----|
| **ML Ecosystem** | Native PyTorch, TensorFlow | Requires CGO bindings |
| **LangChain Support** | First-class Python support | Limited |
| **Team Velocity** | One language for all | Different language = context switch |
| **GCP SDK** | google-cloud-python | google-cloud-go |
| **Data Processing** | Pandas, NumPy native | Via external tools |

---

## 3. Infrastructure Components

### 3.1 Terraform Structure

```
infrastructure/
├── gcp/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── providers.tf
│   │
│   ├── modules/
│   │   ├── network/
│   │   ├── gke/
│   │   ├── cloud-sql/
│   │   ├── memorystore/
│   │   ├── storage/
│   │   ├── vertex-ai/
│   │   └── load-balancer/
```

### 3.2 GKE Module

```hcl
# modules/gke/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# GKE CLUSTER
# ═══════════════════════════════════════════════════════════════════════════

resource "google_container_cluster" "primary" {
  name     = "${var.environment}-mlops-cluster"
  location = var.region
  
  # Private cluster (no public IPs for nodes)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "10.1.0.0/28"
  }
  
  # Network configuration
  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.app.name
  
  # IP allocation for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  # Master authorized networks (for kubectl)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.admin_cidr
      display_name = "Admin Access"
    }
  }
  
  # Node pool configuration
  node_pool {
    name = "default-pool"
    node_count = var.initial_node_count
    
    node_config {
      machine_type = "e2-medium"
      
      # Container runtime
      image_type = "COS_CONTAINERD"
      
      # Service account (workload identity)
      service_account = google_service_account.gke.email
      
      # Scopes for cloud API access
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only"
      ]
      
      # Security hardening
      enable_shielded_nodes = true
      workload_metadata_config {
        mode = "GKE_METADATA"
      }
    }
    
    # Auto-upgrade
    management {
      auto_repair  = true
      auto_upgrade = true
    }
    
    # Auto-scaling
    autoscaling {
      enabled      = true
      min_node_count = 1
      max_node_count = 5
    }
  }
  
  # Vertical Pod Autoscaling
  vertical_pod_autoscaling {
    enabled = true
  }
  
  # Network Policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
  
  # Dataplane V2
  dataplane_v2_engine = "VISIBILITY"
  
  # Shielded logging and monitoring
  logging_config {
    component_config {
      enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
    }
  }
  
  monitoring_config {
    component_config {
      enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
    }
  }
  
  # Release channel
  release_channel {
    channel = "REGULAR"
  }
  
  # Cost optimization: Spot instances for non-production
  dynamic "node_pool" {
    for_each = var.environment != "prod" ? [1] : []
    
    content {
      name = "spot-pool"
      
      node_count = 2
      
      node_config {
        machine_type  = "e2-medium"
        image_type    = "COS_CONTAINERD"
        spot          = true  # Spot instances
        service_account = google_service_account.gke.email
        
        oauth_scopes = [
          "https://www.googleapis.com/auth/cloud-platform",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring"
        ]
        
        enable_shielded_nodes = true
        workload_metadata_config {
          mode = "GKE_METADATA"
        }
      }
      
      management {
        auto_repair  = true
        auto_upgrade = true
      }
    }
  }
  
  depends_on = [
    google_container_node_pool.primary,
    google_project_iam.binding.viewer
  ]
}

# Workload Identity (for service account impersonation)
resource "google_service_account" "gke" {
  account_id   = "${var.environment}-gke-sa"
  display_name = "GKE Workload Identity"
}

resource "google_service_account" "app" {
  account_id   = "${var.environment}-app-sa"
  display_name = "Application Service Account"
}

# Bind IAM for workload identity
resource "google_project_iam_binding" "workload_identity" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  
  members = [
    "serviceAccount:${google_service_account.gke.email}"
  ]
}

# Grant permissions to app service account
resource "google_project_iam_binding" "app_editor" {
  project = var.project_id
  role    = "roles/editor"
  
  members = [
    "serviceAccount:${google_service_account.app.email}"
  ]
}
```

### 3.3 Cloud SQL Module

```hcl
# modules/cloud-sql/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# CLOUD SQL (PostgreSQL)
# ═══════════════════════════════════════════════════════════════════════════

resource "google_sql_database_instance" "primary" {
  name             = "${var.environment}-mlops-db"
  database_version = "POSTGRES_15"
  region           = var.region
  
  deletion_protection = var.environment == "prod"
  
  settings {
    tier              = var.db_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"
    
    # Network configuration (Private IP)
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      
      # Authorized networks (empty for VPC-only)
      authorized_networks = []
      
      # SSL required
      require_ssl = true
      
      # Connection limits
      connection_queue_limit = 50
    }
    
    # Backup configuration
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }
    
    # Storage configuration
    storage {
      auto_resize         = true
      auto_resize_limit   = 100
      data_disk_type      = "PD_SSD"
      data_disk_size_gb   = 100

      # Encryption at rest (Google-managed key, customer-managed available)
      disk_encryption_status = "GOOGLE_DEFAULT_ENCRYPTION"
    }
    
    # Maintenance configuration
    maintenance_window {
      day          = 7  # Sunday
      hour         = 4  # 4 AM
      update_track = "stable"
    }
    
    # Insights
    insights_config {
      insights_enabled  = true
      query_plans_enabled = true
      query_string_length = 1024
    }
    
    # Database flags
    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }
  
  # High availability for production
  dynamic " replica_configuration" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      failover_target = google_sql_database_instance.replica.name
    }
  }
}

# Read replica
resource "google_sql_database_instance" "replica" {
  count                = var.environment == "prod" ? 1 : 0
  name                 = "${var.environment}-mlops-db-read"
  database_version     = google_sql_database_instance.primary.database_version
  region               = var.region
  master_instance_name = google_sql_database_instance.primary.name
  
  deletion_protection = true
  
  settings {
    tier              = google_sql_database_instance.primary.settings[0].tier
    availability_type = "ZONAL"
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      require_ssl     = true
    }
    
    storage {
      auto_resize         = true
      auto_resize_limit   = 100
      data_disk_type      = "PD_SSD"
      data_disk_size_gb   = 100
    }
  }
}

# Databases
resource "google_sql_database" "main" {
  name     = "mlops"
  instance = google_sql_database_instance.primary.name
}

resource "google_sql_database" "cache" {
  name     = "cache"
  instance = google_sql_database_instance.primary.name
}

# User
resource "google_sql_user" "app" {
  name     = "appuser"
  instance = google_sql_database_instance.primary.name
  password = var.db_password
}
```

### 3.4 Vertex AI Module

```hcl
# modules/vertex-ai/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# VERTEX AI WORKFLOW
# ═══════════════════════════════════════════════════════════════════════════

resource "google_vertex_ai_workflow" "training_pipeline" {
  name        = "${var.environment}-ml-training"
  description = "ML Training Pipeline"
  location    = var.region
  
  # Pipeline definition (YAML)
  pipeline_spec {
    pipeline_source = google_storage_bucket_object.pipeline_file.name
    service_account = google_service_account.vertexai.email
  }
  
  display_name = "ML Training Pipeline"
  
  labels = {
    environment = var.environment
  }
}

# Custom Training Job
resource "google_vertex_ai_custom_job" "cnn_training" {
  display_name = "${var.environment}-cnn-training"
  location     = var.region
  
  worker_pool_spec {
    machine_spec {
      machine_type   = "n1-standard-8"
      accelerator_type = "NVIDIA_TESLA_V100"
      accelerator_count = 1
    }
    
    replica_count = 1
    
    container_spec {
      image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/ml/ml-training:latest"
      
      command = ["python", "/app/train.py"]
      
      args = [
        "--data-path", "gs://${var.bucket_name}/data/",
        "--output-path", "gs://${var.bucket_name}/models/"
      ]
      
      env = [
        {
          name  = "GCS_BUCKET"
          value = var.bucket_name
        }
      ]
    }
  }
  
  service_account = google_service_account.vertexai.email
  
  scheduling {
    timeout = "7200s"
    restart_job_on_worker_restart = true
  }
  
  labels = {
    environment = var.environment
    model_type  = "cnn"
  }
}

# Model Registry
resource "google_vertex_ai_model" "cnn_model" {
  name        = "${var.environment}-cnn-classifier"
  location    = var.region
  description = "CNN Image Classifier"
  
  container_spec {
    image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/ml/ml-inference:latest"
    
    ports = [{
      container_port = 8080
    }]
    
    env = [{
      name  = "MODEL_NAME"
      value = "cnn-classifier"
}]
  }
  
  labels = {
    environment = var.environment
  }
}

# Endpoint (for inference)
resource "google_vertex_ai_endpoint" "inference" {
  display_name = "${var.environment}-inference-endpoint"
  location     = var.region
  description  = "ML Inference Endpoint"
  
  # Deployed model
  deployed_model {
    model_format           = "TF Saved"
    model_version           = google_vertex_ai_model.cnn_model.version_id
    dedicated_compute_minimum_instances = 1
    
    machine_spec {
      machine_type = "n1-standard-2"
    }
    
    traffic_split = {
      "0" = 100
    }
  }
  
  labels = {
    environment = var.environment
  }
}
```

---

## 4. AI Agent (LangChain + LangGraph)

```python
# backends/gcp-backend/src/agents/langchain_agent.py

"""
GCP AI Agent - LangChain + LangGraph Implementation
"""

from langchain.pydantic_v1 import BaseModel, Field
from langchain.tools import tool
from langchain_google_vertexai import VertexAI
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated, List
import logging

logger = logging.getLogger(__name__)


# ═══════════════════════════════════════════════════════════════════════════
# STATE DEFINITION
# ═══════════════════════════════════════════════════════════════════════════

class AgentState(TypedDict):
    """State for the LangGraph agent"""
    messages: Annotated[List[str], "messages"]
    current_tool: str
    tool_results: dict
    final_response: str


# ═══════════════════════════════════════════════════════════════════════════
# TOOLS
# ═══════════════════════════════════════════════════════════════════════════

@tool
def vertex_ai_predict(model: str, input: str) -> str:
    """
    Get ML predictions from Vertex AI models.

    Args:
        model: Model name (e.g., 'text-bison', 'gemini-pro')
        input: Input text for prediction

    Returns:
        Prediction result
    """
    try:
        llm = VertexAI(model_name=model, temperature=0)
        result = llm.invoke(input)
        return f"Prediction: {result}"
    except Exception as e:
        return f"Error: {str(e)}"


@tool
def bigquery_query(query: str) -> str:
    """
    Query data from BigQuery.

    Args:
        query: SQL query string

    Returns:
        Query results as string
    """
    try:
        from google.cloud import bigquery
        client = bigquery.Client()
        query_job = client.query(query)
        results = query_job.result()
        row_count = sum(1 for _ in results)
        return f"Query returned {row_count} rows"
    except Exception as e:
        return f"Error: {str(e)}"


@tool
def cloud_function(function_name: str, payload: str) -> str:
    """
    Execute a Cloud Function.

    Args:
        function_name: Name of the Cloud Function
        payload: JSON payload string

    Returns:
        Function execution result
    """
    try:
        from google.cloud import functions_v1
        client = functions_v1.CloudFunctionsServiceClient()
        # Cloud Function invocation logic here
        return f"Function {function_name} executed"
    except Exception as e:
        return f"Error: {str(e)}"


# ═══════════════════════════════════════════════════════════════════════════
# AGENT GRAPH
# ═══════════════════════════════════════════════════════════════════════════

def create_agent_graph(tools: List) -> StateGraph:
    """
    Create the LangGraph state machine for the agent.
    """

    def route_node(state: AgentState) -> str:
        """Router - decides which tool to use based on last message."""
        last_message = state["messages"][-1].lower()

        if any(kw in last_message for kw in ["predict", "inference", "model"]):
            return "vertex_ai_predict"
        elif any(kw in last_message for kw in ["query", "data", "analytics"]):
            return "bigquery_query"
        elif any(kw in last_message for kw in ["function", "serverless"]):
            return "cloud_function"
        else:
            return "respond"

    def tool_executor(state: AgentState) -> AgentState:
        """Execute the selected tool."""
        tool_name = state["current_tool"]

        for t in tools:
            if t.name == tool_name:
                # Extract args from last message
                args = {"query": state["messages"][-1]}
                result = t.invoke(args)

                state["tool_results"][tool_name] = result
                state["messages"].append(f"Tool {tool_name} result: {result}")
                break

        return state

    def response_generator(state: AgentState) -> AgentState:
        """Generate the final response."""
        state["final_response"] = f"Based on the analysis: {state['messages'][-1]}"
        return state

    # Build the graph
    builder = StateGraph(AgentState)
    builder.add_node("router", route_node)
    builder.add_node("tool_executor", tool_executor)
    builder.add_node("response_generator", response_generator)

    builder.set_entry_point("router")
    builder.add_conditional_edges(
        "router",
        lambda state: state["current_tool"],
        {
            "vertex_ai_predict": "tool_executor",
            "bigquery_query": "tool_executor",
            "cloud_function": "tool_executor",
            "respond": "response_generator",
        }
    )
    builder.add_edge("tool_executor", "router")
    builder.add_edge("response_generator", END)

    return builder.compile()


class GCPAgent:
    """Main agent class for GCP pipeline."""

    def __init__(self, project_id: str, location: str = "us-central1"):
        self.project_id = project_id
        self.location = location
        self.tools = [vertex_ai_predict, bigquery_query, cloud_function]
        self.graph = create_agent_graph(self.tools)

    async def run(self, user_message: str) -> str:
        """Run the agent with a user message."""
        initial_state: AgentState = {
            "messages": [user_message],
            "current_tool": "",
            "tool_results": {},
            "final_response": "",
        }

        result = await self.graph.ainvoke(initial_state)
        return result.get("final_response", "No response generated")
```

---

## 5. 💰 Cost-Saving Tips for GCP Pipeline

```
⚠️  IMPORTANT: Stop These Resources After Testing!

1. GKE CLUSTER (~$0.05/hour per node)
   gcloud container clusters resize mlops-dev-cluster --num-nodes=0 --zone=us-central1-a
   
   To restart:
   gcloud container clusters resize mlops-dev-cluster --num-nodes=1 --zone=us-central1-a

2. VERTEX AI ENDPOINTS (~$0.10/hour)
   gcloud ai endpoints delete ENDPOINT_ID --region=us-central1
   
3. CLOUD SQL (~$0.05/hour serverless)
   Cannot pause Cloud SQL, but can reduce tier

4. MEMORYSTORE (~$0.05/hour)
   Cannot stop, relatively cheap

5. DATA FLOW JOBS
   Delete after use:
   gcloud dataflow jobs list --region=us-central1
   gcloud dataflow jobs cancel JOB_ID --region=us-central1

COST CALCULATION (Dev Environment - Idle):
- GKE (0 nodes): $0
- Cloud SQL: ~$0.05/hour
- Memorystore: ~$0.05/hour
- Cloud Run: $0 (only pay when running)
- Total: ~$0.10/hour ≈ $70/month
```

---

## 6. Baby Steps Implementation

### Step 3.1: Setup GCP Account & Prerequisites

```
TASKS:
□ Create GCP Project
□ Enable billing
□ Install Google Cloud SDK
□ Configure ADC (Application Default Credentials)
□ Enable required APIs
□ Install Terraform with GCP provider
□ Test: gcloud auth list
```

### Step 3.2: Create VPC & Networking

```
TASKS:
□ Create Custom VPC
□ Create subnets (public/private)
□ Configure Cloud NAT
□ Create Firewall rules
□ Setup VPC Service Controls
□ Test: terraform apply
```

### Step 3.3: Create GKE Cluster

```
TASKS:
□ Create GKE module
□ Deploy private cluster
□ Configure Workload Identity
□ Setup node pools
□ Deploy sample application
□ Test: kubectl get pods
```

### Step 3.4: Create Cloud SQL

```
TASKS:
□ Create Cloud SQL module
□ Deploy PostgreSQL with Private IP
□ Configure backup
□ Setup read replicas (prod)
□ Setup HashiCorp Vault integration (cloud-agnostic secrets)
□ Test: Connect from GKE pod
```

### Step 3.5: Create Vertex AI Pipeline

```
TASKS:
□ Create Vertex AI module
□ Create custom training job
□ Create model endpoint
□ Deploy inference service
□ Test: Online prediction
```

### Step 3.6: Add AI Agent (LangChain)

```
TASKS:
□ Install LangChain Python SDK
□ Create agent code with input sanitization (prompt injection defense)
□ Implement Vault auth for agent credentials
□ Define tools (Vertex AI, BigQuery, etc.)
□ Deploy to Cloud Run
□ Test: Chat with agent (including adversarial input test)
```

### Step 3.7: Setup CI/CD (Cloud Build)

```
TASKS:
□ Create Cloud Build triggers
□ Configure build steps
□ Deploy to GKE
□ Setup Cloud Deploy for progressive delivery
□ Setup observability (Grafana + Prometheus)
```

---

## 7. Next Steps

1. **Review and approve GCP Pipeline PRD**
2. **Turn off GCP resources**
3. Move to **Azure Pipeline PRD**
