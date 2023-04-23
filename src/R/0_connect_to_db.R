
library(DBI)
library(RPostgres)

# Connect to database 'wpp'
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("PG_DB"),
  host = Sys.getenv("PG_HOST"),
  port = Sys.getenv("PG_PORT"),
  user = Sys.getenv("PG_USER"),
  password = Sys.getenv("PG_PASSWORD")
)

