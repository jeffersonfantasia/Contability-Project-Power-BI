let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"dded1a29-592c-43c2-bea7-2c509b6f9bd7" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="dded1a29-592c-43c2-bea7-2c509b6f9bd7"]}[Data],
    TableString1 = #"dded1a29-592c-43c2-bea7-2c509b6f9bd7"{[entity="TableString"]}[Data]
in
    TableString1