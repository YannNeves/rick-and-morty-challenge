import type { Location } from "../../modules/locations/domain/location.models.js";
import type { RickAndMortyLocation } from "./types.js";
import { extractIdsFromUrls } from "./url-utils.js";

export const toLocation = (location: RickAndMortyLocation): Location => ({
  id: location.id,
  name: location.name,
  type: location.type,
  dimension: location.dimension,
  residentCount: location.residents.length,
  residentIds: extractIdsFromUrls(location.residents)
});
