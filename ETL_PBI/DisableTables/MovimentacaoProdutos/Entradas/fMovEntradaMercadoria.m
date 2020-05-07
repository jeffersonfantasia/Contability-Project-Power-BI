let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"]}[Data],
    fMovProdutoEnt1 = #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"{[entity="fMovProdutoEnt"]}[Data],
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoEnt1,{{"DTMOV", type date}}),
        
    fMovProdutoEnt = 
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALNF"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALNF]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0),

    #"dContabilFilialFornec Mescladas" = 
        Table.NestedJoin(#"ValorPositivo Filtradas", {"CODFILIAL", "CODIGO"}, dContabilFilialFornec, {"CODFILIAL", "CODFORNEC"}, "dContabilFilialFornec", JoinKind.LeftOuter),
    
    #"Conta Fornecedor Expandido" = 
        Table.ReplaceValue( 
            Table.ExpandTableColumn(#"dContabilFilialFornec Mescladas", "dContabilFilialFornec", {"CODCONTAB"}, {"CODCONTABFORNEC"}
            ), null, fnTextAccount("txtFornecedorSemConta"), Replacer.ReplaceValue,{"CODCONTABFORNEC"}
        ),
    
    ListEstoqueComercializavel = 
        fnListCombine("listCfopEntradaMercadoriaRevenda,listCfopEntradaMercConsignada,listCfopEntradaBonificada,listCfopEntradaTransferencia,listCfopEntradaRemessaEntFut,listCfopEntradaRemessaContaOrdem"),

    ListFornecedores = 
        fnListCombine("listCfopEntradaMercadoriaRevenda,listCfopEntradaMercConsigPosVenda,listCfopEntradaFatEntFut,listCfopEntradaTriangular"),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"Conta Fornecedor Expandido", "CONTADEBITO", each 
        if List.Contains( ListEstoqueComercializavel, [CODFISCAL] ) then fnTextAccount("txtContabilEstoque")
        else if List.Contains( fnListCfop("listCfopEntradaMercConsigPosVenda"), [CODFISCAL] ) then fnTextAccount("txtContabilEstoqueConsignado")
        else if List.Contains( fnListCfop("listCfopEntradaDevolucao"), [CODFISCAL] ) then fnTextAccount("txtContabilDevolucao")
        else if List.Contains( fnListCfop("listCfopEntradaConserto"), [CODFISCAL] ) then fnTextAccount("txtContabilConsertoAtivo")
        else if List.Contains( fnListCfop("listCfopEntradaDemonstracao"), [CODFISCAL] ) then fnTextAccount("txtContabilDemonstracaoAtivo")
        else if List.Contains( fnListCfop("listCfopEntradaSimplesRemessa"), [CODFISCAL] ) then fnTextAccount("txtContabilSimplesRemessaAtivo")
        else if List.Contains( fnListCfop("listCfopEntradaFatEntFut"), [CODFISCAL] ) then fnTextAccount("txtContabilMaterialTransito")
        else if List.Contains( fnListCfop("listCfopEntradaTriangular"), [CODFISCAL] ) then fnTextAccount("txtContabilEstoqueContaOrdem")
        else null, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
        if List.Contains( ListFornecedores, [CODFISCAL] ) then [CODCONTABFORNEC]
        else if List.Contains( fnListCfop("listCfopEntradaMercConsignada"), [CODFISCAL] ) then fnTextAccount("txtContabilEstoqueConsignado")
        else if List.Contains( fnListCfop("listCfopEntradaBonificada"), [CODFISCAL] ) then fnTextAccount("txtContabilEntradaBonificacao")
        else if List.Contains( fnListCfop("listCfopEntradaDevolucao"), [CODFISCAL] ) then fnTextAccount("txtDevolucaoPagar")
        else if List.Contains( fnListCfop("listCfopEntradaTransferencia"), [CODFISCAL] ) then fnTextAccount("txtContabilTransferencia")
        else if List.Contains( fnListCfop("listCfopEntradaConserto"), [CODFISCAL] ) then fnTextAccount("txtContabilConsertoPassivo")
        else if List.Contains( fnListCfop("listCfopEntradaDemonstracao"), [CODFISCAL] ) then fnTextAccount("txtContabilDemonstracaoPassivo")
        else if List.Contains( fnListCfop("listCfopEntradaSimplesRemessa"), [CODFISCAL] ) then fnTextAccount("txtContabilSimplesRemessaPassivo")
        else if List.Contains( fnListCfop("listCfopEntradaRemessaEntFut"), [CODFISCAL] ) then fnTextAccount("txtContabilMaterialTransito")
        else if List.Contains( fnListCfop("listCfopEntradaRemessaContaOrdem"), [CODFISCAL] ) then fnTextAccount("txtContabilEstoqueEntInventario")
        else null, type text)
in
    #"ContaCredito Adicionada"