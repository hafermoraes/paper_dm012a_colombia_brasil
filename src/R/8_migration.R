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
  filter( name == 'migração líquida') %>%
  ggplot( aes(x = year, y=value)) + 
  geom_line( aes(color = iso3_code)) + 
  labs(
    x = 'ano',
    y = 'imigração líquida (por 1.000 pessoas)',
    color = 'país'
  ) + 
  scale_x_continuous(n.breaks = 15)

mig_plot +
  ggsave( filename = "imgs/migration/mig.png", width = 7, height = 4)

  
## Migração vs Crescimento natural
mig_nat_plot <- mig_data %>%
  ggplot( aes( x = year, y = value)) + 
  geom_line( aes( color = iso3_code)) + 
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'ano',
    y = 'taxa por 1.000 pessoas',
    color = 'país'
  ) +
  scale_x_continuous(n.breaks = 15) + 
  facet_grid( name ~ ., scales = 'free_y')

mig_nat_plot +
  ggsave( filename = "imgs/migration/mig_natchange.png", width = 7, height = 4)

## waterfall charts
wf_data <- raw_wide %>%
  transmute(
    iso3_code,
    period = case_when(
      year < 1970 ~ '1960-1970',
      year < 1980 ~ '1970-1980',
      year < 1990 ~ '1980-1990',
      year < 2000 ~ '1990-2000',
      year < 2010 ~ '2000-2010',
      year < 2020 ~ '2010-2020'
    ),
    natchange,
    netmigration,
  ) %>% 
  na.omit() %>%
  group_by(iso3_code, period) %>%
  summarise(
    natchange = sum(natchange),
    netmigration = sum(netmigration)
  ) %>%
  left_join(
    raw_wide %>% 
      filter(year == 1960) %>% 
      transmute(
        iso3_code,
        period = '1960-1970', 
        pop_begin = pop_1jan, 
        pop_end=0
      )    
  ) %>%
  mutate( 
    pop_end = pop_begin + natchange + netmigration
  ) %>%
  as.data.frame()

for( i in 2:nrow(wf_data)){
  if( is.na( wf_data[i,'pop_begin'] ) ){
    wf_data[i,'pop_begin'] <- wf_data[i-1, 'pop_end']
    wf_data[i,'pop_end'] <- wf_data[i, 'pop_begin'] + wf_data[i, 'natchange'] + wf_data[i, 'netmigration']
  }
}  

## validation of pop_end
raw_wide %>%
  transmute(
    iso3_code,
    period = case_when(
      year == 1970 ~ '1960-1970',
      year == 1980 ~ '1970-1980',
      year == 1990 ~ '1980-1990',
      year == 2000 ~ '1990-2000',
      year == 2010 ~ '2000-2010',
      year == 2020 ~ '2010-2020'
    ),
    pop_check = pop_1jan
  ) %>%
  na.omit()