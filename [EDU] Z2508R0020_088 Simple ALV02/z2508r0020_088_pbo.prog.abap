*&---------------------------------------------------------------------*
*& Include          Z2508R010_088_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.  " ALV가 최초 생성되는 경우
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FIELDCAT CHANGING GT_FCAT.
    PERFORM SET_EVENT_0100.
    PERFORM DISPLAY_ALV.

  ELSE.                      " ALV의 갱신이 필요한 경우
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
