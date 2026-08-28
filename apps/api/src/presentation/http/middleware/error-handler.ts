import type { NextFunction, Request, Response } from "express";

import { AppError } from "../../../shared/errors/app-error.js";

export const notFoundHandler = (req: Request, _res: Response): never => {
  throw new AppError(`Route ${req.method} ${req.path} not found`, 404, "ROUTE_NOT_FOUND");
};

export const errorHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction
): void => {
  if (error instanceof AppError) {
    res.status(error.statusCode).json({
      error: {
        code: error.code,
        message: error.message,
        details: error.details
      }
    });
    return;
  }

  console.error(error);

  res.status(500).json({
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "Unexpected server error"
    }
  });
};
