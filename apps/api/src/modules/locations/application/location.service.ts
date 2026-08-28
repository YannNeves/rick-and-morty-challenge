import { badRequest } from "../../../shared/errors/app-error.js";
import type {
  LocationDetails,
  LocationListFilters,
  LocationListResult
} from "../domain/location.models.js";
import type { LocationCharactersGateway, LocationsGateway } from "./locations.gateway.js";

export class LocationService {
  constructor(
    private readonly locationsGateway: LocationsGateway,
    private readonly charactersGateway: LocationCharactersGateway
  ) {}

  async listLocations(filters: LocationListFilters): Promise<LocationListResult> {
    const page = await this.locationsGateway.listLocations(filters);

    return {
      ...page,
      locations: page.locations.map(({ residentIds: _residentIds, ...location }) => location)
    };
  }

  async getLocationDetails(id: number): Promise<LocationDetails> {
    if (!Number.isInteger(id) || id <= 0) {
      throw badRequest("Location id must be a positive integer", { id });
    }

    const location = await this.locationsGateway.getLocation(id);
    const residents = await this.charactersGateway.getCharacters(location.residentIds);
    const { residentIds: _residentIds, ...summary } = location;

    return {
      ...summary,
      residents: residents.toSorted((left, right) =>
        left.name.localeCompare(right.name, "en", { sensitivity: "base" })
      )
    };
  }
}
