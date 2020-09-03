let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"8039f4ff-a199-4f5f-8040-21f6488872c5" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="8039f4ff-a199-4f5f-8040-21f6488872c5"]}[Data],
    fContasReceberBaixado1 = #"8039f4ff-a199-4f5f-8040-21f6488872c5"{[entity="fContasReceberBaixado"]}[Data],
    
    #"Valor Substituído" = 
        Table.ReplaceValue(fContasReceberBaixado1, "", fnTextAccount("txtClientes"), Replacer.ReplaceValue, {"CODCONTAB"}),
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(#"Valor Substituído", "CONTADEBITO", each 
            if [TIPO] = "B" then 
                if [CODCOB] = "DESC" 
                then fnTextAccount("txtDescontosConcedidos") 
                else [CODCONTABILBANCO]
            else if [TIPO] = "J" then [CODCONTABILBANCO]
            else if [TIPO] = "P" then fnTextAccount("txtPrejuizosClientes") 
            else if [TIPO] = "T" then fnTextAccount("txtTaxasCartao") 
            else if [TIPO] = "D" then fnTextAccount("txtDescontosConcedidos")
            else if [TIPO] = "E" then [CODCONTAB] 
            else null, type text),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if [TIPO] = "B" then 
                if [CODCOB] = "JUR" 
                then fnTextAccount("txtJurosRecebidos") 
                else [CODCONTAB] 
            else if [TIPO] = "J" then fnTextAccount("txtJurosRecebidos") 
            else if List.Contains( {"P","T","D"},[TIPO] ) then [CODCONTAB] 
            else if [TIPO] = "E" then [CODCONTABILBANCO]
            else null, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "DATA", "VALOR", "CODCOB", "NUMTRANS", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"NUMTRANS", Int64.Type}})
in
    #"Tipo Alterado"