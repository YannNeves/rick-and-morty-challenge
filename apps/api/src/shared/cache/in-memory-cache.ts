type CacheEntry<T> = {
  expiresAt: number;
  value: T;
};

export class InMemoryCache<T> {
  private readonly entries = new Map<string, CacheEntry<T>>();

  constructor(private readonly ttlMs: number) {}

  get(key: string): T | undefined {
    const entry = this.entries.get(key);

    if (!entry) {
      return undefined;
    }

    if (entry.expiresAt <= Date.now()) {
      this.entries.delete(key);
      return undefined;
    }

    return entry.value;
  }

  set(key: string, value: T): void {
    this.entries.set(key, {
      expiresAt: Date.now() + this.ttlMs,
      value
    });
  }

  clear(): void {
    this.entries.clear();
  }
}
