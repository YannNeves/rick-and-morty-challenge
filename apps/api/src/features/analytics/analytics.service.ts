export type AnalyticsEventName =
  | "app_opened"
  | "episode_list_viewed"
  | "episode_details_viewed"
  | "character_sort_changed";

export type AnalyticsEvent = {
  name: AnalyticsEventName;
  properties?: Record<string, string | number | boolean | null>;
  occurredAt: string;
};

export class AnalyticsService {
  private readonly events: AnalyticsEvent[] = [];

  track(event: Omit<AnalyticsEvent, "occurredAt">): AnalyticsEvent {
    const created: AnalyticsEvent = {
      ...event,
      occurredAt: new Date().toISOString()
    };

    this.events.push(created);
    console.info("analytics_event", created);

    return created;
  }

  getSnapshot(): AnalyticsEvent[] {
    return [...this.events];
  }
}
