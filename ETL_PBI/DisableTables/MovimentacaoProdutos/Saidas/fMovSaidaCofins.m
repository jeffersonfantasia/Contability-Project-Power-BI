let
    Fonte = 
        Table.SelectColumns(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCOFINS"}),

    #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCOFINS]), type number}}),

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
            else TxtContabilVendaCofins, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListDevolucao, [CODFISCAL] ) then TxtContabilRecuperarCofins
            else TxtContabilRecolherCofins, type text)

in
    #"ContaCredito Adicionada"