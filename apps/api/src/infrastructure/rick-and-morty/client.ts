import { notFound, upstreamError } from "../../shared/errors/app-error.js";
import { InMemoryCache } from "../cache/in-memory-cache.js";
import type {
  RickAndMortyCharacter,
  RickAndMortyEpisode,
  RickAndMortyLocation,
  RickAndMortyPage
} from "./types.js";
import type { CharactersGateway } from "../../modules/characters/application/characters.gateway.js";
import type {
  CharacterDetails,
  CharacterListFilters,
  CharacterListResult,
  CharacterSummary
} from "../../modules/characters/domain/character.models.js";
import type { EpisodesGateway } from "../../modules/episodes/application/episodes.gateway.js";
import type {
  Episode,
  EpisodeListFilters,
  EpisodePage
} from "../../modules/episodes/domain/episode.models.js";
import { toCharacterDetails, toCharacterSummary } from "./character.mapper.js";
import { toEpisode } from "./episode.mapper.js";
import type { LocationsGateway } from "../../modules/locations/application/locations.gateway.js";
import type { Location, LocationListFilters, LocationPage } from "../../modules/locations/domain/location.models.js";
import { toLocation } from "./location.mapper.js";
import { resolveApiUrl } from "./url-utils.js";

type ClientConfig = {
  baseUrl: string;
  timeoutMs: number;
  cacheTtlMs: number;
  cacheMaxEntries?: number;
  fetchFn?: typeof fetch;
  sleepFn?: (milliseconds: number) => Promise<void>;
  randomFn?: () => number;
};

type CacheValue =
  | RickAndMortyEpisode
  | RickAndMortyEpisode[]
  | RickAndMortyCharacter
  | RickAndMortyCharacter[]
  | RickAndMortyLocation
  | RickAndMortyLocation[]
  | RickAndMortyPage<RickAndMortyCharacter>
  | RickAndMortyPage<RickAndMortyEpisode>
  | RickAndMortyPage<RickAndMortyLocation>;

export class RickAndMortyHttpClient implements EpisodesGateway, CharactersGateway, LocationsGateway {
  private readonly cache: InMemoryCache<CacheValue>;
  private readonly fetchFn: typeof fetch;
  private readonly inFlight = new Map<string, Promise<CacheValue>>();
  private readonly sleepFn: (milliseconds: number) => Promise<void>;
  private readonly randomFn: () => number;

  constructor(private readonly config: ClientConfig) {
    this.cache = new InMemoryCache<CacheValue>(
      config.cacheTtlMs,
      config.cacheMaxEntries
    );
    this.fetchFn = config.fetchFn ?? fetch;
    this.sleepFn = config.sleepFn ?? ((milliseconds) =>
      new Promise((resolve) => setTimeout(resolve, milliseconds)));
    this.randomFn = config.randomFn ?? Math.random;
  }

  async listEpisodes(
    filters: EpisodeListFilters
  ): Promise<EpisodePage> {
    const searchParams = new URLSearchParams();
    if (filters.page > 1) searchParams.set("page", String(filters.page));

    if (filters.name) {
      searchParams.set("name", filters.name);
    }

    if (filters.episode) {
      searchParams.set("episode", filters.episode);
    }

    const page = await this.getJson<RickAndMortyPage<RickAndMortyEpisode>>(
      `/episode${searchParams.size > 0 ? `?${searchParams.toString()}` : ""}`,
      { notFoundValue: this.emptyPage<RickAndMortyEpisode>() }
    );

    return {
      page: filters.page,
      totalPages: page.info.pages,
      totalItems: page.info.count,
      hasNextPage: page.info.next !== null,
      hasPreviousPage: page.info.prev !== null,
      episodes: page.results.map(toEpisode)
    };
  }

  async listCharacters(
    filters: CharacterListFilters
  ): Promise<CharacterListResult> {
    const searchParams = new URLSearchParams();
    if (filters.page > 1) searchParams.set("page", String(filters.page));

    for (const key of ["name", "status", "species", "type", "gender"] as const) {
      const value = filters[key];
      if (value) {
        searchParams.set(key, value);
      }
    }

    const page = await this.getJson<RickAndMortyPage<RickAndMortyCharacter>>(
      `/character${searchParams.size > 0 ? `?${searchParams.toString()}` : ""}`,
      { notFoundValue: this.emptyPage<RickAndMortyCharacter>() }
    );

    return {
      page: filters.page,
      totalPages: page.info.pages,
      totalItems: page.info.count,
      hasNextPage: page.info.next !== null,
      hasPreviousPage: page.info.prev !== null,
      characters: page.results.map(toCharacterSummary)
    };
  }

  async listLocations(filters: LocationListFilters): Promise<LocationPage> {
    const searchParams = new URLSearchParams();
    if (filters.page > 1) searchParams.set("page", String(filters.page));

    for (const key of ["name", "type", "dimension"] as const) {
      const value = filters[key];
      if (value) {
        searchParams.set(key, value);
      }
    }

    const page = await this.getJson<RickAndMortyPage<RickAndMortyLocation>>(
      `/location${searchParams.size > 0 ? `?${searchParams.toString()}` : ""}`,
      { notFoundValue: this.emptyPage<RickAndMortyLocation>() }
    );

    return {
      page: filters.page,
      totalPages: page.info.pages,
      totalItems: page.info.count,
      hasNextPage: page.info.next !== null,
      hasPreviousPage: page.info.prev !== null,
      locations: page.results.map(toLocation)
    };
  }

  async getCharacter(id: number): Promise<CharacterDetails> {
    return toCharacterDetails(
      await this.getJson<RickAndMortyCharacter>(`/character/${id}`)
    );
  }

  async getLocation(id: number): Promise<Location> {
    return toLocation(await this.getJson<RickAndMortyLocation>(`/location/${id}`));
  }

  async getLocations(ids: number[]): Promise<Location[]> {
    if (ids.length === 0) return [];

    const uniqueIds = [...new Set(ids)];
    const response = await this.getJson<RickAndMortyLocation | RickAndMortyLocation[]>(
      `/location/${uniqueIds.join(",")}`
    );

    return (Array.isArray(response) ? response : [response]).map(toLocation);
  }

  async getEpisode(id: number): Promise<Episode> {
    return toEpisode(await this.getJson<RickAndMortyEpisode>(`/episode/${id}`));
  }

  async getEpisodes(ids: number[]): Promise<Episode[]> {
    if (ids.length === 0) return [];
    const uniqueIds = [...new Set(ids)];
    const response = await this.getJson<RickAndMortyEpisode | RickAndMortyEpisode[]>(`/episode/${uniqueIds.join(",")}`);
    return (Array.isArray(response) ? response : [response]).map(toEpisode);
  }

  async getCharacters(ids: number[]): Promise<CharacterSummary[]> {
    if (ids.length === 0) {
      return [];
    }

    const uniqueIds = [...new Set(ids)];
    const path = `/character/${uniqueIds.join(",")}`;
    const response = await this.getJson<RickAndMortyCharacter | RickAndMortyCharacter[]>(path);

    return (Array.isArray(response) ? response : [response]).map(toCharacterSummary);
  }

  private async getJson<T extends CacheValue>(
    path: string,
    options: { notFoundValue?: T } = {}
  ): Promise<T> {
    const cached = this.cache.get(path) as T | undefined;

    if (cached !== undefined) {
      return cached;
    }

    const pending = this.inFlight.get(path);
    if (pending) {
      return pending as Promise<T>;
    }

    const request = this.requestJson(path, options);
    this.inFlight.set(path, request as Promise<CacheValue>);

    try {
      return await request;
    } finally {
      if (this.inFlight.get(path) === request) {
        this.inFlight.delete(path);
      }
    }
  }

  private async requestJson<T extends CacheValue>(
    path: string,
    options: { notFoundValue?: T }
  ): Promise<T> {
    const url = resolveApiUrl(this.config.baseUrl, path);

    const response = await this.fetchWithRetry(url);

    if (response.status === 404) {
      if (options.notFoundValue !== undefined) {
        this.cache.set(path, options.notFoundValue);
        return options.notFoundValue;
      }
      throw notFound("Rick and Morty resource not found", { path });
    }

    if (!response.ok) {
      throw upstreamError("Rick and Morty API returned an unexpected status", {
        path,
        status: response.status
      });
    }

    const body = (await response.json()) as T;
    this.cache.set(path, body);
    return body;
  }

  private async fetchWithRetry(url: URL): Promise<Response> {
    let lastError: unknown;
    const maxAttempts = 3;

    for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
      try {
        const response = await this.fetchOnce(url);
        if (!this.isRetryableStatus(response.status) || attempt === maxAttempts - 1) {
          return response;
        }

        await this.sleepFn(this.retryDelay(response, attempt));
      } catch (error) {
        lastError = error;
        if (attempt < maxAttempts - 1) {
          await this.sleepFn(this.backoffDelay(attempt));
        }
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

  private isRetryableStatus(status: number): boolean {
    return status === 429 || status === 502 || status === 503 || status === 504;
  }

  private retryDelay(response: Response, attempt: number): number {
    const retryAfter = response.headers.get("retry-after");
    if (!retryAfter) return this.backoffDelay(attempt);

    const seconds = Number(retryAfter);
    if (Number.isFinite(seconds) && seconds >= 0) {
      return seconds * 1_000;
    }

    const date = Date.parse(retryAfter);
    return Number.isNaN(date)
      ? this.backoffDelay(attempt)
      : Math.max(0, date - Date.now());
  }

  private backoffDelay(attempt: number): number {
    return 250 * (2 ** attempt) + Math.floor(this.randomFn() * 101);
  }

  private emptyPage<T>(): RickAndMortyPage<T> {
    return {
      info: { count: 0, pages: 0, next: null, prev: null },
      results: []
    };
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
