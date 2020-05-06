let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"f6542a6b-26ef-47d4-a6ab-43956e9f5415" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="f6542a6b-26ef-47d4-a6ab-43956e9f5415"]}[Data],
    fAdiantamentoCliente1 = #"f6542a6b-26ef-47d4-a6ab-43956e9f5415"{[entity="fAdiantamentoCliente"]}[Data],
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(fAdiantamentoCliente1, "CONTADEBITO", each 
            if [VLPAGO] > 0 
            then [CODCONTABILBANCO] 
            else fnTextAccount("txtAdiantamentoCliente"), type text),
    
    #"Conta Credito Adicionada" = Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", 
        each if [VLPAGO] > 0 
        then fnTextAccount("txtAdiantamentoCliente")
        else [CODCONTABILBANCO], type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "DATA", "CODCRED", "NUMTRANS", "VALOR", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"CODCRED", Int64.Type}, {"NUMTRANS", Int64.Type}})
in
    #"Tipo Alterado"