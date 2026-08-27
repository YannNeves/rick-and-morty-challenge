import assert from "node:assert/strict";
import test from "node:test";

import type {
  EpisodeListFilters,
  RickAndMortyCharacter,
  RickAndMortyEpisode,
  RickAndMortyGateway,
  RickAndMortyPage
} from "../../integrations/rick-and-morty/types.js";
import { EpisodeService } from "./episode.service.js";

const episode: RickAndMortyEpisode = {
  id: 28,
  name: "The Ricklantis Mixup",
  air_date: "September 10, 2017",
  episode: "S03E07",
  characters: [
    "https://rickandmortyapi.com/api/character/2",
    "https://rickandmortyapi.com/api/character/1"
  ],
  url: "https://rickandmortyapi.com/api/episode/28",
  created: "2017-11-10T12:56:36.618Z"
};

const character = (id: number, name: string): RickAndMortyCharacter => ({
  id,
  name,
  status: "Alive",
  species: "Human",
  type: "",
  gender: "Male",
  origin: {
    name: "Earth",
    url: ""
  },
  location: {
    name: "Earth",
    url: ""
  },
  image: `https://example.com/${id}.jpeg`,
  episode: ["episode"],
  url: `https://rickandmortyapi.com/api/character/${id}`,
  created: "2017-11-04T18:48:46.250Z"
});

class FakeGateway implements RickAndMortyGateway {
  requestedCharacterIds: number[] = [];

  async listEpisodes(
    filters: EpisodeListFilters
  ): Promise<RickAndMortyPage<RickAndMortyEpisode>> {
    return {
      info: {
        count: 1,
        pages: 1,
        next: null,
        prev: filters.page > 1 ? "previous" : null
      },
      results: [episode]
    };
  }

  async getEpisode(): Promise<RickAndMortyEpisode> {
    return episode;
  }

  async getCharacters(ids: number[]): Promise<RickAndMortyCharacter[]> {
    this.requestedCharacterIds = ids;
    return [character(2, "Morty Smith"), character(1, "Rick Sanchez")];
  }
}

test("listEpisodes maps upstream pagination and episode summaries", async () => {
  const service = new EpisodeService(new FakeGateway());

  const result = await service.listEpisodes({ page: 1 });

  assert.equal(result.totalItems, 1);
  assert.equal(result.episodes[0]?.characterCount, 2);
  assert.equal(result.episodes[0]?.code, "S03E07");
});

test("getEpisodeDetails fetches characters in batch and sorts them by name", async () => {
  const gateway = new FakeGateway();
  const service = new EpisodeService(gateway);

  const result = await service.getEpisodeDetails(28);

  assert.deepEqual(gateway.requestedCharacterIds, [2, 1]);
  assert.deepEqual(
    result.characters.map((item) => item.name),
    ["Morty Smith", "Rick Sanchez"]
  );
});
