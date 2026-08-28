import assert from "node:assert/strict";
import test from "node:test";

import { AppError } from "../../shared/errors/app-error.js";
import { RickAndMortyHttpClient } from "./client.js";

const episode = {
  id: 1,
  name: "Pilot",
  air_date: "December 2, 2013",
  episode: "S01E01",
  characters: [],
  url: "https://rickandmortyapi.com/api/episode/1",
  created: "2017-11-10T12:56:33.798Z"
};

const jsonResponse = (body: unknown, status = 200): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" }
  });

test("client retries a transient connection failure", async () => {
  let calls = 0;
  const fetchFn: typeof fetch = async () => {
    calls += 1;
    if (calls === 1) {
      throw new Error("connection reset");
    }
    return jsonResponse(episode);
  };
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn
  });

  assert.equal((await client.getEpisode(1)).name, "Pilot");
  assert.equal(calls, 2);
});

test("client retries timeout and exposes a normalized upstream error", async () => {
  let calls = 0;
  const fetchFn: typeof fetch = async (_input, init) => {
    calls += 1;
    return new Promise<Response>((_resolve, reject) => {
      init?.signal?.addEventListener(
        "abort",
        () => {
          const error = new Error("aborted");
          error.name = "AbortError";
          reject(error);
        },
        { once: true }
      );
    });
  };
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 5,
    cacheTtlMs: 1_000,
    fetchFn
  });

  await assert.rejects(
    client.getEpisode(1),
    (error: unknown) =>
      error instanceof AppError &&
      error.code === "UPSTREAM_ERROR" &&
      error.message.includes("timed out")
  );
  assert.equal(calls, 2);
});

test("client caches successful responses", async () => {
  let calls = 0;
  const fetchFn: typeof fetch = async () => {
    calls += 1;
    return jsonResponse(episode);
  };
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn
  });

  await client.getEpisode(1);
  await client.getEpisode(1);

  assert.equal(calls, 1);
});

test("client maps missing upstream resources to not found", async () => {
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn: async () => jsonResponse({ error: "not found" }, 404)
  });

  await assert.rejects(
    client.getEpisode(999),
    (error: unknown) => error instanceof AppError && error.code === "NOT_FOUND"
  );
});

test("client forwards character pagination and filters", async () => {
  let requestedUrl = "";
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn: async (input) => {
      requestedUrl = input.toString();
      return jsonResponse({
        info: { count: 0, pages: 0, next: null, prev: null },
        results: []
      });
    }
  });

  await client.listCharacters({
    page: 2,
    name: "rick",
    status: "alive",
    species: "human",
    gender: "male"
  });

  const url = new URL(requestedUrl);
  assert.equal(url.pathname, "/api/character");
  assert.equal(url.searchParams.get("page"), "2");
  assert.equal(url.searchParams.get("name"), "rick");
  assert.equal(url.searchParams.get("status"), "alive");
  assert.equal(url.searchParams.get("species"), "human");
  assert.equal(url.searchParams.get("gender"), "male");
});

test("client forwards location pagination and filters and caches by URL", async () => {
  const requestedUrls: string[] = [];
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn: async (input) => {
      requestedUrls.push(input.toString());
      return jsonResponse({
        info: { count: 1, pages: 1, next: null, prev: null },
        results: [{ id: 3, name: "Citadel of Ricks", type: "Space station", dimension: "unknown", residents: [], url: "", created: "" }]
      });
    }
  });

  const filters = { page: 2, name: "citadel", type: "station", dimension: "unknown" };
  await client.listLocations(filters);
  await client.listLocations(filters);

  const url = new URL(requestedUrls[0]!);
  assert.equal(url.pathname, "/api/location");
  assert.equal(url.searchParams.get("page"), "2");
  assert.equal(url.searchParams.get("name"), "citadel");
  assert.equal(url.searchParams.get("type"), "station");
  assert.equal(url.searchParams.get("dimension"), "unknown");
  assert.equal(requestedUrls.length, 1);
});

test("client gets a single character by id", async () => {
  let requestedUrl = "";
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn: async (input) => {
      requestedUrl = input.toString();
      return jsonResponse({
        id: 2,
        name: "Morty Smith",
        status: "Alive",
        species: "Human",
        type: "",
        gender: "Male",
        origin: { name: "Earth", url: "" },
        location: { name: "Earth", url: "" },
        image: "",
        episode: [],
        url: "",
        created: ""
      });
    }
  });

  assert.equal((await client.getCharacter(2)).name, "Morty Smith");
  assert.equal(new URL(requestedUrl).pathname, "/api/character/2");
});

test("client maps a missing character to not found", async () => {
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn: async () => jsonResponse({ error: "not found" }, 404)
  });

  await assert.rejects(
    client.getCharacter(999),
    (error: unknown) => error instanceof AppError && error.code === "NOT_FOUND"
  );
});

test("client normalizes single and multiple character responses", async () => {
  const responseBody = {
    id: 1,
    name: "Rick Sanchez",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Male",
    origin: { name: "Earth", url: "" },
    location: { name: "Earth", url: "" },
    image: "",
    episode: [],
    url: "",
    created: ""
  };
  const client = new RickAndMortyHttpClient({
    baseUrl: "https://example.com/api",
    timeoutMs: 100,
    cacheTtlMs: 1_000,
    fetchFn: async () => jsonResponse(responseBody)
  });

  assert.deepEqual(
    (await client.getCharacters([1])).map((item) => item.id),
    [1]
  );
});
