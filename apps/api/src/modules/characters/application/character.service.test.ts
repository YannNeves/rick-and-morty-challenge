import assert from "node:assert/strict";
import test from "node:test";
import { AppError } from "../../../shared/errors/app-error.js";
import type { CharacterDetails, CharacterListFilters, CharacterListResult, CharacterSummary } from "../domain/character.models.js";
import { CharacterService } from "./character.service.js";
import type { CharactersGateway } from "./characters.gateway.js";

const summary: CharacterSummary = { id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male", image: "https://example.com/rick.jpeg", origin: "Earth (C-137)", location: "Citadel of Ricks", episodeCount: 2 };
const details: CharacterDetails = { ...summary, origin: { id: 1, name: "Earth (C-137)" }, location: { id: 3, name: "Citadel of Ricks" }, episodeIds: [1, 2] };

class FakeGateway implements CharactersGateway {
  filters?: CharacterListFilters;
  async listCharacters(filters: CharacterListFilters): Promise<CharacterListResult> {
    this.filters = filters;
    return { page: filters.page, totalPages: 2, totalItems: 1, hasNextPage: true, hasPreviousPage: false, characters: [summary] };
  }
  async getCharacter(): Promise<CharacterDetails> { return details; }
  async getCharacters(): Promise<CharacterSummary[]> { return [{ ...summary, id: 2, name: "Morty Smith" }, summary]; }
}

test("listCharacters delegates filters and returns the domain page", async () => {
  const gateway = new FakeGateway();
  const filters: CharacterListFilters = { page: 1, name: "rick", status: "alive", gender: "male" };
  const result = await new CharacterService(gateway).listCharacters(filters);
  assert.deepEqual(gateway.filters, filters);
  assert.deepEqual(result.characters[0], summary);
});

test("getCharactersBatch deduplicates ids and preserves requested order", async () => {
  const result = await new CharacterService(new FakeGateway()).getCharactersBatch([1, 2, 1]);
  assert.deepEqual(result.map((item) => item.id), [1, 2]);
});

test("getCharactersBatch rejects invalid and oversized lists", async () => {
  const service = new CharacterService(new FakeGateway());
  await assert.rejects(service.getCharactersBatch([]), AppError);
  await assert.rejects(service.getCharactersBatch([0]), AppError);
  await assert.rejects(service.getCharactersBatch(Array.from({ length: 101 }, (_, index) => index + 1)), AppError);
});

test("getCharacterDetails returns the domain contract", async () => {
  assert.deepEqual(await new CharacterService(new FakeGateway()).getCharacterDetails(1), details);
});

test("getCharacterDetails rejects invalid ids", async () => {
  await assert.rejects(new CharacterService(new FakeGateway()).getCharacterDetails(0), AppError);
});
