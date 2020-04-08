let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"68771117-f53f-497e-8d61-7af591eff42c" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="68771117-f53f-497e-8d61-7af591eff42c"]}[Data],
    dContabilFilialFornec1 = #"68771117-f53f-497e-8d61-7af591eff42c"{[entity="dContabilFilialFornec"]}[Data],
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(dContabilFilialFornec1,{"CODFILIAL", "CODFORNEC", "Descricao_conta", "CODCONTAB"})
in
    #"Outras Colunas Removidas"