let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"98121384-6c82-4a64-9273-a116316e213e" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="98121384-6c82-4a64-9273-a116316e213e"]}[Data],
    fContasReceberDupManual1 = #"98121384-6c82-4a64-9273-a116316e213e"{[entity="fContasReceberDupManual"]}[Data],
    
    #"Valor Substituído" = 
        Table.ReplaceValue(fContasReceberDupManual1, "", fnTextAccount("txtClientes"), Replacer.ReplaceValue, {"CODCONTAB"}),
    
    #"Conta Debito Renomeadas" = 
        Table.RenameColumns(#"Valor Substituído",{{"CODCONTAB", "CONTADEBITO"}}),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Renomeadas", "CONTACREDITO", each fnTextAccount("txtOutrasReceitasOperacionais"), type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "RECNUM", "DATA", "VALOR", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"RECNUM", Int64.Type}})
in
    #"Tipo Alterado"