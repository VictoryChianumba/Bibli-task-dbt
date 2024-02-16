/*
Create an institutions table with one row per institution, with summary statistics:
    - active_user_count
    - deleted_user_count
    - pending_user_count
    - total_user_count
*/

with users as (
  select *
  from {{ source('challenge', 'users') }}
),

-- YOUR CODE GOES HERE - the output table should have at least these columns

institutions as (
  select 
    ROW_NUMBER() OVER (ORDER BY institution_name) as institution_id,
    institution_name,
    status
  from users
)

select 
  i.institution_id
  , i.institution_name
  , count(case when status = 'active' then 1 end ) as active_user_count
  , count(case when status = 'deleted' then 1 end ) as deleted_user_count
  , count(case when status = 'pending' then 1 end ) as pending_user_count
  , count(*) as total_user_count
from institutions i
GROUP BY i.institution_id, i.institution_name

