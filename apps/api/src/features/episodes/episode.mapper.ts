import type { RickAndMortyEpisode } from "../../integrations/rick-and-morty/types.js";
import type { EpisodeSummary } from "./episode.models.js";

export const toEpisodeSummary = (episode: RickAndMortyEpisode): EpisodeSummary => ({
  id: episode.id,
  name: episode.name,
  airDate: episode.air_date,
  code: episode.episode,
  characterCount: episode.characters.length
});
