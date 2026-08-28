import assert from "node:assert/strict";
import test from "node:test";

import type { RickAndMortyLocation } from "./types.js";
import { toLocation } from "./location.mapper.js";

test("toLocation maps camelCase fields, count and resident ids", () => {
  const upstream: RickAndMortyLocation = {
    id: 3,
    name: "Citadel of Ricks",
    type: "Space station",
    dimension: "unknown",
    residents: ["https://rickandmortyapi.com/api/character/1", "https://rickandmortyapi.com/api/character/2"],
    url: "https://rickandmortyapi.com/api/location/3",
    created: "2017-11-10T13:08:13.191Z"
  };

  assert.deepEqual(toLocation(upstream), {
    id: 3,
    name: "Citadel of Ricks",
    type: "Space station",
    dimension: "unknown",
    residentCount: 2,
    residentIds: [1, 2]
  });
});
