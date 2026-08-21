# =============================================================================
# CREDENCIAIS DE CONEXAO COM O BANCO DE DADOS (SUPABASE / POSTGRES)
# =============================================================================
#
# As credenciais NUNCA devem ficar hardcoded no codigo-fonte. Elas sao lidas
# de variaveis de ambiente, carregadas a partir de um arquivo ".Renviron"
# local que NAO e versionado no git (veja .gitignore).
#
# Como configurar (uma unica vez por maquina):
#   1) Copie ".Renviron.example" para ".Renviron" na raiz do projeto
#   2) Preencha NOHARM_DB_PASSWORD com a senha real do Supabase
#   3) Pronto: os demais scripts chamam conectar_noharm() para obter a conexao
#
# =============================================================================

library(DBI)
library(RPostgres)

if (file.exists(".Renviron")) {
  readRenviron(".Renviron")
}

conectar_noharm <- function() {

  senha <- Sys.getenv("NOHARM_DB_PASSWORD")

  if (identical(senha, "")) {
    stop(
      "NOHARM_DB_PASSWORD nao definida. Copie '.Renviron.example' para ",
      "'.Renviron' e preencha a senha do Supabase antes de conectar."
    )
  }

  dbConnect(
    RPostgres::Postgres(),
    host     = Sys.getenv("NOHARM_DB_HOST", "aws-0-us-west-2.pooler.supabase.com"),
    port     = as.integer(Sys.getenv("NOHARM_DB_PORT", "5432")),
    dbname   = Sys.getenv("NOHARM_DB_NAME", "postgres"),
    user     = Sys.getenv("NOHARM_DB_USER", "postgres.upvjwkbdlptfnnwcqfct"),
    password = senha
  )
}
