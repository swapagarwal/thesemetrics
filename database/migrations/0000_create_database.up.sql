CREATE TABLE "team" (
  "id" serial NOT NULL,
  "type" character varying NOT NULL,
  "name" character varying NOT NULL,
  "createdAt" time with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" time with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE TABLE "user" (
  "id" serial NOT NULL,
  "username" character varying NOT NULL,
  "password" character varying NOT NULL,
  "createdAt" time with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" time with time zone NOT NULL DEFAULT current_timestamp,
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
  "id" integer NOT NULL,
  "name" character varying NOT NULL,
  "type" character varying NOT NULL,
  "domain" character varying,
  "createdAt" time with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" time with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE TABLE "event" (
  "projectId" integer NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  -- event/resource
  "id" serial NOT NULL,
  "type" character varying NOT NULL,
  "name" character varying NOT NULL,
  "resource" character varying NOT NULL,
  "source" character varying,
  -- device
  "device" character varying,
  "deviceType" character varying,
  "screenSize" integer,
  "browser" character varying,
  "browserVersion" character varying,
  "os" character varying,
  "osVersion" character varying,
  -- geo
  "city" character varying,
  "country" character varying,
  -- time
  "userTimeZone" character varying,
  "userTimestamp" timestamp without time zone,
  -- extra
  "batchId" character varying,
  "data" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);