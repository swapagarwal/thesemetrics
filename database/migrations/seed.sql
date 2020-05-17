-->
INSERT INTO
  "pageview" (
    "projectId",
    "path",
    "unique",
    "createdOn"
  )
SELECT
  1 AS "projectId",
  (ARRAY [ '/', '/login', '/about' ]) [ floor(random() * 3 + 1) ] AS "path",
  (ARRAY [ true, FALSE ]) [ floor(random() * 2 + 1) ] AS "unique",
  "createdOn"
FROM
  generate_series (
    '2020-05-01' :: date,
    '2020-05-14' :: date,
    '1 hour' :: INTERVAL
  ) "createdOn";
