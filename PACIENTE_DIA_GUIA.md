# Guia — Página "Paciente-dia" no Power BI Desktop

## Por que isso é um guia manual, e não algo já pronto no `.pbix`

Este `Painel_NoHARM.pbix` foi baixado do Power BI Service (`Metadata` interno
mostra `"CreatedFrom":"Cloud"` e o arquivo `Connections` referencia um
`DatasetId`/`ReportId` do serviço). Arquivos nessa condição carregam um
arquivo interno `SecurityBindings` que assina/valida a integridade do
pacote. Qualquer edição feita por fora do Power BI Desktop — mesmo um JSON
tecnicamente válido dentro do `Report/definition` — invalida essa assinatura,
e o Desktop passa a recusar o arquivo com "Não foi possível abrir o
documento... corrompido ou criado por uma versão não reconhecida".

Foi exatamente isso que aconteceu na primeira tentativa (editar o `.pbix`
diretamente pelo formato de definição de relatório/PBIR). O arquivo no repo
já foi revertido para os bytes originais — deve abrir normalmente agora.

Como este ambiente é Linux e não tem Power BI Desktop instalado, não há como
eu montar/validar o `.pbix` fim a fim por aqui. O caminho seguro é montar a
página manualmente no Power BI Desktop, na sua máquina. Abaixo estão as
especificações exatas (nomes de coluna e agregações) já conferidas contra o
schema real do modelo embutido no arquivo, para que seja só "seguir a
receita" sem precisar adivinhar nomes de campo.

## 0. Antes de tudo: confira a coluna `checado`

O card "Paciente-dia Checados" abaixo assume que `checado = 1` significa
"checado" (e `0`/`NULL` = não checado). Confirme isso rapidamente: crie uma
tabela visual temporária com `df_pacientedia[checado]` e veja os valores
distintos. Se a convenção for diferente, ajuste o valor `1` na medida
`Paciente-dia Checados` abaixo.

## 1. Criar as medidas (recomendado, em vez de agregação implícita)

Na tabela `df_pacientedia`, crie 3 medidas novas (botão direito na tabela →
"Nova medida"):

```DAX
Total Pacientes-dia = COUNTROWS(df_pacientedia)

Tempo Total de Avaliação = SUM(df_pacientedia[tempo_de_avaliacao])

Paciente-dia Checados =
CALCULATE(
    COUNTROWS(df_pacientedia),
    df_pacientedia[checado] = 1
)
```

## 2. Criar a página

Nova página → renomeie para **Paciente-dia**. Se quiser reaproveitar o botão
de navegação que já existe na capa (o ícone circular no canto inferior
direito, que hoje aponta para uma página que não existe), aponte-o para essa
nova página pelas propriedades do botão ("Ação" → "Navegação de página").

## 3. Os 6 visuais

| # | Visual | Tipo | Campos |
|---|--------|------|--------|
| 1 | Card — Total de Pacientes-dia | Cartão | `[Total Pacientes-dia]` |
| 2 | Card — Tempo Total de Avaliação | Cartão | `[Tempo Total de Avaliação]` |
| 3 | Card — Paciente-dia Checados | Cartão | `[Paciente-dia Checados]` |
| 4 | Gráfico temporal por período | Gráfico de linhas | Eixo X: `df_pacientedia[periodo]` · Valores: `[Total Pacientes-dia]` |
| 5 | Filtro temporal por período | Segmentação de dados (slicer) | Campo: `df_pacientedia[periodo]` |
| 6 | Paciente-dia por setor | Gráfico de barras | Eixo: `df_pacientedia[setor]` · Valores: `[Total Pacientes-dia]` |

`periodo` já vem pronto como texto `"AAAA-MM"` (calculado no
`2_Script_TRANSFORM_NOHARM.R`), então ordena e filtra corretamente sem
precisar de uma dimensão de calendário — não é necessário relacionamento
extra para esses dois visuais.

Sugestão de leiaute (tela 1280x720, "Ajustar à página"): os 3 cards lado a
lado no topo; a segmentação de período numa faixa estreita à esquerda; o
gráfico de linha acima do gráfico de barras, ocupando o restante da página.

## 4. Publicar

Depois de montada e conferida no Desktop, publique de volta no workspace do
Power BI Service normalmente (Arquivo → Publicar). Isso gera uma nova
versão já assinada corretamente pelo próprio Power BI, sem o problema de
integridade do `SecurityBindings`.
