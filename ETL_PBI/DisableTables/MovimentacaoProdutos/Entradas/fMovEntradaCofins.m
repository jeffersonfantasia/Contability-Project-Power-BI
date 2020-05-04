let
    Fonte = 
        Table.SelectColumns(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCOFINS"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCOFINS]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas" , "CONTADEBITO", each 
        if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilRecolherCofins
        else TxtContabilRecuperarCofins, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
        if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilVendaCofins
        else if List.Contains( ListCfopEntradaTriangular, [CODFISCAL] ) then TxtContabilEstoqueContaOrdem
        else TxtContabilEstoque, type text)
in
    #"ContaCredito Adicionada"