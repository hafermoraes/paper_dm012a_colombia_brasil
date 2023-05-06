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
          -- agegrp, 
          agegrpstart as age,
          popmale as male, 
          popfemale as female
     from wpp2022.population
    where variant = 'Medium' 
     and iso3_code in ('COL','BRA') 
     and midperiod in (1960,1970,1980,1990,2000,2010,2020) 
order by iso3_code,
         midperiod, 
         agegrpstart
       ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )

## Converte para formato 'long'
raw_long <- raw_wide %>%
  pivot_longer( 
    cols = -(1:3), 
    names_to = "sex", 
    values_to = "pop"
    )

## dados em formato básico para pirâmide populacional
pyramid_data <- raw_long %>%
  left_join(
    raw_long %>%
      group_by(iso3_code, year) %>%
      summarise(pop_total = sum(pop)),
    by = c('iso3_code','year')
  ) %>% 
  mutate(
    year = as.character(year),
    pop_perc = pop / pop_total
  ) 

## https://stackoverflow.com/a/37113996
## Pirâmides em gráficos de escada
## População (milhares)
pyramid_step_thousands <- ggplot( data = pyramid_data, aes( x = age, y = pop, color = year)) +
  geom_step( 
    data = pyramid_data %>% filter( sex == 'female'),
    aes( x = age )
  ) + 
  geom_step( 
    data = pyramid_data %>% filter( sex == 'male'),
    aes( x = age, y = -pop)
  ) + 
  coord_flip() + 
  labs(
    x = 'idade simples'
    ,y = "População (milhares de pessoas)"
    # ,caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
    ,color = 'ano'
  )+ 
  scale_y_continuous(labels = abs) +
  guides(color = guide_legend(reverse=TRUE)) + 
  facet_wrap( ~ iso3_code, scales = 'free_x', ncol = 1)

pyramid_step_thousands +
  ggsave( filename = 'imgs/age_pyramids/age_pyramid_step_thousands.png', width = 5, height = 7)


## População (%)
pyramid_step_pct <- ggplot( data = pyramid_data, aes( x = age, y = pop_perc, color = year)) +
  geom_step( 
    data = pyramid_data %>% filter( sex == 'female'),
    aes( x = age )
  ) + 
  geom_step( 
    data = pyramid_data %>% filter( sex == 'male'),
    aes( x = age, y = -pop_perc)
  ) + 
  coord_flip() + 
  labs(
    x = 'idade simples'
    ,y = "População (% do total)"
    # ,caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
    ,color = 'ano'
  )+ 
  scale_y_continuous(labels = abs) +
  guides(color = guide_legend(reverse=TRUE)) + 
  facet_wrap( ~ iso3_code, scales = 'free_x', ncol = 1)

pyramid_step_pct +
  ggsave( filename = 'imgs/age_pyramids/age_pyramid_step_percent.png', width = 5, height = 7)
