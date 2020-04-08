CREATE OR REPLACE VIEW VIEW_JC_DEVCLIENTE_CREDITO AS
WITH NUMTRANSCLIDEV1400 AS --REGISTROS DESDOBRADOS PELA ROTINA 1400
 (SELECT DISTINCT (L.NUMTRANSENTDEVCLI) AS NUMTRANSENTDEVCLI,
                  L.VALOR,
                  L.CODIGO
    FROM PCCRECLI L
   WHERE L.NUMTRANSENTDEVCLI IS NOT NULL
     AND L.CODROTINA = 1400
     AND L.DTESTORNO IS NOT NULL),
NUMTRANSCLIDEV AS --REGISTROS CRIADOS A PARTIR DAS ROTINA DE DEVOLUÇÃO
 (SELECT DISTINCT (NUMTRANSENTDEVCLI) AS NUMTRANSENTDEVCLI,
                  L.VALOR,
                  L.CODIGO
    FROM PCCRECLI L
   WHERE NUMTRANSENTDEVCLI IS NOT NULL
     AND CODROTINA IN (1303, 1346, 1360)),
REGISTROSEXCLUIR AS --REGISTROS POSITIVO E NEGATIVO QUE FORAM DESDOBRADOS E DEVEM SER DESCONSIDERADOS
 (SELECT I.CODIGO
    FROM NUMTRANSCLIDEV I
   INNER JOIN NUMTRANSCLIDEV1400 D
      ON I.NUMTRANSENTDEVCLI = D.NUMTRANSENTDEVCLI
     AND I.VALOR = (D.VALOR * -1)
  UNION
  SELECT D.CODIGO
    FROM NUMTRANSCLIDEV I
   INNER JOIN NUMTRANSCLIDEV1400 D
      ON I.NUMTRANSENTDEVCLI = D.NUMTRANSENTDEVCLI
     AND I.VALOR = (D.VALOR * -1)),
CFOPMOV AS
 (SELECT NUMTRANSENT, MAX(CODFISCAL) CFOP FROM PCMOV GROUP BY NUMTRANSENT)
SELECT L.CODFILIAL,
       E.NUMNOTA AS NUMNOTA_DEV,
       L.DTDESCONTO AS DATA,
       L.CODIGO,
       L.NUMLANCBAIXA,
       (CASE
         WHEN L.VALOR < 0 THEN
          (L.VALOR * -1)
         ELSE
          L.VALOR
       END) AS VALOR,
       C.CODCONTAB AS CODCONTAB_CLI,
       0 AS CODCONTAB_BANCO,
       (CASE
         WHEN L.NUMTRANSVENDADESC IS NOT NULL THEN
          'C'
         ELSE
          'R'
       END) AS TIPO,
       (CASE
         WHEN L.NUMTRANSVENDADESC IS NOT NULL THEN
          'BAIXA CRED NFD ' || E.NUMNOTA || ' - DUPLIC - ' || L.NUMNOTADESC ||
          ' - ' || C.CLIENTE
         ELSE
          'RECEITA CRED NFD ' || E.NUMNOTA || ' - ' || C.CLIENTE
       END) AS HISTORICO
  FROM PCCRECLI L
  LEFT JOIN PCCLIENT C
    ON L.CODCLI = C.CODCLI
  LEFT JOIN PCNFENT E
    ON L.NUMTRANSENTDEVCLI = E.NUMTRANSENT
  LEFT JOIN CFOPMOV M
    ON L.NUMTRANSENTDEVCLI = M.NUMTRANSENT
  LEFT JOIN REGISTROSEXCLUIR R
    ON L.CODIGO = R.CODIGO
 WHERE L.NUMTRANSENTDEVCLI IS NOT NULL --SOMENTE REGISTROS ORIUNDOS DE DEVOLUÇÃO DE CLIENTE
   AND (L.NUMTRANSVENDADESC IS NOT NULL OR L.NUMLANCBAIXA IS NOT NULL) --DESCONTO NO A RECEBER OU BAIXA COMO RECEITA
   AND M.CFOP NOT IN (1913, 2913) --RETIRAR OS LANCAMENTOS GERADOS POR RETORNO DE AMOSTRA DE SHOWROOM
   AND R.CODIGO IS NULL --DESCONSIDERAR OS REGISTROS QUE FORAM DESDOBRADOS PELA 1400 
UNION ALL
SELECT L.CODFILIAL,
       E.NUMNOTA AS NUMNOTA_DEV,
       L.DTDESCONTO AS DATA,
       L.CODIGO,
       L.NUMLANCBAIXA,
       (CASE
         WHEN L.VALOR < 0 THEN
          (L.VALOR * -1)
         ELSE
          L.VALOR
       END) AS VALOR,   
       '' AS CODCONTAB_CLI,
       B.CODCONTABIL AS CODCONTAB_BANCO,
       'D' AS TIPO,       ('PAG CRED NFD ' || E.NUMNOTA || ' - ' || C.CLIENTE) AS HISTORICO
  FROM PCCRECLI L
  LEFT JOIN PCCLIENT C
    ON L.CODCLI = C.CODCLI
  LEFT JOIN PCMOVCR V
    ON L.NUMTRANSBAIXA = V.NUMTRANS
  LEFT JOIN PCBANCO B
    ON V.CODBANCO = B.CODBANCO
  LEFT JOIN PCNFENT E
    ON L.NUMTRANSENTDEVCLI = E.NUMTRANSENT
  LEFT JOIN CFOPMOV M
    ON L.NUMTRANSENTDEVCLI = M.NUMTRANSENT
  LEFT JOIN REGISTROSEXCLUIR R
    ON L.CODIGO = R.CODIGO
 WHERE L.NUMTRANSENTDEVCLI IS NOT NULL --SOMENTE REGISTROS ORIUNDOS DE DEVOLUÇÃO DE CLIENTE
   AND L.NUMTRANSVENDADESC IS NULL --RETIRAR REGISTROS QUE FORAM APLICADOS COMO DESCONTO NO CONTAS A RECEBER
   AND L.NUMTRANSBAIXA IS NOT NULL --SOMENTE REGISTROS QUE FORAM BAIXADO EM BANCOS MOV NUMERARIOS
   AND M.CFOP NOT IN (1913, 2913) --RETIRAR OS LANCAMENTOS GERADOS POR RETORNO DE AMOSTRA DE SHOWROOM
   AND R.CODIGO IS NULL --DESCONSIDERAR OS REGISTROS QUE FORAM DESDOBRADOS PELA 1400