export type EpisodeSummary = {
  id: number;
  name: string;
  airDate: string;
  code: string;
  characterCount: number;
};

import type { CharacterSummary } from "../characters/character.models.js";

export type EpisodeDetails = EpisodeSummary & {
  characters: CharacterSummary[];
};

export type EpisodeListResult = {
  page: number;
  totalPages: number;
  totalItems: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
  episodes: EpisodeSummary[];
};

export type CharacterSortField = "name" | "id" | "status" | "species";
export type SortOrder = "asc" | "desc";
