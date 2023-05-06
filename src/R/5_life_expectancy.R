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
         ex
    from wpp2022.lifetables_singleage
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and time between 1960 and 2020
order by 1,2,3,4
       ;
"
raw_long <- dbGetQuery( conn, statement = sql_query )

## Evolução da expectativa de vida
ex_dat <- raw_long %>% 
  transmute( 
    iso3_code, 
    year = as.numeric(year), 
    age = as.numeric(age),
    ex
  ) 

e0_plot <- ex_dat %>%
  filter( age == 0) %>% 
  ggplot( aes( x = year, y = ex)) + 
  geom_line(aes(group = iso3_code, colour = iso3_code)) + 
  scale_x_continuous(n.breaks = 15) + 
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'idade',
    y = 'Esperança de vida ao nascer',
    color = 'ano',
  )

e0_plot + 
  ggsave( filename = "imgs/life_tables/e0.png", width = 7, height = 5)  


e0_var_aux <- ex_dat %>%
  filter(age == 0) %>%
  pivot_wider(names_from = iso3_code, values_from = ex)

e0_var_dat <- e0_var_aux %>%
  left_join( e0_var_aux %>% transmute(year = year-1, BRA_num = BRA, COL_num = COL)) %>%
  na.omit() %>% 
  transmute( year, BRA = BRA_num/BRA, COL = COL_num/COL) %>%
  pivot_longer(cols = c(BRA,COL) ) %>%
  mutate(value = value-1)

e0_var_plot <- e0_var_dat %>%
  ggplot( aes(x=year, y=value)) + 
  geom_line( aes( color = name)) + 
  scale_y_continuous(labels = scales::percent) + 
  scale_x_continuous(n.breaks = 15) +
  guides(color = guide_legend(reverse=TRUE)) +
  labs(
    x = 'ano',
    y = 'variação da esperança de vida ao nascer',
    color = 'país',
  )

e0_var_plot + 
  ggsave( filename = "imgs/life_tables/e0_var_plot.png", width = 7, height = 5)  
