let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"e1873762-b5d0-4c6c-947e-617597d25e09" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="e1873762-b5d0-4c6c-947e-617597d25e09"]}[Data],
    fDevFornecPagto1 = #"e1873762-b5d0-4c6c-947e-617597d25e09"{[entity="fDevFornecPagto"]}[Data],
    
    #"Consultas Mescladas" = 
        Table.NestedJoin(fDevFornecPagto1, {"CODFILIAL", "CODFORNEC"}, dContabilFilialFornec, {"CODFILIAL", "CODFORNEC"}, "dContabilFilialFornec", JoinKind.LeftOuter),
    
    #"dContabilFilialFornec Expandido" = 
        Table.ReplaceValue(
            Table.ExpandTableColumn(#"Consultas Mescladas", "dContabilFilialFornec", {"CODCONTAB"}, {"CODCONTAB"}
            ), null, fnTextAccount("txtFornecedorSemConta"), Replacer.ReplaceValue,{"CODCONTAB"}
        ),
    
    #"Conta Debito Adicionada" = 
        Table.AddColumn(#"dContabilFilialFornec Expandido", "CONTADEBITO", each
            if [TIPO] = "D" then [CODCONTAB_BANCO]
            else if [TIPO] = "F" then [CODCONTAB]
            else if [TIPO] = "P" then fnTextAccount("txtPrejuizosClientes") 
            else null, type text),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each fnTextAccount("txtDevolucaoReceber"), type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "RECNUM", "DATA", "VALOR", "TIPO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"RECNUM", Int64.Type}})
in
    #"Tipo Alterado"