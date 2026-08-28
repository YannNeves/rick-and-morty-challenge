import assert from "node:assert/strict";
import test from "node:test";

import { AppError } from "../errors/app-error.js";
import {
  parseCharacterGender,
  parseCharacterStatus
} from "./query-parsers.js";

test("character enum parsers normalize supported values", () => {
  assert.equal(parseCharacterStatus("Alive"), "alive");
  assert.equal(parseCharacterGender("GENDERLESS"), "genderless");
});

test("character enum parsers reject unsupported values", () => {
  assert.throws(
    () => parseCharacterStatus("sleeping"),
    (error: unknown) => error instanceof AppError && error.code === "BAD_REQUEST"
  );
});
