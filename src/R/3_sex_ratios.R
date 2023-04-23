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
           when agegrpstart = 0 then '0'
           when agegrpstart < 5 then '1-4'
           when agegrpstart < 10 then '5-9'
           when agegrpstart < 15 then '10-14'
           when agegrpstart < 20 then '15-19'
           when agegrpstart < 25 then '20-24'
           when agegrpstart < 30 then '25-29'
           when agegrpstart < 35 then '30-34'
           when agegrpstart < 40 then '35-39'
           when agegrpstart < 45 then '40-44'
           when agegrpstart < 50 then '45-49'
           when agegrpstart < 55 then '50-54'
           when agegrpstart < 60 then '55-59'
           when agegrpstart < 65 then '60-64'
           when agegrpstart < 70 then '65-69'
           when agegrpstart < 75 then '70-74'
           when agegrpstart < 80 then '75-79'
           else '80+'
         end as agegrp,
         sum(popmale) as male,
         sum(popfemale) as female
    from wpp2022.population
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and midperiod in (1960,1970,1980,1990,2000,2010,2020)
     -- and midperiod between 1960 and 2020
group by 1,2,3
order by 1,2
    ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )

## base dataframe for graphs
sr_base <- raw_wide %>% 
  mutate(
    agegrp = factor( 
      agegrp,
      levels = c('0','1-4','5-9','10-14','15-19',
                 '20-24','25-29','30-34','35-39',
                 '40-44','45-49','50-54','55-59',
                 '60-64','65-69','70-74','75-80',
                 '80+')
      ),
    male_to_female_ratio = male / female
  ) 

## razão de sexos ao nascer
sr_at_birth_facet <- sr_base %>% 
  filter( agegrp == '0') %>%
  ggplot(
    aes( 
      x = year,
      y = male_to_female_ratio * 100,
      color = iso3_code
      )
  ) + 
  geom_point() + 
  geom_line() +
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'ano',
    y = 'razão de sexos ao nascer',
    color = '',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  ) + 
  theme(
    legend.position = 'top'
  )

sr_at_birth_facet + 
  ggsave( filename = "imgs/sex_ratios/sr_at_birth.png", width = 9, height = 5)

## razão de sexos por grupo etário
sr_facet_agegrp <- sr_base %>% 
  na.omit() %>%
  ggplot(
    aes( 
      x = year,
      y = male_to_female_ratio * 100,
      color = iso3_code
    )
  ) + 
  geom_point() + 
  geom_line() +
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'ano',
    y = 'razão de sexos ao nascer',
    color = '',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  ) + 
  facet_wrap(~agegrp, scales = 'free_y') + 
  theme(
    legend.position = 'top'
  )

sr_facet_agegrp + 
  ggsave( filename = "imgs/sex_ratios/sr_facet_agegrp.png", width = 10, height = 8)

