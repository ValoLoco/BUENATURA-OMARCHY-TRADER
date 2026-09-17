import { appendFile, mkdir, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { SignalState } from "./types.js";

const dataDirectory = process.env.SIGNAL_DATA_DIR ?? join(homedir(), ".local", "share", "buenatura-omarchy-trader");
const latestPath = join(dataDirectory, "latest.json");
const eventsPath = join(dataDirectory, "events.jsonl");

export async function saveSignal(signal: SignalState): Promise<void> {
  await mkdir(dataDirectory, { recursive: true });
  await writeFile(latestPath, JSON.stringify(signal, null, 2) + "
");
  await appendFile(eventsPath, JSON.stringify(signal) + "
");
}

export function getLatestPath(): string {
  return latestPath;
}
