# BibliU Data Challenge
Hello! Welcome to the data tech test.

Not all companies request candidates to complete a technical challenge, but we think that testing how you reason and interact with data in a realistic business context helps both you, the applicant, and us at BibliU understand whether you'll be a good fit for the role.

From our side, we're looking to test that you can:
- Use SQL to answer questions with data
- Perform basic data cleaning
- Work with ambiguity and manage assumptions about a dataset
- Understand the business context of data models

We guarantee that we will at least provide feedback for your solution even if you don't progress further in our process, so don't hold back! And **we will *never* ask applicants to do "free work"** to serve our business needs.

Good luck, have fun!

## Submitting your test
We ask that you perform any work on the test in either a private git repository, or locally on your machine, and submit a `zip` folder of your code at the end of the challenge [via email to our recruiter](mailto:recruitment@bibliu.com).

## Getting set up
The following steps should be performed before you get started on the challenge. This setup assumes that you don't have Postgres installed locally - if you do, feel free to run your local install in the background and skip steps 2-5, however this does mean that you may encounter some permissions issues depending on your exact setup.

Regardless of the system you are running on you will need the following to get started:
* `dbt` (Data Build Tool) command line tool. This will enable you to easily build and rebuild dependent tables during the test. See https://docs.getdbt.com/
* A `postgres` database
* Docker - optional, but recommended for setting up Postgres consistently. See https://docs.docker.com/.
* A SQL client of your choice - optional, but recommended so that you can query your tables and investigate data (we like [DBeaver](https://dbeaver.io/download/) for Postgres).

1. Install `dbt` (https://docs.getdbt.com/dbt-cli/install/overview)

    On macOS:
    ```zsh
    brew update
    brew install git
    brew tap dbt-labs/dbt
    brew install dbt-postgres
    ```
    On Windows:
    ```powershell
    pip install dbt-postgres
    ```
    On Ubuntu:
    ```bash
    sudo apt-get install git libpq-dev python-dev
    pip install dbt-postgres
    ```
2. If you don't already have it, install Docker for [Mac](https://docs.docker.com/docker-for-mac/install/) / [Windows](https://docs.docker.com/docker-for-windows/install/); On Ubuntu you can install it with these commands:
   ```bash
   sudo apt install docker.io
   sudo systemctl start docker
   ```
3. Pull Postgres from your command line of choice:
    ```zsh
    docker pull postgres
    ```
4. Run Postgres in the background with some default options:
    ```zsh
    docker run --rm --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data postgres
    ```
    This will store all data inside the database at `$HOME/docker/volumes/postgres`, so change that path before hitting enter if you want to store it elsewhere. To confirm this will work out of the box you can connect to this database using username=`postgres` and password=`docker` to login. If you have your own existing instance you prefer to use please update `profiles.yml` before moving on to the next step.
5. Set up a `dbt` profile that will connect to your local Postgres database. If you are running Postgres locally with your own setup, you'll need to add account details with permissions to create tables and schemas on a database to your `~/.dbt/profiles.yml` file.
    ```zsh
    mkdir ~/.dbt
    touch ~/.dbt/profiles.yml
    cat profiles.yml >> ~/.dbt/profiles.yml
    ```

You are now ready to build new tables on your local database using `dbt`! For a bit more context on what `dbt` is, you may find it helpful to read [this short introduction](https://docs.getdbt.com/docs/overview), but for the purposes of this challenge think of it as tool that will enable you to build and test tables (with `SELECT` statements) that depend on each other in the right order.

To build the baseline models and understand your starting point, run the commands below:

1. Build all tables:
    ```zsh
    dbt seed # loads seed data provided in the repo under /data
    dbt run
    ```
2. Generate documentation for the tables and take a look at what you're working with! You could also take a look in your SQL client of choice.
    ```zsh
    dbt docs generate
    dbt docs serve # this will open documentation for the tables locally in your browser
    ```
3. Run tests, you should see 5 errors and 0 warnings from 17 tests. Tests are designed to verify expectations of data sources and models. All tests beginning with `source_` should pass. The failing tests are associated with models that you will build out, and should all pass when you have completed the challenge.
    ```zsh
    dbt test
    ```

It's important that `dbt run` works before you start! This is how you will be building your tables later.

# The challenge
The task itself consists of creating several tables, or models, that are derived from the source tables provided in the repository. Each model that you will be required to create will be one SQL query, and templates for each query can be found under the `/models/` directory.

Please note that there is some ambiguity in the challenges and data, so don't feel like you must arrive at one correct answer. Please explain any assumptions you make through inline SQL comments.

## Starting point: data sources
You are provided with three source models, as follows:
1. `books` - information relating to books, including their unique id (`isbn`), title, and publisher.
2. `logs` - access logs of different events being tracked in an app. Each event includes a URL, duration (in seconds), and user ID.
3. `users` - data relating to the users of a platform, including their ID, email, account status, and associated institution / university

These sources are defined in `/models/challenge.yml` (which you can also view via `dbt docs serve`).

## Building models
Each challenge model should exist as its own SQL file using the provided templates, but you can create intermediate models (`.sql` files anywhere under the `/models/*` path) if that helps you (this not a requirement). You can reference these in other files using the [`{{ ref('<file_name>') }}` syntax](https://docs.getdbt.com/reference/dbt-jinja-functions/ref).

At any time, the `dbt run` command will rebuild all of your tables from source using your current `.sql` files - this is the beauty of `dbt`! You can query your tables in your database client after they have been run for the first time. If you'd like to run just one model, you can use the syntax below:

```zsh
dbt run --models <model_file_name> # without the .sql suffix

# e.g. to build only /models/challenge/1_institution_metrics.sql
dbt run --models 1_institution_metrics
```

The tasks are outlined below, roughly in order of increasing complexity:

### 1. Institution metrics
**Task:** Create an `institutions` table with one row per institution, and summary metrics as follows:
- active_user_count
- deleted_user_count
- pending_user_count
- total_user_count

Different user types can be determined via the `status` of a given user.

### 2. Logs by title
**Task:** create a log table with the log events related to each title, including at a minimum:
- isbn: the unique ID for this book
- title: the book title
- event_url: the event URL of the corresponding URL
- event_duration_seconds: the duration of the event in seconds

### 3. Book usage (depends on 2)
**Task:** using your model from task 2, create a table summarising the usage of each title:
- isbn: the unique ID for this book
- title: the book title
- total_duration_seconds: total amount of time this title has been accessed for
- total_chapters_accessed: number of distinct chapters accessed in this book
- total_pages_accessed: number of distinct pages have accessed in this book

If you could not complete task 2, feel free to continue with other tasks.

### 4. User dimension table
**Task:** create a dimension table for users with high-level statistics about their usage, with one row per user:
- avg_visit_events: average number of events during a visit
- avg_visit_duration: average total duration of a visit
- avg_visit_books_accessed: average number of distinct books accessed
- total_user_count:

### 5. Retention
**Task:** create an unbounded retention table for the platform, which is defined as:
> Unbounded retention: the percentage of users who came back on a specific day or any time after that day (i.e. the inverse of churn - the number of users "lost" a certain number of days after initial signup)

More information is provided in [this blog post](https://amplitude.com/blog/2016/08/11/3-ways-measure-user-retention).

A minimal structure for the table should include at least the following columns:
- days_since_signup: an integer number of days since signup
- percentage_users_retained *(or equivalent through multiple other columns)*: a decimal value between [0,1] representing the proportion of all users retained this many days after signup

**Extension:** If you'd like to stretch a bit further, try structuring this table so that you could view the retention curve of any individual institution, or all of them, depending on how you filtered the results:

```sql
-- for one institution
select
    institution_id
    , days_since_signup
    , SOME_AGGREGATION(??) as percentage_users_retained -- could reference >1 column
from {{ ref('5_retention') }}
where institution_id = 'one_specific_institution'
order by days_since_signup asc

-- for all institutions
select
    days_since_signup
    , SOME_AGGREGATION(??) as overall_percentage_users_retained -- could reference >1 column
from {{ ref('5_retention') }}
group by days_since_signup -- aggregate over all institutions
order by days_since_signup asc
```

## Testing Models
At any point, you can run `dbt test` to check if your models pass basic expectations. Note that theses tests do not check whether your solutions are correct, but do verify that models are building successfully and do not have missing or duplicate data.  

We recommend you use a SQL client to query your models after running dbt to explore and validate your solutions.

### More about dbt

---
- [What is dbt](https://docs.getdbt.com/docs/introduction)?
- Read the [dbt viewpoint](https://docs.getdbt.com/docs/about/viewpoint)
- [Installation](https://docs.getdbt.com/dbt-cli/install/overview)
---
