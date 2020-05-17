CREATE TABLE "team" (
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
CREATE TABLE "user" (
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
CREATE INDEX ON "user"("email");

-->
CREATE TABLE "team_member" (
  "teamId" INTEGER NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  "userId" INTEGER NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  "role" text NOT NULL,
  PRIMARY KEY ("teamId", "userId")
);

-->
CREATE TABLE "project" (
  "teamId" INTEGER NOT NULL REFERENCES "team"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
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
CREATE INDEX ON "project"("domain");

-->
CREATE TABLE "pageview" (
  "projectId" INTEGER NOT NULL REFERENCES "project"("id") ON DELETE CASCADE,
  -- event/resource
  "id" bigserial NOT NULL PRIMARY KEY,
  "path" text NOT NULL,
  "unique" boolean NOT NULL DEFAULT false,
  "session" text,
  -- device/software
  "device" text NOT NULL DEFAULT 'unknown',
  "deviceType" text NOT NULL DEFAULT 'unknown',
  "browser" text NOT NULL DEFAULT 'unknown',
  "browserVersion" text NOT NULL DEFAULT 'unknown',
  "os" text NOT NULL DEFAULT 'unknown',
  "osVersion" text NOT NULL DEFAULT 'unknown',
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
CREATE INDEX ON "pageview"("projectId");

-->
CREATE TABLE "event" (
  "projectId" INTEGER NOT NULL REFERENCES "project"("id") ON DELETE CASCADE,
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
CREATE INDEX ON "event"("projectId");

-->
CREATE TABLE "daily_aggregate_device" (
  "projectId" INTEGER NOT NULL REFERENCES "project"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
  "date" DATE NOT NULL,
  "type" TEXT NOT NULL,
  "browser" TEXT NOT NULL,
  "browserVersion" TEXT NOT NULL,
  "os" TEXT NOT NULL,
  "osVersion" TEXT NOT NULL,
  "count" INTEGER NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id"),
  CONSTRAINT daily_aggregate_devices_device UNIQUE("projectId", "date", "type", "browser", "browserVersion", "os", "osVersion")
)

-->
CREATE INDEX ON "daily_aggregate_device"("projectId", "date");

-->
CREATE FUNCTION
  compute_daily_device_pageviews(_date DATE)
RETURNS void LANGUAGE plpgsql AS
$function$
  BEGIN
    INSERT INTO
      "daily_aggregate_device"(
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
      "deviceType" as "type",
      "browser",
      "browserVersion",
      "os",
      "osVersion",
      count("id") as "count"
    FROM
      "pageview"
    WHERE
      "pageview"."createdOn" =  _date
    GROUP BY
      "projectId", "type", "browser", "browserVersion", "os", "osVersion"
    ON CONFLICT ("projectId", "date", "type", "browser", "browserVersion", "os", "osVersion") DO
    UPDATE SET
      "count" = EXCLUDED."count",
      "createdAt" = CURRENT_TIMESTAMP
    ;
  END;
$function$

-->
CREATE TABLE "daily_aggregate_pageview" (
  "projectId" INTEGER NOT NULL REFERENCES "project"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
  "date" DATE NOT NULL,
  "path" TEXT NOT NULL,
  "count" INTEGER NOT NULL,
  "uniqueCount" INTEGER NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id"),
  CONSTRAINT daily_aggregate_pageviews_resource UNIQUE("projectId", "date", "path")
);

-->
CREATE INDEX ON "daily_aggregate_pageview"("projectId", "date");

-->
CREATE INDEX ON "daily_aggregate_pageview"("projectId", "path");

-->
-- Run pageview aggregations on the given day for all paths from all projects.
CREATE FUNCTION
  compute_daily_aggregate_pageviews(_date DATE)
RETURNS void LANGUAGE plpgsql AS
$function$
  BEGIN
    INSERT INTO
      "daily_aggregate_pageview"("projectId", "date", "path", "count", "uniqueCount")
    SELECT
      "projectId",
      _date as "date",
      "path",
      count("id") as "count",
      count("id") filter (where "unique" = true) as "uniqueCount"
    FROM
      "pageview"
    WHERE
      "pageview"."createdOn" = _date
    GROUP BY
      "projectId", "path"
    ON CONFLICT ("projectId", "date", "path") DO
    UPDATE SET
      "count" = EXCLUDED."count",
      "uniqueCount" = EXCLUDED."uniqueCount",
      "createdAt" = CURRENT_TIMESTAMP
    ;

    INSERT INTO
      "daily_aggregate_pageview"("projectId", "date", "path", "count", "uniqueCount")
    SELECT
      "projectId",
      _date as "date",
      '*' as "path",
      count("id") as "count",
      count("id") filter (where "unique" = true) as "uniqueCount"
    FROM
      "pageview"
    WHERE
      "createdOn" = _date
    GROUP BY
      "projectId"
    ON CONFLICT ("projectId", "date", "path") DO
    UPDATE SET
      "count" = EXCLUDED."count",
      "uniqueCount" = EXCLUDED."uniqueCount",
      "createdAt" = CURRENT_TIMESTAMP
    ;
  END;
$function$

-->
CREATE TABLE "daily_aggregate_referrer_pageview" (
  "projectId" INTEGER NOT NULL REFERENCES "project"("id") ON DELETE CASCADE,
  "id" SERIAL NOT NULL,
  "date" DATE NOT NULL,
  "referrerKind" TEXT NOT NULL,
  "referrer" TEXT NOT NULL,
  "path" TEXT NOT NULL,
  "count" INTEGER NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY ("id"),
  CONSTRAINT daily_aggregate_referrer_pageview_resource UNIQUE("projectId", "date", "referrerKind", "referrer", "path")
);


-->
CREATE INDEX ON "daily_aggregate_referrer_pageview"("projectId", "date");

-->
CREATE FUNCTION
  compute_daily_aggregate_referrer_pageviews(_kind TEXT, _date DATE)
RETURNS void LANGUAGE plpgsql AS
$function$
  BEGIN
    EXECUTE FORMAT(
      $sql$
        INSERT INTO
          "daily_aggregate_referrer_pageview"("projectId", "date", "referrerKind", "referrer", "path", "count")
        SELECT
          "projectId",
          $1 AS "date",
          $2 AS "referrerKind",
          %I AS "referrer",
          "path",
          count("id") AS "count"
        FROM
          "pageview"
        WHERE
          "pageview"."createdOn" = $1 AND
          %I IS NOT NULL
        GROUP BY
          "projectId", %I, "path"
        ON CONFLICT ("projectId", "date", "referrerKind", "referrer", "path") DO
        UPDATE SET
          "count" = EXCLUDED."count"
        ;
      $sql$,
      _kind, _kind, _kind
    ) USING _date, _kind;

    EXECUTE FORMAT(
      $sql$
        INSERT INTO
          "daily_aggregate_referrer_pageview"("projectId", "date", "referrerKind", "referrer", "path", "count")
        SELECT
          "projectId",
          $1 AS "date",
          $2 AS "referrerKind",
          %I AS "referrer",
          '*' AS "path",
          count("id") AS "count"
        FROM
          "pageview"
        WHERE
          "pageview"."createdOn" = $1 AND
          %I IS NOT NULL
        GROUP BY
          "projectId", %I
        ON CONFLICT ("projectId", "date", "referrerKind", "referrer", "path") DO
        UPDATE SET
          "count" = EXCLUDED."count"
        ;
      $sql$,
      _kind, _kind, _kind
    ) USING _date, _kind;
  END;
$function$
