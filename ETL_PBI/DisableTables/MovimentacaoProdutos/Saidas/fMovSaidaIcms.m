let
    Fonte = 
        Table.SelectColumns(fMovProdutoSaida, {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALCREDICMSNF", "VLTOTALICMSPART", "VLTOTALFCPPART"}),
    
    #"Valor Adicionada" = 
        Table.AddColumn(Fonte, "VALOR", each [VLTOTALCREDICMSNF] + [VLTOTALICMSPART] + [VLTOTALFCPPART], type number),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Valor Adicionada",{"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VALOR"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(#"Outras Colunas Removidas", {"DTMOV", "CODFILIAL", "CODFISCAL", "CODOPER", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VALOR]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0 and not List.Contains( ListCfopSaidaDesconsiderar, [CODFISCAL] ) ),

    ListEstoque = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaDevolucaoConsignado,
                    ListCfopSaidaDevolucao,
                    ListCfopSaidaTransferencia
                }
            )
        ),

    ListMaterialTransito = 
        List.Buffer(
            List.Union(
                {
                    ListCfopSaidaDemonstracao,
                    ListCfopSaidaSimplesRemessa
                }
            )
        ),

    ListIcmsRecuperar = 
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
            if List.Contains( ListEstoque, [CODFISCAL] ) then TxtContabilEstoque
            else if List.Contains( ListMaterialTransito, [CODFISCAL] ) then TxtContabilMaterialTransito
            else TxtContabilVendaICMS, type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each 
            if List.Contains( ListIcmsRecuperar, [CODFISCAL] ) then TxtContabilRecuperarICMS
            else TxtContabilRecolherICMS, type text)

in
    #"ContaCredito Adicionada"