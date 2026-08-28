import { badRequest } from "../../../shared/errors/app-error.js";
import {
  CHARACTER_BATCH_LIMIT,
  type CharacterDetails,
  type CharacterListFilters,
  type CharacterListResult,
  type CharacterSummary
} from "../domain/character.models.js";
import type { CharactersGateway } from "./characters.gateway.js";

export class CharacterService {
  constructor(private readonly gateway: CharactersGateway) {}

  async listCharacters(filters: CharacterListFilters): Promise<CharacterListResult> {
    return this.gateway.listCharacters(filters);
  }

  async listAllCharacters(): Promise<CharacterSummary[]> {
    const firstPage = await this.gateway.listCharacters({ page: 1 });
    const remainingPages = await Promise.all(
      Array.from({ length: firstPage.totalPages - 1 }, (_, index) =>
        this.gateway.listCharacters({ page: index + 2 })
      )
    );
    return [firstPage, ...remainingPages]
      .flatMap((page) => page.characters)
      .toSorted((left, right) => left.name.localeCompare(right.name, "en", { sensitivity: "base" }));
  }

  async getCharacterDetails(id: number): Promise<CharacterDetails> {
    if (!Number.isInteger(id) || id <= 0) {
      throw badRequest("Character id must be a positive integer", { id });
    }

    return this.gateway.getCharacter(id);
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
      .filter((character) => character !== undefined);
  }
}
