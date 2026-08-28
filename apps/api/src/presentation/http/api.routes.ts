import { Router } from "express";

import type { CharactersGateway } from "../../modules/characters/application/characters.gateway.js";
import type {
  EpisodeCharactersGateway,
  EpisodesGateway
} from "../../modules/episodes/application/episodes.gateway.js";
import { createCharactersRouter } from "../../modules/characters/presentation/characters.routes.js";
import { createEpisodesRouter } from "../../modules/episodes/presentation/episodes.routes.js";
import type { LocationsGateway } from "../../modules/locations/application/locations.gateway.js";
import { createLocationsRouter } from "../../modules/locations/presentation/locations.routes.js";

export const createApiRouter = (
  gateway: CharactersGateway & EpisodesGateway & EpisodeCharactersGateway & LocationsGateway
): Router => {
  const router = Router();

  router.use("/characters", createCharactersRouter(gateway));
  router.use("/episodes", createEpisodesRouter(gateway));
  router.use("/locations", createLocationsRouter(gateway));

  return router;
};
