library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         time as year,
         agegrpstart as agegrp,
         asfr
    from wpp2022.fertility
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and time in (1960,1970,1980,1990,2000,2010,2020)
order by 1,2,3
       ;
"
raw_long <- dbGetQuery( conn, statement = sql_query )

## gráfico das funções de fecundidade
asfr_plot <- raw_long %>%
  mutate(
    year = as.factor(year),
    agegrp = as.numeric(agegrp)
    # agegrp = factor( 
    #   agegrp,
    #   levels = c('10-14','15-19','20-24',
    #              '25-29','30-34','35-39',
    #              '40-44','45-49','50-54')
    # )
  ) %>% 
  ggplot( aes( x = agegrp, y = asfr)) + 
  geom_line(aes(colour = year)) + 
  labs(
    x = 'idade',
    y = 'Taxa Específica de Fecundidade',
    color = 'ano censitário',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  ) + 
  facet_grid(iso3_code ~ .)

asfr_plot + 
  ggsave( filename = "imgs/fertility/fertility_facet_iso3code.png", width = 11, height = 8)  

