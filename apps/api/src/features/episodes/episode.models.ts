export type EpisodeSummary = {
  id: number;
  name: string;
  airDate: string;
  code: string;
  characterCount: number;
};

export type CharacterSummary = {
  id: number;
  name: string;
  status: string;
  species: string;
  type: string;
  gender: string;
  image: string;
  origin: string;
  location: string;
  episodeCount: number;
};

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
