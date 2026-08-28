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

export type CharacterListResult = {
  page: number;
  totalPages: number;
  totalItems: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
  characters: CharacterSummary[];
};

export type CharacterReference = {
  id: number | null;
  name: string;
};

export type CharacterDetails = Omit<
  CharacterSummary,
  "origin" | "location" | "episodeCount"
> & {
  origin: CharacterReference;
  location: CharacterReference;
  episodeCount: number;
  episodeIds: number[];
};
