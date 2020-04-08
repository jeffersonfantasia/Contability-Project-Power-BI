let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"68771117-f53f-497e-8d61-7af591eff42c" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="68771117-f53f-497e-8d61-7af591eff42c"]}[Data],
    dContabilFilialFornec1 = #"68771117-f53f-497e-8d61-7af591eff42c"{[entity="dContabilFilialFornec"]}[Data],
    
    #"Consultas Mescladas" = 
        Table.NestedJoin(dContabilFilialFornec1, {"ID_NIVEL1"}, dBalancete, {"ID_NIVEL1"}, "dBalancete", JoinKind.LeftOuter),
    
    #"dBalancete Expandido" = 
        Table.ExpandTableColumn(#"Consultas Mescladas", "dBalancete", {"Descricao_nivel_1", "ID_NIVEL2", "Descricao_nivel_2", "ID_NIVEL3", "Descricao_nivel_3", "ID_NIVEL4", "Descricao_nivel_4"}, {"Descricao_nivel_1", "ID_NIVEL2", "Descricao_nivel_2", "ID_NIVEL3", "Descricao_nivel_3", "ID_NIVEL4", "Descricao_nivel_4"}),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"dBalancete Expandido",{"ID", "ID_BALANCETE", "Descricao_conta", "CODCONTAB", "ID_NIVEL1", "Descricao_nivel_1", "ID_NIVEL2", "Descricao_nivel_2", "ID_NIVEL3", "Descricao_nivel_3", "ID_NIVEL4", "Descricao_nivel_4"}),
    
    #"Duplicatas Removidas" = 
        Table.Distinct(#"Outras Colunas Removidas", {"ID"})
in
    #"Duplicatas Removidas"