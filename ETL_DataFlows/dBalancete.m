let
  Consulta = SharePoint.Tables("https://jcbrothers.sharepoint.com/sites/FantasyWork", [ApiVersion = 15]),
  Navegação = Consulta{[Id = "252a2962-99c7-49fa-b43a-2defc36db1fc"]}[Items],
  
  #"As outras colunas foram removidas" = 
    Table.SelectColumns(Navegação, {"ID_BALANCETE", "Descricao", "ID_NIVEL1", "CODCONTAB"}),
  
  #"Coluna mesclada inserida" = 
    Table.AddColumn(#"As outras colunas foram removidas", "Descricao_conta", each Text.Combine({Text.From([CODCONTAB]), Text.From([Descricao])}, " - "), type text),
  
  #"Linhas Agrupadas" = 
    Table.Group(#"Coluna mesclada inserida", {"CODCONTAB"}, {{"Tabela", each _, type table [ID_BALANCETE=number, Descricao=text, Descricao_conta=text, CODCONTAB=text, ID_NIVEL1=number]}}),
  
  #"Personalização Adicionada" = 
    Table.AddColumn(#"Linhas Agrupadas", "Personalizar", each Table.AddColumn([Tabela], "ID", each {"1-"&[CODCONTAB],"5-"&[CODCONTAB],"6-"&[CODCONTAB]})),
  
  #"Expandido Personalizar" = 
    Table.ExpandTableColumn(#"Personalização Adicionada", "Personalizar", {"ID_BALANCETE", "ID_NIVEL1", "CODCONTAB", "Descricao_conta", "ID"}, {"ID_BALANCETE", "ID_NIVEL1", "CODCONTAB.1", "Descricao_conta", "ID"}),
  
  #"ID Expandido" = 
    Table.ExpandListColumn(#"Expandido Personalizar", "ID"),
  
  #"As outras colunas foram removidas 2" = 
    Table.SelectColumns(#"ID Expandido", {"ID", "Descricao_conta", "CODCONTAB.1", "ID_NIVEL1", "ID_BALANCETE"}),
  
  #"Tipo de coluna alterado" = 
    Table.TransformColumnTypes(#"As outras colunas foram removidas 2", {{"ID", type text}, {"Descricao_conta", type text}, {"CODCONTAB.1", type text}, {"ID_NIVEL1", Int64.Type}, {"ID_BALANCETE", Int64.Type}}),
  
  #"Consultas mescladas" = 
    Table.NestedJoin(#"Tipo de coluna alterado", {"ID_NIVEL1"}, dBalancete_nivel1, {"ID_NIVEL1"}, "dBalancete_nivel1", JoinKind.LeftOuter),
  
  #"Expandido dBalancete_nivel1" = 
    Table.ExpandTableColumn(#"Consultas mescladas", "dBalancete_nivel1", {"Descricao_nivel_1", "ID_NIVEL2"}, {"Descricao_nivel_1", "ID_NIVEL2"}),
  
  #"Consultas mescladas 1" = 
    Table.NestedJoin(#"Expandido dBalancete_nivel1", {"ID_NIVEL2"}, dBalancete_nivel2, {"ID_NIVEL2"}, "dBalancete_nivel2", JoinKind.LeftOuter),
  
  #"Expandido dBalancete_nivel2" = 
    Table.ExpandTableColumn(#"Consultas mescladas 1", "dBalancete_nivel2", {"Descricao_nivel_2", "ID_NIVEL3"}, {"Descricao_nivel_2", "ID_NIVEL3"}),
  
  #"Consultas mescladas 2" = 
    Table.NestedJoin(#"Expandido dBalancete_nivel2", {"ID_NIVEL3"}, dBalancete_nivel3, {"ID_NIVEL3"}, "dBalancete_nivel3", JoinKind.LeftOuter),
  
  #"Expandido dBalancete_nivel3" = 
    Table.ExpandTableColumn(#"Consultas mescladas 2", "dBalancete_nivel3", {"Descricao_nivel_3", "ID_NIVEL4"}, {"Descricao_nivel_3", "ID_NIVEL4"}),
  
  #"Consultas mescladas 3" = 
    Table.NestedJoin(#"Expandido dBalancete_nivel3", {"ID_NIVEL4"}, dBalancete_nivel4, {"ID_NIVEL4"}, "dBalancete_nivel4", JoinKind.LeftOuter),
  
  #"Expandido dBalancete_nivel4" = 
    Table.ExpandTableColumn(#"Consultas mescladas 3", "dBalancete_nivel4", {"Descricao_nivel_4"}, {"Descricao_nivel_4"}),
  
  #"Colunas renomeadas" = 
    Table.RenameColumns(#"Expandido dBalancete_nivel4", {{"CODCONTAB.1", "CODCONTAB"}})
in
  #"Colunas renomeadas"