let
    Fonte = 
        Table.Combine({
            fLancAdiantamentoFornec, 
            fLancAdiantFornecBaixa, 
            fAdiantamentoCliente, 
            fAdiantamentoClienteBaixado, 
            fContasReceberDesdCartao, 
            fContasReceberBaixado, 
            fContasReceberDupManual, 
            fCreditoAvulso, 
            fDevCliReceitaPag, 
            fDevCliDescDuplicata, 
            fDevCliCreditoGerado, 
            fDevFornecPagto, 
            fLancamentosPagos, 
            fLancamentosAjuste
        }),

    #"Debito Contabil Adicionada" = 
        Table.CombineColumns(    
            Table.DuplicateColumn(
                Table.ExpandListColumn( 
                    Table.AddColumn(Fonte, "CONTA_DEBITO", each fnTransformFilial([CODFILIAL])
                    ),"CONTA_DEBITO"
                ), "CONTADEBITO", "CONTADEBITODUP"
            ),{"CONTA_DEBITO", "CONTADEBITODUP"},Combiner.CombineTextByDelimiter("-", QuoteStyle.None),"CONTA_DEBITO"
        ),

    #"Credito Contabil Adicionada" = 
        Table.CombineColumns(
            Table.DuplicateColumn(
                Table.ExpandListColumn( 
                    Table.AddColumn(#"Debito Contabil Adicionada", "CONTA_CREDITO", each fnTransformFilial([CODFILIAL])
                    ),"CONTA_CREDITO"
                ),"CONTACREDITO", "CONTACREDITODUP"
            ),{"CONTA_CREDITO", "CONTACREDITODUP"},Combiner.CombineTextByDelimiter("-", QuoteStyle.None),"CONTA_CREDITO"
        ),
        
    #"Unpivot Conta Contabil" = 
        Table.UnpivotOtherColumns(
            #"Credito Contabil Adicionada", 
            {"CODFILIAL", "RECNUM", "VALOR", "DATA", "CODFORNEC", "TIPOPARCEIRO", "HISTORICO", "NUMTRANS", "CODCONTA", "CODCRED", "CODIGO", "TIPO", "CODCOB", "NUMTRANSVENDA", "CODLANC", "CODUSUR", "NUMNOTA_DEV", "CONTADEBITO", "CONTACREDITO"}, 
            "TIPOCONTA", "CONTACONTABIL"
        ),
    
    #"fMovBancosTransferencia Acrescentada" = 
        Table.Combine({#"Unpivot Conta Contabil", fMovBancosTransferencia})
in
    #"fMovBancosTransferencia Acrescentada"