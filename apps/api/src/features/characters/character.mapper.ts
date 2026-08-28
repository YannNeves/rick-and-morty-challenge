import type { RickAndMortyCharacter } from "../../integrations/rick-and-morty/types.js";
import type { CharacterSummary } from "./character.models.js";

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
