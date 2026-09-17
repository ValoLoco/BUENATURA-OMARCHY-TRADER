import express from "express";
import { loadConfig } from "./config.js";
import { getLatestPath, saveSignal } from "./state-store.js";
import { validateSignal } from "./validate-signal.js";

const config = await loadConfig();
const app = express();
app.use(express.json({ limit: "32kb" }));

app.get("/health", (_request, response) => {
  response.json({ ok: true, latestSignalPath: getLatestPath() });
});

app.post("/tradingview", async (request, response) => {
  try {
    const signal = validateSignal(request.body, config);
    await saveSignal(signal);
    response.status(202).json({ ok: true, status: signal.status });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Invalid signal";
    response.status(400).json({ ok: false, error: message });
  }
});

app.listen(config.port, "127.0.0.1", () => {
  console.log(`Signal gateway listening on http://127.0.0.1:${config.port}`);
});
