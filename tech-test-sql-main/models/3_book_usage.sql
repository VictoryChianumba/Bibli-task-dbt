/*
Create an aggregate table for total usage by title
*/

-- this "imports" your previous model
with logs_by_title as (
  select *
  from {{ ref('2_logs_by_title') }}
),

-- YOUR CODE GOES HERE - note: this depends on task 2

book_data as (
  select
    isbn,
    title,
    event_duration_seconds,
    substring(event_url, '/html/chapter_(.+)\.html') AS chapter,
    substring(event_url, '/html/page_(.+)\.html') AS pages
  from logs_by_title  
)

-- SUBSTRING(event_url, CHARINDEX('/html/chapter_', event_url) + 14, CHARINDEX('.html', event_url) - CHARINDEX('/html/chapter_', event_url) - 14) AS chapter
select
  isbn,
  title,
  sum(event_duration_seconds) as total_duration_seconds,

   -- how many distinct chapters, or files, have been accessed?
  count(distinct chapter) as total_chapters_accessed,

  -- how many distinct pages have been accessed
  count(distinct pages) as total_pages_accessed
from book_data
group by isbn, title

