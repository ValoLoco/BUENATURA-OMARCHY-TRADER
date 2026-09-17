import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import type { GatewayConfig } from "./types.js";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const configPath = process.env.SIGNAL_CONFIG ?? resolve(root, "config.json");

export async function loadConfig(): Promise<GatewayConfig> {
  return JSON.parse(await readFile(configPath, "utf8")) as GatewayConfig;
}
