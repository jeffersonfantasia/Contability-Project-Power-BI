let
  Consulta = SharePoint.Tables("https://jcbrothers.sharepoint.com/sites/FantasyWork", [ApiVersion = 15]),
  Navegação = Consulta{[Id = "214febf2-ca20-43b1-90e9-77bc74d22042"]}[Items],
  
  #"As outras colunas foram removidas" = 
    Table.SelectColumns(Navegação, {"ID_NIVEL2", "Descricao_nivel2", "ID_NIVEL3", "CODCONTAB"}),
  
  #"Colunas mescladas" = 
    Table.CombineColumns(Table.TransformColumnTypes(#"As outras colunas foram removidas", {{"Descricao_nivel2", type text}, {"CODCONTAB", type text}}), {"CODCONTAB", "Descricao_nivel2"}, Combiner.CombineTextByDelimiter(" - ", QuoteStyle.None), "Descricao_nivel_2"),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"Colunas mescladas", {{"ID_NIVEL2", Int64.Type}, {"ID_NIVEL3", Int64.Type}})
in
  #"Tipo de coluna alterado"