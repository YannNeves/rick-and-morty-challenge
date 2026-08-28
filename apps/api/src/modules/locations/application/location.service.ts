import type {
  LocationListFilters,
  LocationListResult
} from "../domain/location.models.js";
import type { LocationsGateway } from "./locations.gateway.js";

export class LocationService {
  constructor(private readonly gateway: LocationsGateway) {}

  async listLocations(filters: LocationListFilters): Promise<LocationListResult> {
    const page = await this.gateway.listLocations(filters);

    return {
      ...page,
      locations: page.locations.map(({ residentIds: _residentIds, ...location }) => location)
    };
  }
}
