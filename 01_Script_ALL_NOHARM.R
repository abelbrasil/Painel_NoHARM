
# 1) CARREGAR OS PACOTES

library(readr)
library(dplyr)
library(janitor)
library(purrr)
library(tidyr)
library(lubridate)


# 2) EXECUTAR PROCESSO DE EXTRACT E TRANSFORM DO NAME_SUBPROJECT1

setwd("X:/USID/PAINEL_DADOS/MEAC/NOHARM")

source("Script/1_Script_EXTRACT_NOHARM.R")

source("Script/2_Script_TRANSFORM_NOHARM.R")

# 4) PRODUZIR TABELA DE DATAS

data_atualizacao_script = as.character(Sys.time(), format = '%d/%m/%Y %H:%M')

DataRelatorio =
  data.frame(
  data_atualizacao_script,

  stringsAsFactors = F)

rm(data_atualizacao_script)

# 5) SALVAR RDATA NA PASTA

save.image("Rdata/tables_TRANSFORM_NOHARM.Rdata")

#rm(list = ls())

# 6) ESCREVER TABELAS NO DATA WAREHOUSE (DW)

# _____________________
# CARREGAR AS TABELAS DO PROJETO ####

#load("Rdata/tables_LOAD_DW_NAME_SUBPROJECT.Rdata")
source("Script/9_Script_LOAD_DW_NOHARM.R")

rm(list = ls())
