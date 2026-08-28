import { Router } from "express";

import { asyncHandler } from "../../../presentation/http/async-handler.js";
import { LocationService } from "../application/location.service.js";
import type { LocationsGateway } from "../application/locations.gateway.js";
import { LocationsController } from "./locations.controller.js";

export const createLocationsRouter = (gateway: LocationsGateway): Router => {
  const router = Router();
  const controller = new LocationsController(new LocationService(gateway));

  router.get("/", asyncHandler(controller.list));

  return router;
};
