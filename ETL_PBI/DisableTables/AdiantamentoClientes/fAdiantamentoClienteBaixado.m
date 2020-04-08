let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"ebdd4702-34a6-4f47-9e84-b502a9a41ff9" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="ebdd4702-34a6-4f47-9e84-b502a9a41ff9"]}[Data],
    fAdiantamentoClienteBaixado1 = #"ebdd4702-34a6-4f47-9e84-b502a9a41ff9"{[entity="fAdiantamentoClienteBaixado"]}[Data],
    
    #"Valor Substituído" = 
        Table.ReplaceValue(fAdiantamentoClienteBaixado1,"",TxtClientes,Replacer.ReplaceValue,{"CODCONTAB"}),
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(#"Valor Substituído", "CONTADEBITO", each TxtAdiantamentoCliente, type text),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if [TIPO] = "D" 
            then [CODCONTAB] 
            else if [TIPO] = "R" 
                then TxtOutrasReceitasFinanceiras 
                else null, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "DATA", "CODIGO", "NUMTRANS", "VALOR", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"CODIGO", Int64.Type}, {"NUMTRANS", Int64.Type}})
in
    #"Tipo Alterado"