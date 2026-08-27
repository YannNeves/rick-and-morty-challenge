import type { Request, Response } from "express";

import { badRequest } from "../errors/app-error.js";
import type {
  AnalyticsEventName,
  AnalyticsService
} from "../features/analytics/analytics.service.js";

const acceptedEvents = new Set<AnalyticsEventName>([
  "app_opened",
  "episode_list_viewed",
  "episode_details_viewed",
  "character_sort_changed"
]);

export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  track = async (req: Request, res: Response): Promise<void> => {
    const { name, properties } = req.body as {
      name?: string;
      properties?: Record<string, string | number | boolean | null>;
    };

    if (!name || !acceptedEvents.has(name as AnalyticsEventName)) {
      throw badRequest("Analytics event name is invalid", {
        acceptedValues: [...acceptedEvents]
      });
    }

    const event = this.analyticsService.track({
      name: name as AnalyticsEventName,
      ...(properties ? { properties } : {})
    });

    res.status(202).json(event);
  };

  snapshot = async (_req: Request, res: Response): Promise<void> => {
    res.json({
      events: this.analyticsService.getSnapshot()
    });
  };
}
