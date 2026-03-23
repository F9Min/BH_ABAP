*&---------------------------------------------------------------------*
*& Include          Z2512R0010_088_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.

  SELECT-OPTIONS : S_BUKRS FOR BKPF-BUKRS NO INTERVALS NO-EXTENSION,
                   S_GJAHR FOR BKPF-GJAHR NO INTERVALS NO-EXTENSION,
                   S_MONAT FOR BKPF-MONAT NO INTERVALS NO-EXTENSION,
                   S_BELNR FOR BKPF-BELNR NO INTERVALS NO-EXTENSION,
                   S_USNAM FOR BKPF-USNAM NO INTERVALS NO-EXTENSION.

SELECTION-SCREEN END OF BLOCK B1.
