*&---------------------------------------------------------------------*
*& Include          ZRFC0010_088_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.

  SELECT-OPTIONS : S_RFQDT FOR ZMMT0520_088-RFQDT NO-EXTENSION,
                   S_RFQNO FOR ZMMT0520_088-RFQNO NO-EXTENSION NO INTERVALS.

  SELECTION-SCREEN SKIP.

  PARAMETERS : P_NSENT RADIOBUTTON GROUP R1,
               P_SENT  RADIOBUTTON GROUP R1.

SELECTION-SCREEN END OF BLOCK B1.
