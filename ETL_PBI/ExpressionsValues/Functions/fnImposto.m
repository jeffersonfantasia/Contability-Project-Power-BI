(ColumnName) as list =>
let 
  TxtImpostoINSS = "420",
  TxtImpostoISS = "410",
  TxtImpostoCSRF = "419",
  TxtImpostoIRRF = "415",
  TxtImpostoINSSFuncionario = "453",
  TxtImpostoIRRFFuncionario = "446",
  Lista = 
    List.Buffer(
      {
        {"INSS", TxtImpostoINSS},
        {"ISS", TxtImpostoISS},
        {"CSRF", TxtImpostoCSRF},
        {"IRRF", TxtImpostoIRRF},
        {"FINSS", TxtImpostoINSSFuncionario},
        {"FIRRF", TxtImpostoIRRFFuncionario}
      }
    )  
in
    List.ReplaceMatchingItems( {ColumnName}, Lista )