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
            ),null,TxtFornecedorSemConta,Replacer.ReplaceValue,{"CODCONTABFORNEC"}
        ),
    
    ListEstoqueComercializavel = 
        List.Combine(
            {
                ListCfopEntradaMercadoriaRevenda,
                ListCfopEntradaMercConsignada,
                ListCfopEntradaBonificada,
                ListCfopEntradaTransferencia,
                ListCfopEntradaRemessaEntFut,
                ListCfopEntradaRemessaContaOrdem
            }
        ),

    ListFornecedores = 
        List.Combine(
            {
                ListCfopEntradaMercadoriaRevenda,
                ListCfopEntradaMercConsigPosVenda,
                ListCfopEntradaFatEntFut,
                ListCfopEntradaTriangular
            }
        ),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"Conta Fornecedor Expandido", "CONTADEBITO", each 
        if List.Contains( ListEstoqueComercializavel, [CODFISCAL] ) then TxtContabilEstoque
        else if List.Contains( ListCfopEntradaMercConsigPosVenda, [CODFISCAL] ) then TxtContabilEstoqueConsignado
        else if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilDevolucao
        else if List.Contains( ListCfopEntradaConserto, [CODFISCAL] ) then TxtContabilConsertoAtivo
        else if List.Contains( ListCfopEntradaDemonstracao, [CODFISCAL] ) then TxtContabilDemonstracaoAtivo
        else if List.Contains( ListCfopEntradaSimplesRemessa, [CODFISCAL] ) then TxtContabilSimplesRemessaAtivo
        else if List.Contains( ListCfopEntradaFatEntFut, [CODFISCAL] ) then TxtContabilMaterialTransito
        else if List.Contains( ListCfopEntradaTriangular, [CODFISCAL] ) then TxtContabilEstoqueContaOrdem
        else null, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
        if List.Contains( ListFornecedores, [CODFISCAL] ) then [CODCONTABFORNEC]
        else if List.Contains( ListCfopEntradaMercConsignada, [CODFISCAL] ) then TxtContabilEstoqueConsignado
        else if List.Contains( ListCfopEntradaBonificada, [CODFISCAL] ) then TxtContabilEntradaBonificacao
        else if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtDevolucaoPagar
        else if List.Contains( ListCfopEntradaTransferencia, [CODFISCAL] ) then TxtContabilTransferencia
        else if List.Contains( ListCfopEntradaConserto, [CODFISCAL] ) then TxtContabilConsertoPassivo
        else if List.Contains( ListCfopEntradaDemonstracao, [CODFISCAL] ) then TxtContabilDemonstracaoPassivo
        else if List.Contains( ListCfopEntradaSimplesRemessa, [CODFISCAL] ) then TxtContabilSimplesRemessaPassivo
        else if List.Contains( ListCfopEntradaRemessaEntFut, [CODFISCAL] ) then TxtContabilMaterialTransito
        else if List.Contains( ListCfopEntradaRemessaContaOrdem, [CODFISCAL] ) then TxtContabilEstoqueEntInventario
        else null, type text)
in
    #"ContaCredito Adicionada"