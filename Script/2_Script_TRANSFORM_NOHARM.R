
# =============================================================================

df_pacientedia <-
  df_pacientedia %>%
  mutate(
    data = substring(data, 1, 10),
    periodo = format(dmy(data), "%Y-%m"))

df_prescricoes <-
  df_prescricoes %>%
  mutate(
    data = substring(data, 1, 10),
    periodo = format(dmy(data), "%Y-%m"))

df_intervencoes <-
  df_intervencoes %>%
  mutate(
    data = substring(data, 1, 10),
    periodo = format(dmy(data), "%Y-%m"))

df_acoes <-
  df_acoes %>%
  mutate(
    data = substring(data, 1, 10),
    periodo = format(dmy(data), "%Y-%m"))

df_farmaco <-
  df_farmaco %>%
  mutate(
    data_economia_inicial = substring(data_economia_inicial, 1, 10),
    periodo = format(dmy(data_economia_inicial), "%Y-%m"))

# =============================================================================

datas_todas <- c(
  dmy(df_pacientedia$data),
  dmy(df_prescricoes$data),
  dmy(df_intervencoes$data),
  dmy(df_acoes$data),
  dmy(df_farmaco$data_economia_inicial)
)

data_minima <- as.Date(min(datas_todas, na.rm = TRUE))
data_maxima <- as.Date(max(datas_todas, na.rm = TRUE))

message("dCalendario cobrirá de ", data_minima, " até ", data_maxima)

# --- 2. Construir a tabela calendário, um registro por dia ----------------------

dCalendario <- tibble(
  data = seq.Date(from = data_minima, to = data_maxima, by = "day")) %>%
  mutate(
    ano             = year(data),
    mes             = month(data),
    nome_mes        = format(data, "%B"),
    nome_mes_abrev  = format(data, "%b"),
    mes_ano         = format(data, "%m/%Y"),
    periodo         = format(data, "%Y-%m"),   # mesma chave "AAAA-MM" usada nas tabelas fato
    trimestre       = paste0("T", quarter(data)),
    dia_da_semana   = format(data, "%A"),
    dia_do_mes      = day(data),
    fim_de_semana   = if_else(wday(data, week_start = 1) > 5, "Sim", "Não")
  )

rm(data_maxima, data_minima, datas_todas)

# --- 3. Conferência rápida ---------------------------------------------------------

cat("\n===== dCalendario: primeiras linhas =====\n")
print(head(dCalendario))

cat("\n===== dCalendario: total de dias =====\n")
print(nrow(dCalendario))


# --- 1. Unir os setores distintos de todas as tabelas fato ----------------------

dSetor <- bind_rows(

  df_pacientedia  %>% distinct(setor),
  df_prescricoes  %>% distinct(setor),
  df_intervencoes %>% distinct(setor),
  df_acoes        %>% distinct(setor),
  df_farmaco      %>% distinct(setor)) %>%

  distinct(setor) %>%
  filter(!is.na(setor), setor != "") %>%
  arrange(setor) %>%
  mutate(id_setor = row_number()) %>%
  relocate(id_setor, .before = setor)

# --- 2. Conferência rápida ---------------------------------------------------------

cat("\n===== dSetor =====\n")
print(dSetor)

cat("\n===== Total de setores distintos =====\n")
print(nrow(dSetor))
