import assert from "node:assert/strict";
import test from "node:test";

import type {
  CharacterListFilters,
  CharactersGateway,
  RickAndMortyCharacter,
  RickAndMortyPage
} from "../../integrations/rick-and-morty/types.js";
import { CharacterService } from "./character.service.js";

const character: RickAndMortyCharacter = {
  id: 1,
  name: "Rick Sanchez",
  status: "Alive",
  species: "Human",
  type: "",
  gender: "Male",
  origin: { name: "Earth (C-137)", url: "https://example.com/location/1" },
  location: { name: "Citadel of Ricks", url: "https://example.com/location/3" },
  image: "https://example.com/rick.jpeg",
  episode: ["https://example.com/episode/1", "https://example.com/episode/2"],
  url: "https://example.com/character/1",
  created: "2017-11-04T18:48:46.250Z"
};

class FakeGateway implements CharactersGateway {
  filters?: CharacterListFilters;

  async listCharacters(
    filters: CharacterListFilters
  ): Promise<RickAndMortyPage<RickAndMortyCharacter>> {
    this.filters = filters;
    return {
      info: { count: 1, pages: 2, next: "next", prev: null },
      results: [character]
    };
  }
}

test("listCharacters maps pagination and character summaries", async () => {
  const gateway = new FakeGateway();
  const service = new CharacterService(gateway);
  const filters: CharacterListFilters = {
    page: 1,
    name: "rick",
    status: "alive",
    gender: "male"
  };

  const result = await service.listCharacters(filters);

  assert.deepEqual(gateway.filters, filters);
  assert.equal(result.totalItems, 1);
  assert.equal(result.totalPages, 2);
  assert.equal(result.hasNextPage, true);
  assert.deepEqual(result.characters[0], {
    id: 1,
    name: "Rick Sanchez",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Male",
    image: "https://example.com/rick.jpeg",
    origin: "Earth (C-137)",
    location: "Citadel of Ricks",
    episodeCount: 2
  });
});
