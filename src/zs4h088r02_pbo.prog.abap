*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR : OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA : LT_UCOMM TYPE TABLE OF SY-UCOMM.

  CLEAR : LT_UCOMM[].
  IF PA_DEL EQ ABAP_ON.
    LT_UCOMM[] = VALUE #( ( 'RENT' ) ).
  ENDIF.

  SET PF-STATUS 'S0100' EXCLUDING LT_UCOMM.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT     USING GV_DIALOG.
    PERFORM SET_LAYOUT        USING GV_DIALOG.
    PERFORM SET_FIELD_CATALOG USING GV_DIALOG.
    PERFORM SET_EVENT.
    PERFORM DISPLAY_ALV.
  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'S0110'.
  SET TITLEBAR 'T0110'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0120 OUTPUT.
  SET PF-STATUS 'S0120'.
  SET TITLEBAR 'T0120'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0120 OUTPUT.

  IF GO_CUSTOM2 IS INITIAL.
    PERFORM CREATE_OBJECT     USING GV_DIALOG.
    PERFORM SET_LAYOUT        USING GV_DIALOG.
    PERFORM SET_FIELD_CATALOG USING GV_DIALOG.
    PERFORM SET_EVENT.
    PERFORM DISPLAY_ALV.
  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
