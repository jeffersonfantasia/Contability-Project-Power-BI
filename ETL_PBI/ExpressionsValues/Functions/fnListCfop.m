(ColumnName) as list =>
let
    Tabela = TableList as table,
    Fonte = Table.Column( Tabela, ColumnName )

in
    List.Buffer( Fonte{0} )