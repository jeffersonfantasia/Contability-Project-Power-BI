let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"92618e51-ab08-4285-ba0b-a08cdb659c65" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="92618e51-ab08-4285-ba0b-a08cdb659c65"]}[Data],
    fMovBancosTransferencia1 = #"92618e51-ab08-4285-ba0b-a08cdb659c65"{[entity="fMovBancosTransferencia"]}[Data],
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(fMovBancosTransferencia1, "CONTADEBITO", each 
            if List.Contains( {"G"}, [TIPO] ) 
            then [CODCONTABILDEB] 
            else if List.Contains( {"EC", "EB"}, [TIPO] )  then fnTextAccount("txtEmprestimoTerceiros") 
            else null, type text), 

    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if List.Contains( {"G", "EB"}, [TIPO] ) 
            then [CODCONTABILCRED]
            else if List.Contains( {"EC"}, [TIPO] )  then [CODCONTABILDEB]
            else null, type text),

    #"Debito Contabil Adicionada" = 
        Table.CombineColumns(    
            Table.DuplicateColumn(
                Table.ExpandListColumn( 
                    Table.AddColumn(#"Conta Credito Adicionada", "CONTA_DEBITO", each fnTransformFilial([CODFILIALDEB])
                    ),"CONTA_DEBITO"
                ), "CONTADEBITO", "CONTADEBITODUP"
            ),{"CONTA_DEBITO", "CONTADEBITODUP"},Combiner.CombineTextByDelimiter("-", QuoteStyle.None),"CONTA_DEBITO"
        ),
        
    #"Credito Contabil Adicionada" = 
        Table.CombineColumns(
            Table.DuplicateColumn(
                Table.ExpandListColumn( 
                    Table.AddColumn(#"Debito Contabil Adicionada", "CONTA_CREDITO", each fnTransformFilial([CODFILIALCRED]) 
                    ),"CONTA_CREDITO"
                ),"CONTACREDITO", "CONTACREDITODUP"
            ),{"CONTA_CREDITO", "CONTACREDITODUP"},Combiner.CombineTextByDelimiter("-", QuoteStyle.None),"CONTA_CREDITO"
        ),
    
    #"Unpivot Conta Contabil" = 
        Table.UnpivotOtherColumns(
            #"Credito Contabil Adicionada", 
            {"DATA", "NUMTRANS", "CODFILIALCRED", "CODBANCOCRED", "CODCONTABILCRED", "CODFILIALDEB", "CODBANCODEB", "CODCONTABILDEB", "CODCOB", "VALOR", "CONCILIACAO", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}, 
            "TIPOCONTA", "CONTACONTABIL"
        ),
    
    #"Codigo Filial Adicionada" = 
        Table.AddColumn(#"Unpivot Conta Contabil", "CODFILIAL", each 
            if [TIPOCONTA] = "CONTA_DEBITO" 
            then [CODFILIALDEB] 
            else [CODFILIALCRED], type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Codigo Filial Adicionada",{"CODFILIAL", "DATA", "NUMTRANS", "VALOR", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO", "TIPOCONTA", "CONTACONTABIL"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"NUMTRANS", Int64.Type}})
in
    #"Tipo Alterado"