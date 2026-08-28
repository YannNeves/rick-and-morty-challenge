import express from "express";

import type { AppEnv } from "./config/env.js";
import type { CharactersGateway } from "./modules/characters/application/characters.gateway.js";
import type {
  EpisodeCharactersGateway,
  EpisodesGateway
} from "./modules/episodes/application/episodes.gateway.js";
import { cors, securityHeaders } from "./presentation/http/middleware/security.js";
import { errorHandler, notFoundHandler } from "./presentation/http/middleware/error-handler.js";
import { createApiRouter } from "./presentation/http/api.routes.js";

export const createApp = (
  env: AppEnv,
  gateway: CharactersGateway & EpisodesGateway & EpisodeCharactersGateway
) => {
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

  app.use("/api/v1", createApiRouter(gateway));
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
