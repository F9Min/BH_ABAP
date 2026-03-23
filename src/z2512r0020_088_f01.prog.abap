*&---------------------------------------------------------------------*
*& Include          Z2512R0020_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_USER_PARAMETERS
*&---------------------------------------------------------------------*
FORM GET_USER_PARAMETERS  USING PV_PARID.

  DATA : LV_CAC   TYPE KOKRS,
         LT_PARAM TYPE USTYP_T_PARAMETERS.

  CALL FUNCTION 'S_TWB_U_GET_USER_PARAMETERS'
    EXPORTING
      USER_NAME          = SY-UNAME
    TABLES
      SET_GET_PARAMETERS = LT_PARAM.

  PERFORM SET_INITAL_VALUE USING LV_CAC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INITAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITAL_VALUE USING PV_CAC.

  IF PV_CAC IS NOT INITIAL.
    S_KOKRS-LOW = PV_CAC.
    APPEND S_KOKRS.

    SELECT SINGLE FROM TKA02
      FIELDS BUKRS
       WHERE KOKRS = @PV_CAC
        INTO @S_RBUKRS-LOW.

    IF SY-SUBRC EQ 0.
      APPEND S_RBUKRS.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  LOOP AT SCREEN.
    IF SCREEN-NAME = 'S_RBUKRS-LOW'.
      SCREEN-INPUT = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RBUKRS
*&---------------------------------------------------------------------*
FORM SET_RBUKRS .

  IF S_KOKRS-LOW IS NOT INITIAL.

    CLEAR : S_RBUKRS.

    SELECT SINGLE FROM TKA02
      FIELDS BUKRS
      WHERE KOKRS = @S_KOKRS-LOW
      INTO @S_RBUKRS-LOW.

    APPEND S_RBUKRS.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  DATA : LV_LDATE TYPE SY-DATUM,
         LV_FDATE TYPE SY-DATUM,
         LR_BUDAT TYPE RANGE OF SY-DATUM,
         LS_BUDAT LIKE LINE OF LR_BUDAT.

**********************************************************************
* 날짜
**********************************************************************
  LV_FDATE = S_GJAHR-LOW && S_POPER-LOW+1(2) && '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = LV_FDATE         " Key date
    IMPORTING
      LAST_DAY_OF_MONTH = LV_LDATE         " Date of last day of the month from key  date
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1                " Key date is no date
      OTHERS            = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LS_BUDAT-LOW = LV_FDATE.
  LS_BUDAT-HIGH = LV_LDATE.
  LS_BUDAT-OPTION = 'BT'.
  LS_BUDAT-SIGN = 'I'.
  APPEND LS_BUDAT TO LR_BUDAT.

**********************************************************************
* Code Class Header, Body, Content
**********************************************************************

  " Code Class Header
  SELECT SINGLE FROM ZCMT0110
  FIELDS ZMODULE, CLASS
  WHERE ZMODULE = 'CO' AND CLASS = 'CO002'
  INTO @DATA(LS_CLASS_HEADER).

  " Code Class Body
  SELECT FROM ZCMT0120
    FIELDS FIELDS, FLDDESC
    WHERE ZUSAGE EQ @ABAP_ON
      AND CLASS = 'CO002'
    INTO TABLE @DATA(LT_CLASS_BODY).

  " Code Class Content
  SELECT SINGLE FROM ZCMT0130
    FIELDS ZMODULE, CLASS, SEQNO,
           FIELD05, " CO Area
           FIELD11, " Order Group
           FIELD14, " Order Group Text
           FIELD01, " (X)Highest
           FIELD02, " (X)CElement
           FIELD12, " CElement
           FIELD13  " CElement Group
    WHERE FIELD05 = @S_KOKRS-LOW
    INTO @DATA(LS_CLASS_DATA).

**********************************************************************
* 원가요소 계정그룹 -> 원가요소 계정
**********************************************************************
  DATA : LV_CA      TYPE BAPI1030_GEN-CO_AREA,
         LV_EG      TYPE BAPI1030_GEN-COST_ELEM_GRP,
         LT_ELEMENT LIKE TABLE OF BAPI1030_CELIST,
         LT_RETURN  LIKE TABLE OF BAPIRET2.

  LV_CA = S_KOKRS-LOW.
  LV_EG = LS_CLASS_DATA-FIELD13.

  CALL FUNCTION 'K_COSTELEM_BAPI_GETLIST'
    EXPORTING
      CONTROLLINGAREA  = LV_CA  " 관리회계영역(KOKRS)
      COSTELEMENTGROUP = LV_EG  " 셋(Set) 기반 원가요소 그룹명
    TABLES
      COSTELEMENTLIST  = LT_ELEMENT
      RETURN           = LT_RETURN.

  " Error Message 출력 시 예외 처리
  LOOP AT LT_RETURN ASSIGNING FIELD-SYMBOL(<FS_RETURN>).
    IF <FS_RETURN>-TYPE = 'E'.
      MESSAGE I003 DISPLAY LIKE 'E'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.

**********************************************************************
* 원가요소 계정기준 전표 Select
**********************************************************************
  SELECT FROM ACDOCA
    FIELDS RLDNR,
           RBUKRS,
           AUTYP,
           RACCT,
           BUDAT,
           AUFNR,
           HSL,
           XREVERSING,
           XREVERSED
    FOR ALL ENTRIES IN @LT_ELEMENT
    WHERE RLDNR EQ '0L'
      AND RBUKRS EQ @S_RBUKRS-LOW
      AND AUTYP EQ '40'
      AND RACCT EQ @LT_ELEMENT-COST_ELEM
      AND BUDAT IN @LR_BUDAT
      AND AUFNR IS NOT INITIAL
      AND XREVERSING NE @ABAP_ON
      AND XREVERSED  NE @ABAP_ON
     APPENDING CORRESPONDING FIELDS OF TABLE @GT_DATA.

**********************************************************************
* Display 용 데이터로 집계
**********************************************************************
  DATA : LS_DISPLAY TYPE TS_DISPLAY.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    MOVE-CORRESPONDING <FS_DATA> TO LS_DISPLAY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .



ENDFORM.
