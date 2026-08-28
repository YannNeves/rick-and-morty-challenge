import type { Request, Response } from "express";

import { parseIdList, parseOptionalString, parsePositiveInt } from "../../../presentation/http/query-parsers.js";
import type { LocationService } from "../application/location.service.js";
import { LOCATION_BATCH_LIMIT } from "../domain/location.models.js";

export class LocationsController {
  constructor(private readonly service: LocationService) {}

  list = async (req: Request, res: Response): Promise<void> => {
    const page = req.query.page ? parsePositiveInt(req.query.page, "page") : 1;
    const name = parseOptionalString(req.query.name);
    const type = parseOptionalString(req.query.type);
    const dimension = parseOptionalString(req.query.dimension);

    res.json(await this.service.listLocations({
      page,
      ...(name ? { name } : {}),
      ...(type ? { type } : {}),
      ...(dimension ? { dimension } : {})
    }));
  };

  details = async (req: Request, res: Response): Promise<void> => {
    const id = parsePositiveInt(req.params.id, "id");
    res.json(await this.service.getLocationDetails(id));
  };

  batch = async (req: Request, res: Response): Promise<void> => {
    const ids = parseIdList(req.query.ids, "ids", LOCATION_BATCH_LIMIT);
    res.json({ locations: await this.service.getLocationsBatch(ids) });
  };
}
