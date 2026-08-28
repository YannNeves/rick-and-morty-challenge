import type { NextFunction, Request, Response } from "express";

import type { AppEnv } from "../../../config/env.js";

export const securityHeaders =
  () => (_req: Request, res: Response, next: NextFunction): void => {
    res.setHeader("X-Content-Type-Options", "nosniff");
    res.setHeader("X-Frame-Options", "DENY");
    res.setHeader("Referrer-Policy", "no-referrer");
    next();
  };

export const cors =
  (env: AppEnv) => (req: Request, res: Response, next: NextFunction): void => {
    const origin = req.header("origin");
    const allowAnyOrigin = env.allowedOrigins.includes("*");

    if (allowAnyOrigin) {
      res.setHeader("Access-Control-Allow-Origin", "*");
    } else if (origin && env.allowedOrigins.includes(origin)) {
      res.setHeader("Access-Control-Allow-Origin", origin);
      res.setHeader("Vary", "Origin");
    }

    res.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.sendStatus(204);
      return;
    }

    next();
  };
