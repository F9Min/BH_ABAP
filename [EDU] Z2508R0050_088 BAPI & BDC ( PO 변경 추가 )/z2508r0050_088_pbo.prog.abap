*&---------------------------------------------------------------------*
*& Include          Z2508R0040_088_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  IF GV_EXCLUDE EQ ABAP_ON.
    SET PF-STATUS 'S0100' EXCLUDING 'EXEC'.
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
    PERFORM SET_EVENT.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT.
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
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'S0200'.
  SET TITLEBAR 'T0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0210 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0210 OUTPUT.
  SET PF-STATUS 'S0210'.
  SET TITLEBAR 'T0210'.
ENDMODULE.
