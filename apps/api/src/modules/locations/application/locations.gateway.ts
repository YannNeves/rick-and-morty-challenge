import type {
  LocationListFilters,
  Location,
  LocationPage
} from "../domain/location.models.js";
import type { CharacterSummary } from "../../characters/domain/character.models.js";

export interface LocationsGateway {
  listLocations(filters: LocationListFilters): Promise<LocationPage>;
  getLocation(id: number): Promise<Location>;
  getLocations(ids: number[]): Promise<Location[]>;
}

export interface LocationCharactersGateway {
  getCharacters(ids: number[]): Promise<CharacterSummary[]>;
}
