let
  Consulta = SharePoint.Tables("https://jcbrothers.sharepoint.com/sites/FantasyWork", [ApiVersion = 15]),
  Navegação = Consulta{[Id = "19192892-9aa1-4a9c-b0d8-b5873204b6a3"]}[Items],
  
  #"As outras colunas foram removidas" = 
    Table.SelectColumns(Navegação, {"ID_NIVEL4", "DESCRICAO", "CODCONTAB"}),
  
  #"Colunas mescladas" = 
    Table.CombineColumns(
        Table.TransformColumnTypes(#"As outras colunas foram removidas", {{"DESCRICAO", type text}, {"CODCONTAB", type text}}), 
        {"CODCONTAB", "DESCRICAO"}, Combiner.CombineTextByDelimiter(" - ", QuoteStyle.None), "Descricao_nivel_4"
    ),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"Colunas mescladas", {{"ID_NIVEL4", Int64.Type}})
in
  #"Tipo de coluna alterado"