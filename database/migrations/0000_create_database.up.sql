CREATE TABLE "team" (
  "id" serial NOT NULL,
  "type" character varying NOT NULL,
  "name" character varying NOT NULL,
  "email" character varying NOT NULL UNIQUE,
  "plan" character varying NOT NULL DEFAULT 'free',
  "stripe" character varying,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE TABLE "user" (
  "id" serial NOT NULL,
  "name" character varying NOT NULL,
  "email" character varying NOT NULL UNIQUE,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  "lastLoginAt" timestamp with time zone DEFAULT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE "team_member" (
  "teamId" integer NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  "userId" integer NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  "role" character varying NOT NULL,
  PRIMARY KEY ("teamId", "userId")
);

CREATE TABLE "project" (
  "teamId" integer NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  "id" serial NOT NULL,
  "name" character varying NOT NULL,
  "type" character varying NOT NULL,
  "domain" character varying NOT NULL UNIQUE,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" time with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" time with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE TABLE "event" (
  "projectId" integer NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  -- event/resource
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "name" character varying NOT NULL,
  "resource" character varying NOT NULL,
  "batch" character varying,
  "unique" boolean NOT NULL DEFAULT false,
  -- device/software
  "screenSize" integer NOT NULL DEFAULT 0,
  "device" character varying NOT NULL DEFAULT 'Other',
  "browser" character varying NOT NULL DEFAULT 'Other',
  "browserVersion" character varying NOT NULL DEFAULT 'Other',
  "os" character varying NOT NULL DEFAULT 'Other',
  "osVersion" character varying NOT NULL DEFAULT 'Other',
  -- utm/source
  "source" character varying,
  "medium" character varying,
  "campaign" character varying,
  "referrer" character varying,
  -- geo/time
  "country" character varying,
  "timeZone" character varying,
  "timestamp" timestamp without time zone,
  -- extra
  "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE TABLE "daily_aggregated_event" (
  "projectId" integer NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  -- event/resource
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "date" date NOT NULL,
  "kind" character varying NOT NULL,
  "value" character varying NOT NULL,
  "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE TABLE "weekly_aggregated_event" (
  "projectId" integer NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  -- event/resource
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "date" date NOT NULL,
  "kind" character varying NOT NULL,
  "value" character varying NOT NULL,
  "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);
