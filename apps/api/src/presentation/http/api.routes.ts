import { Router } from "express";

import type { CharactersGateway } from "../../modules/characters/application/characters.gateway.js";
import type {
  EpisodeCharactersGateway,
  EpisodesGateway
} from "../../modules/episodes/application/episodes.gateway.js";
import { createCharactersRouter } from "../../modules/characters/presentation/characters.routes.js";
import { createEpisodesRouter } from "../../modules/episodes/presentation/episodes.routes.js";

export const createApiRouter = (
  gateway: CharactersGateway & EpisodesGateway & EpisodeCharactersGateway
): Router => {
  const router = Router();

  router.use("/characters", createCharactersRouter(gateway));
  router.use("/episodes", createEpisodesRouter(gateway));

  return router;
};
