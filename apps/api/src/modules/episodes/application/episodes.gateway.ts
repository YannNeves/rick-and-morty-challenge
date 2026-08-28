import type { CharacterSummary } from "../../characters/domain/character.models.js";
import type {
  Episode,
  EpisodeListFilters,
  EpisodePage
} from "../domain/episode.models.js";

export interface EpisodesGateway {
  listEpisodes(filters: EpisodeListFilters): Promise<EpisodePage>;
  getEpisode(id: number): Promise<Episode>;
}

export interface EpisodeCharactersGateway {
  getCharacters(ids: number[]): Promise<CharacterSummary[]>;
}
