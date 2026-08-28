import { badRequest } from "../../../shared/errors/app-error.js";
import type {
  LocationDetails,
  LocationListFilters,
  LocationListResult,
  LocationSummary
} from "../domain/location.models.js";
import { LOCATION_BATCH_LIMIT } from "../domain/location.models.js";
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

  async listAllLocations(): Promise<LocationSummary[]> {
    const firstPage = await this.locationsGateway.listLocations({ page: 1 });
    const remainingPages = await Promise.all(
      Array.from({ length: firstPage.totalPages - 1 }, (_, index) =>
        this.locationsGateway.listLocations({ page: index + 2 })
      )
    );
    return [firstPage, ...remainingPages]
      .flatMap((page) => page.locations)
      .map(({ residentIds: _residentIds, ...location }) => location)
      .toSorted((left, right) => left.name.localeCompare(right.name, "en", { sensitivity: "base" }));
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

  async getLocationsBatch(ids: number[]): Promise<LocationSummary[]> {
    const uniqueIds = [...new Set(ids)];
    if (
      uniqueIds.length === 0 ||
      uniqueIds.length > LOCATION_BATCH_LIMIT ||
      uniqueIds.some((id) => !Number.isInteger(id) || id <= 0)
    ) {
      throw badRequest("Location ids are invalid", { maxItems: LOCATION_BATCH_LIMIT });
    }

    const locations = await this.locationsGateway.getLocations(uniqueIds);
    const byId = new Map(locations.map((location) => [location.id, location]));

    return uniqueIds.flatMap((id) => {
      const location = byId.get(id);
      if (!location) return [];
      const { residentIds: _residentIds, ...summary } = location;
      return [summary];
    });
  }
}
