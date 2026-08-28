import type { Request, Response } from "express";

import { parseOptionalString, parsePositiveInt } from "../../../presentation/http/query-parsers.js";
import type { LocationService } from "../application/location.service.js";

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
}
