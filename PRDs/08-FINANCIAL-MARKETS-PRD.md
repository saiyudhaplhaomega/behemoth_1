# PRD - Financial Markets Intelligence Platform (FMIP)

**Version:** 1.0
**Date:** 2026-04-16
**Author:** Saiyudh Mannan
**Status:** Draft
**Related To:** Master PRD (00-MASTER-ARCHITECTURE-PRD.md)

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

## 4. MiroFish Swarm Intelligence Integration

### 4.1 What is MiroFish?

MiroFish is a **swarm intelligence prediction engine** that uses multi-agent simulations to predict outcomes. It builds a digital twin of the market environment where agents with different "personalities" interact based on market data, news, and historical patterns.

### 4.2 Integration Architecture

```python
# MiroFish runs as a microservice, called from your backend

MIROFISH_CONFIG = {
    "base_url": os.getenv("MIROFISH_URL", "http://localhost:5001"),
    "frontend_url": os.getenv("MIROFISH_FRONTEND", "http://localhost:3000"),
    "api_version": "v1"
}

def get_mirofish_prediction(question: str, context: dict) -> dict:
    """
    Query MiroFish for swarm intelligence prediction.

    Args:
        question: e.g., "Will BTC reach $100k by end of 2024?"
        context: Market data, news, Polymarket data to feed agents

    Returns:
        Prediction with confidence, agent consensus, and reasoning
    """
    import requests

    response = requests.post(
        f"{MIROFISH_CONFIG['base_url']}/api/v1/predict",
        json={
            "question": question,
            "context": context,
            "agent_count": 100,  # Number of simulated agents
            "simulation_depth": 30,  # Days to simulate
            "memory_enabled": True
        },
        timeout=60
    )

    return response.json()

def get_agent_consensus(prediction: dict) -> dict:
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

### 4.3 MiroFish Deployment

```yaml
# docker-compose.mirofish.yml

version: '3.8'
services:
  mirofish-backend:
    image: ghcr.io/666ghj/mirofish:latest
    ports:
      - "5001:5001"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ZEP_API_KEY=${ZEP_API_KEY}
      - DATABASE_URL=postgresql://mirofish:password@postgres:5432/mirofish
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: mirofish
      POSTGRES_PASSWORD: password
    volumes:
      - mirofish-data:/var/lib/postgresql/data

  redis:
    image: redis:7
    volumes:
      - redis-data:/data

volumes:
  mirofish-data:
  redis-data:
```

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

**Document Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-16 | Saiyudh | Initial financial markets platform PRD |