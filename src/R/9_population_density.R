library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         time as year,
         popdensity as pop_density
    from wpp2022.demographic_indicators
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and time between 1960 and 2020
order by 1,2
    ;
"
raw_long <- dbGetQuery( conn, statement = sql_query )

## Densidade populacional (pessoas por km quadrado)
dens_pop_plot <- raw_long %>%
  ggplot( aes( x = year, y = pop_density)) + 
  geom_line(aes(color = iso3_code)) + 
  scale_x_continuous(n.breaks = 15) + 
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'ano',
    y = 'Densidade populacional (pessoas por km²)',
    color = 'país'
  ) 

dens_pop_plot +
  ggsave( filename = "imgs/population_density/dens_pop.png", width = 7, height = 4)


## Quociente COL/BRA da densidade populacional
quoc_plot <- raw_long %>% 
  pivot_wider(names_from = iso3_code, values_from = pop_density) %>%
  mutate(fct_COL_BRA = COL / BRA) %>%
  ggplot( aes( x = year, y = fct_COL_BRA)) + 
  geom_line() + 
  scale_x_continuous(n.breaks = 15) + 
  labs(
    x = 'ano',
    #subtitle = 'Quociente COL/BRA da Densidade populacional',
    y = '[Dens.Pop.COL] / [Dens.Pop.BRA]'
  ) 

quoc_plot +
  ggsave( filename = "imgs/population_density/quociente_denspop.png", width = 7, height = 4)
