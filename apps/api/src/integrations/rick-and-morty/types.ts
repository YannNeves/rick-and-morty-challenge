export type RickAndMortyPage<T> = {
  info: {
    count: number;
    pages: number;
    next: string | null;
    prev: string | null;
  };
  results: T[];
};

export type RickAndMortyEpisode = {
  id: number;
  name: string;
  air_date: string;
  episode: string;
  characters: string[];
  url: string;
  created: string;
};

export type RickAndMortyCharacter = {
  id: number;
  name: string;
  status: string;
  species: string;
  type: string;
  gender: string;
  origin: {
    name: string;
    url: string;
  };
  location: {
    name: string;
    url: string;
  };
  image: string;
  episode: string[];
  url: string;
  created: string;
};

export type EpisodeListFilters = {
  page: number;
  name?: string;
  episode?: string;
};

export type CharacterStatus = "alive" | "dead" | "unknown";
export type CharacterGender = "female" | "male" | "genderless" | "unknown";

export type CharacterListFilters = {
  page: number;
  name?: string;
  status?: CharacterStatus;
  species?: string;
  type?: string;
  gender?: CharacterGender;
};

export interface CharactersGateway {
  listCharacters(
    filters: CharacterListFilters
  ): Promise<RickAndMortyPage<RickAndMortyCharacter>>;
}

export interface RickAndMortyGateway {
  listEpisodes(filters: EpisodeListFilters): Promise<RickAndMortyPage<RickAndMortyEpisode>>;
  getEpisode(id: number): Promise<RickAndMortyEpisode>;
  getCharacters(ids: number[]): Promise<RickAndMortyCharacter[]>;
}
