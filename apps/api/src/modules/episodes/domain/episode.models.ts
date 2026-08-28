export type EpisodeSummary = {
  id: number;
  name: string;
  airDate: string;
  code: string;
  characterCount: number;
};

export type Episode = EpisodeSummary & {
  characterIds: number[];
};

export type EpisodeListFilters = {
  page: number;
  name?: string;
  episode?: string;
};

export type EpisodePage = {
  page: number;
  totalPages: number;
  totalItems: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
  episodes: Episode[];
};

import type { CharacterSummary } from "../../characters/domain/character.models.js";

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

export const EPISODE_BATCH_LIMIT = 100;
