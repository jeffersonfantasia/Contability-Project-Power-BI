let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"]}[Data],
    fMovProdutoEnt1 = #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"{[entity="fMovProdutoEnt"]}[Data],
       
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoEnt1,{{"DTMOV", type date}}),
        
    fMovProdutoEnt =
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCUSTOCONT"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALCUSTOCONT]), type number}}),
    
    ListCfopFiltro = 
        fnListCombine("listCfopEntradaDevolucao,listCfopEntradaDemonstracao,listCfopEntradaConserto,listCfopEntradaSimplesRemessa"),

    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and List.Contains( ListCfopFiltro, [CODFISCAL] ) ),
    
    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each fnTextAccount("txtContabilEstoque"), type text),
        
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( fnListCfop("listCfopEntradaDevolucao"), [CODFISCAL] ) then fnTextAccount("txtContabilCmv")
            else if ( List.Contains( fnListCfop("listCfopEntradaSimplesRemessa") , [CODFISCAL] ) and [CODOPER] = "EI" ) then fnTextAccount("txtContabilEstoqueEntInventario")
            else fnTextAccount("txtContabilMaterialTransito"), type text)
in
    #"ContaCredito Adicionada"