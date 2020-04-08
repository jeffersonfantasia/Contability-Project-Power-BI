let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"f8b61525-5184-4e44-8d43-f4916f7683e2" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="f8b61525-5184-4e44-8d43-f4916f7683e2"]}[Data],
    fLancAdiantamentoFornec1 = #"f8b61525-5184-4e44-8d43-f4916f7683e2"{[entity="fLancAdiantamentoFornec"]}[Data],
    
    #"Conta Debito Adicionada" = Table.AddColumn(fLancAdiantamentoFornec1, "CONTADEBITO", each 
        if [VPAGO] > 0 
        then TxtAdiantamentoFornecedor 
        else [CODCONTABILBANCO], type text),
    
    #"Conta Credito Adicionada" = Table.AddColumn(#"Conta Debito Adicionada", "CONTACREDITO", each 
        if [VPAGO] > 0 
        then [CODCONTABILBANCO] 
        else TxtAdiantamentoFornecedor, type text),
    
    #"Outras Colunas Removidas" = 
        Table.SelectColumns(#"Conta Credito Adicionada",{"CODFILIAL", "RECNUM", "VALOR", "DATA", "CODFORNEC", "TIPOPARCEIRO", "HISTORICO", "NUMTRANS", "CONTADEBITO", "CONTACREDITO", "CODCONTA"}),
    
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(#"Outras Colunas Removidas",{{"DATA", type date}, {"RECNUM", Int64.Type}, {"CODFORNEC", Int64.Type}})
in
    #"Tipo Alterado"