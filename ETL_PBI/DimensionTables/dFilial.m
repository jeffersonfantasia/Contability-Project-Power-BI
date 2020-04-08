let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"05d3cd59-9afa-418e-88d0-e2031641cbb1" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="05d3cd59-9afa-418e-88d0-e2031641cbb1"]}[Data],
    dFilial1 = #"05d3cd59-9afa-418e-88d0-e2031641cbb1"{[entity="dFilial"]}[Data]
in
    dFilial1