const idFromUrlPattern = /\/(\d+)$/;

export const extractIdFromUrl = (url: string): number | null => {
  const match = idFromUrlPattern.exec(url);

  if (!match?.[1]) {
    return null;
  }

  const id = Number(match[1]);
  return Number.isInteger(id) && id > 0 ? id : null;
};

export const extractIdsFromUrls = (urls: string[]): number[] =>
  urls
    .map(extractIdFromUrl)
    .filter((id): id is number => typeof id === "number");

export const resolveApiUrl = (baseUrl: string, path: string): URL => {
  const normalizedBase = baseUrl.endsWith("/") ? baseUrl.slice(0, -1) : baseUrl;
  const normalizedPath = path.startsWith("/") ? path.slice(1) : path;

  return new URL(`${normalizedBase}/${normalizedPath}`);
};
