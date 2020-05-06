let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"]}[Data],
    fMovProdutoEnt1 = #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"{[entity="fMovProdutoEnt"]}[Data],
       
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoEnt1,{{"DTMOV", type date}}),
        
    fMovProdutoEnt =
        Table.SelectColumns(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCUSTOCONT"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCUSTOCONT]), type number}}),
    
    ListCfopFiltro = 
        List.Combine(
            {
                ListCfopEntradaDevolucao ,
                ListCfopEntradaDemonstracao,
                ListCfopEntradaConserto,
                ListCfopEntradaSimplesRemessa
            }
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