*&---------------------------------------------------------------------*
*& Include          ZS4H088R01_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA USING PV_DIALOG
                       PS_DISPLAY TYPE TS_DISPLAY.

  DATA : LT_DATA  TYPE TY_DATA,
         LT_WHERE TYPE STRING.

  IF PV_DIALOG IS INITIAL.
    " DIALOG가 아닌 MAIN TABLE의 출력인 경우
    " 누가 얼마나 빌렸는지, 현재 빌리고 있는지 파악하기 위한 Data Selection
    SELECT T04~ID,         " ID, NAME, MAIL : 누가 빌리고 있는지 확인하기 위한 개인정보
           T04~BDAY,
           T04~NAME,
           T04~MAIL,
           T05~RDATE,      " 반납일 : 존재하지 않는 경우 현재 대여 중
           T05~REDATE2     " 반납일 : 존재하지 않는 경우 현재 대여 중
      FROM ZS4H088T04 AS T04
      LEFT OUTER JOIN ZS4H088T05 AS T05
      ON T05~ID EQ T04~ID
      INTO CORRESPONDING FIELDS OF TABLE @LT_DATA
      WHERE T04~NAME IN @SO_NAME
        AND T04~ID   IN @SO_ID.

    " DISPLAY 용 DATA로 가공하기 위한 Subroutine
    PERFORM MODIFY_DATA USING LT_DATA.

  ELSEIF PV_DIALOG EQ 'C' OR PV_DIALOG EQ 'T'.
    " Dialog 출력인 경우
    DATA : LV_SEQ TYPE NUMC3.

    IF PV_DIALOG EQ 'C'.
      LT_WHERE = |T05~REDATE2 IS INITIAL|.
    ENDIF.

    CLEAR : GT_LIST.

    SELECT T02~TITLE,
           T03~ISBN,
           T03~SEQ,
           T05~ID,
           T05~RDATE,
           T05~REDATE2
      FROM ZS4H088T05 AS T05
      JOIN ZS4H088T03 AS T03
        ON T05~CODE = T03~CODE AND T05~ISBN = T03~ISBN AND T05~SEQ = T03~SEQ
      JOIN ZS4H088T02 AS T02
        ON T02~CODE = T03~CODE AND T02~ISBN = T03~ISBN
     WHERE T05~ID = @GS_DISPLAY-ID
       AND (LT_WHERE)
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

    LOOP AT GT_LIST INTO DATA(LS_LIST).
      LV_SEQ = LS_LIST-SEQ.
      LS_LIST-ISBN_SEQ = LS_LIST-ISBN && '-' && LV_SEQ.

      MODIFY GT_LIST FROM LS_LIST.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
FORM MODIFY_DATA USING PT_DATA TYPE TY_DATA.

  DATA : LV_CURRENT   TYPE INT4 VALUE 0,
         LV_TOTAL     TYPE INT4 VALUE 0,
         LV_ID_RECORD TYPE ZS4H088T04-ID,
         LV_ID_NOW    TYPE ZS4H088T04-ID,
         LV_RECORDED. " 사용자 ID를 처음 접했는지 기록하기 위한 변수

  FIELD-SYMBOLS : <FS> TYPE TS_DATA.

  SORT PT_DATA BY ID. " 사용자 ID를 기준으로 현재 대여권수와 총 대여권수를 세기 위해 SORT 진행

  LOOP AT PT_DATA ASSIGNING <FS>.
    IF LV_RECORDED NE ABAP_ON.
      " 현재 사용자 ID에 대한 최초 시행인 경우
      CLEAR : GS_DISPLAY.
      MOVE-CORRESPONDING <FS> TO GS_DISPLAY.
      " ID를 최초로 감지했을 경우 기록용 LOCAL VARIABLE에 기록
      LV_ID_RECORD = <FS>-ID.
      LV_RECORDED = ABAP_ON.
    ENDIF.

    " 현재 레코드의 ID를 LOCAL VARIABLE에 기록
    LV_ID_NOW = <FS>-ID.

    IF LV_ID_RECORD EQ LV_ID_NOW AND <FS>-RDATE IS NOT INITIAL.
      " 기록 ID와 현재 레코드의 ID가 같은 경우 : 동일한 사용자에 대한 카운팅을 진행 중임을 의미함.
      " [ RDATE : 대여일 ]이 존재하는 경우에만 대여를 의미하기 때문에 이하 소스코드 블록이 유효함.
      LV_TOTAL += 1.  " 전체 대여권수는 무조건 카운팅
      IF <FS>-REDATE2 IS INITIAL.
        LV_CURRENT += 1.
      ENDIF.
    ELSEIF LV_ID_RECORD NE LV_ID_NOW.
      " 기록 ID와 현재 레코드의 ID가 서로 다른 경우 : 기존에 카운팅 중이던 사용자와 다른 사용자임을 의미함.
      " 현재 카운팅을 진행하고 있는 사용자 정보를 GS_DISPLAY에 저장
      GS_DISPLAY-CURRENT = LV_CURRENT.            " 사용자의 현재 대여권 수를 저장
      GS_DISPLAY-TOTAL = LV_TOTAL.                " 사용자의 총 대여권 수를 저장
      APPEND GS_DISPLAY TO GT_DISPLAY.

      " 변수 초기화
      LV_CURRENT = LV_TOTAL = 0.
      LV_ID_NOW = LV_ID_RECORD = LV_RECORDED = SPACE.

      IF LV_RECORDED NE ABAP_ON.
        " LOOP가 진행 중이며 ID가 바뀌었을 때의 후속 트랜잭션
        CLEAR : GS_DISPLAY.
        MOVE-CORRESPONDING <FS> TO GS_DISPLAY.
        " 변수가 초기화 되었으므로 현재 레코드에 대한 기록을 다시 진행
        LV_ID_RECORD = <FS>-ID.
        LV_RECORDED = ABAP_ON.
      ENDIF.

      IF GS_DISPLAY-RDATE IS NOT INITIAL.
        " [ RDATE : 대여일 ]이 존재하는 경우에만 대여를 의미하기 때문에 이하 소스코드 블록이 유효함.
        LV_TOTAL += 1.  " 전체 대여권수는 무조건 카운팅
        IF <FS>-REDATE2 IS INITIAL.
          LV_CURRENT += 1.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF LV_RECORDED EQ 'X'.
    GS_DISPLAY-CURRENT = LV_CURRENT.            " 사용자의 현재 대여권 수를 저장
    GS_DISPLAY-TOTAL = LV_TOTAL.                " 사용자의 총 대여권 수를 저장
    APPEND GS_DISPLAY TO GT_DISPLAY.
  ENDIF.

  UNASSIGN <FS>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF GT_DISPLAY IS NOT INITIAL.
    " 표시할 데이터가 존재할 경우에만 CALL SCREEN.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE TEXT-E06 TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

*  CREATE OBJECT GO_CONTAINER
*    EXPORTING
*      CONTAINER_NAME              = 'CCON'                 " Name of the Screen CustCtrl Name to Link Container To
*    EXCEPTIONS
*      CNTL_ERROR                  = 1                " CNTL_ERROR
*      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
*      CREATE_ERROR                = 3                " CREATE_ERROR
*      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
*      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
*      OTHERS                      = 6.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  IF GV_DIALOG IS INITIAL.

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

  ELSE.

    CREATE OBJECT GO_DIALOG_CUSTOM
      EXPORTING
        CONTAINER_NAME              = 'CCON'                 " Name of the Screen CustCtrl Name to Link Container To
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
        I_PARENT          = GO_DIALOG_CUSTOM  " Parent Container
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
*& Form set_layout
*&---------------------------------------------------------------------*
FORM SET_LAYOUT .

  GS_LAYO-CWIDTH_OPT = 'A'.
  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-SEL_MODE = 'D'.

  IF GV_DIALOG IS INITIAL.
    GS_LAYO-INFO_FNAME = 'COLOR'.
  ENDIF.

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
FORM SET_FCAT USING GV_DIALOG.

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR: LV_COL_POS.
  LV_COL_POS = 10.

  IF GV_DIALOG IS INITIAL.

    PERFORM SET_FIELD_CATALOG USING 'ID'      ABAP_ON '사용자 ID'        'ZS4H088T04' 'ID'
                           CHANGING LV_COL_POS GT_FCAT.

    PERFORM SET_FIELD_CATALOG USING 'NAME'    SPACE   '사용자 명'        'ZS4H088T04' 'NAME'
                           CHANGING LV_COL_POS GT_FCAT.

    PERFORM SET_FIELD_CATALOG USING 'MAIL'    SPACE   '전자메일'         'ZS4H088T04' 'MAIL'
                           CHANGING LV_COL_POS GT_FCAT.

    PERFORM SET_FIELD_CATALOG USING 'CURRENT' SPACE   '대여중인 도서 수' SPACE         SPACE
                           CHANGING LV_COL_POS GT_FCAT.

    PERFORM SET_FIELD_CATALOG USING 'TOTAL'   SPACE   '전체 대여도서 수' SPACE         SPACE
                           CHANGING LV_COL_POS GT_FCAT.

  ELSE.

    PERFORM SET_FIELD_CATALOG USING 'ISBN_SEQ'   ABAP_ON   '도서번호' SPACE         SPACE
                           CHANGING LV_COL_POS GT_FCAT2.

    PERFORM SET_FIELD_CATALOG USING 'TITLE'   SPACE   '도서명' SPACE         SPACE
                           CHANGING LV_COL_POS GT_FCAT2.

    PERFORM SET_FIELD_CATALOG USING 'RDATE'   SPACE   '대여일' SPACE         SPACE
                           CHANGING LV_COL_POS GT_FCAT2.

    PERFORM SET_FIELD_CATALOG USING 'REDATE2'   SPACE   '반납일' SPACE         SPACE
                           CHANGING LV_COL_POS GT_FCAT2.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG  USING    PV_FIELDNAME
                                 PV_KEY
                                 PV_COLTEXT
                                 PV_REF_TABLE
                                 PV_REF_FIELD
                        CHANGING PV_COL_POS
                                 PT_FCAT TYPE LVC_T_FCAT.

* 기존 PT_FCAT 테이블에 새로운 필드 카탈로그 항목 추가
  PT_FCAT[] = VALUE #( BASE PT_FCAT[] ( FIELDNAME   = PV_FIELDNAME
                                        KEY         = PV_KEY
                                        COL_POS     = PV_COL_POS
                                        COLTEXT     = PV_COLTEXT
                                        REF_TABLE   = PV_REF_TABLE
                                        REF_FIELD   = PV_REF_FIELD
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
        IS_VARIANT                    = GS_VARIANT        " Layout
        I_SAVE                        = GV_SAVE           " Save Layout
        IS_LAYOUT                     = GS_LAYO           " Layout
      CHANGING
        IT_OUTTAB                     = GT_DISPLAY        " Output Table
        IT_FIELDCATALOG               = GT_FCAT           " Field Catalog
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
        PROGRAM_ERROR                 = 2                " Program Errors
        TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.

    CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT        " Layout
        I_SAVE                        = GV_SAVE           " Save Layout
        IS_LAYOUT                     = GS_LAYO           " Layout
      CHANGING
        IT_OUTTAB                     = GT_LIST           " Output Table
        IT_FIELDCATALOG               = GT_FCAT2          " Field Catalog
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
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV USING PV_DIALOG.

  DATA : LS_STBL TYPE LVC_S_STBL.
  LS_STBL-COL = 'X'.
  LS_STBL-ROW = 'X'.

  IF PV_DIALOG IS INITIAL.

    CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STBL          " With Stable Rows/Columns
      EXCEPTIONS
        FINISHED  = 1                " Display was Ended (by Export)
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.

    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STBL          " With Stable Rows/Columns
      EXCEPTIONS
        FINISHED  = 1                " Display was Ended (by Export)
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN USING PV_COMP.

  CASE ABAP_ON.
    WHEN PA_CRT.
      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'M01'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ROW
*&---------------------------------------------------------------------*
FORM GET_ROW .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_DISPLAY
*&---------------------------------------------------------------------*
FORM UPDATE_DISPLAY  USING    PV_ID
                     CHANGING PT_DISPLAY TYPE TY_DISPLAY.

  SELECT SINGLE T04~ID
                T04~BDAY
                T04~NAME
                T04~MAIL
                T05~RDATE
                T05~REDATE2
               FROM ZS4H088T04 AS T04
    LEFT OUTER JOIN ZS4H088T05 AS T05
      ON T04~ID = T05~ID
    INTO CORRESPONDING FIELDS OF GS_DISPLAY
    WHERE T04~ID EQ PV_ID.

  GS_DISPLAY-CURRENT = 0.
  GS_DISPLAY-TOTAL = 0.

  CASE ABAP_ON.
    WHEN PA_CRT.
      APPEND GS_DISPLAY TO GT_DISPLAY.
    WHEN PA_MOD.
      MODIFY GT_DISPLAY FROM GS_DISPLAY TRANSPORTING NAME BDAY MAIL WHERE ID = PV_ID.
  ENDCASE.

  SORT GT_DISPLAY BY ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_SELECT_OPTIONS
*&---------------------------------------------------------------------*
FORM CLEAR_SELECT_OPTIONS .

  CASE ABAP_ON.
    WHEN PA_CRT.
      " 생성 모드일 경우 SELECT OPTION에 부여된 조건이 적용되지 않도록 CLEAR를 해준다.
      IF SO_ID IS NOT INITIAL.
        CLEAR : SO_ID, SO_ID[].
      ENDIF.

      IF SO_NAME IS NOT INITIAL.
        CLEAR : SO_NAME, SO_NAME[].
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDELR
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDELR .

  CREATE OBJECT GO_EVENT.
  SET HANDLER GO_EVENT->ON_DOUBLE_CLICK FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NAME1
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
