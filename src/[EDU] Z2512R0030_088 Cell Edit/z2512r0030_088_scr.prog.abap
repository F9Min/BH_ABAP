*&---------------------------------------------------------------------*
*& Include          Z2508R010_088_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.

  SELECT-OPTIONS : S_EKORG FOR EKKO-EKORG NO INTERVALS NO-EXTENSION OBLIGATORY,  " 구매 조직
                   S_EKGRP FOR EKKO-EKGRP NO INTERVALS NO-EXTENSION,             " 구매 그룹
                   S_LIFNR FOR EKKO-LIFNR NO INTERVALS,                          " 공급업체
                   S_BEDAT FOR EKKO-BEDAT NO-EXTENSION OBLIGATORY.               " 생성일

SELECTION-SCREEN END OF BLOCK B1.
