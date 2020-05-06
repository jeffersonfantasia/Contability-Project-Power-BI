let
  Consulta = SharePoint.Tables("https://jcbrothers.sharepoint.com/sites/FantasyWork", [ApiVersion = 15]),
  Navegação = Consulta{[Id = "453d6fe9-0a90-4ba5-90d5-78fbfa56a2db"]}[Items],
  
  #"As outras colunas foram removidas" = 
    Table.SelectColumns(Navegação, {"DATA", "VALOR", "CONTADEBITO", "CONTACREDITO", "HISTORICO", "CODFILIAL", "CODBANCO"}),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"As outras colunas foram removidas", {{"CODBANCO", Int64.Type}, {"CODFILIAL", type text}, {"HISTORICO", type text}, {"CONTACREDITO", type text}, {"CONTADEBITO", type text}, {"VALOR", type number}, {"DATA", type date}})
in
  #"Tipo de coluna alterado"