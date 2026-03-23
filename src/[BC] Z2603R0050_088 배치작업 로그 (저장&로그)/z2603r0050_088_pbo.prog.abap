*&---------------------------------------------------------------------*
*& Include          Z2603R0050_088_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S0100'.

  CASE ABAP_ON.
    WHEN P_DIS.
      SET TITLEBAR 'T0100' WITH '조회'.
    WHEN P_SAV.
      SET TITLEBAR 'T0100' WITH '저장'.
  ENDCASE.
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
    PERFORM REFRESH_ALV USING GO_ALV_GRID GS_LAYO.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR : OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'S0110'.
  SET TITLEBAR 'T0110'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0110 OUTPUT.

  IF GO_CUSTOM IS INITIAL.

    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FIELDCAT.
    PERFORM SET_EVENT_0110.
    PERFORM DISPLAY_ALV.

  ELSE.
    PERFORM REFRESH_ALV USING GO_ALV_GRID2 GS_LAYO2.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0120 OUTPUT.
  SET PF-STATUS 'S0120'.
  SET TITLEBAR 'T0120'.
ENDMODULE.
