# PRD 05 - Azure Pipeline Architecture

**Version:** 2.0
**Date:** 2026-04-16
**Related To:** Master PRD
**Status:** DEFERRED (Post-MVP)

---

## 1. Azure Pipeline Overview

### 1.1 Architecture Summary

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AZURE ML PLATFORM                                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                           AZURE VIRTUAL NETWORK                                │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                          PUBLIC SUBNET (for Azure Load Balancer)          │  │  │
│  │  │  subnet-public: 10.0.1.0/24 | subnet-public-2: 10.0.2.0/24                │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                          PRIVATE SUBNETS                                  │  │  │
│  │  │                                                                             │  │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐                     │  │  │
│  │  │  │App Subnet│  │Data Sub.│  │ Web Sub │  │Mgmt Sub │                     │  │  │
│  │  │  │         │  │         │  │         │  │         │                     │  │  │
│  │  │  │• AKS    │  │• Azure  │  │• App GW │  │• Bastion│                     │  │  │
│  │  │  │• ACR    │  │  SQL    │  │• WAF    │  │• VPN    │                     │  │  │
│  │  │  │         │  │• ADLS   │  │         │  │         │                     │  │  │
│  │  │  │         │  │• Cosmos │  │         │  │         │                     │  │  │
│  │  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘                     │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                              │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                           AZURE SERVICES                                      │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │  AKS        │  │ Azure ML   │  │ Azure SQL   │  │ Azure Cache │           │  │
│  │  │ (K8s)       │  │ (ML)        │  │ (PostgreSQL)│  │ (Redis)     │           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Backend API │  │ Training   │  │ Primary DB  │  │ Cache       │           │  │
│  │  │ Frontend    │  │ Inference  │  │ Read       │  │ Sessions    │           │  │
│  │  │ AI Agent    │  │ AutoML     │  │ Replicas   │  │             │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │  ADLS Gen2  │  │ Cosmos DB  │  │ Data Factory│  │ Power BI    │           │  │
│  │  │ (Data Lake) │  │ (NoSQL)    │  │ (ETL)       │  │ (Embedded)  │           │  │
│  │  │             │  │             │  │             │  │             │           │  │
│  │  │ Bronze      │  │ Events     │  │ Pipelines   │  │ Reports     │           │  │
│  │  │ Silver      │  │ Sessions   │  │ Data Flow   │  │ Dashboards  │           │  │
│  │  │ Gold        │  │             │  │             │  │             │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                           AI AGENT (CrewAI)                                    │  │
│  │                                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                         Multi-Agent Team                                   │  │  │
│  │  │                                                                             │  │  │
│  │  │  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐            │  │  │
│  │  │  │Research Agent │    │  Coder Agent │    │  QA Agent    │            │  │  │
│  │  │  │              │    │              │    │              │            │  │  │
│  │  │  │- Azure AI    │    │- Azure Func │    │- Test Azure  │            │  │  │
│  │  │  │- Web Search  │    │- SDK calls   │    │- Validate    │            │  │  │
│  │  │  └───────────────┘    └───────────────┘    └───────────────┘            │  │  │
│  │  │           │                    │                    │                    │  │  │
│  │  │           └────────────────────┼────────────────────┘                    │  │  │
│  │  │                                ▼                                           │  │  │
│  │  │                     ┌───────────────────┐                                  │  │  │
│  │  │                     │   Orchestrator    │                                  │  │  │
│  │  │                     │   (CrewAI Boss)   │                                  │  │  │
│  │  │                     └───────────────────┘                                  │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Key Differences from AWS

### 2.1 Azure vs AWS Service Mapping

| AWS Service | Azure Equivalent | Key Difference |
|-------------|------------------|----------------|
| ECS Fargate | AKS / Container Apps | AKS = managed K8s |
| RDS Aurora | Azure SQL / Cosmos DB | Multiple database options |
| ElastiCache | Azure Cache for Redis | Same Redis engine |
| ALB | Application Gateway | Azure-native WAF |
| SageMaker | Azure ML | Unified ML platform |
| S3 | Azure Blob Storage / ADLS | ADLS Gen2 for enterprise |
| ECR | Azure Container Registry | Integrated with AKS |
| IAM | Azure AD / RBAC | Enterprise identity |

### 2.2 Why Python + FastAPI for Azure Backend?

**Q: Why use Python instead of .NET 8 for Azure Backend?**

**A:** Python unifies the stack across all pipelines:

| Factor | Python | .NET 8 |
|--------|--------|--------|
| **ML Ecosystem** | Native PyTorch, TensorFlow | Requires interop |
| **LangChain Support** | First-class Python support | Limited |
| **Team Velocity** | One language everywhere | Context switching |
| **Cross-Cloud** | Same stack = easier debugging | Azure-only focus |
| **Azure SDK** | azure-identity, azure-ml | Azure SDK for .NET |

---

## 3. Infrastructure Components

### 3.1 Terraform Structure

```
infrastructure/
├── azure/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── modules/
│   │   ├── networking/
│   │   │   ├── vnet.tf
│   │   │   ├── subnets.tf
│   │   │   ├── nsg.tf
│   │   │   └── bastion.tf
│   │   ├── aks/
│   │   ├── azure-sql/
│   │   ├── redis/
│   │   ├── azure-ml/
│   │   ├── adls/
│   │   └── container-registry.tf
```

### 3.2 AKS Module

```hcl
# modules/aks/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# AZURE KUBERNETES SERVICE
# ═══════════════════════════════════════════════════════════════════════════

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.environment}-mlops-aks"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  dns_prefix          = "mlops"
  kubernetes_version   = var.kubernetes_version
  sku_tier           = var.environment == "prod" ? "Standard" : "Free"
  
  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size            = "Standard_DS2_v2"
    type               = "VirtualMachineScaleSets"
    availability_zones = ["1", "2", "3"]
    
    # Enable auto-scaling
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 5
    
    # Network configuration
    vnet_subnet_id = var.subnet_id
    
    # OS disk
    os_disk_size_gb = 100
    os_disk_type    = "Managed"
    
    # Node labels
    node_labels = {
      "workload" = "default"
    }
  }
  
  # Identity configuration (System Assigned)
  identity {
    type = "SystemAssigned"
  }
  
  # Network profile
  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }
  
  # Azure AD integration
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled    = true
    admin_group_object_ids = var.admin_group_ids
  }
  
  # KeyVault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  
  # Monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
  
  # Maintenance window
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [0, 6, 12, 18]
    }
  }
  
  # SKU (auto-scaling pool for GPU)
  automatic_channel_upgrade = "stable"
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

# Auto-scaling Profile (Cost Optimization)
resource "azurerm_kubernetes_cluster_autoscaling_profile" "main" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  
  min_size = 1
  max_size = 10
  
  # Enable scale-to-zero for spot nodes
  scale_down_mode = "Deallocate"
}

# Add Node Pool (GPU for ML)
resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  name                  = "gpu-pool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size              = "Standard_NC6s_v3"
  node_count           = 0  # Scale to 0 when not needed
  
  enable_auto_scaling = true
  min_count          = 0
  max_count          = 3
  
  vnet_subnet_id = var.subnet_id
  
  node_labels = {
    "workload" = "ml"
    "gpu"      = "true"
  }
  
  taint = ["sku=gpu:NoSchedule"]
  
  os_disk_size_gb = 100
  
  # Spot instance for cost savings
  priority        = "Spot"
  eviction_policy = "Delete"
  
  spot_max_price = -1  # Pay up to on-demand price
  
  lifecycle {
    ignore_changes = [node_count]
  }
}
```

### 3.3 Azure SQL Module

```hcl
# modules/azure-sql/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# AZURE SQL (PostgreSQL)
# ═══════════════════════════════════════════════════════════════════════════

resource "azurerm_mssql_server" "main" {
  name                         = "${var.environment}-mlops-sqlserver"
  location                     = var.resource_group.location
  resource_group_name         = var.resource_group.name
  version                      = "12.0"
  administrator_login         = "sqladmin"
  administrator_login_password = var.sql_password
  
  # Identity
  identity {
    type = "SystemAssigned"
  }
  
  # Transparent Data Encryption
  transparent_data_encryption_enabled = true
  
  tags = var.tags
}

# Database
resource "azurerm_mssql_database" "main" {
  name           = "mlops"
  server_id     = azurerm_mssql_server.main.id
  collation     = "SQL_Latin1_General_CP1_CI_AS"
  license_type  = "LicenseIncluded"
  
  sku_name = var.environment == "prod" ? "S2" : "S0"
  
  # Auto-pause (cost saving)
  auto_pause_delay_in_minutes = var.environment == "prod" ? null : 60
  
  # Storage
  max_size_gb = var.environment == "prod" ? 250 : 2
  
  storage_account_type = "Local"
  
  threat_detection_policy {
    enabled = true
    retention_days = 30
    
    disabled_alerts = [
      "Sql_Injection",
      "Data_Exfiltration"
    ]
  }
}

# Firewall Rule (for development)
resource "azurerm_mssql_firewall_rule" "dev" {
  count = var.environment == "dev" ? 1 : 0
  
  server_id = azurerm_mssql_server.main.id
  name     = "AllowAllWindowsAzureIps"
  start_ip = "0.0.0.0"
  end_ip   = "0.0.0.0"
}

# Private Endpoint
resource "azurerm_private_endpoint" "main" {
  name                = "${var.environment}-mlops-sql-pe"
  location           = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id          = var.subnet_id
  
  private_service_connection {
    name                           = "${var.environment}-mlops-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection          = false
  }
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.main.id]
  }
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group.location
  
  tags = var.tags
}
```

### 3.4 Azure ML Module

```hcl
# modules/azure-ml/main.tf

# ═══════════════════════════════════════════════════════════════════════════
# AZURE MACHINE LEARNING
# ═══════════════════════════════════════════════════════════════════════════

resource "azurerm_machine_learning_workspace" "main" {
  name                    = "${var.environment}-ml-workspace"
  location               = var.resource_group.location
  resource_group_name    = var.resource_group.name
  friendly_name         = "MLOps Workspace"
  description            = "MLOps Platform ML Workspace"
  
  # Identity (System Assigned)
  identity {
    type = "SystemAssigned"
  }
  
  # Storage Account
  storage_account_id   = azurerm_storage_account.main.id
  container_registry_id = var.container_registry_id
  key_vault_id        = var.key_vault_id
  
  application_insights_id = azurerm_application_insights.main.id
  
  # Public Network Access
  public_network_access_enabled = false
  
  tags = var.tags
}

# Compute Instance (for development)
resource "azurerm_machine_learning_compute_cluster" "instance" {
  name                = "${var.environment}-compute"
  location           = var.resource_group.location
  resource_group_name = var.resource_group.name
  workspace_id       = azurerm_machine_learning_workspace.main.id
  
  vm_size    = "STANDARD_DS11_V2"
  subnet_resource_id = var.subnet_id
  
  scale_settings {
    min_node_count = 0
    max_node_count = 1
    scale_down_delay_minutes = 15
  }
  
  identity {
    type = "SystemAssigned"
  }
}

# Compute Cluster (for training)
resource "azurerm_machine_learning_compute_cluster" "training" {
  name                = "${var.environment}-training-cluster"
  location           = var.resource_group.location
  resource_group_name = var.resource_group.name
  workspace_id       = azurerm_machine_learning_workspace.main.id
  
  vm_size    = "STANDARD_D8s_v3"
  subnet_resource_id = var.subnet_id
  
  scale_settings {
    min_node_count = 0
    max_node_count = 4
    scale_down_delay_minutes = 10
  }
  
  # Low priority for cost savings
  scale_priority = "LowPriority"
  
  identity {
    type = "SystemAssigned"
  }
}

# Inference Cluster (for deployment)
resource "azurerm_machine_learning_inference_cluster" "production" {
  name                = "${var.environment}-inference"
  location           = var.resource_group.location
  resource_group_name = var.resource_group.name
  workspace_id       = azurerm_machine_learning_workspace.main.id
  
  kube_config {
    kube_config_raw = var.kube_config_raw
  }
  
  kubernetes_cluster_id = var.aks_cluster_id
  
  inference_scheduler {
    max_response_time_seconds = 60
    node_count = 2
    
    scale_settings {
      min_node_count = 0
      max_node_count = 3
      scale_down_delay_minutes = 10
    }
  }
}
```

---

## 4. AI Agent (CrewAI)

```python
# backends/azure-backend/src/agents/crewai_agent.py

"""
Azure Backend AI Agent using CrewAI
Multi-agent orchestration with Azure OpenAI
"""

from crewai import Agent, Crew, Task, Process
from crewai.tools import BaseTool
from typing import List, Dict, Any
from pydantic import BaseModel
import logging

logger = logging.getLogger(__name__)

class AzureTool(BaseTool):
    """Base class for Azure tools"""
    name: str = ""
    description: str = ""
    
    def _run(self, **kwargs) -> str:
        raise NotImplementedError("Subclass must implement _run method")

class AzureOpenAITool(AzureTool):
    """Tool for Azure OpenAI"""
    name = "azure_openai"
    description = "Use Azure OpenAI for text generation and chat"
    
    def __init__(self, endpoint: str, api_key: str):
        super().__init__()
        self.endpoint = endpoint
        self.api_key = api_key
    
    def _run(self, prompt: str, model: str = "gpt-4") -> str:
        """Execute OpenAI request"""
        # Azure OpenAI API call
        response = call_azure_openai(
            endpoint=self.endpoint,
            api_key=self.api_key,
            prompt=prompt,
            model=model
        )
        return response

class AzureMLTool(AzureTool):
    """Tool for Azure ML operations"""
    name = "azure_ml"
    description = "Train and deploy ML models using Azure ML"
    
    def __init__(self, subscription_id: str, resource_group: str, workspace_name: str):
        super().__init__()
        self.subscription_id = subscription_id
        self.resource_group = resource_group
        self.workspace_name = workspace_name
    
    def _run(self, operation: str, **kwargs) -> str:
        """Execute Azure ML operation"""
        if operation == "train":
            return self._train_model(kwargs)
        elif operation == "deploy":
            return self._deploy_model(kwargs)
        elif operation == "predict":
            return self._get_prediction(kwargs)
        return "Unknown operation"

class AzureDataTool(AzureTool):
    """Tool for Azure Data operations"""
    name = "azure_data"
    description = "Query and manipulate data in Azure Data services"
    
    def _run(self, source: str, query: str) -> str:
        """Execute data query"""
        if source == "cosmos":
            return query_cosmos_db(query)
        elif source == "sql":
            return query_azure_sql(query)
        elif source == "adls":
            return query_adls(query)
        return "Unknown data source"

class CrewAIOrchestrator:
    """
    CrewAI-based multi-agent orchestrator
    Uses Azure OpenAI as the LLM backend
    """
    
    def __init__(
        self,
        azure_openai_endpoint: str,
        azure_openai_key: str,
        azure_ml_config: Dict[str, str],
        azure_data_config: Dict[str, str]
    ):
        self.llm = AzureOpenAI(
            api_key=azure_openai_key,
            endpoint=azure_openai_endpoint,
            model="gpt-4",
            api_version="2024-02-15-preview"
        )
        
        # Initialize tools
        self.tools = [
            AzureOpenAITool(azure_openai_endpoint, azure_openai_key),
            AzureMLTool(**azure_ml_config),
            AzureDataTool(),
            # Add more tools...
        ]
        
        # Create agents
        self.research_agent = self._create_research_agent()
        self.ml_agent = self._create_ml_agent()
        self.data_agent = self._create_data_agent()
        self.qa_agent = self._create_qa_agent()
    
    def _create_research_agent(self) -> Agent:
        """Create research agent"""
        return Agent(
            role="Research Analyst",
            goal="Research and gather information about ML topics",
            backstory="Expert data scientist with years of experience in ML research",
            tools=[tool for tool in self.tools if isinstance(tool, AzureOpenAITool)],
            llm=self.llm,
            verbose=True
        )
    
    def _create_ml_agent(self) -> Agent:
        """Create ML agent"""
        return Agent(
            role="ML Engineer",
            goal="Train, evaluate, and deploy ML models",
            backstory="Expert ML engineer specializing in CNN, RNN, and transformer models",
            tools=[tool for tool in self.tools if "ml" in tool.name.lower()],
            llm=self.llm,
            verbose=True
        )
    
    def _create_data_agent(self) -> Agent:
        """Create data agent"""
        return Agent(
            role="Data Engineer",
            goal="Query and transform data from various Azure data sources",
            backstory="Expert data engineer with deep knowledge of Azure data services",
            tools=[tool for tool in self.tools if "data" in tool.name.lower()],
            llm=self.llm,
            verbose=True
        )
    
    def _create_qa_agent(self) -> Agent:
        """Create QA agent"""
        return Agent(
            role="Quality Assurance",
            goal="Validate ML models and ensure quality standards",
            backstory="ML QA specialist with focus on model validation and testing",
            tools=self.tools,
            llm=self.llm,
            verbose=True
        )
    
    def create_crew(self, task_type: str) -> Crew:
        """Create a crew based on task type"""
        
        if task_type == "full_ml_pipeline":
            return Crew(
                agents=[
                    self.research_agent,
                    self.data_agent,
                    self.ml_agent,
                    self.qa_agent
                ],
                tasks=[
                    Task(
                        description="Research the best ML approach for the given problem",
                        agent=self.research_agent,
expected_output="Research report with recommendations"
                    ),
                    Task(
                        description="Prepare and validate the training data",
                        agent=self.data_agent,
                        expected_output="Cleaned and validated dataset"
                    ),
                    Task(
                        description="Train and evaluate the ML model",
                        agent=self.ml_agent,
                        expected_output="Trained model with performance metrics"
                    ),
                    Task(
                        description="Run quality checks on the model",
                        agent=self.qa_agent,
                        expected_output="QA report with validation results"
                    )
                ],
                process=Process.hierarchical,
                manager_llm=self.llm
            )
        
        elif task_type == "quick_prediction":
            return Crew(
                agents=[self.ml_agent],
                tasks=[
                    Task(
                        description="Generate prediction using existing model",
                        agent=self.ml_agent,
                        expected_output="Prediction results"
                    )
                ],
                process=Process.sequential
            )
        
        raise ValueError(f"Unknown task type: {task_type}")
    
    def execute(self, task_type: str, input_data: str) -> Dict[str, Any]:
        """Execute a crew task"""
        crew = self.create_crew(task_type)
        result = crew.kickoff(inputs={"task": input_data})
        
        return {
            "success": True,
            "result": result,
            "task_type": task_type
        }
```

---

## 5. 💰 Cost-Saving Tips for Azure Pipeline

```
⚠️  IMPORTANT: Stop These Resources After Testing!

1. AKS CLUSTER (~$0.05/hour per node)
   az aks scale --name mlops-dev --resource-group rg-mlops-dev --node-count 0
   
   To restart:
   az aks scale --name mlops-dev --resource-group rg-mlops-dev --node-count 1

2. AZURE ML COMPUTE (~$0.10/hour)
   az ml compute stop --name compute --workspace-name ml-workspace --resource-group rg-mlops
   
3. AZURE SQL (~$0.005/hour serverless)
   Auto-pause is enabled for dev (pauses after 60 min of inactivity)

4. AZURE CACHE FOR REDIS (~$0.05/hour)
   Cannot stop, relatively cheap

5. APPLICATION GATEWAY (~$0.03/hour)
   Cannot stop, relatively cheap

COST CALCULATION (Dev Environment - Idle):
- AKS (0 nodes): $0
- Azure SQL (auto-paused): $0
- Azure Cache: ~$0.05/hour
- Application Gateway: ~$0.03/hour
- Azure ML: ~$0 when paused
- Total: ~$0.08/hour ≈ $60/month
```

---

## 6. Baby Steps Implementation

### Step 4.1: Setup Azure Account & Prerequisites

```
TASKS:
□ Create Azure Account
□ Install Azure CLI
□ Authenticate: az login
□ Create Service Principal for Terraform
□ Configure Terraform backend (Azure Storage)
□ Install Terraform
□ Test: az account show
```

### Step 4.2: Create Virtual Network & Subnets

```
TASKS:
□ Create Resource Group
□ Create Virtual Network
□ Create Subnets (App, Data, Web, Mgmt)
□ Create NSGs
□ Configure Private DNS
□ Test: terraform apply
```

### Step 4.3: Create AKS Cluster

```
TASKS:
□ Create AKS module
□ Deploy AKS with private cluster
□ Configure Azure AD integration
□ Setup RBAC
□ Deploy sample app
□ Test: kubectl get pods
```

### Step 4.4: Create Azure SQL

```
TASKS:
□ Create Azure SQL module
□ Deploy SQL Server
□ Configure Private Endpoint
□ Setup auto-pause (dev)
□ Configure Threat Detection
□ Setup HashiCorp Vault integration (cloud-agnostic secrets)
□ Test: Connect from AKS pod
```

### Step 4.5: Create Azure ML

```
TASKS:
□ Create Azure ML module
□ Deploy ML Workspace
□ Create compute clusters
□ Configure network
□ Test: Submit training job
```

### Step 4.6: Add AI Agent (CrewAI)

```
TASKS:
□ Install CrewAI
□ Create agent code with input sanitization (prompt injection defense)
□ Implement Vault auth for agent credentials
□ Define agents and tasks
□ Deploy to Container Apps
□ Test: Execute crew task (including adversarial input test)
```

### Step 4.7: Setup CI/CD (Azure DevOps)

```
TASKS:
□ Create Azure DevOps pipeline
□ Configure service connections
□ Deploy to AKS
□ Setup Azure Deployment Centers
□ Setup observability (Grafana + Prometheus)
```

---

## 8. Azure Features (Social + Community Pipeline)

### 8.1 Assigned Features

Azure serves as the **social trading** and **community engagement** pipeline. Assigned features:

| Feature | Components | Purpose |
|---------|------------|---------|
| **Social Trading / Signal Marketplace** | Azure SQL + AOAI + Azure ML | Share, copy, rank signals |
| **Paper Trading Competitions** | Azure SQL + App Service + Power BI | Leaderboards, prizes |
| **Trading Journal + AI Insights** | AOAI (GPT-4) + Azure Cognitive Search | AI diary generation |
| **Options Flow Analysis** | Azure Functions + Azure SQL + Power BI | Put/call ratio, IV rank |

### 8.2 Cross-Pipeline Events: Azure Publishes

```python
# Azure publishes (social features)
EVENTS_AZURE_PUBLISHES = {
    "signal.copied": {
        "description": "A signal was copied by another trader",
        "payload": {
            "signal_id": "str",
            "copier_id": "str",
            "copier_username": "str",
            "timestamp": "ISO8601"
        },
        "consumers": ["AWS", "GCP"]
    },
    "competition.update": {
        "description": "Competition leaderboard updated",
        "payload": {
            "competition_id": "str",
            "rankings": [{"user_id": "str", "pnl_pct": "float"}],
            "timestamp": "ISO8601"
        },
        "consumers": ["Databricks"]
    },
    "trade.journal_entry": {
        "description": "New trading journal entry created",
        "payload": {
            "user_id": "str",
            "symbol": "str",
            "action": "str",
            "pnl": "float",
            "tags": ["list"],
            "timestamp": "ISO8601"
        },
        "consumers": ["Databricks"]
    }
}
```

### 8.3 Cross-Pipeline Events: Azure Consumes

```python
# Azure subscribes to (consumed from others)
EVENTS_AZURE_CONSUMES = {
    "signal.generated": {
        "publisher": "AWS",
        "description": "Core trading signal from ML models"
    },
    "whale.alert": {
        "publisher": "GCP",
        "description": "Blockchain whale activity alert"
    },
    "onchain.signal": {
        "publisher": "GCP",
        "description": "On-chain activity signal"
    }
}
```

### 8.4 Fallback Behavior When Others Are Down

| Pipeline Down | Azure Behavior | User Impact |
|--------------|---------------|-------------|
| **AWS down** | Social signals still work (local Azure SQL) | ML-generated signals unavailable |
| **GCP down** | Blockchain alerts show cached data | No new whale alerts |
| **Databricks down** | Historical performance shows cached data | No live attribution |

### 8.5 Standalone Operation

Azure can operate **fully independently** for its social features:

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    AZURE STANDALONE OPERATION                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Social Trading, Competitions, Trading Journal:                                    │
│  - Azure SQL stores all social data locally                                       │
│  - AOAI (GPT-4) runs independently                                                │
│  - Azure Functions process events via Event Hub                                    │
│  - Power BI dashboards pull from Azure SQL directly                                 │
│                                                                                     │
│  NO EXTERNAL DEPENDENCIES REQUIRED FOR SOCIAL FEATURES                           │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Next Steps

1. **Review and approve Azure Pipeline PRD**
2. Build Azure core infrastructure (VNet, AKS, Azure SQL)
3. Setup AOAI for chat/summarization features
4. Deploy social trading backend
5. Configure Power BI for leaderboards
6. Integrate Cloudflare Queues for cross-pipeline events
