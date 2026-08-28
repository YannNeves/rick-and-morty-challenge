import type { Request, Response } from "express";

import type { EpisodeService } from "../application/episode.service.js";
import {
  parseCharacterSortField,
  parseOptionalString,
  parsePositiveInt,
  parseSortOrder
} from "../../../presentation/http/query-parsers.js";

export class EpisodesController {
  constructor(private readonly episodeService: EpisodeService) {}

  list = async (req: Request, res: Response): Promise<void> => {
    const page = req.query.page ? parsePositiveInt(req.query.page, "page") : 1;
    const name = parseOptionalString(req.query.name);
    const episode = parseOptionalString(req.query.episode);
    const result = await this.episodeService.listEpisodes({
      page,
      ...(name ? { name } : {}),
      ...(episode ? { episode } : {})
    });

    res.json(result);
  };

  details = async (req: Request, res: Response): Promise<void> => {
    const id = parsePositiveInt(req.params.id, "id");
    const sortCharactersBy = parseCharacterSortField(req.query.sortCharactersBy);
    const characterOrder = parseSortOrder(req.query.characterOrder);
    const result = await this.episodeService.getEpisodeDetails(id, {
      ...(sortCharactersBy ? { sortCharactersBy } : {}),
      ...(characterOrder ? { characterOrder } : {})
    });

    res.json(result);
  };
}
