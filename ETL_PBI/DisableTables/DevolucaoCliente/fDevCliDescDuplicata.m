let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"35b82b06-95a8-40f5-9492-c72ed37562d7" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="35b82b06-95a8-40f5-9492-c72ed37562d7"]}[Data],
    fDevCliDescDuplicata1 = #"35b82b06-95a8-40f5-9492-c72ed37562d7"{[entity="fDevCliDescDuplicata"]}[Data],
    
    #"Valor Substituído" = 
        Table.ReplaceValue(fDevCliDescDuplicata1,"", fnTextAccount("txtClientes"), Replacer.ReplaceValue, {"CODCONTAB_CLI"}),
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(#"Valor Substituído", "CONTADEBITO", each fnTextAccount("txtDevolucaoPagar"), type text),
    
    #"Conta Credito Renomeadas" = 
        Table.RenameColumns(#"Conta Debito Adicionada",{{"CODCONTAB_CLI", "CONTACREDITO"}}),
    
    #"Colunas Reordenadas" = 
        Table.ReorderColumns(#"Conta Credito Renomeadas",{"CODFILIAL", "DATA", "VALOR", "CODUSUR", "NUMNOTA_DEV", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Colunas Reordenadas",{{"DATA", type date}, {"NUMNOTA_DEV", Int64.Type}})
in
    #"Tipo Alterado"