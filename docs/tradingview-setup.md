# TradingView setup

## Security boundary

The plugin never asks for, collects, or stores TradingView credentials. Use the official TradingView sign-in page in your browser. The only connection to this project is an outbound TradingView alert webhook.

## 1. Start the local gateway

```bash
cd gateway
cp config.example.json config.json
chmod 600 config.json
npm install
npm run dev
```

Verify it locally:

```bash
curl http://127.0.0.1:8787/health
```

## 2. Configure a secure public delivery path

TradingView must reach an HTTPS endpoint. Do not expose port 8787 directly to the internet. Use an authenticated tunnel or a reverse proxy on infrastructure you control that forwards only validated requests to the local gateway.

## 3. Sign in to TradingView

Open https://www.tradingview.com/accounts/signin/ in the browser. Complete sign-in and any two-factor authentication directly with TradingView.

## 4. Add a strategy and create an alert

1. Open the intended NQ chart.
2. Add your tested Pine strategy.
3. Create an alert.
4. Select the strategy and `Any alert() function call`.
5. Use `Once Per Bar Close`.
6. Enter your HTTPS webhook URL.
7. Create the alert.

Copy the template from `pine/signal-sentinel-template.pine` into TradingView, but set the strategy conditions and stop/target values before using it.

## 5. Verify a local test event

Use this only after replacing the secret in `config.json`:

```bash
curl -X POST http://127.0.0.1:8787/tradingview \
  -H 'Content-Type: application/json' \
  -d '{"secret":"REPLACE_WITH_YOUR_SECRET","event":"test","strategy":"sierra618-nq-5m","symbol":"CME_MINI:NQ1!","timeframe":"5","action":"long","price":20000,"timestamp":0,"barClose":true}'
```

For a real test, replace `timestamp` with the current Unix epoch time in milliseconds.

## Manual execution only

A received signal is an alert for review. Confirm market conditions and risk in TradingView before placing any trade. This project does not execute orders.
