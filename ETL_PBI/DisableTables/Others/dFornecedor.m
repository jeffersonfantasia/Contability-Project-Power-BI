let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"614ddf4e-fb81-4818-913f-5bcd70ec0e72" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="614ddf4e-fb81-4818-913f-5bcd70ec0e72"]}[Data],
    dFornecedor1 = #"614ddf4e-fb81-4818-913f-5bcd70ec0e72"{[entity="dFornecedor"]}[Data]
in
    dFornecedor1