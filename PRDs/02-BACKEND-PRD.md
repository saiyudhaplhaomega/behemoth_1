# PRD 02 - Backend Architecture

**Version:** 1.0  
**Date:** 2026-04-16  
**Related To:** Master PRD, Frontend PRD  
**Status:** Draft

---

## 1. Overview

### 1.1 What Are We Building?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BACKEND ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    UNIFIED API GATEWAY                                 │   │
│   │                     (Python FastAPI)                              │   │
│   │                                                                       │   │
│   │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐      │   │
│   │   │  Auth   │ │Routing  │ │ Rate    │ │ Load    │ │SSL/TLS  │      │   │
│   │   │ Middleware│ │Engine  │ │ Limiting│ │ Balance │ │Termin.  │      │   │
│   │   └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘      │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                       │                                      │
│              ┌────────────────────────┼────────────────────────┐             │
│              │                        │                        │             │
│              ▼                        ▼                        ▼             │
│   ┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────────┐    │
│   │    AWS BACKEND      │ │     GCP BACKEND     │ │   AZURE BACKEND     │    │
│   │   ┌─────────────┐   │ │   ┌─────────────┐   │ │   ┌─────────────┐   │    │
│   │   │ Python  │   │ │   │ Python  │   │ │   │ Python  │   │    │
│   │   │ FastAPI     │   │ │   │ FastAPI     │   │ │   │ FastAPI     │   │    │
│   │   └─────────────┘   │ │   └─────────────┘   │ │   └─────────────┘   │    │
│   │   ┌─────────────┐   │ │   ┌─────────────┐   │ │   ┌─────────────┐   │    │
│   │   │ ML Service  │   │ │   │ ML Service  │   │ │   │ ML Service  │   │    │
│   │   │ (SageMaker) │   │ │   │ (Vertex AI) │   │ │   │ (Azure ML)  │   │    │
│   │   └─────────────┘   │ │   └─────────────┘   │ │   └─────────────┘   │    │
│   │   ┌─────────────┐   │ │   ┌─────────────┐   │ │   ┌─────────────┐   │    │
│   │   │ AI Agent    │   │ │   │ AI Agent    │   │ │   │ AI Agent    │   │    │
│   │   │ (Google ADK)│   │ │   │(LangChain) │   │ │   │  (CrewAI)   │   │    │
│   │   └─────────────┘   │ │   └─────────────┘   │ │   └─────────────┘   │    │
│   └─────────────────────┘ └─────────────────────┘ └─────────────────────┘    │
│                                       │                                      │
│                                       ▼                                      │
│                           ┌─────────────────────┐                            │
│                           │ DATABRICKS BACKEND   │                            │
│                           │   ┌─────────────┐   │                            │
│                           │   │ Python  │   │                            │
│                           │   │ FastAPI     │   │                            │
│                           │   └─────────────┘   │                            │
│                           │   ┌─────────────┐   │                            │
│                           │   │ ML Service  │   │                            │
│                           │   │ (Databricks│   │                            │
│                           │   └─────────────┘   │                            │
│                           └─────────────────────┘                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Why One Backend Stack (Python + FastAPI)?

**Q: Why use Python + FastAPI for all backends instead of different languages?**

**A:** Simplicity and maintainability wins:

| Pipeline | Language | Framework | Justification |
|----------|----------|-----------|---------------|
| AWS | **Python** | FastAPI | Best ML ecosystem, SageMaker native support |
| GCP | **Python** | FastAPI | Same stack, unified team velocity |
| Azure | **Python** | FastAPI | Same stack, easier cross-cloud debugging |
| Databricks | **Python** | FastAPI | Same stack, native PySpark interop |

**Trade-off Analysis:**

| Approach | Pros | Cons |
|----------|------|------|
| **Single Python (Chosen)** | One language, best ML tooling, easier hiring | Minor perf difference vs Go |
| Multi-language | Native per-cloud optimization | Steeper learning curve, more complexity |

---

## 2. Unified API Gateway

### 2.1 Architecture

```mermaid
┌─────────────────────────────────────────────────────────────────────────────┐
│                         UNIFIED API GATEWAY                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                       FASTAPI ROUTER (Python)                          │  │
│  │                                                                        │  │
│  │   GET   /api/v1/pipelines/*       → Route to appropriate backend     │  │
│  │   POST  /api/v1/auth/*            → Auth service                      │  │
│  │   WS    /api/v1/ws                → WebSocket for real-time           │  │
│  │   GET   /api/v1/health            → Health check                      │  │
│  │                                                                        │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                       │                                      │
│  ┌───────────────────────────────────┼───────────────────────────────────┐  │
│  │                           MIDDLEWARE                                   │  │
│  │                                                                        │  │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐│  │
│  │   │    CORS     │→ │    Auth      │→ │ Rate Limit   │→ │   Logger  ││  │
│  │   │             │  │  (JWT/OAuth) │  │              │  │           ││  │
│  │   └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘│  │
│  │                                                                        │  │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐│  │
│  │   │   Request   │  │    Cache    │→ │  Validator  │→ │  Circuit  ││  │
│  │   │  Normalizer │  │  (Redis)    │  │             │  │  Breaker  ││  │
│  │   └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘│  │
│  │                                                                        │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                       │                                      │
│  ┌───────────────────────────────────┼───────────────────────────────────┐  │
│  │                           BACKEND ROUTING                              │  │
│  │                                                                        │  │
│  │   /api/v1/aws/*     → http://aws-backend:8081                          │  │
│  │   /api/v1/gcp/*     → http://gcp-backend:8082                          │  │
│  │   /api/v1/azure/*    → http://azure-backend:8083                        │  │
│  │   /api/v1/databricks/* → http://databricks-backend:8084                │  │
│  │                                                                        │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Why FastAPI for API Gateway?

**Q: Why use FastAPI for the API Gateway instead of Express?**

**A:** FastAPI is ideal for high-performance Python API Gateway:

| Factor | FastAPI | Express |
|--------|---------|---------|
| **Performance** | High performance | Good |
| **Type Safety** | Python type hints | Pydantic models |
| **Validation** | Built-in Pydantic | Middleware needed |
| **Plugin System** | Great DX | Good |
| **ML Ecosystem** | Native Python ML libs | Limited |

---

## 2.1 API Versioning Strategy

**Q: How do we version APIs to allow for breaking changes without breaking clients?**

**A:** URL-based versioning with a 12-month deprecation window:

| Version | Status | Sunset Date |
|---------|--------|------------|
| `/api/v1` | Active (deprecated) | 2027-04-16 |
| `/api/v2` | Active (current) | 2028-04-16 |
| `/api/v3` | Planned | TBD |

**Versioning Rules:**
1. **Breaking changes** (response schema, status codes) → New major version
2. **Additive changes** (new fields, new endpoints) → No version bump
3. **Deprecation** → 12-month notice before sunset
4. **Migration path** → All clients must migrate within deprecation window

**Response Headers for Versioning:**
```python
# Add to all responses
response.headers["API-Version"] = "v2"
response.headers["Deprecation"] = "true"
response.headers["Sunset"] = "Sat, 01 Apr 2027 00:00:00 GMT"
response.headers["Link"] = '<https://api.behemoth.ai/api/v3>; rel="successor-version"'
```

**Deprecation Response Format:**
```json
{
  "error": {
    "code": "DEPRECATED_VERSION",
    "message": "This endpoint is deprecated. Please use /api/v3/pipelines.",
    "sunset_date": "2027-04-01"
  }
}
```

---

## 2.2 Pagination Strategy

**Q: How do we handle large datasets without overwhelming clients or servers?**

**A:** Cursor-based pagination for all list endpoints:

| Endpoint Type | Pagination | Rationale |
|---------------|------------|-----------|
| List pipelines | Cursor-based | Stable during concurrent writes |
| List deployments | Cursor-based | Stable during concurrent writes |
| Search/filter | Offset + cursor hybrid | User can jump to page |
| ML experiments | Time-series cursor | Natural time ordering |

**Cursor Pagination Implementation:**
```python
from pydantic import BaseModel
from typing import Optional
import base64
import json

class Cursor(BaseModel):
    """Opaque cursor for pagination"""
    created_at: str
    id: str

    def encode(self) -> str:
        return base64.urlsafe_b64encode(
            json.dumps({"created_at": self.created_at, "id": self.id}).encode()
        ).decode()

    @classmethod
    def decode(cls, cursor: str) -> "Cursor":
        data = json.loads(base64.urlsafe_b64decode(cursor.encode()))
        return cls(**data)

class PaginatedResponse(BaseModel):
    data: list
    pagination: dict = {
        "next_cursor": Optional[str] = None,
        "prev_cursor": Optional[str] = None,
        "has_more": bool,
        "total_count": int  # Only on first page
    }
```

**Request/Response Example:**
```http
GET /api/v2/pipelines?cursor=eyJjcmVhdGVkX2F0IjoiMjAyNi0wNC0xNlQwMDowMDowMCIsImlkIjoiMTIzNDUifQ&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJjcmVhdGVkX2F0IjoiMjAyNi0wNC0xNlQwMDowMDowMCIsImlkIjoiMTIzNDUifQ",
    "has_more": true,
    "total_count": 150
  }
}
```

---

## 2.3 Database Migration Strategy (Alembic)

**Q: How do we safely evolve database schemas without downtime?**

**A:** Alembic for Python with the expand-contract pattern:

| Phase | Migration Type | Downtime |
|-------|---------------|----------|
| Expand | Add new table/column | None |
| Migrate | Backfill data | None |
| Contract | Drop old column/table | Brief lock |

**Migration Directory Structure:**
```
backends/
├── aws-backend/
│   ├── alembic/
│   │   ├── versions/
│   │   │   ├── 001_add_pipelines_table.py
│   │   │   ├── 002_add_deployments_table.py
│   │   │   └── 003_add_mlflow_uri_column.py
│   │   ├── env.py
│   │   └── script.py.mako
│   └── alembic.ini
```

**Migration Example (Zero-Downtime):**
```python
# migrations/004_add_model_version_column.py

def upgrade():
    # Phase 1: Expand - Add nullable column
    op.add_column('models',
        Column('version', String(50), nullable=True))

    # Phase 2: Migrate - Backfill (done in application code)
    # Application code reads version from 'v1'/'v2'/'v3' fallback logic

    # Phase 3: Contract - Make NOT NULL after backfill
    # Separate migration after application deploys
    op.alter_column('models', 'version', nullable=False)
```

**Migration Commands:**
```bash
# Generate new migration
alembic revision --autogenerate -m "Add models table"

# Apply migrations (CI/CD)
alembic upgrade head

# Rollback (emergency only)
alembic downgrade -1

# Check current state
alembic current
alembic history
```

**Testing Migrations:**
```bash
# Test on staging DB first
alembic upgrade head --sql > migration.sql
# Review SQL, then apply
psql -f migration.sql

# Never use downgrade in production
```

---

## 2.4 Security Headers

**Q: How do we protect against common web vulnerabilities (XSS, clickjacking, etc.)?**

**A:** FastAPI middleware with security headers:

```python
# backends/shared/src/middleware/security_headers.py

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        response = await call_next(request)

        # Prevent XSS
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-XSS-Protection"] = "1; mode=block"

        # Prevent clickjacking
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self'"

        # Force HTTPS
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"

        # Prevent MIME sniffing
        response.headers["X-Content-Type-Options"] = "nosniff"

        # Referrer policy
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"

        # Permissions policy (disable dangerous features)
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"

        return response
```

**Registered in FastAPI app:**
```python
# backends/aws-backend/src/main.py

from fastapi import FastAPI
from middleware.security_headers import SecurityHeadersMiddleware

app = FastAPI()
app.add_middleware(SecurityHeadersMiddleware)

# ... routes
```

---

## 2.5 Rate Limiting Configuration

**Q: How do we prevent API abuse without affecting legitimate users?**

**A:** Kong rate limiting plugin + per-user limits in application code:

| Tier | Requests/Minute | Burst | Use Case |
|------|-----------------|-------|----------|
| Free | 60 | 10 | Development |
| Pro | 600 | 100 | Production |
| Enterprise | 6000 | 1000 | High-volume |

**Rate Limit Headers:**
```http
X-RateLimit-Limit: 600
X-RateLimit-Remaining: 599
X-RateLimit-Reset: 1713206400
Retry-After: 60
```

**Per-User Rate Limiting (FastAPI):**
```python
# backends/shared/src/middleware/rate_limiter.py

from fastapi import Request, HTTPException
from redis import Redis
import time

async def check_rate_limit(request: Request, user_id: str, limit: int = 600):
    redis = Redis.from_url(os.getenv("REDIS_URL"))

    key = f"rate_limit:{user_id}"
    current = redis.get(key)

    if current and int(current) >= limit:
        raise HTTPException(
            status_code=429,
            headers={
                "Retry-After": redis.ttl(key),
                "X-RateLimit-Limit": limit,
                "X-RateLimit-Remaining": 0
            }
        )

    pipe = redis.pipeline()
    pipe.incr(key)
    pipe.expire(key, 60)  # 1 minute window
    pipe.execute()
```

**Kong Plugin Configuration:**
```yaml
# kong/rate-limiting-plugin.yaml
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limiting-global
plugin: rate-limiting
config:
  minute: 600
  policy: redis
  redis_host: redis
  hide_client_headers: false
```

---

## 3. AWS Backend (Python FastAPI)

### 3.1 Directory Structure

```
backends/
└── aws-backend/
    ├── src/
    │   ├── __init__.py
    │   ├── main.py                 # FastAPI application
    │   ├── config.py               # Configuration
    │   │
    │   ├── api/                    # API Routes
    │   │   ├── __init__.py
    │   │   ├── routes/
    │   │   │   ├── __init__.py
    │   │   │   ├── health.py       # Health checks
    │   │   │   ├── auth.py         # Auth endpoints
    │   │   │   ├── pipelines.py    # Pipeline CRUD
    │   │   │   ├── ml.py          # ML endpoints
    │   │   │   ├── deployments.py  # Deployments
    │   │   │   └── agents.py      # AI Agent endpoints
    │   │   └── dependencies.py     # FastAPI dependencies
    │   │
    │   ├── models/                # Pydantic Models
    │   │   ├── __init__.py
    │   │   ├── user.py
    │   │   ├── pipeline.py
    │   │   ├── deployment.py
    │   │   ├── model.py          # ML models
    │   │   └── agent.py          # Agent requests/responses
    │   │
    │   ├── services/              # Business Logic
    │   │   ├── __init__.py
    │   │   ├── pipeline_service.py
    │   │   ├── deployment_service.py
    │   │   ├── notification_service.py
    │   │   └── cost_service.py
    │   │
    │   ├── ml/                    # ML Integration
    │   │   ├── __init__.py
    │   │   ├── sagemaker_client.py  # SageMaker SDK wrapper
    │   │   ├── inference.py         # Inference endpoints
    │   │   ├── training.py         # Training jobs
    │   │   └── model_registry.py   # Model registry
    │   │
    │   ├── agents/                # AI Agent (Google ADK)
    │   │   ├── __init__.py
    │   │   ├── agent.py         # Main agent class
    │   │   ├── tools/
    │   │   │   ├── __init__.py
    │   │   │   ├── sagemaker_tools.py
    │   │   │   ├── lambda_tools.py
    │   │   │   ├── ecs_tools.py
    │   │   │   └── cost_tools.py
    │   │   └── prompts/
    │   │       ├── __init__.py
    │   │       └── system_prompt.py
    │   │
    │   ├── db/                    # Database
    │   │   ├── __init__.py
    │   │   ├── database.py       # SQLAlchemy connection
    │   │   ├── redis.py          # Redis client
    │   │   └── repositories/
    │   │       ├── __init__.py
    │   │       ├── user_repo.py
    │   │       └── pipeline_repo.py
    │   │
    │   ├── middleware/            # Custom Middleware
    │   │   ├── __init__.py
    │   │   ├── logging.py
    │   │   ├── metrics.py        # Prometheus metrics
    │   │   └── tracing.py        # OpenTelemetry
    │   │
    │   └── utils/               # Utilities
    │       ├── __init__.py
    │       ├── exceptions.py
    │       └── helpers.py
    │
    ├── tests/
    │   ├── __init__.py
    │   ├── conftest.py         # Pytest fixtures
    │   ├── unit/
    │   │   ├── test_services.py
    │   │   ├── test_agents.py
    │   │   └── test_ml.py
    │   ├── integration/
    │   │   └── test_api.py
    │   └── contracts/           # Pact tests
    │       └── consumer_pacts/
    │
    ├── scripts/
    │   ├── init_db.py
    │   └── seed_data.py
    │
    ├── Dockerfile
    ├── docker-compose.yml
    ├── Makefile
    ├── requirements.txt
    ├── requirements-dev.txt
    └── pyproject.toml
```

### 3.2 FastAPI Application Structure

```python
# src/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

from api.routes import health, pipelines, ml
from config import settings

# ═══════════════════════════════════════════════════════════════════════════
# FASTAPI APPLICATION
# ═══════════════════════════════════════════════════════════════════════════

app = FastAPI(
    title="AWS Backend API",
    description="MLOps Backend for AWS Pipeline",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ═══════════════════════════════════════════════════════════════════════════
# MIDDLEWARE
# ═══════════════════════════════════════════════════════════════════════════

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prometheus metrics
Instrumentator().instrument(app).expose(app)

# OpenTelemetry tracing
FastAPIInstrumentor.instrument(app)

# ═══════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "aws-backend"}

@app.get("/health/ready")
async def readiness_check():
    return {"status": "ready"}

@app.get("/health/live")
async def liveness_check():
    return {"status": "alive"}

# ═══════════════════════════════════════════════════════════════════════════
# API ROUTES
# ═══════════════════════════════════════════════════════════════════════════

app.include_router(health.router, prefix="/api/v1")
app.include_router(pipelines.router, prefix="/api/v1/pipelines")
app.include_router(ml.router, prefix="/api/v1/ml")

# ═══════════════════════════════════════════════════════════════════════════
# START SERVER
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8081, reload=False)
```

### 3.3 API Routes Example

```python
# src/api/routes/pipelines.py

from fastapi import APIRouter, Header, HTTPException, Query
from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum

router = APIRouter()

class PipelineStatus(str, Enum):
    running = "running"
    stopped = "stopped"
    error = "error"

class PipelineBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None

class PipelineCreate(PipelineBase):
    pass

class Pipeline(PipelineBase):
    id: str
    status: PipelineStatus
    createdAt: str

class PipelineListResponse(BaseModel):
    pipelines: list[Pipeline]
    total: int
    skip: int
    limit: int

class DeploymentResponse(BaseModel):
    deploymentId: str
    environment: str
    status: str

# GET /pipelines - List all pipelines
@router.get("/", response_model=PipelineListResponse)
async def list_pipelines(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[PipelineStatus] = None,
    x_user_id: str = Header(..., alias="x-user-id"),
):
    pipelines, total = await pipeline_service.list(
        user_id=x_user_id,
        skip=skip,
        limit=limit,
        status=status,
    )
    return PipelineListResponse(
        pipelines=pipelines,
        total=total,
        skip=skip,
        limit=limit,
    )

# POST /pipelines - Create a new pipeline
@router.post("/", response_model=Pipeline, status_code=201)
async def create_pipeline(
    pipeline: PipelineCreate,
    x_user_id: str = Header(..., alias="x-user-id"),
):
    new_pipeline = await pipeline_service.create(
        user_id=x_user_id,
        name=pipeline.name,
        description=pipeline.description,
    )
    return new_pipeline

# GET /pipelines/:id - Get pipeline by ID
@router.get("/{pipeline_id}", response_model=Pipeline)
async def get_pipeline(
    pipeline_id: str,
    x_user_id: str = Header(..., alias="x-user-id"),
):
    pipeline = await pipeline_service.get(id=pipeline_id, user_id=x_user_id)
    if not pipeline:
        raise HTTPException(status_code=404, detail=f"Pipeline {pipeline_id} not found")
    return pipeline

# PUT /pipelines/:id - Update pipeline
@router.put("/{pipeline_id}", response_model=Pipeline)
async def update_pipeline(
    pipeline_id: str,
    updates: PipelineCreate,
    x_user_id: str = Header(..., alias="x-user-id"),
):
    pipeline = await pipeline_service.update(
        id=pipeline_id,
        user_id=x_user_id,
        updates=updates.model_dump(exclude_unset=True),
    )
    if not pipeline:
        raise HTTPException(status_code=404, detail=f"Pipeline {pipeline_id} not found")
    return pipeline

# DELETE /pipelines/:id - Delete pipeline
@router.delete("/{pipeline_id}", status_code=204)
async def delete_pipeline(
    pipeline_id: str,
    x_user_id: str = Header(..., alias="x-user-id"),
):
    deleted = await pipeline_service.delete(id=pipeline_id, user_id=x_user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail=f"Pipeline {pipeline_id} not found")
    return None

# POST /pipelines/:id/deploy - Trigger deployment
@router.post("/{pipeline_id}/deploy", response_model=DeploymentResponse, status_code=201)
async def deploy_pipeline(
    pipeline_id: str,
    environment: str = Query("staging"),
    x_user_id: str = Header(..., alias="x-user-id"),
):
    deployment = await pipeline_service.deploy(
        id=pipeline_id,
        user_id=x_user_id,
        environment=environment,
    )
    return deployment
```

### 3.4 ML Service Integration

```python
# src/ml/sagemaker_client.py

import boto3
from botocore.config import Config
from typing import Optional
from datetime import datetime
from .config import settings

class SageMakerClient:
    def __init__(self, region: Optional[str] = None):
        self.region = region or settings.AWS_REGION
        config = Config(
            retries={"max_attempts": 3, "mode": "standard"},
            connect_timeout=5,
            read_timeout=60,
        )
        self.client = boto3.client("sagemaker", region_name=self.region, config=config)

    async def create_training_job(
        self,
        job_name: str,
        training_image: str,
        role_arn: str,
        output_path: str,
        hyperparameters: dict[str, str],
        instance_config: dict,
    ) -> str:
        response = self.client.create_training_job(
            TrainingJobName=job_name,
            AlgorithmSpecification={
                "TrainingImage": training_image,
                "TrainingInputMode": "File",
            },
            RoleArn=role_arn,
            OutputDataConfig={"S3OutputPath": output_path},
            ResourceConfig={
                "InstanceType": instance_config["instance_type"],
                "InstanceCount": instance_config["instance_count"],
                "VolumeSizeInGB": instance_config.get("volume_size", 30),
            },
            HyperParameters=hyperparameters,
            StoppingCondition={"MaxRuntimeInSeconds": 86400},
        )
        return response["TrainingJobArn"]

    async def get_training_job_status(self, job_name: str) -> dict:
        response = self.client.describe_training_job(TrainingJobName=job_name)
        return {
            "status": response["TrainingJobStatus"],
            "creation_time": str(response.get("CreationTime", "")),
            "training_time": response.get("TrainingTimeInSeconds", 0),
            "metrics": response.get("FinalMetricDataList", []),
            "best_model": response.get("BestCandidate", {}).get("CandidateName"),
            "failure_reason": response.get("FailureReason"),
        }

    async def list_training_jobs(
        self, max_results: int = 100, status_filter: Optional[str] = None
    ) -> dict:
        kwargs = {"MaxResults": max_results}
        if status_filter:
            kwargs["StatusEquals"] = status_filter
        response = self.client.list_training_jobs(**kwargs)
        return {
            "jobs": response.get("TrainingJobSummaries", []),
            "count": len(response.get("TrainingJobSummaries", [])),
            "next_token": response.get("NextToken"),
        }
```

---

## 4. AI Agent (Google ADK)

### 4.1 Agent Architecture

```python
# src/agents/agent.py

import os
import json
import logging
from typing import Optional, Any
from google.adk.agents import Agent
from google.adk.models import get_model_from_environment
from google.adk.tools import Tool
from .tools.sagemaker_tools import (
    list_training_jobs,
    create_training_job,
    get_training_job_status,
)
from .tools.ecs_tools import list_tasks, scale_service
from .tools.cost_tools import get_monthly_costs, get_service_costs
from .prompts.system_prompt import AWS_SYSTEM_PROMPT

logger = logging.getLogger(__name__)

class AWSPlatformAgent:
    def __init__(self, model_name: Optional[str] = None):
        self.model_name = model_name or os.getenv("ADK_MODEL_NAME", "gemini-2.0-flash")
        self.agent = self._build_agent()

    def _build_agent(self) -> Agent:
        tools: list[Tool] = [
            list_training_jobs,
            create_training_job,
            get_training_job_status,
            list_tasks,
            scale_service,
            get_monthly_costs,
            get_service_costs,
        ]
        return Agent(
            model=self.model_name,
            name="aws_platform_agent",
            description="AWS MLOps platform assistant for managing pipelines, ML models, and infrastructure",
            instruction=AWS_SYSTEM_PROMPT,
            tools=tools,
            before_agent_run=self._before_callback,
            after_agent_run=self._after_callback,
        )

    def _before_callback(self, context: dict[str, Any]) -> None:
        logger.info(f"Agent invoked with context: {json.dumps(context)}")

    def _after_callback(self, response: Any) -> None:
        logger.info(f"Agent response: {response}")

    async def run(self, user_message: str, session_id: str) -> str:
        try:
            response = await self.agent.run(
                user_id=session_id,
                session_id=session_id,
                message=user_message,
            )
            return response.text if hasattr(response, "text") else str(response)
        except Exception as e:
            logger.error(f"Agent error: {e}")
            return f"I encountered an error: {str(e)}"

    def list_available_tools(self) -> list[str]:
        return [tool.name for tool in self.agent.tools]
```

### 4.2 Agent Tools

```python
# src/agents/tools/sagemaker_tools.py

import boto3
import os
from typing import Any
from google.adk.tools import Tool

sagemaker_client = boto3.client("sagemaker", region_name=os.getenv("AWS_REGION", "us-east-1"))

def create_sagemaker_tool(
    name: str,
    description: str,
    input_schema: dict,
    execute_fn: Any,
) -> Tool:
    return Tool(
        name=name,
        description=description,
        input_schema=input_schema,
        func=execute_fn,
    )

list_training_jobs = create_sagemaker_tool(
    name="list_training_jobs",
    description="List all SageMaker training jobs",
    input_schema={
        "type": "object",
        "properties": {
            "max_results": {"type": "integer", "default": 100},
            "status": {"type": "string"},
        },
    },
    execute_fn=lambda args: _list_training_jobs_impl(args),
)

def _list_training_jobs_impl(args: dict) -> dict:
    try:
        kwargs = {"MaxResults": args.get("max_results", 100)}
        if args.get("status"):
            kwargs["StatusEquals"] = args["status"]
        response = sagemaker_client.list_training_jobs(**kwargs)
        return {
            "success": True,
            "jobs": response.get("TrainingJobSummaries", []),
            "count": len(response.get("TrainingJobSummaries", [])),
            "next_token": response.get("NextToken"),
        }
    except Exception as e:
        return {"success": False, "error": str(e), "jobs": [], "count": 0}

create_training_job = create_sagemaker_tool(
    name="create_training_job",
    description="Create a new SageMaker training job",
    input_schema={
        "type": "object",
        "required": ["job_name", "image_uri", "role_arn", "output_path"],
        "properties": {
            "job_name": {"type": "string"},
            "image_uri": {"type": "string"},
            "role_arn": {"type": "string"},
            "output_path": {"type": "string"},
            "instance_type": {"type": "string", "default": "ml.m5.xlarge"},
            "instance_count": {"type": "integer", "default": 1},
        },
    },
    execute_fn=lambda args: _create_training_job_impl(args),
)

def _create_training_job_impl(args: dict) -> dict:
    try:
        response = sagemaker_client.create_training_job(
            TrainingJobName=args["job_name"],
            AlgorithmSpecification={
                "TrainingImage": args["image_uri"],
                "TrainingInputMode": "File",
            },
            RoleArn=args["role_arn"],
            OutputDataConfig={"S3OutputPath": args["output_path"]},
            ResourceConfig={
                "InstanceType": args.get("instance_type", "ml.m5.xlarge"),
                "InstanceCount": args.get("instance_count", 1),
                "VolumeSizeInGB": 30,
            },
            StoppingCondition={"MaxRuntimeInSeconds": 86400},
        )
        return {
            "success": True,
            "job_arn": response["TrainingJobArn"],
            "job_name": args["job_name"],
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

get_training_job_status = create_sagemaker_tool(
    name="get_training_job_status",
    description="Get the status of a SageMaker training job",
    input_schema={
        "type": "object",
        "required": ["job_name"],
        "properties": {
            "job_name": {"type": "string"},
        },
    },
    execute_fn=lambda args: _get_training_job_status_impl(args),
)

def _get_training_job_status_impl(args: dict) -> dict:
    try:
        response = sagemaker_client.describe_training_job(
            TrainingJobName=args["job_name"]
        )
        return {
            "success": True,
            "job_name": args["job_name"],
            "status": response["TrainingJobStatus"],
            "creation_time": str(response.get("CreationTime", "")),
            "training_time": response.get("TrainingTimeInSeconds", 0),
            "metrics": response.get("FinalMetricDataList", []),
            "best_model": response.get("BestCandidate", {}).get("CandidateName"),
            "failure_reason": response.get("FailureReason"),
        }
    except Exception as e:
        return {"success": False, "error": str(e)}
```

---

## 5. Backend Comparison Matrix

| Feature | AWS (Python+FastAPI) | GCP (Python+FastAPI) | Azure (Python+FastAPI) | Databricks (Python+FastAPI) |
|---------|----------------------|----------------------|------------------------|------------------------------|
| **Language** | Python | Python | Python | Python |
| **Web Framework** | FastAPI | FastAPI | FastAPI | FastAPI |
| **ORM** | SQLAlchemy | SQLAlchemy | SQLAlchemy | SQLAlchemy |
| **ML SDK** | boto3 (SageMaker) | google-cloud-aiplatform | azure-ai-ml | databricks-sdk |
| **AI Agent** | Google ADK | LangChain + LangGraph | CrewAI | Custom + MLflow |
| **Auth** | AWS Cognito | GCP IAP | Azure AD | Databricks OAuth |
| **Caching** | Redis (ElastiCache) | Memorystore | Azure Cache | Redis |
| **Monitoring** | Grafana + Prometheus | Grafana + Prometheus | Grafana + Prometheus | Grafana + Prometheus |

---

## 6. API Contract Testing (Pact)

### 6.1 Consumer Test Example

```python
# tests/contracts/test_pipeline_consumer.py

import pytest
from pact import Consumer, Provider, Like, Term

consumer = Consumer("aws-frontend")
provider = Provider("aws-backend")

pact = consumer.with_pact_provider(provider, log_dir="tests/pacts", pact_dir="tests/pacts")


@pytest.fixture(scope="module")
def pact_setup():
    pact.start_service()
    yield
    pact.stop_service()


def test_get_pipelines(pact_setup):
    pact.given("pipelines exist").upon_receiving("a request for pipelines").with_request(
        method="GET",
        path="/api/v1/pipelines",
        headers={"Authorization": "Bearer test-token"},
    ).will_respond_with(
        status=200,
        body={
            "pipelines": [
                {
                    "id": "123",
                    "name": "Test Pipeline",
                    "status": "running",
                    "createdAt": Term(match=r".*", example="2026-04-16T00:00:00Z"),
                },
            ],
            "total": 1,
            "skip": 0,
            "limit": 100,
        },
    )

    with pact.verify():
        import requests
        response = requests.get(
            "http://localhost:8081/api/v1/pipelines",
            headers={"Authorization": "Bearer test-token"},
        )
        assert response.status_code == 200
        data = response.json()
        assert len(data["pipelines"]) == 1
```

---

## 7. Docker Configuration

```dockerfile
# Dockerfile

FROM python:3.11-slim

WORKDIR /app

# Install dependencies first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Expose port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8081/health')" || exit 1

# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8081"]
```

---

## 8. 💰 Cost-Saving Checkpoints

After completing Backend Development:

```
□ Delete local Docker images after testing
□ Stop PostgreSQL/Redis containers when not in use
□ Use smaller instance types for development
□ Enable connection pooling
□ Implement response caching
□ Use batch operations where possible
□ Turn off detailed logging in production
```

---

## 9. Baby Steps Implementation

### Step 2.1: Setup AWS Backend

```
TASKS:
□ Create directory structure
□ Initialize Python project (pyproject.toml)
□ Setup Python virtual environment
□ Install FastAPI and dependencies
□ Create basic FastAPI app structure
□ Add health check endpoints
□ Setup SQLAlchemy ORM with PostgreSQL
□ Setup Redis connection (redis-py)
□ Write first unit test (Pytest)
□ Test: make test SECTION=aws-backend
```

### Step 2.2: Create API Routes

```
TASKS:
□ Create Pydantic models for validation
□ Create pipeline CRUD routes
□ Create ML endpoints
□ Create deployment endpoints
□ Add authentication middleware
□ Add logging middleware
□ Write integration tests
□ Test: make test SECTION=aws-backend
```

### Step 2.3: Integrate SageMaker

```
TASKS:
□ Install AWS SDK (boto3)
□ Create SageMaker client wrapper
□ Implement training job creation
□ Implement endpoint deployment
□ Implement inference endpoints
□ Test with mock AWS calls (moto)
□ Test: make test SECTION=aws-backend
```

### Step 2.4: Add AI Agent (Google ADK)

```
TASKS:
□ Install Google ADK (google-adk)
□ Create agent class
□ Define agent tools
□ Create system prompt
□ Integrate with API routes
□ Write agent tests
□ Test: make test SECTION=aws-backend
```

---

## 10. Success Criteria

| Criterion | Measurement |
|-----------|-------------|
| API Response Time | < 200ms p95 |
| Code Coverage | > 80% |
| Type Hints | 100% public API |
| Documentation | OpenAPI spec auto-generated |
| Docker Image Size | < 500MB |
| Cold Start | < 3 seconds |

---

**Next Steps:**
1. Review and approve Backend PRD
2. Move to AWS Pipeline PRD (03-AWS-PIPELINE-PRD.md)
3. Begin Step 2.1: Setup AWS Backend
