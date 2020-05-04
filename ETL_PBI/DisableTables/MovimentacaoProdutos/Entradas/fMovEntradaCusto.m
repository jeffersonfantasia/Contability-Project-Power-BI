let
    Fonte = 
        Table.SelectColumns(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCUSTOCONT"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCUSTOCONT]), type number}}),
    
    ListCfopFiltro = 
        List.Buffer(
            List.Union(
                {
                    ListCfopEntradaDevolucao ,
                    ListCfopEntradaDemonstracao,
                    ListCfopEntradaConserto,
                    ListCfopEntradaSimplesRemessa
                }
            )
        ),

    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and List.Contains( ListCfopFiltro, [CODFISCAL] ) ),
    
    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each TxtContabilEstoque, type text),
        
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
        if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilCMV
        else if ( List.Contains( ListCfopEntradaSimplesRemessa , [CODFISCAL] ) and [CODOPER] = "EI" ) then TxtContabilEstoqueEntInventario
        else TxtContabilMaterialTransito, type text)
in
    #"ContaCredito Adicionada"