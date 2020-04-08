let
  Lista =
    Table.SelectColumns(Table.SelectRows(dFornecedor, each [OBS2] = "GOV"), {"CODFORNEC"}),
    
  ListaFornecedores = List.Buffer( Lista[CODFORNEC] )
in
    ListaFornecedores