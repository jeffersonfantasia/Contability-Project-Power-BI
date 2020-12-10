	1. Adicionar coluna com os códigos contábil dos impostos - (buscar da fLancImpostosNotas).
	2. Adicionar coluna com o código contábil dos fornecedores - (buscar da dContabilFilialFornec), substituindo os valores nulos pelo código de outros fornecedores (99999)
	3. Adicionar coluna com código contábil das contas - (buscar da dContasGerenciais).
	4. Adicionar coluna CONTA DEBITO:
		○ TIPO F - 
			§ Lista com grupos e contas gerenciais a serem consideradas, desconsiderando o fornecedor - ListGruposDesconsiderar, ListContasDesconsiderar, ListContasConsiderar, ListFornecedoresDesconsiderar
				□ VPAGO positivo: conta contábil da conta gerencial
				□ VPAGO negativo: conta do banco em questão 
			§ Demais casas considerando o fornecedor
				□ VPAGO positivo: conta do fornecedor
				□ VPAGO negativo: conta do banco em questão 
		○ TIPO O -
			§ VPAGO positivo: conta contábil da conta gerencial
				□ Se a empresa for JC Brothers - Puxar a conta de Imposto de Renda a Restituir
				□ Se não for, puxar conta contábil da conta gerencial
			§ VPAGO negativo: conta do banco em questão
		○ TIPO D - conta do fornecedor em questão
		○ TIPO J - conta de Juros sob atraso
		○ TIPO I - conta do impostos em questão 
		○ TIPO MK - conta do fornecedor em questão
		○ TIPO MI - conta do cliente em questão
		○ TIPO C - 
			§ VPAGO positivo: conta contábil da conta gerencial 
			§ VPAGO negativo: conta do fornecedor
		○ TIPO EC - conta contábil da conta gerencial
		○ TIPO EB - conta de empréstimo de terceiros
		○ TIPO A - conta contábil da conta gerencial
		○ TIPO MT:
			§ VPAGO positivo: conta contábil da conta gerencial
			§ VPAGO negativo: conta do banco em questão
		○ TIPO V -  conta do banco em questão
	5. Adicionar coluna CONTA CREDITO:
		○ TIPO F -
			§ Lista com grupos e contas gerenciais a serem consideradas desconsiderando o fornecedor - ListGruposDesconsiderar, ListContasDesconsiderar, ListContasConsiderar, ListFornecedoresDesconsiderar
				□ VPAGO positivo: conta do banco em questão 
				□ VPAGO negativo: conta contábil da conta gerencial - Se não houver conta, traremos conta de Outras receitas financeiras
			§ Demais casas considerando o fornecedor
				□ VPAGO positivo: conta do banco em questão 
				□ VPAGO negativo: conta contábil da conta gerencial - Se não houver conta, traremos conta de Outras receitas financeiras
		○ TIPO O - 
			§ VPAGO positivo: conta do banco em questão
			§ VPAGO negativo: conta contábil da conta gerencial - Se não houver conta, traremos conta de Outras receitas financeiras
		○ TIPO D - conta de Desconto financeiro obtido
		○ TIPO J - conta do banco em questão 
		○ TIPO I - conta do banco em questão
		○ TIPO MK - conta do cliente em questão
		○ TIPO MI - conta do fornecedor em questão
		○ TIPO C - 
			§ VPAGO positivo: conta do banco em questão
			§ VPAGO negativo: conta contábil da conta gerencial
		○ TIPO EC - conta de empréstimo de terceiros
		○ TIPO EB - conta do banco em questão
		○ TIPO A - conta de cliente em questão
		○ TIPO MT:
			§ VPAGO positivo: conta do banco em questão
			§ VPAGO negativo: conta contábil da conta gerencial - Se não houver conta, traremos conta de Outras receitas financeiras
		○ TIPO V -  Outras receitas financeiras
	6. Adicionar coluna DATA:
		○ TIPO F - Data de Pagamento
		○ TIPO O - 
			§ Grupo de contas dentro da ListGruposCompensacao - Data de Compensação
			§ Grupo de contas fora da ListGruposCompensacao - Data de Pagamento
		○ TIPO D - Data de Pagamento
		○ TIPO J - Data de Pagamento
		○ TIPO I - Data de Pagamento
		○ TIPO MK - Data de Competência
		○ TIPO MI - Data de Competência
		○ TIPO C - Data de Competência
		○ TIPO EC - Data de Pagamento
		○ TIPO EB - Data de Pagamento
		○ TIPO A - Data de Competência
		○ TIPO MT - Data de Compensação
		○ TIPO V - Data de Compensação
