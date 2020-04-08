let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"ff79aa6b-1614-4c29-8fa3-a953b81184b5" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="ff79aa6b-1614-4c29-8fa3-a953b81184b5"]}[Data],
    fLancamentosAjuste1 = #"ff79aa6b-1614-4c29-8fa3-a953b81184b5"{[entity="fLancamentosAjuste"]}[Data],
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(fLancamentosAjuste1,{"CODFILIAL", "DATA", "VALOR", "HISTORICO", "CONTADEBITO", "CONTACREDITO"})
in
    #"Outras Colunas Removidas"