import type {
  CharacterSortField,
  SortOrder
} from "./episode.models.js";
import type { CharacterSummary } from "../../characters/domain/character.models.js";

const collator = new Intl.Collator("pt-BR", {
  sensitivity: "base",
  numeric: true
});

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

    return collator.compare(left[sortBy], right[sortBy]) * direction;
  });
};
