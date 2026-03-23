*&---------------------------------------------------------------------*
*& Include          ZS4H088R01_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  DATA : LT_UCOMM TYPE TABLE OF SY-UCOMM.

  CLEAR : LT_UCOMM.

  IF PA_CHECK EQ ABAP_ON.
    LT_UCOMM[] = VALUE #( BASE LT_UCOMM[] ( 'CREATE' ) ).
    LT_UCOMM[] = VALUE #( BASE LT_UCOMM[] ( 'MODIFY' ) ).
  ELSEIF PA_CRT EQ ABAP_ON.
    LT_UCOMM[] = VALUE #( BASE LT_UCOMM[] ( 'MODIFY' ) ).
  ELSEIF PA_MOD EQ ABAP_ON.
    LT_UCOMM[] = VALUE #( BASE LT_UCOMM[] ( 'CREATE' ) ).
  ENDIF.

  SET PF-STATUS 'S0100' EXCLUDING LT_UCOMM.

  CASE ABAP_ON.
    WHEN PA_CHECK.
      SET TITLEBAR 'T0100'.
    WHEN PA_CRT.
      SET TITLEBAR 'T0100_CRT'.
    WHEN PA_MOD.
      SET TITLEBAR 'T0100_MOD'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.

  CLEAR : OK_CODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.

    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYOUT.
    PERFORM SET_FCAT USING GV_DIALOG.
    PERFORM SET_EVENT_HANDELR.
    PERFORM DISPLAY_ALV.

  ELSE.

    PERFORM REFRESH_ALV USING GV_DIALOG.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  IF GV_COMP EQ 'X'.
    SET PF-STATUS 'S0110' EXCLUDING 'CONT'.
  ELSE.
    SET PF-STATUS 'S0110'.
  ENDIF.
  SET TITLEBAR 'T0110'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INPUT_CONTROL OUTPUT
*&---------------------------------------------------------------------*
MODULE INPUT_CONTROL OUTPUT.

  CASE ABAP_ON.
    WHEN PA_MOD.
      LOOP AT SCREEN.
        IF SCREEN-NAME = 'GV_ID' OR SCREEN-NAME = 'GV_NAME'.
          SCREEN-INPUT = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
      IF GV_COMP EQ 'X'.

        SELECT SINGLE ID
          FROM ZS4H088T04
          INTO GV_ID
          WHERE NAME = GV_NAME
            AND BDAY = GV_BDAY
            AND MAIL = GV_MAIL.

        LOOP AT SCREEN.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF SCREEN-NAME = 'GV_ID'.
            SCREEN-INPUT = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0120 OUTPUT.
  SET PF-STATUS 'S0120'.
  IF GV_DIALOG EQ 'C'.
    SET TITLEBAR 'T0120'.
  ELSEIF GV_DIALOG EQ 'T'.
    SET TITLEBAR 'T0120_T'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_0120 OUTPUT.

  IF GO_DIALOG_CUSTOM IS INITIAL.

    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYOUT.
    PERFORM SET_FCAT USING GV_DIALOG.
    PERFORM DISPLAY_ALV.

  ELSE.

    PERFORM REFRESH_ALV USING GV_DIALOG.

  ENDIF.

ENDMODULE.
