*&---------------------------------------------------------------------*
*& Include          Z2603R0050_088_PAI
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
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

  CASE OK_CODE.
    WHEN 'SAVE'.
      " 저장 로직
      IF GO_ALV_GRID2 IS NOT INITIAL.
        " 화면의 입력 값을 인터널 테이블(GT_JOB)로 강제 업데이트 및 DATA_CHANGED 이벤트 발생
        CALL METHOD GO_ALV_GRID2->CHECK_CHANGED_DATA.
      ENDIF.

      IF GV_FLAG = ABAP_TRUE.
        " 팝업을 통한 확인
        PERFORM POPUP_TO_CHECK.

        IF GV_FLAG = 1.
          " 예를 클릭한 경우
          CLEAR : GV_ENTERED_PW.
          CALL SCREEN 0120 STARTING AT 10 10.

          IF GV_PW = GV_ENTERED_PW.
            " 120번 화면에서 올바른 비밀번호를 입력한 경우에만 수정된 부분만 가져와서 저장 로직 진행
            DESCRIBE TABLE GT_JOB LINES DATA(LV_MAX_SEQ).
            READ TABLE GT_JOB INTO GS_JOB INDEX LV_MAX_SEQ.
            MOVE-CORRESPONDING GS_JOB TO ZBCT0020.

            ZBCT0020-USNAM = SY-UNAME.
            ZBCT0020-REDAT = SY-DATUM.
            ZBCT0020-RETIM = SY-UZEIT.

            INSERT ZBCT0020 FROM ZBCT0020.

            IF SY-SUBRC = 0.
              " 저장 성공
              MESSAGE '조치사항이 성공적으로 저장되었습니다.' TYPE 'S'.
              CLEAR GV_FLAG.        " 다음을 위해 플래그 초기화
              LEAVE TO SCREEN 0.    " 저장 완료 후 팝업 화면 닫기 (메인 화면 0100으로 돌아감)

            ELSE.
              " 저장 실패
              MESSAGE '데이터 저장 중 오류가 발생했습니다.' TYPE 'E'.

            ENDIF.

          ELSE.
            " 120번 화면에서 취소 버튼을 누른 경우
            MESSAGE '작업이 취소되었습니다.' TYPE 'S' DISPLAY LIKE 'W'.
            RETURN.

          ENDIF.

        ELSE.
          " 아니요를 클릭한 경우
          MESSAGE '작업이 취소되었습니다.' TYPE 'S' DISPLAY LIKE 'W'.
          RETURN.

        ENDIF.

      ELSE.
        " 새롭게 입력된 값이 없는 경우
        MESSAGE '새롭게 입력된 조치사항이 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.

  IF GV_ENTERED_PW = GV_PW.
    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE '비밀번호가 불일치합니다.' TYPE 'S' DISPLAY LIKE 'E'.
    CLEAR : GV_ENTERED_PW.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0120  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0120 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
