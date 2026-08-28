import assert from "node:assert/strict";
import test from "node:test";

import type { LocationListFilters, LocationPage } from "../domain/location.models.js";
import { LocationService } from "./location.service.js";
import type { LocationsGateway } from "./locations.gateway.js";

class FakeGateway implements LocationsGateway {
  filters?: LocationListFilters;

  async listLocations(filters: LocationListFilters): Promise<LocationPage> {
    this.filters = filters;
    return {
      page: filters.page,
      totalPages: 7,
      totalItems: 126,
      hasNextPage: true,
      hasPreviousPage: false,
      locations: [{ id: 3, name: "Citadel of Ricks", type: "Space station", dimension: "unknown", residentCount: 2, residentIds: [1, 2] }]
    };
  }
}

test("listLocations delegates filters and hides internal resident ids", async () => {
  const gateway = new FakeGateway();
  const filters = { page: 1, name: "citadel", type: "station", dimension: "unknown" };
  const result = await new LocationService(gateway).listLocations(filters);

  assert.deepEqual(gateway.filters, filters);
  assert.equal(result.totalItems, 126);
  assert.equal(result.locations[0]?.residentCount, 2);
  assert.equal("residentIds" in (result.locations[0] ?? {}), false);
});
