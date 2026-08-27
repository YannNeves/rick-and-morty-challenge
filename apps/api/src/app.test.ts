import assert from "node:assert/strict";
import { AddressInfo } from "node:net";
import test from "node:test";

import { createApp } from "./app.js";
import type { AppEnv } from "./config/env.js";
import type {
  EpisodeListFilters,
  RickAndMortyCharacter,
  RickAndMortyEpisode,
  RickAndMortyGateway,
  RickAndMortyPage
} from "./integrations/rick-and-morty/types.js";

const testEnv: AppEnv = {
  nodeEnv: "test",
  port: 0,
  rickAndMortyApiUrl: "https://example.com",
  requestTimeoutMs: 100,
  cacheTtlMs: 100,
  allowedOrigins: ["*"]
};

const episode: RickAndMortyEpisode = {
  id: 1,
  name: "Pilot",
  air_date: "December 2, 2013",
  episode: "S01E01",
  characters: ["https://rickandmortyapi.com/api/character/1"],
  url: "https://rickandmortyapi.com/api/episode/1",
  created: "2017-11-10T12:56:33.798Z"
};

class FakeGateway implements RickAndMortyGateway {
  async listEpisodes(
    _filters: EpisodeListFilters
  ): Promise<RickAndMortyPage<RickAndMortyEpisode>> {
    return {
      info: {
        count: 1,
        pages: 1,
        next: null,
        prev: null
      },
      results: [episode]
    };
  }

  async getEpisode(): Promise<RickAndMortyEpisode> {
    return episode;
  }

  async getCharacters(): Promise<RickAndMortyCharacter[]> {
    return [
      {
        id: 1,
        name: "Rick Sanchez",
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
        image: "",
        episode: ["episode"],
        url: "",
        created: ""
      }
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
    await new Promise<void>((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
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
