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
         time as year,
         cbr,
         cdr,
         tpopulationmale1july + tpopulationfemale1july as pop
    from wpp2022.demographic_indicators
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     -- and time in (1960,1970,1980,1990,2000,2010,2020)
     and time between 1950 and 2020
order by 1,2
       ;

"
raw_wide <- dbGetQuery( conn, statement = sql_query )

## gráfico da transição demográfica
raw_wide %>%
  filter(iso3_code == 'BRA') %>% 
  ggplot( aes(x = year)) + 
  geom_line( aes( y = cdr), lty=1) + 
  geom_line( aes( y = cbr), lty=2) #+ 
  #geom_bar( aes( y = pop), stat = 'identity', alpha=0.4, size=0.1)
  
  
             