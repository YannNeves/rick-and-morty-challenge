export const mapWithConcurrency = async <Input, Output>(
  items: readonly Input[],
  concurrency: number,
  mapper: (item: Input, index: number) => Promise<Output>
): Promise<Output[]> => {
  if (!Number.isInteger(concurrency) || concurrency <= 0) {
    throw new RangeError("Concurrency must be a positive integer");
  }

  const results = Array.from<Output>({ length: items.length });
  let nextIndex = 0;

  const worker = async (): Promise<void> => {
    while (nextIndex < items.length) {
      const index = nextIndex;
      nextIndex += 1;
      results[index] = await mapper(items[index] as Input, index);
    }
  };

  await Promise.all(
    Array.from({ length: Math.min(concurrency, items.length) }, worker)
  );

  return results;
};
