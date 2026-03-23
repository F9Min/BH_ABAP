*&---------------------------------------------------------------------*
*& Report ZS4H088R01
*&---------------------------------------------------------------------*
*& 사용자 관리
*&---------------------------------------------------------------------*
REPORT ZS4H088R01.

INCLUDE ZS4H088R01_TOP.
INCLUDE ZS4H088R01_SCR.
INCLUDE ZS4H088R01_CLS.
INCLUDE ZS4H088R01_F01.
INCLUDE ZS4H088R01_PBO.
INCLUDE ZS4H088R01_PAI.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN USING GV_COMP.
  PERFORM CLEAR_SELECT_OPTIONS.

AT SELECTION-SCREEN.
  PERFORM CHECK_NAME.

START-OF-SELECTION.
  PERFORM SELECT_DATA USING GV_DIALOG
                            GS_DISPLAY.
  PERFORM DISPLAY_DATA.
