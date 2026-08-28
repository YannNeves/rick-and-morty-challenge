import assert from "node:assert/strict";
import test from "node:test";

import { mapWithConcurrency } from "./map-with-concurrency.js";

test("mapWithConcurrency preserves order and limits active work", async () => {
  let active = 0;
  let maximumActive = 0;
  const result = await mapWithConcurrency([1, 2, 3, 4, 5, 6], 4, async (value) => {
    active += 1;
    maximumActive = Math.max(maximumActive, active);
    await Promise.resolve();
    active -= 1;
    return value * 2;
  });

  assert.deepEqual(result, [2, 4, 6, 8, 10, 12]);
  assert.equal(maximumActive, 4);
});

test("mapWithConcurrency rejects invalid limits", async () => {
  await assert.rejects(mapWithConcurrency([1], 0, async (value) => value), RangeError);
});
