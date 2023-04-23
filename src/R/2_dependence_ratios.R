library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(readr)         # write_csv2
library(tidyr)         # pivot_wider, pivot_longer
library(stringr)       # str_detect, str_sub
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         midperiod as year,
         case
           when agegrpstart < 15 then 'infant'
           when agegrpstart < 60 then 'economically_active'
           else 'elderly'
         end as pop_type,
         sum(poptotal) as pop_total
    from wpp2022.population
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and midperiod in (1960,1970,1980,1990,2000,2010,2020)
group by 1,2,3
order by 1, 2
    ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )
