# PRD - Financial Markets Intelligence Platform (FMIP)

**Version:** 2.0
**Date:** 2026-04-16
**Author:** Saiyudh Mannan
**Status:** Draft
**Related To:** Master PRD (00-MASTER-ARCHITECTURE-PRD.md)

---

## 0. Architecture Clarifications (v2.0)

### 0.1 IMPORTANT: MiroFish Explained

**What is MiroFish?**

MiroFish was originally conceptualized as a separate swarm intelligence microservice. After architectural review, **MiroFish functionality is implemented via the CrewAI Bull/Bear/Judge debate swarm** running within the AWS pipeline. This eliminates an external dependency and simplifies the architecture.

| Original Concept | Current Implementation |
|------------------|-----------------------|
| MiroFish external microservice | **CrewAI Bull/Bear/Judge swarm** (same functionality) |
| ghcr.io/666ghj/mirofish:latest | CrewAI agents in ECS Fargate |
| PostgreSQL + Redis dependencies | Shared ElastiCache + RDS Aurora |

**MiroFish == CrewAI Debate Swarm** in this implementation. The PRD retains "MiroFish" references for conceptual continuity, but actual implementation uses CrewAI.

### 0.2 Single Source of Truth for External Data

**Problem:** In multi-cloud setups, each cloud independently polling CoinGecko/Polymarket would hit rate limits immediately.

**Solution (AWS-Core):** All external API ingestion happens from **AWS only**. No other clouds hit external APIs directly.

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL DATA INGESTION (AWS-CORE)                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                   │
│  ┌───────────────────────────────────────────────────────────────────────────┐   │
│  │                     AWS INGESTION LAYER (Lambda + ECS)                      │   │
│  │                                                                           │   │
│  │    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │   │
│  │    │  Lambda      │  │  Lambda       │  │  Lambda       │                 │   │
│  │    │  (Polymarket │  │  (CoinGecko)  │  │  (Yahoo       │                 │   │
│  │    │   Gamma API) │  │              │  │   Finance)   │                 │   │
│  │    └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                 │   │
│  │           │                  │                  │                          │   │
│  │           └──────────────────┼──────────────────┘                          │   │
│  │                              ▼                                            │   │
│  │                    ┌──────────────┐                                        │   │
│  │                    │     S3      │  Raw data bucket                        │   │
│  │                    │  (Raw/)     │  - polymarket/raw/                      │   │
│  │                    └──────┬──────┘  - coingecko/raw/                        │   │
│  │                           │             - yahoo/raw/                        │   │
│  │                           ▼                                              │   │
│  │                    ┌──────────────┐                                        │   │
│  │                    │  Glue ETL   │  Transformed data                      │   │
│  │                    └──────┬──────┘  - polymarket/processed/               │   │
│  │                           │             - coingecko/processed/               │   │
│  │                           ▼                                              │   │
│  │                    ┌──────────────┐                                        │   │
│  │                    │  S3 (Gold/) │  Enriched, analysis-ready              │   │
│  │                    └──────────────┘                                        │   │
│  │                                                                           │   │
│  └───────────────────────────────────────────────────────────────────────────┘   │
│                                                                                   │
│  RATE LIMIT PROTECTION: Lambda poller runs at staggered intervals                 │
│  CoinGecko: 10-30 calls/minute max (free tier)                                   │
│  Polymarket Gamma: 60 calls/minute max                                              │
│                                                                                   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

**Key Points:**
- Only **AWS Lambda** polls external APIs (CoinGecko, Polymarket, Yahoo Finance, FRED, NewsAPI)
- Raw data written to **S3 Raw bucket** immediately
- **Glue ETL** transforms and writes to S3 Gold bucket
- **SageMaker, ECS, CrewAI** read from S3 - never call external APIs directly
- Staggered polling intervals to avoid rate limits

### 0.3 Unified Frontend Architecture

**Decision:** Single unified Next.js frontend, NOT multiple fragmented frontends.

| Original (Multi-Cloud) | Current (AWS-Core) |
|------------------------|-------------------|
| Next.js (AWS), Vue.js (GCP), Angular (Azure), Streamlit (Databricks) | **Single Next.js** dashboard |
| 4 separate codebases | 1 codebase |
| Fragmented UI/UX | Consistent UX |

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         UNIFIED FRONTEND (Next.js)                               │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                         ┌─────────────────────┐                                   │
│                         │   Next.js App       │                                   │
│                         │   (Single Repo)     │                                   │
│                         └─────────┬─────────┘                                   │
│                                   │                                               │
│         ┌─────────────────────────┼─────────────────────────┐                     │
│         │                         │                         │                     │
│         ▼                         ▼                         ▼                     │
│  ┌──────────────┐        ┌──────────────┐        ┌──────────────┐            │
│  │  /signals    │        │  /markets    │        │  /portfolio  │            │
│  │  Live signals│        │  Polymarket  │        │  Paper trade  │            │
│  └──────────────┘        └──────────────┘        └──────────────┘            │
│                                                                                  │
│  Frontend calls:                                                                 │
│  - /api/v1/signals       → ECS FastAPI (SageMaker ML inference)                  │
│  - /api/v1/markets      → ECS FastAPI (Polymarket data from S3)                 │
│  - /api/v1/paper        → ECS FastAPI (Paper trading engine)                    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 0.4 Cost Management: Scale-to-Zero

**Critical for solo/small projects - always-on infrastructure is expensive.**

| Component | Always-On Cost (Idle) | Scale-to-Zero Strategy |
|-----------|----------------------|----------------------|
| **ECS Fargate** | ~$0.02-0.05/hour | Fargate Spot, schedule scaling |
| **SageMaker Endpoints** | ~$0.10+/hour | Delete when not in use |
| **RDS Aurora** | ~$0.02-0.12/hour | Serverless v2 min capacity = 0 |
| **Lambda** | $0 (only pay per invocation) | N/A - already serverless |
| **ElastiCache** | ~$0.08/hour | Stop dev cluster, use local Redis |

**Scale-to-Zero Schedule (Dev/Non-Production):**
```bash
# Stop ECS services off-hours (dev only)
aws ecs update-service --cluster mlops-dev-cluster --desired-count 0

# Delete SageMaker endpoints when idle
aws sagemaker delete-endpoint --endpoint-name inference-ep

# Set RDS Aurora serverless min capacity to 0
aws rds modify-db-cluster --db-cluster-identifier mlops-db-cluster \
  --serverlessv2-scaling-configuration MinCapacity=0,MaxCapacity=16

# Start everything before work
aws ecs update-service --cluster mlops-dev-cluster --desired-count 1
```

---

## 1. Executive Summary

### 1.1 Project Overview

**Project Name:** Financial Markets Intelligence Platform (FMIP)

**What Are We Building?**
An AI-powered financial markets prediction platform that combines multi-cloud ML infrastructure with swarm intelligence, real-time sentiment analysis, and prediction market data to generate actionable trading signals across stocks, crypto, forex, commodities, and Polymarket prediction markets.

### 1.2 Core Capabilities

| Capability | Description |
|------------|-------------|
| **Algorithmic Trading** | Price direction prediction with backtesting |
| **Risk Management** | VaR, stress testing, portfolio optimization |
| **Time Series Forecasting** | Volatility, multi-asset prediction |
| **Sentiment Analysis** | News + social → trading signals |
| **Prediction Markets** | Polymarket data + swarm intelligence |
| **Paper Trading** | Train without financial risk |

### 1.3 Business Value

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BUSINESS VALUE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  VALUE PROPOSITION                           │    METRICS                    │
│  ───────────────────────────────────────────┼─────────────────────────────   │
│  • Multi-market prediction                   │  60%+ prediction accuracy     │
│  • Paper trading (zero risk training)        │  100% safe backtesting        │
│  • Swarm intelligence (MiroFish)            │  10x faster signal generation │
│  • Real-time sentiment from news/social     │  <5min news-to-signal         │
│  • Polymarket integration                   │  Prediction market edge        │
│  • Cost optimization via cloud arbitrage     │  30-40% infra cost savings    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Sources

### 2.1 Polymarket APIs

Polymarket has 3 APIs for different purposes:

| API | Base URL | Auth Required | Purpose |
|-----|----------|--------------|---------|
| **Gamma** | `https://gamma-api.polymarket.com` | No | Browse markets, events, tags |
| **Data** | `https://data-api.polymarket.com` | No | User activity, leaderboards |
| **CLOB** | `https://clob.polymarket.com` | Yes | Orderbook, pricing, trading |

#### Gamma API (Public - Market Discovery)

```python
import requests

BASE_URL = "https://gamma-api.polymarket.com"

# Get all active markets
def get_markets(limit: int = 100, archived: bool = False):
    params = {"limit": limit, "archived": archived}
    response = requests.get(f"{BASE_URL}/markets", params=params)
    return response.json()

# Get specific market by ID
def get_market(market_id: str):
    response = requests.get(f"{BASE_URL}/markets/{market_id}")
    return response.json()

# Get events
def get_events(limit: int = 100):
    response = requests.get(f"{BASE_URL}/events", params={"limit": limit})
    return response.json()

# Search markets
def search_markets(query: str):
    response = requests.get(f"{BASE_URL}/search", params={"q": query})
    return response.json()

# Get market tags
def get_tags():
    response = requests.get(f"{BASE_URL}/tags")
    return response.json()

# Get market series
def get_series():
    response = requests.get(f"{BASE_URL}/series")
    return response.json()

# Get market comments
def get_comments(market_id: str):
    response = requests.get(f"{BASE_URL}/comments", params={"market": market_id})
    return response.json()
```

#### Data API (Public - User Activity)

```python
DATA_BASE_URL = "https://data-api.polymarket.com"

# Get user positions
def get_positions(api_key: str = None):
    headers = {"Authorization": f"Bearer {api_key}"} if api_key else {}
    response = requests.get(f"{DATA_BASE_URL}/positions", headers=headers)
    return response.json()

# Get trade history
def get_trades(api_key: str = None, limit: int = 100):
    headers = {"Authorization": f"Bearer {api_key}"} if api_key else {}
    response = requests.get(f"{DATA_BASE_URL}/trades", params={"limit": limit}, headers=headers)
    return response.json()

# Get market holder data
def get_holders(market_id: str):
    response = requests.get(f"{DATA_BASE_URL}/holders/{market_id}")
    return response.json()

# Get trading leaderboard
def get_leaderboard():
    response = requests.get(f"{DATA_BASE_URL}/leaderboard")
    return response.json()

# Get open interest
def get_open_interest(market_id: str = None):
    url = f"{DATA_BASE_URL}/open-interest"
    params = {"marketId": market_id} if market_id else {}
    response = requests.get(url, params=params)
    return response.json()
```

#### CLOB API (Requires Authentication - Trading)

```python
CLOB_BASE_URL = "https://clob.polymarket.com"

# Get orderbook for a market
def get_orderbook(market_id: str):
    response = requests.get(f"{CLOB_BASE_URL}/book/{market_id}")
    return response.json()

# Get current pricing
def get_prices(market_id: str):
    response = requests.get(f"{CLOB_BASE_URL}/prices/{market_id}")
    return response.json()

# Get price history
def get_price_history(market_id: str, interval: str = "1d"):
    response = requests.get(f"{CLOB_BASE_URL}/history/{market_id}", params={"interval": interval})
    return response.json()

# Place order (requires API key)
def place_order(api_key: str, market_id: str, side: str, size: float, price: float):
    headers = {"Authorization": f"Bearer {api_key}"}
    payload = {
        "market": market_id,
        "side": side,  # "BUY" or "SELL"
        "size": size,
        "price": price
    }
    response = requests.post(f"{CLOB_BASE_URL}/orders", json=payload, headers=headers)
    return response.json()

# Cancel order
def cancel_order(api_key: str, order_id: str):
    headers = {"Authorization": f"Bearer {api_key}"}
    response = requests.delete(f"{CLOB_BASE_URL}/orders/{order_id}", headers=headers)
    return response.json()
```

### 2.2 Other Data Sources

| Source | Library/API | Data Provided | Cost |
|--------|-------------|---------------|------|
| **Yahoo Finance** | `yfinance` | Stocks, ETF, crypto, FX daily data | Free |
| **CoinGecko** | `pycoingecko` | Crypto prices, market cap, orderbooks | Free |
| **FRED** | `fredapi` | Economic indicators, GDP, inflation | Free |
| **NewsAPI** | `newsapi-python` | Financial news headlines | Free tier |
| **Finnhub** | `finnhub-python` | Market news, company fundamentals | Free tier |
| **Alpha Vantage** | `alpha_vantage` | Stocks, FX, crypto daily data | Free tier |
| **Polymarket** | REST API (above) | Prediction market data | Free |

```python
# Yahoo Finance - Stocks/Crypto/FX
import yfinance as yf

def get_stock_data(symbol: str, period: str = "1y"):
    ticker = yf.Ticker(symbol)
    return ticker.history(period=period)

def get_crypto_data(symbol: str, interval: str = "1d"):
    ticker = yf.Ticker(f"{symbol}-USD")  # e.g., BTC-USD
    return ticker.history(interval=interval)

# CoinGecko - Crypto
from pycoingecko import CoinGeckoAPI
cg = CoinGeckoAPI()

def get_crypto_price(coin_ids: list):
    return cg.get_price(ids=coin_ids, vs_currencies='usd')

def get_market_data(coin_id: str):
    return cg.get_market_chart_by_id(id=coin_id, vs_currency='usd', days=30)

# FRED - Economic Data
from fredapi import Fred
fred = Fred(api_key=os.getenv('FRED_API_KEY'))

def get_economic_indicator(series_id: str):
    return fred.get_series(series_id)  # e.g., 'GDP', 'UNRATE', 'CPI'

# NewsAPI - Financial News
from newsapi import NewsApiClient
newsapi = NewsApiClient(api_key=os.getenv('NEWS_API_KEY'))

def get_financial_news(query: str, from_date: str = None):
    return newsapi.get_everything(
        q=query,
        from_param=from_date,
        language='en',
        sort_by='publishedAt'
    )
```

---

## 3. ML Use Cases

### 3.1 Algorithmic Trading (Price Direction Prediction)

**Problem:** Predict whether an asset will go up or down in the next time period.

**Target Accuracy:** > 60%

**Models:**
- XGBoost (primary)
- LightGBM (ensemble)
- Random Forest (baseline)

**Features:**
```python
FEATURES = {
    "price_based": [
        "returns_1d", "returns_5d", "returns_20d",
        "volatility_20d", "volume_change",
        "high_low_ratio", "close_to_high_ratio"
    ],
    "technical": [
        "rsi_14", "macd", "macd_signal",
        "bb_upper", "bb_lower", "bb_position",
        "stoch_k", "stoch_d", "adx"
    ],
    "polymarket": [
        "implied_probability", "volume", "open_interest",
        "yes_bid", "no_ask", "spread"
    ],
    "cross_asset": [
        "spx_correlation", "vix", "dxy_correlation",
        "crypto_correlation", "bond_yield_change"
    ]
}

# Training pipeline
from xgboost import XGBClassifier
from sklearn.model_selection import TimeSeriesSplit

def create_features(df: pd.DataFrame) -> pd.DataFrame:
    """Create feature matrix from raw price data"""
    features = pd.DataFrame()

    # Price returns
    features['returns_1d'] = df['close'].pct_change(1)
    features['returns_5d'] = df['close'].pct_change(5)
    features['returns_20d'] = df['close'].pct_change(20)

    # Volatility
    features['volatility_20d'] = df['returns_1d'].rolling(20).std()

    # Technical indicators
    features['rsi_14'] = compute_rsi(df['close'], 14)
    features['macd'] = compute_macd(df['close'])
    features['bb_upper'] = compute_bollinger_upper(df['close'])
    features['bb_lower'] = compute_bollinger_lower(df['close'])

    # Target: 1 if price goes up next period, 0 otherwise
    features['target'] = (df['close'].shift(-1) > df['close']).astype(int)

    return features.dropna()

# Time series cross validation
tscv = TimeSeriesSplit(n_splits=5)
model = XGBClassifier(n_estimators=100, max_depth=6, learning_rate=0.1)
model.fit(X_train, y_train, eval_set=[(X_test, y_test)], verbose=False)
```

### 3.2 Risk Management (VaR, Stress Testing)

**Problem:** Quantify portfolio risk and simulate worst-case scenarios.

**Metrics:**
- Value at Risk (VaR) - 95%, 99%
- Conditional VaR (CVaR / Expected Shortfall)
- Sharpe Ratio
- Maximum Drawdown

```python
import numpy as np
from scipy import stats

def calculate_var(returns: np.ndarray, confidence: float = 0.95) -> float:
    """Calculate Value at Risk using historical simulation"""
    return np.percentile(returns, (1 - confidence) * 100)

def calculate_cvar(returns: np.ndarray, confidence: float = 0.95) -> float:
    """Calculate Conditional VaR (Expected Shortfall)"""
    var = calculate_var(returns, confidence)
    return np.mean(returns[returns <= var])

def monte_carlo_portfolio(weights: np.ndarray, returns: np.ndarray,
                          n_simulations: int = 10000) -> dict:
    """Monte Carlo simulation for portfolio risk"""
    mean_returns = returns.mean()
    cov_matrix = returns.cov()

    portfolio_returns = []
    for _ in range(n_simulations):
        z = np.random.standard_normal(len(weights))
        portfolio_return = np.dot(weights, mean_returns + np.dot(cov_matrix, z))
        portfolio_returns.append(portfolio_return)

    portfolio_returns = np.array(portfolio_returns)

    return {
        'var_95': calculate_var(portfolio_returns, 0.95),
        'var_99': calculate_var(portfolio_returns, 0.99),
        'cvar_95': calculate_cvar(portfolio_returns, 0.95),
        'expected_return': np.mean(portfolio_returns),
        'volatility': np.std(portfolio_returns),
        'sharpe_ratio': np.mean(portfolio_returns) / np.std(portfolio_returns) * np.sqrt(252)
    }

def stress_test(portfolio_weights: np.ndarray, historical_returns: pd.DataFrame,
                scenarios: list) -> dict:
    """Run stress tests on historical scenarios"""
    results = {}

    for scenario_name, scenario_returns in scenarios.items():
        portfolio_return = np.dot(portfolio_weights, scenario_returns)
        results[scenario_name] = {
            'return': portfolio_return,
            'var_95': calculate_var(portfolio_return, 0.95),
            'max_loss': portfolio_return.min()
        }

    return results

# Common stress scenarios
SCENARIOS = {
    '2008_crisis': historical_returns['2008-01':'2008-12'],
    '2020_covid': historical_returns['2020-02':'2020-03'],
    '2022_inflation': historical_returns['2022-01':'2022-12'],
}
```

### 3.3 Time Series Forecasting

**Problem:** Forecast future values of assets or volatility.

**Models:**
- LSTM (deep learning)
- Prophet (Facebook/Meta)
- ARIMA (statistical)

**Use Cases:**
- Next-day price prediction
- Volatility forecasting (for options)
- Multi-asset correlation forecasting

```python
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from prophet import Prophet

def build_lstm_model(sequence_length: int, n_features: int) -> Sequential:
    """Build LSTM for time series forecasting"""
    model = Sequential([
        LSTM(64, return_sequences=True, input_shape=(sequence_length, n_features)),
        Dropout(0.2),
        LSTM(32),
        Dense(1)
    ])
    model.compile(optimizer='adam', loss='mse')
    return model

def prepare_lstm_data(data: np.ndarray, sequence_length: int = 60) -> tuple:
    """Prepare data for LSTM: create sequences"""
    X, y = [], []
    for i in range(sequence_length, len(data)):
        X.append(data[i-sequence_length:i])
        y.append(data[i])
    return np.array(X), np.array(y)

def forecast_with_prophet(df: pd.DataFrame, periods: int = 30) -> dict:
    """Prophet for decomposable time series"""
    model = Prophet(
        daily_seasonality=True,
        yearly_seasonality=True,
        weekly_seasonality=True,
        changepoint_prior_scale=0.05
    )
    model.fit(df[['ds', 'y']])

    future = model.make_future_dataframe(periods=periods)
    forecast = model.predict(future)

    return {
        'forecast': forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']],
        'trend': forecast['trend'],
        'yearly': forecast['yearly'],
        'weekly': forecast['weekly']
    }

def forecast_volatility(returns: np.ndarray, horizon: int = 30) -> dict:
    """Forecast volatility using GARCH or simple rolling"""
    # Simple: rolling standard deviation with forecast
    rolling_std = pd.Series(returns).rolling(20).std()

    # Forecast: use last known volatility as baseline
    current_vol = rolling_std.iloc[-1]

    return {
        'volatility_forecast': current_vol,
        'volatility_ci_upper': current_vol * 1.5,  # Simple CI
        'volatility_ci_lower': current_vol * 0.5
    }
```

### 3.4 Sentiment Analysis (News → Trading Signals)

**Problem:** Convert news/social sentiment into actionable trading signals.

**Models:**
- FinBERT (financial sentiment)
- VADER (social media)
- RoBERTa (general NLP)

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import torch

# Load FinBERT
tokenizer = AutoTokenizer.from_pretrained("ProsusAI/finbert")
model = AutoModelForSequenceClassification.from_pretrained("ProsusAI/finbert")

def analyze_sentiment(text: str) -> dict:
    """Get sentiment score from financial text"""
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
    outputs = model(**inputs)
    probs = torch.softmax(outputs.logits, dim=1)

    return {
        'positive': probs[0][0].item(),
        'negative': probs[0][1].item(),
        'neutral': probs[0][2].item(),
        'signal': 'buy' if probs[0][0] > 0.6 else 'sell' if probs[0][1] > 0.6 else 'hold',
        'confidence': max(probs[0].tolist())
    }

def aggregate_news_sentiment(symbol: str, days: int = 7) -> dict:
    """Aggregate sentiment from recent news"""
    from newsapi import NewsApiClient
    newsapi = NewsApiClient(api_key=os.getenv('NEWS_API_KEY'))

    news = newsapi.get_everything(
        q=symbol,
        from_param=f'{days}d ago',
        language='en',
        sort_by='publishedAt'
    )

    sentiments = []
    for article in news['articles']:
        if article.get('content'):
            try:
                sent = analyze_sentiment(article['content'][:512])
                sentiments.append(sent)
            except:
                continue

    if not sentiments:
        return {'signal': 'hold', 'confidence': 0}

    avg_positive = np.mean([s['positive'] for s in sentiments])
    avg_negative = np.mean([s['negative'] for s in sentiments])
    avg_confidence = np.mean([s['confidence'] for s in sentiments])

    return {
        'avg_sentiment': 'bullish' if avg_positive > avg_negative else 'bearish',
        'positive': avg_positive,
        'negative': avg_negative,
        'confidence': avg_confidence,
        'signal': 'buy' if avg_positive > 0.4 else 'sell' if avg_negative > 0.4 else 'hold',
        'articles_analyzed': len(sentiments)
    }

def get_polymarket_sentiment(market_id: str) -> dict:
    """Get sentiment from Polymarket market data"""
    import requests

    market = requests.get(f"https://gamma-api.polymarket.com/markets/{market_id}").json()

    return {
        'question': market.get('question'),
        'prob_yes': float(market.get('outcomePrices', ['0.5'])[0] if 'YES' in market.get('outcomePrices', ['0.5']).__str__() else 0.5),
        'prob_no': 1 - float(market.get('outcomePrices', ['0.5'])[0] if 'YES' in market.get('outcomePrices', ['0.5']).__str__() else 0.5),
        'volume': market.get('volume'),
        'liquidity': market.get('liquidity'),
        'signal': 'buy' if float(market.get('outcomePrices', ['0.5'])[0]) > 0.6 else 'sell' if float(market.get('outcomePrices', ['0.5'])[0]) < 0.4 else 'hold'
    }
```

---

## 4. MiroFish (CrewAI Debate Swarm) Integration

### 4.1 What is MiroFish?

**MiroFish is now implemented via CrewAI Bull/Bear/Judge debate swarm** - no external microservice required.

The original MiroFish concept described a swarm intelligence prediction engine. In this AWS-core implementation, we achieve the same outcome using CrewAI agents running in ECS Fargate. This simplifies the architecture by eliminating external service dependencies.

### 4.2 Implementation Architecture

```python
# CrewAI-based MiroFish Equivalent (runs in ECS Fargate)

from crewai import Agent, Task, Crew

bull_agent = Agent(
    role="Bullish Analyst",
    goal="Identify bullish signals and upward momentum",
    backstory="""You are a bullish financial analyst who specializes in
    identifying upward market movements. You analyze news sentiment,
    SEC filings for positive developments, and technical breakout patterns.""",
    tools=[polymarket_tool, news_tool, sec_filings_tool],
    verbose=True
)

bear_agent = Agent(
    role="Bearish Analyst",
    goal="Identify bearish signals and downside risks",
    backstory="""You are a risk-averse analyst who warns about market
    downturns. You look for red flags in filings, negative sentiment,
    macro headwinds, and technical breakdown signals.""",
    tools=[polymarket_tool, news_tool, sec_filings_tool],
    verbose=True
)

judge_agent = Agent(
    role="Portfolio Judge",
    goal="Make final position sizing decisions based on debate",
    backstory="""You are the final arbiter for portfolio decisions.
    You weigh the bull and bear arguments, score conviction levels,
    and determine optimal position sizing with risk-adjusted returns.""",
    tools=[risk_calculator, portfolio_tool],
    verbose=True
)

# The "debate" - agents work sequentially then the judge decides
debate_crew = Crew(
    agents=[bull_agent, bear_agent],
    tasks=[bull_task, bear_task],
    crew="debate"
)

result = debate_crew.kickoff()
```

### 4.3 Why CrewAI Over MiroFish Microservice?

| Aspect | MiroFish External | CrewAI Debate Swarm |
|--------|-------------------|---------------------|
| **Infrastructure** | Separate PostgreSQL + Redis + Docker | Shared ElastiCache + RDS Aurora |
| **Deployment** | ghcr.io/666ghj/mirofish:latest | ECS Fargate (same as backend) |
| **Cost** | $50-100/month (separate infra) | $0 extra (uses existing ECS) |
| **Integration** | HTTP API with retries | Direct Python imports |
| **Latency** | +50-100ms network call | In-process |
| **Maintenance** | External repo, separate releases | Single codebase |

**Conclusion:** CrewAI provides equivalent swarm intelligence functionality without the operational overhead of a separate microservice.
    """Extract consensus from MiroFish agents"""
    return {
        "bullish_agents": prediction.get("bullish_count", 0),
        "bearish_agents": prediction.get("bearish_count", 0),
        "consensus_probability": prediction.get("probability", 0.5),
        "confidence": prediction.get("confidence", 0),
        "reasoning_summary": prediction.get("summary", ""),
        "key_factors": prediction.get("factors", [])
    }

# Use in trading signals
def generate_swarm_signal(market_id: str, question: str) -> dict:
    """Generate trading signal using MiroFish swarm intelligence"""

    # Gather market context
    price_data = get_stock_data(market_id, period="3mo")
    news_sentiment = aggregate_news_sentiment(market_id.split('-')[0], days=7)
    polymarket_data = get_polymarket_sentiment(market_id)

    context = {
        "price_data": price_data.tail(30).to_dict(),
        "sentiment": news_sentiment,
        "polymarket": polymarket_data,
        "technical_indicators": compute_technical_indicators(price_data)
    }

    # Get MiroFish prediction
    prediction = get_mirofish_prediction(question, context)
    consensus = get_agent_consensus(prediction)

    # Combine with model predictions
    ml_signal = get_ml_prediction_signal(market_id)

    return {
        "swarm": consensus,
        "ml": ml_signal,
        "combined_signal": combine_signals([consensus, ml_signal]),
        "confidence": max(consensus['confidence'], ml_signal['confidence']),
        "rationale": f"Swarm: {consensus['reasoning_summary'][:100]}..."
    }
```

### 4.3 CrewAI Deployment (ECS Fargate)

Since MiroFish is now implemented via CrewAI, deployment is alongside the existing backend in ECS Fargate:

```python
# ECS Task Definition for CrewAI Bull/Bear/Judge Swarm

crewai_task_definition = {
    "family": "crewai-debate-swarm",
    "network_mode": "awsvpc",
    "requires_compatibilities": ["FARGATE"],
    "cpu": "2048",
    "memory": "4096",
    "execution_role_arn": ecs_execution_role.arn,
    "task_role_arn": ecs_task_role.arn,
    "container_definitions": [{
        "name": "crewai-agent",
        "image": f"{ecr_repo}/crewai-debate-swarm:latest",
        "portMappings": [{"container_port": 8082}],
        "environment": [
            {"name": "LANGCHAIN_TRACING", "value": "true"},
            {"name": "LANGCHAIN_ENDPOINT", "value": "https://api.smith.langchain.com"},
            {"name": "ADK_MODEL", "value": "gemini-2.0-flash"},
        ],
        "secrets": [
            {"name": "GOOGLE_API_KEY", "valueFrom": f"{secret_arn}:api_key::"}
        ],
        "log_configuration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/crewai",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "crewai"
            }
        }
    }]
}
```

**Key Benefits:**
- CrewAI runs in same ECS cluster as FastAPI backend
- Uses shared RDS Aurora and ElastiCache (no separate PostgreSQL/Redis needed)
- Scales automatically with Fargate auto-scaling
- No external Docker image dependency

---

## 5. Vector Database & Knowledge Graph

### 5.1 Purpose

Store and query:
- Historical market data embeddings
- News article embeddings
- Trading signal history
- Model prediction history
- Knowledge graph for cross-market relationships

### 5.2 Technologies

| Technology | Use Case | Deployment |
|------------|----------|------------|
| **ChromaDB** | Local vector storage | Self-hosted |
| **Pinecone** | Cloud vector DB, production | Cloud |
| **Neo4j** | Knowledge graph | Self-hosted or Aura |

### 5.3 Implementation

```python
# ChromaDB for vector storage
import chromadb
from chromadb.config import Settings

client = chromadb.Client(Settings(
    persist_directory="./vector_db",
    anonymized_telemetry=False
))

# Create collections
def setup_collections():
    collections = {
        "news_embeddings": client.create_collection("news_embeddings"),
        "market_embeddings": client.create_collection("market_embeddings"),
        "signal_history": client.create_collection("signal_history"),
        "polymarket_embeddings": client.create_collection("polymarket_embeddings")
    }
    return collections

# Add news to vector store
def store_news_embedding(news_id: str, text: str, embedding: list, metadata: dict):
    collection = client.get_collection("news_embeddings")
    collection.add(
        ids=[news_id],
        documents=[text],
        embeddings=[embedding],
        metadatas=[metadata]
    )

# Search similar news
def search_similar_news(query_embedding: list, n_results: int = 5):
    collection = client.get_collection("news_embeddings")
    return collection.query(
        query_embeddings=[query_embedding],
        n_results=n_results
    )

# Neo4j knowledge graph
from neo4j import GraphDatabase

class MarketKnowledgeGraph:
    def __init__(self, uri: str, user: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def add_market_relationship(self, from_id: str, to_id: str, relationship: str):
        with self.driver.session() as session:
            session.run(f"""
                MATCH (a:Market {{id: $from_id}})
                MATCH (b:Market {{id: $to_id}})
                MERGE (a)-[r:{relationship}]->(b)
            """, from_id=from_id, to_id=to_id)

    def query_correlated_markets(self, market_id: str):
        with self.driver.session() as session:
            result = session.run("""
                MATCH (m:Market {id: $market_id})-[:CORRELATED]->(related)
                RETURN related.id, related.name, related.correlation_strength
            """, market_id=market_id)
            return [dict(record) for record in result]
```

---

## 6. Paper Trading & Backtesting

### 6.1 Paper Trading Engine

```python
class PaperTradingEngine:
    def __init__(self, initial_capital: float = 100000):
        self.capital = initial_capital
        self.initial_capital = initial_capital
        self.positions = {}
        self.trades = []

    def buy(self, symbol: str, quantity: int, price: float):
        """Execute a buy order (paper)"""
        cost = quantity * price
        if cost > self.capital:
            return {"success": False, "reason": "Insufficient capital"}

        self.capital -= cost
        if symbol not in self.positions:
            self.positions[symbol] = {"quantity": 0, "avg_cost": 0}

        pos = self.positions[symbol]
        total_cost = pos["quantity"] * pos["avg_cost"] + cost
        pos["quantity"] += quantity
        pos["avg_cost"] = total_cost / pos["quantity"]

        self.trades.append({
            "timestamp": pd.Timestamp.now(),
            "action": "BUY",
            "symbol": symbol,
            "quantity": quantity,
            "price": price
        })

        return {"success": True, "capital_remaining": self.capital}

    def sell(self, symbol: str, quantity: int, price: float):
        """Execute a sell order (paper)"""
        if symbol not in self.positions:
            return {"success": False, "reason": "No position to sell"}

        pos = self.positions[symbol]
        if pos["quantity"] < quantity:
            return {"success": False, "reason": "Insufficient shares"}

        proceeds = quantity * price
        self.capital += proceeds
        pos["quantity"] -= quantity

        if pos["quantity"] == 0:
            del self.positions[symbol]

        self.trades.append({
            "timestamp": pd.Timestamp.now(),
            "action": "SELL",
            "symbol": symbol,
            "quantity": quantity,
            "price": price
        })

        return {"success": True, "capital_remaining": self.capital}

    def get_portfolio_value(self, current_prices: dict) -> float:
        """Calculate total portfolio value"""
        positions_value = sum(
            self.positions[s].get("quantity", 0) * current_prices.get(s, 0)
            for s in self.positions
        )
        return self.capital + positions_value

    def get_performance(self) -> dict:
        """Calculate performance metrics"""
        total_value = self.get_portfolio_value({})  # Use last prices
        pnl = total_value - self.initial_capital
        pnl_pct = (pnl / self.initial_capital) * 100

        winning_trades = [t for t in self.trades if t["action"] == "SELL" and
                          self._get_trade_pnl(t) > 0]
        losing_trades = [t for t in self.trades if t["action"] == "SELL" and
                        self._get_trade_pnl(t) <= 0]

        return {
            "total_value": total_value,
            "pnl": pnl,
            "pnl_pct": pnl_pct,
            "num_trades": len(self.trades),
            "winning_trades": len(winning_trades),
            "losing_trades": len(losing_trades),
            "win_rate": len(winning_trades) / len(self.trades) if self.trades else 0
        }
```

### 6.2 Backtesting Engine

```python
class BacktestEngine:
    def __init__(self, initial_capital: float = 100000, commission: float = 0.001):
        self.capital = initial_capital
        self.commission = commission
        self.initial_capital = initial_capital
        self.positions = {}
        self.equity_curve = []

    def run(self, signals: pd.DataFrame, prices: pd.DataFrame) -> dict:
        """
        Run backtest given signals and price data.

        signals: DataFrame with 'timestamp', 'signal' (1=buy, -1=sell, 0=hold)
        prices: DataFrame with 'timestamp', 'close'
        """
        for idx, row in signals.iterrows():
            if idx not in prices.index:
                continue

            ts = idx
            price = prices.loc[idx, 'close']
            signal = row['signal']

            if signal == 1 and self.capital >= price:
                # Buy
                shares = int(self.capital / price)
                if shares > 0:
                    cost = shares * price * (1 + self.commission)
                    self.capital -= cost
                    self.positions[ts] = {'shares': shares, 'entry': price, 'exit': None}

            elif signal == -1 and ts in self.positions:
                # Sell
                shares = self.positions[ts]['shares']
                proceeds = shares * price * (1 - self.commission)
                self.capital += proceeds
                self.positions[ts]['exit'] = price
                self.positions[ts]['pnl'] = proceeds - (shares * self.positions[ts]['entry'] * (1 + self.commission))
                del self.positions[ts]

            # Record equity
            positions_value = sum(
                p['shares'] * price for p in self.positions.values()
            )
            self.equity_curve.append(self.capital + positions_value)

        return self.calculate_metrics()

    def calculate_metrics(self) -> dict:
        """Calculate performance metrics"""
        equity = pd.Series(self.equity_curve)
        returns = equity.pct_change().dropna()

        total_return = (equity.iloc[-1] / self.initial_capital - 1) * 100

        # Sharpe ratio
        if returns.std() > 0:
            sharpe = returns.mean() / returns.std() * np.sqrt(252)
        else:
            sharpe = 0

        # Max drawdown
        cummax = equity.cummax()
        drawdown = (equity - cummax) / cummax
        max_drawdown = drawdown.min() * 100

        # Win rate
        closed_positions = [p for p in self.positions.values() if p.get('pnl') is not None]
        winning = len([p for p in closed_positions if p['pnl'] > 0])
        win_rate = winning / len(closed_positions) if closed_positions else 0

        return {
            'total_return': total_return,
            'sharpe_ratio': sharpe,
            'max_drawdown': max_drawdown,
            'win_rate': win_rate,
            'num_trades': len(closed_positions),
            'equity_curve': equity.tolist()
        }
```

---

## 7. MiniMax Agent Integration

Use MiniMax API for enhanced reasoning:

```python
from openai import OpenAI

MINIMAX_CLIENT = OpenAI(
    api_key=os.getenv("MINIMAX_API_KEY"),
    base_url="https://api.minimax.chat/v1"
)

def query_minimax_agent(prompt: str, system: str = "You are a financial analyst specializing in market prediction.") -> str:
    """Query MiniMax for enhanced reasoning"""
    response = MINIMAX_CLIENT.chat.completions.create(
        model="MiniMax-Text-01",
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7
    )
    return response.choices[0].message.content

# Use cases
def explain_signal(signal: dict) -> str:
    """Explain trading signal in natural language"""
    return query_minimax_agent(
        f"Explain this trading signal in simple terms: {signal}",
        system="You are a friendly financial advisor explaining market signals."
    )

def analyze_market_sentiment(symbol: str, news: list) -> str:
    """Analyze market sentiment and provide summary"""
    news_text = "\n".join([f"- {n['title']}: {n['description']}" for n in news[:5]])
    return query_minimax_agent(
        f"Analyze sentiment for {symbol} based on these headlines:\n{news_text}",
        system="You are a professional financial analyst."
    )

def generate_trading_rationale(signal: dict, context: dict) -> str:
    """Generate natural language rationale for a trade"""
    return query_minimax_agent(
        f"Generate a trading rationale for:\nSignal: {signal}\nContext: {context}",
        system="You are a quantitative analyst explaining trading decisions."
    )
```

---

## 8. Frontend Dashboard

### 8.1 Unified Dashboard Features

| Feature | Description |
|---------|-------------|
| **Signals Monitor** | Real-time trading signals from all models |
| **Market Browser** | Browse Polymarket, stocks, crypto |
| **Portfolio Tracker** | Paper trading portfolio with P&L |
| **Risk Dashboard** | VaR, exposure, drawdown |
| **Sentiment Analysis** | News + social sentiment gauges |
| **Backtesting** | Strategy performance visualization |

### 8.2 Page Structure

```
/                       → Landing + Quick stats
/signals               → Live trading signals table
/markets               → Market browser (Polymarket, stocks, crypto)
/portfolio             → Paper trading portfolio
/risk                  → Risk management dashboard
/backtest              → Backtesting results
/sentiment             → News sentiment analysis
/polymarket            → Polymarket prediction markets
/settings              → API keys, preferences
```

---

## 9. Development Roadmap

```
PHASE 1: Foundation (Weeks 1-4)
├── Setup project structure
├── Connect Polymarket APIs (Gamma, Data, CLOB)
├── Connect Yahoo Finance, CoinGecko
├── Setup ChromaDB + Neo4j
└── Build basic dashboard

PHASE 2: ML Models (Weeks 5-8)
├── Algorithmic Trading (XGBoost)
├── Risk Management (Monte Carlo, VaR)
├── Time Series Forecasting (LSTM, Prophet)
└── Sentiment Analysis (FinBERT)

PHASE 3: Advanced Features (Weeks 9-12)
├── MiroFish integration
├── Paper trading engine
├── Backtesting framework
└── MiniMax agent integration

PHASE 4: Cloud Deployment (Weeks 13-16)
├── AWS SageMaker deployment
├── GCP Vertex AI deployment
└── Azure ML deployment
```

---

## 10. API Endpoints

### Market Data
```
GET  /api/v1/markets/polymarket       → List Polymarket markets
GET  /api/v1/markets/{id}             → Get market details
GET  /api/v1/markets/search?q={query} → Search markets
GET  /api/v1/prices/{symbol}          → Get current price
GET  /api/v1/prices/history/{symbol}  → Get price history
```

### Signals
```
GET  /api/v1/signals                  → Get all active signals
GET  /api/v1/signals/{model}          → Get signals from specific model
POST /api/v1/signals/generate         → Trigger signal generation
GET  /api/v1/signals/history           → Get signal history
```

### Trading
```
GET  /api/v1/paper/portfolio          → Get paper trading portfolio
POST /api/v1/paper/buy               → Execute paper buy
POST /api/v1/paper/sell               → Execute paper sell
GET  /api/v1/paper/performance        → Get performance metrics
```

### ML
```
POST /api/v1/ml/train                 → Train a model
GET  /api/v1/ml/models                → List trained models
POST /api/v1/ml/predict               → Run prediction
GET  /api/v1/ml/backtest             → Run backtest
```

---

## 11. Success Metrics

| Metric | Target |
|--------|--------|
| Prediction Accuracy | > 60% for directional trades |
| Backtesting Sharpe Ratio | > 1.5 |
| Max Drawdown | < 20% |
| News-to-Signal Latency | < 5 min |
| Paper Trading P&L | > 0% |

---

## 12. Arbitrage & Market Microstructure

### 12.1 The Intelligence Arbitrage Framework

Modern markets have inefficiencies that AI can exploit. The economic gap has shifted from **labor arbitrage** (offshoring) to **intelligence arbitrage** (AI + talent + speed).

| Gap Type | Description | Exploitation | FMIP Implementation |
|----------|-------------|--------------|---------------------|
| **Speed Gap** | One system updates slower than reality | Latency arbitrage | Real-time data pipelines with <100ms latency |
| **Reasoning Gap** | Public info but AI interprets faster | Earnings/regulatory parsing | FinBERT + MiniMax agent analysis |
| **Fragmentation Gap** | Data siloed across venues | Cross-venue synthesis | Polymarket + Yahoo + CoinGecko unified |
| **Discipline Gap** | Humans suffer fatigue, emotion | Automated execution | Paper trading → bot execution pipeline |

### 12.2 Polymarket-Specific Exploits

**The $313 → $414K Case (Late 2025):**
A bot exploited the fact that short-duration crypto contracts on Polymarket updated prices slower than spot exchanges. Key success factors:
- Small initial capital ($313)
- Identified predictable price update lag
- Bot automation for speed advantage
- Single month, 1322x return

**Detection Patterns:**

```python
class ArbitrageDetector:
    """Detect arbitrage opportunities across venues"""

    def __init__(self):
        self.price_history = defaultdict(list)

    def detect_speed_gap(self, polymarket_price: float, spot_price: float,
                         threshold: float = 0.02) -> dict:
        """
        Detect if Polymarket lags behind spot market.
        threshold: 2% price difference triggers alert
        """
        gap = abs(polymarket_price - spot_price) / spot_price

        if gap > threshold:
            direction = "OVERPRICED" if polymarket_price > spot_price else "UNDERPRICED"
            return {
                "opportunity": "speed_gap",
                "gap_pct": gap * 100,
                "direction": direction,
                "action": "SELL" if direction == "OVERPRICED" else "BUY",
                "expected_edge": gap * 100
            }
        return {"opportunity": None}

    def detect_momentum_ divergence(self, asset: str, spot_prices: list,
                                    polymarket_prices: list) -> dict:
        """
        Detect when Polymarket probability diverges from spot momentum.
        """
        if len(spot_prices) < 5 or len(polymarket_prices) < 5:
            return {"opportunity": None}

        spot_momentum = (spot_prices[-1] - spot_prices[0]) / spot_prices[0]
        pm_momentum = (polymarket_prices[-1] - polymarket_prices[0]) / polymarket_prices[0]

        divergence = abs(spot_momentum - pm_momentum)

        if divergence > 0.1:  # 10% divergence threshold
            return {
                "opportunity": "momentum_divergence",
                "spot_momentum": spot_momentum * 100,
                "pm_momentum": pm_momentum * 100,
                "divergence": divergence * 100,
                "action": "BUY" if spot_momentum > pm_momentum else "SELL",
                "rationale": "Polymarket underreacting to spot momentum"
            }
        return {"opportunity": None}

    def scan_cross_venue_arbitrage(self, venues: dict) -> list:
        """
        Scan multiple venues for cross-market arbitrage.
        venues: {venue_name: price}
        """
        prices = {v: p for v, p in venues.items() if p > 0}
        if len(prices) < 2:
            return []

        max_price = max(prices.values())
        min_price = min(prices.values())
        max_venue = max(prices, key=prices.get)
        min_venue = min(prices, key=prices.get)

        spread_pct = (max_price - min_price) / min_price * 100

        if spread_pct > 0.5:  # 0.5% minimum profitable spread
            return [{
                "opportunity": "cross_venue",
                "buy_venue": min_venue,
                "sell_venue": max_venue,
                "spread_pct": spread_pct,
                "action": f"BUY {min_venue} @ {min_price}, SELL {max_venue} @ {max_price}"
            }]
        return []
```

### 12.3 Real-Time Arbitrage Pipeline

```python
class ArbitragePipeline:
    """Continuous arbitrage opportunity scanning"""

    def __init__(self):
        self.detector = ArbitrageDetector()
        self.position_sizer = PositionSizer()
        self.risk_manager = RiskManager()

    async def scan_opportunities(self):
        """Main scanning loop - runs every 100ms"""
        opportunities = []

        # 1. Polymarket vs Spot Crypto
        crypto_markets = await self.fetch_polymarket_crypto_markets()
        for market in crypto_markets:
            spot_price = await self.get_spot_price(market['asset'])
            pm_price = market['implied_probability'] * spot_price  # Convert to same scale

            speed_gap = self.detector.detect_speed_gap(pm_price, spot_price)
            if speed_gap['opportunity']:
                opportunities.append(speed_gap)

        # 2. Cross-venue crypto
        venues = await self.fetch_all_crypto_venues()
        cross_venue = self.detector.scan_cross_venue_arbitrage(venues)
        opportunities.extend(cross_venue)

        # 3. Momentum divergence
        for market in crypto_markets:
            momentum = self.detector.detect_momentum_divergence(
                market['asset'],
                await self.get_spot_history(market['asset'], period='1h'),
                await self.get_pm_history(market['id'], period='1h')
            )
            if momentum['opportunity']:
                opportunities.append(momentum)

        return opportunities

    async def execute_opportunity(self, opportunity: dict, capital: float):
        """Execute arbitrage with position sizing and risk management"""
        position = self.position_sizer.calculate(
            opportunity['expected_edge'],
            capital,
            max_risk_pct=0.02  # 2% max risk per trade
        )

        if position['size'] < 1:
            return {"executed": False, "reason": "Position too small"}

        risk = self.risk_manager.check_risk(position, opportunity)
        if not risk['approved']:
            return {"executed": False, "reason": risk['reason']}

        # Execute in paper trading mode
        return await self.paper_trading.buy(
            symbol=opportunity.get('asset', opportunity.get('market_id')),
            quantity=position['size'],
            price=opportunity.get('price', position['entry_price'])
        )
```

### 12.4 Discipline Gap - Automated Execution

Unlike humans, AI doesn't:
- Miss trades due to fatigue
- Hold losing positions out of hope
- Overtrade due to emotion
- Ignore risk limits

```python
class AutomatedExecution:
    """Rules-based execution eliminating human bias"""

    def __init__(self):
        self.max_daily_trades = 50
        self.max_position_pct = 0.05  # 5% per position
        self.max_drawdown_pct = 0.10  # 10% daily drawdown limit
        self.min_confidence = 0.65

    def should_execute(self, signal: dict, portfolio: dict) -> dict:
        """Determine if signal should execute based on rules"""

        # Confidence check
        if signal.get('confidence', 0) < self.min_confidence:
            return {"execute": False, "reason": f"Confidence {signal['confidence']} < {self.min_confidence}"}

        # Position size check
        position_value = signal.get('price', 0) * signal.get('size', 0)
        portfolio_value = portfolio.get('total_value', 1)
        if position_value / portfolio_value > self.max_position_pct:
            return {"execute": False, "reason": f"Position {position_value/portfolio_value*100:.1f}% > {self.max_position_pct*100}% max"}

        # Drawdown check
        if portfolio.get('drawdown_pct', 0) > self.max_drawdown_pct:
            return {"execute": False, "reason": f"Drawdown {portfolio['drawdown_pct']*100:.1f}% > {self.max_drawdown_pct*100}% limit"}

        # Daily trade limit
        if portfolio.get('daily_trades', 0) >= self.max_daily_trades:
            return {"execute": False, "reason": f"Daily trades {portfolio['daily_trades']} >= {self.max_daily_trades} limit"}

        return {"execute": True, "reason": "All checks passed"}
```

### 12.5 Success Metrics for Arbitrage

| Metric | Target |
|--------|--------|
| Speed Gap Detection | < 100ms latency advantage |
| Spread Capture Rate | > 80% of detected spreads |
| Win Rate | > 55% on arbitrage signals |
| Max Drawdown | < 15% per strategy |
| Daily Signal Generation | 20-50 opportunities/day |

### 12.6 Scalability Path

1. **Phase 1 (Paper):** $10k starting capital, manual approval of signals
2. **Phase 2 (Semi-auto):** $50k, AI suggests, human approves
3. **Phase 3 (Automated):** $100k+, full automation with risk limits
4. **Phase 4 (Multi-venue):** Expand to Binance, Coinbase, Kraken, Polymarket
5. **Phase 5 (Production):** Real money, MiroFish swarm intelligence added

**Document Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-16 | Saiyudh | Initial financial markets platform PRD |
| 1.1 | 2026-04-16 | Claude | Added arbitrage & market microstructure section |