import type { CharacterSummary } from "./character.models.js";

const collator = new Intl.Collator("pt-BR", {
  sensitivity: "base",
  numeric: true
});

export const compareCharactersByName = (
  left: CharacterSummary,
  right: CharacterSummary
): number => collator.compare(left.name, right.name) || left.id - right.id;

export const compareCharacterText = (left: string, right: string): number =>
  collator.compare(left, right);
