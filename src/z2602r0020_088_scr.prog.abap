*&---------------------------------------------------------------------*
*& Include          Z2602R0020_088_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
  PARAMETERS : P_YYYY TYPE CHAR4.
  SELECT-OPTIONS : S_ERNAM FOR VBAK-ERNAM.
SELECTION-SCREEN END OF BLOCK B1.
