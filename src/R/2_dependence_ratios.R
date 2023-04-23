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
           when agegrpstart < 15 then '0-14'
           when agegrpstart < 60 then '15-59'
           else '60+'
         end as pop_type,
         sum(poptotal) as pop_total
    from wpp2022.population
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     and midperiod in (1960,1970,1980,1990,2000,2010,2020)
     -- and midperiod between 1960 and 2020
group by 1,2,3
order by 1, 2
    ;
"
raw_long <- dbGetQuery( conn, statement = sql_query )

## converte para formato 'wide' e calcula razões de dependência
raw_wide <- raw_long %>%
  pivot_wider( 
    id_cols = 1:2,
    names_from = pop_type,
    values_from = pop_total
    ) %>% 
  mutate(
    total = (`0-14` + `60+`) / `15-59`,
    jovens = `0-14` / `15-59`,
    idosos = `60+` / `15-59`
  )

## novamente no formato longo para basear os gráficos
dr_base <- raw_wide %>%
  select( -c(`0-14`,`15-59`,`60+`)) %>% 
  pivot_longer( cols = -(1:2)) 

## comparação lado-a-lado entre países
dr_facet_iso3code <- dr_base %>% 
  ggplot(
    aes( 
      x = year,
      y = value,
      color = name
    )
  ) + 
  geom_point() + 
  geom_line() + 
  labs(
    y = 'Razão de dependência',
    x = 'ano',
    color = '',
    group = '',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  ) + 
  guides(color = guide_legend(reverse=TRUE)) +
  facet_grid(~iso3_code) + 
  theme(
    legend.position = 'top'
  )

dr_facet_iso3code +
  ggsave( filename = "imgs/dependence_ratios/dr_facet_iso3code.png", width = 9, height = 5)

## comparação dos países por tipo de dependência
dr_facet_poptype <- dr_base %>% 
  ggplot(
    aes( 
      x = year,
      y = value,
      color = iso3_code
    )
  ) + 
  geom_point() + 
  geom_line() + 
  labs(
    y = 'Razão de dependência',
    x = 'ano',
    color = '',
    group = '',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  ) + 
  guides(color = guide_legend(reverse=TRUE)) +
  facet_wrap(~name, scales = "free_y") + 
  theme(
    legend.position = 'top'
  )

dr_facet_poptype +
  ggsave( filename = "imgs/dependence_ratios/dr_facet_poptype.png", width = 9, height = 5)
