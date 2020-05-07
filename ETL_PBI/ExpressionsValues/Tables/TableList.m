let
  Fonte = #table(
        type table [Name = text, Value = list ],
        {
          {"listContasConsiderar", {515106,515107,515112,515113} },
          {"listContasDesconsiderar", {410105} },
          {"listEmpresaJCBrothers", {"1","2","7"} },
          {"listGruposCompensacao", {610,620,650} },
          {"listGruposDesconsiderar", {140,300,510,515,610,620,650,670,810,820} },
          {"listCfopEntradaBonificada", {1910,2910,2911} },
          {"listCfopEntradaConserto", {1915,1916,2915,2916} },
          {"listCfopEntradaDemonstracao", {1912,1913,2912,2913} },
          {"listCfopEntradaDevolucao", {1202,1411,2202,2411} },
          {"listCfopEntradaFatEntFut", {1922,2922} },
          {"listCfopEntradaMercadoriaRevenda", {1101,1102,1403,2102,2401,2403} },
          {"listCfopEntradaMercConsignada", {1917,1918,2917,2918} },
          {"listCfopEntradaMercConsigPosVenda", {1113,2113,1114,2114} },
          {"listCfopEntradaRemessaContaOrdem", {1923,2923} },
          {"listCfopEntradaRemessaEntFut", {1116,1117,2116,2117} },
          {"listCfopEntradaSimplesRemessa", {1908, 1949,2949} },
          {"listCfopEntradaTransferencia", {1152,1409} },
          {"listCfopEntradaTriangular", {1118,1119,2118,2119} },
          {"listCfopSaidaBonificada", {5910,6910} },
          {"listCfopSaidaConserto", {5915,5916,6915,6916} },
          {"listCfopSaidaDemonstracao", {5912,6912} },
          {"listCfopSaidaDesconsiderar", {5904,5908,5919,6919,5929} },
          {"listCfopSaidaDevolucao", {5202,5209,5411,6202,6411} },
          {"listCfopSaidaDevolucaoConsignado", {5918, 6918} },
          {"listCfopSaidaFatContaOrdem", {5119,6119} },
          {"listCfopSaidaFatEntFut", {5922,6922} },
          {"listCfopSaidaPerdaMercadoria", {5927} },
          {"listCfopSaidaRemessaContaOrdem", {5923,6923} },
          {"listCfopSaidaRemessaEntFut", {5117,6117} },
          {"listCfopSaidaSimplesRemessa", {5949,6949} },
          {"listCfopSaidaTransferencia", {5152,5409} },
          {"listCfopSaidaVendaConsignada", {5115,6115} },
          {"listCfopSaidaVendaNormal", {5102,5109,5403,5405,6102,6108,6403} },
          {"listCfopSaidaVendaTriangular", {5120,6120} }
        }
      ),

  #"Coluna dinamizada" = 
    Table.Pivot(Table.TransformColumnTypes(Fonte, {{"Name", type text}}), List.Distinct(Table.TransformColumnTypes(Fonte, {{"Name", type text}})[Name]), "Name", "Value")
in
  #"Coluna dinamizada"