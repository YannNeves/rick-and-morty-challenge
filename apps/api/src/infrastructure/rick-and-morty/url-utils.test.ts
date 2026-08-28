import assert from "node:assert/strict";
import test from "node:test";

import { extractIdFromUrl, extractIdsFromUrls, resolveApiUrl } from "./url-utils.js";

test("extractIdFromUrl returns the trailing resource id", () => {
  assert.equal(
    extractIdFromUrl("https://rickandmortyapi.com/api/character/42"),
    42
  );
});

test("extractIdFromUrl ignores invalid urls", () => {
  assert.equal(extractIdFromUrl("https://rickandmortyapi.com/api/character"), null);
});

test("extractIdsFromUrls keeps only valid positive ids", () => {
  assert.deepEqual(extractIdsFromUrls(["/character/1", "invalid", "/character/2"]), [
    1,
    2
  ]);
});

test("resolveApiUrl preserves the upstream /api base path", () => {
  assert.equal(
    resolveApiUrl("https://rickandmortyapi.com/api", "/episode/28").toString(),
    "https://rickandmortyapi.com/api/episode/28"
  );
});
