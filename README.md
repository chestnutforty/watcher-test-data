# Watcher Test Data

Controllable JSON endpoints served via GitHub Pages for testing the prediction engine watcher.

**Dashboard:** https://danielproj.github.io/watcher-test-data/

## Endpoints

| Dataset | URL | Description |
|---------|-----|-------------|
| Unemployment | `/data/unemployment.json` | BLS U-3 unemployment rate |
| GDP | `/data/gdp.json` | BEA quarterly GDP |
| Fed Rate | `/data/fed-rate.json` | Federal funds rate |
| CPI | `/data/cpi.json` | Consumer price index |
| S&P 500 | `/data/sp500.json` | S&P 500 index |

## Quick Start

```bash
# 1. Create a forecast
curl -X POST http://localhost:6080/v1/forecast \
  -H "Content-Type: application/json" \
  -d '{"question": "Will US unemployment exceed 5%?", ...}'

# 2. Register all test endpoints as watches
./scripts/register-watches.sh <forecast_id>

# 3. Simulate a data change
./scripts/simulate-scenario.sh unemployment-spike

# 4. Wait for watcher poll cycle, check updates
curl http://localhost:6080/v1/forecast/<forecast_id>/updates
```

## Scenarios

```bash
./scripts/simulate-scenario.sh unemployment-spike   # 4.3% → 5.1%
./scripts/simulate-scenario.sh rate-cut              # 4.50% → 4.25%
./scripts/simulate-scenario.sh market-crash          # S&P drops 8%
./scripts/simulate-scenario.sh inflation-surge       # CPI YoY hits 4.2%
./scripts/simulate-scenario.sh gdp-contraction       # GDP goes negative
./scripts/simulate-scenario.sh all-change            # Everything changes
./scripts/simulate-scenario.sh reset                 # Back to baseline
```
