CREATE OR REPLACE VIEW VIEW_JC_DEVFORNEC_PAGTO AS
WITH NFDEVCANCELADA AS --VERBAS GERADAS COMO O REGISTRO DO CANCELAMENTO
 (SELECT NUMTRANSENTDEVFORNEC
    FROM PCMOVCRFOR
   WHERE NUMTRANSENTDEVFORNEC IS NOT NULL
     AND DTPAGO IS NOT NULL),
VERBASNFDEV AS
 (SELECT V.NUMVERBA, F.NUMNOTA AS NUMNOTADEV
    FROM PCMOVCRFOR V
    LEFT JOIN PCNFSAID F
      ON V.NUMTRANSENTDEVFORNEC = F.NUMTRANSVENDA
    LEFT JOIN NFDEVCANCELADA D
      ON V.NUMTRANSENTDEVFORNEC = D.NUMTRANSENTDEVFORNEC
   WHERE V.NUMTRANSENTDEVFORNEC IS NOT NULL
     AND D.NUMTRANSENTDEVFORNEC IS NULL), --RETIRAR LANCAMENTOS DAS NOTAS CANCELADAS, TANTO A VERBA GERADA COMO O REGISTRO DO CANCELAMENTO
BAIXAVERBAS AS
 (SELECT V.NUMLANC,
         V.NUMTRANSENT,
         V.NUMVERBA,
         V.NUMTRANSEST,
         F.NUMNOTADEV,
         V.VALOR AS VALORDEV
    FROM PCMOVCRFOR V
   INNER JOIN VERBASNFDEV F
      ON V.NUMVERBA = F.NUMVERBA
   WHERE V.TIPO = 'C' --SOMENTE BAIXAS DAS VERBAS
     AND V.ROTINALANC NOT IN (1327) --RETIRANDO LANCAMENTOS CANCELADOS
     AND DTESTORNO IS NULL) --RETIRAR LANCAMENTOS ESTORNADOS
--RECEBIMENTO EM DINHEIRO--
SELECT L.CODFILIAL,
       L.RECNUM,
       (CASE
         WHEN L.VPAGO < 0 THEN
          NVL(L.VPAGO, 0) * -1
         ELSE
          L.VPAGO
       END) AS VALOR, --TRANSFORMAR OS VALORES NEGATIVOS PARA ARQUIVO CONTABILIDADE
       TO_DATE(NVL(M.DTCOMPENSACAO, L.DTCOMPETENCIA), 'DD/MM/YY') AS DATA,
       (CASE
         WHEN B.CODCONTABIL = 837 THEN
          725
         ELSE
          B.CODCONTABIL
       END) AS CODCONTAB_BANCO, --TROCA DO CODCONTABIL DOS BANCOS DE BONIFICACAO/ACERTO MOTORISTA
       0 AS NOTA_ENT,
       L.CODCONTA,
       L.CODFORNEC,
       V.NUMNOTADEV,
       'D' AS TIPO,
       (CASE
         WHEN L.VPAGO < 0 THEN
          ('PAG FORNEC NFD ' || V.NUMNOTADEV || ' - ' || F.FORNECEDOR)
         ELSE
          ('DEV PAG FORNEC NFD ' || V.NUMNOTADEV || ' - ' || F.FORNECEDOR)
       END) HISTORICO
  FROM PCLANC L
 INNER JOIN BAIXAVERBAS V
    ON L.NUMTRANS = V.NUMTRANSEST
 INNER JOIN PCMOVCR M
    ON L.NUMTRANS = M.NUMTRANS
  LEFT JOIN PCBANCO B
    ON M.CODBANCO = B.CODBANCO
  LEFT JOIN PCFORNEC F
    ON L.CODFORNEC = F.CODFORNEC
 WHERE L.DTCANCEL IS NULL --NAO CONSIDERAR LANCAMENTOS CANCELADOS
   AND L.DTESTORNOBAIXA IS NULL --NAO CONSIDERAR LANCAMENTOS ESTORNADOS
   AND M.DTESTORNO IS NULL --PARA NAO TRAZER LANCAMENTO DUPLICADOS OU TRIPILICADOS QUE TENHA SIDO ESTORNADOS NA PCMOVCR   
   AND M.CODROTINALANC NOT IN (1209) --NAO CONSIDERAR MOVIMENTACOES QUE FORAM ESTORNADAS
   AND L.DTPAGTO IS NOT NULL --APENAS LANCAMENTOS PAGOS
UNION ALL
--BAIXA DA VERBA EM DUPLICATAS A PAGAR--SELECT L.CODFILIAL,
       L.RECNUM,
       V.VALORDEV AS VALOR, 
       L.DTPAGTO AS DATA,
       0 AS CODCONTAB_BANCO,
       0 AS NOTA_ENT,
       L.CODCONTA,
       L.CODFORNEC,
       V.NUMNOTADEV,
       'F' AS TIPO,
       ('BAIXA NFD ' || V.NUMNOTADEV || ' - DUP ' || L.NUMNOTA || '-' ||
       L.DUPLIC || ' - ' || F.FORNECEDOR) AS HISTORICO
  FROM PCLANC L
 INNER JOIN BAIXAVERBAS V
    ON L.RECNUM = V.NUMLANC
  LEFT JOIN PCFORNEC F
    ON L.CODFORNEC = F.CODFORNEC
 WHERE L.RECNUM NOT IN (0) --RETIRAR VERBAS COM RECNUM ZERADO POIS SÃO VERBAS QUE FORAM RECEBIDAS COM NF BONIFICACAO
   AND L.DTPAGTO IS NOT NULL --SOMENTE LANCAMENTOS PAGOS
   AND L.DTCANCEL IS NULL --NAO CONSIDERAR LANCAMENTOS CANCELADOS
UNION ALL
--BAIXA DAS VERBAS COMO PREJUIZOS--
SELECT V.CODFILIAL,
       V.NUMVERBA AS RECNUM,
       V.VALOR,
       V.DTPAGO AS DATA,
       0 AS CODCONTAB_BANCO,
       E.NUMNOTA AS NOTA_ENT,
       V.CODCONTA,
       V.CODFORNEC,
       F.NUMNOTADEV,
       'P' AS TIPO,
       ('PREJUIZO NFD ' || F.NUMNOTADEV || ' - ' || F.FORNECEDOR) AS HISTORICO
  FROM PCMOVCRFOR V
 INNER JOIN VERBASNFDEV F
    ON V.NUMVERBA = F.NUMVERBA
  LEFT JOIN PCNFENT E
    ON V.NUMTRANSENT = E.NUMTRANSENT
  LEFT JOIN PCFORNEC F
    ON V.CODFORNEC = F.CODFORNEC
 WHERE V.TIPO = 'C' --SOMENTE BAIXAS DAS VERBAS
   AND V.ROTINALANC NOT IN (1327) --RETIRANDO LANCAMENTOS CANCELADOS
   AND V.DTESTORNO IS NULL --RETIRAR LANCAMENTOS ESTORNADOS
   AND (V.NUMLANC IS NULL OR V.NUMLANC IN (0))
UNION ALL
--BAIXA DEVOLUCAO DIRETO NA DUPLICATA SEM GERAR VERBA--
SELECT L.CODFILIAL,
       L.RECNUM,
       L.VALORDEV AS VALOR,
       L.DTPAGTO AS DATA,
       0 AS CODCONTAB_BANCO,
       0 AS NOTA_ENT,
       L.CODCONTA,
       L.CODFORNEC,
       L.NUMNOTADEV,
       'F' AS TIPO,
       ('BAIXA NFD ' || L.NUMNOTADEV || ' - DUP ' || L.NUMNOTA || '-' ||
       L.DUPLIC || ' - ' || F.FORNECEDOR) AS HISTORICO
  FROM PCLANC L
  LEFT JOIN BAIXAVERBAS V
    ON L.RECNUM = V.NUMLANC
  LEFT JOIN PCFORNEC F
    ON L.CODFORNEC = F.CODFORNEC
 WHERE L.VALORDEV > 0 --SOMENTE REGISTROS COM APLICAÇÃO DE DEVOLUÇÃO COMO DESCONTO
   AND L.NUMNOTADEV IS NOT NULL --SOMENTE REGISTROS AONDE TEMOS O NUMERO DA NOTA DE DEVOLUÇÃO
   AND L.DTPAGTO IS NOT NULL --SOMENTE LANÇAMENTOS PAGOS
   AND L.DTCANCEL IS NULL --NAO CONSIDERAR LANCAMENTOS CANCELADOS
   AND V.NUMLANC IS NULL --RETIRAR DESCONTO DE DEVOLUÇÃO REFERENTE AS VERBAS

;