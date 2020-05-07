(lista) as list =>
let
    Tabela = TableList,
    
    SelecaoListas = 
        Table.SelectColumns( Tabela, Text.Split(lista, ",") ),
    
    Unpivot = 
        Table.UnpivotOtherColumns( SelecaoListas, {}, "Atributo", "Valor" ),
    
    SelecaoValor = 
        Table.SelectColumns( Unpivot, {"Valor"} ),
    
    CombineList = 
        Table.ExpandListColumn( SelecaoValor, "Valor"),
    
    Listas = CombineList[Valor]
in
    List.Buffer( Listas )