/*
Create an unbounded retention curve for the platform. Unbounded retention is
defined as follows:
"the percentage of users who came back on a specific day or any time after that day"

More information below:
https://amplitude.com/blog/2016/08/11/3-ways-measure-user-retention
*/

with logs as (
  select *
  from {{ source('challenge', 'logs') }}
),

users as (
  select *
  from {{ source('challenge', 'users') }}
),

-- YOUR CODE GOES HERE

first_login AS (
  SELECT 
    user_id,
    MIN(event_at) AS first_login_at
  FROM logs
  GROUP BY user_id
),

retention AS (
  SELECT
    users.user_id,
    users.signup_at,
    first_login.first_login_at,
    EXTRACT( day from CAST(first_login.first_login_at AS TIMESTAMP) - CAST(users.signup_at AS TIMESTAMP)) AS days_since_signup
  FROM users
  LEFT JOIN first_login
    ON users.user_id = first_login.user_id 
)
-- ,

-- user_counts AS (
--   SELECT 
--     EXTRACT(DAY FROM (NOW() - CAST(users.signup_at AS TIMESTAMP))) AS days_since_signup,
--     COUNT(*) AS total_users
--   FROM users
--   GROUP BY days_since_signup
-- ),
-- retained_users AS (
--   SELECT
--     days_since_signup,
--     COUNT(retention.user_id) AS retained_users
--   FROM retention
--   GROUP BY days_since_signup
-- )
-- SELECT
--   uc.days_since_signup,
--   COALESCE(r.retained_users, 0) / uc.total_users AS percentage_users_retained
-- FROM user_counts uc
-- LEFT JOIN retained_users r ON uc.days_since_signup = r.days_since_signup
-- ORDER BY 1

SELECT
  days_since_signup,
  COUNT(user_id) / COUNT(*) OVER() AS percentage_users_retained
FROM retention
GROUP BY 1
ORDER BY 1

