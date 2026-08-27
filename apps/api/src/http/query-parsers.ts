import { badRequest } from "../errors/app-error.js";
import type {
  CharacterSortField,
  SortOrder
} from "../features/episodes/episode.models.js";

const characterSortFields = new Set<CharacterSortField>([
  "name",
  "id",
  "status",
  "species"
]);
const sortOrders = new Set<SortOrder>(["asc", "desc"]);

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
