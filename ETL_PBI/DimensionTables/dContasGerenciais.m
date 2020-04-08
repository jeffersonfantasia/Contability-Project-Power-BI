let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"f198c8b1-4cc5-481f-91e8-c3afab05341c" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="f198c8b1-4cc5-481f-91e8-c3afab05341c"]}[Data],
    dContasGerenciais1 = #"f198c8b1-4cc5-481f-91e8-c3afab05341c"{[entity="dContasGerenciais"]}[Data]
in
    dContasGerenciais1