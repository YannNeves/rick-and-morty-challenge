import { badRequest } from "../errors/app-error.js";
import type {
  CharacterSortField,
  SortOrder
} from "../features/episodes/episode.models.js";
import type {
  CharacterGender,
  CharacterStatus
} from "../integrations/rick-and-morty/types.js";

const characterSortFields = new Set<CharacterSortField>([
  "name",
  "id",
  "status",
  "species"
]);
const sortOrders = new Set<SortOrder>(["asc", "desc"]);
const characterStatuses = new Set<CharacterStatus>(["alive", "dead", "unknown"]);
const characterGenders = new Set<CharacterGender>([
  "female",
  "male",
  "genderless",
  "unknown"
]);

export const parsePositiveInt = (value: unknown, fieldName: string): number => {
  const normalized = Array.isArray(value) ? value[0] : value;
  const parsed = Number(normalized);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw badRequest(`${fieldName} must be a positive integer`, {
      [fieldName]: normalized
    });
  }

  return parsed;
};

export const parseOptionalString = (value: unknown): string | undefined => {
  const normalized = Array.isArray(value) ? value[0] : value;

  if (typeof normalized !== "string") {
    return undefined;
  }

  const trimmed = normalized.trim();
  return trimmed.length > 0 ? trimmed : undefined;
};

export const parseIdList = (
  value: unknown,
  fieldName: string,
  maxItems: number
): number[] => {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw badRequest(`${fieldName} must be a comma-separated list of ids`);
  }

  const parts = value.split(",").map((part) => part.trim());
  if (parts.length > maxItems) {
    throw badRequest(`${fieldName} exceeds the maximum number of items`, {
      maxItems
    });
  }

  const ids = parts.map(Number);
  if (ids.some((id) => !Number.isInteger(id) || id <= 0)) {
    throw badRequest(`${fieldName} must contain only positive integers`);
  }

  return [...new Set(ids)];
};

const parseEnum = <T extends string>(
  value: unknown,
  fieldName: string,
  acceptedValues: Set<T>
): T | undefined => {
  const parsed = parseOptionalString(value)?.toLowerCase();
  if (!parsed) {
    return undefined;
  }
  if (!acceptedValues.has(parsed as T)) {
    throw badRequest(`${fieldName} is invalid`, {
      acceptedValues: [...acceptedValues]
    });
  }
  return parsed as T;
};

export const parseCharacterStatus = (value: unknown): CharacterStatus | undefined =>
  parseEnum(value, "status", characterStatuses);

export const parseCharacterGender = (value: unknown): CharacterGender | undefined =>
  parseEnum(value, "gender", characterGenders);

export const parseCharacterSortField = (
  value: unknown
): CharacterSortField | undefined => {
  const parsed = parseOptionalString(value);

  if (!parsed) {
    return undefined;
  }

  if (!characterSortFields.has(parsed as CharacterSortField)) {
    throw badRequest("sortCharactersBy is invalid", {
      acceptedValues: [...characterSortFields]
    });
  }

  return parsed as CharacterSortField;
};

export const parseSortOrder = (value: unknown): SortOrder | undefined => {
  const parsed = parseOptionalString(value);

  if (!parsed) {
    return undefined;
  }

  if (!sortOrders.has(parsed as SortOrder)) {
    throw badRequest("characterOrder is invalid", {
      acceptedValues: [...sortOrders]
    });
  }

  return parsed as SortOrder;
};
