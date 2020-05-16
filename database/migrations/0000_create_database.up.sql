CREATE TABLE "teams" (
  "id" SERIAL NOT NULL,
  "type" text NOT NULL,
  "name" text NOT NULL,
  "email" text NOT NULL UNIQUE,
  "plan" text NOT NULL DEFAULT 'free',
  "stripe" text,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

-->
CREATE TABLE "users" (
  "id" SERIAL NOT NULL,
  "name" text NOT NULL,
  "email" text NOT NULL UNIQUE,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  "lastLoginAt" TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  PRIMARY KEY ("id")
);

-->
CREATE TABLE "team_member" (
  "teamId" INTEGER NOT NULL REFERENCES "teams"("id") ON DELETE CASCADE,
  "userId" INTEGER NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "role" text NOT NULL,
  PRIMARY KEY ("teamId", "userId")
);

-->
CREATE TABLE "projects" (
  "teamId" INTEGER NOT NULL REFERENCES "teams"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
  "name" text NOT NULL,
  "type" text NOT NULL,
  "domain" text NOT NULL UNIQUE,
  "preferences" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdAt" time with time zone NOT NULL DEFAULT current_timestamp,
  "updatedAt" time with time zone NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

CREATE INDEX ON "projects"("teamId");

-->
CREATE TABLE "pageviews" (
  "projectId" INTEGER NOT NULL REFERENCES "projects"("id") ON DELETE CASCADE,
  -- event/resource
  "id" bigserial NOT NULL PRIMARY KEY,
  "path" text NOT NULL,
  "unique" boolean NOT NULL DEFAULT false,
  "session" text,
  -- device/software
  "device" text NOT NULL DEFAULT 'Other',
  "browser" text NOT NULL DEFAULT 'Other',
  "browserVersion" text NOT NULL DEFAULT 'Other',
  "os" text NOT NULL DEFAULT 'Other',
  "osVersion" text NOT NULL DEFAULT 'Other',
  "screenSize" INTEGER NOT NULL DEFAULT 0,
  -- utm/source
  "source" text,
  "medium" text,
  "campaign" text,
  "referrer" text,
  -- geo/time
  "country" text,
  "timezone" text,
  "timestamp" timestamp without time zone,
  -- extra
  "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdOn" date DEFAULT current_date,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp
);

-->
CREATE INDEX ON "pageviews"("projectId");

-->
CREATE TABLE "events" (
  "projectId" INTEGER NOT NULL REFERENCES "projects"("id") ON DELETE CASCADE,
  -- event/resource
  "id" SERIAL NOT NULL,
  "name" text NOT NULL,
  "path" text NOT NULL,
  "session" text,
  -- user timestamp
  "timestamp" timestamp without time zone,
  -- extra
  "data" jsonb NOT NULL DEFAULT '{}' :: jsonb,
  "createdOn" date DEFAULT current_date,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id")
);

-->
CREATE INDEX ON "events"("projectId");

-->
CREATE TABLE "daily_aggregate_devices" (
  "projectId" INTEGER NOT NULL REFERENCES "projects"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
  "date" DATE NOT NULL,
  "type" TEXT NOT NULL,
  "browser" TEXT NOT NULL,
  "browserVersion" TEXT NOT NULL,
  "os" TEXT NOT NULL,
  "osVersion" TEXT NOT NULL,
  "count" INTEGER NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT daily_aggregate_devices_device UNIQUE("projectId", "date", "type", "browser", "browserVersion", "os", "osVersion")
)

-->
CREATE INDEX ON "daily_aggregate_devices"("projectId");

-->
CREATE FUNCTION
  compute_daily_device_pageviews(_date DATE)
RETURNS void LANGUAGE plpgsql AS
$function$
  BEGIN
    INSERT INTO
      "daily_aggregate_devices"(
        "projectId", 
        "date", 
        "type", 
        "browser", 
        "browserVersion", 
        "os", 
        "osVersion", 
        "count"
      )
    SELECT
      "projectId",
      _date as "date",
      "device" as "type",
      "browser",
      "browserVersion",
      "os",
      "osVersion",
      count("id") as "count"
    FROM
      "pageviews"
    WHERE
      "pageviews"."createdOn" =  _date
    GROUP BY
      "projectId", "type", "browser", "browserVersion", "os", "osVersion"
    ON CONFLICT ("projectId", "date", "type", "browser", "browserVersion", "os", "osVersion") DO
    UPDATE SET
      "count" = EXCLUDED."count"
    ;
  END;
$function$

-->
CREATE TABLE "daily_aggregate_pageviews" (
  "projectId" INTEGER NOT NULL REFERENCES "projects"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
  "date" DATE NOT NULL,
  "path" TEXT NOT NULL,
  "pageviews" INTEGER NOT NULL,
  "uniquePageviews" INTEGER NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id"),
  CONSTRAINT daily_aggregate_pageviews_resoruce UNIQUE("projectId", "date", "path")
);

-->
-- Run pageview aggregations on the given day for all paths from all projects.
CREATE FUNCTION
  compute_daily_aggregate_pageviews(_date DATE)
RETURNS void LANGUAGE plpgsql AS
$function$
  BEGIN
    INSERT INTO
      "daily_aggregate_pageviews"("projectId", "date", "path", "pageviews", "uniquePageviews")
    SELECT
      "projectId",
      _date as "date",
      "path",
      count("id") as "pageviews",
      count("id") filter (where "unique" = true) as "uniquePageviews"
    FROM
      "pageviews"
    WHERE
      "pageviews"."createdOn" = _date
    GROUP BY
      "projectId", "path"
    ON CONFLICT ("projectId", "date", "path") DO
    UPDATE SET
      "pageviews" = EXCLUDED."pageviews",
      "uniquePageviews" = EXCLUDED."uniquePageviews"
    ;

    INSERT INTO
      "daily_aggregate_pageviews"("projectId", "date", "path", "pageviews", "uniquePageviews")
    SELECT
      "projectId",
      _date as "date",
      '*' as "path",
      count("id") as "pageviews",
      count("id") filter (where "unique" = true) as "uniquePageviews"
    FROM
      "pageviews"
    WHERE
      "createdOn" = _date
    GROUP BY
      "projectId"
    ON CONFLICT ("projectId", "date", "path") DO
    UPDATE SET
      "pageviews" = EXCLUDED."pageviews",
      "uniquePageviews" = EXCLUDED."uniquePageviews"
    ;
  END;
$function$
