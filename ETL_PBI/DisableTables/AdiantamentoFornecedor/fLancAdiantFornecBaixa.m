let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"20b937c8-fc6f-4f3d-a4b6-7ac0c3393089" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="20b937c8-fc6f-4f3d-a4b6-7ac0c3393089"]}[Data],
    fLancAdiantFornecBaixa1 = #"20b937c8-fc6f-4f3d-a4b6-7ac0c3393089"{[entity="fLancAdiantFornecBaixa"]}[Data],
    
    #"Consultas Mescladas" = 
        Table.NestedJoin(fLancAdiantFornecBaixa1, {"CODFILIAL", "CODFORNEC"}, dContabilFilialFornec, {"CODFILIAL", "CODFORNEC"}, "dContabilFilialFornec", JoinKind.LeftOuter),
    
    #"Conta Debito Expandido" = 
        Table.ReplaceValue(Table.ExpandTableColumn(#"Consultas Mescladas", "dContabilFilialFornec", {"CODCONTAB"}, {"CONTADEBITO"}), null, fnTextAccount("txtFornecedorSemConta"), Replacer.ReplaceValue,{"CONTADEBITO"}),
    
    #"Conta Credito Adicionada" = 
        Table.AddColumn(#"Conta Debito Expandido", "CONTACREDITO", each 
            if [VPAGO] > 0 
            then fnTextAccount("txtAdiantamentoFornecedor") 
            else fnTextAccount("txtDescontosObtidos"), type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "RECNUM", "VALOR", "DATA", "CODCONTA", "CODFORNEC", "TIPOPARCEIRO", "HISTORICO", "CONTADEBITO", "CONTACREDITO"}),
    
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"RECNUM", Int64.Type}, {"CODFORNEC", Int64.Type}})
in
    #"Tipo Alterado"