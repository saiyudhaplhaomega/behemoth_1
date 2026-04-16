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
│  VALUE PROPOSITION                           │    METRICS                   │
│  ───────────────────────────────────────────┼─────────────────────────────  │
│  • AWS-core infrastructure                  │  Single-cloud simplicity      │
│  • Cost optimization via cloud arbitrage    │  30-40% savings (future)       │
│  • ML innovation velocity                  │  5x faster model deployment   │
│  • Unified observability                    │  Single pane of glass         │
│  • Swarm intelligence                       │  10x faster signal generation │
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
│  │  ┌─────────────────────────────────────────────────────────────────────────┐    │  │
│  │  │                                                                   MVP   │    │  │
│  │  │  ┌───────────────────────────────────────────────────────────────┐   │    │  │
│  │  │  │                        AWS (ACTIVE)                            │   │    │  │
│  │  │  │  ┌───────────┐  ┌───────────────────────────────────────────┐│   │    │  │
│  │  │  │  │ Unified   │  │  Backend  │  ML Agent  │  Data Lake  │      ││   │    │  │
│  │  │  │  │ Dashboard │  │(FastAPI)  │(Google ADK│  (S3)      │      ││   │    │  │
│  │  │  │  │ (Next.js) │  │           │+CrewAI)    │            │      ││   │    │  │
│  │  │  │  └───────────┘  │           │            │            │      ││   │    │  │
│  │  │  │                 │  ML Pipeline│          │  ETL      │      ││   │    │  │
│  │  │  │                 │(SageMaker) │           │ (Glue)    │      ││   │    │  │
│  │  │  │                 └────────────┴───────────┴───────────┴──────┘│   │    │  │
│  │  │  └───────────────────────────────────────────────────────────────┘   │    │  │
│  │  └───────────────────────────────────────────────────────────────────┘   │  │
│  │                                                                                │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │  │
│  │  │      GCP        │  │     Azure       │  │   Databricks    │             │  │
│  │  │   (DEFERRED)    │  │   (DEFERRED)    │  │   (DEFERRED)    │             │  │
│  │  │                 │  │                 │  │                 │             │  │
│  │  │  • BigQuery     │  │  • Azure SQL    │  │  • Delta Lake   │             │  │
│  │  │  • Vertex AI    │  │  • Azure ML     │  │  • Spark       │             │  │
│  │  │  • Cloud Fn     │  │  • AOAI (GPT-4) │  │  • MLflow      │             │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘             │  │
│  │                                                                                │  │
│  │  All DEFERRED pipelines use Cloudflare Queues for future event integration   │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
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
| **Frontend Hosting** | **Cloudflare Pages** | Free, global CDN, scale-to-zero |
| **Backend** | Python + FastAPI | Best ML ecosystem, unified stack |
| **Backend Hosting** | **Lambda + Cloudflare Workers** | Pay-per-invocation, scale-to-zero |
| **AI Agents** | **Google ADK** (primary), **CrewAI** (Bull/Bear/Judge) | ADK for orchestration, CrewAI for debate swarm |
| **ML Platform** | **SageMaker** (XGBoost, LSTM) | Primary ML training/inference (stopped when idle) |
| **Data Lake** | **S3** | Primary data storage |
| **Vector DB** | **ChromaDB** | Embeddings storage |
| **Knowledge Graph** | **Neo4j Aura** | Entity relationship traversal |
| **Cache** | **Cloudflare KV** | Free tier, global, scale-to-zero |
| **Database** | **RDS Aurora Serverless v2** | Min capacity = 0, scales on demand |
| **Compute** | **Lambda** (<100ms arbitrage) + Cloudflare Workers | Serverless, pay per request |
| **API Gateway** | **Cloudflare Workers** | $0.50/million requests, global |
| **IaC** | Terraform | Infrastructure as code |
| **CI/CD** | GitHub Actions | Industry standard |
| **Observability** | LangSmith + Grafana (on-demand) | Unified monitoring + agent tracing |
| **Contract Testing** | Pact | API contract validation |
| **Secrets** | HashiCorp Vault | Cloud-agnostic secrets |

**Scale-to-Zero Design:** All components designed to cost $0 when idle. Only pay for compute when actively running workloads.

---

## 3. Pipeline Specifications

### 3.1 AWS Pipeline (CORE - 100% Focus)

| Component | Technology | Scale-to-Zero |
|-----------|------------|---------------|
| Frontend | Next.js + Cloudflare Pages | ✅ Free when idle |
| Backend | Python + FastAPI (Lambda) | ✅ Pay per invocation |
| AI Agent | Google ADK (Lambda function) | ✅ Pay per invocation |
| Swarm Debate | CrewAI (Lambda) | ✅ Pay per invocation |
| ML Platform | SageMaker | ✅ Stopped when idle (saves $0.138/hr) |
| Arbitrage Compute | Lambda | ✅ Pay per ms |
| Data Lake | S3 | ✅ Always $0.023/hr (storage only) |
| Vector DB | ChromaDB (Lambda embedded) | ✅ Pay per invocation |
| Knowledge Graph | Neo4j Aura | ✅ ~$0.05/hr when idle |
| Database | RDS Aurora Serverless v2 | ✅ Min capacity = 0 |
| Cache | Cloudflare KV | ✅ Free tier: 100K reads/day |
| IaC | Terraform | N/A |

**Note:** GCP, Azure, and Databricks pipelines are **deferred** until post-MVP. Focus entirely on AWS for speed-to-market and operational simplicity.

## 4. Agent System Architecture

### 4.1 Hybrid Quant + Agent Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    TRADING SIGNAL PIPELINE                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                          XGBOOST SIGNAL GENERATION                          │  │
│  │  Technical signals from SageMaker (RSI, MACD, Bollinger, momentum, etc.)    │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                           │
│                                      ▼                                           │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                        CREWAI DEBATE SWARM                                │  │
│  │                                                                           │  │
│  │  ┌──────────────────┐           ┌──────────────────┐                     │  │
│  │  │   BULL AGENT    │           │   BEAR AGENT     │                     │  │
│  │  │   (CrewAI)      │           │   (CrewAI)       │                     │  │
│  │  │                 │           │                  │                     │  │
│  │  │ • News bullish  │           │ • Risk-off bias  │                     │  │
│  │  │ • SEC filings   │           │ • Bearish TA     │                     │  │
│  │  │ • Sentiment +   │           │ • Macro concerns │                     │  │
│  │  │                 │◀────────▶│                  │                     │  │
│  │  └────────┬─────────┘           └────────┬─────────┘                     │  │
│  │           │                              │                               │  │
│  │           └──────────────────────────────┘                               │  │
│  │                              │                                            │  │
│  │                              ▼                                            │  │
│  │                    ┌──────────────────┐                                   │  │
│  │                    │   JUDGE AGENT    │                                   │  │
│  │                    │   (CrewAI)       │                                   │  │
│  │                    │                  │                                   │  │
│  │                    │ • Conviction scoring                    │  │
│  │                    │ • Portfolio sizing                      │  │
│  │                    │ • Risk-adjusted position               │  │
│  │                    └────────┬─────────┘                                   │  │
│  └─────────────────────────────┼────────────────────────────────────────────┘  │
│                                │                                             │
│                                ▼                                             │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                    EXECUTION LAYER (<100ms)                               │  │
│  │                                                                           │  │
│  │              Pure programmatic - NO LLMs in hot path                        │  │
│  │              Python/Lambda for speed                                       │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Google ADK Meta-Orchestrator

The **Google ADK** serves as the top-level meta-orchestrator that:

1. Routes incoming queries to appropriate agents
2. Coordinates the CrewAI Bull/Bear/Judge debate swarm
3. Maintains conversation context across sessions
4. Integrates with LangSmith for observability
5. Manages RAG context from ChromaDB + Neo4j

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    GOOGLE ADK META-ORCHESTRATOR                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │  ADK Agent                                                               │  │
│  │  ├── Tool: Bedrock (Claude) OR Gemini (via ADK)                         │  │
│  │  ├── Tool: Lambda (arbitrage triggers)                                   │  │
│  │  ├── Tool: SageMaker (ML inference)                                       │  │
│  │  ├── RAG: ChromaDB (embeddings) + Neo4j (relationships)                  │  │
│  │  ├── Memory: ElastiCache Redis (session)                                   │  │
│  │  └── Sub-Agent: CrewAI Swarm (Bull/Bear/Judge)                            │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Lambda Functions (Latency-Critical Paths)

| Lambda | Latency Target | Purpose | LLM? |
|--------|---------------|---------|------|
| **Arbitrage Detector** | <100ms | Speed gap detection, cross-venue spread | NO |
| **Event Triggers** | <500ms | Price alert processing, signal propagation | NO |
| **Risk Parameters** | 5-10s | Dynamic risk limit adjustment | NO |
| **Market Regime** | 30-60s | Regime detection (trending, volatile, calm) | NO |

**Critical Rule:** Lambda functions in the hot path contain **NO LLM calls**. They are purely programmatic calculations.

### 4.4 Cross-Pipeline Resilience Architecture

Each pipeline operates **independently** but shares data via **async events**. If one pipeline goes down, others continue operating.

#### Core Principles

1. **Each pipeline has its own data store** - Can operate independently
2. **Async event-driven communication** - No synchronous blocking calls
3. **Essential data replicated** - Critical data mirrored across pipelines
4. **Feature flags with fallbacks** - Frontend routes to available pipeline
5. **Circuit breakers** - Failed pipelines don't block others

#### Cross-Pipeline Event Bus (Cloudflare Queues)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    RESILIENT CROSS-PIPELINE ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐   │
│  │                     SHARED EVENT BUS (Cloudflare Queues)                   │   │
│  │  All pipelines publish events here                                          │   │
│  │  If pipeline is down → events queue → retry when restored                   │   │
│  │  Survives any single cloud provider outage                                   │   │
│  └───────────────────────────────────────────────────────────────────────────┘   │
│                                      │                                           │
│  ┌─────────────────────────────────┼─────────────────────────────────────────┐   │
│  │                                 │                                          │   │
│  ▼                                 ▼                                          ▼   │
│┌──────────────┐            ┌──────────────┐            ┌──────────────────┐      │
││     AWS       │            │    AZURE     │            │      GCP         │      │
││              │            │              │            │                  │      │
││ OWNED DATA:   │            │ OWNED DATA:   │            │ OWNED DATA:      │      │
│• Polymarket    │            │• Social       │            │• On-chain        │      │
│• Real-time    │            │  signals      │            │  analytics       │      │
│• Core signals │            │• Competitions │            │• Whale tracking  │      │
│• ML models    │            │• Trading      │            │• DeFi data       │      │
││              │            │  journal      │            │                  │      │
││ FALLBACK FOR: │            │ FALLBACK FOR: │            │ FALLBACK FOR:    │      │
│• On-chain     │◀──────────▶│• Real-time    │◀──────────▶│• Social features │      │
│  (if GCP down)│  Async via │  (if AWS down)│  Async via │  (if Azure down)│      │
│• Social       │  EventBus  │• ML inference │  EventBus  │• ML inference    │      │
│  (if Azure down)         │  (if AWS down) │            │  (if AWS down)   │      │
│              │            │              │            │                  │      │
│┌──────────────┐            │              │            │                  │      │
││  DATABRICKS  │            │              │            │                  │      │
││              │            │              │            │                  │      │
││ OWNED DATA:   │            │              │            │                  │      │
││• Historical  │            │              │            │                  │      │
││  backtests   │            │              │            │                  │      │
││• Factor      │            │              │            │                  │      │
││  research    │            │              │            │                  │      │
││              │            │              │            │                  │      │
││ FALLBACK FOR: │            │              │            │                  │      │
││• On-chain     │◀──────────▶│              │            │                  │      │
│  (async, GCP  │            │              │            │                  │      │
│  still owns)  │            │              │            │                  │      │
│└──────────────┘            │              │            │                  │      │
└────────────────────────────┴──────────────┴────────────┴──────────────────┘      │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

#### Event Types

```python
# Cross-pipeline events published to Cloudflare Queues

EVENT_TYPES = {
    # AWS publishes (core signals)
    "signal.generated": {"publisher": "AWS", "consumers": ["Azure", "GCP", "Databricks"]},
    "price.update": {"publisher": "AWS", "consumers": ["Azure", "GCP"]},
    "arbitrage.opportunity": {"publisher": "AWS", "consumers": ["Azure"]},

    # Azure publishes (social features)
    "signal.copied": {"publisher": "Azure", "consumers": ["AWS", "GCP"]},
    "competition.update": {"publisher": "Azure", "consumers": ["Databricks"]},
    "trade.journal_entry": {"publisher": "Azure", "consumers": ["Databricks"]},

    # GCP publishes (on-chain)
    "whale.alert": {"publisher": "GCP", "consumers": ["AWS", "Azure"]},
    "onchain.signal": {"publisher": "GCP", "consumers": ["AWS", "Azure", "Databricks"]},
    "defi.liquidity_change": {"publisher": "GCP", "consumers": ["AWS"]},

    # Databricks publishes (historical)
    "backtest.complete": {"publisher": "Databricks", "consumers": ["Azure", "AWS"]},
    "factor.research_update": {"publisher": "Databricks", "consumers": ["AWS"]},
}
```

#### Pipeline Independence Matrix

| Feature | Primary Pipeline | Can Run Alone | Falls Back To | Works If Others Down |
|---------|------------------|---------------|---------------|---------------------|
| **Real-Time WebSocket** | AWS | ✅ Yes | Cached prices from S3 | Any |
| **3D Market Globe** | AWS | ✅ Yes | Static last-known state | None (display only) |
| **SEC Filing Tracker** | AWS | ✅ Yes | Polling-based (no WebSocket) | None |
| **Factor Analysis** | AWS | ✅ Yes | Pre-computed factor loads | None |
| **Explainable AI** | AWS | ✅ Yes | Cached SHAP values | None |
| **Rebalancing Engine** | AWS | ✅ Yes | Scheduled Lambda runs independently | None |
| **Social Trading** | Azure | ✅ Yes | Local Azure SQL only | None |
| **Competitions** | Azure | ✅ Yes | Local leaderboard only | None |
| **Trading Journal** | Azure | ✅ Yes | Local storage only | None |
| **Options Flow** | Azure | ✅ Yes | Azure Functions run independently | None |
| **On-Chain Analytics** | GCP | ✅ Yes | BigQuery data still accessible | AWS (read-only copy) |
| **DeFi Integration** | GCP | ✅ Yes | Cloud Functions independent | AWS (cached DeFi data) |
| **Whale Tracking** | GCP | ✅ Yes | BigQuery historical queries | None |
| **Edge Deployment** | GCP | ✅ Yes | Cloudflare Workers independent | AWS Lambda@Edge |
| **Backtesting** | Databricks | ✅ Yes | Delta Lake local | None |
| **Performance Attribution** | Databricks | ✅ Yes | Delta Lake + Spark | None |
| **Factor Research** | Databricks | ✅ Yes | Local notebooks | AWS SageMaker |

#### Circuit Breaker Pattern

```python
# Lambda circuit breaker for cross-pipeline calls

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN

    def call(self, func, *args, **kwargs):
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = "HALF_OPEN"
            else:
                raise Exception("Circuit OPEN - using fallback")

        try:
            result = func(*args, **kwargs)
            self.record_success()
            return result
        except Exception as e:
            self.record_failure()
            raise e

    def record_success(self):
        self.failures = 0
        self.state = "CLOSED"

    def record_failure(self):
        self.failures += 1
        self.last_failure_time = time.time()
        if self.failures >= self.failure_threshold:
            self.state = "OPEN"
```

#### Frontend Resilience Pattern

```typescript
// Next.js API client with fallback logic

class PipelineClient {
  private pipelines = {
    aws: 'https://api.aws.behemoth.ai',
    azure: 'https://api.azure.behemoth.ai',
    gcp: 'https://api.gcp.behemoth.ai',
    databricks: 'https://api.databricks.behemoth.ai'
  };

  private async callWithFallback<T>(
    primary: string,
    fallback: string,
    endpoint: string
  ): Promise<T> {
    try {
      const response = await fetch(`${this.pipelines[primary]}${endpoint}`);
      if (!response.ok) throw new Error(`${primary} failed`);
      return response.json();
    } catch (primaryError) {
      console.warn(`${primary} unavailable, using ${fallback}`);

      // Try fallback
      try {
        const fallbackResponse = await fetch(`${this.pipelines[fallback]}${endpoint}`);
        if (!fallbackResponse.ok) throw new Error(`${fallback} also failed`);
        return fallbackResponse.json();
      } catch (fallbackError) {
        // Return cached data if both fail
        return this.getCachedData(endpoint);
      }
    }
  }

  async getRealtimePrice(symbol: string) {
    return this.callWithFallback('aws', 'azure', `/prices/${symbol}`);
  }

  async getSocialSignals() {
    return this.callWithFallback('azure', 'aws', '/social/signals');
  }

  async getOnChainMetrics() {
    return this.callWithFallback('gcp', 'aws', '/onchain/metrics');
  }
}
```

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

## 5. Development Roadmap (AWS-Core Focus)

### 5.1 Phased Implementation

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    AWS-CORE DEVELOPMENT ROADMAP                              │
│                    (Single-Cloud Focus for Speed)                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  PHASE 1: FOUNDATION (Weeks 1-6)                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  1.1: Frontend - Unified Dashboard (Next.js + TypeScript)             │  │
│  │  1.2: Backend - FastAPI Core (Python)                                  │  │
│  │  1.3: Infrastructure - VPC, ECS, RDS (Terraform)                     │  │
│  │  1.4: Data Layer - S3, ChromaDB, Neo4j setup                           │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                        │
│  PHASE 2: ML PIPELINE (Weeks 7-10)                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  2.1: SageMaker - XGBoost training pipeline                             │  │
│  │  2.2: Feature engineering (technical indicators)                       │  │
│  │  2.3: SageMaker endpoints for inference                                │  │
│  │  2.4: Lambda arbitrage detector (<100ms)                               │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                        │
│  PHASE 3: AI AGENTS (Weeks 11-14)                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  3.1: Google ADK - Meta-orchestrator setup                              │  │
│  │  3.2: CrewAI Bull/Bear/Judge swarm implementation                      │  │
│  │  3.3: LangSmith observability integration                              │  │
│  │  3.4: Time-weighted RAG (ChromaDB + Neo4j)                              │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                        │
│  PHASE 4: TRADING & PAPER TRADING (Weeks 15-18)                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  4.1: Paper trading engine                                             │  │
│  │  4.2: Backtesting framework                                          │  │
│  │  4.3: Risk management (VaR, Monte Carlo)                               │  │
│  │  4.4: Integration with Polymarket APIs                                │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                        │
│  PHASE 5: PRODUCTION HARDENING (Weeks 19-20)                                   │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  5.1: Security hardening (WAF, Vault)                                  │  │
│  │  5.2: Performance testing                                              │  │
│  │  5.3: E2E testing (Playwright)                                         │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Note:** GCP, Azure, and Databricks expansions are **deferred post-MVP**. This focused approach minimizes latency and operational complexity.

### 6.2 Per-Section Testing Strategy

```makefile
# After each section, run:
# make test SECTION=<section-name>

# Example:
# make test SECTION=frontend      # Tests frontend
# make test SECTION=backend      # Tests backend
# make test SECTION=aws-infra    # Tests AWS infrastructure
# make test SECTION=contracts    # Runs contract tests
```

---

## 7. Cost Analysis (Scale-to-Zero Design)

### 7.1 Cost States

| State | What Runs | Cost/hr | Notes |
|-------|----------|---------|-------|
| **Idle** (logged out) | S3 storage only | $0.023 | Everything stopped |
| **Active** (working) | Lambda + Aurora + SageMaker (if ML needed) | $0.05-0.20 | Depends on workload |
| **ML Training** | SageMaker training job | $0.50-2.00 | Only during training |

### 7.2 Hourly Cost Breakdown (Active State)

| Component | Idle | Active (API) | Active (ML Inference) | Active (Full Stack) |
|-----------|------|--------------|----------------------|---------------------|
| **Cloudflare Pages** | $0 | $0 | $0 | $0 |
| **Cloudflare Workers** | $0 | $0.005 | $0.005 | $0.005 |
| **Lambda (API/Agent)** | $0 | $0.01 | $0.01 | $0.02 |
| **Aurora Serverless** | $0 | $0.02 | $0.02 | $0.06 |
| **SageMaker Endpoint** | $0 | $0 | $0.138 | $0.138 |
| **S3 Storage** | $0.023 | $0.023 | $0.023 | $0.023 |
| **Cloudflare KV** | $0 | $0 | $0 | $0 |
| **Neo4j Aura** | $0.05 | $0.05 | $0.05 | $0.05 |
| **Cloudflare Queues** | $0 | $0.001 | $0.001 | $0.001 |
| **LangSmith** | $0 | $0.042 | $0.042 | $0.042 |
| **Total/hr** | **$0.07** | **$0.15** | **$0.30** | **$0.40** |

### 7.3 Scale-to-Zero vs Always-On Comparison

| Scenario | Condition | Monthly Cost |
|----------|-----------|--------------|
| **Always-On (old design)** | 24/7 running | $389/month |
| **Scale-to-Zero (new)** | 8hrs/day × 22 days | **$26/month** |
| **Scale-to-Zero (new)** | 4hrs/day × 22 days | **$13/month** |
| **Scale-to-Zero (new)** | Idle (storage only) | **$0.69/month** |

### 7.4 Post-MVP: Adding Other Pipelines

| Pipeline Added | Extra Cost/hr | Notes |
|----------------|---------------|-------|
| **GCP** (BigQuery + Cloud Functions) | +$0.12 | On-demand, no always-on |
| **Azure** (AKS + Azure SQL) | +$0.10 | Spot instances |
| **Databricks** (interactive cluster) | +$0.40 | DBU + compute |

### 7.5 Cost Optimization Commands

```bash
# Start everything for a work session (2-3 min warm-up)
make start-dev

# Stop everything after session
make stop-dev

# Quick status check
make status

# Scale Aurora to 0 (manual)
aws rds modify-db-cluster --db-cluster-identifier fmip-db \
  --serverlessv2-scaling-configuration MinCapacity=0,MaxCapacity=16

# Stop SageMaker endpoint (saves $0.138/hr)
aws sagemaker delete-endpoint --endpoint-name inference-ep
```

### 7.6 Recommendation

**MVP Phase:** Use scale-to-zero AWS-Core only
- Idle cost: ~$0.69/month (just S3 storage)
- Active cost: ~$0.15-0.40/hr depending on ML usage
- 8hr workday × 22 days = ~$26/month

**Post-MVP:** Add GCP/Azure/Databricks only when revenue supports ~$200-400/month additional for each pipeline.

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

## 9. Shared Infrastructure Services

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

## 10. Next Steps

1. **Review and approve this PRD**
2. **Proceed to create Frontend PRD** (01-FRONTEND-PRD.md)
3. **Begin Frontend implementation** with Baby Steps 1.1-1.2
4. **Create API Gateway ADR** documenting Kong decision

---

**Document Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-16 | Saiyudh | Initial draft |
