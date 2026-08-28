import type { RickAndMortyEpisode } from "./types.js";
import type { Episode } from "../../modules/episodes/domain/episode.models.js";
import { extractIdsFromUrls } from "./url-utils.js";

export const toEpisode = (episode: RickAndMortyEpisode): Episode => ({
  id: episode.id,
  name: episode.name,
  airDate: episode.air_date,
  code: episode.episode,
  characterCount: episode.characters.length,
  characterIds: extractIdsFromUrls(episode.characters)
});
