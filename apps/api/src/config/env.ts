export type AppEnv = {
  nodeEnv: string;
  port: number;
  rickAndMortyApiUrl: string;
  requestTimeoutMs: number;
  cacheTtlMs: number;
  cacheMaxEntries: number;
  allowedOrigins: string[];
};

const toNumber = (value: string | undefined, fallback: number): number => {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

const toOrigins = (value: string | undefined): string[] => {
  if (!value) {
    return ["*"];
  }

  return value
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
};

export const env: AppEnv = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  port: toNumber(process.env.PORT, 3000),
  rickAndMortyApiUrl:
    process.env.RICK_AND_MORTY_API_URL ?? "https://rickandmortyapi.com/api",
  requestTimeoutMs: toNumber(process.env.REQUEST_TIMEOUT_MS, 6000),
  cacheTtlMs: toNumber(process.env.CACHE_TTL_MS, 60_000),
  cacheMaxEntries: toNumber(process.env.CACHE_MAX_ENTRIES, 500),
  allowedOrigins: toOrigins(process.env.ALLOWED_ORIGINS)
};
