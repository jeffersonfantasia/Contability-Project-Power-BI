(ColumnName) as list =>
let
  Lista =
    List.Buffer (
      {
        {"1", "1"},
        {"2", "1"},
        {"3", "1"},
        {"7", "1"},
        {"99", "1"},
        {"5", "5"},
        {"6", "6"}
      }
    ) 
in
  List.ReplaceMatchingItems( {ColumnName}, Lista )