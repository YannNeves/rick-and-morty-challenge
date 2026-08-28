import type { Request, Response } from "express";

import type { CharacterService } from "../application/character.service.js";
import { CHARACTER_BATCH_LIMIT } from "../domain/character.models.js";
import {
  parseCharacterGender,
  parseCharacterStatus,
  parseIdList,
  parseOptionalString,
  parsePositiveInt
} from "../../../presentation/http/query-parsers.js";

export class CharactersController {
  constructor(private readonly characterService: CharacterService) {}

  list = async (req: Request, res: Response): Promise<void> => {
    const page = req.query.page ? parsePositiveInt(req.query.page, "page") : 1;
    const name = parseOptionalString(req.query.name);
    const status = parseCharacterStatus(req.query.status);
    const species = parseOptionalString(req.query.species);
    const type = parseOptionalString(req.query.type);
    const gender = parseCharacterGender(req.query.gender);
    const result = await this.characterService.listCharacters({
      page,
      ...(name ? { name } : {}),
      ...(status ? { status } : {}),
      ...(species ? { species } : {}),
      ...(type ? { type } : {}),
      ...(gender ? { gender } : {})
    });

    res.json(result);
  };

  details = async (req: Request, res: Response): Promise<void> => {
    const id = parsePositiveInt(req.params.id, "id");
    res.json(await this.characterService.getCharacterDetails(id));
  };

  all = async (_req: Request, res: Response): Promise<void> => {
    res.json({ characters: await this.characterService.listAllCharacters() });
  };

  batch = async (req: Request, res: Response): Promise<void> => {
    const ids = parseIdList(req.query.ids, "ids", CHARACTER_BATCH_LIMIT);
    res.json({
      characters: await this.characterService.getCharactersBatch(ids)
    });
  };
}
