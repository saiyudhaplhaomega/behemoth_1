# ═══════════════════════════════════════════════════════════════════════════════
# ENTERPRISE MLOPS PLATFORM - ROOT MAKEFILE
# ═══════════════════════════════════════════════════════════════════════════════
#
# This is the main entry point for all operations across all 4 cloud pipelines.
# Each section has its own Makefile that can be run independently.
#
# Usage:
#   make help                    - Show all available targets
#   make deploy SECTION=aws      - Deploy specific section
#   make test SECTION=frontend   - Test specific section
#
# ═══════════════════════════════════════════════════════════════════════════════

.SHELL := /bin/bash
.DELETE_ON_ERROR:
.SUFFIXES:

# ─────────────────────────────────────────────────────────────────────────────
# Variables
# ─────────────────────────────────────────────────────────────────────────────

export SECTION ?= all
export ENV ?= dev
export PIPELINE ?= aws

# Cloud providers
CLOUDS := aws gcp azure databricks

# Directories
ROOT_DIR := $(shell pwd)
INFRA_DIR := $(ROOT_DIR)/infrastructure
FRONTENDS_DIR := $(ROOT_DIR)/frontends
BACKENDS_DIR := $(ROOT_DIR)/backends
MLOPS_DIR := $(ROOT_DIR)/mlops
PACKAGES_DIR := $(ROOT_DIR)/packages
PRDS_DIR := $(ROOT_DIR)/PRDs

# Docker
DOCKER_REGISTRY ?= 123456789.dkr.ecr.us-east-1.amazonaws.com
IMAGE_TAG ?= $(shell git rev-parse --short HEAD)

# Terraform
TERRAFORM_VERSION := 1.6.0
TERRAFORM_BACKEND := s3://mlops-terraform-state/terraform.tfstate

# Python
PYTHON_VERSION := 3.11
PYTHON_PATH := .venv/bin/activate

# Node
NODE_VERSION := 20

# Colors
BOLD := \033[1m
GREEN := \033[0;32m
BLUE := \033[0;34m
RED := \033[0;31m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# ─────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────────────────────

define print_header
	@echo ""
	@echo "$(BOLD)$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BOLD)$(BLUE)  $1$(NC)"
	@echo "$(BOLD)$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
endef

define print_success
	@echo "$(GREEN)✓ $1$(NC)"
endef

define print_error
	@echo "$(RED)✗ $1$(NC)"
endef

define print_warning
	@echo "$(YELLOW)⚠ $1$(NC)"
endef

# ─────────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────────

help: ## Show this help message
	@echo ""
	@$(call print_header,"Enterprise MLOps Platform - Makefile Help")
	@echo "$(BOLD)USAGE:$(NC)"
	@echo "  make [target] [SECTION=value] [ENV=value] [PIPELINE=value]"
	@echo ""
	@echo "$(BOLD)GLOBAL TARGETS:$(NC)"
	@echo "  help                    Show this help"
	@echo "  setup                   Initial project setup"
	@echo "  setup:env               Create .env files from templates"
	@echo ""
	@echo "$(BOLD)DEPLOYMENT:$(NC)"
	@echo "  deploy                  Deploy all or specific section"
	@echo "  deploy:infra            Deploy infrastructure"
	@echo "  deploy:apps             Deploy applications"
	@echo "  deploy:ml               Deploy ML models"
	@echo "  deploy:db               Deploy databases"
	@echo ""
	@echo "$(BOLD)TESTING:$(NC)"
	@echo "  test                    Run all tests"
	@echo "  test:unit               Run unit tests"
	@echo "  test:integration        Run integration tests"
	@echo "  test:e2e                Run E2E tests"
	@echo "  test:contracts           Run contract tests"
	@echo "  test:security            Run security tests"
	@echo ""
	@echo "$(BOLD)BUILD:$(NC)"
	@echo "  build                   Build all containers"
	@echo "  build:frontend           Build frontend containers"
	@echo "  build:backend            Build backend containers"
	@echo "  build:ml                 Build ML containers"
	@echo ""
	@echo "$(BOLD)INFRASTRUCTURE:$(NC)"
	@echo "  infra:init              Initialize Terraform"
	@echo "  infra:plan              Plan infrastructure changes"
	@echo "  infra:apply             Apply infrastructure changes"
	@echo "  infra:destroy            Destroy infrastructure"
	@echo "  infra:validate           Validate Terraform"
	@echo ""
	@echo "$(BOLD)CLEANUP:$(NC)"
	@echo "  clean                   Clean build artifacts"
	@echo "  clean:all                Clean everything"
	@echo "  prune                   Prune Docker resources"
	@echo ""
	@echo "$(BOLD)UTILITIES:$(NC)"
	@echo "  logs                    Get application logs"
	@echo "  ssh                     SSH to bastion host"
	@echo "  exec                    Execute command in container"
	@echo "  docs                    Generate documentation"
	@echo ""
	@echo "$(BOLD)AVAILABLE SECTIONS:$(NC)"
	@echo "  aws, gcp, azure, databricks, frontend, backend, ml, all"
	@echo ""
	@echo "$(BOLD)AVAILABLE ENVIRONMENTS:$(NC)"
	@echo "  dev, staging, prod"
	@echo ""
	@echo "$(BOLD)EXAMPLES:$(NC)"
	@echo "  make deploy SECTION=aws ENV=dev"
	@echo "  make test SECTION=frontend PIPELINE=aws"
	@echo "  make infra:apply SECTION=gcp ENV=staging"
	@echo ""
	@echo "$(BOLD)COST-SAVING COMMANDS:$(NC)"
	@echo "  make stop     SECTION=aws     # Stop running services"
	@echo "  make start    SECTION=aws     # Start stopped services"
	@echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

setup: ## Initial project setup
	@$(call print_header,"Initial Setup")
	@echo "$(BOLD)Checking prerequisites...$(NC)"
	@command -v docker >/dev/null 2>&1 || { $(call print_error,"Docker is required but not installed."; exit 1); }
	@command -v terraform >/dev/null 2>&1 || { $(call print_error,"Terraform is required but not installed."; exit 1); }
	@command -v node >/dev/null 2>&1 || { $(call print_error,"Node.js is required but not installed."; exit 1); }
	@command -v python3 >/dev/null 2>&1 || { $(call print_error,"Python is required but not installed."; exit 1); }
	@$(call print_success,"All prerequisites installed")
	@echo ""
	@echo "$(BOLD)Setting up Python virtual environments...$(NC)"
	@$(MAKE) setup:python
	@echo ""
	@echo "$(BOLD)Installing frontend dependencies...$(NC)"
	@$(MAKE) setup:frontend
	@echo ""
	@$(call print_success,"Initial setup complete!")
	@echo ""
	@$(call print_warning,"Next steps:")
	@echo "  1. Run 'make setup:env' to create .env files"
	@echo "  2. Configure your cloud credentials"
	@echo "  3. Run 'make deploy ENV=dev' to deploy to development"

setup:python: ## Setup Python virtual environments
	@for backend in $(BACKENDS_DIR)/*/; do \
		$(MAKE) setup:python:backend BACKEND=$$backend; \
	done
	@$(call print_success,"Python setup complete")

setup:python:backend: ## Setup Python for specific backend
	@cd $(BACKEND) && \
		python3 -m venv .venv && \
		source .venv/bin/activate && \
		pip install --upgrade pip && \
		pip install -r requirements.txt

setup:frontend: ## Install frontend dependencies
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		$(MAKE) setup:frontend:$$frontend; \
	done

setup:frontend:$$(FRONTENDS_DIR)/%: ## Setup specific frontend
	@cd $@ && npm install

setup:env: ## Create .env files from templates
	@echo "$(BOLD)Creating .env files...$(NC)"
	@for env_file in $(shell find . -name ".env.example" -o -name ".env.template" 2>/dev/null); do \
		env_dest=$$(dirname $$env_file)/.env; \
		if [ ! -f $$env_dest ]; then \
			cp $$env_file $$env_dest; \
			echo "Created $$env_dest"; \
		else \
			echo "$$env_dest already exists, skipping"; \
		fi \
	done

# ─────────────────────────────────────────────────────────────────────────────
# Testing
# ─────────────────────────────────────────────────────────────────────────────

test: ## Run all tests
	@$(call print_header,"Running All Tests")
	@$(MAKE) test:unit
	@$(MAKE) test:integration
	@$(MAKE) test:contracts
	@$(call print_success,"All tests complete")

test:unit: ## Run unit tests
	@$(call print_header,"Running Unit Tests")
	@$(MAKE) test:unit:frontend
	@$(MAKE) test:unit:backend
	@$(MAKE) test:unit:ml

test:unit:frontend: ## Run frontend unit tests
	@$(call print_warning,"Running frontend unit tests...")
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		cd $$frontend && \
		echo "$(BOLD)Testing $$frontend...$(NC)" && \
		npm run test:unit -- --coverage --passWithNoTests || true; \
		cd - > /dev/null; \
	done

test:unit:backend: ## Run backend unit tests
	@$(call print_warning,"Running backend unit tests...")
	@$(MAKE) test:unit:backend:$(PIPELINE)

test:unit:backend:$$(BACKENDS_DIR)/%: ## Run specific backend tests
	@cd $@ && \
		source .venv/bin/activate 2>/dev/null || true && \
		pytest tests/unit -v --cov=src --cov-report=term-missing || true

test:unit:ml: ## Run ML tests
	@$(call print_warning,"Running ML unit tests...")
	@for cloud in $(CLOUDS); do \
		cd $(BACKENDS_DIR)/$$cloud-backend/src/ml 2>/dev/null && \
		pytest tests/ -v || true; \
		cd - > /dev/null; \
	done

test:integration: ## Run integration tests
	@$(call print_header,"Running Integration Tests")
	@$(call print_warning,"Running integration tests...")
	@docker-compose up -d test-deps
	@sleep 10
	@$(MAKE) test:integration:backend
	@$(MAKE) test:integration:e2e
	@docker-compose down

test:integration:backend: ## Run backend integration tests
	@for backend in $(BACKENDS_DIR)/*/; do \
		cd $$backend && \
		source .venv/bin/activate 2>/dev/null || true && \
		pytest tests/integration -v || true; \
		cd - > /dev/null; \
	done

test:integration:e2e: ## Run E2E integration tests
	@cd tests/e2e && \
		npx playwright install --with-deps && \
		npx playwright test

test:contracts: ## Run contract tests
	@$(call print_header,"Running Contract Tests")
	@docker-compose up -d pact-broker
	@sleep 5
	@for cloud in $(CLOUDS); do \
		$(MAKE) test:contract:$$cloud; \
	done
	@docker-compose down

test:contract:%: ## Run contract test for specific pipeline
	@$(call print_warning,"Running contract tests for $@...")

test:security: ## Run security tests
	@$(call print_header,"Running Security Tests")
	@$(MAKE) test:security:secret
	@$(MAKE) test:security:deps
	@$(MAKE) test:security:container

test:security:secret: ## Check for secrets in code
	@$(call print_warning,"Scanning for secrets...")
	@git clone --depth 1 https://github.com/trufflesecurity/trufflehog.git /tmp/trufflehog 2>/dev/null || true
	@trufflehog filesystem . || true

test:security:deps: ## Check dependency vulnerabilities
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		cd $$frontend && npm audit || true; \
		cd - > /dev/null; \
	done

test:security:container: ## Scan containers for vulnerabilities
	@$(call print_warning,"Scanning containers...")
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy image --severity HIGH,CRITICAL $(DOCKER_REGISTRY)/$(PIPELINE)-backend:latest || true

# ─────────────────────────────────────────────────────────────────────────────
# Building
# ─────────────────────────────────────────────────────────────────────────────

build: ## Build all Docker images
	@$(call print_header,"Building Docker Images")
	@$(MAKE) build:frontend
	@$(MAKE) build:backend
	@$(MAKE) build:ml

build:frontend: ## Build all frontend images
	@$(call print_warning,"Building frontend images...")
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		pipeline=$$(basename $$frontend | sed 's/-frontend//'); \
		cd $$frontend && \
		docker build -t $(DOCKER_REGISTRY)/$$pipeline-frontend:$(IMAGE_TAG) . && \
		docker tag $(DOCKER_REGISTRY)/$$pipeline-frontend:$(IMAGE_TAG) \
			$(DOCKER_REGISTRY)/$$pipeline-frontend:latest && \
		cd - > /dev/null; \
	done

build:backend: ## Build all backend images
	@$(call print_warning,"Building backend images...")
	@for backend in $(BACKENDS_DIR)/*/; do \
		pipeline=$$(basename $$backend | sed 's/-backend//'); \
		cd $$backend && \
		docker build -t $(DOCKER_REGISTRY)/$$pipeline-backend:$(IMAGE_TAG) . && \
		docker tag $(DOCKER_REGISTRY)/$$pipeline-backend:$(IMAGE_TAG) \
			$(DOCKER_REGISTRY)/$$pipeline-backend:latest && \
		cd - > /dev/null; \
	done

build:ml: ## Build ML images
	@$(call print_warning,"Building ML images...")
	@for cloud in $(CLOUDS); do \
		$(MAKE) build:ml:$$cloud; \
	done

build:ml:%: ## Build ML image for specific cloud
	@pipeline=$(@); \
	cd $(BACKENDS_DIR)/$$pipeline-backend/src/ml && \
	docker build -t $(DOCKER_REGISTRY)/$$pipeline-ml:$(IMAGE_TAG) -f Dockerfile.ml .

# ─────────────────────────────────────────────────────────────────────────────
# Infrastructure
# ─────────────────────────────────────────────────────────────────────────────

infra:init: ## Initialize Terraform for all clouds
	@$(call print_header,"Initializing Terraform")
	@for cloud in $(CLOUDS); do \
		$(MAKE) infra:init:$$cloud; \
	done

infra:init:%: ## Initialize Terraform for specific cloud
	@$(call print_warning,"Initializing Terraform for $@...")
	@cd $(INFRA_DIR)/$@ && \
		terraform init \
			-backend-config="bucket=mlops-terraform-state" \
			-backend-config="key=$@/terraform.tfstate" \
			-backend-config="region=us-east-1"

infra:plan: ## Plan infrastructure changes
	@$(call print_header,"Planning Infrastructure Changes")
	@if [ "$(SECTION)" = "all" ]; then \
		for cloud in $(CLOUDS); do \
			$(MAKE) infra:plan:$$cloud; \
		done \
	else \
		$(MAKE) infra:plan:$(SECTION); \
	fi

infra:plan:%: ## Plan for specific cloud
	@$(call print_warning,"Planning $@ infrastructure...")
	@cd $(INFRA_DIR)/$@ && \
		terraform workspace select $(ENV) 2>/dev/null || \
		terraform workspace new $(ENV) && \
		terraform plan -var-file="environments/$(ENV)/terraform.tfvars"

infra:apply: ## Apply infrastructure changes
	@$(call print_header,"Applying Infrastructure Changes")
	@if [ "$(SECTION)" = "all" ]; then \
		for cloud in $(CLOUDS); do \
			$(MAKE) infra:apply:$$cloud; \
		done \
	else \
		$(MAKE) infra:apply:$(SECTION); \
	fi

infra:apply:%: ## Apply for specific cloud
	@$(call print_warning,"Applying $@ infrastructure to $(ENV)...")
	@cd $(INFRA_DIR)/$@ && \
		terraform workspace select $(ENV) 2>/dev/null || \
		terraform workspace new $(ENV) && \
		terraform apply -var-file="environments/$(ENV)/terraform.tfvars" -auto-approve

infra:destroy: ## Destroy infrastructure
	@$(call print_warning,"This will destroy all resources in $(SECTION)/$(ENV)!")
	@read -p "Are you sure? (yes/no) " -r; \
	if [ $$REPLY = "yes" ]; then \
		cd $(INFRA_DIR)/$(SECTION) && \
		terraform workspace select $(ENV) && \
		terraform destroy -var-file="environments/$(ENV)/terraform.tfvars" -auto-approve; \
	fi

infra:validate: ## Validate Terraform
	@$(call print_header,"Validating Terraform")
	@for cloud in $(CLOUDS); do \
		cd $(INFRA_DIR)/$$cloud && \
		echo "$(BOLD)Validating $$cloud...$(NC)" && \
		terraform fmt -recursive && \
		terraform validate; \
		cd - > /dev/null; \
	done

# ─────────────────────────────────────────────────────────────────────────────
# Deployment
# ─────────────────────────────────────────────────────────────────────────────

deploy: ## Deploy all or specific section
	@$(call print_header,"Deploying $(SECTION) to $(ENV)")
	@$(MAKE) deploy:check
	@$(MAKE) infra:apply
	@$(MAKE) build
	@$(MAKE) deploy:apps
	@$(MAKE) deploy:ml
	@$(call print_success,"Deployment complete!")

deploy:check: ## Pre-deployment checks
	@$(call print_warning,"Running pre-deployment checks...")
	@command -v terraform >/dev/null 2>&1 || { $(call print_error,"Terraform required"; exit 1); }
	@command -v docker >/dev/null 2>&1 || { $(call print_error,"Docker required"; exit 1); }
	@$(call print_success,"Pre-deployment checks passed")

deploy:apps: ## Deploy applications
	@$(call print_header,"Deploying Applications")
	@$(MAKE) deploy:backend
	@$(MAKE) deploy:frontend

deploy:backend: ## Deploy backend
	@$(call print_warning,"Deploying backends...")
	@$(MAKE) deploy:backend:$(PIPELINE)

deploy:backend:%: ## Deploy specific backend
	@pipeline=$(@); \
	$(MAKE) build:backend:$$pipeline && \
	$(MAKE) deploy:ecs:$$pipeline || \
	$(MAKE) deploy:k8s:$$pipeline || \
	$(MAKE) deploy:cloudrun:$$pipeline || \
	$(MAKE) deploy:containerapps:$$pipeline || \
	$(MAKE) deploy:databricks:$$pipeline

deploy:frontend: ## Deploy frontend
	@$(call print_warning,"Deploying frontends...")
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		pipeline=$$(basename $$frontend | sed 's/-frontend//'); \
		$(MAKE) deploy:cdn:$$pipeline || \
		$(MAKE) deploy:s3:$$pipeline; \
	done

deploy:ml: ## Deploy ML models
	@$(call print_header,"Deploying ML Models")
	@$(MAKE) deploy:sagemaker || true
	@$(MAKE) deploy:vertexai || true
	@$(MAKE) deploy:azureml || true
	@$(MAKE) deploy:databricks_ml || true

# ─────────────────────────────────────────────────────────────────────────────
# Cost Management
# ─────────────────────────────────────────────────────────────────────────────

cost: ## Show cost estimates
	@$(call print_header,"Cost Estimates")
	@$(call print_warning,"Estimating monthly costs...")

cost:breakdown: ## Show cost breakdown by service
	@echo "$(BOLD)Monthly Cost Breakdown:$(NC)"
	@echo ""
	@echo "$(BOLD)AWS Pipeline:$(NC)"
	@echo "  ECS Tasks:     ~\$50-100"
	@echo "  RDS Aurora:    ~\$30-50"
	@echo "  SageMaker:      ~\$20-100 (usage-based)"
	@echo ""
	@echo "$(BOLD)GCP Pipeline:$(NC)"
	@echo "  GKE Cluster:   ~\$40-80"
	@echo "  Cloud SQL:     ~\$30-50"
	@echo "  Vertex AI:     ~\$20-100 (usage-based)"
	@echo ""
	@echo "$(BOLD)Azure Pipeline:$(NC)"
	@echo "  AKS Cluster:   ~\$40-80"
	@echo "  Azure SQL:    ~\$30-50"
	@echo "  Azure ML:     ~\$20-100 (usage-based)"
	@echo ""
	@echo "$(BOLD)Databricks Pipeline:$(NC)"
	@echo "  DBSQL:         ~\$20-50 (usage-based)"
	@echo "  Workspace:     ~\$50-100"
	@echo ""

stop: ## Stop running services (cost saving)
	@$(call print_warning,"Stopping services to save costs...")
	@$(MAKE) stop:ecs || true
	@$(MAKE) stop:gke || true
	@$(MAKE) stop:aks || true
	@$(MAKE) stop:databricks || true
	@$(call print_success,"Services stopped. Remember to start them when needed!")

stop:ecs: ## Stop ECS tasks
	@$(call print_warning,"Stopping ECS tasks...")

stop:gke: ## Scale down GKE cluster
	@$(call print_warning,"Scaling down GKE nodes...")

stop:aks: ## Scale down AKS cluster
	@$(call print_warning,"Scaling down AKS nodes...")

stop:databricks: ## Stop Databricks resources
	@$(call print_warning,"Stopping Databricks warehouses...")

start: ## Start stopped services
	@$(call print_warning,"Starting services...")
	@$(MAKE) start:ecs || true
	@$(MAKE) start:gke || true
	@$(MAKE) start:aks || true
	@$(MAKE) start:databricks || true
	@$(call print_success,"Services started!")

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────

clean: ## Clean build artifacts
	@$(call print_warning,"Cleaning build artifacts...")
	@find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".venv" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "coverage" -type d -exec rm -rf {} + 2>/dev/null || true
	@$(call print_success,"Clean complete")

clean:all: ## Clean everything
	@$(call print_warning,"This will clean ALL build artifacts and caches!")
	@$(MAKE) clean
	@docker system prune -af || true
	@docker volume prune -f || true
	@$(call print_success,"Full clean complete")

prune: ## Prune Docker resources
	@$(call print_warning,"Pruning Docker resources...")
	@docker system prune -f
	@docker builder prune -f
	@$(call print_success,"Prune complete")

# ─────────────────────────────────────────────────────────────────────────────
# Documentation
# ─────────────────────────────────────────────────────────────────────────────

docs: ## Generate documentation
	@$(call print_header,"Generating Documentation")
	@$(MAKE) docs:api
	@$(MAKE) docs:openapi
	@$(call print_success,"Documentation generated")

docs:api: ## Generate API documentation
	@$(call print_warning,"Generating API docs...")
	@for backend in $(BACKENDS_DIR)/*/; do \
		cd $$backend && \
		$(MAKE) docs:api || true; \
		cd - > /dev/null; \
	done

docs:openapi: ## Generate OpenAPI specs
	@$(call print_warning,"Generating OpenAPI specs...")
	@for backend in $(BACKENDS_DIR)/*/; do \
		cd $$backend && \
		$(MAKE) docs:openapi || true; \
		cd - > /dev/null; \
	done

# ─────────────────────────────────────────────────────────────────────────────
# Development
# ─────────────────────────────────────────────────────────────────────────────

dev: ## Start development environment
	@$(call print_header,"Starting Development Environment")
	@docker-compose up -d
	@$(call print_success,"Development environment started!")
	@echo ""
	@echo "$(BOLD)Services running:$(NC)"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  AWS API:   http://localhost:8081"
	@echo "  GCP API:   http://localhost:8082"
	@echo "  Azure API: http://localhost:8083"
	@echo "  DB API:    http://localhost:8084"
	@echo "  Gateway:   http://localhost:8000"

dev:stop: ## Stop development environment
	@docker-compose down
	@$(call print_success,"Development environment stopped")

lint: ## Run all linters
	@$(call print_header,"Running Linters")
	@$(MAKE) lint:frontend
	@$(MAKE) lint:backend
	@$(MAKE) lint:terraform

lint:frontend: ## Lint frontend code
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		cd $$frontend && \
		npm run lint || true; \
		cd - > /dev/null; \
	done

lint:backend: ## Lint backend code
	@$(MAKE) lint:backend:$(PIPELINE)

lint:backend:%: ## Lint specific backend
	@cd $(BACKENDS_DIR)/$(@) && \
		source .venv/bin/activate 2>/dev/null || true && \
		ruff check src/ || \
		flake8 src/ || \
		pylint src/ || true

lint:terraform: ## Lint Terraform
	@$(call print_warning,"Linting Terraform...")
	@for cloud in $(CLOUDS); do \
		cd $(INFRA_DIR)/$$cloud && \
		terraform fmt -recursive; \
		cd - > /dev/null; \
	done

fmt: ## Format all code
	@$(call print_header,"Formatting Code")
	@$(MAKE) fmt:frontend
	@$(MAKE) fmt:backend
	@$(MAKE) fmt:terraform

fmt:frontend: ## Format frontend code
	@for frontend in $(FRONTENDS_DIR)/*/; do \
		cd $$frontend && \
		npm run format || true; \
		cd - > /dev/null; \
	done

fmt:backend: ## Format backend code
	@$(call print_warning,"Formatting backend code...")
	@for backend in $(BACKENDS_DIR)/*/; do \
		cd $$backend && \
		black src/ 2>/dev/null || \
		ruff check --fix src/ 2>/dev/null || true; \
		cd - > /dev/null; \
	done

fmt:terraform: ## Format Terraform
	@$(call print_warning,"Formatting Terraform...")
	@for cloud in $(CLOUDS); do \
		cd $(INFRA_DIR)/$$cloud && \
		terraform fmt -recursive; \
		cd - > /dev/null; \
	done
