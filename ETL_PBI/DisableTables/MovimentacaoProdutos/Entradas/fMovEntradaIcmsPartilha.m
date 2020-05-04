let
    Fonte = 
        Table.SelectColumns(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALICMSPARTDEST"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(Fonte, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALICMSPARTDEST]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and [CODFISCAL] <> 2913),
    
     #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas" , "CONTADEBITO", each 
            if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilRecolherPartilha
            else null, type text),
        
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilVendaICMS
            else null, type text)
in
    #"ContaCredito Adicionada"