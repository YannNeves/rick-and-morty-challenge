import type { RickAndMortyCharacter } from "../../integrations/rick-and-morty/types.js";
import {
  extractIdFromUrl,
  extractIdsFromUrls
} from "../../integrations/rick-and-morty/url-utils.js";
import type {
  CharacterDetails,
  CharacterSummary
} from "./character.models.js";

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

export const toCharacterDetails = (
  character: RickAndMortyCharacter
): CharacterDetails => ({
  id: character.id,
  name: character.name,
  status: character.status,
  species: character.species,
  type: character.type,
  gender: character.gender,
  image: character.image,
  origin: {
    id: extractIdFromUrl(character.origin.url),
    name: character.origin.name
  },
  location: {
    id: extractIdFromUrl(character.location.url),
    name: character.location.name
  },
  episodeCount: character.episode.length,
  episodeIds: extractIdsFromUrls(character.episode)
});
