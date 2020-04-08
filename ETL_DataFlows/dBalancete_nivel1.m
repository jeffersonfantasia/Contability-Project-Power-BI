let
  Consulta = SharePoint.Tables("https://jcbrothers.sharepoint.com/sites/FantasyWork", [ApiVersion = 15]),
  Navegação = Consulta{[Id = "70057c82-b8a8-4dc2-91c6-46b14fac7d14"]}[Items],
  
  #"As outras colunas foram removidas" = 
    Table.SelectColumns(Navegação, {"ID_NIVEL1", "Descricao_nivel1", "ID_NIVEL2", "CODCONTAB"}),
  
  #"Colunas mescladas" = 
    Table.CombineColumns(
        Table.TransformColumnTypes(#"As outras colunas foram removidas", {{"Descricao_nivel1", type text}, {"CODCONTAB", type text}}),
        {"CODCONTAB", "Descricao_nivel1"}, Combiner.CombineTextByDelimiter(" - ", QuoteStyle.None), "Descricao_nivel_1"
    ),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"Colunas mescladas", {{"ID_NIVEL1", Int64.Type}, {"ID_NIVEL2", Int64.Type}})
in
  #"Tipo de coluna alterado"