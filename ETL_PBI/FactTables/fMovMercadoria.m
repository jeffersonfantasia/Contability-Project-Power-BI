let
    Fonte = 
        Table.Combine(
            {
                fMovEntradaMercadoria,
                fMovEntradaIcms,
                fMovEntradaPis,
                fMovEntradaCofins,
                fMovEntradaIcmsPartilha,
                fMovEntradaStForaNota,
                fMovEntradaCusto,
                fMovSaidaMercadoria,
                fMovSaidaIcms,
                fMovSaidaPis,
                fMovSaidaCofins,
                fMovSaidaIcmsPartilha,
                fMovSaidaSt,
                fMovSaidaCusto
            }
        ),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(Fonte,{"DTMOV", "CODFILIAL", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VALOR", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Debito Contabil Adicionada" = 
        Table.CombineColumns(    
            Table.DuplicateColumn(
                Table.ExpandListColumn( 
                    Table.AddColumn( #"Outras Colunas Removidas", "CONTA_DEBITO", each fnTransformFilial([CODFILIAL]) 
                    ),"CONTA_DEBITO"
                ), "CONTADEBITO", "CONTADEBITODUP"
            ),{"CONTA_DEBITO", "CONTADEBITODUP"}, Combiner.CombineTextByDelimiter("-", QuoteStyle.None),"CONTA_DEBITO"
        ),

    #"Credito Contabil Adicionada" = 
        Table.CombineColumns(
            Table.DuplicateColumn(
                Table.ExpandListColumn( 
                    Table.AddColumn( #"Debito Contabil Adicionada", "CONTA_CREDITO", each fnTransformFilial([CODFILIAL]) 
                    ),"CONTA_CREDITO"
                ),"CONTACREDITO", "CONTACREDITODUP"
            ),{"CONTA_CREDITO", "CONTACREDITODUP"}, Combiner.CombineTextByDelimiter("-", QuoteStyle.None),"CONTA_CREDITO"
        ),
    
    #"Unpivot Conta Contabil" = 
        Table.UnpivotOtherColumns(
            #"Credito Contabil Adicionada", 
            {"DTMOV", "CODFILIAL", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VALOR", "CONTADEBITO", "CONTACREDITO"}, 
            "TIPOCONTA", "CONTACONTABIL"
    )
    
in
    #"Unpivot Conta Contabil"