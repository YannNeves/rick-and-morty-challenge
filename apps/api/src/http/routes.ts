import { Router } from "express";

import { AnalyticsService } from "../features/analytics/analytics.service.js";
import { EpisodeService } from "../features/episodes/episode.service.js";
import { CharacterService } from "../features/characters/character.service.js";
import type {
  CharactersGateway,
  RickAndMortyGateway
} from "../integrations/rick-and-morty/types.js";
import { asyncHandler } from "../shared/http/async-handler.js";
import { AnalyticsController } from "./analytics.controller.js";
import { EpisodesController } from "./episodes.controller.js";
import { CharactersController } from "./characters.controller.js";

export const createRouter = (
  gateway: RickAndMortyGateway & CharactersGateway
): Router => {
  const router = Router();
  const episodesController = new EpisodesController(new EpisodeService(gateway));
  const analyticsController = new AnalyticsController(new AnalyticsService());
  const charactersController = new CharactersController(new CharacterService(gateway));

  router.get("/characters", asyncHandler(charactersController.list));
  router.get("/characters/batch", asyncHandler(charactersController.batch));
  router.get("/characters/:id", asyncHandler(charactersController.details));
  router.get("/episodes", asyncHandler(episodesController.list));
  router.get("/episodes/:id", asyncHandler(episodesController.details));
  router.post("/analytics/events", asyncHandler(analyticsController.track));
  router.get("/analytics/events", asyncHandler(analyticsController.snapshot));

  return router;
};
