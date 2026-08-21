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

`Painel_NoHARM.pbix` já contém a conexão com o Supabase, as tabelas
importadas e uma nova página **Paciente-dia**, construída sobre a tabela
`df_pacientedia`, com:

- **Card — Total de Pacientes-dia**: contagem de registros de `df_pacientedia`.
- **Card — Tempo Total de Avaliação**: soma da coluna `tempo_de_avaliacao`.
- **Card — Paciente-dia Checados**: contagem de registros com `checado = 1`.
- **Gráfico temporal por período**: linha com a contagem de paciente-dia por
  `periodo` (coluna `AAAA-MM` já calculada no transform).
- **Filtro temporal por período**: slicer sobre a coluna `periodo`.
- **Gráfico por setor**: barras com a contagem de paciente-dia por `setor`.

O botão de navegação que já existia na capa do relatório foi mantido
apontando para essa página.

### Sobre a primeira tentativa (arquivo "corrompido")

Uma primeira versão deste arquivo falhou ao abrir ("corrompido ou criado por
uma versão não reconhecida"). Causa: este `.pbix` foi baixado do Power BI
Service (`Metadata` interno mostra `"CreatedFrom":"Cloud"`) e carregava um
part `SecurityBindings` — uma assinatura de integridade do pacote que
qualquer edição feita por fora do Power BI Desktop invalida. A correção
(documentada pela comunidade Power BI para esse exato cenário) é remover o
part `SecurityBindings` e a sua entrada em `[Content_Types].xml` antes de
reempacotar; o Power BI Desktop recria esse part sozinho ao salvar. Essa
correção já foi aplicada ao `.pbix` deste repositório.

Como este ambiente não tem Power BI Desktop instalado para renderizar e
validar visualmente o resultado, abra o arquivo no Desktop e confira o
layout/formatação antes de publicar. Se algum visual aparecer com erro de
campo, **[PACIENTE_DIA_GUIA.md](PACIENTE_DIA_GUIA.md)** traz a mesma
especificação (medidas DAX, campos e tipos de visual) para reconstruir a
página manualmente como alternativa.
