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
         time as year,
         cbr,
         cdr,
         tpopulationmale1july + tpopulationfemale1july as pop
    from wpp2022.demographic_indicators
   where variant = 'Medium'
     and iso3_code in ('COL','BRA')
     -- and time in (1960,1970,1980,1990,2000,2010,2020)
     and time between 1950 and 2030
order by 1,2
       ;

"
raw_wide <- dbGetQuery( conn, statement = sql_query )


raw_wide %>%
  pivot_longer(
    cols = c(cbr,cdr,pop)) %>%
  pivot_wider(
    id_cols = c(name, year),
    names_from=iso3_code,
    values_from=value
  ) %>%
  arrange(name,year) %>%
  write_csv2(
    './data/demographic_transition.csv'
  )

## gráfico da transição demográfica
## Brasil
dt_brasil <- raw_wide %>%
  filter(iso3_code == 'BRA') %>% 
  ggplot( aes(x = year)) + 
  geom_line( aes( y = cdr), lty=1) + 
  geom_line( aes( y = cbr), lty=2) +
  geom_bar( aes( y = pop/5000), stat = 'identity', alpha=0.4, size=0.1) + 
  geom_vline( xintercept = 2022, lty=2, col='red') + 
  scale_y_continuous(
    name = "Taxas por 1.000 (TBN e TBM)", 
    sec.axis = sec_axis(~.*5, name = "População (Milhões de pessoas)")
  ) + 
  labs(
    x = 'ano',
    title = 'Brasil',
    subtitle = 'Transição demográfica',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  )

dt_brasil +
  ggsave( filename = "imgs/demographic_transition/dt_brasil.png", width = 10, height = 5)  
  
## Colombia
dt_colombia <- raw_wide %>%
  filter(iso3_code == 'COL') %>% 
  ggplot( aes(x = year)) + 
  geom_line( aes( y = cdr), lty=1) + 
  geom_line( aes( y = cbr), lty=2) +
  geom_bar( aes( y = pop/1000), stat = 'identity', alpha=0.4, size=0.1) + 
  geom_vline( xintercept = 2022, lty=2, col='red') + 
  scale_y_continuous(
    name = "Taxas por 1.000 (TBN e TBM)", 
    sec.axis = sec_axis(~.*1, name = "População (Milhões de pessoas)")
  ) + 
  labs(
    x = 'ano',
    title = 'Colômbia',
    subtitle = 'Transição demográfica',
    caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
  )

dt_colombia +
  ggsave( filename = "imgs/demographic_transition/dt_colombia.png", width = 10, height = 5)  


## Tudo em um gráfico só...
dt_bra_col <- raw_wide %>%
  ggplot( aes(x = year, color = iso3_code)) + 
  geom_line( aes( y = cdr), lty=1) + 
  geom_line( aes( y = cbr), lty=5) +
  geom_bar( 
    aes(y = pop/5000, fill = iso3_code), 
    stat = 'identity', 
    position = position_nudge(), 
    alpha=0.2, 
    size=0.08
  ) + 
  geom_vline( xintercept = 2022, lty=2, col='black') + 
  scale_y_continuous(
    name = "Taxas por 1.000 (TBN e TBM)", 
    sec.axis = sec_axis(~.*5, name = "População (Milhões de pessoas)")
  ) + 
  labs(
    x = 'ano',
    fill = "",
    color = ""
  )

dt_bra_col +
  ggsave( filename = "imgs/demographic_transition/dt_bra_col.png", width = 10, height = 5)  
