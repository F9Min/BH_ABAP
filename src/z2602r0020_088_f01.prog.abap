*&---------------------------------------------------------------------*
*& Include          Z2602R0020_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CREATE OBJECT LO_INCENTIVE.
  CALL METHOD LO_INCENTIVE->CALCULATE_MONTHLY_INCENTIVE  " METHOD가 INSATNCE METHOD 이므로 객체가 필수
    EXPORTING
      IV_YEAR   = P_YYYY
    IMPORTING
      ET_RESULT = GT_RESULT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_USER_NAME
*&---------------------------------------------------------------------*
FORM GET_USER_NAME .

  SELECT BNAME, NAME_TEXTC FROM USER_ADDR " 또는 ADRP 등 시스템 환경에 맞는 테이블
      FOR ALL ENTRIES IN @GT_RESULT
      WHERE BNAME = @GT_RESULT-VBELN_REP
      INTO TABLE @GT_NAMES.

  PERFORM SET_DISPLAY_ITAB USING GT_NAMES.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISPLAY_ITAB
*&---------------------------------------------------------------------*
FORM SET_DISPLAY_ITAB  USING PT_NAMES TYPE TT_NAMES.

  DATA : LS_COLOR_LINE LIKE LINE OF GS_DISPLAY-COLOR_TAB.
  SORT PT_NAMES BY BNAME.
  CLEAR : GT_DISPLAY.

  LOOP AT GT_RESULT INTO DATA(LS_RESULT).

    CLEAR : GS_DISPLAY, LS_COLOR_LINE.
    MOVE-CORRESPONDING LS_RESULT TO GS_DISPLAY.

    READ TABLE PT_NAMES INTO DATA(LS_NAMES) WITH KEY BNAME = LS_RESULT-VBELN_REP BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISPLAY-NAME_TEXTC = LS_NAMES-NAME_TEXTC.
    ENDIF.

    GS_DISPLAY-BONUS_AMOUNT = SWITCH #(
      GS_DISPLAY-GRADE
        WHEN 'A' THEN GS_DISPLAY-TOTAL_SALES * '0.05'
        WHEN 'B' THEN GS_DISPLAY-TOTAL_SALES * '0.02'
        ELSE 0
    ).

    IF GS_DISPLAY-GRADE = 'A'.

      LS_COLOR_LINE-FNAME = 'GRADE'.
      LS_COLOR_LINE-COLOR-COL = COL_POSITIVE.
      LS_COLOR_LINE-COLOR-INT = '1'.
      LS_COLOR_LINE-COLOR-INV = '0'.
      APPEND LS_COLOR_LINE TO GS_DISPLAY-COLOR_TAB.

    ENDIF.

    APPEND GS_DISPLAY TO GT_DISPLAY.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  CALL SCREEN 0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  CREATE OBJECT GO_DOCKING
    EXPORTING
      REPID                       = SY-CPROG         " Report to Which This Docking Control is Linked
      DYNNR                       = SY-DYNNR         " Screen to Which This Docking Control is Linked
      EXTENSION                   = 5000             " Control Extension
    EXCEPTIONS
      CNTL_ERROR                  = 1                " Invalid Parent Control
      CNTL_SYSTEM_ERROR           = 2                " System Error
      CREATE_ERROR                = 3                " Create Error
      LIFETIME_ERROR              = 4                " Lifetime Error
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT          = GO_DOCKING                 " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1                " Error when creating the control
      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
      ERROR_CNTL_LINK   = 3                " Error While Linking Control
      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO .

  GS_LAYO-CWIDTH_OPT = 'X'.
  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-SEL_MODE = 'D'.
  GS_LAYO-CTAB_FNAME = 'COLOR_TAB'.

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT .

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
  LV_COL_POS = 10.

  PERFORM SET_FIELD_CATALOG USING : 'GRADE' SPACE '평가 등급' SPACE SPACE CHANGING LV_COL_POS,
                                    'VBELN_REP' ABAP_ON '영업사원 번호' SPACE SPACE CHANGING LV_COL_POS,
                                    'NAME_TEXTC' SPACE '영업사원명' SPACE SPACE CHANGING LV_COL_POS,
                                    'TOTAL_SALES' SPACE '판매 총 금액' SPACE SPACE CHANGING LV_COL_POS,
                                    'BONUS_AMOUNT' SPACE '보너스 금액' SPACE SPACE CHANGING LV_COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG USING PV_FIELDNAME
                             PV_KEY
                             PV_COLTEXT
                             PV_REF_TABLE
                             PV_REF_FIELD
                    CHANGING PV_COL_POS.

  DATA(LS_FCAT) = VALUE LVC_S_FCAT( FIELDNAME = PV_FIELDNAME
                                    KEY = PV_KEY
                                    COL_POS = PV_COL_POS
                                    COLTEXT = PV_COLTEXT
                                    REF_TABLE = PV_REF_TABLE
                                    REF_FIELD = PV_REF_FIELD
                                   ).

  CASE PV_FIELDNAME.
    WHEN 'TOTAL_SALES' OR 'BONUS_AMOUNT'.
      LS_FCAT-CFIELDNAME = 'KRW'.
  ENDCASE.

  APPEND LS_FCAT TO GT_FCAT.
  PV_COL_POS += 10.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  SORT GT_DISPLAY BY GRADE
                     TOTAL_SALES DESCENDING.

  CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE          " Save Layout
      IS_LAYOUT                     = GS_LAYO          " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY       " Output Table
      IT_FIELDCATALOG               = GT_FCAT          " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .
  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
ENDFORM.
