library(dplyr)         # mutate, %>% ,select, filter, transmute, etc...
library(readr)         # write_csv2
library(tidyr)         # pivot_wider, pivot_longer
library(ggplot2)       # ggplot, geom_line, geom_point, ...

## to connect postgresql database (saved in 'conn' object)
source('src/R/0_connect_to_db.R')

## query the database
sql_query <- "
  select iso3_code,
         midperiod as year,
         case
           when agegrpstart < 15 then '0-14'
           when agegrpstart < 60 then '15-59'
           else '60+'
         end as pop_type,
         sum(poptotal) as pop_total,
		 sum(popmale) as pop_male,
		 sum(popfemale) as pop_female
    from wpp2022.population
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and midperiod in (1960,1970,1980,1990,2000,2010,2020)
group by 1,2,3
order by 1, 2
    ;
"
raw_wide <- dbGetQuery( conn, statement = sql_query )

## Crescimento (geométrico) populacional por década/país
pop_geom_growth <- raw_wide %>%
  group_by(iso3_code, year) %>%
  summarise(pop = sum(pop_total)) %>%
  pivot_wider(id_cols = 'year', names_from = iso3_code, values_from = pop) %>%
  mutate( period = NA, r_BRA = NA, r_COL = NA) %>%
  as.data.frame()

for(i in 1:(nrow(pop_geom_growth)-1)){
  # década de crescimento
  pop_geom_growth[i,'period'] <- paste0(pop_geom_growth[i,'year'],'-',pop_geom_growth[i+1,'year'])
  # taxa de crescimento geométrico na década para o Brasil
  pop_geom_growth[i,'r_BRA'] <- (pop_geom_growth[i+1,'BRA']/pop_geom_growth[i,'BRA'])^(1/10)-1
  # taxa de crescimento geométrico na década para a Colômbia
  pop_geom_growth[i,'r_COL'] <- (pop_geom_growth[i+1,'COL']/pop_geom_growth[i,'COL'])^(1/10)-1
}

pop_growth_plot <- pop_geom_growth %>%
  na.omit() %>%
  transmute(period = factor(period), BRA = r_BRA, COL = r_COL) %>%
  pivot_longer(cols = 2:3) %>%
  ggplot( aes( x = period, y = value, group = name, color = name )) + 
  geom_line() + 
  geom_point() +
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'período',
    y = 'taxa (geométrica) de crescimento',
    color = 'país'
  ) +
  scale_y_continuous(labels = scales::percent)
  
pop_growth_plot +
  ggsave( filename = "imgs/population_growth/pg_total.png", width = 7, height = 4)


## Crescimento (geométrico) populacional por década/país estratificado por jovem/idoso/PIA
pg_wide_base <- raw_wide %>%
  rename( type = pop_type, total = pop_total, homens = pop_male, mulheres = pop_female) %>%
  pivot_longer(cols = c(total,homens, mulheres)) %>%
  pivot_wider(names_from = year, values_from = value) 

pg_by_age <- pg_wide_base %>% 
  transmute(
    iso3_code, type, gender = name,
    `1960-1970` = (`1970`/`1960`)^(1/10)-1,
    `1970-1980` = (`1980`/`1970`)^(1/10)-1,
    `1980-1990` = (`1990`/`1980`)^(1/10)-1,
    `1990-2000` = (`2000`/`1990`)^(1/10)-1,
    `2010-2000` = (`2010`/`2000`)^(1/10)-1,
    `2020-2010` = (`2020`/`2010`)^(1/10)-1
  )


pg_by_age_plot <- pg_by_age %>%
  pivot_longer(
    cols = -c('iso3_code','type','gender'), 
    names_to = 'period',
    values_to = 'growth'
  ) %>%
  filter( gender == 'total') %>%
  ggplot( aes( x = factor(period), y = growth, group = iso3_code, color = iso3_code)) + 
  geom_point() + 
  geom_line() + 
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'período',
    y = 'taxa (geométrica) de crescimento',
    color = 'país'
  ) +
  scale_y_continuous(labels = scales::percent) + 
  facet_grid( . ~ type )

pg_by_age_plot +
  ggsave( filename = "imgs/population_growth/pg_by_age.png", width = 16, height = 6)



pg_by_age_gender_plot <- pg_by_age %>%
  pivot_longer(
    cols = -c('iso3_code','type','gender'), 
    names_to = 'period',
    values_to = 'growth'
  ) %>%
  ggplot( aes( x = factor(period), y = growth, group = iso3_code, color = iso3_code)) + 
  geom_point() + 
  geom_line() + 
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'período',
    y = 'taxa (geométrica) de crescimento',
    color = 'país'
  ) +
  scale_y_continuous(labels = scales::percent) + 
  facet_grid( gender ~ type )

pg_by_age_gender_plot +
  ggsave( filename = "imgs/population_growth/pg_by_age_and_gender.png", width = 16, height = 8)
