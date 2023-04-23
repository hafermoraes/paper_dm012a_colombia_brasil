\timing

-- cria e conecta-se ao banco ~textos_nepo~
\c wpp;

-- cria schema ~wpp2022~ para a versão 2022 dos dados da World Population Prospects
          create schema wpp2022;

-- Estoque de população (arquivo ~WPP2022_PopulationBySingleAgeSex_Medium_1950-2021.csv~)
-- drop table if exists wpp2022.population
           create table wpp2022.population (
                        sortorder integer,
                        locid integer,
                        notes varchar(20),
                        iso3_code varchar(20),
                        iso2_code varchar(20),
                        sdmx_code integer,
                        loctypeid integer,
                        loctypename varchar(255),
                        parentid integer,
                        location varchar(255),
                        varid integer,
                        variant varchar(255),
                        time integer,
                        midperiod integer,
                        agegrp varchar(20),
                        agegrpstart integer,
                        agegrpspan integer,
                        popmale real,
                        popfemale real,
                        poptotal real
                        );

-- importa população na tabela ~population~
-- /pg_data/ existe dentro do docker do postgres!
                   copy wpp2022.population
                   from '/pg_data/WPP2022_PopulationBySingleAgeSex_Medium_1950-2021.csv'
              delimiter ','
                    csv
                 header -- ignora linha de nomes de coluna
                      ; 


-- Indicadores de Fecundidade (arquivo ~WPP2022_Fertility_by_Age5.csv~)
-- drop table if exists wpp2022.fertility
           create table wpp2022.fertility (
                        sortorder integer,
                        locid integer,
                        notes varchar(20),
                        iso3_code varchar(20),
                        iso2_code varchar(20),
                        sdmx_code integer,
                        loctypeid integer,
                        loctypename varchar(255),
                        parentid integer,
                        location varchar(255),
                        varid integer,
                        variant varchar(255),
                        time integer,
                        midperiod real,
                        agegrp varchar(10),
                        agegrpstart varchar(10),
                        agegrpspan varchar(10),
                        asfr real,
                        pasfr real,
                        births real
                        );

-- importa indicadores de fecundidade na tabela ~fertility~
-- /pg_data/ existe dentro do docker do postgres!
                   copy wpp2022.fertility
                   from '/pg_data/WPP2022_Fertility_by_Age5.csv'
              delimiter ','
                    csv
                 header -- ignora linha de nomes de coluna
                      ; 


-- Tábuas de Vida Abreviadas (arquivo ~WPP2022_Life_Table_Abridged_Medium_1950-2021.csv~)
-- drop table if exists wpp2022.lifetables
           create table wpp2022.lifetables (
                        sortorder integer,
                        locid integer,
                        notes varchar(20),
                        iso3_code varchar(20),
                        iso2_code varchar(20),
                        sdmx_code integer,
                        loctypeid integer,
                        loctypename varchar(255),
                        parentid integer,
                        location varchar(255),
                        varid integer,
                        variant varchar(255),
                        time integer,
                        midperiod real,
                        sexid integer,
                        sex varchar(10),
                        agegrp varchar(10),
                        agegrpstart varchar(10),
                        agegrpspan varchar(10),
                        mx real,
                        qx real,
                        px real,
                        lx real,
                        dx real,
                        uppercase_lx real,
                        uppercase_sx real,
                        uppercase_tx real,
                        ex real,
                        ax real
                        );

-- importa tábuas de vida na tabela ~lifetables~
-- /pg_data/ existe dentro do docker do postgres!
                   copy wpp2022.lifetables
                   from '/pg_data/WPP2022_Life_Table_Abridged_Medium_1950-2021.csv'
              delimiter ','
                    csv
                 header -- ignora linha de nomes de coluna
                      ; 

