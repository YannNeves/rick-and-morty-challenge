import type {
  CharacterListFilters,
  CharactersGateway
} from "../../integrations/rick-and-morty/types.js";
import { badRequest } from "../../errors/app-error.js";
import {
  toCharacterDetails,
  toCharacterSummary
} from "./character.mapper.js";
import {
  CHARACTER_BATCH_LIMIT,
  type CharacterDetails,
  type CharacterListResult,
  type CharacterSummary
} from "./character.models.js";

export class CharacterService {
  constructor(private readonly gateway: CharactersGateway) {}

  async listCharacters(filters: CharacterListFilters): Promise<CharacterListResult> {
    const page = await this.gateway.listCharacters(filters);

    return {
      page: filters.page,
      totalPages: page.info.pages,
      totalItems: page.info.count,
      hasNextPage: page.info.next !== null,
      hasPreviousPage: page.info.prev !== null,
      characters: page.results.map(toCharacterSummary)
    };
  }

  async getCharacterDetails(id: number): Promise<CharacterDetails> {
    if (!Number.isInteger(id) || id <= 0) {
      throw badRequest("Character id must be a positive integer", { id });
    }

    return toCharacterDetails(await this.gateway.getCharacter(id));
  }

  async getCharactersBatch(ids: number[]): Promise<CharacterSummary[]> {
    const uniqueIds = [...new Set(ids)];
    if (
      uniqueIds.length === 0 ||
      uniqueIds.length > CHARACTER_BATCH_LIMIT ||
      uniqueIds.some((id) => !Number.isInteger(id) || id <= 0)
    ) {
      throw badRequest("Character ids are invalid", {
        maxItems: CHARACTER_BATCH_LIMIT
      });
    }

    const characters = await this.gateway.getCharacters(uniqueIds);
    const byId = new Map(characters.map((character) => [character.id, character]));

    return uniqueIds
      .map((id) => byId.get(id))
      .filter((character) => character !== undefined)
      .map(toCharacterSummary);
  }
}
