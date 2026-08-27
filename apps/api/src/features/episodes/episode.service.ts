import { badRequest } from "../../errors/app-error.js";
import type {
  EpisodeListFilters,
  RickAndMortyGateway
} from "../../integrations/rick-and-morty/types.js";
import { extractIdsFromUrls } from "../../integrations/rick-and-morty/url-utils.js";
import { sortCharacters } from "./character-sorter.js";
import { toCharacterSummary, toEpisodeSummary } from "./episode.mapper.js";
import type {
  CharacterSortField,
  EpisodeDetails,
  EpisodeListResult,
  SortOrder
} from "./episode.models.js";

export type EpisodeDetailsOptions = {
  sortCharactersBy?: CharacterSortField;
  characterOrder?: SortOrder;
};

export class EpisodeService {
  constructor(private readonly gateway: RickAndMortyGateway) {}

  async listEpisodes(filters: EpisodeListFilters): Promise<EpisodeListResult> {
    const page = await this.gateway.listEpisodes(filters);

    return {
      page: filters.page,
      totalPages: page.info.pages,
      totalItems: page.info.count,
      hasNextPage: page.info.next !== null,
      hasPreviousPage: page.info.prev !== null,
      episodes: page.results.map(toEpisodeSummary)
    };
  }

  async getEpisodeDetails(
    id: number,
    options: EpisodeDetailsOptions = {}
  ): Promise<EpisodeDetails> {
    if (!Number.isInteger(id) || id <= 0) {
      throw badRequest("Episode id must be a positive integer", { id });
    }

    const episode = await this.gateway.getEpisode(id);
    const characterIds = extractIdsFromUrls(episode.characters);
    const characters = await this.gateway.getCharacters(characterIds);
    const mappedCharacters = characters.map(toCharacterSummary);

    return {
      ...toEpisodeSummary(episode),
      characters: sortCharacters(
        mappedCharacters,
        options.sortCharactersBy ?? "name",
        options.characterOrder ?? "asc"
      )
    };
  }
}
