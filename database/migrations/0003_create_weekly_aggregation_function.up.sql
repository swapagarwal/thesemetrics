-->
CREATE FUNCTION __compute_date_range_total_page_views(_table TEXT, _start DATE, _end DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          %I ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
          $1 AS "date",
          'page_views' AS "kind",
          'total' AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND "createdOn" BETWEEN $1 AND $2
        GROUP BY
          "projectId"
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _table
    ) USING _start, _end;
  END;
$function$;

-->
CREATE FUNCTION __compute_date_range_total_unique_page_views(_table TEXT, _start DATE, _end DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          %I ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
          $1 AS "date",
          'unique_page_views' AS "kind",
          'total' AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND "createdOn" BETWEEN $1 AND $2 AND "unique" = TRUE
        GROUP BY
          "projectId"
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _table
    ) USING _start, _end;
  END;
$function$;


-->
CREATE FUNCTION __compute_date_range_page_views(_table TEXT, _column TEXT, _start DATE, _end DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          %I ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
            $1 AS "date",
            %L || '_page_views' AS "kind",
            %I AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND "createdOn" BETWEEN $1 AND $2 AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _table, _column, _column, _column, _column) 
    USING _start, _end;
  END;
$function$;

-->
CREATE FUNCTION __compute_date_range_unique_page_views(_table TEXT, _column TEXT, _start DATE, _end DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          %I ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
            $1 AS "date",
            %L || '_unique_page_views' AS "kind",
            %I AS "value",
          jsonb_build_object('count', count("id")) AS "data"
        FROM
          "event"
        WHERE
          "name" = 'pageview' AND "createdOn" BETWEEN $1 AND $2 AND "unique" = TRUE AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _table, _column, _column, _column, _column) 
    USING _start, _end;
  END;
$function$;

-->
CREATE FUNCTION __compute_date_range_total_page_reads(_table TEXT, _start DATE, _end DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          %I ("projectId", "date", "kind", "value", "data")
        SELECT
          "projectId",
          $1 AS "date",
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
          "name" = 'pageread' AND "createdOn" BETWEEN $1 AND $2
        GROUP BY
          "projectId"
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _table)
    USING _start, _end;
  END;
$function$;

-->
CREATE FUNCTION __compute_date_range_page_reads(_table TEXT, _column TEXT, _start DATE, _end DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    EXECUTE FORMAT(
      $$
        INSERT INTO
          %I ("projectId", "date", "kind", "value", "data")
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
          "name" = 'pageread' AND "createdOn" BETWEEN $1 AND $2 AND %I IS NOT NULL
        GROUP BY
          "projectId",
          %I
        ON CONFLICT ("projectId", "date", "kind", "value") 
          DO UPDATE SET "data" = EXCLUDED."data";
      $$, _table, _column, _column, _column, _column) 
    USING _start, _end;
  END;
$function$;

-->
CREATE FUNCTION compute_weekly_total_page_views(_start DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    PERFORM __compute_date_range_total_page_views('weekly_aggregated_event', _start, (_start + interval '1 week')::date);
  END;
$function$

-->
CREATE FUNCTION compute_weekly_total_unique_page_views(_start DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    PERFORM __compute_date_range_total_unique_page_views('weekly_aggregated_event', _start, (_start + interval '1 week')::date);
  END;
$function$

-->
CREATE FUNCTION compute_weekly_page_views(_column TEXT, _start DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    PERFORM __compute_date_range_page_views('weekly_aggregated_event', _column, _start, (_start + interval '1 week')::date);
  END;
$function$

-->
CREATE FUNCTION compute_weekly_unique_page_views(_column TEXT, _start DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    PERFORM __compute_date_range_unique_page_views('weekly_aggregated_event', _column, _start, (_start + interval '1 week')::date);
  END;
$function$

-->
CREATE FUNCTION compute_weekly_total_page_reads(_start DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    PERFORM __compute_date_range_total_page_reads('weekly_aggregated_event', _start, (_start + interval '1 week')::date);
  END;
$function$

-->
CREATE FUNCTION compute_weekly_page_reads(_column TEXT, _start DATE)
RETURNS void LANGUAGE plpgsql AS 
$function$ 
  BEGIN
    PERFORM __compute_date_range_page_reads('weekly_aggregated_event'::text, _column, _start, (_start + interval '1 week')::date);
  END;
$function$