# BUENATURA OMARCHY TRADER

A local-first TradingView signal receiver and Omarchy trading notification plugin.

## Scope

- Receives authenticated TradingView webhook alerts
- Validates strategy, symbol, timeframe, freshness, and duplicate events
- Stores local signal state for an Omarchy shell plugin
- Displays an actionable signal overlay and top-bar status
- Opens TradingView for manual trade review and entry

## Non-goals

- No broker integration
- No automated order execution
- No TradingView credential collection or storage
- No public exposure of the local machine

## Architecture

```text
TradingView Pine alert
  -> authenticated webhook
  -> local signal gateway
  -> local state files
  -> Omarchy plugin, notification, and overlay
  -> manual decision in TradingView
```

## Quick start

```bash
cd gateway
npm install
cp config.example.json config.json
npm run dev
```

Then follow [TradingView setup](docs/tradingview-setup.md).

## Security

Use a long random webhook secret. Keep `gateway/config.json` local and never commit it. For internet delivery, use an authenticated tunnel or a reverse proxy on infrastructure you control.
