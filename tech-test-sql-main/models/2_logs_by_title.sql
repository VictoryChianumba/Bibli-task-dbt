/*
Create a log table with the events related to each title
*/

with logs as (
  select *
  from {{ source('challenge', 'logs') }}
),

books as (
  select *
  from {{ source('challenge', 'books') }}
)

-- YOUR CODE GOES HERE - the output table should have at least these columns


select
  b.isbn as isbn
  , b.title as title
  , l.event_url as event_url
  , l.event_duration_seconds as event_duration_seconds
from books b
left join logs l 
on l.event_url like '%' || b.isbn || '%'
