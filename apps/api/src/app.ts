import express from "express";

import type { AppEnv } from "./config/env.js";
import type { RickAndMortyGateway } from "./integrations/rick-and-morty/types.js";
import { cors, securityHeaders } from "./shared/http/security.js";
import { errorHandler, notFoundHandler } from "./shared/http/error-handler.js";
import { createRouter } from "./http/routes.js";

export const createApp = (env: AppEnv, gateway: RickAndMortyGateway) => {
  const app = express();

  app.disable("x-powered-by");
  app.use(express.json({ limit: "64kb" }));
  app.use(securityHeaders());
  app.use(cors(env));

  app.get("/health", (_req, res) => {
    res.json({
      status: "ok",
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    });
  });

  app.use("/api/v1", createRouter(gateway));
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
