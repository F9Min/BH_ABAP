************************************************************************
* Program ID   : Z2603R0050_088
* Title        : [BC] 배치작업 로그 (저장&로그)
* Create Date  : 2026-03-19
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        |2026-03-19     |조성민    | inital Coding
************************************************************************
REPORT Z2603R0050_088.

INCLUDE Z2603R0050_088_TOP.
INCLUDE Z2603R0050_088_CLS.
INCLUDE Z2603R0050_088_SCR.

INCLUDE Z2603R0050_088_F01.
INCLUDE Z2603R0050_088_PBO.
INCLUDE Z2603R0050_088_PAI.

INITIALIZATION.
  PERFORM SET_SELECTION_SCREEN.

  GV_PW = 'pass123'.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELECITON_SCREEN.

START-OF-SELECTION.
  CASE SY-BATCH.
    WHEN ABAP_ON.
**********************************************************************
* 배치 작업 진행 시 팝업 없이 바로 진행
**********************************************************************
      PERFORM GET_DATA_TO_SAVE.

    WHEN SPACE.

      CASE ABAP_ON.
        WHEN P_SAV.
**********************************************************************
* 저장
**********************************************************************
          PERFORM POPUP_TO_CHECK.
          IF GV_FLAG = '1'.
            " 확인 팝업에서 예 클릭 시
            PERFORM GET_DATA_TO_SAVE.

          ELSE.
            " 확인 팝업에서 아니요 클릭 시
            MESSAGE '작업이 취소되었습니다.' TYPE 'S' DISPLAY LIKE 'W'.
            STOP.
          ENDIF.

        WHEN P_DIS.
**********************************************************************
* 조회
**********************************************************************
          PERFORM GET_DATA_TO_DISPLAY.

          IF GT_LIST IS INITIAL.
            " 조회할 데이터가 없는 경우
            MESSAGE '조회할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
            RETURN.

          ELSE.
            CALL SCREEN 0100.
          ENDIF.

      ENDCASE.

  ENDCASE.
