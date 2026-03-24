*&---------------------------------------------------------------------*
*& Include          MZCC_SD030I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0110  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0110 INPUT.

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
      " 탭과 관련된 Function Code가 OK_CODE에 들어올 경우
      " Next Screen에 내가 지금 누른 버튼(탭)이 눌리도록 activetab으로 설정 후
      " 이 activetab의 값에 의해 보여질 화면번호도 결정된다.
    WHEN 'FC1'.
      MY_TAB_STRIP-ACTIVETAB = OK_CODE.
    WHEN 'FC2'.
      " 두번째 탭으로 진행되기 이전에 기본정보가 모두 입력되었는지 점검한다.
      " 상단의 기본정보를 입력하면 110번 화면의 Input Field의 Input 값을 변경하기 위해 사용하는 플래그를 기준으로 기본정보가 입력되었는지 검사한다.
      IF GV_CLOSE NE 'X'.
        " 기본정보를 입력해주세요
        MESSAGE S034(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF ZCC_VBAK-VKBUR IS INITIAL.
        "담당 영업장을 입력해주세요.
        MESSAGE S051(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF ZCC_VBAK-VKBUR IS NOT INITIAL.

        " 영업장 정보 SELECT
        SELECT FROM DD07L AS A
         LEFT OUTER JOIN
              DD07T AS B ON A~DOMNAME   EQ B~DOMNAME
                        AND A~AS4LOCAL  EQ B~AS4LOCAL
                        AND A~VALPOS    EQ B~VALPOS
                        AND A~AS4VERS   EQ B~AS4VERS
         FIELDS A~DOMVALUE_L, B~DDTEXT
         WHERE A~DOMNAME    EQ 'ZCC_VKBUR'
           AND B~DDLANGUAGE EQ @SY-LANGU
           AND A~AS4LOCAL   EQ 'A'                " Active인 Fixed Value만 조회
           AND A~DOMVALUE_L EQ @ZCC_VBAK-VKBUR    " 입력한 영업장을 기준으로 조회
          INTO TABLE @DATA(LS_VKBUR).

        " 영업장 정보가 없을 경우
        IF SY-SUBRC NE 0.
          MESSAGE S113(ZCC_MSG) DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

      ENDIF.

      " EMAIL에서 @가 있는지 확인
      FIND '@' IN ZCC_VBAK-EMAIL.

      IF SY-SUBRC NE 0.
        " 찾지 못한 경우
        " 올바른 형식의 EMAIL을 입력해주세요.
        MESSAGE S109(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      MY_TAB_STRIP-ACTIVETAB = OK_CODE.
    WHEN 'FC3'.
      " 세번째 탭으로 진행되기 이전에 기본정보와 아이템 정보가 모두 입력되었는지, 최소주문수량을 맞추었는지 검사한다.
      IF GV_CLOSE NE 'X'.
        " 기본정보를 입력해주세요
        MESSAGE S034(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF ZCC_VBAK-VKBUR IS INITIAL.
        "담당 영업장을 입력해주세요.
        MESSAGE S051(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF GT_DISPLAY IS INITIAL.
        " 세부 주문정보를 입력해주세요.
        MESSAGE S035(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        " 최소주문수량을 맞추었는지 검사
        PERFORM CHECK_DATA.
      ENDIF.
      MY_TAB_STRIP-ACTIVETAB = OK_CODE.

    WHEN 'SAVE'.
      DATA: LV_ANSWER TYPE C.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = '저장 확인'
          TEXT_QUESTION         = '저장하시겠습니까?'
          TEXT_BUTTON_1         = '예'(001)
          TEXT_BUTTON_2         = '아니오'(002)
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = ''
        IMPORTING
          ANSWER                = LV_ANSWER.

      IF LV_ANSWER = '1'.
        " 예 선택
        IF ZCC_VBAK-VBELN IS INITIAL.
          " 주문번호가 존재하지 않는 경우 : 아직 저장되지 않았음을 의미함
          PERFORM FINAL_SAVE.
        ELSEIF ZCC_VBAK-VBELN IS NOT INITIAL.
          " 주문번호가 존재하는 경우 : 이미 저장되었음을 의미함
          MESSAGE S108(ZCC_MSG) DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        " 아니오 선택
        MESSAGE '저장하지 않았습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'QUOT'.
      PERFORM CALL_QUOT_DIALOG.
  ENDCASE.

ENDMODULE.
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
*&      Module  CHECK_BASIC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BASIC INPUT.

* 입력된 정보를 기반으로 고객 정보를 가져온다.
  SELECT SINGLE KUNNR
                NAME1
                STRAS
                LAND1
                WERKS
                BANKN
                WAERS
                STCD1
                EMAIL
                NAME2
                TELF
                ZTERM
                ZLSPR
                LOEVM
            FROM ZCC_KNA1
            INTO CORRESPONDING FIELDS OF ZCC_KNA1
            WHERE KUNNR = ZCC_KNA1-KUNNR
               OR NAME1 = ZCC_KNA1-NAME1.

  IF SY-SUBRC NE 0.
    " 고객번호 혹은 고객명이 유효하지 않은 경우
    " [ 고객번호/고객명 ] 은/는 유효하지 않는 고객번호입니다.
    MESSAGE S033(ZCC_MSG) WITH ZCC_KNA1-KUNNR '고객번호' DISPLAY LIKE 'E'.
    CLEAR : ZCC_KNA1, ZCC_VBAK.
    EXIT.
  ENDIF.

  IF ZCC_VBAK-AUART NE 'NO' AND ZCC_VBAK-AUART NE 'QT'.
    " 주문유형이 미리 설정된 주문유형에 부합하지 않은 경우
    " [ 주문유형 ] 은/는 유효하지 않는 주문유형입니다.
    MESSAGE S033(ZCC_MSG) WITH ZCC_VBAK-AUART '주문유형' DISPLAY LIKE 'E'.
    CLEAR : ZCC_KNA1, ZCC_VBAK.
    EXIT.
  ENDIF.

  IF ZCC_VBAK-VDATU <= SY-DATUM.
    " 요청날짜가 유효하지 않은 경우
    " [ 요청날짜 ] 은/는 유효하지 않는 요청날짜입니다.
    MESSAGE S033(ZCC_MSG) WITH ZCC_VBAK-VDATU '요청날짜' DISPLAY LIKE 'E'.
    CLEAR : ZCC_KNA1, ZCC_VBAK.
    EXIT.
  ENDIF.

  PERFORM FILL_VBAK.
  GV_CLOSE = 'X'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_NAME1_0140  INPUT
*&---------------------------------------------------------------------*
MODULE SET_NAME1_0140 INPUT.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
         LS_RETURN TYPE DDSHRETVAL.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME     = 'ZCC_KNA1'         " Table/structure name from Dictionary
      FIELDNAME   = 'KUNNR'            " Field name from Dictionary
      SEARCHHELP  = 'ZCC_SH_CUST'      " Search help as screen field attribute
      DYNPPROG    = SY-REPID           " Current program
      DYNPNR      = SY-DYNNR           " Screen number
      DYNPROFIELD = 'ZCC_KNA1-KUNNR'   " Name of screen field for value return
    TABLES
      RETURN_TAB  = LT_RETURN.         " Return the selected value

  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF SY-SUBRC = 0.
    " 고객ID를 입력
    ZCC_QUOT-KUNNR = LS_RETURN-FIELDVAL.

    " 고객명을 가져옴
    SELECT SINGLE NAME1
      INTO @ZCC_QUOT-NAME1
      FROM ZCC_KNA1
     WHERE KUNNR = @ZCC_QUOT-KUNNR.

    LEAVE SCREEN.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_KUNNR_0140  INPUT
*&---------------------------------------------------------------------*
MODULE SET_KUNNR_0140 INPUT.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME     = 'ZCC_KNA1'         " Table/structure name from Dictionary
      FIELDNAME   = 'KUNNR'            " Field name from Dictionary
      SEARCHHELP  = 'ZCC_SH_CUST'      " Search help as screen field attribute
      DYNPPROG    = SY-REPID           " Current program
      DYNPNR      = SY-DYNNR           " Screen number
      DYNPROFIELD = 'ZCC_KNA1-KUNNR'   " Name of screen field for value return
    TABLES
      RETURN_TAB  = LT_RETURN.         " Return the selected value

  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF SY-SUBRC = 0.
    " 고객ID를 입력
    ZCC_QUOT-KUNNR = LS_RETURN-FIELDVAL.

    " 고객명을 가져옴
    SELECT SINGLE NAME1
      INTO @ZCC_QUOT-NAME1
      FROM ZCC_KNA1
     WHERE KUNNR = @ZCC_QUOT-KUNNR.

    LEAVE SCREEN.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0140  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0140 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0140  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0140 INPUT.

  CASE OK_CODE.
    WHEN 'LOAD'.

      DATA: LT_ROWS TYPE LVC_T_ROW,     " 선택된 행 인덱스 목록
            LS_ROW  TYPE LVC_S_ROW.

      CALL METHOD GO_ALV_GRID3->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROWS.

      " 선택된 행의 개수 파악
      DESCRIBE TABLE LT_ROWS LINES DATA(LV_LINE_COUNT).

      IF LV_LINE_COUNT NE 1.
        " 선택된 행의 개수가 1개가 아닌 경우
        " 한 건의 견적만 선택해주세요.
        MESSAGE S128(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        READ TABLE LT_ROWS INTO LS_ROW INDEX 1.
      ENDIF.

      IF LS_ROW-ROWTYPE IS NOT INITIAL.
        " 일반 행이 아닌 행을 선택한 경우
        " 일반 행을 선택해주세요.
        MESSAGE S129(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      READ TABLE GT_QUOT INTO GS_QUOT INDEX LS_ROW-INDEX.

      MOVE-CORRESPONDING GS_QUOT TO ZCC_KNA1.

      SELECT SINGLE KUNNR
                    NAME1
                    STRAS
                    LAND1
                    WERKS
                    BANKN
                    WAERS
                    STCD1
                    EMAIL
                    NAME2
                    TELF
                    ZTERM
                    ZLSPR
                    LOEVM
          FROM ZCC_KNA1
          INTO CORRESPONDING FIELDS OF ZCC_KNA1
          WHERE KUNNR = ZCC_KNA1-KUNNR
             OR NAME1 = ZCC_KNA1-NAME1.

      PERFORM FILL_VBAK.

      ZCC_VBAK-STRAS = GS_QUOT-STRAS.
      ZCC_VBAK-NAME2 = GS_QUOT-NAME2.
      ZCC_VBAK-EMAIL = GS_QUOT-EMAIL.
      ZCC_VBAK-TELF = GS_QUOT-TELF.
      ZCC_VBAK-AUART = 'QT'.
      ZCC_VBAK-VKBUR = GS_QUOT-VKBUR.
      ZCC_VBAK-VDATU = GS_QUOT-VDATU.
      GV_CLOSE = 'X'.

      " 완제품에 해당하는 노드를 클릭했을 때만 ALV에 아이템을 삽입하도록 처리함.
      " 제품 테이블에서 노드의 ITEM TEXT에 해당하는 제품번호를 조건으로 하여 검색
      SELECT SINGLE
        FROM ZCC_MVKE
        FIELDS *
        WHERE MATNR EQ @GS_QUOT-MATNR
        INTO @DATA(LS_MVKE).

      PERFORM FILL_ALV USING LS_MVKE.

      GS_QUOT-QUOT_STAT = 'X'.

      LEAVE TO SCREEN 0.

    WHEN 'SEARCH'.
      PERFORM SELECT_QUOT USING ZCC_QUOT-KUNNR ZCC_QUOT-NAME1
                       CHANGING GT_QUOT.

      CALL METHOD GO_ALV_GRID3->REFRESH_TABLE_DISPLAY
        EXCEPTIONS
          FINISHED = 1                " Display was Ended (by Export)
          OTHERS   = 2.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_NAME1  INPUT
*&---------------------------------------------------------------------*
MODULE SET_NAME1 INPUT.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME     = 'ZCC_KNA1'         " Table/structure name from Dictionary
      FIELDNAME   = 'KUNNR'            " Field name from Dictionary
      SEARCHHELP  = 'ZCC_SH_CUST'      " Search help as screen field attribute
      DYNPPROG    = SY-REPID           " Current program
      DYNPNR      = SY-DYNNR           " Screen number
      DYNPROFIELD = 'ZCC_KNA1-KUNNR'   " Name of screen field for value return
    TABLES
      RETURN_TAB  = LT_RETURN.         " Return the selected value

  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF SY-SUBRC = 0.
    " 고객ID를 입력
    ZCC_KNA1-KUNNR = LS_RETURN-FIELDVAL.

    " 고객명을 가져옴
    SELECT SINGLE NAME1
      INTO @ZCC_KNA1-NAME1
      FROM ZCC_KNA1
     WHERE KUNNR = @ZCC_KNA1-KUNNR.

    LEAVE SCREEN.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_KUNNR  INPUT
*&---------------------------------------------------------------------*
MODULE SET_KUNNR INPUT.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME     = 'ZCC_KNA1'         " Table/structure name from Dictionary
      FIELDNAME   = 'KUNNR'            " Field name from Dictionary
      SEARCHHELP  = 'ZCC_SH_CUST'      " Search help as screen field attribute
      DYNPPROG    = SY-REPID           " Current program
      DYNPNR      = SY-DYNNR           " Screen number
      DYNPROFIELD = 'ZCC_KNA1-KUNNR'   " Name of screen field for value return
    TABLES
      RETURN_TAB  = LT_RETURN.         " Return the selected value

  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF SY-SUBRC = 0.
    " 고객ID를 입력
    ZCC_KNA1-KUNNR = LS_RETURN-FIELDVAL.

    " 고객명을 가져옴
    SELECT SINGLE NAME1
      INTO @ZCC_KNA1-NAME1
      FROM ZCC_KNA1
     WHERE KUNNR = @ZCC_KNA1-KUNNR.

    LEAVE SCREEN.

  ENDIF.

ENDMODULE.
