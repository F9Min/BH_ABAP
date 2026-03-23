*&---------------------------------------------------------------------*
*& Include          Z2603R0010_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM GET_DATA.

  DATA : LR_DATE      TYPE RANGE OF SY-DATUM,
         LS_DATE      LIKE LINE OF LR_DATE,
         LV_CONDITION TYPE CHAR100. " 동적 조건의 길이 차이에 따라 길이가 긴 경우 잘릴 수 있으므로 사전에 선언하여 방지

  GV_START_DATE = |{ S_DATE-LOW }01|.

  LS_DATE-LOW = GV_START_DATE.
  LS_DATE-OPTION = 'BT'.
  LS_DATE-SIGN = 'I'.

  IF S_DATE-HIGH IS NOT INITIAL.
    " HIGH에 값이 있는 경우 해당 월의 마지막날을 최대로 지정
    GV_END_DATE = |{ S_DATE-HIGH }01|.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = GV_END_DATE      " Key date
      IMPORTING
        LAST_DAY_OF_MONTH = GV_END_DATE      " Date of last day of the month from key  date
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1                " Key date is no date
        OTHERS            = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    " HIGH에 값이 없는 경우 LOW 월의 마지막 날을 최대로 지정
    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = GV_START_DATE    " Key date
      IMPORTING
        LAST_DAY_OF_MONTH = GV_END_DATE      " Date of last day of the month from key  date
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1                " Key date is no date
        OTHERS            = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

  IF GV_END_DATE IS NOT INITIAL.

    LS_DATE-HIGH = GV_END_DATE.
    APPEND LS_DATE TO LR_DATE.

  ENDIF.

  IF P_CANC EQ 'X'.
    LV_CONDITION = |C~CANCELLED = 'X'|.
  ELSEIF P_CONF EQ 'X'.
    LV_CONDITION = |C~CANCELLED = ' '|.
  ENDIF.

  SELECT
    FROM SPFLI AS A
    JOIN SCARR AS B
      ON A~CARRID = B~CARRID
    JOIN SBOOK AS C
      ON A~CARRID = C~CARRID
     AND A~CONNID = C~CONNID
  FIELDS A~CARRID
       , B~CARRNAME
       , C~FLDATE
       , COUNT( * ) AS COUNT
   WHERE A~CARRID   IN @S_ID
     AND B~CARRNAME IN @S_NAME
     AND C~FLDATE   IN @LR_DATE
     AND (LV_CONDITION)
    GROUP BY A~CARRID, B~CARRNAME, C~FLDATE
    ORDER BY A~CARRID, C~FLDATE
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  " SUM과 AVG 계산 : 이후 LOOP 문 내부에서 다시 계산을 하는 것보다 SELECT와 쿼리를 통해 계산해서 들고 있는 것이 더 낫다.
  DATA(LV_DATE) = GV_END_DATE - GV_START_DATE.

  SELECT A~CARRID,
         B~CARRNAME,
         COUNT( * ) AS SUM,
         DIV( COUNT( * ), @LV_DATE ) AS AVG
    FROM SPFLI AS A
    JOIN SCARR AS B
      ON A~CARRID = B~CARRID
    JOIN SBOOK AS C
      ON A~CARRID = C~CARRID
     AND A~CONNID = C~CONNID
   WHERE A~CARRID   IN @S_ID
     AND B~CARRNAME IN @S_NAME
     AND C~FLDATE   IN @LR_DATE
     AND (LV_CONDITION)
    GROUP BY A~CARRID, B~CARRNAME
    ORDER BY A~CARRID
    INTO CORRESPONDING FIELDS OF TABLE @GT_CAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF GT_DATA IS INITIAL.
    MESSAGE '출력할 데이터가 존재하지 않습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.


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

  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT            = GO_DOCKING         " Parent Container
      ROWS              = 2                  " Number of Rows to be displayed
      COLUMNS           = 1                  " Number of Columns to be Displayed
    EXCEPTIONS
      CNTL_ERROR        = 1                  " See Superclass
      CNTL_SYSTEM_ERROR = 2                  " See Superclass
      OTHERS            = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_SPLITTER->GET_CONTAINER  " SPLITTER로 분할한 화면에 CONTAINER 할당
    EXPORTING
      ROW       = 1                       " Row
      COLUMN    = 1                       " Column
    RECEIVING
      CONTAINER = GO_CONTAINER1.          " Container

  CALL METHOD GO_SPLITTER->GET_CONTAINER  " SPLITTER로 분할한 화면에 CONTAINER 할당
    EXPORTING
      ROW       = 2                       " Row
      COLUMN    = 1                       " Column
    RECEIVING
      CONTAINER = GO_CONTAINER2.          " Container

  CREATE OBJECT GO_ALV_GRID1
    EXPORTING
      I_PARENT          = GO_CONTAINER1    " Parent Container
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

  CREATE OBJECT GO_ALV_GRID2
    EXPORTING
      I_PARENT          = GO_CONTAINER2    " Parent Container
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
  GS_LAYO-CTAB_FNAME = 'COLOR'.

  GS_VARIANT-REPORT = SY-CPROG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO_DETAILI
*&---------------------------------------------------------------------*
FORM SET_LAYO_DETAIL .

  GS_LAYO_DETAIL-CWIDTH_OPT = 'X'.
  GS_LAYO_DETAIL-ZEBRA = 'X'.
  GS_LAYO_DETAIL-SEL_MODE = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT CHANGING PT_FCAT TYPE LVC_T_FCAT.

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
*  LV_COL_POS = 10.  " LV_COL_POS 삭제( 이후부터 )

  IF GT_DETAIL IS INITIAL.
    " 더블클릭 이벤트를 통해 GT_DETAIL에 데이터가 SELECT 된 경우
    " 하단 ALV의 FCAT을 생성
    PERFORM SET_FIELD_CATALOG USING : 'CARRID' ABAP_ON '항공사코드' 'SPFLI' 'CARRID' CHANGING LV_COL_POS PT_FCAT,
                                      'CARRNAME' ABAP_ON '항공사명' 'SCARR' 'CARRNAME' CHANGING LV_COL_POS PT_FCAT.

    " 날짜에 맞춰 동적으로 FCAT 생성
    DATA(LV_DATE) = GV_START_DATE.

    WHILE LV_DATE <= GV_END_DATE.

      DATA(LV_FNAME) = |D{ LV_DATE }|.
      DATA(LV_TEXT) = |{ LV_DATE+(4) }.{ LV_DATE+4(2) }.{ LV_DATE+6(2) }|.
      PERFORM SET_FIELD_CATALOG USING : LV_FNAME SPACE LV_TEXT SPACE SPACE CHANGING LV_COL_POS PT_FCAT.

      LV_DATE += 1.

    ENDWHILE.

    PERFORM SET_FIELD_CATALOG USING : 'SUM' SPACE '합계' SPACE SPACE CHANGING LV_COL_POS PT_FCAT,
                                      'AVG' SPACE '평균' SPACE SPACE CHANGING LV_COL_POS PT_FCAT,
                                      'COLOR' SPACE SPACE SPACE SPACE CHANGING LV_COL_POS PT_FCAT.

    PERFORM CRAETE_DYNAMIC_ITAB.
    PERFORM SET_DYNAMIC_ITAB.

  ELSE.

    PERFORM SET_FIELD_CATALOG USING : 'BOOKID' ABAP_ON '항공사코드' 'SBOOK' 'BOOKID' CHANGING LV_COL_POS PT_FCAT,
                                      'CUSTOMID' ABAP_ON '고객번호' 'SBOOK' 'CUSTOMID' CHANGING LV_COL_POS PT_FCAT,
                                      'CUSTTYPE' ABAP_ON '항공사명' 'SBOOK' 'CUSTTYPE' CHANGING LV_COL_POS PT_FCAT,
                                      'ORDER_DATE' SPACE '예약일' 'SBOOK' 'ORDER_DATE' CHANGING LV_COL_POS PT_FCAT,
                                      'INVOICE' SPACE '송장표시' 'SBOOK' 'INVOICE' CHANGING LV_COL_POS PT_FCAT,
                                      'LOCCURAM' SPACE '현지통화 예약가격' 'SBOOK' 'LOCCURAM' CHANGING LV_COL_POS PT_FCAT,
                                      'LOCCURKEY' SPACE '현지통화' 'SBOOK' 'LOCCURKEY' CHANGING LV_COL_POS PT_FCAT,
                                      'CANCELLED' SPACE '취소여부' 'SBOOK' 'CANCELLED' CHANGING LV_COL_POS PT_FCAT.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .

  SET HANDLER LCL_EVENT=>HANDLE_DOUBLE_CLICK FOR GO_ALV_GRID1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  CALL METHOD GO_ALV_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
      IS_LAYOUT                     = GS_LAYO                 " Layout
    CHANGING
      IT_OUTTAB                     = <GT_ALV>                 " Output Table
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .
  CALL METHOD GO_ALV_GRID1->REFRESH_TABLE_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG USING PV_FIELDNAME
                             PV_KEY
                             PV_COLTEXT
                             PV_REF_TABLE
                             PV_REF_FIELD
                    CHANGING PV_COL_POS
                             PT_FCAT TYPE LVC_T_FCAT.

  DATA(LS_FCAT) = VALUE LVC_S_FCAT( FIELDNAME = PV_FIELDNAME
                                  KEY = PV_KEY
                                  COL_POS = PV_COL_POS
                                  COLTEXT = PV_COLTEXT
                                  REF_TABLE = PV_REF_TABLE
                                  REF_FIELD = PV_REF_FIELD
                                 ).
  CASE PT_FCAT.
    WHEN GT_FCAT.

      IF PV_FIELDNAME+(1) = 'D'.

        LS_FCAT-DATATYPE = 'INT4'.

      ELSEIF PV_FIELDNAME = 'COLOR'.

        LS_FCAT-NO_OUT = 'X'.
        LS_FCAT-DATATYPE = 'TTYP'.
        LS_FCAT-REF_TABLE = 'LVC_T_SCOL'.

      ENDIF.

    WHEN GT_FCAT_DETAIL.

      CASE PV_FIELDNAME.
        WHEN 'LOCCURAM'.
          LS_FCAT-CFIELDNAME = 'LOCCURKEY'.
      ENDCASE.

  ENDCASE.

  APPEND LS_FCAT TO PT_FCAT.
  PV_COL_POS += 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRAETE_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
FORM CRAETE_DYNAMIC_ITAB .

*  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
*    EXPORTING
*      IT_FIELDCATALOG           = GT_FCAT          " Field Catalog
*    IMPORTING
*      EP_TABLE                  = GT_DISPLAY       " Pointer to Dynamic Data Table
*    EXCEPTIONS
*      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
*      OTHERS                    = 2.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  DATA: LT_COMP   TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE, " 구조체의 각 칸(필드)들을 모아둘 테이블
        LS_COMP   LIKE LINE OF LT_COMP,                      " 구조체의 한 칸(필드)
        LO_STRUCT TYPE REF TO CL_ABAP_STRUCTDESCR,           " 완성된 구조체 객체
        LO_TABLE  TYPE REF TO CL_ABAP_TABLEDESCR.            " 완성된 테이블 객체

  LOOP AT GT_FCAT INTO DATA(LS_FCAT).
    CLEAR LS_COMP.
    LS_COMP-NAME = LS_FCAT-FIELDNAME.

    " 메모리 타입을 지정
    IF LS_FCAT-FIELDNAME = 'COLOR'.
      " 셀 색상 필드는 LVC_T_SCOL으로 지정.
      LS_COMP-TYPE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( 'LVC_T_SCOL' ).

    ELSEIF LS_FCAT-REF_TABLE IS NOT INITIAL AND LS_FCAT-REF_FIELD IS NOT INITIAL.
      " DDIC 참조가 있는 필드
      DATA(LV_FNAME) = |{ LS_FCAT-REF_TABLE }-{ LS_FCAT-REF_FIELD }|.
      LS_COMP-TYPE ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_NAME( LV_FNAME ).

    ELSEIF LS_FCAT-DATATYPE = 'INT4'.
      " 정수형 필드
      LS_COMP-TYPE = CL_ABAP_ELEMDESCR=>GET_I( ).

    ELSE.
      " 참조할 대상이 없는 경우
      LS_COMP-TYPE ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_NAME( 'CHAR30' ).
    ENDIF.

    " 필드 정보를 하나의 ITAB에 담기
    APPEND LS_COMP TO LT_COMP.
  ENDLOOP.

  " 필드 정보를 기반으로 STRUCTURE 생성
  LO_STRUCT = CL_ABAP_STRUCTDESCR=>CREATE( P_COMPONENTS = LT_COMP ).

  " STRUCTURE를 기반으로 ITAB 생성
  LO_TABLE = CL_ABAP_TABLEDESCR=>CREATE( P_LINE_TYPE = LO_STRUCT ).

  " GT_DISPLAY 생성
  CREATE DATA GT_DISPLAY TYPE HANDLE LO_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
FORM SET_DYNAMIC_ITAB .
**********************************************************************
* 휴일 데이터 가지고 있는 ITAB 세팅
**********************************************************************
  SELECT
    FROM THOC
  FIELDS DATUM
   WHERE IDENT = 'KR'
     AND DATUM GE @GV_START_DATE
     AND DATUM LE @GV_END_DATE
    INTO TABLE @DATA(LT_HOLI).
**********************************************************************
* 동적 ITAB 값 세팅
**********************************************************************
  DATA : LS_COLOR TYPE LVC_S_SCOL.

  ASSIGN GT_DISPLAY->* TO <GT_ALV>.

  LOOP AT GT_DATA INTO DATA(LS_DATA).
    " <GT_ALV>에 현재 CARRID 가 이미 존재하는지 확인
    READ TABLE <GT_ALV> ASSIGNING <GS_ALV> WITH KEY ('CARRID') = LS_DATA-CARRID.

    IF SY-SUBRC <> 0.
      " 존재하지 않는 경우 신규 빈 행을 추가
      APPEND INITIAL LINE TO <GT_ALV> ASSIGNING <GS_ALV>.
      " 고정값 매핑
      ASSIGN COMPONENT 'CARRID' OF STRUCTURE <GS_ALV> TO <GV_ALV>.
      <GV_ALV> = LS_DATA-CARRID.

      ASSIGN COMPONENT 'CARRNAME' OF STRUCTURE <GS_ALV> TO <GV_ALV>.
      <GV_ALV> = LS_DATA-CARRNAME.

    ENDIF.
    " 날짜별 Count 동적 매핑
    DATA(LV_FNAME) = |D{ LS_DATA-FLDATE }|.
    ASSIGN COMPONENT LV_FNAME OF STRUCTURE <GS_ALV> TO <GV_ALV>.

    IF SY-SUBRC = 0.
      <GV_ALV> = LS_DATA-COUNT.
    ENDIF.
    " 합계 및 평균 작성
    READ TABLE GT_CAL INTO DATA(LS_CAL) WITH KEY CARRID = LS_DATA-CARRID
                                                 CARRNAME = LS_DATA-CARRNAME.
    IF SY-SUBRC EQ 0.
      " 합계
      ASSIGN COMPONENT 'SUM' OF STRUCTURE <GS_ALV> TO <GV_ALV>.
      IF SY-SUBRC EQ 0.
        <GV_ALV> = LS_CAL-SUM.
      ENDIF.
      " 평균
      ASSIGN COMPONENT 'AVG' OF STRUCTURE <GS_ALV> TO <GV_ALV>.
      IF SY-SUBRC EQ 0.
        <GV_ALV> = LS_CAL-AVG.
      ENDIF.

    ENDIF.
*    ASSIGN COMPONENT 'SUM' OF STRUCTURE <GS_ALV> TO <GV_ALV>.
*    <GV_ALV> += LS_DATA-COUNT.

    " 셀 색상
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE <GS_ALV> TO <GV_COLOR>.
    LS_COLOR-FNAME = 'AVG'.
    LS_COLOR-COLOR-COL = 3.
    LS_COLOR-COLOR-INT = 1.
    LS_COLOR-COLOR-INV = 0.
    INSERT LS_COLOR INTO TABLE <GV_COLOR>.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE <GS_ALV> TO <GV_COLOR>.
    LS_COLOR-FNAME = 'SUM'.
    LS_COLOR-COLOR-COL = 3.
    LS_COLOR-COLOR-INT = 1.
    LS_COLOR-COLOR-INV = 0.
    INSERT LS_COLOR INTO TABLE <GV_COLOR>.

    READ TABLE LT_HOLI INTO DATA(LS_HOLI) WITH KEY DATUM = LS_DATA-FLDATE.

    IF SY-SUBRC EQ 0.

      ASSIGN COMPONENT 'COLOR' OF STRUCTURE <GS_ALV> TO <GV_COLOR>.
      LS_COLOR-FNAME = |D{ LS_DATA-FLDATE }|.
      LS_COLOR-COLOR-COL = 5.
      LS_COLOR-COLOR-INT = 1.
      LS_COLOR-COLOR-INV = 0.
      INSERT LS_COLOR INTO TABLE <GV_COLOR>.

    ENDIF.

  ENDLOOP.
**********************************************************************
* 평균값 계산
**********************************************************************
*  DATA(LV_DATE_COUNT) = GV_END_DATE - GV_START_DATE.
*
*  LOOP AT <GT_ALV> ASSIGNING <GS_ALV>.
*
*    ASSIGN COMPONENT 'SUM' OF STRUCTURE <GS_ALV> TO FIELD-SYMBOL(<GV_SUM>).
*    ASSIGN COMPONENT 'AVG' OF STRUCTURE <GS_ALV> TO FIELD-SYMBOL(<GV_AVG>).
*
*    IF SY-SUBRC = 0 AND LV_DATE_COUNT > 0.
*
*      <GV_AVG> = ROUND( VAL = <GV_SUM> / LV_DATE_COUNT
*                        DEC = 0
*                        MODE = CL_ABAP_MATH=>ROUND_HALF_UP
*                       ).
*
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM ALV_HANDLE_DOUBLE_CLICK  USING    P_COLUMN TYPE LVC_S_COL
                                       P_ROW_NO TYPE LVC_S_ROID.

  IF P_COLUMN+(1) NE 'D'.
    MESSAGE '올바른 열을 클릭해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA(LV_DATE) = P_COLUMN+1(8).
  READ TABLE <GT_ALV> ASSIGNING FIELD-SYMBOL(<GS_ALV>) INDEX P_ROW_NO-ROW_ID.
  ASSIGN COMPONENT P_COLUMN OF STRUCTURE <GS_ALV> TO <GV_ALV>.

  IF <GV_ALV> IS INITIAL.
    MESSAGE '데이터가 있는 셀을 더블클릭 해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  ASSIGN COMPONENT 'CARRID' OF STRUCTURE <GS_ALV> TO <GV_ALV>.

  IF P_CANC EQ 'X'.
    DATA(LV_CONDITION) = |CANCELLED = 'X'|.
  ELSEIF P_CONF EQ 'X'.
    LV_CONDITION = |CANCELLED = ' '|.
  ENDIF.

  CLEAR : GT_DETAIL.

  SELECT
    FROM SBOOK
  FIELDS BOOKID
       , CUSTOMID
       , CUSTTYPE
       , ORDER_DATE
       , INVOICE
       , LOCCURAM
       , LOCCURKEY
       , CANCELLED
   WHERE CARRID EQ @<GV_ALV>
     AND FLDATE EQ @LV_DATE
     AND (LV_CONDITION)
   ORDER BY CANCELLED, BOOKID
    INTO CORRESPONDING FIELDS OF TABLE @GT_DETAIL.

  IF GT_FCAT_DETAIL IS INITIAL.
    PERFORM SET_FIELDCAT CHANGING GT_FCAT_DETAIL.
  ENDIF.

  IF GS_LAYO_DETAIL IS INITIAL.
    PERFORM SET_LAYO_DETAIL.
  ENDIF.

  PERFORM DISPLAY_DETAIL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DETAIL
*&---------------------------------------------------------------------*
FORM DISPLAY_DETAIL .

  CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE          " Save Layout
      IS_LAYOUT                     = GS_LAYO_DETAIL   " Layout
    CHANGING
      IT_OUTTAB                     = GT_DETAIL        " Output Table
      IT_FIELDCATALOG               = GT_FCAT_DETAIL   " Field Catalog
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
