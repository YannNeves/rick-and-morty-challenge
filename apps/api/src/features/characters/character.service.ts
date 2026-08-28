import type {
  CharacterListFilters,
  CharactersGateway
} from "../../integrations/rick-and-morty/types.js";
import { toCharacterSummary } from "./character.mapper.js";
import type { CharacterListResult } from "./character.models.js";

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
}
