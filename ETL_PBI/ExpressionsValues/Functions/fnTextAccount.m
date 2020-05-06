(ColumnName) as text =>
let
    Tabela = TableString as table,
    Fonte = Table.Column( Tabela, ColumnName )

in
    List.Max( Fonte )