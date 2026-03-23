*&---------------------------------------------------------------------*
*& Include          Z2508R030_088_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.

  PARAMETERS : P_BUKRS TYPE T001-BUKRS OBLIGATORY DEFAULT 4000,  " COMPANY CODE
               P_VBELN TYPE VBAK-VBELN OBLIGATORY.               " SALES ORDER

  SELECTION-SCREEN SKIP 1.

  PARAMETERS : P_PDF AS CHECKBOX DEFAULT ABAP_ON.

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN : FUNCTION KEY 1.
