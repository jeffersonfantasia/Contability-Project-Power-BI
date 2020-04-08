let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"3198aef9-92a9-484a-8f1b-9f02ce2b9591" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="3198aef9-92a9-484a-8f1b-9f02ce2b9591"]}[Data],
    dCalendario1 = #"3198aef9-92a9-484a-8f1b-9f02ce2b9591"{[entity="dCalendario"]}[Data],
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(dCalendario1,{"Data Base", "Ano", "Nº Mês", "Mês", "Trimestre"}),
    
    #"Extrato Bancario Adicionada" = 
        Table.AddColumn(#"Outras Colunas Removidas", "Extrato Bancario", each "EXTRATO BANCARIO", type text)
in
    #"Extrato Bancario Adicionada"