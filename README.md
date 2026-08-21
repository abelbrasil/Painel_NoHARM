# Painel NoHarm

Pipeline de ETL em R (extract → transform → load) que alimenta um Data
Warehouse no Supabase (Postgres) e um painel Power BI conectado a esse DW.

## Estrutura

```
01_Script_ALL_NOHARM.R          # orquestra todo o pipeline (extract -> transform -> load)
Script/
  0_Script_CREDENCIAIS_NOHARM.R # conexão com o banco (credenciais via .Renviron)
  1_Script_EXTRACT_NOHARM.R     # lê e une os CSVs da pasta Input/
  2_Script_TRANSFORM_NOHARM.R   # transformações e criação de dCalendario/dSetor
  9_Script_LOAD_DW_NOHARM.R     # grava as tabelas no schema sq_noharm do Supabase
Input/                          # CSVs de origem (não versionados, veja .gitignore)
Rdata/                          # snapshot .Rdata do pipeline (não versionado)
Painel_NoHARM.pbix              # relatório Power BI conectado ao DW
```

## Configurando as credenciais do banco

As credenciais de acesso ao Postgres do Supabase **nunca** ficam hardcoded no
código. Elas são lidas de variáveis de ambiente carregadas de um arquivo
`.Renviron` local (ignorado pelo git):

1. Copie `.Renviron.example` para `.Renviron` na raiz do projeto.
2. Preencha `NOHARM_DB_PASSWORD` com a senha real do Supabase.
3. Os scripts chamam `conectar_noharm()` (definida em
   `Script/0_Script_CREDENCIAIS_NOHARM.R`) para obter a conexão — nenhum
   outro script precisa saber a senha.

## Rodando o pipeline

1. Coloque os CSVs exportados do NoHarm na pasta `Input/` (arquivos
   `*pacientedia*.csv`, `*prescricoes*.csv`, `*intervencoes*.csv`,
   `*acoes*.csv`, `*farmacoeconomia*.csv`).
2. Ajuste o `setwd()` no início de `01_Script_ALL_NOHARM.R` para a pasta do
   projeto na sua máquina.
3. Rode `01_Script_ALL_NOHARM.R`. Ele executa o extract, o transform, salva
   um snapshot em `Rdata/` e grava as tabelas no schema `sq_noharm` do
   Supabase (`dCalendario`, `DataRelatorio`, `dSetor`, `df_acoes`,
   `df_farmaco`, `df_pacientedia`, `df_prescricoes`).

## Painel Power BI — página "Paciente-dia"

`Painel_NoHARM.pbix` neste repositório é o arquivo **original, sem
alterações binárias** — ele já contém a conexão com o Supabase e as tabelas
importadas, incluindo `df_pacientedia`.

Este arquivo foi baixado do Power BI Service (é um pbix "Cloud"), o que
significa que carrega uma assinatura interna de integridade
(`SecurityBindings`). Editar o pacote `.pbix` por fora do Power BI Desktop
invalida essa assinatura e o arquivo passa a ser recusado como "corrompido"
ao abrir — foi o que aconteceu numa primeira tentativa de montar a página
"Paciente-dia" editando o JSON do relatório diretamente. Por isso a página
**não** foi embutida no `.pbix` — precisa ser criada no Power BI Desktop.

Veja **[PACIENTE_DIA_GUIA.md](PACIENTE_DIA_GUIA.md)** para o passo a passo
completo: as 3 medidas DAX, os 6 visuais pedidos (cards, gráfico e filtro
temporal por período, gráfico por setor) e os nomes exatos de coluna,
já conferidos contra o schema real do modelo embutido no arquivo.
