let
    Fonte = 
        Table.SelectColumns(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALNF"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALNF]), type number}}),
    
    ListCfopFiltro = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaBonificada ,
                    ListCfopSaidaRemessaContaOrdem,
                    ListCfopSaidaDesconsiderar
                }
            )
        ),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopFiltro, [CODFISCAL] ) ),

    ListVendaClientes = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaVendaNormal,
                    ListCfopSaidaVendaConsignada,
                    ListCfopSaidaFatEntFut,
                    ListCfopSaidaFatContaOrdem,
                    ListCfopSaidaVendaTriangular
                }
            )
        ),

    ListEstoque = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaDevolucaoConsignado,
                    ListCfopSaidaDevolucao,
                    ListCfopSaidaTransferencia,
                    ListCfopSaidaPerdaMercadoria,
                    ListCfopSaidaRemessaEntFut
                }
            )
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