library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         time as year,
         tpopulation1jan as pop_1jan,
         -- popdensity as pop_density,
         natchange as natchange,
         netmigrations as netmigration,
         natchangert as natchange_rate,
         cnmr as netmigration_rate
    from wpp2022.demographic_indicators
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and time between 1960 and 2020
order by 1,2
    ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )

## Migração vs Crescimento natural
mig_data <- raw_wide %>% 
  select(-c(pop_1jan,natchange, netmigration)) %>% 
  pivot_longer(cols = c(natchange_rate, netmigration_rate)) %>% 
  mutate( 
    name = case_when(
      name == 'natchange_rate' ~ 'crescimento natural',
      TRUE ~ 'migração líquida'
    )
  ) 

mig_plot <- mig_data %>%
  ggplot( aes( x = year, y = value)) + 
  geom_line( aes( color = iso3_code)) + 
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'ano',
    y = 'taxa por 1.000 pessoas',
    color = 'país'
  ) +
  facet_grid( name ~ ., scales = 'free_y')

mig_plot +
  ggsave( filename = "imgs/migration/mig_natchange.png", width = 7, height = 4)


