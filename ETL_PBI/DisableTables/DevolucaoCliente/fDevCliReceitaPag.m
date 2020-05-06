let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"56d76aa7-c1b1-4cf7-9c3a-562ed96b9db5" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="56d76aa7-c1b1-4cf7-9c3a-562ed96b9db5"]}[Data],
    fDevCliReceitaPag1 = #"56d76aa7-c1b1-4cf7-9c3a-562ed96b9db5"{[entity="fDevCliReceitaPag"]}[Data],
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(fDevCliReceitaPag1, "CONTADEBITO", each fnTextAccount("txtDevolucaoPagar"), type text),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if [TIPO] = "D" 
            then [CODCONTAB_BANCO]
            else if [TIPO] = "R" then fnTextAccount("txtOutrasReceitasOperacionais") 
            else null, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "RECNUM", "DATA", "VALOR", "NUMTRANS", "CODUSUR", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"RECNUM", Int64.Type}, {"NUMTRANS", Int64.Type}, {"CODUSUR", Int64.Type}})
in
    #"Tipo Alterado"