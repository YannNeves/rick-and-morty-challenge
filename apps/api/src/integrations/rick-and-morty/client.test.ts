import assert from "node:assert/strict";
import test from "node:test";

import { AppError } from "../../errors/app-error.js";
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
