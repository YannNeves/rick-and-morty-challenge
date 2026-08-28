import type {
  CharacterDetails,
  CharacterListFilters,
  CharacterListResult,
  CharacterSummary
} from "../domain/character.models.js";

export interface CharactersGateway {
  listCharacters(filters: CharacterListFilters): Promise<CharacterListResult>;
  getCharacter(id: number): Promise<CharacterDetails>;
  getCharacters(ids: number[]): Promise<CharacterSummary[]>;
}
