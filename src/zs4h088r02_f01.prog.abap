*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  DATA : LT_WHERE  TYPE STRING,
         LT_WHERE2 TYPE STRING,
         LT_DATA   TYPE TY_DATA.

* 검색기능 구현
  IF SO_TITLE-LOW IS NOT INITIAL.
    LOOP AT SO_TITLE.
      " CP는 와일드카드를 반드시 포함해야한다.
      SO_TITLE-LOW = '*' && SO_TITLE-LOW && '*'.
      SO_TITLE-OPTION = 'CP'.
      MODIFY SO_TITLE.
    ENDLOOP.
  ENDIF.

  IF PA_DEL EQ 'X'.
    " 연체 포함 : 연체만 조회되도록
    LT_WHERE  = |T05~REDATE < @SY-DATUM|.
    LT_WHERE2 = |T05~REDATE IS NOT INITIAL|.
  ELSE.
    " 연체 미포함 : 연체를 포함하지 않도록
*    LT_WHERE = |T05~REDATE IS INITIAL OR T05~REDATE >= @SY-DATUM|.
  ENDIF.

  SELECT T01~CODE,                                        " 도서분류코드
         T01~TEXT,                                        " 도서분류
         T02~TITLE,                                       " 도서명
         T02~AUTHOR,                                      " 저자
         T02~PUBLISHER,                                   " 출판사
         T03~ISBN,                                        " ISBN
         T03~SEQ,                                         " SEQ.
         T04~ID,                                          " 이름
         T04~NAME,                                        " 사용자명, 대여자
         T05~RDATE,                                       " 대여일
         T05~REDATE                                       " 반납기일
    FROM ZS4H088T01 AS T01                                " 도서분류
    JOIN ZS4H088T02 AS T02                                " 도서정보
      ON T01~CODE = T02~CODE
    JOIN ZS4H088T03 AS T03                                " 도서개별
      ON T02~CODE = T03~CODE AND T02~ISBN = T03~ISBN
    LEFT OUTER JOIN ZS4H088T05 AS T05                     " 도서대여정보
      ON T03~CODE = T05~CODE AND T03~ISBN = T05~ISBN AND T05~REDATE2 IS INITIAL AND T03~SEQ = T05~SEQ AND (LT_WHERE)
    LEFT OUTER JOIN ZS4H088T04 AS T04                     " 사용자 정보
      ON T04~ID = T05~ID AND T03~CODE = T05~CODE AND T03~ISBN = T05~ISBN
    WHERE T04~ID        IN @SO_ID
      AND T04~NAME      IN @SO_NAME
      AND T02~TITLE     IN @SO_TITLE
      AND T02~PUBLISHER IN @SO_PUB
      AND T02~AUTHOR    IN @SO_AUT
      AND (LT_WHERE2)
    INTO CORRESPONDING FIELDS OF TABLE @LT_DATA.


  PERFORM MODIFY_DATA USING LT_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
FORM MODIFY_DATA USING LT_DATA TYPE TY_DATA.

  CLEAR : GT_DISPLAY.
  FIELD-SYMBOLS : <FS_DATA> TYPE TS_DATA.

  SORT LT_DATA BY ISBN SEQ.
  LOOP AT LT_DATA ASSIGNING <FS_DATA>.

    CLEAR : GS_DISPLAY.
    MOVE-CORRESPONDING <FS_DATA> TO GS_DISPLAY.

    AT NEW ISBN.
      PERFORM COLORIZE_ROW USING '3' '1' '0'
                        CHANGING GS_DISPLAY.
    ENDAT.

    PERFORM SET_OVERDUE USING <FS_DATA>
                     CHANGING GS_DISPLAY.
    PERFORM SET_ISBN USING <FS_DATA>
                  CHANGING GS_DISPLAY.

    APPEND GS_DISPLAY TO GT_DISPLAY.

  ENDLOOP.

  UNASSIGN <FS_DATA>.
  SORT GT_DISPLAY BY CODE TITLE ISBN ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OVERDUE
*&---------------------------------------------------------------------*
FORM SET_OVERDUE  USING    PS_DATA TYPE TS_DATA
                  CHANGING PS_DISPLAY TYPE TS_DISPLAY.

  DATA : LS_COLFIELD TYPE LINE OF TS_DISPLAY-IT_COLFIELDS.

  IF PS_DATA-RDATE IS NOT INITIAL.
    " 대여자가 존재하는 것은 대여 상태라는 것을 의미함.
    IF PS_DATA-REDATE < SY-DATUM.
      PS_DISPLAY-OVERDUE = 'X'.

      LS_COLFIELD-FNAME = 'OVERDUE'.
      LS_COLFIELD-COLOR-COL = COL_NEGATIVE.
      LS_COLFIELD-COLOR-INT = '1'.
      LS_COLFIELD-COLOR-INV = '0'.
      APPEND LS_COLFIELD TO PS_DISPLAY-IT_COLFIELDS.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ISBN
*&---------------------------------------------------------------------*
FORM SET_ISBN  USING    PS_DATA    TYPE TS_DATA
               CHANGING PS_DISPLAY TYPE TS_DISPLAY.

  DATA : LV_ISBN TYPE STRING,
         LV_SEQ  TYPE NUMC3.

  LV_SEQ = PS_DATA-SEQ.
  LV_ISBN = PS_DATA-ISBN &&'-' && LV_SEQ.
  PS_DISPLAY-ISBN = LV_ISBN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF GT_DISPLAY IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE '출력할 데이터가 없습니다.' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .

  IF GV_DIALOG IS INITIAL.
    CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

    SORT GT_DISPLAY BY CODE TITLE ISBN ID.
  ELSE.
    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT USING GV_DIALOG.

  IF GV_DIALOG EQ 'X'.

    CREATE OBJECT GO_CUSTOM2
      EXPORTING
        CONTAINER_NAME              = 'CCON1'            " Name of the Screen CustCtrl Name to Link Container To
      EXCEPTIONS
        CNTL_ERROR                  = 1                " CNTL_ERROR
        CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
        CREATE_ERROR                = 3                " CREATE_ERROR
        LIFETIME_ERROR              = 4                " LIFETIME_ERROR
        LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
        OTHERS                      = 6.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CREATE OBJECT GO_ALV_GRID2
      EXPORTING
        I_PARENT          = GO_CUSTOM2         " Parent Container
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

  ELSE.

*    CREATE OBJECT GO_CUSTOM
*      EXPORTING
*        CONTAINER_NAME              = 'CCON'            " Name of the Screen CustCtrl Name to Link Container To
*      EXCEPTIONS
*        CNTL_ERROR                  = 1                " CNTL_ERROR
*        CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
*        CREATE_ERROR                = 3                " CREATE_ERROR
*        LIFETIME_ERROR              = 4                " LIFETIME_ERROR
*        LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
*        OTHERS                      = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

    CREATE OBJECT GO_DOCKING
      EXPORTING
        REPID                       = SY-REPID         " Report to Which This Docking Control is Linked
        DYNNR                       = SY-DYNNR         " Screen to Which This Docking Control is Linked
        EXTENSION                   = 2000             " Control Extension
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
        I_PARENT          = GO_DOCKING       " Parent Container
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

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_LAYOUT USING PV_DIALOG.

  IF PV_DIALOG EQ SPACE.

    GS_LAYO-CWIDTH_OPT = 'A'.
    GS_LAYO-SEL_MODE   = 'A'.
    GS_LAYO-ZEBRA      = 'X'.
    GS_LAYO-CTAB_FNAME = 'IT_COLFIELDS'.
*    GS_LAYO-INFO_FNAME = 'COLOR'.

    GS_VARIANT-REPORT = SY-CPROG.
    GV_SAVE           = 'A'.

  ELSEIF PV_DIALOG EQ 'X'.

    GS_LAYO2-CWIDTH_OPT = 'A'.
    GS_LAYO2-SEL_MODE   = 'A'.
    GS_LAYO2-ZEBRA      = 'X'.

    GS_VARIANT2-REPORT = SY-CPROG.
    GV_SAVE2           = 'A'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG USING PV_DIALOG.

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
  LV_COL_POS = 10.
  IF PV_DIALOG EQ SPACE.

    PERFORM ADD_FIELD_CATALOG USING 'TEXT'      ABAP_ON '도서분류' 'ZS4H088T01' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'TITLE'     ABAP_ON '도서명'   'ZS4H088T02' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'ISBN'      ABAP_ON  'ISBN'    'ZS4H088T02' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'AUTHOR'    SPACE    '저자'    'ZS4H088T02' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'PUBLISHER' SPACE    '출판사'  'ZS4H088T02' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'ID'        SPACE    '대여자'  'ZS4H088T04' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'NAME'      SPACE    '대여자'  'ZS4H088T04' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'RDATE'     SPACE    '대여일'  'ZS4H088T05' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT.

    PERFORM ADD_FIELD_CATALOG USING 'OVERDUE'   SPACE    '연체여부' SPACE       SPACE 'C'
                           CHANGING LV_COL_POS GT_FCAT.

  ELSEIF PV_DIALOG EQ 'X'.

    CLEAR : GT_FCAT2.

    PERFORM ADD_FIELD_CATALOG USING 'ID'      ABAP_ON '사용자 ID' 'ZS4H088T04' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT2.

    PERFORM ADD_FIELD_CATALOG USING 'NAME'    SPACE   '사용자 명' 'ZS4H088T04' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT2.

    PERFORM ADD_FIELD_CATALOG USING 'RDATE'   SPACE   '대여일'    'ZS4H088T05' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT2.

    PERFORM ADD_FIELD_CATALOG USING 'REDATE2' SPACE   '반납일'    'ZS4H088T05' SPACE SPACE
                            CHANGING LV_COL_POS GT_FCAT2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM ADD_FIELD_CATALOG  USING    PV_FIELDNAME
                                 PV_KEY
                                 PV_COLTEXT
                                 PV_REF_TABLE
                                 PV_REF_FIELD
                                 PV_JUST
                        CHANGING PV_COL_POS TYPE LVC_S_FCAT-COL_POS
                                 PT_FCAT TYPE LVC_T_FCAT.

  PT_FCAT[] = VALUE #( BASE PT_FCAT[] ( FIELDNAME = PV_FIELDNAME
                                        KEY = PV_KEY
                                        COL_POS = PV_COL_POS
                                        COLTEXT = PV_COLTEXT
                                        REF_TABLE = PV_REF_TABLE
                                        REF_FIELD = PV_REF_FIELD
                                        JUST = PV_JUST
                                        ) ).

  PV_COL_POS += 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .
  IF GV_DIALOG IS INITIAL.

    CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT                 " Layout
        I_SAVE                        = GV_SAVE           " Save Layout
        IS_LAYOUT                     = GS_LAYO                 " Layout
      CHANGING
        IT_OUTTAB                     = GT_DISPLAY                 " Output Table
        IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
        PROGRAM_ERROR                 = 2                " Program Errors
        TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSEIF GV_DIALOG EQ 'X'.

    CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT2      " Layout
        I_SAVE                        = GV_SAVE2         " Save Layout
        I_DEFAULT                     = 'X'              " Default Display Variant
        IS_LAYOUT                     = GS_LAYO2         " Layout
      CHANGING
        IT_OUTTAB                     = GT_BOOK          " Output Table
        IT_FIELDCATALOG               = GT_FCAT2         " Field Catalog
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
        PROGRAM_ERROR                 = 2                " Program Errors
        TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BOOK
*&---------------------------------------------------------------------*
FORM CHECK_BOOK .

  DATA : LT_ROWS TYPE LVC_T_ROW,
         LS_ROWS TYPE LVC_S_ROW.

  CALL METHOD GO_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS.  " Indexes of Selected Rows

* Validation: 선택 라인 체크
  DESCRIBE TABLE LT_ROWS LINES DATA(LV_LINES).

  IF LV_LINES IS INITIAL.
    " 항목 미선택
    MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ELSEIF LV_LINES GT 1.
    " 여러 행 선택 시
    MESSAGE TEXT-E02 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF LS_ROWS-ROWTYPE IS NOT INITIAL.
    " 일반 행이 아닌 행 선택 시
    MESSAGE TEXT-E03 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  READ TABLE LT_ROWS INTO LS_ROWS INDEX 1.
  READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_ROWS-INDEX.

  IF GS_DISPLAY-ID IS NOT INITIAL.
    MESSAGE TEXT-E09 TYPE 'S' DISPLAY LIKE 'E'.  " 이미 대여된 도서입니다.
    RETURN.
  ENDIF.

  CALL SCREEN 0110 STARTING AT 5 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RENT_BOOK
*&---------------------------------------------------------------------*
FORM RENT_BOOK .

  DATA : LV_ISBN TYPE ZS4H088T03-ISBN,
         LV_SEQ  TYPE NUMC3.

* 정합성 체크를 위한 DATA SELECTION
  SELECT SINGLE ID,
                NAME
    FROM ZS4H088T04
    INTO @DATA(GS_USER)
    WHERE ID = @GV_ID.

  IF SY-SUBRC NE 0.
    MESSAGE |{ GV_ID }는 존재하지 않는 사용자 ID 입니다.| TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

* 고객 정보를 확인하기 위한 DATA SELECTION
*  SELECT SINGLE ID
*                NAME
*                BDAY
*                MAIL
*    FROM ZS4H088T04
*    INTO CORRESPONDING FIELDS OF ZS4H088T04
*    WHERE ID EQ GV_ID.
*
*  IF SY-SUBRC NE 0.
*    MESSAGE TEXT-E08 TYPE 'W' DISPLAY LIKE 'E'.  " 올바른 고객 ID를 입력해주세요.
*    RETURN.
*  ENDIF.

* 정합성 체크 : 대여권 수 체크하기
  SELECT ID,
         NAME,
         ISBN,
         TITLE,
         OVERDUE
    FROM @GT_DISPLAY AS G
   WHERE ID = @GV_ID
   INTO TABLE @DATA(GT_RECORD).

  DESCRIBE TABLE GT_RECORD LINES DATA(LV_RECORD).

  IF LV_RECORD GE 5.
    READ TABLE GT_RECORD INTO DATA(GS_RECORD) INDEX 1.
    MESSAGE | 사용자 { GS_RECORD-NAME } ({ GS_RECORD-ID })님의 대여한도가 초과 되었습니다. | TYPE 'W' DISPLAY LIKE 'E'..
    RETURN.
  ENDIF.

* 도서번호 별도 저장
  LV_ISBN = GS_DISPLAY-ISBN+0(13).
  LV_SEQ = GS_DISPLAY-ISBN+14(3).

* 정합성 체크: 연체 항목 체크 / 동일한 책 대여 여부 체크
  LOOP AT GT_RECORD INTO GS_RECORD.
    IF GS_RECORD-OVERDUE EQ 'X'.
      MESSAGE TEXT-E05 TYPE 'W' DISPLAY LIKE 'E'.  " 연체도서 반납 후 대여 가능합니다.
      RETURN.
    ENDIF.

    IF GS_RECORD-ISBN+0(13) = LV_ISBN.
      MESSAGE | 사용자 { GS_RECORD-NAME }님의 대여도서 { GS_RECORD-TITLE }이/가 미반납 상태입니다.| TYPE 'W' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  GET TIME STAMP FIELD ZS4H088T05-MSTIME.
  CONVERT TIME STAMP ZS4H088T05-MSTIME TIME ZONE SY-ZONLO INTO DATE ZS4H088T05-RDATE TIME ZS4H088T05-RTIME.
  ZS4H088T05-REDATE = ZS4H088T05-RDATE + 10.

*  ZS4H088T05-ID = ZS4H088T04-ID.
  ZS4H088T05-CODE = GS_DISPLAY-CODE.
  ZS4H088T05-ISBN = LV_ISBN.
  ZS4H088T05-SEQ = LV_SEQ.

  ZS4H088T05-ERDAT = SY-DATUM.
  ZS4H088T05-ERNAM = SY-UNAME.
  ZS4H088T05-ERZET = SY-UZEIT.

  INSERT ZS4H088T05 FROM ZS4H088T05.

  IF SY-SUBRC EQ 0.
    GS_DISPLAY-ID = ZS4H088T05-ID.

    SELECT SINGLE NAME
      FROM ZS4H088T04
      INTO GS_DISPLAY-NAME
      WHERE ID = GS_DISPLAY-ID.

    GS_DISPLAY-RDATE = ZS4H088T05-RDATE.

    MODIFY GT_DISPLAY FROM GS_DISPLAY TRANSPORTING ID NAME RDATE WHERE ISBN = GS_DISPLAY-ISBN.
    PERFORM REFRESH_ALV.

    MESSAGE '도서 대여에 성공했습니다.' TYPE 'S'.
  ELSE.
    MESSAGE '도서 대여에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    ROLLBACK WORK.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_BOOK
*&---------------------------------------------------------------------*
FORM RETURN_BOOK .

  DATA : LT_ROW     TYPE LVC_T_ROW,
         LS_ROW     TYPE LVC_S_ROW,
         LV_FIRST,
         LV_ID      TYPE ZS4H088T05-ID,
         LT_T05     TYPE TABLE OF ZS4H088T05,
         LT_DISPLAY TYPE TY_DISPLAY,
         LV_ANSWER.

  CALL METHOD GO_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.                 " Indexes of Selected Rows

  DESCRIBE TABLE LT_ROW LINES DATA(LV_LINES).

* Validation : 선택 항목 체크
  IF LV_LINES IS INITIAL.
    MESSAGE TEXT-E10 TYPE 'S' DISPLAY LIKE 'E'.  " 반납처리할 도서를 선택해주세요.
    RETURN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION         = '반납처리 하시겠습니까?'
      TEXT_BUTTON_1         = '예'
      TEXT_BUTTON_2         = '아니오'
      DISPLAY_CANCEL_BUTTON = 'X'
    IMPORTING
      ANSWER                = LV_ANSWER.

  IF LV_ANSWER = '1'.

    LOOP AT LT_ROW INTO LS_ROW.

*   VALIDATION : 일반행이 아닌 행 선택 여부 체크
      IF LS_ROW-ROWTYPE IS NOT INITIAL.
        MESSAGE TEXT-E03 TYPE 'S' DISPLAY LIKE 'E'.  " 일반 행을 선택해주세요.
        RETURN.
      ENDIF.

      READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_ROW-INDEX.
      APPEND GS_DISPLAY TO LT_DISPLAY.

    ENDLOOP.

    LOOP AT LT_DISPLAY INTO GS_DISPLAY.
*   Validation : 대여처리되지 않은 도서 선택 시
      IF GS_DISPLAY-ID IS INITIAL.
        MESSAGE TEXT-E11 TYPE 'S' DISPLAY LIKE 'E'.  " 대여된 도서만 선택해주세요.
        RETURN.
      ENDIF.

*   Validation : 대여자 체크
      IF LV_FIRST NE 'X'.
        LV_ID = GS_DISPLAY-ID.
        LV_FIRST = 'X'.
      ELSE.
        IF LV_ID NE GS_DISPLAY-ID.
          MESSAGE TEXT-E12 TYPE 'S' DISPLAY LIKE 'E'.  " 동일한 대여자의 도서만 처리 가능합니다.
          RETURN.
        ENDIF.
      ENDIF.

*   반납 처리
      UPDATE ZS4H088T05 SET REDATE2 = SY-DATUM WHERE ID = GS_DISPLAY-ID AND ISBN = GS_DISPLAY-ISBN+0(13).

      IF SY-SUBRC NE 0.
        MESSAGE TEXT-E13 TYPE 'S' DISPLAY LIKE 'E'.  " 반납처리에 실패했습니다.
        ROLLBACK WORK.
        RETURN.
      ELSE.
        CLEAR : GS_DISPLAY-ID,
                GS_DISPLAY-NAME,
                GS_DISPLAY-RDATE,
                GS_DISPLAY-OVERDUE,
                GS_DISPLAY-IT_COLFIELDS.

        MODIFY GT_DISPLAY FROM GS_DISPLAY TRANSPORTING ID NAME RDATE OVERDUE IT_COLFIELDS WHERE ISBN = GS_DISPLAY-ISBN.
        PERFORM REFRESH_ALV.
        MESSAGE TEXT-S01 TYPE 'S'.  " 반납처리되었습니다.
      ENDIF.

    ENDLOOP.

*    PERFORM SELECT_DATA.
*    PERFORM MODIFY_DATA.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
FORM SET_EVENT .

  IF GV_DIALOG IS INITIAL.
    CREATE OBJECT GO_EVENT.
    SET HANDLER GO_EVENT->ON_DOUBLE_CLICK FOR GO_ALV_GRID.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COLORIZE_ROW
*&---------------------------------------------------------------------*
FORM COLORIZE_ROW  USING PV_COLOR
                         PV_INTENSE
                         PV_INVERSE
                CHANGING PS_DISPLAY TYPE TS_DISPLAY.

  PS_DISPLAY-COLOR = 'C' && PV_COLOR && PV_INTENSE && PV_INVERSE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NAME
*&---------------------------------------------------------------------*
FORM CHECK_NAME.

  IF SO_NAME-LOW IS NOT INITIAL.
    " 사용자 명 조건이 입력된 경우에만 검사를 진행

    DATA : LV_INVALID TYPE I.
    LOOP AT SO_NAME INTO DATA(LS_NAME).

      " 값이 완성된 한글로만 되어 있는지 검사
      FIND REGEX '[^가-힣]' IN LS_NAME-LOW MATCH COUNT LV_INVALID.
      IF LV_INVALID > 0.
        MESSAGE '사용자명이 올바르지 않습니다.' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

      " 자음/모음 단독 검사
      CLEAR LV_INVALID.
      FIND REGEX '[ㄱ-ㅎㅏ-ㅣ]' IN LS_NAME-LOW MATCH COUNT LV_INVALID.
      IF LV_INVALID > 0.
        MESSAGE '사용자명이 올바르지 않습니다.' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.
