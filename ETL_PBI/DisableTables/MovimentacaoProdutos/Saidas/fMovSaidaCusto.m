let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"11ca4578-1d92-41c1-84d9-c15a13e543f0" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="11ca4578-1d92-41c1-84d9-c15a13e543f0"]}[Data],
    fMovProdutoSaida1 = #"11ca4578-1d92-41c1-84d9-c15a13e543f0"{[entity="fMovProdutoSaida"]}[Data],
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoSaida1,{{"DTMOV", type date}}),

    fMovProdutoSaida = 
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCUSTOCONT"}),

     #"Linhas Agrupadas" = 
        Table.Group(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCUSTOCONT]), type number}}),
    
    ListCfopFiltro = 
        List.Combine(
            {
                ListCfopSaidaTransferencia ,
                ListCfopSaidaDevolucao,
                ListCfopSaidaDevolucaoConsignado,
                ListCfopSaidaPerdaMercadoria,
                ListCfopSaidaRemessaEntFut
            }
        ),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopFiltro, [CODFISCAL] ) ),

    ListCMVEstoque = 
        List.Combine(
            {
                ListCfopSaidaVendaNormal,
                ListCfopSaidaVendaConsignada,
                ListCfopSaidaFatEntFut,
                ListCfopSaidaFatContaOrdem,
                ListCfopSaidaVendaTriangular
            }
        ),
          
    ListMaterialTransitoDebito = 
        List.Combine(
            {
                ListCfopSaidaConserto,
                ListCfopSaidaDemonstracao,
                ListCfopSaidaSimplesRemessa,
                ListCfopSaidaRemessaContaOrdem
            }
        ),

    ListMaterialTransitoCredito = 
        List.Combine(
            {
                ListCfopSaidaFatEntFut,
                ListCfopSaidaFatContaOrdem
            }
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