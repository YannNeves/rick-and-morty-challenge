export class AppError extends Error {
  constructor(
    message: string,
    readonly statusCode: number,
    readonly code: string,
    readonly details?: unknown
  ) {
    super(message);
    this.name = "AppError";
  }
}

export const badRequest = (message: string, details?: unknown): AppError =>
  new AppError(message, 400, "BAD_REQUEST", details);

export const notFound = (message: string, details?: unknown): AppError =>
  new AppError(message, 404, "NOT_FOUND", details);

export const upstreamError = (message: string, details?: unknown): AppError =>
  new AppError(message, 502, "UPSTREAM_ERROR", details);
