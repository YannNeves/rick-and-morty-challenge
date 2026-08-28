import { Router } from "express";

import type {
  EpisodeCharactersGateway,
  EpisodesGateway
} from "../application/episodes.gateway.js";
import { asyncHandler } from "../../../presentation/http/async-handler.js";
import { EpisodeService } from "../application/episode.service.js";
import { EpisodesController } from "./episodes.controller.js";

export const createEpisodesRouter = (
  gateway: EpisodesGateway & EpisodeCharactersGateway
): Router => {
  const router = Router();
  const controller = new EpisodesController(new EpisodeService(gateway, gateway));

  router.get("/", asyncHandler(controller.list));
  router.get("/all", asyncHandler(controller.all));
  router.get("/batch", asyncHandler(controller.batch));
  router.get("/:id", asyncHandler(controller.details));

  return router;
};
