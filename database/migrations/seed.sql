-->
INSERT INTO
  "project" ("teamId", "name", "type", "domain")
VALUES
  (1, 'One', 'website', 'one.example.com'),
  (1, 'Two', 'website', 'two.example.com'),
  (1, 'Three', 'website', 'three.example.com');

-->
INSERT INTO
  "event" (
    "projectId",
    "name",
    "resource",
    "unique",
    "createdOn"
  )
SELECT
  floor(random() * 3 + 1) :: INT AS "projectId",
  'pageview' AS "name",
  (ARRAY [ '/', '/login', '/about' ]) [ floor(random() * 3 + 1) ] AS "resource",
  (ARRAY [ true, FALSE ]) [ floor(random() * 2 + 1) ] AS "unique",
  "createdOn"
FROM
  generate_series (
    '2020-05-01' :: date,
    '2020-05-14' :: date,
    '1 hour' :: INTERVAL
  ) "createdOn";
