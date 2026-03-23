*&---------------------------------------------------------------------*
*& Include          ZS4H088R01_CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.
    METHODS:
      ON_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW E_COLUMN.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD : ON_DOUBLE_CLICK.
    CASE E_COLUMN-FIELDNAME.
      WHEN 'CURRENT'.
        " 선택한 행에 대한 INDEX 정보 가져오기
        READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX E_ROW-INDEX.
        GV_DIALOG = 'C'.
        PERFORM SELECT_DATA USING GV_DIALOG
                                  GS_DISPLAY.

        IF GT_LIST IS INITIAL.
          MESSAGE TEXT-E06 TYPE 'I' DISPLAY LIKE 'E'. " 표시할 데이터가 존재하지 않습니다.
          RETURN.
        ENDIF.

        CALL SCREEN 0120 STARTING AT 5 1.
      WHEN 'TOTAL'.
        " 선택한 행에 대한 INDEX 정보 가져오기
        READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX E_ROW-INDEX.
        GV_DIALOG = 'T'.
        PERFORM SELECT_DATA USING GV_DIALOG
                                  GS_DISPLAY.

        IF GT_LIST IS INITIAL.
          MESSAGE TEXT-E06 TYPE 'I' DISPLAY LIKE 'E'. " 표시할 데이터가 존재하지 않습니다.
          RETURN.
        ENDIF.

        CALL SCREEN 0120 STARTING AT 5 1.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
