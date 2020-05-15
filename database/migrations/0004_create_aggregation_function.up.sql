--> -- Aggregate page views.
CREATE FUNCTION compute_total_page_views()
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_page_views';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_page_views', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

      -- TODO: Maybe clear old aggregation if start is null.

    INSERT INTO
      "aggregated_event" ("projectId", "kind", "value", "data")
    SELECT
      "projectId",
      'page_views' AS "kind",
      'total' AS "value",
      jsonb_build_object('count', count("id")) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageview' AND (_start IS NULL OR "createdAt" BETWEEN _start AND _end)
    GROUP BY
      "projectId"
    ON CONFLICT ("projectId", "kind", "value") 
      DO UPDATE SET "data" = jsonb_build_object(
        'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer
      );
  END;
$function$;

--> -- Aggregate unique page views.
CREATE FUNCTION compute_total_unique_page_views()
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_unique_page_views';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_unique_page_views', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    INSERT INTO
      "aggregated_event" ("projectId", "kind", "value", "data")
    SELECT
      "projectId",
      'unique_page_views' AS "kind",
      'total' AS "value",
      jsonb_build_object('count', count("id")) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageview' AND (_start IS NULL OR "createdAt" BETWEEN _start AND _end) AND "unique" = TRUE
    GROUP BY
      "projectId"
    ON CONFLICT ("projectId", "kind", "value") 
      DO UPDATE SET "data" = jsonb_build_object(
        'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer
      );
  END;
$function$;

--> -- Aggregate page views by _column.
CREATE FUNCTION compute_page_views(_column TEXT)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_'||_column||'_page_views';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_'||_column||'_page_views', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    EXECUTE FORMAT(
      $$
        INSERT INTO
          "aggregated_event" ("projectId", "kind", "value", "data")
        SELECT
          "projectId",
            %L || '_page_views' AS "kind",
            %I AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND ($1 IS NULL OR "createdAt" BETWEEN $1 AND $2) AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "kind", "value") 
          DO UPDATE SET "data" = jsonb_build_object(
            'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer
          );
      $$, _column, _column, _column, _column) 
    USING _start, _end;
  END;
$function$;

--> -- Aggregate page views by _column.
CREATE FUNCTION compute_unique_page_views(_column TEXT)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_'||_column||'_unique_page_views';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_'||_column||'_unique_page_views', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    EXECUTE FORMAT(
      $$
        INSERT INTO
          "aggregated_event" ("projectId", "kind", "value", "data")
        SELECT
          "projectId",
            %L || '_unique_page_views' AS "kind",
            %I AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND ($1 IS NULL OR "createdAt" BETWEEN $1 AND $2) AND "unique" = TRUE AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "kind", "value") 
          DO UPDATE SET "data" = jsonb_build_object(
            'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer
          );
      $$, _column, _column, _column, _column) 
    USING _start, _end;
  END;
$function$;

--> -- Aggregate page views by hour.
CREATE FUNCTION compute_total_page_views_by_hour()
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone;
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_page_views_by_hour';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_page_views_by_hour', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    INSERT INTO
      "aggregated_event" ("projectId", "kind", "value", "data")
    SELECT
      "projectId",
      'page_views_at_' || extract(hour from "timestamp")::integer AS "kind",
      'total' AS "value",
      jsonb_build_object('count', count("id")) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageview' AND (_start IS NULL OR "createdAt" BETWEEN _start AND _end) AND "timestamp" IS NOT NULL
    GROUP BY
      "projectId",
      extract(hour from "timestamp")
    ON CONFLICT ("projectId", "kind", "value") 
      DO UPDATE SET "data" = jsonb_build_object(
        'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer
      );
  END;
$function$;

--> -- Aggregate unique page views by hour.
CREATE FUNCTION compute_total_unique_page_views_by_hour()
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_unique_page_views_by_hour';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_unique_page_views_by_hour', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    INSERT INTO
      "aggregated_event" ("projectId", "kind", "value", "data")
    SELECT
      "projectId",
      'unique_page_views_at_' || extract(hour from "timestamp")::integer AS "kind",
      'total' AS "value",
      jsonb_build_object('count', count("id")) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageview' AND (_start IS NULL OR "createdAt" BETWEEN _start AND _end) AND "unique" = TRUE AND "timestamp" IS NOT NULL
    GROUP BY
      "projectId",
      extract(hour from "timestamp")
    ON CONFLICT ("projectId", "kind", "value") 
      DO UPDATE SET "data" = jsonb_build_object(
        'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer
      );
  END;
$function$;

--> -- Aggregate page reads.
CREATE FUNCTION compute_total_page_reads()
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_page_reads';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_page_reads', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    INSERT INTO
      "aggregated_event" ("projectId", "kind", "value", "data")
    SELECT
      "projectId",
      'page_reads' AS "kind",
      'total' AS "value",
      jsonb_build_object(
        'count', count("event"."id"), 
        'duration', sum(("event"."data"->>'duration')::integer), 
        'completion', sum(("event"."data"->>'completion')::integer)
      ) as "data"
    FROM
      "event"
    WHERE
      "name" = 'pageread' AND (_start IS NULL OR "createdAt" BETWEEN _start AND _end)
    GROUP BY
      "projectId"
    ON CONFLICT ("projectId", "kind", "value") 
      DO UPDATE SET "data" = jsonb_build_object(
        'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer,
        'duration', ("aggregated_event"."data"->>'duration')::integer + (EXCLUDED."data"->>'duration')::integer,
        'completion',  ("aggregated_event"."data"->>'completion')::integer + (EXCLUDED."data"->>'completion')::integer
      );
  END;
$function$;

--> -- Aggregate page reads by _column.
CREATE FUNCTION compute_page_reads(_column TEXT)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  DECLARE
    _start timestamp with time zone := to_timestamp(0);
    _end timestamp with time zone := clock_timestamp() + interval '1 minute';
  BEGIN
    SELECT 
      "lastExecutionAt" INTO _start
    FROM 
      "execution" 
    WHERE
      "name" = 'compute_total_'||_column||'_page_reads';
    
    INSERT INTO "execution" ("name", "lastExecutionAt") VALUES ('compute_total_'||_column||'_page_reads', _end)
      ON CONFLICT ("name") DO UPDATE SET "lastExecutionAt" = _end;

    EXECUTE FORMAT(
      $$
        INSERT INTO
          "aggregated_event" ("projectId", "kind", "value", "data")
        SELECT
          "projectId",
            %L || '_page_reads' AS "kind",
            %I AS "value",
          jsonb_build_object(
            'count', count("id"), 
            'duration', sum(("event"."data"->>'duration')::integer), 
            'completion', sum(("event"."data"->>'completion')::integer)
          ) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageread' AND ($1 IS NULL OR "createdAt" BETWEEN $1 AND $2) AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "kind", "value") 
          DO UPDATE SET "data" = jsonb_build_object(
            'count', ("aggregated_event"."data"->>'count')::integer + (EXCLUDED."data"->>'count')::integer,
            'duration', ("aggregated_event"."data"->>'duration')::integer + (EXCLUDED."data"->>'duration')::integer,
            'completion', ("aggregated_event"."data"->>'completion')::integer + (EXCLUDED."data"->>'completion')::integer
          );
      $$, _column, _column, _column, _column) 
    USING _start, _end;
  END;
$function$;
