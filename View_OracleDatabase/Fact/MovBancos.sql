CREATE OR REPLACE VIEW VIEW_JC_MOVIMENTACAO_BANCOS AS
WITH PCMOVCR_CREDITO AS
 (SELECT M.NUMTRANS,
         B.CODFILIAL AS CODFILIALCRED,
         M.CODBANCO AS CODBANCOCRED,
         B.NOME AS BANCOCRED,
         B.CODCONTABIL AS CODCONTABILCRED,
         M.CODCOB,
         M.VALOR,
         (CASE
           WHEN M.HISTORICO2 = '                          0' OR
                M.HISTORICO2 LIKE '%TRANSF. DE%' THEN
            NULL
           ELSE
            M.HISTORICO2
         END) AS HISTORICO --PARA RETIRAR HISTORICO ZERADO OU COM O PADRAO TRANSF
    FROM PCMOVCR M
    LEFT JOIN PCBANCO B
      ON M.CODBANCO = B.CODBANCO
   WHERE M.DTESTORNO IS NULL
     AND M.ESTORNO <> 'S' --NAO TRAZER MOVIMENTACOES ESTORNADAS
     AND M.CODCOB = 'D' --SOMENTE TRANSACOES COM DINHERO
     AND M.TIPO = 'C' --NESSE PRIMEIRO MOMENTO TRAZER LANÇAMENTOS DE CREDITO
     AND M.CODROTINALANC IN (632, 643) --LANCAMENTOS SOMENTE COM MOVIMENTACAO ENTRE CAIXAS
     AND M.CODBANCO NOT IN (17, 20, 35, 50, 52, 53, 54)) --BANCOS DE BONIFICACAO E ACERTO MOTORISTA
,
PCMOVCR_DEBITO AS
 (SELECT (CASE
           WHEN M.DTCOMPENSACAO IS NULL THEN
            M.DATA
           ELSE
            M.DTCOMPENSACAO
         END) AS DATA, --PARA QUE TENHAMOS A DATA DE MOVIMENTACOES NAO CONCILIADAS ATÉ SEREM CONCILIADAS
         M.NUMTRANS,
         M.CONCILIACAO,
         B.CODFILIAL AS CODFILIALDEB,
         M.CODBANCO AS CODBANCODEB,
         B.NOME AS BANCODEB,
         B.CODCONTABIL AS CODCONTABILDEB
    FROM PCMOVCR M
    LEFT JOIN PCBANCO B
      ON M.CODBANCO = B.CODBANCO
   WHERE M.DTESTORNO IS NULL
     AND M.ESTORNO <> 'S' --NAO TRAZER MOVIMENTACOES ESTORNADAS
     AND M.CODCOB = 'D' --SOMENTE TRANSACOES COM DINHERO
     AND M.TIPO = 'D' --NESSE PRIMEIRO MOMENTO TRAZER LANÇAMENTOS DE DEBITO
     AND M.CODROTINALANC IN (632, 643) --LANCAMENTOS SOMENTE COM MOVIMENTACAO ENTRE CAIXAS
     AND M.CODBANCO NOT IN (17, 20, 35, 50, 52, 53, 54) --BANCOS DE BONIFICACAO E ACERTO MOTORISTA E EXTRAVIO DE MERCADORIA
  ),
BANCOS_EMPRESA AS
 (SELECT CODBANCO,
         (CASE
           WHEN CODFILIAL IN (1, 2, 7, 99) THEN
            '1'
           ELSE
            CODFILIAL
         END) AS CODEMPRESA
    FROM PCBANCO),
EMPRESA_CREDITO AS
 (SELECT E.CODEMPRESA AS EMPRESA_CREDITO, C.NUMTRANS
    FROM PCMOVCR_CREDITO C
   INNER JOIN BANCOS_EMPRESA E
      ON E.CODBANCO = C.CODBANCOCRED),
EMPRESA_DEBITO AS
 (SELECT E.CODEMPRESA AS EMPRESA_DEBITO, D.NUMTRANS
    FROM PCMOVCR_DEBITO D
   INNER JOIN BANCOS_EMPRESA E
      ON E.CODBANCO = D.CODBANCODEB),
PCMOVCR_BASE AS
 (SELECT D.DATA,
         C.NUMTRANS,
         C.CODFILIALCRED,
         C.CODBANCOCRED,
         C.CODCONTABILCRED,
         D.CODFILIALDEB,
         D.CODBANCODEB,
         D.CODCONTABILDEB,
         C.CODCOB,
         C.VALOR,
         D.CONCILIACAO,
         (CASE
           WHEN C.HISTORICO IS NULL THEN
            ('Nº ' || C.NUMTRANS || ' - ' || C.BANCOCRED || ' - P/ ' ||
            D.BANCODEB)
           ELSE
            ('Nº ' || C.NUMTRANS || ' - ' || C.BANCOCRED || ' - P/ ' ||
            D.BANCODEB || ' - ' || C.HISTORICO)
         END) HISTORICO
    FROM PCMOVCR_CREDITO C
   INNER JOIN PCMOVCR_DEBITO D
      ON C.NUMTRANS = D.NUMTRANS
   WHERE C.NUMTRANS NOT IN (116436) --PARA RETIRAR LANCAMENTO DE AJUSTE ENTRE INVESTIMENTOS DO ITAU EM JUN/19
  ),
EMPRESAS_DIFERENTES AS
 (SELECT B.DATA,
         B.NUMTRANS,
         B.CODFILIALCRED,
         B.CODBANCOCRED,
         B.CODCONTABILCRED,
         B.CODFILIALDEB,
         B.CODBANCODEB,
         B.CODCONTABILDEB,
         B.CODCOB,
         B.VALOR,
         B.CONCILIACAO
    FROM PCMOVCR_BASE B
   INNER JOIN EMPRESA_CREDITO C
      ON B.NUMTRANS = C.NUMTRANS
   INNER JOIN EMPRESA_DEBITO D
      ON B.NUMTRANS = D.NUMTRANS
   WHERE EMPRESA_CREDITO <> EMPRESA_DEBITO --EMPRESAS DIFERENTES
  )
SELECT B.DATA,
       B.NUMTRANS,
       B.CODFILIALCRED,
       B.CODBANCOCRED,
       B.CODCONTABILCRED,
       B.CODFILIALDEB,
       B.CODBANCODEB,
       B.CODCONTABILDEB,
       B.CODCOB,
       B.VALOR,
       B.CONCILIACAO,
       'G' AS TIPO,
       B.HISTORICO
  FROM PCMOVCR_BASE B
  LEFT JOIN EMPRESAS_DIFERENTES D
    ON B.NUMTRANS = D.NUMTRANS
 WHERE D.NUMTRANS IS NULL --RETIRAR LANCAMENTOS DE EMPRESAS DIFERENTES
UNION ALL
SELECT B.DATA,
       B.NUMTRANS,
       B.CODFILIALCRED,
       B.CODBANCOCRED,
       B.CODCONTABILCRED,
       B.CODFILIALDEB,
       B.CODBANCODEB,
       B.CODCONTABILDEB,
       B.CODCOB,
       B.VALOR,
       B.CONCILIACAO,
       'EC' AS TIPO,
       (B.NUMTRANS || ' - PAGTO EMPRESTIMOS A TERCEIROS') HISTORICO
  FROM PCMOVCR_BASE B
 INNER JOIN EMPRESAS_DIFERENTES E
    ON B.NUMTRANS = E.NUMTRANS
UNION ALL
SELECT B.DATA,
       B.NUMTRANS,
       B.CODFILIALDEB AS CODFILIALCRED,
       B.CODBANCOCRED,
       B.CODCONTABILCRED,
       B.CODFILIALDEB,
       B.CODBANCODEB,
       B.CODCONTABILDEB,
       B.CODCOB,
       B.VALOR,
       B.CONCILIACAO,
       'EB' AS TIPO,
       (B.NUMTRANS || ' - RECEBIMENTO EMPRESTIMOS A TERCEIROS') AS HISTORICO
  FROM PCMOVCR_BASE B
 INNER JOIN EMPRESAS_DIFERENTES E
    ON B.NUMTRANS = E.NUMTRANS
