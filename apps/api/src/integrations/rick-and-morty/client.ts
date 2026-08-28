import { notFound, upstreamError } from "../../errors/app-error.js";
import { InMemoryCache } from "../../shared/cache/in-memory-cache.js";
import type {
  CharacterListFilters,
  CharactersGateway,
  EpisodeListFilters,
  RickAndMortyCharacter,
  RickAndMortyEpisode,
  RickAndMortyGateway,
  RickAndMortyPage
} from "./types.js";
import { resolveApiUrl } from "./url-utils.js";

type ClientConfig = {
  baseUrl: string;
  timeoutMs: number;
  cacheTtlMs: number;
  fetchFn?: typeof fetch;
};

type CacheValue =
  | RickAndMortyEpisode
  | RickAndMortyCharacter[]
  | RickAndMortyPage<RickAndMortyCharacter>
  | RickAndMortyPage<RickAndMortyEpisode>;

export class RickAndMortyHttpClient implements RickAndMortyGateway, CharactersGateway {
  private readonly cache: InMemoryCache<CacheValue>;
  private readonly fetchFn: typeof fetch;

  constructor(private readonly config: ClientConfig) {
    this.cache = new InMemoryCache<CacheValue>(config.cacheTtlMs);
    this.fetchFn = config.fetchFn ?? fetch;
  }

  async listEpisodes(
    filters: EpisodeListFilters
  ): Promise<RickAndMortyPage<RickAndMortyEpisode>> {
    const searchParams = new URLSearchParams({ page: String(filters.page) });

    if (filters.name) {
      searchParams.set("name", filters.name);
    }

    if (filters.episode) {
      searchParams.set("episode", filters.episode);
    }

    return this.getJson<RickAndMortyPage<RickAndMortyEpisode>>(
      `/episode?${searchParams.toString()}`
    );
  }

  async listCharacters(
    filters: CharacterListFilters
  ): Promise<RickAndMortyPage<RickAndMortyCharacter>> {
    const searchParams = new URLSearchParams({ page: String(filters.page) });

    for (const key of ["name", "status", "species", "type", "gender"] as const) {
      const value = filters[key];
      if (value) {
        searchParams.set(key, value);
      }
    }

    return this.getJson<RickAndMortyPage<RickAndMortyCharacter>>(
      `/character?${searchParams.toString()}`
    );
  }

  async getCharacter(id: number): Promise<RickAndMortyCharacter> {
    return this.getJson<RickAndMortyCharacter>(`/character/${id}`);
  }

  async getEpisode(id: number): Promise<RickAndMortyEpisode> {
    return this.getJson<RickAndMortyEpisode>(`/episode/${id}`);
  }

  async getCharacters(ids: number[]): Promise<RickAndMortyCharacter[]> {
    if (ids.length === 0) {
      return [];
    }

    const uniqueIds = [...new Set(ids)];
    const path = `/character/${uniqueIds.join(",")}`;
    const response = await this.getJson<RickAndMortyCharacter | RickAndMortyCharacter[]>(path);

    return Array.isArray(response) ? response : [response];
  }

  private async getJson<T>(path: string): Promise<T> {
    const cached = this.cache.get(path) as T | undefined;

    if (cached) {
      return cached;
    }

    const url = resolveApiUrl(this.config.baseUrl, path);

    const response = await this.fetchWithRetry(url);

    if (response.status === 404) {
      throw notFound("Rick and Morty resource not found", { path });
    }

    if (!response.ok) {
      throw upstreamError("Rick and Morty API returned an unexpected status", {
        path,
        status: response.status
      });
    }

    const body = (await response.json()) as T;
    this.cache.set(path, body as CacheValue);
    return body;
  }

  private async fetchWithRetry(url: URL): Promise<Response> {
    let lastError: unknown;

    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        return await this.fetchOnce(url);
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError instanceof Error && lastError.name === "AbortError") {
      throw upstreamError("Rick and Morty API request timed out", {
        url: url.toString(),
        timeoutMs: this.config.timeoutMs
      });
    }

    throw upstreamError("Could not connect to Rick and Morty API", {
      url: url.toString(),
      cause: lastError instanceof Error ? lastError.message : String(lastError)
    });
  }

  private async fetchOnce(url: URL): Promise<Response> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.config.timeoutMs);

    try {
      return await this.fetchFn(url, {
        headers: {
          accept: "application/json"
        },
        signal: controller.signal
      });
    } finally {
      clearTimeout(timeout);
    }
  }
}
