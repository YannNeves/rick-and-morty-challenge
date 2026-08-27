import { notFound, upstreamError } from "../../errors/app-error.js";
import { InMemoryCache } from "../../shared/cache/in-memory-cache.js";
import type {
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
};

type CacheValue =
  | RickAndMortyEpisode
  | RickAndMortyCharacter[]
  | RickAndMortyPage<RickAndMortyEpisode>;

export class RickAndMortyHttpClient implements RickAndMortyGateway {
  private readonly cache: InMemoryCache<CacheValue>;

  constructor(private readonly config: ClientConfig) {
    this.cache = new InMemoryCache<CacheValue>(config.cacheTtlMs);
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
    try {
      return await this.fetchOnce(url);
    } catch (error) {
      if (error instanceof Error && error.name === "AbortError") {
        throw upstreamError("Rick and Morty API request timed out", {
          url: url.toString(),
          timeoutMs: this.config.timeoutMs
        });
      }

      return this.fetchOnce(url);
    }
  }

  private async fetchOnce(url: URL): Promise<Response> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.config.timeoutMs);

    try {
      return await fetch(url, {
        headers: {
          accept: "application/json"
        },
        signal: controller.signal
      });
    } catch (error) {
      if (error instanceof Error && error.name === "AbortError") {
        throw error;
      }

      throw upstreamError("Could not connect to Rick and Morty API", {
        url: url.toString(),
        cause: error instanceof Error ? error.message : String(error)
      });
    } finally {
      clearTimeout(timeout);
    }
  }
}
