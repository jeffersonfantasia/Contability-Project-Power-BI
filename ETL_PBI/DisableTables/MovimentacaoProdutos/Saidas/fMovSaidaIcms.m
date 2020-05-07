let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"11ca4578-1d92-41c1-84d9-c15a13e543f0" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="11ca4578-1d92-41c1-84d9-c15a13e543f0"]}[Data],
    fMovProdutoSaida1 = #"11ca4578-1d92-41c1-84d9-c15a13e543f0"{[entity="fMovProdutoSaida"]}[Data],
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoSaida1,{{"DTMOV", type date}}),

    fMovProdutoSaida = 
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCREDICMSNF", "VLTOTALICMSPART", "VLTOTALFCPPART"}),
    
    #"Valor Adicionada" = 
        Table.AddColumn(fMovProdutoSaida, "VALOR", each [VLTOTALCREDICMSNF] + [VLTOTALICMSPART] + [VLTOTALFCPPART], type number),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Valor Adicionada",{"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VALOR"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(#"Outras Colunas Removidas", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VALOR]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( fnListCfop("listCfopSaidaDesconsiderar"), [CODFISCAL] ) ),

    ListEstoque = 
        fnListCombine("listCfopSaidaDevolucaoConsignado,listCfopSaidaDevolucao,listCfopSaidaTransferencia"),
   
    ListMaterialTransito = 
        fnListCombine("listCfopSaidaDemonstracao,listCfopSaidaSimplesRemessa"),
        
    ListIcmsRecuperar = 
        fnListCombine("listCfopSaidaDevolucaoConsignado,listCfopSaidaDevolucao"),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each 
            if List.Contains( ListEstoque, [CODFISCAL] ) then fnTextAccount("txtContabilEstoque")
            else if List.Contains( ListMaterialTransito, [CODFISCAL] ) then fnTextAccount("txtContabilMaterialTransito")
            else fnTextAccount("txtContabilVendaIcms"), type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListIcmsRecuperar, [CODFISCAL] ) then fnTextAccount("txtContabilRecuperarIcms")
            else fnTextAccount("txtContabilRecolherIcms"), type text)

in
    #"ContaCredito Adicionada"