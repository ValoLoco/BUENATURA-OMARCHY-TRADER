export type SignalAction = "long" | "short" | "exit";

export type IncomingSignal = {
  secret: string;
  event: "signal" | "test";
  strategy: string;
  symbol: string;
  timeframe: string;
  action: SignalAction;
  price: number;
  stop?: number;
  target?: number;
  timestamp: number;
  barClose: boolean;
};

export type StrategyConfig = {
  id: string;
  name: string;
  enabled: boolean;
  symbols: string[];
  timeframes: string[];
  chartUrl: string;
};

export type GatewayConfig = {
  port: number;
  webhookSecret: string;
  signalTtlSeconds: number;
  strategies: StrategyConfig[];
};

export type SignalState = Omit<IncomingSignal, "secret"> & {
  receivedAt: string;
  status: "armed" | "blocked" | "stale";
  reason?: string;
};
