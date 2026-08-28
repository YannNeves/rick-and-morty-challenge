import type {
  LocationListFilters,
  LocationPage
} from "../domain/location.models.js";

export interface LocationsGateway {
  listLocations(filters: LocationListFilters): Promise<LocationPage>;
}
