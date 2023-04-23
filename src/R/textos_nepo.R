
library(tidyverse)
library(DBI)
library(RPostgres)

# Connect to database 'paa'
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("PG_DB"),
  host = Sys.getenv("PG_HOST"),
  port = Sys.getenv("PG_PORT"),
  user = Sys.getenv("PG_USER"),
  password = Sys.getenv("PG_PASSWORD")
)

dbGetQuery( conn, statement = "select * from wpp2022.life_tables limit 5;" )
