let
  Consulta = SharePoint.Tables("https://jcbrothers.sharepoint.com/sites/FantasyWork", [ApiVersion = 15]),
  Navegação = Consulta{[Id = "7eadc7f6-2de1-4fc3-b0cc-8e9d0aa80635"]}[Items],
  
  #"As outras colunas foram removidas" = 
    Table.SelectColumns(Navegação, {"ID_NIVEL3", "DESCRICAO", "ID_NIVEL4", "CODCONTAB"}),
  
  #"Colunas mescladas" = 
    Table.CombineColumns(Table.TransformColumnTypes(#"As outras colunas foram removidas", {{"DESCRICAO", type text}, {"CODCONTAB", type text}}), {"CODCONTAB", "DESCRICAO"}, Combiner.CombineTextByDelimiter(" - ", QuoteStyle.None), "Descricao_nivel_3"),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"Colunas mescladas", {{"ID_NIVEL4", Int64.Type}, {"ID_NIVEL3", Int64.Type}})
in
  #"Tipo de coluna alterado"