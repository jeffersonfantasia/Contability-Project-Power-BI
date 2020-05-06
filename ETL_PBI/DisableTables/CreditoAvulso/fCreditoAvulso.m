let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"b211c13c-c37c-46ae-9cb9-a59bf176aaec" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="b211c13c-c37c-46ae-9cb9-a59bf176aaec"]}[Data],
    fCreditoAvulso1 = #"b211c13c-c37c-46ae-9cb9-a59bf176aaec"{[entity="fCreditoAvulso"]}[Data],
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(fCreditoAvulso1, "CONTADEBITO", each 
            if [TIPO] = "L" 
            then fnTextAccount("txtClientes") 
            else if List.Contains( {"E", "B"}, [TIPO] ) then fnTextAccount("txtAdiantamentoCreditoAvulso") 
            else if List.Contains( {"D", "M"}, [TIPO] )then fnTextAccount("txtDescontosConcedidos") 
            else null, type text),

    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if [TIPO] = "L" 
            then fnTextAccount("txtAdiantamentoCreditoAvulso") 
            else if List.Contains( {"E", "D", "B"}, [TIPO] ) then fnTextAccount("txtClientes") 
            else if [TIPO] = "M" then Text.From( [CODCONTA] ) 
            else null, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "CODLANC", "DATA", "VALOR", "CODUSUR", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"CODUSUR", Int64.Type}, {"CODLANC", Int64.Type}})
in
    #"Tipo Alterado"