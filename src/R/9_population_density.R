library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         time as year,
         popdensity as pop_density,
    from wpp2022.demographic_indicators
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and time between 1960 and 2020
order by 1,2
    ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )
