import type {
  RickAndMortyCharacter,
  RickAndMortyEpisode
} from "../../integrations/rick-and-morty/types.js";
import type { CharacterSummary, EpisodeSummary } from "./episode.models.js";

export const toEpisodeSummary = (episode: RickAndMortyEpisode): EpisodeSummary => ({
  id: episode.id,
  name: episode.name,
  airDate: episode.air_date,
  code: episode.episode,
  characterCount: episode.characters.length
});

export const toCharacterSummary = (
  character: RickAndMortyCharacter
): CharacterSummary => ({
  id: character.id,
  name: character.name,
  status: character.status,
  species: character.species,
  type: character.type,
  gender: character.gender,
  image: character.image,
  origin: character.origin.name,
  location: character.location.name,
  episodeCount: character.episode.length
});
