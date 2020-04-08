let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"db9a303a-a0f8-42cc-ab59-3d1fa3c77943" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="db9a303a-a0f8-42cc-ab59-3d1fa3c77943"]}[Data],
    fContasReceberDesdCartao1 = #"db9a303a-a0f8-42cc-ab59-3d1fa3c77943"{[entity="fContasReceberDesdCartao"]}[Data],
    
    #"Conta Debito Renomeadas" = 
        Table.RenameColumns(fContasReceberDesdCartao1,{{"CODCONTAB", "CONTADEBITO"}}),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Renomeadas", "CONTACREDITO", each TxtClientes, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "DATA", "CODCOB", "NUMTRANSVENDA", "VALOR", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"NUMTRANSVENDA", Int64.Type}})
in
    #"Tipo Alterado"