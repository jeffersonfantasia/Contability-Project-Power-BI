let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"8c2891f5-110b-4b8a-b823-b5e41d5b3623" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="8c2891f5-110b-4b8a-b823-b5e41d5b3623"]}[Data],
    LastRefresh1 = #"8c2891f5-110b-4b8a-b823-b5e41d5b3623"{[entity="LastRefresh"]}[Data]
in
    LastRefresh1