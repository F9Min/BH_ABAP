*&---------------------------------------------------------------------*
*& Include          MZCC_SD010CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS :
      ON_TOOLBAR FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT,

      ON_USER_COMMAND FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM SENDER,

      ON_DATA_CHANGED FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED,

      ON_TOP_OF_PAGE FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
        IMPORTING E_DYNDOC_ID,

      ON_HOT_SPOT FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID E_COLUMN_ID.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD ON_TOOLBAR.
    DATA : LS_TOOLBAR LIKE LINE OF E_OBJECT->MT_TOOLBAR.

    CLEAR : LS_TOOLBAR.
    LS_TOOLBAR-BUTN_TYPE = 3.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    CLEAR : LS_TOOLBAR.
    LS_TOOLBAR-FUNCTION = 'EDIT'.
    LS_TOOLBAR-ICON = ICON_EDIT_FILE.
    LS_TOOLBAR-TEXT = '편집하기'.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    IF GV_EDIT = 'X'.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'APPEND'.
      LS_TOOLBAR-ICON = ICON_INSERT_ROW.
      LS_TOOLBAR-TEXT = '행추가'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'DELETE'.
      LS_TOOLBAR-ICON = ICON_DELETE_ROW.
      LS_TOOLBAR-TEXT = '행제거'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    ENDIF.

    CLEAR : LS_TOOLBAR.
    LS_TOOLBAR-BUTN_TYPE = 3.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    IF GV_KPI IS INITIAL AND GV_PAI IS INITIAL.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'APPLY_KPI'.
      LS_TOOLBAR-ICON = ICON_CALCULATION.
      LS_TOOLBAR-TEXT = 'KPI 적용'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'APPLY_PAI'.
      LS_TOOLBAR-ICON = ICON_CALCULATION.
      LS_TOOLBAR-TEXT = 'PAI 적용'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    ENDIF.

    IF GV_KPI = 'X'.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'SHOW'.
      LS_TOOLBAR-ICON = ICON_GRAPHICS.
      LS_TOOLBAR-TEXT = 'KPI 확인'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'GRAPH'.
      LS_TOOLBAR-ICON = ICON_PERIOD.
      LS_TOOLBAR-TEXT = 'KPI 그래프'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'INIT'.
      LS_TOOLBAR-ICON = ICON_DELETE_TEMPLATE.
      LS_TOOLBAR-TEXT = '색상 초기화'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    ELSEIF GV_PAI = 'X'.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'SHOW'.
      LS_TOOLBAR-ICON = ICON_GRAPHICS.
      LS_TOOLBAR-TEXT = 'PAI 확인'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'GRAPH'.
      LS_TOOLBAR-ICON = ICON_PERIOD.
      LS_TOOLBAR-TEXT = 'PAI 그래프'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR : LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'INIT'.
      LS_TOOLBAR-ICON = ICON_DELETE_TEMPLATE.
      LS_TOOLBAR-TEXT = '색상 초기화'.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    ENDIF.

  ENDMETHOD.

  METHOD ON_USER_COMMAND.

    CASE SENDER.
      WHEN GO_ALV_GRID2.
        CASE E_UCOMM.
          WHEN 'EDIT'.
            " 버튼을 누를 경우 ALV에 입력가능/불가능 상태를 전환하도록 한다.
            DATA(LV_INPUT) = GO_ALV_GRID2->IS_READY_FOR_INPUT( ).

            IF LV_INPUT EQ 0.
              LV_INPUT = 1.
              GV_EDIT = 'X'.
            ELSE.
              LV_INPUT = 0.
              GV_EDIT = SPACE.
            ENDIF.

            CALL METHOD GO_ALV_GRID2->SET_READY_FOR_INPUT
              EXPORTING
                I_READY_FOR_INPUT = LV_INPUT.                " Ready for Input Status

          WHEN 'APPEND'.
            PERFORM ADD_NEW_ROW.

          WHEN 'DELETE'.
            PERFORM DELETE_SELECTED_ROW.

        ENDCASE.
      WHEN GO_ALV_GRID4.
        CASE E_UCOMM.
          WHEN 'EDIT'.
            " 버튼을 누를 경우 ALV에 입력가능/불가능 상태를 전환하도록 한다.
            LV_INPUT = GO_ALV_GRID4->IS_READY_FOR_INPUT( ).

            IF LV_INPUT EQ 0.
              LV_INPUT = 1.
              GV_EDIT = 'X'.
            ELSE.
              LV_INPUT = 0.
              GV_EDIT = SPACE.
            ENDIF.

            CALL METHOD GO_ALV_GRID4->SET_READY_FOR_INPUT
              EXPORTING
                I_READY_FOR_INPUT = LV_INPUT.                " Ready for Input Status

          WHEN 'APPEND'.
            PERFORM ADD_NEW_ROW.

          WHEN 'DELETE'.
            PERFORM DELETE_SELECTED_ROW.

          WHEN 'APPLY_KPI'.
            PERFORM CALCULATE_KPI CHANGING GT_DISPLAY3.
            GV_KPI = 'X'.

            CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
              EXPORTING
                IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )                 " With Stable Rows/Columns
              EXCEPTIONS
                FINISHED  = 1                " Display was Ended (by Export)
                OTHERS    = 2.

            IF SY-SUBRC <> 0.
              CASE SY-SUBRC.
                WHEN 1.
                  MESSAGE I084 DISPLAY LIKE 'E'. " Display was Ended (by Export)
                WHEN 2.
                  MESSAGE I075 DISPLAY LIKE 'E'. " others_error
              ENDCASE.
            ENDIF.

          WHEN 'APPLY_PAI'.
            PERFORM CALCULATE_PAI CHANGING GT_DISPLAY3.
            GV_PAI = 'X'.

            CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
              EXPORTING
                IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )                 " With Stable Rows/Columns
              EXCEPTIONS
                FINISHED  = 1                " Display was Ended (by Export)
                OTHERS    = 2.

            IF SY-SUBRC <> 0.
              CASE SY-SUBRC.
                WHEN 1.
                  MESSAGE I084 DISPLAY LIKE 'E'. " Display was Ended (by Export)
                WHEN 2.
                  MESSAGE I075 DISPLAY LIKE 'E'. " others_error
              ENDCASE.
            ENDIF.

          WHEN 'INIT'.

            PERFORM INIT_DISPLAY CHANGING GT_DISPLAY3.

            CLEAR : GT_KPI, GT_PAI.

            GV_KPI = SPACE.
            GV_PAI = SPACE.

            CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
              EXPORTING
                IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )     " With Stable Rows/Columns
              EXCEPTIONS
                FINISHED  = 1                                           " Display was Ended (by Export)
                OTHERS    = 2.

            IF SY-SUBRC <> 0.
              CASE SY-SUBRC.
                WHEN 1.
                  MESSAGE I084 DISPLAY LIKE 'E'.                        " Display was Ended (by Export)
                WHEN 2.
                  MESSAGE I075 DISPLAY LIKE 'E'.                        " others_error
              ENDCASE.
            ENDIF.

          WHEN 'SHOW'.
            PERFORM SHOW.

          WHEN 'GRAPH'.
            PERFORM SHOW_GRAPH.

        ENDCASE.
    ENDCASE.
  ENDMETHOD.

  METHOD ON_DATA_CHANGED.

    PERFORM ALV_HANDLER_DATA_CHANGED USING ER_DATA_CHANGED.

  ENDMETHOD.
  METHOD ON_TOP_OF_PAGE.

    PERFORM ALV_HANDLER_TOP_OF_PAGE.

  ENDMETHOD.

  METHOD ON_HOT_SPOT.

    CASE E_COLUMN_ID.
      WHEN 'MATNR'.
        IF E_ROW_ID-ROWTYPE EQ 0.
          PERFORM SHOW_MAT_INFO USING E_ROW_ID.
        ELSE.
          MESSAGE I108 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
