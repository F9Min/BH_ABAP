*&---------------------------------------------------------------------*
*& Report ZS4H088R02
*&---------------------------------------------------------------------*
*& 도서 대여 현황
*&---------------------------------------------------------------------*
REPORT ZS4H088R02.

INCLUDE ZS4H088R02_TOP.
INCLUDE ZS4H088R02_SCR.
INCLUDE ZS4H088R02_CLS.
INCLUDE ZS4H088R02_F01.
INCLUDE ZS4H088R02_PBO.
INCLUDE ZS4H088R02_PAI.

AT SELECTION-SCREEN.
  PERFORM CHECK_NAME.

START-OF-SELECTION.
  PERFORM SELECT_DATA.
*  PERFORM MODIFY_DATA.
  PERFORM DISPLAY_DATA.
