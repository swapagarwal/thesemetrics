CREATE TABLE "team" (
  "id" serial NOT NULL,
  "type" text NOT NULL,
  "name" text NOT NULL,
  "email" text NOT NULL UNIQUE,
  "plan" text NOT NULL DEFAULT 'free',
  "stripe" text,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

-->
CREATE TABLE "user" (
  "id" serial NOT NULL,
  "name" text NOT NULL,
  "email" text NOT NULL UNIQUE,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  "lastLoginAt" timestamp with time zone DEFAULT NULL,
  PRIMARY KEY ("id")
);

-->
CREATE TABLE "team_member" (
  "teamId" integer NOT NULL REFERENCES "team"("id") ON
  DELETE
    CASCADE,
    "userId" integer NOT NULL REFERENCES "user"("id") ON
  DELETE
    CASCADE,
    "role" text NOT NULL,
    PRIMARY KEY ("teamId", "userId")
);

-->
CREATE TABLE "project" (
  "teamId" integer NOT NULL REFERENCES "team"("id") ON
  DELETE
    CASCADE,
    "id" serial NOT NULL,
    "name" text NOT NULL,
    "type" text NOT NULL,
    "domain" text NOT NULL UNIQUE,
    "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
    "createdAt" time with time zone NOT NULL DEFAULT current_timestamp,
    "updatedAt" time with time zone NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY ("id")
);

-->
CREATE INDEX ON "project"("teamId");

-->
CREATE TABLE "event" (
  "projectId" integer NOT NULL REFERENCES "project"("id") ON
  DELETE
    CASCADE,
    -- event/resource
    "id" serial NOT NULL,
    "name" text NOT NULL,
    "resource" text NOT NULL,
    "batch" text,
    "unique" boolean NOT NULL DEFAULT false,
    -- device/software
    "screenSize" integer NOT NULL DEFAULT 0,
    "device" text NOT NULL DEFAULT 'Other',
    "browser" text NOT NULL DEFAULT 'Other',
    "browserVersion" text NOT NULL DEFAULT 'Other',
    "os" text NOT NULL DEFAULT 'Other',
    "osVersion" text NOT NULL DEFAULT 'Other',
    -- utm/source
    "source" text,
    "medium" text,
    "campaign" text,
    "referrer" text,
    -- geo/time
    "country" text,
    "timeZone" text,
    "timestamp" timestamp without time zone,
    -- extra
    "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
    "createdOn" date DEFAULT current_date,
    "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY ("id")
);

-->
CREATE INDEX ON "event"("projectId");

-->
CREATE TABLE "daily_aggregated_event" (
  "projectId" integer NOT NULL REFERENCES "project"("id") ON
  DELETE
    CASCADE,
    -- event/resource
    "id" serial NOT NULL,
    "date" date NOT NULL,
    "kind" text NOT NULL,
    "value" text NOT NULL,
    "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
    "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY ("id"),
    UNIQUE ("projectId", "date", "kind", "value")
);

-->
CREATE INDEX ON "daily_aggregated_event"("projectId");

-->
CREATE TABLE "weekly_aggregated_event" (
  "projectId" integer NOT NULL REFERENCES "project"("id") ON
  DELETE
    CASCADE,
    -- event/resource
    "id" serial NOT NULL,
    "date" date NOT NULL,
    "kind" text NOT NULL,
    "value" text NOT NULL,
    "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
    "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY ("id"),
    UNIQUE ("projectId", "date", "kind", "value")
);

-->
CREATE INDEX ON "weekly_aggregated_event"("projectId");

-->
CREATE TABLE "aggregated_event" (
  "projectId" integer NOT NULL REFERENCES "project"("id") ON
  DELETE
    CASCADE,
    -- event/resource
    "id" serial NOT NULL,
    "kind" text NOT NULL,
    "value" text NOT NULL,
    "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
    "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY ("id"),
    UNIQUE ("projectId", "kind", "value")
);

-->
CREATE INDEX ON "aggregated_event"("projectId");

-->
CREATE TABLE "execution" (
  "id" serial NOT NULL,
  "name" text NOT NULL UNIQUE,
  "lastExecutionAt" timestamp with time zone NOT NULL,
  PRIMARY KEY("id")
);
