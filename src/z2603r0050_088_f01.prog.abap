*&---------------------------------------------------------------------*
*& Include          Z2603R0050_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM SET_SELECTION_SCREEN .

  S_DATE-LOW = SY-DATUM - 1.
  APPEND S_DATE.

  P_UNAM = 'FIX000'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SELECITON_SCREEN
*&---------------------------------------------------------------------*
FORM MODIFY_SELECITON_SCREEN .

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'P_UNAM'.
      SCREEN-INPUT = '0'.
      MODIFY SCREEN.
    ENDIF.

    IF P_SAV EQ ABAP_ON AND SCREEN-GROUP1 = 'M1'.
      SCREEN-INVISIBLE = '1'.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_TO_SAVE
*&---------------------------------------------------------------------*
FORM GET_DATA_TO_SAVE .

  DATA : LV_DURATION TYPE SYTABIX,
         LV_CNT      TYPE I.

*  "데이터 가져오기
  SELECT T1~JOBNAME	   AS TBTCO_JOBNAME   ,
         T1~JOBCOUNT   AS TBTCO_JOBCOUNT  ,
         T1~JOBGROUP   AS TBTCO_JOBGROUP  ,
         T1~INTREPORT	 AS TBTCO_INTREPORT ,
         T1~STEPCOUNT	 AS TBTCO_STEPCOUNT ,
         T1~SDLSTRTDT	 AS TBTCO_SDLSTRTDT ,
         T1~SDLSTRTTM	 AS TBTCO_SDLSTRTTM ,
         T1~BTCSYSTEM	 AS TBTCO_BTCSYSTEM ,
         T1~SDLDATE	   AS TBTCO_SDLDATE   ,
         T1~SDLTIME	   AS TBTCO_SDLTIME   ,
         T1~SDLUNAME   AS TBTCO_SDLUNAME  ,
         T1~LASTCHDATE AS TBTCO_LASTCHDATE,
         T1~LASTCHTIME AS TBTCO_LASTCHTIME,
         T1~LASTCHNAME AS TBTCO_LASTCHNAME,
         T1~RELDATE	   AS TBTCO_RELDATE   ,
         T1~RELTIME	   AS TBTCO_RELTIME   ,
         T1~RELUNAME 	 AS TBTCO_RELUNAME  ,
         T1~STRTDATE   AS TBTCO_STRTDATE  ,
         T1~STRTTIME 	 AS TBTCO_STRTTIME  ,
         T1~ENDDATE	   AS TBTCO_ENDDATE   ,
         T1~ENDTIME	   AS TBTCO_ENDTIME   ,
         T1~PRDMINS	   AS TBTCO_PRDMINS   ,
         T1~PRDHOURS   AS TBTCO_PRDHOURS  ,
         T1~PRDDAYS	   AS TBTCO_PRDDAYS   ,
         T1~PRDWEEKS   AS TBTCO_PRDWEEKS  ,
         T1~PRDMONTHS  AS TBTCO_PRDMONTHS ,
         T1~PERIODIC   AS TBTCO_PERIODIC  ,
         T1~DELANFREP  AS TBTCO_DELANFREP ,
         T1~EMERGMODE	 AS TBTCO_EMERGMODE ,
         T1~STATUS     AS TBTCO_STATUS    ,
         T1~NEWFLAG	   AS TBTCO_NEWFLAG   ,
         T1~AUTHCKNAM	 AS TBTCO_AUTHCKNAM ,
         T1~AUTHCKMAN	 AS TBTCO_AUTHCKMAN ,
         T1~SUCCNUM	   AS TBTCO_SUCCNUM   ,
         T1~PREDNUM	   AS TBTCO_PREDNUM   ,
         T1~JOBLOG     AS TBTCO_JOBLOG    ,
         T1~LASTSTRTDT AS TBTCO_LASTSTRTDT,
         T1~LASTSTRTTM AS TBTCO_LASTSTRTTM,
         T1~WPNUMBER   AS TBTCO_WPNUMBER  ,
         T1~WPPROCID 	 AS TBTCO_WPPROCID  ,
         T1~EVENTID	   AS TBTCO_EVENTID   ,
         T1~EVENTPARM	 AS TBTCO_EVENTPARM ,
         T1~BTCSYSREAX AS TBTCO_BTCSYSREAX,
         T1~JOBCLASS   AS TBTCO_JOBCLASS  ,
         T1~PRIORITY   AS TBTCO_PRIORITY  ,
         T1~EVENTCOUNT AS TBTCO_EVENTCOUNT,
         T1~CHECKSTAT	 AS TBTCO_CHECKSTAT ,
         T1~CALENDARID AS TBTCO_CALENDARID,
         T1~PRDBEHAV   AS TBTCO_PRDBEHAV  ,
         T1~EXECSERVER AS TBTCO_EXECSERVER,
         T1~EOMCORRECT AS TBTCO_EOMCORRECT,
         T1~CALCORRECT AS TBTCO_CALCORRECT,
         T1~REAXSERVER AS TBTCO_REAXSERVER,
         T1~RECLOGSYS	 AS TBTCO_RECLOGSYS ,
         T1~RECOBJTYPE AS TBTCO_RECOBJTYPE,
         T1~RECOBJKEY	 AS TBTCO_RECOBJKEY ,
         T1~RECDESCRIB AS TBTCO_RECDESCRIB,
         T1~TGTSRVGRP	 AS TBTCO_TGTSRVGRP ,
         T2~PROGNAME,
         T2~VARIANT
    FROM TBTCO AS T1
    LEFT OUTER JOIN TBTCP AS T2
      ON T1~JOBNAME   EQ T2~JOBNAME
     AND T1~JOBCOUNT  EQ T2~JOBCOUNT
     AND T1~STEPCOUNT EQ T2~STEPCOUNT
   WHERE T1~STRTDATE  IN @S_DATE
     AND T1~SDLUNAME  EQ @P_UNAM
    INTO CORRESPONDING FIELDS OF TABLE @GT_STAT.

  IF GT_STAT IS INITIAL.
    MESSAGE '저장할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  "STATTXT 지정
  LOOP AT GT_STAT INTO GS_STAT.

    IF GS_STAT-TBTCO_STATUS EQ 'A'.
      GS_STAT-STATTXT = 'Cancelled(Aborted)'.
    ELSEIF GS_STAT-TBTCO_STATUS EQ 'F'.
      GS_STAT-STATTXT = 'Completed(Finished)'.
    ELSEIF GS_STAT-TBTCO_STATUS EQ 'P'.
      GS_STAT-STATTXT = 'Scheduled'.
    ELSEIF GS_STAT-TBTCO_STATUS EQ 'R'.
      GS_STAT-STATTXT = 'Active(Runnung)'.
    ELSEIF GS_STAT-TBTCO_STATUS EQ 'S'.
      GS_STAT-STATTXT = 'Released'.
    ELSEIF GS_STAT-TBTCO_STATUS EQ 'Y'.
      GS_STAT-STATTXT = 'Ready'.
    ELSEIF GS_STAT-TBTCO_STATUS EQ 'X'.
      GS_STAT-STATTXT = 'Unknown_state'.
    ENDIF.

    "지연시간 계산 (실행-예정)
    CALL FUNCTION 'SWI_DURATION_DETERMINE'
      EXPORTING
        START_DATE = GS_STAT-TBTCO_SDLSTRTDT
        END_DATE   = GS_STAT-TBTCO_STRTDATE
        START_TIME = GS_STAT-TBTCO_SDLSTRTTM
        END_TIME   = GS_STAT-TBTCO_STRTTIME
      IMPORTING
        DURATION   = LV_DURATION.

    GS_STAT-DELAYTIME = LV_DURATION.
    CLEAR LV_DURATION.

    "실행시간 계산 (종료-시작)
    CALL FUNCTION 'SWI_DURATION_DETERMINE'
      EXPORTING
        START_DATE = GS_STAT-TBTCO_STRTDATE
        END_DATE   = GS_STAT-TBTCO_ENDDATE
        START_TIME = GS_STAT-TBTCO_STRTTIME
        END_TIME   = GS_STAT-TBTCO_ENDTIME
      IMPORTING
        DURATION   = LV_DURATION.

    GS_STAT-PLAYTIME = LV_DURATION.
    CLEAR LV_DURATION.

    "작업주기 계산
    IF GS_STAT-TBTCO_PERIODIC EQ SPACE.
      GS_STAT-PRDLEN = 'ONCE'.
    ELSEIF GS_STAT-TBTCO_PRDMINS   NE SPACE.
      GS_STAT-PRDLEN = GS_STAT-TBTCO_PRDMINS && ' MIN'.
    ELSEIF GS_STAT-TBTCO_PRDHOURS  NE SPACE.
      GS_STAT-PRDLEN = GS_STAT-TBTCO_PRDHOURS && ' HOUR'.
    ELSEIF GS_STAT-TBTCO_PRDWEEKS  NE SPACE.
      GS_STAT-PRDLEN = GS_STAT-TBTCO_PRDWEEKS && ' WEEK'.
    ELSEIF GS_STAT-TBTCO_PRDMONTHS NE SPACE.
      GS_STAT-PRDLEN = GS_STAT-TBTCO_PRDMONTHS && ' MONTH'.
    ELSEIF GS_STAT-TBTCO_PRDDAYS   NE SPACE.
      GS_STAT-PRDLEN = GS_STAT-TBTCO_PRDDAYS && ' DAYS'.
    ENDIF.

    "저장일자와, 저장시간, 타임스탬프 저장
    GS_STAT-ERDAT = SY-DATUM.
    GS_STAT-ERTIM = SY-UZEIT.
    GET TIME STAMP FIELD GS_STAT-TIMESTAMP.

    MODIFY GT_STAT FROM GS_STAT.
  ENDLOOP.

  "CBOTABLE에 저장
  MODIFY ZBCT0010 FROM TABLE GT_STAT.

  IF SY-SUBRC <> 0.
    MESSAGE '데이터 저장에 실패하였습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ELSE.
    "LV_CNT lines were uploaded.
    LV_CNT = LINES( GT_STAT ).
    MESSAGE |{ LV_CNT }건의 데이터를 저장하였습니다.| TYPE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CHECK
*&---------------------------------------------------------------------*
FORM POPUP_TO_CHECK .

  IF SY-DYNNR = 0110.
    DATA(LV_QUESTION) = '원인 및 조치사항을 저장하시겠습니까?'.
  ELSE.
    LV_QUESTION = '선택조건으로 데이터를 저장하시겠습니까?'.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '작업 확인'
      TEXT_QUESTION         = LV_QUESTION
      TEXT_BUTTON_1         = '예'
      TEXT_BUTTON_2         = '아니오'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = GV_FLAG
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF SY-SUBRC <> 0.
    MESSAGE 'POPUP ERROR' TYPE 'E'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_TO_DISPLAY
*&---------------------------------------------------------------------*
FORM GET_DATA_TO_DISPLAY .

  DATA : LT_STAT TYPE RANGE OF TBTCO-STATUS,
         LS_STAT LIKE LINE OF LT_STAT.

  IF P_FAIL = 'X' OR P_SUC = 'X'.
    LS_STAT-SIGN = 'I'.
    LS_STAT-OPTION = 'EQ'.

    CASE 'X'.
      WHEN P_FAIL. "실패
        LS_STAT-LOW = 'A'.
      WHEN P_SUC. "성공
        LS_STAT-LOW = 'F'.
    ENDCASE.

    APPEND LS_STAT TO LT_STAT.

  ELSEIF P_ETC = 'X'.
    " 기타일 경우 실패와 성공 제외
    LS_STAT-SIGN = 'E'.
    LS_STAT-OPTION = 'EQ'.
    LS_STAT-LOW = 'A'.
    APPEND LS_STAT TO LT_STAT.
    CLEAR LS_STAT.

    LS_STAT-SIGN = 'E'.
    LS_STAT-OPTION = 'EQ'.
    LS_STAT-LOW = 'F'.
    APPEND LS_STAT TO LT_STAT.

  ENDIF.

  SELECT T1~TBTCO_JOBNAME,
         T1~TBTCO_STEPCOUNT,
         T1~TBTCO_SDLUNAME,
         T1~TBTCO_STATUS,
         T1~STATTXT,
         T2~REMARK AS DETAIL,
         T1~TBTCO_SDLDATE,
         T1~TBTCO_SDLTIME,
         T1~TBTCO_LASTCHDATE,
         T1~TBTCO_LASTCHTIME,
         T1~TBTCO_RELDATE,
         T1~TBTCO_RELTIME,
         T1~TBTCO_SDLSTRTDT,
         T1~TBTCO_SDLSTRTTM,
         T1~TBTCO_STRTDATE,
         T1~TBTCO_STRTTIME,
         T1~DELAYTIME,
         T1~TBTCO_ENDDATE,
         T1~TBTCO_ENDTIME,
         T1~PLAYTIME,
         T1~PROGNAME,
         T1~VARIANT,
         T1~PRDLEN,
         T1~TBTCO_JOBCOUNT,
         T1~ERDAT,
         T1~ERTIM,
         T1~TIMESTAMP
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
    FROM ZBCT0010 AS T1
    LEFT OUTER JOIN ZBCT0020 AS T2
      ON T1~TBTCO_JOBNAME = T2~JOBNAME
     AND T1~TBTCO_JOBCOUNT = T2~JOBCOUNT
     AND T1~TBTCO_STEPCOUNT = T2~STEPCOUNT
     AND T1~TIMESTAMP = T2~TIMESTAMP
     AND T2~SEQ = 1
     AND T1~TBTCO_STATUS = 'A'
   WHERE T1~TBTCO_STRTDATE   IN @S_DATE
     AND T1~TBTCO_JOBNAME    IN @S_JNAME
     AND T1~PROGNAME         IN @S_PNAME
     AND T1~TBTCO_STATUS     IN @LT_STAT
   ORDER BY TBTCO_STRTDATE, TBTCO_STRTTIME ASCENDING.

  GV_LINES = LINES( GT_LIST ).

  LOOP AT GT_LIST INTO GS_LIST.

    IF GS_LIST-TBTCO_STATUS = 'A'. "
      "실패한 데이터에만 한해서 아이콘 지정
      IF GS_LIST-DETAIL IS INITIAL.
        "조치사항 내역이 없을 경우
        GS_LIST-REMARK = ICON_ADD_ROW.
      ELSE.
        "조치사항 내역이 있을 경우
        GS_LIST-REMARK = ICON_MESSAGE_ERROR_SMALL.
      ENDIF.

    ENDIF.

    MODIFY GT_LIST FROM GS_LIST.
    CLEAR : GS_LIST.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  IF SY-DYNNR = 0100.

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

  ELSEIF SY-DYNNR  = 0110.

    CREATE OBJECT GO_CUSTOM
      EXPORTING
        CONTAINER_NAME              = 'CON1'           " Name of the Screen CustCtrl Name to Link Container To
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
        I_PARENT          = GO_CUSTOM        " Parent Container
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
*& Form SET_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO .

  IF SY-DYNNR = 0100.

    GS_LAYO-CWIDTH_OPT = 'X'.
    GS_LAYO-ZEBRA = 'X'.
    GS_LAYO-SEL_MODE = 'D'.

  ELSEIF SY-DYNNR = 0110.

    GS_LAYO2-CWIDTH_OPT = 'X'.
    GS_LAYO2-ZEBRA = 'X'.
    GS_LAYO2-SEL_MODE = 'D'.
    GS_LAYO2-STYLEFNAME = 'CELLTAB'.

  ENDIF.

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT .

  IF SY-DYNNR = 0100.
    PERFORM SET_FIELDCAT_0100.
  ELSEIF SY-DYNNR = 0110.
    PERFORM SET_FIELDCAT_0110.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  IF SY-DYNNR = 0100.

    CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT       " Layout
        I_SAVE                        = GV_SAVE          " Save Layout
        IS_LAYOUT                     = GS_LAYO          " Layout
      CHANGING
        IT_OUTTAB                     = GT_LIST          " Output Table
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

  ELSEIF SY-DYNNR = 0110.

    CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT       " Layout
        I_SAVE                        = GV_SAVE          " Save Layout
        IS_LAYOUT                     = GS_LAYO2         " Layout
      CHANGING
        IT_OUTTAB                     = GT_JOB           " Output Table
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
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV USING PO_ALV_GRID  TYPE REF TO CL_GUI_ALV_GRID
                       PS_LAYO      TYPE LVC_S_LAYO.
  CALL METHOD PO_ALV_GRID->REFRESH_TABLE_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
FORM SET_TEXT  USING PV_FIELDNAME
            CHANGING PV_COLTEXT.

  CASE PV_FIELDNAME.
    WHEN 'TBTCO_JOBNAME'.    PV_COLTEXT = '작업내역'.
    WHEN 'TBTCO_STEPCOUNT'.  PV_COLTEXT = '단계번호'.
    WHEN 'TBTCO_SDLUNAME'.   PV_COLTEXT = '작업생성자'.
    WHEN 'TBTCO_STATUS'.     PV_COLTEXT = '상태'.
    WHEN 'STATTXT'.          PV_COLTEXT = '상태 내역'.
    WHEN 'REMARK'.           PV_COLTEXT = '원인 및 조치사항'.
    WHEN 'DETAIL'.           PV_COLTEXT = '최근 조치사항'.
    WHEN 'TBTCO_SDLDATE'.    PV_COLTEXT = '작업일정 계획일자'.
    WHEN 'TBTCO_SDLTIME'.    PV_COLTEXT = '작업일정 계획시간'.
    WHEN 'TBTCO_LASTCHDATE'. PV_COLTEXT = '최종변경 일자'.
    WHEN 'TBTCO_LASTCHTIME'. PV_COLTEXT = '최종변경 시간'.
    WHEN 'TBTCO_RELDATE'.    PV_COLTEXT = '릴리즈 일자'.
    WHEN 'TBTCO_RELTIME'.    PV_COLTEXT = '릴리즈 시간'.
    WHEN 'TBTCO_SDLSTRTDT'.  PV_COLTEXT = '예정된시작 일자'.
    WHEN 'TBTCO_SDLSTRTTM'.  PV_COLTEXT = '예정된시작 시간'.
    WHEN 'TBTCO_STRTDATE'.   PV_COLTEXT = '실행시작 일자'.
    WHEN 'TBTCO_STRTTIME'.   PV_COLTEXT = '실행시작 시간'.
    WHEN 'DELAYTIME'.        PV_COLTEXT = '지연시간'.
    WHEN 'TBTCO_ENDDATE'.    PV_COLTEXT = '실행종료 일자'.
    WHEN 'TBTCO_ENDTIME'.    PV_COLTEXT = '실행종료 시간'.
    WHEN 'PLAYTIME'.         PV_COLTEXT = '실행시간'.
    WHEN 'PROGNAME'.         PV_COLTEXT = '프로그램'.
    WHEN 'VARIANT'.          PV_COLTEXT = '변형'.
    WHEN 'PRDLEN'.           PV_COLTEXT = '작업주기'.
    WHEN 'TBTCO_JOBCOUNT'.   PV_COLTEXT = '작업번호'.
    WHEN 'ERDAT'.            PV_COLTEXT = '저장일자'.
    WHEN 'ERTIM'.            PV_COLTEXT = '저장시간'.
    WHEN 'TIMESTAMP'.        PV_COLTEXT = '타임스탬프'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING P_ROW    TYPE LVC_S_ROW
                               P_COLUMN TYPE LVC_S_COL
                               P_ROW_NO TYPE LVC_S_ROID.

  CASE P_COLUMN-FIELDNAME.
    WHEN 'REMARK'.

      READ TABLE GT_LIST INTO GS_LIST INDEX P_ROW_NO-ROW_ID.
      IF SY-SUBRC = 0 AND GS_LIST-TBTCO_STATUS = 'A'.
        PERFORM GET_JOBLOG USING P_ROW_NO-ROW_ID.
        CALL SCREEN 110 STARTING AT 1 1.
        PERFORM GET_DATA_TO_DISPLAY.
        PERFORM REFRESH_ALV USING GO_ALV_GRID GS_LAYO.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING       P_DATA_CHANGED
                   TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               P_ONF4
                               P_ONF4_BEFORE
                               P_ONF4_AFTER
                               P_UCOMM.

  DATA : LS_MODI TYPE LVC_S_MODI,
         LV_ROW  TYPE I.

  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MODI.

    "변경한 행 번호
    LV_ROW = LS_MODI-ROW_ID.

    IF LS_MODI-FIELDNAME = 'REMARK'.

      IF LS_MODI-VALUE IS NOT INITIAL.
        GV_FLAG = ABAP_TRUE.

        READ TABLE GT_JOB INTO DATA(LS_DATA) INDEX LV_ROW.
        LS_DATA-REMARK = LS_MODI-VALUE.
      ENDIF.
    ENDIF.

    MODIFY GT_JOB FROM LS_DATA INDEX LV_ROW.

  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_ALV_GRID2
                   CHANGING GS_LAYO2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JOBLOG
*&---------------------------------------------------------------------*
FORM GET_JOBLOG  USING P_ROW_NO.

  DATA : LV_CELL TYPE LVC_S_STYL.

  CLEAR : GT_JOB.
  READ TABLE GT_LIST INTO GS_LIST INDEX P_ROW_NO.

  SELECT *
    FROM ZBCT0020
   WHERE JOBNAME   = @GS_LIST-TBTCO_JOBNAME
     AND JOBCOUNT  = @GS_LIST-TBTCO_JOBCOUNT
     AND STEPCOUNT = @GS_LIST-TBTCO_STEPCOUNT
     AND TIMESTAMP = @GS_LIST-TIMESTAMP
   ORDER BY SEQ ASCENDING
    INTO CORRESPONDING FIELDS OF TABLE @GT_JOB.

  LV_CELL-FIELDNAME = 'REMARK'.
  LV_CELL-STYLE     =  CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

  LOOP AT GT_JOB ASSIGNING FIELD-SYMBOL(<FS_JOB>).
    INSERT LV_CELL INTO TABLE <FS_JOB>-CELLTAB.
  ENDLOOP.

  CLEAR : GS_JOB.
  GS_JOB-JOBNAME   = GS_LIST-TBTCO_JOBNAME.
  GS_JOB-JOBCOUNT  = GS_LIST-TBTCO_JOBCOUNT.
  GS_JOB-STEPCOUNT = GS_LIST-TBTCO_STEPCOUNT.
  GS_JOB-TIMESTAMP = GS_LIST-TIMESTAMP.

  DESCRIBE TABLE GT_JOB LINES GS_JOB-SEQ.
  GS_JOB-SEQ += 1.

  LV_CELL-FIELDNAME = 'REMARK'.
  LV_CELL-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
  INSERT LV_CELL INTO TABLE GS_JOB-CELLTAB.
  APPEND GS_JOB TO GT_JOB.
  CLEAR : GS_JOB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .

  SET HANDLER LCL_EVENT_HANDLER=>ON_DOUBLE_CLICK FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100 .

  DATA : LO_TABLE TYPE REF TO CL_ABAP_TABLEDESCR,
         LO_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_COMP  TYPE ABAP_COMPDESCR_TAB,
         LS_COMP  LIKE LINE OF LT_COMP.

  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_LIST ).
  LO_STRUC ?= LO_TABLE->GET_TABLE_LINE_TYPE( ).
  LT_COMP = LO_STRUC->COMPONENTS[].

  GT_FCAT = CORRESPONDING #( CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC )
                             MAPPING KEY       = KEYFLAG
                                     COLTEXT   = FIELDTEXT
                                     REF_TABLE = REFTABLE
                                     REF_FIELD = REFFIELD
                                     CFIELDNAME = PRECFIELD
                                     QFIELDNAME = PRECFIELD ).

  LOOP AT GT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).

    PERFORM SET_TEXT USING <LS_FCAT>-FIELDNAME
                  CHANGING <LS_FCAT>-COLTEXT.

    <LS_FCAT>-COL_POS = SY-TABIX.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.

    CASE <LS_FCAT>-FIELDNAME.
**********************************************************************
* Key
**********************************************************************
      WHEN 'TBTCO_JOBNAME' OR 'TBTCO_STEPCOUNT' OR 'TBTCO_SDLUNAME' OR 'TBTCO_STATUS' OR 'STATTXT'.
        <LS_FCAT>-KEY        = 'X'.
**********************************************************************
* 색상
**********************************************************************
      WHEN 'TBTCO_STRTDATE' OR 'TBTCO_STRTTIME' OR 'DELAYTIME'.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'TBTCO_ENDDATE' OR 'TBTCO_ENDTIME' OR 'PLAYTIME'.
        <LS_FCAT>-EMPHASIZE = 'C310'.
      WHEN 'TBTCO_JOBNAME' OR 'TBTCO_STEPCOUNT' OR 'TBTCO_SDLUNAME ' OR 'TBTCO_STATUS' OR 'STATTXT'.
        <LS_FCAT>-EMPHASIZE = 'C410'.
      WHEN 'PROGNAME' OR 'VARIANT' OR 'PRDLEN' OR 'TBTCO_JOBCOUNT'.
        <LS_FCAT>-EMPHASIZE = 'C410'.
**********************************************************************
* 버튼
**********************************************************************
      WHEN 'REMARK'.
        <LS_FCAT>-JUST = 'C'.
*        <LS_FCAT>-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0110
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0110 .

  DATA : LO_TABLE TYPE REF TO CL_ABAP_TABLEDESCR,
         LO_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_COMP  TYPE ABAP_COMPDESCR_TAB,
         LS_COMP  LIKE LINE OF LT_COMP.

  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_JOB ).
  LO_STRUC ?= LO_TABLE->GET_TABLE_LINE_TYPE( ).
  LT_COMP = LO_STRUC->COMPONENTS[].

  GT_FCAT2 = CORRESPONDING #( CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC )
                             MAPPING KEY       = KEYFLAG
                                     COLTEXT   = FIELDTEXT
                                     REF_TABLE = REFTABLE
                                     REF_FIELD = REFFIELD
                                     CFIELDNAME = PRECFIELD
                                     QFIELDNAME = PRECFIELD ).

  LOOP AT GT_FCAT2 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).

    PERFORM SET_TEXT USING <LS_FCAT>-FIELDNAME
                  CHANGING <LS_FCAT>-COLTEXT.

    <LS_FCAT>-COL_POS = SY-TABIX.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'REMARK'.
        <LS_FCAT>-EDIT = 'X'.
      WHEN 'MANDT' OR 'JOBNAME' OR 'STEPCOUNT' OR 'JOBCOUNT' OR 'TIMESTAMP'.
        <LS_FCAT>-NO_OUT = 'X'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0110
*&---------------------------------------------------------------------*
FORM SET_EVENT_0110 .

  SET HANDLER LCL_EVENT_HANDLER=>DATA_CHANGED FOR GO_ALV_GRID2.

ENDFORM.
