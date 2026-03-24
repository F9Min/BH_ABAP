*&---------------------------------------------------------------------*
*& Include          MZCC_SD010I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SEARCH'.
      CASE GV_TABTYPE.
        WHEN GC_PERFORM.
          " 판매실적 조회 기능
          PERFORM SELECT_DATA_PERFORMANCE.
          PERFORM MODIFY_DATA.
        WHEN GC_PLAN.
          " 판매계획 조회 기능
          PERFORM SELECT_DATA_PLAN.
          PERFORM MODIFY_PLAN_DATA.
      ENDCASE.
    WHEN 'CRET_MULTI'.
      " 계획다건생성
      PERFORM CREATE_MULTI_PLAN.
      CALL SCREEN 0200.
    WHEN 'CRET_ONE'.
      " 계획단건생성
      CLEAR : GS_INPUT_SINGLE.
      CALL SCREEN 0210 STARTING AT 5 5.
    WHEN 'NEXT'.
      " 생산계획 생성으로 이동
      CALL TRANSACTION 'ZCCPP070'.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_ACTIVE_TAB  INPUT
*&---------------------------------------------------------------------*
MODULE GET_ACTIVE_TAB INPUT.

  CASE OK_CODE.
    WHEN 'FC1'.
      TS-ACTIVETAB = OK_CODE.
    WHEN 'FC2'.
      TS-ACTIVETAB = OK_CODE.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ALV_CHECK_CHANGED_DATA  INPUT
*&---------------------------------------------------------------------*
MODULE ALV_CHECK_CHANGED_DATA INPUT.

  IF SY-DYNNR EQ '0100'.
    " GO_ALV_GRID2가 생성되었을 경우에만 아래 로직을 진행함.
    CHECK GO_ALV_GRID2 IS BOUND.
    " CHECK GO_ALV_GRID2 IS NOT INITIAL.

    " alv의 편집 중인 셀의 내용이 internal table로 전달되기 위한 메소드 호출
    CALL METHOD GO_ALV_GRID2->CHECK_CHANGED_DATA.
  ELSEIF SY-DYNNR EQ '0200'.
    " GO_ALV_GRID2가 생성되었을 경우에만 아래 로직을 진행함.
    CHECK GO_ALV_GRID4 IS BOUND.
    " CHECK GO_ALV_GRID2 IS NOT INITIAL.

    " alv의 편집 중인 셀의 내용이 internal table로 전달되기 위한 메소드 호출
    CALL METHOD GO_ALV_GRID4->CHECK_CHANGED_DATA.
  ENDIF.

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
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

  CASE OK_CODE.
    WHEN 'SHOW01'.
      CLEAR : GV_HIDE01.
    WHEN 'HIDE01'.
      GV_HIDE01 = ABAP_TRUE.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.

  CASE OK_CODE.
    WHEN 'SHOW02'.
      CLEAR : GV_HIDE02.
    WHEN 'HIDE02'.
      GV_HIDE02 = ABAP_TRUE.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE' OR 'PLAN_SAVE'.
      "DB 저장 관련 로직
      CLEAR : GT_SAVE.

      PERFORM CONVERT_MULTI_SAVE USING GT_DISPLAY3
                              CHANGING GT_SAVE.

      PERFORM CHECK_PLAN USING GT_SAVE.
    WHEN 'NEXT'.
      CALL SCREEN 0100 STARTING AT 5 5.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_MATKG  INPUT
*&---------------------------------------------------------------------*
MODULE SET_MATKG INPUT.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
         LS_RETURN TYPE DDSHRETVAL.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME    = 'ZCC_MAKT'            " Table/structure name from Dictionary
      FIELDNAME  = 'MATNR'               " Field name from Dictionary
      SEARCHHELP = 'ZCC_SH_MAKT'         " Search help as screen field attribute
    TABLES
      RETURN_TAB = LT_RETURN.         " Return the selected value

  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF SY-SUBRC EQ 0.
    " 자재ID, 자재명, 제품군, 제품군명을 가져옴.
    SELECT SINGLE A~MATNR,
                  B~MAKTG,
                  A~SPART
    INTO @DATA(LS_MAT)
    FROM ZCC_MARA AS A
    LEFT OUTER JOIN ZCC_MAKT AS B
       ON B~MATNR EQ A~MATNR
      AND B~SPRAS EQ @SY-LANGU
    WHERE A~MATNR EQ @LS_RETURN-FIELDVAL.

    " 제품군명을 가져옴.
    SELECT SINGLE
         FROM DD07L AS A
         LEFT OUTER JOIN
              DD07T AS B ON A~DOMNAME   EQ B~DOMNAME
                        AND A~AS4LOCAL  EQ B~AS4LOCAL
                        AND A~VALPOS    EQ B~VALPOS
                        AND A~AS4VERS   EQ B~AS4VERS
         FIELDS A~DOMVALUE_L, B~DDTEXT
         WHERE A~DOMNAME    EQ 'ZCC_SPART'
           AND B~DDLANGUAGE EQ @SY-LANGU
           AND A~AS4LOCAL   EQ 'A'  " Active인 Fixed Value만 조회
           AND A~DOMVALUE_L EQ @LS_MAT-SPART
          INTO @DATA(LS_SPART_TXT).

    DATA LT_DYNPREAD2 TYPE TABLE OF DYNPREAD.
    DATA LS_DYNPREAD2 TYPE DYNPREAD.

    CLEAR LS_DYNPREAD2.
    LS_DYNPREAD2-FIELDNAME = 'GS_INPUT_SINGLE-MATNR'.
    LS_DYNPREAD2-FIELDVALUE = LS_MAT-MATNR.
    APPEND LS_DYNPREAD2 TO LT_DYNPREAD2.

    CLEAR LS_DYNPREAD2.
    LS_DYNPREAD2-FIELDNAME = 'GS_INPUT_SINGLE-MAKTG'.
    LS_DYNPREAD2-FIELDVALUE = LS_MAT-MAKTG.
    APPEND LS_DYNPREAD2 TO LT_DYNPREAD2.

    CLEAR LS_DYNPREAD2.
    LS_DYNPREAD2-FIELDNAME = 'GS_INPUT_SINGLE-SPART'.
    LS_DYNPREAD2-FIELDVALUE = LS_MAT-SPART.
    APPEND LS_DYNPREAD2 TO LT_DYNPREAD2.

    CLEAR LS_DYNPREAD2.
    LS_DYNPREAD2-FIELDNAME = 'GS_INPUT_SINGLE-SPART_TXT'.
    LS_DYNPREAD2-FIELDVALUE = LS_SPART_TXT-DDTEXT.
    APPEND LS_DYNPREAD2 TO LT_DYNPREAD2.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-REPID         " Program Name
        DYNUMB               = '0210'           " Screen number
      TABLES
        DYNPFIELDS           = LT_DYNPREAD2     " Screen field value reset table
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1                " No valid work area
        INVALID_DYNPROFIELD  = 2                " No valid screen field
        INVALID_DYNPRONAME   = 3                " No valid screen name
        INVALID_DYNPRONUMMER = 4                " Invalid screen number
        INVALID_REQUEST      = 5                " General request error
        NO_FIELDDESCRIPTION  = 6                " No field description
        UNDEFIND_ERROR       = 7                " Undefined error
        OTHERS               = 8.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

**   자재ID를 가져옴.
*    GS_INPUT_SINGLE-MATNR = LS_RETURN-FIELDVAL.
*
**   자재명을 가져옴.
*    SELECT SINGLE MAKTG
*      INTO @GS_INPUT_SINGLE-MAKTG
*      FROM ZCC_MAKT
*     WHERE MATNR = @GS_INPUT_SINGLE-MATNR.
*
*    DATA LV_VALUE TYPE DYNPREAD-FIELDVALUE.
*
*    LV_VALUE = GS_INPUT_SINGLE-MAKTG.
*
*    CALL FUNCTION 'SET_DYNP_VALUE'
*      EXPORTING
*        I_FIELD = 'GS_INPUT_SINGLE-MAKTG'
*        I_REPID = SY-REPID
*        I_DYNNR = '0210'
*        I_VALUE = LV_VALUE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_SPART_TXT  INPUT
*&---------------------------------------------------------------------*
MODULE SET_SPART_TXT INPUT.

* 제품군 코드와 제품군 코드에 대한 상세설명을 SELECT 하여 LOCAL VARIABLE에 입력
  SELECT FROM DD07L AS A
    LEFT OUTER JOIN
    DD07T AS B ON A~DOMNAME   EQ B~DOMNAME
    AND A~AS4LOCAL  EQ B~AS4LOCAL
    AND A~VALPOS    EQ B~VALPOS
    AND A~AS4VERS   EQ B~AS4VERS
    FIELDS A~DOMVALUE_L, B~DDTEXT
    WHERE A~DOMNAME    EQ 'ZCC_SPART'
      AND B~DDLANGUAGE EQ @SY-LANGU
      AND A~AS4LOCAL   EQ 'A'  " Active인 Fixed Value만 조회
    ORDER BY A~VALPOS
     INTO TABLE @DATA(LT_SPART).

  SORT LT_SPART BY DOMVALUE_L.

* LOCAL VARIABLE에 입력한 데이터를 INPUT HELP로 출력
  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'DOMVALUE_L'                          " Name of return field in FIELD_TAB
      WINDOW_TITLE    = '제품군'                          " Title for the hit list
      VALUE_ORG       = 'S'                               " Value return: C: cell by cell, S: structured
    TABLES
      VALUE_TAB       = LT_SPART                          " Table of values: entries cell by cell
      RETURN_TAB      = LT_RETURN_TAB                     " Return the selected value
    EXCEPTIONS
      PARAMETER_ERROR = 1                                 " Incorrect parameter
      NO_VALUES_FOUND = 2                                 " No values found
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* 선택한 INPUT HELP의 제품군 코드에 맞춰 코드에 대한 설명을 읽어오기 위해 READ TABLE
  READ TABLE LT_RETURN_TAB INTO DATA(LS_RETURN_TAB) INDEX 1.

  IF SY-SUBRC EQ '0'.
    " 선택된 코드를 기준으로 제품군명을 가져옴.
    READ TABLE LT_SPART INTO DATA(LS_SPART) WITH KEY DOMVALUE_L = LS_RETURN_TAB-FIELDVAL BINARY SEARCH.


    DATA LT_DYNPREAD TYPE TABLE OF DYNPREAD.
    DATA LS_DYNPREAD TYPE DYNPREAD.

    CLEAR LS_DYNPREAD.
    LS_DYNPREAD-FIELDNAME = 'GS_INPUT_SINGLE-SPART'.
    LS_DYNPREAD-FIELDVALUE = LS_SPART-DOMVALUE_L.
    APPEND LS_DYNPREAD TO LT_DYNPREAD.

    CLEAR LS_DYNPREAD.
    LS_DYNPREAD-FIELDNAME = 'GS_INPUT_SINGLE-SPART_TXT'.
    LS_DYNPREAD-FIELDVALUE = LS_SPART-DDTEXT.
    APPEND LS_DYNPREAD TO LT_DYNPREAD.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-REPID         " Program Name
        DYNUMB               = '0210'           " Screen number
      TABLES
        DYNPFIELDS           = LT_DYNPREAD      " Screen field value reset table
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1                " No valid work area
        INVALID_DYNPROFIELD  = 2                " No valid screen field
        INVALID_DYNPRONAME   = 3                " No valid screen name
        INVALID_DYNPRONUMMER = 4                " Invalid screen number
        INVALID_REQUEST      = 5                " General request error
        NO_FIELDDESCRIPTION  = 6                " No field description
        UNDEFIND_ERROR       = 7                " Undefined error
        OTHERS               = 8.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0210 INPUT.

  CASE OK_CODE.
    WHEN 'SAVE'.
      CLEAR : GT_SAVE.
      PERFORM CONVERT_SINGLE_SAVE USING GS_INPUT_SINGLE
                               CHANGING GT_SAVE.
      PERFORM CHECK_PLAN          USING GT_SAVE.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0210  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0210 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0300  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0300 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0310  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0310 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
