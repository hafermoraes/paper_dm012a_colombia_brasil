\timing

--drop database if exists textos_nepo;
--        create database textos_nepo;

-- cria e conecta-se ao banco ~textos_nepo~
\c textos_nepo;

-- cria schema ~wpp2022~ para a versão 2022 dos dados da World Population Prospects
          create schema wpp2022;

-- Indicadores demográficos (arquivo ~WPP2022_Demographic_Indicators_Medium.csv~)
-- drop table if exists wpp2022.demographic_indicators
           create table wpp2022.demographic_indicators (
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
                        tpopulation1jan real,
                        tpopulation1july real,
                        tpopulationmale1july real,
                        tpopulationfemale1july real,
                        popdensity real,
                        popsexratio real,
                        medianagepop real,
                        natchange real,
                        natchangert real,
                        popchange real,
                        popgrowthrate real,
                        doublingtime real,
                        births real,
                        births1519 real,
                        cbr real,
                        tfr real,
                        nrr real,
                        mac real,
                        srb real,
                        deaths real,
                        deathsmale real,
                        deathsfemale real,
                        cdr real,
                        lex real,
                        lexmale real,
                        lexfemale real,
                        le15 real,
                        le15male real,
                        le15female real,
                        le65 real,
                        le65male real,
                        le65female real,
                        le80 real,
                        le80male real,
                        le80female real,
                        infantdeaths real,
                        imr real,
                        lbsurvivingage1 real,
                        under5deaths real,
                        q5 real,
                        q0040 real,
                        q0040male real,
                        q0040female real,
                        q0060 real,
                        q0060male real,
                        q0060female real,
                        q1550 real,
                        q1550male real,
                        q1550female real,
                        q1560 real,
                        q1560male real,
                        q1560female real,
                        netmigrations real,
                        cnmr real
                        );

-- importa indicadores demográficos na tabela ~demographic_indicators~
-- /pg_data/ existe dentro do docker do postgres!
                   copy wpp2022.demographic_indicators
                   from '/pg_data/WPP2022_Demographic_Indicators_Medium.csv'
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
-- drop table if exists wpp2022.life_tables
           create table wpp2022.life_tables (
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
                        lx real,
                        sx real,
                        tx real,
                        ex real,
                        ax real
                        );

-- importa tábuas de vida na tabela ~life_tables~
-- /pg_data/ existe dentro do docker do postgres!
                   copy wpp2022.life_tables
                   from '/pg_data/WPP2022_Life_Table_Abridged_Medium_1950-2021.csv'
              delimiter ','
                    csv
                 header -- ignora linha de nomes de coluna
                      ; 

