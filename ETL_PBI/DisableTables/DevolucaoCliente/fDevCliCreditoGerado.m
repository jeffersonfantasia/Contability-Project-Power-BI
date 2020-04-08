let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"24e3bfb3-12d1-48cb-af3f-dcee84651121" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="24e3bfb3-12d1-48cb-af3f-dcee84651121"]}[Data],
    fDevCliCreditoGerado1 = #"24e3bfb3-12d1-48cb-af3f-dcee84651121"{[entity="fDevCliCreditoGerado"]}[Data],
    
    #"Valor Substituído" = 
        Table.ReplaceValue(fDevCliCreditoGerado1,"",TxtClientes,Replacer.ReplaceValue,{"CODCONTAB_CLI"}),
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(#"Valor Substituído", "CONTADEBITO", each TxtDevolucaoPagar, type text),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if [TIPO] = "R" 
            then TxtOutrasReceitasOperacionais 
            else if [TIPO] ="C" then [CODCONTAB_CLI] 
            else if [TIPO] = "D" then [CODCONTAB_BANCO] 
            else null, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "NUMNOTA_DEV", "DATA", "CODIGO", "VALOR", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"NUMNOTA_DEV", Int64.Type}, {"CODIGO", Int64.Type}})
in
    #"Tipo Alterado"