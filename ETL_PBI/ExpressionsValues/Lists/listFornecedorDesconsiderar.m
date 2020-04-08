let
    ListFornecedorDesconsiderar = 
        Table.FromList( 
            List.RemoveNulls( 
                List.ReplaceValue( dFuncionarios[CPF] ,"",null,Replacer.ReplaceValue ) 
            ),
            Splitter.SplitByNothing(), null, null, ExtraValues.Error
        ),
    
    #"Consultas Mescladas" = Table.NestedJoin(ListFornecedorDesconsiderar, {"Column1"}, dFornecedor, {"CGC"}, "dFornecedor", JoinKind.LeftOuter),
    
    #"dFornecedor Expandido" = Table.ExpandTableColumn(#"Consultas Mescladas", "dFornecedor", {"CODFORNEC"}, {"CODFORNEC"}),
    
    #"Lista CodFornec" = 
        List.Buffer( 
            List.Union({
                List.RemoveNulls( #"dFornecedor Expandido"[CODFORNEC] ) , 
                ListFornecGov
            }) 
        )
in
    #"Lista CodFornec"