import type {
  CharacterSortField,
  SortOrder
} from "./episode.models.js";
import type { CharacterSummary } from "../../characters/domain/character.models.js";
import {
  compareCharactersByName,
  compareCharacterText
} from "../../characters/domain/character-order.js";

export const sortCharacters = (
  characters: CharacterSummary[],
  sortBy: CharacterSortField = "name",
  order: SortOrder = "asc"
): CharacterSummary[] => {
  const direction = order === "asc" ? 1 : -1;

  return [...characters].sort((left, right) => {
    if (sortBy === "id") {
      return (left.id - right.id) * direction;
    }

    const comparison = sortBy === "name"
      ? compareCharactersByName(left, right)
      : compareCharacterText(left[sortBy], right[sortBy]) || left.id - right.id;

    return comparison * direction;
  });
};
