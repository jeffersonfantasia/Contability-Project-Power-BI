### Instruções iniciais:

	1. SharePoint - Foi criado 5 listas para formar a hierarquia das contas contábeis do plano de conta da contabilidade:
		○ dBalancete_nível4
		○ dBalancete_nível3
		○ dBalancete_nível2
		○ dBalancete_nível1
		○ dBalancete
	2. Posteriormente no ETL do DataFlow foi realizado a mescla das tabelas com a dBalancete para que pudéssemos ter as descrições das contas.
	3. Foi realizado a inclusão da coluna ID que traz a informação da filial da empresa concatenada com a conta contábil, para que usemos como chave primária no vínculo das demais tabelas do modelo.
