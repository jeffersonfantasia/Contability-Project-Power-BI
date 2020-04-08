let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"1f91d82d-5ec7-42f5-a514-337b791d5173" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="1f91d82d-5ec7-42f5-a514-337b791d5173"]}[Data],
    fLancImpostosNotas1 = #"1f91d82d-5ec7-42f5-a514-337b791d5173"{[entity="fLancImpostosNotas"]}[Data],
    
    #"Função fnImposto Invocada" = 
        Table.AddColumn(fLancImpostosNotas1, "CODCONTAB_IMPOSTO", each fnImposto([IMPOSTO])),
    
    #"Conta Contabil Expandido" = 
        Table.ExpandListColumn(#"Função fnImposto Invocada", "CODCONTAB_IMPOSTO"),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Conta Contabil Expandido",{{"CODCONTAB_IMPOSTO", type text}})
in
    #"Tipo Alterado"