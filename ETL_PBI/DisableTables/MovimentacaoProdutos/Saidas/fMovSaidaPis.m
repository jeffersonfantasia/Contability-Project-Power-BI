let
    Fonte = 
        Table.SelectColumns(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALPIS"}),

    #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALPIS]), type number}}),

    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopSaidaDesconsiderar, [CODFISCAL] ) ),       

    ListDevolucao = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaDevolucaoConsignado,
                    ListCfopSaidaDevolucao
                }
            )
        ),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each 
            if List.Contains( ListDevolucao, [CODFISCAL] ) then TxtContabilEstoque
            else TxtContabilVendaPis, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListDevolucao, [CODFISCAL] ) then TxtContabilRecuperarPis
            else TxtContabilRecolherPis, type text)

in
    #"ContaCredito Adicionada"