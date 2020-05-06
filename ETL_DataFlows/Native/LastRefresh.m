let
  Origem = 
    DateTimeZone.SwitchZone( DateTimeZone.LocalNow(), -3),
  
  #"Convertido em tabela" = 
    #table(1, {{Origem}}),
  
  #"Colunas renomeadas" = 
    Table.RenameColumns(#"Convertido em tabela", {{"Column1", "LastRefresh"}}),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"Colunas renomeadas", {{"LastRefresh", type datetimezone}})
in
  #"Tipo de coluna alterado"