import { Router } from "express";

import { AnalyticsService } from "../features/analytics/analytics.service.js";
import { EpisodeService } from "../features/episodes/episode.service.js";
import type { RickAndMortyGateway } from "../integrations/rick-and-morty/types.js";
import { asyncHandler } from "../shared/http/async-handler.js";
import { AnalyticsController } from "./analytics.controller.js";
import { EpisodesController } from "./episodes.controller.js";

export const createRouter = (gateway: RickAndMortyGateway): Router => {
  const router = Router();
  const episodesController = new EpisodesController(new EpisodeService(gateway));
  const analyticsController = new AnalyticsController(new AnalyticsService());

  router.get("/episodes", asyncHandler(episodesController.list));
  router.get("/episodes/:id", asyncHandler(episodesController.details));
  router.post("/analytics/events", asyncHandler(analyticsController.track));
  router.get("/analytics/events", asyncHandler(analyticsController.snapshot));

  return router;
};
