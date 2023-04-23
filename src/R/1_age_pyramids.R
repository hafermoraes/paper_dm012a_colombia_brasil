
library(tidyverse)

## to connect postgresql database (saved in 'conn' object)
source('R/0_connect_to_db.R')

## query the database
dbGetQuery( conn, statement = "select * from wpp2022.life_tables limit 5;" )
