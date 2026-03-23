*&---------------------------------------------------------------------*
*& Include          ZS4H088R01_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

  DATA : LV_ID      TYPE ZS4H088T04-ID,
         LV_RESULT,
         LV_ANSWER,
         LV_MESSAGE TYPE STRING.

  CASE OK_CODE.
    WHEN 'CONT'.
      IF PA_MOD EQ ABAP_ON.
        CALL FUNCTION 'ZFM_USER_MANAGE'
          EXPORTING
            IV_NAME    = GV_NAME          " 사용자 명
            IV_ID      = GV_ID            " ID
            IV_BDAY    = GV_BDAY          " 생년월일
            IV_MAIL    = GV_MAIL          " 전자메일
            IV_MODE    = 'M'              " 구분자
          IMPORTING
            EV_ID      = LV_ID            " 사용자 코드 (ID)
            EV_RESULT  = LV_RESULT        " 성공: S, 실패: F
            EV_MESSAGE = LV_MESSAGE.      " ABAP System Field: Return Code of ABAP Statements

        IF LV_RESULT EQ 'F'.
          MESSAGE LV_MESSAGE TYPE 'I' DISPLAY LIKE 'E'.
*          RETURN.
        ELSEIF LV_RESULT EQ 'S'.
          PERFORM UPDATE_DISPLAY USING LV_ID
                                 CHANGING GT_DISPLAY.
          PERFORM REFRESH_ALV USING GV_DIALOG.
          MESSAGE LV_MESSAGE TYPE 'S'.
          LEAVE TO SCREEN 0.
        ENDIF.

      ELSEIF PA_CRT EQ ABAP_ON.
        CALL FUNCTION 'ZFM_USER_MANAGE'
          EXPORTING
            IV_NAME    = GV_NAME          " 사용자 명
            IV_BDAY    = GV_BDAY          " 생년월일
            IV_MAIL    = GV_MAIL          " 전자메일
            IV_MODE    = 'I'              " 구분자
          IMPORTING
            EV_ID      = LV_ID            " 사용자 코드 (ID)
            EV_RESULT  = LV_RESULT        " 성공: S, 실패: F
            EV_MESSAGE = LV_MESSAGE.      " ABAP System Field: Return Code of ABAP Statements

        IF LV_RESULT EQ 'F'.
          MESSAGE LV_MESSAGE TYPE 'I' DISPLAY LIKE 'E'.
          RETURN.
        ELSEIF LV_RESULT EQ 'S'.
          GV_COMP = 'X'.
          PERFORM MODIFY_SCREEN USING GV_COMP.
          PERFORM UPDATE_DISPLAY USING LV_ID
                                 CHANGING GT_DISPLAY.
          PERFORM REFRESH_ALV USING GV_DIALOG.
          MESSAGE LV_MESSAGE TYPE 'S'.
*          LEAVE TO SCREEN 0.
        ENDIF.

      ENDIF.

    WHEN 'CANC'.

      IF GV_COMP EQ 'X'.
        CLEAR : GV_COMP.
        LEAVE TO SCREEN 0.
      ENDIF.

      IF GV_ID IS NOT INITIAL OR GV_NAME IS NOT INITIAL OR GV_BDAY IS NOT INITIAL OR GV_MAIL IS NOT INITIAL.
        IF GS_DISPLAY-NAME NE GV_NAME OR GS_DISPLAY-BDAY NE GV_BDAY OR GS_DISPLAY-MAIL NE GV_MAIL.
          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              TEXT_QUESTION         = '입력된 정보가 존재합니다. 정말 삭제하시겠습니까?'
              TEXT_BUTTON_1         = '예'
              TEXT_BUTTON_2         = '아니오'
              DISPLAY_CANCEL_BUTTON = 'X'
            IMPORTING
              ANSWER                = LV_ANSWER.

          IF LV_ANSWER = '1'.
            CASE ABAP_ON.
              WHEN PA_CRT.
                MESSAGE '사용자 등록이 취소되었습니다.' TYPE 'S' DISPLAY LIKE 'W'.
              WHEN PA_MOD.
                MESSAGE '사용자 정보 수정이 취소되었습니다.' TYPE 'S' DISPLAY LIKE 'W'.
            ENDCASE.

            LEAVE TO SCREEN 0.
          ENDIF.
        ELSE.
          MESSAGE '입력/변경된 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        MESSAGE '입력/변경된 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CREATE'.
      CLEAR : GV_ID, GV_NAME, GV_BDAY, GV_MAIL.

      CALL SCREEN 0110 STARTING AT 5 5.

      PERFORM REFRESH_ALV USING GV_DIALOG.
*
*      CLEAR : GT_DATA, GT_DISPLAY.
*      PERFORM SELECT_DATA.
*      PERFORM MODIFY_DATA.
    WHEN 'MODIFY'.
      DATA : LT_ROW  TYPE LVC_T_ROW.

      CLEAR : GV_ID, GV_NAME, GV_BDAY, GV_MAIL.

      CALL METHOD GO_ALV_GRID->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROW.           " Indexes of Selected Rows

      DESCRIBE TABLE LT_ROW LINES DATA(LV_LINE).

      IF LT_ROW IS INITIAL.
        " 행 선택이 이루어지지 않은 경우
        " 변경할 행을 선택해주세요.
        MESSAGE TEXT-E05 TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      IF LV_LINE NE 1.
        " 사용자 정보 변경은 한 번에 하나의 항목만 수정할 수 있습니다.
        MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      READ TABLE LT_ROW INTO DATA(LS_ROW) INDEX 1.

      IF LS_ROW-ROWTYPE IS NOT INITIAL.
        " 일반 행을 선택해주세요.
        MESSAGE TEXT-E02 TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_ROW-INDEX.
      GV_ID = GS_DISPLAY-ID.
      GV_NAME = GS_DISPLAY-NAME.
      GV_BDAY = GS_DISPLAY-BDAY.
      GV_MAIL = GS_DISPLAY-MAIL.

      CALL SCREEN 0110 STARTING AT 5 5.

*      CLEAR : GT_DATA, GT_DISPLAY.
*      PERFORM SELECT_DATA.
*      PERFORM MODIFY_DATA.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      CLEAR : GV_DIALOG.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
