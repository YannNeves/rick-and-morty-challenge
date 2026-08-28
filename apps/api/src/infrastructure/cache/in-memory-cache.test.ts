import assert from "node:assert/strict";
import test from "node:test";

import { InMemoryCache } from "./in-memory-cache.js";

test("cache evicts the oldest entry when it reaches its maximum size", () => {
  const cache = new InMemoryCache<number>(1_000, 2);
  cache.set("first", 1);
  cache.set("second", 2);
  cache.set("third", 3);

  assert.equal(cache.get("first"), undefined);
  assert.equal(cache.get("second"), 2);
  assert.equal(cache.get("third"), 3);
});

test("cache refreshes an existing key without evicting another entry", () => {
  const cache = new InMemoryCache<number>(1_000, 2);
  cache.set("first", 1);
  cache.set("second", 2);
  cache.set("first", 10);

  assert.equal(cache.get("first"), 10);
  assert.equal(cache.get("second"), 2);
  cache.clear();
  assert.equal(cache.get("first"), undefined);
});
