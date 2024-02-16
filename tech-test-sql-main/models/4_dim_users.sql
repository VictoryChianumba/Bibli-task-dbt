/*
Create a dimension table for users with high-level statistics about their usage,
with one row per user
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

events as (
  select
    user_id,
    visit_id, 
    count(*) as event_count,
    sum(event_duration_seconds) as total_duration,
    -- count(distinct substring(event_url, locate('books/', event_url)+6, 13)) as books_accessed
    COUNT(DISTINCT SUBSTRING(event_url, POSITION('books/' IN event_url) + 6, 13)) AS books_accessed
  from logs
  group by user_id, visit_id

),

user_stats as(
  select
    user_id,
    avg(event_count) as avg_visited_events,
    avg(total_duration) as avg_total_duration,
    avg(books_accessed) as avg_books_accessed
  from events
  group by user_id
)

-- user_books as (
--   select
--     user_id,
--     count(distinct ibsn) as total_books_accessed    
--   from logs
--   LEFT JOIN books
--     ON SUBSTRING(event_url, LOCATE('books/', event_url)+6, 13) = books.isbn
--   GROUP BY 1
-- )


SELECT
  *,
  COUNT(*) OVER() AS total_user_count
FROM user_stats