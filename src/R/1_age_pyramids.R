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
    pop_perc = pop / pop_total,
    sign_perc = ifelse(test = sex == 'male',
                       yes = -pop_perc, no = pop_perc)
  ) 

## gráfico base da pirâmide populacional
pyramid_plot_base <- pyramid_data %>% # https://www.statology.org/population-pyramid-in-r/
  ggplot( aes(x = age, fill = sex,
              y = ifelse(test = sex == 'male',
                         yes = -pop_perc, no = pop_perc))) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = abs, limits = max(pyramid_data$pop_perc) * c(-1,1)) +
  coord_flip() +
  labs(
    x = 'idade'
    ,y = "Percentual da população"
    #,title = 'Pirâmides etárias - Brasil e Colômbia'
    #,subtitle =  'Dados proveninentes do World Population Prospects/UN'
    ,caption = 'United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.'
    ,fill = ''
  )+ 
  guides(fill = guide_legend(reverse=TRUE)) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "top"
    )

## pirâmides em matriz 'longa' ( linha: anos, coluna: país )
pyramid_plot_base + 
  facet_grid(year ~ iso3_code) +
  ggsave( filename = 'age_pyramid_long.png', width = 10, height = 20)

## pirâmides em matriz 'larga' ( linha: país, coluna: anos )
pyramid_plot_base + 
  facet_grid(iso3_code ~ year) +
  ggsave( filename = 'imgs/age_pyramid_wide.png', width = 15, height = 7)

