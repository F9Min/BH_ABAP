*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT INPUT.

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
    WHEN 'RENT'.
      PERFORM CHECK_BOOK.
    WHEN 'RETURN'.
      PERFORM RETURN_BOOK.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

  CASE OK_CODE.
    WHEN 'ENTER'.
      GV_ID = ZS4H088T05-ID.
      IF GV_ID IS INITIAL.
        MESSAGE TEXT-E07 TYPE 'W' DISPLAY LIKE 'E'.  " 대여할 고객 ID를 입력해주세요.
        RETURN.
      ENDIF.
      PERFORM RENT_BOOK.
*      PERFORM SELECT_DATA.
*      PERFORM MODIFY_DATA.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SELECT_ID  INPUT
*&---------------------------------------------------------------------*
MODULE SELECT_ID INPUT.

  " ZS4H088T05-ID에 이름 혹은 ID를 입력했을 때 해당 사용자만 SEARCH HELP에 출력되도록 함.
  DATA : LR_ID         TYPE RANGE OF ZS4H088T05-ID,
         LS_ID         LIKE LINE OF LR_ID,
         LR_NAME       TYPE RANGE OF ZS4H088T04-NAME,
         LS_NAME       LIKE LINE OF LR_NAME,
         LT_DYNPFIELDS TYPE TABLE OF DYNPREAD,
         LS_DYNPFIELD  TYPE DYNPREAD.

  LS_DYNPFIELD-FIELDNAME = 'ZS4H088T05-ID'.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID         " Program Name
      DYNUMB               = SY-DYNNR         " Screen Number
    TABLES
      DYNPFIELDS           = LT_DYNPFIELDS    " Table for Reading Current Screen Values
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1                " No valid work area
      INVALID_DYNPROFIELD  = 2                " No valid screen field
      INVALID_DYNPRONAME   = 3                " No valid screen name
      INVALID_DYNPRONUMMER = 4                " Invalid screen number
      INVALID_REQUEST      = 5                " General request error
      NO_FIELDDESCRIPTION  = 6                " No field description
      INVALID_PARAMETER    = 7                " Internal system function parameters have incorrect values
      UNDEFIND_ERROR       = 8                " Undefined error
      DOUBLE_CONVERSION    = 9                " Double conversion required
      STEPL_NOT_FOUND      = 10               " Could not determine line in the loop
      OTHERS               = 11.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF LT_DYNPFIELDS IS INITIAL.

    " SEARCH HELP로 출력할 ITAB를 출력
    SELECT ID,
           NAME
      FROM ZS4H088T04
      INTO TABLE @DATA(LT_ID).

  ELSE.
    READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.

    LS_ID-LOW = '*' && LS_DYNPFIELD-FIELDVALUE && '*'.
    LS_ID-SIGN = 'I'.
    LS_ID-OPTION = 'CP'.
    APPEND LS_ID TO LR_ID.

    LS_NAME-LOW = '*' && LS_DYNPFIELD-FIELDVALUE && '*'.
    LS_NAME-SIGN = 'I'.
    LS_NAME-OPTION = 'CP'.
    APPEND LS_NAME TO LR_NAME.

    " SEARCH HELP로 출력할 ITAB를 출력
    SELECT ID,
           NAME
      FROM ZS4H088T04
      INTO TABLE @LT_ID
      WHERE NAME IN @LR_NAME
         OR ID   IN @LR_ID.

  ENDIF.

  SORT LT_ID BY ID.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL.

* ITAB를 통한 SEARCH HELP 출력
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ID'             " Name of return field in FIELD_TAB
      WINDOW_TITLE    = '고객ID'         " Title for the hit list
      VALUE_ORG       = 'S'              " Value return: C: cell by cell, S: structured
    TABLES
      VALUE_TAB       = LT_ID            " Table of values: entries cell by cell
      RETURN_TAB      = LT_RETURN_TAB    " Return the selected value
    EXCEPTIONS
      PARAMETER_ERROR = 1                " Incorrect parameter
      NO_VALUES_FOUND = 2                " No values found
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* ITAB 내부에 한줄만 존재하기 때문에 INDEX 1을 기준으로 READ TABLE
  READ TABLE LT_RETURN_TAB INTO DATA(LS_RETURN_WA) INDEX 1.

* 선택된 ID를 Global Variable에 저장
  CLEAR : ZS4H088T05-ID.
  ZS4H088T05-ID = LS_RETURN_WA-FIELDVAL.

* 기능 재사용에 대비하여 Local Variable Clear
  CLEAR : LR_NAME, LR_ID, LT_ID.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0120  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0120 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      CLEAR : GV_DIALOG.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
