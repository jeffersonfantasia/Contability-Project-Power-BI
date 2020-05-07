let
    Fonte = PowerBI.Dataflows(null),
    #"62685399-e81e-4c28-bb3e-37dd18427335" = Fonte{[workspaceId="62685399-e81e-4c28-bb3e-37dd18427335"]}[Data],
    #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4" = #"62685399-e81e-4c28-bb3e-37dd18427335"{[dataflowId="0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"]}[Data],
    fMovProdutoEnt1 = #"0a2a816b-7a5c-410b-ae9e-34c212f4f6b4"{[entity="fMovProdutoEnt"]}[Data],
       
    #"Tipo Alterado" = 
        Table.TransformColumnTypes(fMovProdutoEnt1,{{"DTMOV", type date}}),
        
    fMovProdutoEnt =
        Table.SelectColumns(#"Tipo Alterado", {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO", "VLTOTALSTFORANF"}),
    
    #"Linhas Agrupadas" = 
        Table.Group(fMovProdutoEnt, {"DTMOV", "CODFILIAL", "CODFISCAL", "TIPOCONTABIL", "CODIGO", "CLIENTE_FORNECEDOR", "NUMTRANSACAO"}, {{"VALOR", each List.Sum([VLTOTALSTFORANF]), type number}}),
    
    #"ValorPositivo Filtradas" = 
        Table.SelectRows(#"Linhas Agrupadas", each [VALOR] > 0),

     #"ContaDebito Adicionada" = 
        Table.AddColumn(#"ValorPositivo Filtradas", "CONTADEBITO", each fnTextAccount("txtContabilEstoque"), type text),
    
    #"ContaCredito Adicionada" = 
        Table.AddColumn(#"ContaDebito Adicionada", "CONTACREDITO", each fnTextAccount("txtContabilRecolherST"), type text)
in
    #"ContaCredito Adicionada"