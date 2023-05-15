library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         time as year,
         agegrpstart as age,
         sex,
         mx,
         lx,
         dx
    from wpp2022.lifetables_singleage
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     -- and time in (1960,1970,1980,1990,2000,2010,2020)
     and time in (1960,2020)
order by 1,2,3,4
       ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )

## gráfico das funções da tábua de vida (inspirado por Preston 2001, p.52, figura 3.3)
lt_plot <- raw_wide %>% 
  transmute( 
    iso3_code, 
    year = as.factor(year), 
    age = as.numeric(age),
    log_mx = log(mx),
    lx,
    dx
  ) %>% 
  pivot_longer(cols = -c(1:3)) %>% 
  ggplot( aes( x = age, y = value)) + 
  geom_line(aes(linetype = year)) + 
  labs(
    x = 'idade',
    y = 'valor da função da tábua de vida',
    color = 'ano censitário',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  ) + 
  facet_grid(name ~ iso3_code, scales = 'free')

lt_plot + 
  ggsave( filename = "imgs/life_tables/lt_facet_iso3code.png", width = 11, height = 8)  

