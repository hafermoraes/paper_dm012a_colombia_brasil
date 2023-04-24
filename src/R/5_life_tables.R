library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         time as year,
         agegrpstart,
         mx,
         lx,
         dx
    from wpp2022.lifetables 
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and time in (1960,1970,1980,1990,2000,2010,2020)
order by 1,2,3
       ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )

raw_wide %>% 
  pivot_longer(cols = -c(1:3)) %>% 
  mutate( 
    agegrpstart = as.numeric(agegrpstart),
    year = as.factor(year)
  ) %>% 
  ggplot( aes( x = agegrpstart, y = value, linetype = year)) + 
  geom_line() + 
  facet_grid(name ~ iso3_code, scales = 'free')
