let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"]}[Data],
    fMovProdutoEnt1 = #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"{[entity="fMovProdutoEnt"]}[Data],
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoEnt1,{{"DTMOV", type date}}),
        
    fMovProdutoEnt = 
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCREDICMSNF", "VLTOTALICMSPART", "VLTOTALFCPPART"}),
    
    #"Valor Adicionada" = 
        Table.AddColumn(fMovProdutoEnt, "VALOR", each [VLTOTALCREDICMSNF] + [VLTOTALICMSPART] + [VLTOTALFCPPART], type number),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Valor Adicionada",{"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VALOR"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(#"Outras Colunas Removidas", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VALOR]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0),
    
    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas" , "CONTADEBITO", each 
            if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilRecolherICMS
            else if ( List.Contains( ListCfopEntradaSimplesRemessa , [CODFISCAL] ) and [CODOPER] = "EI" ) then TxtContabilRecuperarICMS
            else TxtContabilRecuperarICMS, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListCfopEntradaDevolucao, [CODFISCAL] ) then TxtContabilVendaICMS
            else if ( List.Contains( ListCfopEntradaSimplesRemessa , [CODFISCAL] ) and [CODOPER] = "EI" ) then TxtContabilEstoqueEntInventario
            else if List.Contains( ListCfopEntradaTriangular, [CODFISCAL] ) then TxtContabilEstoqueContaOrdem
            else TxtContabilEstoque, type text)
in
    #"ContaCredito Adicionada"