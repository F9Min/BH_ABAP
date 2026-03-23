*&---------------------------------------------------------------------*
*& Include          ZRFC0010_088_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA: LT_EXCLUDE TYPE UI_FUNCTIONS.

  IF P_SENT EQ ABAP_ON.

    APPEND 'SAVE' TO LT_EXCLUDE.
    APPEND 'SEND' TO LT_EXCLUDE.
    APPEND 'ADD'  TO LT_EXCLUDE.
    APPEND 'DELT' TO LT_EXCLUDE.

    SET PF-STATUS 'S0100' EXCLUDING LT_EXCLUDE.
  ELSE.

    SET PF-STATUS 'S0100'.
  ENDIF.

  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.

    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FIELDCAT.
    PERFORM SET_EVENT_0100.
    PERFORM DISPLAY_ALV.

  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR : OK_CODE.
ENDMODULE.
