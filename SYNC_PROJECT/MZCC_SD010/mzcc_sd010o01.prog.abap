*&---------------------------------------------------------------------*
*& Include          MZCC_SD010O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  DATA : LT_UCOMM TYPE TABLE OF SY-UCOMM.

  CLEAR : LT_UCOMM[].
  IF GV_TABTYPE EQ GC_PLAN.
    LT_UCOMM[] = VALUE #( ( 'CRET_ONE' ) ( 'CRET_MULTI' ) ).
  ENDIF.

  SET PF-STATUS 'S0100' EXCLUDING LT_UCOMM.
  SET TITLEBAR 'T0100' WITH GV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0110 OUTPUT.

  IF GO_CUSTOM1 IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT USING SY-DYNNR.
    PERFORM SET_ALV_EVENT.
    PERFORM DISPLAY_DATA.
  ELSE.
    CALL METHOD GO_ALV_GRID1->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
      EXCEPTIONS
        FINISHED  = 1                " Display was Ended (by Export)
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0120 OUTPUT.

  IF GO_CUSTOM2 IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT USING SY-DYNNR.
    PERFORM SET_ALV_EVENT.
    PERFORM DISPLAY_DATA2.
  ELSE.
    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
      EXCEPTIONS
        FINISHED  = 1                " Display was Ended (by Export)
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN_0120 OUTPUT.

  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'GV_COLL02'.
        IF GV_HIDE02 IS NOT INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN 'GV_EXPAND02'.
        IF GV_HIDE02 IS INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'S0200'.
  SET TITLEBAR 'T0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0200 OUTPUT.

  IF GO_CUSTOM3 IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT USING SY-DYNNR.
    PERFORM SET_ALV_EVENT.
    PERFORM DISPLAY_DATA.
  ELSE.
    CALL METHOD GO_ALV_GRID3->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
      EXCEPTIONS
        FINISHED  = 1                " Display was Ended (by Export)
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
      EXCEPTIONS
        FINISHED  = 1                " Display was Ended (by Export)
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0210 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0210 OUTPUT.
  SET PF-STATUS 'S0210'.
  SET TITLEBAR 'T0210'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_INIT_0210 OUTPUT
*&---------------------------------------------------------------------*
MODULE SET_INIT_0210 OUTPUT.

  GS_INPUT_SINGLE-PLAN_YEAR = SY-DATUM+0(4).
  GS_INPUT_SINGLE-MEINS = 'EA'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS 'S0300'.
  SET TITLEBAR 'T0300' WITH GS_DISPLAY3-VKBUR GS_DISPLAY3-MATNR.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0300 OUTPUT.

  CALL FUNCTION 'GFW_PRES_SHOW'
    EXPORTING
      CONTAINER         = 'CCON5'    "A screen with an empty container must be defined
      PRESENTATION_TYPE = GFW_PRESTYPE_LINES
*     PRESENTATION_TYPE = GFW_PRESTYPE_TIME_AXIS
*     PRESENTATION_TYPE = GFW_PRESTYPE_AREA
*     PRESENTATION_TYPE = GFW_PRESTYPE_HORIZONTAL_BARS
    TABLES
      VALUES            = Y_VALUES
      COLUMN_TEXTS      = X_TEXTS
    EXCEPTIONS
      ERROR_OCCURRED    = 1                " A GFW error occurred
      OTHERS            = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0310 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0310 OUTPUT.
  SET PF-STATUS 'S0310'.
  SET TITLEBAR 'T0310' WITH GS_MAT_INFO-MATNR.
ENDMODULE.
