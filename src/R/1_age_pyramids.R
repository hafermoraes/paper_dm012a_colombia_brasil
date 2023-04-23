
library(tidyverse)

## to connect postgresql database (saved in 'conn' object)
source('R/0_connect_to_db.R')

## query the database
sql_query <- "
   select iso3_code, 
          midperiod, 
          agegrp, 
          popmale, 
          popfemale, 
          poptotal 
     from wpp2022.population 
    where variant = 'Medium' 
     and iso3_code in ('COL','BRA') 
     and midperiod in (1960,1970,1980,1990,2000,2010) 
order by iso3_code,
         midperiod, 
         agegrpstart
       ;
"
dbGetQuery( conn, statement = sql_query )
