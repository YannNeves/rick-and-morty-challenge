import assert from "node:assert/strict";
import test from "node:test";
import type { CharacterSummary } from "../../characters/domain/character.models.js";
import type { Episode, EpisodeListFilters, EpisodePage } from "../domain/episode.models.js";
import { EpisodeService } from "./episode.service.js";
import type { EpisodeCharactersGateway, EpisodesGateway } from "./episodes.gateway.js";

const episode: Episode = { id: 28, name: "The Ricklantis Mixup", airDate: "September 10, 2017", code: "S03E07", characterCount: 2, characterIds: [2, 1] };
const character = (id: number, name: string): CharacterSummary => ({ id, name, status: "Alive", species: "Human", type: "", gender: "Male", origin: "Earth", location: "Earth", image: `https://example.com/${id}.jpeg`, episodeCount: 1 });

class FakeGateway implements EpisodesGateway, EpisodeCharactersGateway {
  requestedCharacterIds: number[] = [];
  async listEpisodes(filters: EpisodeListFilters): Promise<EpisodePage> {
    return { page: filters.page, totalPages: 1, totalItems: 1, hasNextPage: false, hasPreviousPage: filters.page > 1, episodes: [episode] };
  }
  async getEpisode(): Promise<Episode> { return episode; }
  async getEpisodes(): Promise<Episode[]> { return [{ ...episode, id: 10 }, episode]; }
  async getCharacters(ids: number[]): Promise<CharacterSummary[]> {
    this.requestedCharacterIds = ids;
    return [character(2, "Morty Smith"), character(1, "Rick Sanchez")];
  }
}

test("listEpisodes removes internal character ids from the public contract", async () => {
  const gateway = new FakeGateway();
  const result = await new EpisodeService(gateway, gateway).listEpisodes({ page: 1 });
  assert.equal(result.totalItems, 1);
  assert.equal("characterIds" in (result.episodes[0] ?? {}), false);
});

test("listAllEpisodes returns the complete public collection", async () => {
  const gateway = new FakeGateway();
  const result = await new EpisodeService(gateway, gateway).listAllEpisodes();
  assert.equal(result.length, 1);
  assert.equal("characterIds" in (result[0] ?? {}), false);
});

test("getEpisodeDetails fetches characters in batch and sorts them by name", async () => {
  const gateway = new FakeGateway();
  const result = await new EpisodeService(gateway, gateway).getEpisodeDetails(28);
  assert.deepEqual(gateway.requestedCharacterIds, [2, 1]);
  assert.deepEqual(result.characters.map((item) => item.name), ["Morty Smith", "Rick Sanchez"]);
});

test("getEpisodesBatch deduplicates ids, preserves order and hides character ids", async () => {
  const gateway = new FakeGateway();
  const result = await new EpisodeService(gateway, gateway).getEpisodesBatch([28, 10, 28]);
  assert.deepEqual(result.map((item) => item.id), [28, 10]);
  assert.equal("characterIds" in (result[0] ?? {}), false);
});

test("getEpisodesBatch rejects empty, invalid and oversized lists", async () => {
  const gateway = new FakeGateway();
  const service = new EpisodeService(gateway, gateway);
  await assert.rejects(service.getEpisodesBatch([]));
  await assert.rejects(service.getEpisodesBatch([0]));
  await assert.rejects(service.getEpisodesBatch(Array.from({ length: 101 }, (_, index) => index + 1)));
});
