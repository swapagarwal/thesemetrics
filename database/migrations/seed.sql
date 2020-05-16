-->
INSERT INTO
  "projects" ("teamId", "name", "type", "domain")
VALUES
  (1, 'One', 'website', 'one.example.com'),
  (1, 'Two', 'website', 'two.example.com'),
  (1, 'Three', 'website', 'three.example.com');

-->
INSERT INTO
  "pageviews" (
    "projectId",
    "path",
    "unique",
    "createdOn"
  )
SELECT
  floor(random() * 3 + 1) :: INT AS "projectId",
  (ARRAY [ '/', '/login', '/about' ]) [ floor(random() * 3 + 1) ] AS "path",
  (ARRAY [ true, FALSE ]) [ floor(random() * 2 + 1) ] AS "unique",
  "createdOn"
FROM
  generate_series (
    '2020-05-01' :: date,
    '2020-05-14' :: date,
    '1 hour' :: INTERVAL
  ) "createdOn";
