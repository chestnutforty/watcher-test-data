#!/usr/bin/env bash
# Simulate realistic data change scenarios for watcher testing.
#
# Usage:
#   ./scripts/simulate-scenario.sh <scenario>
#
# Scenarios:
#   unemployment-spike   - Unemployment jumps from 4.3% to 5.1%
#   rate-cut             - Fed cuts rate from 4.50% to 4.25%
#   market-crash         - S&P 500 drops 8%
#   inflation-surge      - CPI spikes with high YoY change
#   gdp-contraction      - GDP goes negative (recession signal)
#   all-change           - All datasets change at once
#   reset                - Reset all datasets to baseline values

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:?Usage: $0 <scenario>}" in

unemployment-spike)
    echo "📊 Scenario: Unemployment spikes to 5.1%"
    "$SCRIPT_DIR/update-data.sh" unemployment latest.value 5.1
    "$SCRIPT_DIR/update-data.sh" unemployment latest.date 2026-03
    ;;

rate-cut)
    echo "🏦 Scenario: Fed cuts rate to 4.25%"
    "$SCRIPT_DIR/update-data.sh" fed-rate latest.value 4.25
    "$SCRIPT_DIR/update-data.sh" fed-rate latest.date 2026-03
    ;;

market-crash)
    echo "📈 Scenario: S&P 500 drops 8% to 5396"
    "$SCRIPT_DIR/update-data.sh" sp500 latest.close 5396.08
    "$SCRIPT_DIR/update-data.sh" sp500 latest.change_pct -7.99
    ;;

inflation-surge)
    echo "🛒 Scenario: CPI surges, YoY hits 4.2%"
    "$SCRIPT_DIR/update-data.sh" cpi latest.value 325.8
    "$SCRIPT_DIR/update-data.sh" cpi yoy_change_pct 4.2
    ;;

gdp-contraction)
    echo "💰 Scenario: GDP contracts (recession signal)"
    "$SCRIPT_DIR/update-data.sh" gdp latest.value 29200.0
    ;;

all-change)
    echo "🔥 Scenario: All datasets change"
    "$SCRIPT_DIR/simulate-scenario.sh" unemployment-spike
    "$SCRIPT_DIR/simulate-scenario.sh" rate-cut
    "$SCRIPT_DIR/simulate-scenario.sh" market-crash
    "$SCRIPT_DIR/simulate-scenario.sh" inflation-surge
    "$SCRIPT_DIR/simulate-scenario.sh" gdp-contraction
    ;;

reset)
    echo "🔄 Resetting all datasets to baseline..."
    REPO="danielproj/watcher-test-data"
    git -C "$(dirname "$SCRIPT_DIR")" checkout -- data/
    git -C "$(dirname "$SCRIPT_DIR")" add data/ && \
    git -C "$(dirname "$SCRIPT_DIR")" commit -m "Reset test data to baseline" && \
    git -C "$(dirname "$SCRIPT_DIR")" push origin main || true
    echo "✓ Reset complete"
    ;;

*)
    echo "Unknown scenario: $1"
    echo ""
    echo "Available scenarios:"
    echo "  unemployment-spike  - Unemployment jumps to 5.1%"
    echo "  rate-cut            - Fed cuts rate to 4.25%"
    echo "  market-crash        - S&P 500 drops 8%"
    echo "  inflation-surge     - CPI spikes with high YoY"
    echo "  gdp-contraction     - GDP goes negative"
    echo "  all-change          - All datasets change at once"
    echo "  reset               - Reset to baseline values"
    exit 1
    ;;
esac
