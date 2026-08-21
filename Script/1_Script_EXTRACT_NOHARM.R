
# =============================================================================

unir_planilhas <- function(tema, pasta_input = "Input") {

  arquivos <- list.files(
    path       = pasta_input,
    pattern    = paste0("(?i)", tema, ".*\\.csv$"),
    full.names = TRUE
  )

  if (length(arquivos) == 0) {
    stop("Nenhum arquivo '", tema, "*.csv' encontrado em: ", pasta_input)
  }

  message("[", tema, "] arquivos encontrados:\n",
          paste(" -", basename(arquivos), collapse = "\n"))

  ler_um <- function(caminho) {
    df <- read_csv(
      caminho,
      locale = locale(encoding = "UTF-8"),
      na = c("", "NA"),
      col_types = cols(.default = col_character()),
      show_col_types = FALSE)

    df <- clean_names(df)

    df <- as.data.frame(df, stringsAsFactors = FALSE)

    attr(df, "spec")     <- NULL

    attr(df, "problems") <- NULL

    df$arquivo_origem <- basename(caminho)

    df

  }

  df_uniao <- map_dfr(arquivos, ler_um)

  df_uniao <- suppressMessages(
    type_convert(df_uniao, na = c("", "NA"), locale = locale(decimal_mark = ","))
  )

  message("[", tema, "] total de linhas após a união: ", nrow(df_uniao))

  df_uniao
}

# =============================================================================

df_pacientedia <- unir_planilhas("pacientedia")
df_prescricoes <- unir_planilhas("prescricoes")
df_intervencoes <- unir_planilhas("intervencoes")
df_acoes <- unir_planilhas("acoes")
df_farmaco <- unir_planilhas("farmacoeconomia")

rm(unir_planilhas)

# =============================================================================
