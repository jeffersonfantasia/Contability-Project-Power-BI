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
        fnListCombine("listCfopSaidaBonificada,listCfopSaidaRemessaEntFut,listCfopSaidaRemessaContaOrdem,listCfopSaidaDesconsiderar"),

    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopFiltro, [CODFISCAL] ) ),

    ListVendaClientes =
        fnListCombine("listCfopSaidaVendaNormal,listCfopSaidaVendaConsignada,listCfopSaidaFatEntFut,listCfopSaidaFatContaOrdem,listCfopSaidaVendaTriangular"),

    ListEstoque = 
        fnListCombine("listCfopSaidaDevolucaoConsignado,listCfopSaidaDevolucao,listCfopSaidaTransferencia,listCfopSaidaPerdaMercadoria"),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each 
            if List.Contains( ListVendaClientes, [CODFISCAL] ) then fnTextAccount("txtClientes")
            else if List.Contains( fnListCfop("listCfopSaidaDevolucaoConsignado"), [CODFISCAL] ) then fnTextAccount("txtContabilEstoqueConsignado")
            else if List.Contains( fnListCfop("listCfopSaidaDevolucao"), [CODFISCAL] ) then fnTextAccount("txtDevolucaoReceber")
            else if List.Contains( fnListCfop("listCfopSaidaTransferencia"), [CODFISCAL] ) then fnTextAccount("txtContabilTransferencia")
            else if List.Contains( fnListCfop("listCfopSaidaConserto"), [CODFISCAL] ) then fnTextAccount("txtContabilConsertoPassivo")
            else if List.Contains( fnListCfop("listCfopSaidaDemonstracao"), [CODFISCAL] ) then fnTextAccount("txtContabilDemonstracaoPassivo")
            else if List.Contains( fnListCfop("listCfopSaidaSimplesRemessa"), [CODFISCAL] ) then fnTextAccount("txtContabilSimplesRemessaPassivo")
            else if List.Contains( fnListCfop("listCfopSaidaPerdaMercadoria"), [CODFISCAL] ) then fnTextAccount("txtPerdaMercadoria")
            else null, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListVendaClientes, [CODFISCAL] ) then fnTextAccount("txtContabilFaturamento")
            else if List.Contains( ListEstoque, [CODFISCAL] ) then fnTextAccount("txtContabilEstoque")
            else if List.Contains( fnListCfop("listCfopSaidaDevolucao"), [CODFISCAL] ) then fnTextAccount("txtContabilEstoque")
            else if List.Contains( fnListCfop("listCfopSaidaConserto"), [CODFISCAL] ) then fnTextAccount("txtContabilConsertoAtivo")
            else if List.Contains( fnListCfop("listCfopSaidaDemonstracao"), [CODFISCAL] ) then fnTextAccount("txtContabilDemonstracaoAtivo")
            else if List.Contains( fnListCfop("listCfopSaidaSimplesRemessa"), [CODFISCAL] ) then fnTextAccount("txtContabilSimplesRemessaAtivo")
            else null, type text)
in
    #"ContaCredito Adicionada"