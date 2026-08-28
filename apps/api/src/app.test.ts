import assert from "node:assert/strict";
import { AddressInfo } from "node:net";
import test from "node:test";

import { createApp } from "./app.js";
import type { AppEnv } from "./config/env.js";
import type { CharactersGateway } from "./modules/characters/application/characters.gateway.js";
import type {
  CharacterDetails,
  CharacterListFilters,
  CharacterListResult,
  CharacterSummary
} from "./modules/characters/domain/character.models.js";
import type {
  EpisodeCharactersGateway,
  EpisodesGateway
} from "./modules/episodes/application/episodes.gateway.js";
import type {
  Episode,
  EpisodeListFilters,
  EpisodePage
} from "./modules/episodes/domain/episode.models.js";
import type { LocationsGateway } from "./modules/locations/application/locations.gateway.js";
import type { Location, LocationListFilters, LocationPage } from "./modules/locations/domain/location.models.js";

const testEnv: AppEnv = {
  nodeEnv: "test",
  port: 0,
  rickAndMortyApiUrl: "https://example.com",
  requestTimeoutMs: 100,
  cacheTtlMs: 100,
  cacheMaxEntries: 20,
  allowedOrigins: ["*"]
};

const episode: Episode = {
  id: 1,
  name: "Pilot",
  airDate: "December 2, 2013",
  code: "S01E01",
  characterCount: 1,
  characterIds: [1]
};

const character: CharacterSummary = {
  id: 1,
  name: "Rick Sanchez",
  status: "Alive",
  species: "Human",
  type: "",
  gender: "Male",
  origin: "Earth",
  location: "Earth",
  image: "",
  episodeCount: 1
};

class FakeGateway implements CharactersGateway, EpisodesGateway, EpisodeCharactersGateway, LocationsGateway {
  async listCharacters(
    filters: CharacterListFilters
  ): Promise<CharacterListResult> {
    return {
      page: filters.page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      characters: [character]
    };
  }

  async getCharacter(): Promise<CharacterDetails> {
    return {
      ...character,
      origin: { id: null, name: "Earth" },
      location: { id: null, name: "Earth" },
      episodeIds: []
    };
  }

  async listEpisodes(
    _filters: EpisodeListFilters
  ): Promise<EpisodePage> {
    return {
      page: _filters.page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      episodes: [episode]
    };
  }

  async getEpisode(): Promise<Episode> {
    return episode;
  }

  async getEpisodes(): Promise<Episode[]> {
    return [{ ...episode, id: 28, name: "The Ricklantis Mixup", code: "S03E07" }, { ...episode, id: 10 }];
  }

  async getCharacters(): Promise<CharacterSummary[]> {
    return [character];
  }

  async listLocations(filters: LocationListFilters): Promise<LocationPage> {
    return {
      page: filters.page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      locations: [{ id: 3, name: "Citadel of Ricks", type: "Space station", dimension: "unknown", residentCount: 1, residentIds: [1] }]
    };
  }

  async getLocation(): Promise<Location> {
    return { id: 3, name: "Citadel of Ricks", type: "Space station", dimension: "unknown", residentCount: 1, residentIds: [1] };
  }

  async getLocations(): Promise<Location[]> {
    return [
      { id: 21, name: "Testicle Monster Dimension", type: "Dimension", dimension: "Testicle Monster Dimension", residentCount: 0, residentIds: [] },
      await this.getLocation()
    ];
  }
}

const withServer = async <T>(callback: (baseUrl: string) => Promise<T>): Promise<T> => {
  const app = createApp(testEnv, new FakeGateway());
  const server = await new Promise<ReturnType<typeof app.listen>>((resolve, reject) => {
    const createdServer = app.listen(0, "127.0.0.1", () => resolve(createdServer));
    createdServer.once("error", reject);
  });

  try {
    const { port } = server.address() as AddressInfo;
    return await callback(`http://127.0.0.1:${port}`);
  } finally {
    if (server.listening) {
      await new Promise<void>((resolve, reject) => {
        server.close((error) => (error ? reject(error) : resolve()));
      });
    }
  }
};

test("GET /health returns service status", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/health`);
    const body = (await response.json()) as { status: string };

    assert.equal(response.status, 200);
    assert.equal(body.status, "ok");
  });
});

test("GET /api/v1/episodes returns mapped episodes", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/episodes`);
    const body = (await response.json()) as {
      episodes: Array<{ name: string; characterCount: number }>;
    };

    assert.equal(response.status, 200);
    assert.equal(body.episodes[0]?.name, "Pilot");
    assert.equal(body.episodes[0]?.characterCount, 1);
  });
});

test("GET /api/v1/episodes/:id rejects invalid ids", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/episodes/zero`);
    const body = (await response.json()) as { error: { code: string } };

    assert.equal(response.status, 400);
    assert.equal(body.error.code, "BAD_REQUEST");
  });
});

test("GET /api/v1/episodes/batch returns deduplicated episode summaries", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/episodes/batch?ids=10,28,10`);
    const body = (await response.json()) as { episodes: Array<{ id: number; characterIds?: number[] }> };
    assert.equal(response.status, 200);
    assert.deepEqual(body.episodes.map((item) => item.id), [10, 28]);
    assert.equal(body.episodes[0]?.characterIds, undefined);
  });
});

test("GET /api/v1/episodes/batch rejects invalid lists", async () => {
  await withServer(async (baseUrl) => assert.equal((await fetch(`${baseUrl}/api/v1/episodes/batch?ids=10,zero`)).status, 400));
});

test("GET /api/v1/locations returns a mapped location page", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/locations?name=citadel&type=station&dimension=unknown`);
    const body = (await response.json()) as { totalItems: number; locations: Array<{ name: string; residentCount: number }> };

    assert.equal(response.status, 200);
    assert.equal(body.totalItems, 1);
    assert.deepEqual(body.locations[0], { id: 3, name: "Citadel of Ricks", type: "Space station", dimension: "unknown", residentCount: 1 });
  });
});

test("GET /api/v1/locations/:id returns sorted residents", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/locations/3`);
    const body = (await response.json()) as { name: string; residents: CharacterSummary[] };

    assert.equal(response.status, 200);
    assert.equal(body.name, "Citadel of Ricks");
    assert.deepEqual(body.residents.map((resident) => resident.name), ["Rick Sanchez"]);
  });
});

test("GET /api/v1/locations/:id rejects invalid ids", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/locations/zero`);
    assert.equal(response.status, 400);
  });
});

test("GET /api/v1/locations/batch returns deduplicated locations", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/locations/batch?ids=3,21,3`);
    const body = (await response.json()) as { locations: Array<{ id: number }> };
    assert.equal(response.status, 200);
    assert.deepEqual(body.locations.map((location) => location.id), [3, 21]);
  });
});

test("GET /api/v1/locations/batch rejects invalid lists", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/locations/batch?ids=3,zero`);
    assert.equal(response.status, 400);
  });
});

test("GET /api/v1/characters returns a mapped character page", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(
      `${baseUrl}/api/v1/characters?name=rick&status=alive&gender=male`
    );
    const body = (await response.json()) as {
      totalItems: number;
      characters: Array<{ name: string; episodeCount: number }>;
    };

    assert.equal(response.status, 200);
    assert.equal(body.totalItems, 1);
    assert.equal(body.characters[0]?.name, "Rick Sanchez");
    assert.equal(body.characters[0]?.episodeCount, 1);
  });
});

test("GET /api/v1/characters rejects invalid enum filters", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/characters?status=sleeping`);
    const body = (await response.json()) as { error: { code: string } };

    assert.equal(response.status, 400);
    assert.equal(body.error.code, "BAD_REQUEST");
  });
});

test("GET /api/v1/characters/:id returns character details", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/characters/1`);
    const body = (await response.json()) as {
      name: string;
      episodeIds: number[];
      origin: { id: number | null; name: string };
    };

    assert.equal(response.status, 200);
    assert.equal(body.name, "Rick Sanchez");
    assert.deepEqual(body.episodeIds, []);
    assert.deepEqual(body.origin, { id: null, name: "Earth" });
  });
});

test("GET /api/v1/characters/:id rejects invalid ids", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/characters/zero`);
    const body = (await response.json()) as { error: { code: string } };

    assert.equal(response.status, 400);
    assert.equal(body.error.code, "BAD_REQUEST");
  });
});

test("GET /api/v1/characters/batch returns deduplicated characters", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/characters/batch?ids=1,1`);
    const body = (await response.json()) as {
      characters: Array<{ id: number; name: string }>;
    };

    assert.equal(response.status, 200);
    assert.deepEqual(
      body.characters.map((character) => character.id),
      [1]
    );
  });
});

test("GET /api/v1/characters/batch rejects invalid lists", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/v1/characters/batch?ids=1,zero`);
    const body = (await response.json()) as { error: { code: string } };

    assert.equal(response.status, 400);
    assert.equal(body.error.code, "BAD_REQUEST");
  });
});
