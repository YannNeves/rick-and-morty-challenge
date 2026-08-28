import { Router } from "express";

import { asyncHandler } from "../../../presentation/http/async-handler.js";
import { LocationService } from "../application/location.service.js";
import type { LocationCharactersGateway, LocationsGateway } from "../application/locations.gateway.js";
import { LocationsController } from "./locations.controller.js";

export const createLocationsRouter = (gateway: LocationsGateway & LocationCharactersGateway): Router => {
  const router = Router();
  const controller = new LocationsController(new LocationService(gateway, gateway));

  router.get("/", asyncHandler(controller.list));
  router.get("/all", asyncHandler(controller.all));
  router.get("/batch", asyncHandler(controller.batch));
  router.get("/:id", asyncHandler(controller.details));

  return router;
};
