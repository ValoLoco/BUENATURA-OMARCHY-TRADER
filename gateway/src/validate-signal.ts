import type { GatewayConfig, IncomingSignal, SignalState } from "./types.js";

const actions = new Set(["long", "short", "exit"]);

export function validateSignal(payload: unknown, config: GatewayConfig): SignalState {
  if (!isRecord(payload)) throw new Error("Payload must be a JSON object");

  const signal = payload as Partial<IncomingSignal>;
  if (signal.secret !== config.webhookSecret) throw new Error("Unauthorized webhook");
  if (signal.event !== "signal" && signal.event !== "test") throw new Error("Invalid event");
  if (!isText(signal.strategy) || !isText(signal.symbol) || !isText(signal.timeframe)) throw new Error("Missing strategy metadata");
  if (!isText(signal.action) || !actions.has(signal.action)) throw new Error("Invalid action");
  if (!isFiniteNumber(signal.price) || !isFiniteNumber(signal.timestamp)) throw new Error("Invalid price or timestamp");
  if (signal.barClose !== true) throw new Error("Only confirmed bar-close signals are accepted");

  const strategy = config.strategies.find((item) => item.id === signal.strategy);
  if (!strategy) throw new Error("Unknown strategy");
  if (!strategy.enabled) throw new Error("Strategy is disabled");
  if (!strategy.symbols.includes(signal.symbol)) throw new Error("Symbol is not allowed");
  if (!strategy.timeframes.includes(signal.timeframe)) throw new Error("Timeframe is not allowed");

  const ageSeconds = Math.abs(Date.now() - signal.timestamp) / 1000;
  if (ageSeconds > config.signalTtlSeconds) throw new Error("Signal is stale");

  return {
    event: signal.event,
    strategy: signal.strategy,
    symbol: signal.symbol,
    timeframe: signal.timeframe,
    action: signal.action,
    price: signal.price,
    stop: signal.stop,
    target: signal.target,
    timestamp: signal.timestamp,
    barClose: true,
    receivedAt: new Date().toISOString(),
    status: "armed"
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function isText(value: unknown): value is string {
  return typeof value === "string" && value.length > 0;
}

function isFiniteNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}
