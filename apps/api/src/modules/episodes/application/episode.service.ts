import { badRequest } from "../../../shared/errors/app-error.js";
import { sortCharacters } from "../domain/character-sorter.js";
import type {
  CharacterSortField,
  EpisodeDetails,
  EpisodeListFilters,
  EpisodeListResult,
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
}
