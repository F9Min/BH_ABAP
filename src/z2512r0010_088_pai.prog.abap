*&---------------------------------------------------------------------*
*& Include          Z2512R0010_088_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  CASE OK_CODE.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'DISPLAY'.
      PERFORM DISPLAY_DOC.
    WHEN 'ATTACH'.

      DATA : LT_ROWS TYPE LVC_T_ROW,
             LS_ROW  LIKE LINE OF LT_ROWS.

      CALL METHOD GO_ALV_GRID->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROWS.                 " Indexes of Selected Rows

      DESCRIBE TABLE LT_ROWS LINES DATA(LV_ROWS_NUM).

      IF LV_ROWS_NUM NE 1.
        MESSAGE S001 DISPLAY LIKE 'E'.
      ELSE.

        READ TABLE LT_ROWS INTO LS_ROW INDEX 1.

        IF LS_ROW-ROWTYPE IS NOT INITIAL.
          MESSAGE S002 DISPLAY LIKE 'E'.
        ELSE.

          READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) INDEX LS_ROW-INDEX.

          PERFORM ATTACH_DOC USING LS_DISPLAY.

        ENDIF.

      ENDIF.
  ENDCASE.

ENDMODULE.
