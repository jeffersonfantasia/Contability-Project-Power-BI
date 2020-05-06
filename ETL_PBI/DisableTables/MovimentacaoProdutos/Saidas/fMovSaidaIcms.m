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
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopSaidaDesconsiderar, [CODFISCAL] ) ),

    ListEstoque = 
        List.Combine(
            {
                ListCfopSaidaDevolucaoConsignado,
                ListCfopSaidaDevolucao,
                ListCfopSaidaTransferencia
            }
        ),
    
    ListMaterialTransito = 
        List.Combine(
            {
                ListCfopSaidaDemonstracao,
                ListCfopSaidaSimplesRemessa
            }
        ),
        
    ListIcmsRecuperar = 
        List.Combine(
            {
                ListCfopSaidaDevolucaoConsignado,
                ListCfopSaidaDevolucao
            }
        ),

    #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each 
            if List.Contains( ListEstoque, [CODFISCAL] ) then TxtContabilEstoque
            else if List.Contains( ListMaterialTransito, [CODFISCAL] ) then TxtContabilMaterialTransito
            else TxtContabilVendaICMS, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListIcmsRecuperar, [CODFISCAL] ) then TxtContabilRecuperarICMS
            else TxtContabilRecolherICMS, type text)

in
    #"ContaCredito Adicionada"