import { badRequest } from "../../../shared/errors/app-error.js";
import { sortCharacters } from "../domain/character-sorter.js";
import { EPISODE_BATCH_LIMIT } from "../domain/episode.models.js";
import type {
  CharacterSortField,
  EpisodeDetails,
  EpisodeListFilters,
  EpisodeListResult,
  EpisodeSummary,
  SortOrder
} from "../domain/episode.models.js";
import type {
  EpisodeCharactersGateway,
  EpisodesGateway
} from "./episodes.gateway.js";

export type EpisodeDetailsOptions = {
  sortCharactersBy?: CharacterSortField;
  characterOrder?: SortOrder;
};

export class EpisodeService {
  constructor(
    private readonly episodesGateway: EpisodesGateway,
    private readonly charactersGateway: EpisodeCharactersGateway
  ) {}

  async listEpisodes(filters: EpisodeListFilters): Promise<EpisodeListResult> {
    const page = await this.episodesGateway.listEpisodes(filters);

    return {
      ...page,
      episodes: page.episodes.map(({ characterIds: _characterIds, ...episode }) => episode)
    };
  }

  async listAllEpisodes(): Promise<EpisodeSummary[]> {
    const firstPage = await this.episodesGateway.listEpisodes({ page: 1 });
    const remainingPages = await Promise.all(
      Array.from({ length: firstPage.totalPages - 1 }, (_, index) =>
        this.episodesGateway.listEpisodes({ page: index + 2 })
      )
    );
    return [firstPage, ...remainingPages]
      .flatMap((page) => page.episodes)
      .map(({ characterIds: _characterIds, ...episode }) => episode)
      .toSorted((left, right) => left.code.localeCompare(right.code));
  }

  async getEpisodeDetails(
    id: number,
    options: EpisodeDetailsOptions = {}
  ): Promise<EpisodeDetails> {
    if (!Number.isInteger(id) || id <= 0) {
      throw badRequest("Episode id must be a positive integer", { id });
    }

    const episode = await this.episodesGateway.getEpisode(id);
    const characters = await this.charactersGateway.getCharacters(episode.characterIds);
    const { characterIds: _characterIds, ...summary } = episode;

    return {
      ...summary,
      characters: sortCharacters(
        characters,
        options.sortCharactersBy ?? "name",
        options.characterOrder ?? "asc"
      )
    };
  }

  async getEpisodesBatch(ids: number[]): Promise<EpisodeSummary[]> {
    const uniqueIds = [...new Set(ids)];
    if (uniqueIds.length === 0 || uniqueIds.length > EPISODE_BATCH_LIMIT || uniqueIds.some((id) => !Number.isInteger(id) || id <= 0)) {
      throw badRequest("Episode ids are invalid", { maxItems: EPISODE_BATCH_LIMIT });
    }

    const episodes = await this.episodesGateway.getEpisodes(uniqueIds);
    const byId = new Map(episodes.map((episode) => [episode.id, episode]));
    return uniqueIds.flatMap((id) => {
      const episode = byId.get(id);
      if (!episode) return [];
      const { characterIds: _characterIds, ...summary } = episode;
      return [summary];
    });
  }
}
