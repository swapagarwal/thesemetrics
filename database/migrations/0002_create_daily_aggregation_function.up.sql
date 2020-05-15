-->
CREATE FUNCTION compute_daily_total_page_views(DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    INSERT INTO
      "daily_aggregated_event" ("projectId", "date", "kind", "value", "data")
    SELECT
      "projectId",
      "createdOn" AS "date",
      'page_views' AS "kind",
      'total' AS "value",
      jsonb_build_object('count', count("id")) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageview' AND "createdOn" = $1
    GROUP BY
      "projectId",
      "createdOn"
    ON CONFLICT ("projectId", "date", "kind", "value") 
      DO UPDATE SET "data" = EXCLUDED. "data";
  END;
$function$;

-->
CREATE FUNCTION compute_daily_total_unique_page_views(DATE) 
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    INSERT INTO
      "daily_aggregated_event" ("projectId", "date", "kind", "value", "data")
    SELECT
      "projectId",
      "createdOn" AS "date",
      'unique_page_views' AS "kind",
      'total' AS "value",
      jsonb_build_object('count', count("id")) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageview' 
      AND "createdOn" = $1
      AND "unique" = TRUE
    GROUP BY
      "projectId",
      "createdOn"
    ON CONFLICT ("projectId", "date", "kind", "value") 
      DO UPDATE SET "data" = EXCLUDED."data";
  END;
$function$;

-->
CREATE FUNCTION compute_daily_page_views(_column TEXT, _date DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          "daily_aggregated_event" ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
            $1 AS "date",
            %L || '_page_views' AS "kind",
            %I AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND "createdOn" = $1 AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _column, _column, _column, _column) 
    USING _date;
  END;
$function$;

-->
CREATE FUNCTION compute_daily_unique_page_views(_column TEXT, _date DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          "daily_aggregated_event" ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
            $1 AS "date",
            %L || '_unique_page_views' AS "kind",
            %I AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND "createdOn" = $1 AND "unique" = TRUE AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _column, _column, _column, _column) 
    USING _date;
  END;
$function$;

-->
CREATE FUNCTION compute_daily_total_page_reads(DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    INSERT INTO
      "daily_aggregated_event" ("projectId", "date", "kind", "value", "data")
    SELECT
      "projectId",
      "createdOn" AS "date",
      'page_reads' AS "kind",
      'total' AS "value",
      jsonb_build_object(
        'count', count("id"), 
        'duration', sum(("event"."data"->>'duration')::integer), 
        'completion', sum(("event"."data"->>'completion')::integer)
      ) AS "data"
    FROM
      "event"
    WHERE
      "name" = 'pageread' AND "createdOn" = $1
    GROUP BY
      "projectId",
      "createdOn"
    ON CONFLICT ("projectId", "date", "kind", "value") 
      DO UPDATE SET "data" = EXCLUDED."data";
  END;
$function$;

-->
CREATE FUNCTION compute_daily_page_reads(_column TEXT, _date DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          "daily_aggregated_event" ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
            $1 AS "date",
            %L  || '_page_reads' AS "kind",
            %I AS "value",
          jsonb_build_object(
            'count', count("id"), 
            'duration', sum(("event"."data"->>'duration')::integer), 
            'completion', sum(("event"."data"->>'completion')::integer)
          ) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageread' AND "createdOn" = $1 AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _column, _column, _column, _column) 
    USING _date;
  END;
$function$;
