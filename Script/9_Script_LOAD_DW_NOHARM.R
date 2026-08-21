

# _____________________
# CONECTAR AO BANCO DE DADOS (SUPABASE / POSTGRES) ####

    source("Script/0_Script_CREDENCIAIS_NOHARM.R")

    con <- conectar_noharm()

    conjuntos_de_dados <- list(
      dCalendario      = dCalendario,
      DataRelatorio    = DataRelatorio,
      dSetor           = dSetor,
      df_acoes         = df_acoes,
      df_farmaco       = df_farmaco,
      df_pacientedia   = df_pacientedia,
      df_prescricoes   = df_prescricoes
    )

    schema_alvo <- "sq_noharm"

    for (nome in names(conjuntos_de_dados)) {
      dbWriteTable(
        con,
        Id(schema = schema_alvo, table = nome),
        conjuntos_de_dados[[nome]],
        overwrite = TRUE
      )
      message("Tabela '", schema_alvo, ".", nome, "' escrita com sucesso.")
    }

    dbDisconnect(con)

    rm(schema_alvo, nome)
    rm(con)
    rm(conjuntos_de_dados)
