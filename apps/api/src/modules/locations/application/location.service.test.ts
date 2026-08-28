import assert from "node:assert/strict";
import test from "node:test";

import { AppError } from "../../../shared/errors/app-error.js";
import type { CharacterSummary } from "../../characters/domain/character.models.js";
import type { Location, LocationListFilters, LocationPage } from "../domain/location.models.js";
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

  async getLocation(): Promise<Location> {
    return { id: 3, name: "Citadel of Ricks", type: "Space station", dimension: "unknown", residentCount: 2, residentIds: [2, 1] };
  }

  async getCharacters(ids: number[]): Promise<CharacterSummary[]> {
    return ids.map((id) => ({ id, name: id === 1 ? "Rick Sanchez" : "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", image: "", origin: "Earth", location: "Citadel", episodeCount: 1 }));
  }
}

test("listLocations delegates filters and hides internal resident ids", async () => {
  const gateway = new FakeGateway();
  const filters = { page: 1, name: "citadel", type: "station", dimension: "unknown" };
  const result = await new LocationService(gateway, gateway).listLocations(filters);

  assert.deepEqual(gateway.filters, filters);
  assert.equal(result.totalItems, 126);
  assert.equal(result.locations[0]?.residentCount, 2);
  assert.equal("residentIds" in (result.locations[0] ?? {}), false);
});

test("getLocationDetails expands and sorts residents by name", async () => {
  const gateway = new FakeGateway();
  const result = await new LocationService(gateway, gateway).getLocationDetails(3);

  assert.deepEqual(result.residents.map((resident) => resident.name), ["Morty Smith", "Rick Sanchez"]);
  assert.equal("residentIds" in result, false);
});

test("getLocationDetails supports empty locations", async () => {
  const gateway = new FakeGateway();
  gateway.getLocation = async () => ({ id: 1, name: "Empty", type: "Planet", dimension: "unknown", residentCount: 0, residentIds: [] });

  const result = await new LocationService(gateway, gateway).getLocationDetails(1);
  assert.deepEqual(result.residents, []);
});

test("getLocationDetails rejects invalid ids", async () => {
  const gateway = new FakeGateway();
  await assert.rejects(new LocationService(gateway, gateway).getLocationDetails(0), AppError);
});
