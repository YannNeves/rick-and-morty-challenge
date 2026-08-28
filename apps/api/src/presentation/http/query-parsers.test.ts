import assert from "node:assert/strict";
import test from "node:test";

import { AppError } from "../../shared/errors/app-error.js";
import {
  parseCharacterGender,
  parseCharacterStatus,
  parseIdList
} from "./query-parsers.js";

test("character enum parsers normalize supported values", () => {
  assert.equal(parseCharacterStatus("Alive"), "alive");
  assert.equal(parseCharacterGender("GENDERLESS"), "genderless");
});

test("parseIdList deduplicates ids while preserving order", () => {
  assert.deepEqual(parseIdList("3, 1,3,2", "ids", 10), [3, 1, 2]);
});

test("parseIdList rejects missing, invalid and oversized lists", () => {
  assert.throws(() => parseIdList(undefined, "ids", 2), AppError);
  assert.throws(() => parseIdList("1,zero", "ids", 2), AppError);
  assert.throws(() => parseIdList("1,2,3", "ids", 2), AppError);
});

test("character enum parsers reject unsupported values", () => {
  assert.throws(
    () => parseCharacterStatus("sleeping"),
    (error: unknown) => error instanceof AppError && error.code === "BAD_REQUEST"
  );
});
