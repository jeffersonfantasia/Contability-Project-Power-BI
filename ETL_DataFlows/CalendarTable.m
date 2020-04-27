let
  DataAtual = Date.From( 
      DateTimeZone.SwitchZone( DateTimeZone.LocalNow(),-3) 
    ),
  
  DataInicial = Date.StartOfYear( 
      Date.AddYears( DataAtual, -7 ) 
    ),
  
  DataFinal = Date.EndOfYear( 
      Date.AddYears( DataAtual, 1 ) 
    ),
  
  Dias = Duration.Days( DataFinal - DataInicial) + 1,
  
  ListaCalendario = List.Dates( DataInicial, Dias, #duration(1, 0, 0, 0) ),
  
  #"Convertido para Tabela" = Table.FromList(ListaCalendario, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
  
  #"Colunas Renomeadas" = Table.RenameColumns(#"Convertido para Tabela", {{"Column1", "Data Base"}}),
  
  #"Tipo Alterado" = Table.TransformColumnTypes(#"Colunas Renomeadas", {{"Data Base", type date}}),
  
  #"Ano Inserido" = Table.AddColumn(#"Tipo Alterado", "Ano", each Date.Year([Data Base]), Int64.Type),
  
  #"Mês Inserido" = Table.AddColumn(#"Ano Inserido", "Nº Mês", each Date.Month([Data Base]), Int64.Type),
  
  #"Nome do Mês Inserido" = Table.AddColumn(#"Mês Inserido", "Mês", each Date.MonthName([Data Base]), type text),
  
  #"Colocar Cada Palavra Em Maiúscula" = Table.TransformColumns( #"Nome do Mês Inserido",{{"Mês", Text.Proper, type text}} ),
  
  #"Trimestre Inserido" = Table.AddColumn(#"Colocar Cada Palavra Em Maiúscula", "Trimestre", each Date.QuarterOfYear([Data Base]), Int64.Type),
  
  #"Sufixo Adicionado" = Table.TransformColumns(#"Trimestre Inserido", {{"Trimestre", each Text.From(_, "pt-BR") & "º Trimestre", type text}}),
  
  #"Semana do Ano Inserida" = Table.AddColumn(#"Sufixo Adicionado", "Nº Semana Ano", each Date.WeekOfYear([Data Base]), Int64.Type),
  
  #"Semana do Mês Inserida" = Table.AddColumn(#"Semana do Ano Inserida", "Nº Semana Mês", each Date.WeekOfMonth([Data Base]), Int64.Type),
  
  #"Dia Inserido" = Table.AddColumn(#"Semana do Mês Inserida", "Dia", each Date.Day([Data Base]), Int64.Type),
  
  #"Nome do Dia Inserido" = Table.AddColumn(#"Dia Inserido", "Nome do Dia", each Date.DayOfWeekName([Data Base]), type text),
  
  #"Colocar Cada Palavra Em Maiúscula1" = Table.TransformColumns( #"Nome do Dia Inserido",{{"Nome do Dia", Text.Proper, type text}}),
  
  #"Primeiros Caracteres Inseridos" = Table.AddColumn(#"Colocar Cada Palavra Em Maiúscula1", "Mês Abrv", each Text.Start([Mês], 3), type text),
  
  #"Coluna Mesclada Inserida" = Table.AddColumn(#"Primeiros Caracteres Inseridos", "Mês Abrev-Ano", each Text.Combine({[Mês Abrv], Text.From([Ano], "pt-BR")}, "-"), type text),
  
  #"Linhas Filtradas" = Table.SelectRows( #"Coluna Mesclada Inserida", each true ),
  
  #"Coluna Duplicada" = Table.DuplicateColumn(#"Linhas Filtradas", "Nº Semana Ano", "Semana Ano"),
  
  #"Sufixo Adicionado1" = Table.TransformColumns(#"Coluna Duplicada", {{"Semana Ano", each Text.From(_, "pt-BR") & "º Sem. Ano", type text}}),
  
  #"Coluna Duplicada1" = Table.DuplicateColumn(#"Sufixo Adicionado1", "Nº Semana Mês", "Semana Mês"),
  
  #"Sufixo Adicionado2" = Table.TransformColumns(#"Coluna Duplicada1", {{"Semana Mês", each Text.From(_, "pt-BR") & "º Semana", type text}}),
  
  #"Cálculo Mês Atual" = 
    Table.AddColumn(#"Sufixo Adicionado2", "Cálculo Mês Atual", each 
        ( Date.Year( [Data Base] ) - Date.Year( DataAtual ) ) * 12 
        + Date.Month( [Data Base] ) 
        - Date.Month( DataAtual ), Int64.Type),
  
  #"Cálculo Trimestre Atual" = 
    Table.AddColumn(#"Cálculo Mês Atual", "Cálculo Trimestre Atual", each /*Year Difference*/
        ( Date.Year( [Data Base] ) - Date.Year( DataAtual ) ) * 4   /*Quarter Difference*/
        + Number.RoundUp( Date.Month( [Data Base] ) / 3 )
        - Number.RoundUp( Date.Month( DataAtual ) / 3 ), Int64.Type),
  
  #"Cálculo Ano Atual" = 
    Table.AddColumn(#"Cálculo Trimestre Atual", "Cálculo Ano Atual", each 
        Date.Year( [Data Base] ) 
        - Date.Year( DataAtual ), Int64.Type),
  
  #"Cálculo Semana Atual" = 
    Table.AddColumn(#"Cálculo Ano Atual", "Cálculo Semana Atual", each 
        ( Date.Year( [Data Base] ) - Date.Year( DataAtual ) ) *53 
        + Date.WeekOfYear( [Data Base] ) 
        - Date.WeekOfYear( DataAtual ), Int64.Type),
  
  #"Marcação Data Futura" = 
    Table.AddColumn(#"Cálculo Semana Atual" , "Período", each 
        if [Data Base] = DataAtual 
        then "Hoje" 
        else if [Data Base] > DataAtual then "Futuro" 
        else "Passado", type text),
  
  #"Nº Mês-Ano" = Table.AddColumn(#"Marcação Data Futura", "Nº Mês-Ano", each [Ano] * 100 + [Nº Mês], Int64.Type),
  
  #"Nome Mês-Ano" = Table.AddColumn( #"Nº Mês-Ano", "MêsAno Abrev", each [Mês] & "-" & Text.End( Text.From( [Ano] ),2 ) ),
  
  #"Nome Mês-Ano Longo" = Table.AddColumn(#"Nome Mês-Ano", "MêsAno Completo", each [Mês] & "-" & Text.From([Ano])),
  
  #"Nº Dia Semana" = Table.AddColumn(#"Nome Mês-Ano Longo", "Nº Dia Semana", each Date.DayOfWeek([Data Base]), Int64.Type),
  
  #"Dia da Semana" = Table.AddColumn( #"Nº Dia Semana", "Dia Semana Abrev", each Text.Proper( Text.Start( Date.DayOfWeekName( [Data Base] ),3 ) ), type text ),
  
  #"Fim de Semana" = 
    Table.AddColumn( #"Dia da Semana", "Semana ou Fim Semana", each 
        if ( [Nº Dia Semana] = 0 or [Nº Dia Semana] = 6 )
        then "Fim de Semana"
        else "Semana"),
  
  #"Transformar colunas" = Table.TransformColumnTypes(#"Fim de Semana", {{"MêsAno Abrev", type text}, {"MêsAno Completo", type text}, {"Semana ou Fim Semana", type text}}),
  
  #"Substituir erros" = Table.ReplaceErrorValues(#"Transformar colunas", {{"MêsAno Abrev", null}, {"MêsAno Completo", null}, {"Semana ou Fim Semana", null}})
in
  #"Substituir erros"