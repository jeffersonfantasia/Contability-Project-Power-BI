let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"113d7657-93ed-4ae7-9b5b-aeafbd2e7f2e" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="113d7657-93ed-4ae7-9b5b-aeafbd2e7f2e"]}[Data],
    fLancamentosPagos1 = #"113d7657-93ed-4ae7-9b5b-aeafbd2e7f2e"{[entity="fLancamentosPagos"]}[Data],
    
    #"fLancImpostosNotas Mescladas" = 
        Table.NestedJoin(fLancamentosPagos1, {"RECNUM"}, fLancImpostosNotas, {"RECNUM"}, "fLancImpostosNotas", JoinKind.LeftOuter),
    
    #"Conta Impostos Expandido" = 
        Table.ExpandTableColumn(#"fLancImpostosNotas Mescladas", "fLancImpostosNotas", {"CODCONTAB_IMPOSTO"}, {"CODCONTAB_IMPOSTO"}),
    
    #"dContabilFilialFornec Mescladas" = 
        Table.NestedJoin(#"Conta Impostos Expandido", {"CODFILIAL", "CODFORNEC"}, dContabilFilialFornec, {"CODFILIAL", "CODFORNEC"}, "dContabilFilialFornec", JoinKind.LeftOuter),
    
    #"Conta Fornecedor Expandido" = 
        Table.ReplaceValue( 
            Table.ExpandTableColumn(#"dContabilFilialFornec Mescladas", "dContabilFilialFornec", {"CODCONTAB"}, {"CODCONTAB_FORNEC"}
            ), null, fnTextAccount("txtFornecedorSemConta"), Replacer.ReplaceValue, {"CODCONTAB_FORNEC"}
        ),
    
    #"dContasGerenciais Mescladas" = 
        Table.NestedJoin(#"Conta Fornecedor Expandido", {"CODCONTA"}, dContasGerenciais, {"CODCONTA"}, "dContasGerenciais", JoinKind.LeftOuter),
    
    #"Conta Contabil Expandido" = 
        Table.ExpandTableColumn(#"dContasGerenciais Mescladas", "dContasGerenciais", {"CONTACONTABIL"}, {"CODCONTAB_CONTA"}),
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(#"Conta Contabil Expandido", "CONTADEBITO", each 
            if [TIPO] = "F" then 
                if ( List.Contains( fnListCfop("listGruposDesconsiderar"), [GRUPOCONTA] ) and not List.Contains( fnListCfop("listContasConsiderar"), [CODCONTA] ) ) 
                    or List.Contains( fnListCfop("listContasDesconsiderar"), [CODCONTA] ) 
                    or List.Contains( listFornecedorDesconsiderar, [CODFORNEC] )
                then 
                    if [VPAGO] > 0
                    then [CODCONTAB_CONTA]
                    else [CODCONTABILBANCO]
                else
                    if [VPAGO] > 0 
                    then [CODCONTAB_FORNEC]
                    else [CODCONTABILBANCO]
            
            else if [TIPO] = "O" then
                if [VPAGO] > 0 then
                    if ( List.Contains( fnListCfop("listEmpresaJCBrothers"), [CODFILIAL] ) and [CODCONTA] = 620110 )
                    then fnTextAccount("txtRestituirIR")
                    else [CODCONTAB_CONTA]
                else [CODCONTABILBANCO]
            
            else if [TIPO] = "J" then fnTextAccount("txtJurosPagos")
            
            else if [TIPO] = "I" then [CODCONTAB_IMPOSTO]

            else if [TIPO] = "MI" then [CODCONTABCLIENTE]
            
            else if [TIPO] = "EB" then fnTextAccount("txtEmprestimoTerceiros")

            else if [TIPO] = "MT" then 
                if [VPAGO] > 0 
                then [CODCONTAB_CONTA]
                else [CODCONTABILBANCO]

            else if [TIPO] = "C" then 
                if [VPAGO] > 0 
                then [CODCONTAB_CONTA]
                else [CODCONTAB_FORNEC]   

            else if [TIPO] = "V" then [CODCONTABILBANCO]
            
            else if List.Contains( {"D","MK"}, [TIPO])
                then [CODCONTAB_FORNEC]
            
            else if List.Contains( {"EC","A"}, [TIPO])
                then [CODCONTAB_CONTA]
            
            else null, type text),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
            if List.Contains( {"F", "O", "MT"}, [TIPO]) then 
                if [VPAGO] > 0
                then [CODCONTABILBANCO]
                else if [CODCONTAB_CONTA] = "" 
                    then fnTextAccount("txtOutrasReceitasFinanceiras") 
                    else [CODCONTAB_CONTA] 

            else if [TIPO] = "D" then fnTextAccount("txtDescontosObtidos")
        
            else if [TIPO] = "MI" then [CODCONTAB_FORNEC]

            else if [TIPO] = "C" then 
                if [VPAGO] > 0 
                then [CODCONTABILBANCO]
                else [CODCONTAB_CONTA] 

            else if [TIPO] = "EC" then fnTextAccount("txtEmprestimoTerceiros")

            else if [TIPO] = "V" then fnTextAccount("txtOutrasReceitasFinanceiras")
            
            else if List.Contains( {"J","I","EB"}, [TIPO])
                then [CODCONTABILBANCO]
            
            else if List.Contains( {"MK","A"}, [TIPO])
                then [CODCONTABCLIENTE]
            
            else null, type text),
    
    #"Data Adicionada" = 
        Table.AddColumn(#"Conta Credito Adicionada", "DATA", each 
            if [TIPO] = "O" then
                if List.Contains( fnListCfop("listGruposCompensacao"), [GRUPOCONTA] ) 
                then [DTCOMPENSACAO]
                else [DTPAGTO]

            else if List.Contains( {"MT", "V"} , [TIPO] ) then [DTCOMPENSACAO]

            else if List.Contains( {"F","D","J","I","EC","EB"}, [TIPO] )
            then [DTPAGTO] 

            else if List.Contains( {"MK","MI","C","A"}, [TIPO] )
            then [DTCOMPETENCIA]

            else null, type date),
            
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Data Adicionada",{"CODFILIAL", "RECNUM", "DATA", "VALOR", "CODCONTA", "CODFORNEC", "NUMTRANS", "TIPOPARCEIRO", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}})
in
    #"Tipo Alterado"