import { env } from "./config/env.js";
import { createApp } from "./app.js";
import { RickAndMortyHttpClient } from "./infrastructure/rick-and-morty/client.js";

const gateway = new RickAndMortyHttpClient({
  baseUrl: env.rickAndMortyApiUrl,
  timeoutMs: env.requestTimeoutMs,
  cacheTtlMs: env.cacheTtlMs,
  cacheMaxEntries: env.cacheMaxEntries
});

const app = createApp(env, gateway);

app.listen(env.port, () => {
  console.log(`API running on port ${env.port}`);
});
