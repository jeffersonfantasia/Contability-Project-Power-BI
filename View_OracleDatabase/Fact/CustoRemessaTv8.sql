CREATE OR REPLACE VIEW VIEW_JC_CUSTOCONT_TV8 AS
WITH MOVT7 AS
 (SELECT M.NUMTRANSVENDA,
         M.NUMTRANSITEM  AS NUMTRANSITEM_TV7,
         M.CODPROD,
         M.CUSTOCONT     AS CUSTOCONT_TV7
    FROM PCMOV M
   INNER JOIN PCNFSAID S
      ON M.NUMTRANSVENDA = S.NUMTRANSVENDA
   WHERE S.CONDVENDA = 7)
SELECT M8.NUMTRANSITEM     AS NUMTRANSITEM_TV8,
       T7.CUSTOCONT_TV7
  FROM PCMOV M8
 INNER JOIN PCPEDC C
    ON M8.NUMTRANSVENDA = C.NUMTRANSVENDA
 INNER JOIN PCNFSAID S
    ON C.NUMPEDENTFUT = S.NUMPED
 INNER JOIN MOVT7 T7
    ON S.NUMTRANSVENDA = T7.NUMTRANSVENDA
   AND M8.CODPROD = T7.CODPROD
 WHERE C.DTCANCEL IS NULL
   AND M8.DTCANCEL IS NULL
   AND C.CONDVENDA = 8
;