let
    Fonte = 
        Table.SelectColumns(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCUSTOCONT"}),

     #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCUSTOCONT]), type number}}),
    
    ListCfopFiltro = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaTransferencia ,
                    ListCfopSaidaDevolucao,
                    ListCfopSaidaDevolucaoConsignado,
                    ListCfopSaidaPerdaMercadoria,
                    ListCfopSaidaRemessaEntFut
                }
            )
        ),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopFiltro, [CODFISCAL] ) ),

    ListCMVEstoque = 
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

    ListMaterialTransitoDebito = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaConserto,
                    ListCfopSaidaDemonstracao,
                    ListCfopSaidaSimplesRemessa,
                    ListCfopSaidaRemessaContaOrdem
                }
            )
        ),

    ListMaterialTransitoCredito = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaFatEntFut,
                    ListCfopSaidaFatContaOrdem
                }
            )
        ),    

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each 
            if List.Contains( ListCMVEstoque, [CODFISCAL] ) then TxtContabilCMV
            else if List.Contains( ListCfopSaidaBonificada, [CODFISCAL] ) then TxtContabilVendaBonificacao
            else if List.Contains( ListMaterialTransitoDebito, [CODFISCAL] ) then TxtContabilMaterialTransito
            else null, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListMaterialTransitoCredito, [CODFISCAL] ) then TxtContabilMaterialTransito
            else if List.Contains( ListCfopSaidaVendaTriangular, [CODFISCAL] ) then TxtContabilEstoqueContaOrdem
            else TxtContabilEstoque, type text)
in
    #"ContaCredito Adicionada"