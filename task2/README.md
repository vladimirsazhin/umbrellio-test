# Задача 2

```postgresql
CREATE TEMP TABLE users(id bigserial, group_id bigint);

INSERT INTO users(group_id) VALUES (1), (1), (1), (2), (1), (3);

SELECT MIN(id) AS min_id, group_id, COUNT(id) FROM (
  SELECT id, group_id, SUM(group_id_changed) OVER (ORDER BY id) AS partition_id FROM (
    SELECT id, group_id, CASE WHEN group_id = lag(group_id) OVER (ORDER BY id) THEN 0 ELSE 1 END AS group_id_changed FROM users
  ) tmp1
) tmp2 GROUP BY partition_id, group_id;
```
