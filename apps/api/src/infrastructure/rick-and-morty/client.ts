import { notFound, upstreamError } from "../../shared/errors/app-error.js";
import { InMemoryCache } from "../cache/in-memory-cache.js";
import type {
  RickAndMortyCharacter,
  RickAndMortyEpisode,
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

export class RickAndMortyHttpClient implements EpisodesGateway, CharactersGateway {
  private readonly cache: InMemoryCache<CacheValue>;
  private readonly fetchFn: typeof fetch;

  constructor(private readonly config: ClientConfig) {
    this.cache = new InMemoryCache<CacheValue>(config.cacheTtlMs);
    this.fetchFn = config.fetchFn ?? fetch;
  }

  async listEpisodes(
    filters: EpisodeListFilters
  ): Promise<EpisodePage> {
    const searchParams = new URLSearchParams({ page: String(filters.page) });

    if (filters.name) {
      searchParams.set("name", filters.name);
    }

    if (filters.episode) {
      searchParams.set("episode", filters.episode);
    }

    const page = await this.getJson<RickAndMortyPage<RickAndMortyEpisode>>(
      `/episode?${searchParams.toString()}`
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
    const searchParams = new URLSearchParams({ page: String(filters.page) });

    for (const key of ["name", "status", "species", "type", "gender"] as const) {
      const value = filters[key];
      if (value) {
        searchParams.set(key, value);
      }
    }

    const page = await this.getJson<RickAndMortyPage<RickAndMortyCharacter>>(
      `/character?${searchParams.toString()}`
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

  async getCharacter(id: number): Promise<CharacterDetails> {
    return toCharacterDetails(
      await this.getJson<RickAndMortyCharacter>(`/character/${id}`)
    );
  }

  async getEpisode(id: number): Promise<Episode> {
    return toEpisode(await this.getJson<RickAndMortyEpisode>(`/episode/${id}`));
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
