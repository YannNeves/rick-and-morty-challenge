import { Router } from "express";

import type { CharactersGateway } from "../application/characters.gateway.js";
import { asyncHandler } from "../../../presentation/http/async-handler.js";
import { CharacterService } from "../application/character.service.js";
import { CharactersController } from "./characters.controller.js";

export const createCharactersRouter = (gateway: CharactersGateway): Router => {
  const router = Router();
  const controller = new CharactersController(new CharacterService(gateway));

  router.get("/", asyncHandler(controller.list));
  router.get("/all", asyncHandler(controller.all));
  router.get("/batch", asyncHandler(controller.batch));
  router.get("/:id", asyncHandler(controller.details));

  return router;
};
