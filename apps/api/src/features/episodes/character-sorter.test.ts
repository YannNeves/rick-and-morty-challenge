import assert from "node:assert/strict";
import test from "node:test";

import { sortCharacters } from "./character-sorter.js";
import type { CharacterSummary } from "../characters/character.models.js";

const characters: CharacterSummary[] = [
  {
    id: 2,
    name: "Morty Smith",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Male",
    image: "",
    origin: "Earth",
    location: "Earth",
    episodeCount: 51
  },
  {
    id: 1,
    name: "Rick Sanchez",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Male",
    image: "",
    origin: "Earth",
    location: "Earth",
    episodeCount: 51
  },
  {
    id: 3,
    name: "Abradolf Lincler",
    status: "unknown",
    species: "Human",
    type: "",
    gender: "Male",
    image: "",
    origin: "unknown",
    location: "unknown",
    episodeCount: 1
  }
];

test("sortCharacters orders by name asc by default without mutating input", () => {
  const sorted = sortCharacters(characters);

  assert.deepEqual(
    sorted.map((character) => character.name),
    ["Abradolf Lincler", "Morty Smith", "Rick Sanchez"]
  );
  assert.equal(characters[0]?.name, "Morty Smith");
});

test("sortCharacters orders by id desc when requested", () => {
  const sorted = sortCharacters(characters, "id", "desc");

  assert.deepEqual(
    sorted.map((character) => character.id),
    [3, 2, 1]
  );
});
