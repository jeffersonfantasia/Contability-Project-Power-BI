let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"11ca4578-1d92-41c1-84d9-c15a13e543f0" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="11ca4578-1d92-41c1-84d9-c15a13e543f0"]}[Data],
    fMovProdutoSaida1 = #"11ca4578-1d92-41c1-84d9-c15a13e543f0"{[entity="fMovProdutoSaida"]}[Data],
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoSaida1,{{"DTMOV", type date}}),

    fMovProdutoSaida =  
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALNF"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALNF]), type number}}),
    
    ListCfopFiltro = 
        List.Combine(
            {
                ListCfopSaidaBonificada ,
                ListCfopSaidaRemessaContaOrdem,
                ListCfopSaidaDesconsiderar
            }
        ),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopFiltro, [CODFISCAL] ) ),

    ListVendaClientes =
        List.Combine(
            {
                ListCfopSaidaVendaNormal,
                ListCfopSaidaVendaConsignada,
                ListCfopSaidaFatEntFut,
                ListCfopSaidaFatContaOrdem,
                ListCfopSaidaVendaTriangular
            }
        ),

    ListEstoque = 
        List.Combine(
            {
                ListCfopSaidaDevolucaoConsignado,
                ListCfopSaidaDevolucao,
                ListCfopSaidaTransferencia,
                ListCfopSaidaPerdaMercadoria,
                ListCfopSaidaRemessaEntFut
            }
        ),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each 
            if List.Contains( ListVendaClientes, [CODFISCAL] ) then TxtClientes
            else if List.Contains( ListCfopSaidaDevolucaoConsignado, [CODFISCAL] ) then TxtContabilEstoqueConsignado
            else if List.Contains( ListCfopSaidaDevolucao, [CODFISCAL] ) then TxtDevolucaoReceber
            else if List.Contains( ListCfopSaidaTransferencia, [CODFISCAL] ) then TxtContabilTransferencia
            else if List.Contains( ListCfopSaidaConserto, [CODFISCAL] ) then TxtContabilConsertoPassivo
            else if List.Contains( ListCfopSaidaDemonstracao, [CODFISCAL] ) then TxtContabilDemonstracaoPassivo
            else if List.Contains( ListCfopSaidaSimplesRemessa, [CODFISCAL] ) then TxtContabilSimplesRemessaPassivo
            else if List.Contains( ListCfopSaidaPerdaMercadoria, [CODFISCAL] ) then TxtPerdaMercadoria
            else if List.Contains( ListCfopSaidaRemessaEntFut, [CODFISCAL] ) then TxtContabilMaterialTransito
            else null, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListVendaClientes, [CODFISCAL] ) then TxtContabilFaturamento
            else if List.Contains( ListEstoque, [CODFISCAL] ) then TxtContabilEstoque
            else if List.Contains( ListCfopSaidaDevolucao, [CODFISCAL] ) then TxtContabilEstoque
            else if List.Contains( ListCfopSaidaConserto, [CODFISCAL] ) then TxtContabilConsertoAtivo
            else if List.Contains( ListCfopSaidaDemonstracao, [CODFISCAL] ) then TxtContabilDemonstracaoAtivo
            else if List.Contains( ListCfopSaidaSimplesRemessa, [CODFISCAL] ) then TxtContabilSimplesRemessaAtivo
            else null, type text)
in
    #"ContaCredito Adicionada"