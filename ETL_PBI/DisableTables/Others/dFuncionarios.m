let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"4195dbed-3085-4725-abe0-0a356ab6bdb5" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="4195dbed-3085-4725-abe0-0a356ab6bdb5"]}[Data],
    dFuncionarios1 = #"4195dbed-3085-4725-abe0-0a356ab6bdb5"{[entity="dFuncionarios"]}[Data]
in
    dFuncionarios1