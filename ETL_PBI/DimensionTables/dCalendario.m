let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"17ba9f69-32e1-407f-8cd9-c84c347d4f05" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="17ba9f69-32e1-407f-8cd9-c84c347d4f05"]}[Data],
    dCalendario1 = #"17ba9f69-32e1-407f-8cd9-c84c347d4f05"{[entity="dCalendario"]}[Data],        
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(dCalendario1,{"Data Base", "Ano", "Nº Mês", "Mês", "Trimestre", "Nº Mês-Ano", "Mês Abrev-Ano"}),
    
    #"Extrato Bancario Adicionada" = 
        Table.AddColumn(#"Outras Colunas Removidas", "Extrato Bancario", each "EXTRATO BANCARIO", type text)
in
    #"Extrato Bancario Adicionada"
