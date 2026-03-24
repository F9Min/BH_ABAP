*&---------------------------------------------------------------------*
*& Include          MZCC_SD010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INITIAL
*&---------------------------------------------------------------------*
FORM SET_INITIAL .

  P_GJAHR = P_GJAHR2 = SY-DATUM+0(4) - 1.
  GV_TITLE = SY-TITLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM MODIFY_SELECTION_SCREEN .

* 검색조건 숨기기 기능 활성화
  CHECK ( SY-DYNNR EQ '1100' AND GV_HIDE01 IS NOT INITIAL )
     OR ( SY-DYNNR EQ '1200' AND GV_HIDE02 IS NOT INITIAL ) .

  LOOP AT SCREEN.
    SCREEN-ACTIVE = 0.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module FILL_TABSTRIP_DYNNR OUTPUT
*&---------------------------------------------------------------------*
MODULE FILL_TABSTRIP_DYNNR OUTPUT.

  CLEAR : GV_TABTYPE.
  CASE TS-ACTIVETAB.
    WHEN 'FC1'.
      DYNNR = '110'.
      GV_TABTYPE = GC_PERFORM.
    WHEN 'FC2'.
      DYNNR = '120'.
      GV_TABTYPE = GC_PLAN.
    WHEN OTHERS.
      DYNNR = '110'.
      GV_TABTYPE = GC_PERFORM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA_PERFORMANCE
*&---------------------------------------------------------------------*
FORM SELECT_DATA_PERFORMANCE .

  CLEAR : GT_DATA1.

  IF OK_CODE EQ 'CRET_MULTI'.
    " 계획다건생성의 경우 실행 년도의 전년도 판매실적을 무조건 가져와야한다.
    " POPUP 출력을 통해 판매계획이 초기화 됨을 안내하며 사용 방법을 명시한다.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TITEL     = '알림'
        TEXTLINE1 = '작년 판매실적을 기반으로 올해 판매계획이 설정됩니다.'
        TEXTLINE2 = '판매계획을 모두 세운 경우 상단의 저장 버튼을 통해 저장해주세요.'.

    " 작년 판매 실적을 통해 올해 판매계획을 세우기 위한 DATA SELECITON
    " 올해 년도를 기준으로 작년 한 해동안 수금까지 완료된 일반 주문을 SELECT 해야한다.
    DATA : LV_LAST_YEAR TYPE NUMC2.
    LV_LAST_YEAR = CONV I( SY-DATUM+2(2) ) - 1.

    SELECT A~VBELN,                                    " 판매오더번호
           A~AUART,                                    " 판매오더유형
           A~VKBUR,                                    " 영업장
           A~KUNNR,                                    " 고객ID
           A~STATUS,                                   " 판매오더상태
           A~ERDAT,                                    " 생산 날짜
           B~MATNR,                                    " 자재번호
           B~SPART,                                    " 제품군
           B~KWMENG,                                   " 주문수량
           B~MEINS,                                    " 단위
           B~NETWR_IT,                                 " 아이템 별 순금액
           B~WAERS                                     " 통화단위
      FROM ZCC_VBAK AS A
      JOIN ZCC_VBAP AS B
        ON A~VBELN = B~VBELN
     WHERE A~STATUS EQ 'ED'                            " 수금완료 상태인 판매오더
       AND A~AUART  EQ 'NO'                            " 일반주문에 한하여 Select
       AND SUBSTRING( A~VBELN, 3, 2 ) EQ @LV_LAST_YEAR " 작년도 판매오더
       INTO CORRESPONDING FIELDS OF TABLE @GT_DATA1.

  ELSE.
    " 계획다건생성 외의 일반조희의 경우 조회조건을 적용해 SELECT를 진행해야한다.
    DATA : LR_GJAHR TYPE RANGE OF NUMC2,
           LS_GJAHR LIKE LINE OF LR_GJAHR,
           LR_MONAT TYPE RANGE OF NUMC2,
           LS_MONAT LIKE LINE OF LR_MONAT.

    " 판매년도의 경우 비워질 경우 모든 년도의 데이터를 가져오기 위해 RANGE 변수를 통해 SELECT-OPTION과 동일하게 WHERE 조건을 적용한다.
    LR_GJAHR[] = VALUE #( ( SIGN = 'I' OPTION ='EQ' LOW = P_GJAHR ) ).

    SELECT A~VBELN,                                    " 판매오더번호
           A~AUART,                                    " 판매오더유형
           A~VKBUR,                                    " 영업장
           A~KUNNR,                                    " 고객ID
           A~STATUS,                                   " 판매오더상태
           A~ERDAT,                                    " 생산 날짜
           B~MATNR,                                    " 자재번호
           B~SPART,                                    " 제품군
           B~KWMENG,                                   " 주문수량
           B~MEINS,                                    " 단위
           B~NETWR_IT,                                 " 아이템 별 순금액
           B~WAERS                                     " 통화단위
     FROM ZCC_VBAK AS A
     JOIN ZCC_VBAP AS B
     ON A~VBELN = B~VBELN
     WHERE A~STATUS EQ 'ED'                             " 수금완료 상태인 판매오더
      AND A~AUART   EQ 'NO'                             " 일반주문에 한하여 Select
      AND SUBSTRING( A~VBELN, 5, 2 ) IN @SO_MONAT       " 판매년도
      AND A~VKBUR   IN @SO_VKBUR                        " 영업장
      AND A~KUNNR   IN @SO_KUNNR                        " 고객ID
      AND A~VBELN   IN @SO_VBELN                        " 판매오더번호
      AND SUBSTRING( A~VBELN, 3, 2 ) IN @LR_GJAHR       " 판매월
      AND B~SPART   IN @SO_SPART                        " 제품군
      AND B~MATNR   IN @SO_MATNR                        " 자재번호
     INTO CORRESPONDING FIELDS OF TABLE @GT_DATA1.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

* 사용자가 조회버튼을 여러 번 누를 경우 지속적으로 값이 누적되는 것을 방지하기 위해 CLEAR 진행
  CLEAR : GT_DISPLAY1.

  DATA : LV_YEAR  TYPE NUMC4,
         " 자재명을 가져오기 위한 LOCAL VARIABLE
         LT_MAKT  TYPE TABLE OF ZCC_MAKT,
         LS_MAKT  TYPE ZCC_MAKT,
         " 제품군명을 가져오기 위한 LOCAL VARIABLE
         LT_DD07T LIKE TABLE OF DD07T,
         LS_DD07T TYPE DD07T.

  FIELD-SYMBOLS <FS_MONTH> TYPE ZCC_VBAP-KWMENG.

* 자재명 SELECT
  SELECT MATNR
         SPRAS
         MAKTG
    INTO CORRESPONDING FIELDS OF TABLE LT_MAKT
    FROM ZCC_MAKT
    WHERE SPRAS EQ SY-LANGU.

  SORT LT_MAKT BY MATNR.

* 제품군명 SELECT
  SELECT DOMNAME
         DDLANGUAGE
         AS4LOCAL
         VALPOS
         AS4VERS
         DDTEXT
         DOMVAL_LD
         DOMVAL_HD
         DOMVALUE_L
    INTO CORRESPONDING FIELDS OF TABLE LT_DD07T
    FROM DD07T
    WHERE DOMNAME EQ 'ZCC_SPART'
      AND DDLANGUAGE EQ SY-LANGU
      AND AS4LOCAL EQ 'A'.

  SORT LT_DD07T BY DOMVALUE_L.

* GT_DATA1에 담겨있는 판매실적 데이터를 사용자가 보기 편한 형태로 가공
  LOOP AT GT_DATA1 INTO GS_DATA1.

    CLEAR : GS_DISPLAY1.

    MOVE-CORRESPONDING GS_DATA1 TO GS_DISPLAY1.

    " 년도 정보는 판매오더번호의 일부에 담겨있는 정보이므로 익숙한 형태로 가공한다.
    CONCATENATE '20' GS_DATA1-VBELN+2(2) INTO LV_YEAR.
    GS_DISPLAY1-PLAN_YEAR = LV_YEAR.
    GS_DISPLAY1-MEINS = GS_DATA1-MEINS.  " 단위 정보

    " 판매실적을 올바른 월에 넣기 위한 작업.
    DATA(LV_FIELD_NAME) = |GS_DISPLAY1-KWMENG_{ GS_DATA1-VBELN+4(2) }|.
    ASSIGN (LV_FIELD_NAME) TO <FS_MONTH>.
    <FS_MONTH> = GS_DATA1-KWMENG.
    UNASSIGN <FS_MONTH>.

    " 제품군에 따른 제품군명을 FIXED VALUE를 참조하여 보여주기 위해 DATA SELECTION 을 진행한다
    READ TABLE LT_DD07T INTO LS_DD07T WITH KEY DOMVALUE_L = GS_DISPLAY1-SPART BINARY SEARCH.  " BINARY SEARCH 활용
    GS_DISPLAY1-SPART_TXT = LS_DD07T-DDTEXT.

    " 로그온 언어에 맞는 제품명을 보여주기 위해 자재명 테이블에서 자재코드에 맞는 자재명을 가져온다.
    READ TABLE LT_MAKT INTO LS_MAKT WITH KEY MATNR = GS_DISPLAY1-MATNR BINARY SEARCH.  " BINARY SEARCH 활용
    GS_DISPLAY1-MAKTG = LS_MAKT-MAKTG.

    " 동일한 KEY 값( 영업장, 판매년도, 판매월, 자재번호 등 )을 가지고 있는 경우에는 COLLECT를 통해 누계를 진행하도록 함.
    COLLECT GS_DISPLAY1 INTO GT_DISPLAY1.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA_PLAN
*&---------------------------------------------------------------------*
FORM SELECT_DATA_PLAN .

  CLEAR : GT_DATA2.

* 검색 조건에 따라 Data Selection
  SELECT MATNR
         SPLAN
         VKBUR
         PLAN_YEAR
         PLAN_MONTH
         SPART
         VBBEZ
         MEINS
         STATUS
    FROM ZCC_VBBS
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA2
    WHERE PLAN_YEAR  EQ P_GJAHR2                   " 계획년도
      AND SPLAN      IN SO_VBEL2                   " 판매계획번호
      AND PLAN_MONTH IN SO_MONA2                   " 계획월
      AND VKBUR      IN SO_VKBU2                   " 영업장
      AND MATNR      IN SO_MATN2.                  "자재번호

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_PLAN_DATA
*&---------------------------------------------------------------------*
FORM MODIFY_PLAN_DATA .

* 사용자가 조회버튼을 여러 번 누를 경우 지속적으로 값이 누적되는 것을 방지하기 위해 CLEAR 진행
  CLEAR : GT_DISPLAY2.

  DATA : LT_MAKT  TYPE TABLE OF ZCC_MAKT,  " 자재명을 가져오기 위한 LOCAL VARIABLE
         LS_MAKT  TYPE ZCC_MAKT,
         LT_DD07T LIKE TABLE OF DD07T,     " 제품군명을 가져오기 위한 LOCAL VARIABLE
         LS_DD07T TYPE DD07T.

  FIELD-SYMBOLS <FS_MONTH> TYPE ZCC_VBBS-VBBEZ.

* 자재명 SELECT
  SELECT MATNR
         SPRAS
         MAKTG
    INTO CORRESPONDING FIELDS OF TABLE LT_MAKT
    FROM ZCC_MAKT
    WHERE SPRAS EQ SY-LANGU.

  SORT LT_MAKT BY MATNR.

* 제품군명 SELECT
  SELECT DOMNAME
         DDLANGUAGE
         AS4LOCAL
         VALPOS
         AS4VERS
         DDTEXT
         DOMVAL_LD
         DOMVAL_HD
         DOMVALUE_L
    INTO CORRESPONDING FIELDS OF TABLE LT_DD07T
    FROM DD07T
    WHERE DOMNAME EQ 'ZCC_SPART'
      AND DDLANGUAGE EQ SY-LANGU
      AND AS4LOCAL EQ 'A'.

  SORT LT_DD07T BY DOMVALUE_L.

* 작년도 판매계획을 가져오기 위한 LOCAL VARIABLE 선언
  DATA : BEGIN OF LS_VBBS,
           VKBUR      TYPE ZCC_VBBS-VKBUR,      " 영업장
           PLAN_YEAR  TYPE ZCC_VBBS-PLAN_YEAR,  " 계획 년도
           PLAN_MONTH TYPE ZCC_VBBS-PLAN_MONTH, " 계획월
           MATNR      TYPE ZCC_VBBS-MATNR,      " 자재번호
           VBBEZ      TYPE ZCC_VBBS-VBBEZ,      " 계획 수량
         END OF LS_VBBS,
         LT_VBBS      LIKE TABLE OF LS_VBBS,
         LV_LAST_YEAR TYPE NUMC4.

  " 계획생성(다건)의 경우
  LV_LAST_YEAR = CONV I( SY-DATUM+0(4) ) - 1.

  SELECT VKBUR       " 영업장
         PLAN_YEAR   " 계획 년도
         PLAN_MONTH  " 계획월
         MATNR       " 자재번호
         VBBEZ       " 계획 수량
    INTO CORRESPONDING FIELDS OF TABLE LT_VBBS
    FROM ZCC_VBBS
    WHERE PLAN_YEAR EQ LV_LAST_YEAR.  " 작년의 판매계획을 가져옴.

  SORT LT_VBBS BY VKBUR PLAN_MONTH MATNR.

  SELECT  MATNR,
          VKBUR,
          PLAN_YEAR,
          PLAN_MONTH,
          SUM( VBBEZ ) AS VBBEZ
     FROM @GT_DATA2 AS T
    GROUP BY MATNR, VKBUR, PLAN_YEAR, PLAN_MONTH
     INTO TABLE @DATA(LT_SUM).

  CLEAR : GT_KPI.
* GT_DATA2에 담겨있는 올해 판매계획 데이터( = 작년 1년 전 판매실적 )를 사용자가 보기 편한 형태로 가공
  LOOP AT GT_DATA2 INTO ZCC_VBBS.
*&---------------------------------------------------------------------*
* GT_DATA2에 담겨있는 판매실적을 통해 KPI를 계산한다.
*&---------------------------------------------------------------------*
    CLEAR LS_VBBS.
    READ TABLE LT_VBBS INTO LS_VBBS WITH KEY VKBUR      = ZCC_VBBS-VKBUR
                                             PLAN_MONTH = ZCC_VBBS-PLAN_MONTH
                                             MATNR      = ZCC_VBBS-MATNR
                                             BINARY SEARCH.

    IF LS_VBBS-VBBEZ NE 0.
      GS_KPI-VKBUR = LS_VBBS-VKBUR.
      GS_KPI-MATNR = LS_VBBS-MATNR.
      GS_KPI-PLAN_YEAR = LS_VBBS-PLAN_YEAR.
      GS_KPI-PLAN_MONTH = LS_VBBS-PLAN_MONTH.
      GS_KPI-KPI = ZCC_VBBS-VBBEZ * 100 / LS_VBBS-VBBEZ.  " (작년) 판매실적 * 100 / (작년) 판매계획

      APPEND GS_KPI TO GT_KPI.
    ENDIF.

*&---------------------------------------------------------------------*
* GT_DATA2에 담겨있는 판매실적을 DISPLAY를 위한 GT_DISPLAY2로 변형
*&---------------------------------------------------------------------*
    CLEAR : GS_DISPLAY2.
    MOVE-CORRESPONDING ZCC_VBBS TO GS_DISPLAY2.

    DATA(LV_FIELD_NAME) = |GS_DISPLAY2-KWMENG_{ ZCC_VBBS-PLAN_MONTH }|.
    ASSIGN (LV_FIELD_NAME) TO <FS_MONTH>.

    <FS_MONTH> = ZCC_VBBS-VBBEZ.
    UNASSIGN <FS_MONTH>.

    " 제품군에 따른 제품군명을 FIXED VALUE를 참조하여 보여주기 위해 DATA SELECTION 을 진행한다
    READ TABLE LT_DD07T INTO LS_DD07T WITH KEY DOMVALUE_L = GS_DISPLAY2-SPART BINARY SEARCH.  " BINARY SEARCH 활용
    GS_DISPLAY2-SPART_TXT = LS_DD07T-DDTEXT.

    " 로그온 언어에 맞는 제품명을 보여주기 위해 자재명 테이블에서 자재코드에 맞는 자재명을 가져온다.
    READ TABLE LT_MAKT INTO LS_MAKT WITH KEY MATNR = GS_DISPLAY2-MATNR BINARY SEARCH.  " BINARY SEARCH 활용
    GS_DISPLAY2-MAKTG = LS_MAKT-MAKTG.

    " 동일한 KEY 값( 영업장, 판매년도, 판매월, 자재번호 등 )을 가지고 있는 경우에는 COLLECT를 통해 누계를 진행하도록 함.
    COLLECT GS_DISPLAY2 INTO GT_DISPLAY2.

  ENDLOOP.

  SORT GT_KPI BY VKBUR MATNR PLAN_YEAR PLAN_MONTH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MULTI_PLAN
*&---------------------------------------------------------------------*
FORM CREATE_MULTI_PLAN .

* 판매실적 데이터를 가져온다.
  PERFORM SELECT_DATA_PERFORMANCE.
* 판매실적 데이터를 GT_DISPLAY1 데이터의 형태로 가공한다.
  PERFORM MODIFY_DATA.

  SELECT MATNR
         SPLAN
         VKBUR
         PLAN_YEAR
         PLAN_MONTH
         SPART
         VBBEZ
         MEINS
         STATUS
         PFLAG
    FROM ZCC_VBBS
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA2
    WHERE PLAN_YEAR EQ SY-DATUM+0(4).

  IF GT_DATA2 IS INITIAL.
    " 올해의 판매계획이 아직 없는 경우 작년 판매실적을 기반으로 올해 판매계획을 세우기 위한 SUBROUTINE
    PERFORM CREATE_DATA2.
  ENDIF.

* 판매실적을 기반으로 세운 판매계획을 월별로 쪼갬
  PERFORM MODIFY_PLAN_DATA.
* 월별로 쪼갠 데이터를 월 기반으로 STYLE 적용
  PERFORM MODIFY_STYLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module FILL_SUBSCREEN_DYNNR OUTPUT
*&---------------------------------------------------------------------*
MODULE FILL_SUBSCREEN_DYNNR OUTPUT.

  CASE SY-DYNNR.
    WHEN '0110'.
      DYNNR = '1100'.
    WHEN '0120'.
      DYNNR = '1200'.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN_0110 OUTPUT.

  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'GV_COLL01'.
        IF GV_HIDE01 IS NOT INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN 'GV_EXPAND01'.
        IF GV_HIDE01 IS INITIAL.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  CASE SY-DYNNR.
    WHEN '0110'.
      CREATE OBJECT GO_CUSTOM1
        EXPORTING
          CONTAINER_NAME              = 'CCON1'          " Name of the Screen CustCtrl Name to Link Container To
        EXCEPTIONS
          CNTL_ERROR                  = 1                " CNTL_ERROR
          CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
          CREATE_ERROR                = 3                " CREATE_ERROR
          LIFETIME_ERROR              = 4                " LIFETIME_ERROR
          LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
          OTHERS                      = 6.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I070 DISPLAY LIKE 'E'. " CNTL_ERROR
          WHEN 2.
            MESSAGE I071 DISPLAY LIKE 'E'. " CNTL_SYSTEM_ERROR
          WHEN 3.
            MESSAGE I072 DISPLAY LIKE 'E'. " CREATE_ERROR
          WHEN 4.
            MESSAGE I073 DISPLAY LIKE 'E'. " LIFETIME_ERROR
          WHEN 5.
            MESSAGE I074 DISPLAY LIKE 'E'. " LIFETIME_DYNPRO_DYNPRO_LINK
          WHEN 6.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

      CREATE OBJECT GO_ALV_GRID1
        EXPORTING
          I_PARENT          = GO_CUSTOM1       " Parent ContainerEXCEPTIONS
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1                " Error when creating the control
          ERROR_CNTL_INIT   = 2                " Error While Initializing Control
          ERROR_CNTL_LINK   = 3                " Error While Linking Control
          ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I076 DISPLAY LIKE 'E'. " Error when creating the control
          WHEN 2.
            MESSAGE I077 DISPLAY LIKE 'E'. " Error While Initializing Control
          WHEN 3.
            MESSAGE I078 DISPLAY LIKE 'E'. " Error While Linking Control
          WHEN 4.
            MESSAGE I079 DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
          WHEN 5.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

    WHEN '0120'.
      CREATE OBJECT GO_CUSTOM2
        EXPORTING
          CONTAINER_NAME              = 'CCON2'          " Name of the Screen CustCtrl Name to Link Container To
        EXCEPTIONS
          CNTL_ERROR                  = 1                " CNTL_ERROR
          CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
          CREATE_ERROR                = 3                " CREATE_ERROR
          LIFETIME_ERROR              = 4                " LIFETIME_ERROR
          LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
          OTHERS                      = 6.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I070 DISPLAY LIKE 'E'. " CNTL_ERROR
          WHEN 2.
            MESSAGE I071 DISPLAY LIKE 'E'. " CNTL_SYSTEM_ERROR
          WHEN 3.
            MESSAGE I072 DISPLAY LIKE 'E'. " CREATE_ERROR
          WHEN 4.
            MESSAGE I073 DISPLAY LIKE 'E'. " LIFETIME_ERROR
          WHEN 5.
            MESSAGE I074 DISPLAY LIKE 'E'. " LIFETIME_DYNPRO_DYNPRO_LINK
          WHEN 6.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

      CREATE OBJECT GO_ALV_GRID2
        EXPORTING
          I_PARENT          = GO_CUSTOM2       " Parent Container
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1                " Error when creating the control
          ERROR_CNTL_INIT   = 2                " Error While Initializing Control
          ERROR_CNTL_LINK   = 3                " Error While Linking Control
          ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I076 DISPLAY LIKE 'E'. " Error when creating the control
          WHEN 2.
            MESSAGE I077 DISPLAY LIKE 'E'. " Error While Initializing Control
          WHEN 3.
            MESSAGE I078 DISPLAY LIKE 'E'. " Error While Linking Control
          WHEN 4.
            MESSAGE I079 DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
          WHEN 5.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

    WHEN '0200'.
      CREATE OBJECT GO_CUSTOM3
        EXPORTING
          CONTAINER_NAME              = 'CCON3'
        EXCEPTIONS
          CNTL_ERROR                  = 1                " CNTL_ERROR
          CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
          CREATE_ERROR                = 3                " CREATE_ERROR
          LIFETIME_ERROR              = 4                " LIFETIME_ERROR
          LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
          OTHERS                      = 6.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I070 DISPLAY LIKE 'E'. " CNTL_ERROR
          WHEN 2.
            MESSAGE I071 DISPLAY LIKE 'E'. " CNTL_SYSTEM_ERROR
          WHEN 3.
            MESSAGE I072 DISPLAY LIKE 'E'. " CREATE_ERROR
          WHEN 4.
            MESSAGE I073 DISPLAY LIKE 'E'. " LIFETIME_ERROR
          WHEN 5.
            MESSAGE I074 DISPLAY LIKE 'E'. " LIFETIME_DYNPRO_DYNPRO_LINK
          WHEN 6.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

      CREATE OBJECT GO_SPLITTER
        EXPORTING
          PARENT            = GO_CUSTOM3
          ROWS              = 3
          COLUMNS           = 1
        EXCEPTIONS
          CNTL_ERROR        = 1                  " See Superclass
          CNTL_SYSTEM_ERROR = 2                  " See Superclass
          OTHERS            = 3.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1 OR 2.
            MESSAGE I083 DISPLAY LIKE 'E'. " See Superclass
          WHEN 3.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

      GO_CON1 = GO_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
      GO_CON2 = GO_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
      GO_CON3 = GO_SPLITTER->GET_CONTAINER( ROW = 3 COLUMN = 1 ).

      CALL METHOD GO_SPLITTER->SET_ROW_HEIGHT
        EXPORTING
          ID     = 2
          HEIGHT = 14.

      CREATE OBJECT GO_ALV_GRID3
        EXPORTING
          I_PARENT          = GO_CON1       " Parent Container
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1                " Error when creating the control
          ERROR_CNTL_INIT   = 2                " Error While Initializing Control
          ERROR_CNTL_LINK   = 3                " Error While Linking Control
          ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I076 DISPLAY LIKE 'E'. " Error when creating the control
          WHEN 2.
            MESSAGE I077 DISPLAY LIKE 'E'. " Error While Initializing Control
          WHEN 3.
            MESSAGE I078 DISPLAY LIKE 'E'. " Error While Linking Control
          WHEN 4.
            MESSAGE I079 DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
          WHEN 5.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

      CREATE OBJECT GO_ALV_GRID4
        EXPORTING
          I_PARENT          = GO_CON3       " Parent Container
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1                " Error when creating the control
          ERROR_CNTL_INIT   = 2                " Error While Initializing Control
          ERROR_CNTL_LINK   = 3                " Error While Linking Control
          ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I076 DISPLAY LIKE 'E'. " Error when creating the control
          WHEN 2.
            MESSAGE I077 DISPLAY LIKE 'E'. " Error While Initializing Control
          WHEN 3.
            MESSAGE I078 DISPLAY LIKE 'E'. " Error While Linking Control
          WHEN 4.
            MESSAGE I079 DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
          WHEN 5.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

      "TOP-Document
      CREATE OBJECT GO_DOCUMENT
        EXPORTING
          STYLE = 'ALV_GRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO .

  CLEAR : GS_LAYO, GS_LAYO2, GS_VARIANT, GV_SAVE.
  GV_SAVE = 'A'.

  CASE SY-DYNNR.
    WHEN '0110'.
      GS_LAYO = VALUE #( ZEBRA        = 'X'
                         CWIDTH_OPT   = 'A'
                         SEL_MODE     = 'D' ).
      GS_VARIANT = VALUE #( REPORT = SY-CPROG
                            HANDLE = 'ALV1' ).
    WHEN '0120'.
      GS_LAYO2 = VALUE #( ZEBRA        = 'X'
                          CWIDTH_OPT   = 'A'
                          SEL_MODE     = 'D'
                          NO_ROWINS    = 'X'
                          NO_ROWMOVE   = 'X' ).
      GS_VARIANT = VALUE #( REPORT = SY-CPROG
                            HANDLE = 'ALV2' ).
    WHEN '0200'.

      DATA : LV_LAST_YEAR TYPE NUMC4.
      LV_LAST_YEAR = CONV I( SY-DATUM+0(4) ) - 1.

      GS_LAYO = VALUE #( ZEBRA        = 'X'
                         CWIDTH_OPT   = 'A'
                         SEL_MODE     = 'D'
                         GRID_TITLE   = |{ LV_LAST_YEAR }년도 판매실적|
                         SMALLTITLE   = 'X'
                         ).
      GS_LAYO2 = VALUE #( ZEBRA        = 'X'
                          CWIDTH_OPT   = 'A'
                          SEL_MODE     = 'D'
                          GRID_TITLE   = |{ SY-DATUM+0(4) }년도 판매계획|
                          SMALLTITLE   = 'X'
                          NO_ROWINS    = 'X'
                          NO_ROWMOVE   = 'X'
                          CTAB_FNAME = 'IT_COLFIELD'
                          STYLEFNAME = 'STYLE' ).
      GS_VARIANT = VALUE #( REPORT = SY-CPROG
                            HANDLE = 'ALV3' ).
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT  USING PV_DYNNR.

  "FIELDNAME / KEY / COLTEXT / REF_TABLE / REF_FIELD / QFIELDNAME / EDIT
  DATA : LV_MONTH TYPE NUMC2.
  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
  LV_COL_POS = 10.

  CASE PV_DYNNR.
    WHEN '0110'.
      CLEAR : GT_FCAT[].
      PERFORM SET_FIELD_CATALOG : USING 'VKBUR'      ABAP_ON '영업장'      'ZCC_VBBS' SPACE SPACE SPACE SPACE
                                CHANGING LV_COL_POS GT_FCAT,

                                  USING 'MATNR'      ABAP_ON '자재번호'    'ZCC_VBAK' SPACE SPACE SPACE ABAP_ON
                                CHANGING LV_COL_POS GT_FCAT,

                                  USING 'MAKTG'      ABAP_ON '자재명'      'ZCC_VBAK' SPACE SPACE SPACE SPACE
                                CHANGING LV_COL_POS GT_FCAT,

                                  USING 'SPART'      SPACE   '제품군 번호' 'ZCC_VBAK' SPACE SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT,

                                  USING 'SPART_TXT'  SPACE   '제품군명'    'ZCC_VBAK' SPACE SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT,

                                  USING 'PLAN_YEAR'  SPACE   '판매년도'    'ZCC_VBAK' SPACE SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT.
      CLEAR : LV_MONTH.

      DO 12 TIMES.
        LV_MONTH += 1.
        DATA(LV_FIELDNAME) = |KWMENG_{ LV_MONTH }|.
        DATA(LV_COLTEXT) = |{ LV_MONTH }월 판매량|.

        PERFORM SET_FIELD_CATALOG USING LV_FIELDNAME SPACE LV_COLTEXT 'ZCC_VBAP' 'KWMENG' 'MEINS' SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT.
      ENDDO.

      PERFORM SET_FIELD_CATALOG : USING 'MEINS' ABAP_ON '수량단위' 'ZCC_VBAP' 'MEINS' SPACE SPACE SPACE
                                CHANGING LV_COL_POS GT_FCAT.

    WHEN '0120'.
      PERFORM SET_FIELD_CATALOG : USING 'VKBUR'     ABAP_ON '영업장'      'ZCC_VBBS' SPACE SPACE ABAP_ON SPACE
                               CHANGING LV_COL_POS GT_FCAT2,

                                  USING 'MATNR'     ABAP_ON '자재번호'    'ZCC_VBBS' SPACE SPACE ABAP_ON SPACE
                               CHANGING LV_COL_POS GT_FCAT2,

                                  USING 'MAKTG'     ABAP_ON '자재명'      'ZCC_VBAK' SPACE SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT2,

                                  USING 'SPART'     SPACE   '제품군 번호' 'ZCC_VBAK' SPACE SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT2,

                                  USING 'SPART_TXT' SPACE   '제품군명'    'ZCC_VBAK' SPACE SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT2.
      CLEAR : LV_MONTH.

      DO 12 TIMES.
        LV_MONTH += 1.
        LV_FIELDNAME = |KWMENG_{ LV_MONTH }|.
        LV_COLTEXT = |{ LV_MONTH }월 계획량|.

        PERFORM SET_FIELD_CATALOG USING LV_FIELDNAME SPACE LV_COLTEXT 'ZCC_VBAP' 'KWMENG' 'MEINS' ABAP_ON SPACE
                               CHANGING LV_COL_POS GT_FCAT2.
      ENDDO.

      PERFORM SET_FIELD_CATALOG : USING 'MEINS' ABAP_ON '수량단위' 'ZCC_VBAP' 'MEINS' SPACE SPACE SPACE
                               CHANGING LV_COL_POS GT_FCAT2.
    WHEN '0200'.
      IF GT_FCAT[] IS INITIAL.
        PERFORM SET_FCAT USING '0110'.
      ENDIF.

      IF GT_FCAT2[] IS INITIAL.
        PERFORM SET_FCAT USING '0120'.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_EVENT
*&---------------------------------------------------------------------*
FORM SET_ALV_EVENT .

  CASE SY-DYNNR.
    WHEN '0110'.
      SET HANDLER LCL_EVENT_HANDLER=>ON_HOT_SPOT     FOR GO_ALV_GRID1.
    WHEN '0120'.

      CALL METHOD GO_ALV_GRID2->SET_READY_FOR_INPUT
        EXPORTING
          I_READY_FOR_INPUT = 0.                " Ready for Input Status
*
*      CALL METHOD GO_ALV_GRID2->REGISTER_EDIT_EVENT
*        EXPORTING
*          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.  " Event ID
*
*      SET HANDLER LCL_EVENT_HANDLER=>ON_TOOLBAR      FOR GO_ALV_GRID2.
*      SET HANDLER LCL_EVENT_HANDLER=>ON_USER_COMMAND FOR GO_ALV_GRID2.
*      SET HANDLER LCL_EVENT_HANDLER=>ON_DATA_CHANGED FOR GO_ALV_GRID2.
      SET HANDLER LCL_EVENT_HANDLER=>ON_HOT_SPOT     FOR GO_ALV_GRID2.
    WHEN '0200'.

      CALL METHOD GO_ALV_GRID4->SET_READY_FOR_INPUT
        EXPORTING
          I_READY_FOR_INPUT = 0.                " Ready for Input Status

      CALL METHOD GO_ALV_GRID4->REGISTER_EDIT_EVENT
        EXPORTING
          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.  " Event ID

      SET HANDLER LCL_EVENT_HANDLER=>ON_TOOLBAR      FOR GO_ALV_GRID4.
      SET HANDLER LCL_EVENT_HANDLER=>ON_USER_COMMAND FOR GO_ALV_GRID4.
      SET HANDLER LCL_EVENT_HANDLER=>ON_DATA_CHANGED FOR GO_ALV_GRID4.
      SET HANDLER LCL_EVENT_HANDLER=>ON_TOP_OF_PAGE  FOR GO_ALV_GRID4.

      SET HANDLER LCL_EVENT_HANDLER=>ON_HOT_SPOT     FOR GO_ALV_GRID3.
      SET HANDLER LCL_EVENT_HANDLER=>ON_HOT_SPOT     FOR GO_ALV_GRID4.

      "TOP_OF_PAGE 이벤트 실행 메서드
      CALL METHOD GO_ALV_GRID4->LIST_PROCESSING_EVENTS
        EXPORTING
          I_EVENT_NAME = 'TOP_OF_PAGE'
          I_DYNDOC_ID  = GO_DOCUMENT.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  CASE SY-DYNNR.
    WHEN '0110'.
      CALL METHOD GO_ALV_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT                    = GS_VARIANT              " Layout
          I_SAVE                        = GV_SAVE                 " Save Layout
          IS_LAYOUT                     = GS_LAYO                 " Layout
        CHANGING
          IT_OUTTAB                     = GT_DISPLAY1             " Output Table
          IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
        EXCEPTIONS
          INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
          PROGRAM_ERROR                 = 2                " Program Errors
          TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
          OTHERS                        = 4.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I080 DISPLAY LIKE 'E'. " Wrong Parameter
          WHEN 2.
            MESSAGE I081 DISPLAY LIKE 'E'. " Program Errors
          WHEN 3.
            MESSAGE I082 DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
          WHEN 4.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

    WHEN '0120'.
      GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY( EXPORTING
                                                    IS_VARIANT = GS_VARIANT
                                                    I_SAVE     = GV_SAVE
                                                    IS_LAYOUT  = GS_LAYO2
                                                 CHANGING
                                                    IT_OUTTAB  = GT_DISPLAY2
                                                    IT_FIELDCATALOG = GT_FCAT2
                                                 EXCEPTIONS
                                                    INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
                                                    PROGRAM_ERROR                 = 2                " Program Errors
                                                    TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
                                                    OTHERS                        = 4 ).

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I080 DISPLAY LIKE 'E'. " Wrong Parameter
          WHEN 2.
            MESSAGE I081 DISPLAY LIKE 'E'. " Program Errors
          WHEN 3.
            MESSAGE I082 DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
          WHEN 4.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

    WHEN '0200'.
      CALL METHOD GO_ALV_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT                    = GS_VARIANT              " Layout
          I_SAVE                        = GV_SAVE                 " Save Layout
          IS_LAYOUT                     = GS_LAYO                 " Layout
        CHANGING
          IT_OUTTAB                     = GT_DISPLAY1             " Output Table
          IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
        EXCEPTIONS
          INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
          PROGRAM_ERROR                 = 2                " Program Errors
          TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
          OTHERS                        = 4.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I080 DISPLAY LIKE 'E'. " Wrong Parameter
          WHEN 2.
            MESSAGE I081 DISPLAY LIKE 'E'. " Program Errors
          WHEN 3.
            MESSAGE I082 DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
          WHEN 4.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.


      CALL METHOD GO_ALV_GRID4->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT                    = GS_VARIANT              " Layout
          I_SAVE                        = GV_SAVE                 " Save Layout
          IS_LAYOUT                     = GS_LAYO2                " Layout
        CHANGING
          IT_OUTTAB                     = GT_DISPLAY3             " Output Table
          IT_FIELDCATALOG               = GT_FCAT2                " Field Catalog
        EXCEPTIONS
          INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
          PROGRAM_ERROR                 = 2                " Program Errors
          TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
          OTHERS                        = 4.

      IF SY-SUBRC <> 0.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE I080 DISPLAY LIKE 'E'. " Wrong Parameter
          WHEN 2.
            MESSAGE I081 DISPLAY LIKE 'E'. " Program Errors
          WHEN 3.
            MESSAGE I082 DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
          WHEN 4.
            MESSAGE I075 DISPLAY LIKE 'E'. " others_error
        ENDCASE.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG  USING    PV_FIELDNAME
                                 PV_KEY
                                 PV_COLTEXT
                                 PV_REF_TABLE
                                 PV_REF_FIELD
                                 PV_QFIELDNAME
                                 PV_EDIT
                                 PV_HOTSPOT
                        CHANGING PV_COL_POS
                                 PT_FCAT TYPE LVC_T_FCAT.

* 기존 PT_FCAT 테이블에 새로운 필드 카탈로그 항목 추가
  PT_FCAT[] = VALUE #( BASE PT_FCAT[] ( FIELDNAME   = PV_FIELDNAME
                                        KEY         = PV_KEY
                                        COL_POS     = PV_COL_POS
                                        COLTEXT     = PV_COLTEXT
                                        REF_TABLE   = PV_REF_TABLE
                                        REF_FIELD   = PV_REF_FIELD
                                        QUANTITY    = SWITCH #( PV_FIELDNAME WHEN 'MEINS' THEN ABAP_ON ELSE SPACE )
                                        QFIELDNAME  = PV_QFIELDNAME
                                        EDIT        = PV_EDIT
                                        HOTSPOT     = PV_HOTSPOT
                                         ) ).
  PV_COL_POS += 10.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HANDLER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM ALV_HANDLER_DATA_CHANGED  USING    PO_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LT_MODI TYPE LVC_T_MODI,
         LS_MODI TYPE LVC_S_MODI.

  FIELD-SYMBOLS <FS>.

  LT_MODI = PO_DATA_CHANGED->MT_MOD_CELLS.

  LOOP AT LT_MODI INTO LS_MODI.
    CASE LS_MODI-FIELDNAME.
      WHEN 'MATNR'.
        CASE SY-DYNNR.
          WHEN '0100'.
            CLEAR : GS_DISPLAY2.

            PO_DATA_CHANGED->GET_CELL_VALUE(
              EXPORTING
                I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
                I_FIELDNAME = 'VKBUR'                 " Field Name
              IMPORTING
                E_VALUE     = GS_DISPLAY2-VKBUR       " Cell Content
            ).

            PO_DATA_CHANGED->GET_CELL_VALUE(
              EXPORTING
                I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
                I_FIELDNAME = 'MATNR'                 " Field Name
              IMPORTING
                E_VALUE     = GS_DISPLAY2-MATNR       " Cell Content
            ).

            SELECT SINGLE
              FROM ZCC_MARA AS A
              LEFT OUTER JOIN ZCC_MAKT AS B
                 ON A~MATNR EQ B~MATNR
                AND B~SPRAS EQ @SY-LANGU
             FIELDS A~MATNR, B~MAKTG, A~SPART
              WHERE A~MATNR EQ @GS_DISPLAY2-MATNR
              INTO @DATA(LS_MAT).

            SELECT SINGLE
              FROM DD07L AS A
              LEFT OUTER JOIN DD07T AS B
                ON A~DOMNAME   EQ B~DOMNAME
               AND A~AS4LOCAL  EQ B~AS4LOCAL
               AND A~VALPOS    EQ B~VALPOS
               AND A~AS4VERS   EQ B~AS4VERS
            FIELDS A~DOMVALUE_L, B~DDTEXT
             WHERE A~DOMNAME    EQ 'ZCC_SPART'
               AND B~DDLANGUAGE EQ @SY-LANGU
               AND A~AS4LOCAL   EQ 'A'  " Active인 Fixed Value만 조회
               AND A~DOMVALUE_L EQ @LS_MAT-SPART
              INTO @DATA(LS_SPART).

            GS_DISPLAY2-MAKTG = LS_MAT-MAKTG.
            GS_DISPLAY2-SPART = LS_MAT-SPART.
            GS_DISPLAY2-SPART_TXT = LS_SPART-DDTEXT.

            PO_DATA_CHANGED->MODIFY_CELL(
            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
            I_FIELDNAME = 'MAKTG'                 " Field Name
            I_VALUE     = GS_DISPLAY2-MAKTG       " Value
          ).

            PO_DATA_CHANGED->MODIFY_CELL(
            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
            I_FIELDNAME = 'SPART'                 " Field Name
            I_VALUE     = GS_DISPLAY2-SPART       " Value
          ).

            PO_DATA_CHANGED->MODIFY_CELL(
            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
            I_FIELDNAME = 'SPART_TXT'             " Field Name
            I_VALUE     = GS_DISPLAY2-SPART_TXT   " Value
          ).

            PO_DATA_CHANGED->MODIFY_CELL(
            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
            I_FIELDNAME = 'MEINS'                 " Field Name
            I_VALUE     = 'EA'                    " Value
          ).

            READ TABLE GT_DISPLAY2 INTO DATA(LS_DISPLAY) WITH KEY VKBUR = GS_DISPLAY2-VKBUR
                                                                  MATNR = GS_DISPLAY2-MATNR.
            IF SY-SUBRC EQ 0.
              MESSAGE I104.
              DELETE GT_DISPLAY2 INDEX LS_MODI-ROW_ID.

              CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY
                EXPORTING
                  IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
                EXCEPTIONS
                  FINISHED  = 1                " Display was Ended (by Export)
                  OTHERS    = 2.

              IF SY-SUBRC <> 0.
                MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.
            ENDIF.

          WHEN '0200'.
            CLEAR : GS_DISPLAY3.

            DEFINE   __GET_VALUE.

              ASSIGN COMPONENT &1 OF STRUCTURE GS_DISPLAY3 TO <FS>.
              IF SY-SUBRC EQ 0.
                PO_DATA_CHANGED->GET_CELL_VALUE(
                  EXPORTING
                    I_ROW_ID    = LS_MODI-ROW_ID                 " Row ID
                    I_FIELDNAME = &1                 " Field Name
                  IMPORTING
                    E_VALUE     = <FS>                 " Cell Content
                ).
                UNASSIGN <FS>.
              ENDIF.
            END-OF-DEFINITION.

            DEFINE __MODIFY_VALUE.

              ASSIGN COMPONENT &1 OF STRUCTURE GS_DISPLAY3 TO <FS>.
              IF SY-SUBRC EQ 0.
                PO_DATA_CHANGED->MODIFY_CELL(
                  I_ROW_ID    = LS_MODI-ROW_ID     " Row ID
                  I_FIELDNAME = &1                 " Field Name
                  I_VALUE     = <FS>               " Value
                ).
                UNASSIGN <FS>.
              ENDIF.

            END-OF-DEFINITION.

            __GET_VALUE : 'VKBUR',
                          'MATNR'.

            SELECT SINGLE
              FROM ZCC_MARA AS A
              LEFT OUTER JOIN ZCC_MAKT AS B
                 ON A~MATNR EQ B~MATNR
                AND B~SPRAS EQ @SY-LANGU
             FIELDS A~MATNR, B~MAKTG, A~SPART
              WHERE A~MATNR EQ @GS_DISPLAY3-MATNR
              INTO @DATA(LS_MAT2).

            SELECT SINGLE
              FROM DD07L AS A
              LEFT OUTER JOIN DD07T AS B
                ON A~DOMNAME   EQ B~DOMNAME
               AND A~AS4LOCAL  EQ B~AS4LOCAL
               AND A~VALPOS    EQ B~VALPOS
               AND A~AS4VERS   EQ B~AS4VERS
            FIELDS A~DOMVALUE_L, B~DDTEXT
             WHERE A~DOMNAME    EQ 'ZCC_SPART'
               AND B~DDLANGUAGE EQ @SY-LANGU
               AND A~AS4LOCAL   EQ 'A'  " Active인 Fixed Value만 조회
               AND A~DOMVALUE_L EQ @LS_MAT2-SPART
              INTO @DATA(LS_SPART2).

            GS_DISPLAY3-MAKTG = LS_MAT2-MAKTG.
            GS_DISPLAY3-SPART = LS_MAT2-SPART.
            GS_DISPLAY3-SPART_TXT = LS_SPART2-DDTEXT.

            __MODIFY_VALUE : 'MAKTG',
                             'SPART',
                             'SPART_TXT'.

*            PO_DATA_CHANGED->MODIFY_CELL(
*            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
*            I_FIELDNAME = 'MAKTG'                 " Field Name
*            I_VALUE     = GS_DISPLAY3-MAKTG       " Value
*          ).
*
*            PO_DATA_CHANGED->MODIFY_CELL(
*            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
*            I_FIELDNAME = 'SPART'                 " Field Name
*            I_VALUE     = GS_DISPLAY3-SPART       " Value
*          ).
*
*            PO_DATA_CHANGED->MODIFY_CELL(
*            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
*            I_FIELDNAME = 'SPART_TXT'             " Field Name
*            I_VALUE     = GS_DISPLAY3-SPART_TXT   " Value
*          ).
*
*            PO_DATA_CHANGED->MODIFY_CELL(
*            I_ROW_ID    = LS_MODI-ROW_ID          " Row ID
*            I_FIELDNAME = 'MEINS'                 " Field Name
*            I_VALUE     = 'EA'                    " Value
*          ).

            READ TABLE GT_DISPLAY3 INTO DATA(LS_DISPLAY2) WITH KEY VKBUR = GS_DISPLAY3-VKBUR
                                                                   MATNR = GS_DISPLAY3-MATNR.
            IF SY-SUBRC EQ 0.
              MESSAGE I104.
              DELETE GT_DISPLAY3 INDEX LS_MODI-ROW_ID.

              CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
                EXPORTING
                  IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
                EXCEPTIONS
                  FINISHED  = 1                " Display was Ended (by Export)
                  OTHERS    = 2.

              IF SY-SUBRC <> 0.
                MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.
            ENDIF.

        ENDCASE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HANDLER_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM ALV_HANDLER_TOP_OF_PAGE .

  DATA : LO_DD_TABLE TYPE REF TO CL_DD_TABLE_ELEMENT.
  DATA : LO_COL_VALUE TYPE REF TO CL_DD_AREA.
  DATA : LV_TEXT TYPE SDYDO_TEXT_ELEMENT.

*-- 테이블 문서 생성
  CALL METHOD GO_DOCUMENT->ADD_TABLE
    EXPORTING
      NO_OF_COLUMNS = 2
      BORDER        = '0' "테두리
    IMPORTING
      TABLE         = LO_DD_TABLE
    EXCEPTIONS
      OTHERS        = 2.

  IF SY-SUBRC <> 0.
    MESSAGE A016(PN) WITH '테이블 문서 생성 Method가 실행되지 않습니다'.
  ENDIF.

*-- 컬럼 추가
  CALL METHOD LO_DD_TABLE->ADD_COLUMN
    EXPORTING
      WIDTH  = '60%'
    IMPORTING
      COLUMN = LO_COL_VALUE
    EXCEPTIONS
      OTHERS = 2.

  IF SY-SUBRC <> 0.
    MESSAGE A016(PN) WITH '컬럼 추가 Method가 실행되지 않습니다'.
  ENDIF.

*-- 컬럼 문구 - 1
  LV_TEXT = '* 작년 판매실적을 기반으로 올해 판매계획이 설정됩니다.'.

  CALL METHOD LO_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = CL_DD_DOCUMENT=>LARGE
      SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG.

  CALL METHOD LO_COL_VALUE->NEW_LINE( ).

  LV_TEXT = '* 판매계획을 모두 세운 경우 상단의 저장 버튼을 통해 저장해주세요.'.

  CALL METHOD LO_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = CL_DD_DOCUMENT=>LARGE
      SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG.

  CALL METHOD LO_COL_VALUE->NEW_LINE( ).

  LV_TEXT = '* 작년 KPI 혹은 PAI에 따라 셀의 색상이 표시됩니다.'.

  CALL METHOD LO_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = CL_DD_DOCUMENT=>LARGE
      SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG.

*-- 컬럼 추가

  CALL METHOD LO_DD_TABLE->ADD_COLUMN
    IMPORTING
      COLUMN = LO_COL_VALUE
    EXCEPTIONS
      OTHERS = 2.

  IF SY-SUBRC <> 0.
    MESSAGE A016(PN) WITH '컬럼 추가 Method가 실행되지 않습니다'.
  ENDIF.

*-- 컬럼 문구 - 2

  DATA : LV_ICON TYPE ICON-ID.

  LV_ICON = ICON_LED_GREEN.
  LV_TEXT = '초록 : KPI가 90 이상 110 이하 / PAI가 90 이상 110 이하'.

  CALL METHOD LO_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = CL_DD_DOCUMENT=>MEDIUM.

  CALL METHOD LO_COL_VALUE->NEW_LINE( ).

  LV_ICON = ICON_LED_YELLOW.
  LV_TEXT = '노랑 : KPI가 80 이상 90 미만 혹은 110 초과 120 이하 / PAI가 110 초과 130 이하'.

  CALL METHOD LO_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = CL_DD_DOCUMENT=>MEDIUM.

  CALL METHOD LO_COL_VALUE->NEW_LINE( ).

  LV_ICON = ICON_LED_RED.
  LV_TEXT = '빨강 : KPI가 80 미만 혹은 120 초과 / PAI가 90 미만 130 초과'.

  CALL METHOD LO_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = CL_DD_DOCUMENT=>MEDIUM.

*-- top-of-page 문서 작업 병합
  CALL METHOD GO_DOCUMENT->MERGE_DOCUMENT..
  GO_DOCUMENT->HTML_CONTROL = GO_HTML.

*-- top-of-page 문서 출력 필수 메서드
  CALL METHOD GO_DOCUMENT->DISPLAY_DOCUMENT
    EXPORTING
      REUSE_CONTROL = 'X'
      PARENT        = GO_CON2
    EXCEPTIONS
      OTHERS        = 2.

  IF SY-SUBRC <> 0.
    MESSAGE A016(PN) WITH 'Top-of-page 문서 출력 Method가 실행되지 않습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA2
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA2 .

  CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT              " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
      IS_LAYOUT                     = GS_LAYO2                " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY2             " Output Table
      IT_FIELDCATALOG               = GT_FCAT2                " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                       " Wrong Parameter
      PROGRAM_ERROR                 = 2                       " Program Errors
      TOO_MANY_LINES                = 3                       " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I080 DISPLAY LIKE 'E'. " Wrong Parameter
      WHEN 2.
        MESSAGE I081 DISPLAY LIKE 'E'. " Program Errors
      WHEN 3.
        MESSAGE I082 DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
      WHEN 4.
        MESSAGE I075 DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DATA2
*&---------------------------------------------------------------------*
FORM CREATE_DATA2 .

  CLEAR : GT_DATA2.

  LOOP AT GT_DATA1 INTO GS_DATA1.

    CLEAR : ZCC_VBBS.

    MOVE-CORRESPONDING GS_DATA1 TO ZCC_VBBS.
    ZCC_VBBS-PLAN_YEAR = SY-DATUM+0(4).
    ZCC_VBBS-PLAN_MONTH = GS_DATA1-VBELN+4(2).
    ZCC_VBBS-VBBEZ = GS_DATA1-KWMENG.
    ZCC_VBBS-STATUS = 'WT'.
    ZCC_VBBS-ERNAM = SY-UNAME.
    ZCC_VBBS-ERDAT = SY-DATUM.
    ZCC_VBBS-ERZET = SY-UZEIT.

    COLLECT ZCC_VBBS INTO GT_DATA2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_STYLE
*&---------------------------------------------------------------------*
FORM MODIFY_STYLE .

  DATA : LS_STYLE     TYPE LVC_S_STYL,  " GS_DISLPAY3-STYLE의 WA
         LV_STANDARD  TYPE N LENGTH 2,
         LV_MONTH_IDX TYPE NUMC2.

* DISPLAY2와 DISPLAY3은 CELL COLOR 를 제외한 모든 정보가 동일하므로 MOVE-CORRESPONDING
  MOVE-CORRESPONDING GT_DISPLAY2 TO GT_DISPLAY3.

  LV_STANDARD = SY-DATUM+4(2) + 1.

  LOOP AT GT_DISPLAY3 INTO GS_DISPLAY3.

    " 1~LV_STANDARD까지는 월별 판매량 필드 비활성화
    DO LV_STANDARD TIMES.
      LV_MONTH_IDX = SY-INDEX.
      DATA(LV_FIELDNAME) = |KWMENG_{ LV_MONTH_IDX }|.  " 동적 필드명 구성: 'KWMENG_01', ...
      CONDENSE LV_FIELDNAME NO-GAPS.

      CLEAR LS_STYLE.
      LS_STYLE-FIELDNAME = LV_FIELDNAME.
      LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      APPEND LS_STYLE TO GS_DISPLAY3-STYLE.
    ENDDO.

    CLEAR : LS_STYLE.
    LS_STYLE-FIELDNAME = 'MATNR'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    APPEND LS_STYLE TO GS_DISPLAY3-STYLE.

    CLEAR : LS_STYLE.
    LS_STYLE-FIELDNAME = 'VKBUR'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    APPEND LS_STYLE TO GS_DISPLAY3-STYLE.

    MODIFY GT_DISPLAY3 FROM GS_DISPLAY3 TRANSPORTING STYLE.

  ENDLOOP.

  SORT GT_DISPLAY3 BY VKBUR MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_SINGLE_SAVE
*&---------------------------------------------------------------------*
FORM CONVERT_SINGLE_SAVE  USING PS_INPUT_SINGLE TYPE TS_DISPLAY
                       CHANGING PT_SAVE  TYPE TY_SAVE.

  FIELD-SYMBOLS <FS>.
  DATA : LV_MONTH TYPE NUMC2,
         LV_COUNT TYPE INT2,
         LS_SAVE  LIKE LINE OF PT_SAVE.

  LV_COUNT = 00.

  DO 12 TIMES.
    " 횟수를 카운트 하면 12번 반복함으로써 각 달에 해당하는 계획량에 대한 점검을 진행
    LV_COUNT += 1.
    LV_MONTH = LV_COUNT.

    " 데이터가 들어있는 필드를 동적으로 받기 위해 변수명을 지정함.
    DATA(LV_VBBEZ) = |PS_INPUT_SINGLE-KWMENG_{ LV_MONTH }|.

    " PS_INPUT_SINGLE-KWMENG_{ LV_MONTH }이라는 변수를 <FS>에 할당
    ASSIGN (LV_VBBEZ) TO <FS>.

    CHECK <FS> IS NOT INITIAL.

    " 기본 정보 채우기
    LS_SAVE-MATNR = PS_INPUT_SINGLE-MATNR.
    LS_SAVE-VKBUR = PS_INPUT_SINGLE-VKBUR.
    LS_SAVE-PLAN_YEAR = PS_INPUT_SINGLE-PLAN_YEAR.
    LS_SAVE-PLAN_MONTH = LV_MONTH.
    LS_SAVE-SPART = PS_INPUT_SINGLE-SPART.
    LS_SAVE-VBBEZ = <FS>.
    LS_SAVE-MEINS = PS_INPUT_SINGLE-MEINS.
    LS_SAVE-STATUS = 'WT'.
    LS_SAVE-ERNAM = SY-UNAME.
    LS_SAVE-ERDAT = SY-DATUM.
    LS_SAVE-ERZET = SY-UZEIT.

    APPEND LS_SAVE TO PT_SAVE.
    UNASSIGN <FS>.

  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPLAN
*&---------------------------------------------------------------------*
FORM SET_SPLAN  CHANGING PT_SAVE TYPE TY_SAVE.

  DATA : LV_SPLAN TYPE STRING.

*  IF PT_SAVE IS NOT INITIAL.
*    CALL FUNCTION 'NUMBER_GET_NEXT'
*      EXPORTING
*        NR_RANGE_NR        = '1'                 " Number range number
*        OBJECT             = 'ZCC_SPLA'          " Name of number range object
*      IMPORTING
*        NUMBER             = LV_NUM               " free number
*      EXCEPTIONS
*        INTERVAL_NOT_FOUND = 1                " Interval not found
*        OBJECT_NOT_FOUND   = 2                " Object not defined in TNRO
*        OTHERS             = 3.
*
*  ENDIF.

  LOOP AT PT_SAVE INTO DATA(PS_SAVE).
    LV_SPLAN = 'SP' && PS_SAVE-PLAN_YEAR && PS_SAVE-PLAN_MONTH.
    PS_SAVE-SPLAN = LV_SPLAN.
    MODIFY PT_SAVE FROM PS_SAVE TRANSPORTING SPLAN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_SINGLE
*&---------------------------------------------------------------------*
FORM SAVE_SINGLE  USING    PT_SAVE TYPE TY_SAVE.

  MODIFY ZCC_VBBS FROM TABLE PT_SAVE.

  IF SY-SUBRC EQ 0.
    MESSAGE S061.
  ELSE.
    MESSAGE I062 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PLAN
*&---------------------------------------------------------------------*
FORM CHECK_PLAN  USING PT_SAVE TYPE TY_SAVE.

  DATA: LV_ANSWER TYPE C LENGTH 1.

  SELECT MATNR,
         SPLAN,
         VKBUR,
         PLAN_YEAR,
         PLAN_MONTH,
         SPART,
         STATUS
    INTO TABLE @DATA(LT_VBBS)
    FROM ZCC_VBBS
    FOR ALL ENTRIES IN @PT_SAVE
    WHERE MATNR      = @PT_SAVE-MATNR
      AND VKBUR      = @PT_SAVE-VKBUR
      AND PLAN_YEAR  = @PT_SAVE-PLAN_YEAR
      AND PLAN_MONTH = @PT_SAVE-PLAN_MONTH.

  IF LT_VBBS IS NOT INITIAL.
    " 저장하려는 데이터 중 일부 혹은 전체가 이미 DB에 존재하는 경우
    LOOP AT LT_VBBS INTO DATA(LS_VBBS).
      IF LS_VBBS-STATUS = 'AP'.
        " 이미 승인된 판매계획이 존재하는 경우에는 생성을 멈춤.
        MESSAGE I100 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.
    " 저장하려는 데이터 중 일부 혹은 전체가 이미 DB에 있으나, 해당 데이터가 승인 이전인 경우 계속 진행하면 기존 데이터를 덮어쓴다.
    " 해당 내용을 사용자에게 팝업으로 경고하고 계속 진행할 지 묻는다.
    " 팝업 메시지 호출
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = '판매계획 초기화'
        TEXT_QUESTION         = '기존 계획이 삭제되고 현재 입력 중인 정보를 기준으로 초기화됩니다. 계속 진행하시겠습니까?'
        TEXT_BUTTON_1         = '예'           " 버튼1: 예
        TEXT_BUTTON_2         = '아니오'       " 버튼2: 아니오
        DEFAULT_BUTTON        = '2'            " 기본 선택: 아니오
        DISPLAY_CANCEL_BUTTON = 'X'             " 취소버튼 비활성화
      IMPORTING
        ANSWER                = LV_ANSWER.

    " 사용자의 선택에 따라 처리
    IF LV_ANSWER = '1'.  " 예
*      DELETE ZCC_VBBS FROM TABLE LT_VBBS.
      PERFORM SET_SPLAN CHANGING PT_SAVE.
      PERFORM SAVE_SINGLE  USING PT_SAVE.
      " 여기에 기존 계획 삭제 및 실적 복사 로직 작성
      MESSAGE S101.
    ELSE.
      MESSAGE S102 DISPLAY LIKE 'W'.
      EXIT.
    ENDIF.

  ELSE.
*    DELETE ZCC_VBBS FROM TABLE LT_VBBS.
    PERFORM SET_SPLAN CHANGING PT_SAVE.
    PERFORM SAVE_SINGLE  USING PT_SAVE.
*    MESSAGE S101.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_NEW_ROW
*&---------------------------------------------------------------------*
FORM ADD_NEW_ROW .

  CASE SY-DYNNR.
    WHEN '0100'.
      APPEND INITIAL LINE TO GT_DISPLAY2.

      CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    WHEN '0200'.
      APPEND INITIAL LINE TO GT_DISPLAY3.

      CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_SELECTED_ROW
*&---------------------------------------------------------------------*
FORM DELETE_SELECTED_ROW .

  DATA: LT_ROWS      TYPE LVC_T_ROW,
        LS_ROW       TYPE LVC_S_ROW,
        LT_KEY_CHECK TYPE TABLE OF ZCC_VBBS,
        LT_EXISTING  TYPE TABLE OF ZCC_VBBS.

  CASE SY-DYNNR.
    WHEN '0200'.
      " 선택한 행들의 정보를 받아온다.
      CALL METHOD GO_ALV_GRID4->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROWS.

      " LT_ROWS에는 INDEX 정보만 존재하기 때문에 삭제 가능 여부를 검토하기 위해 사용할 KEY VALUE 들을 DISPLAY TABLE에서 받아온다.
      " 이때 판매계획번호는 [ SP + 년도 + 월 ] 이므로 유효성 검사를 위한 KEY FIELD로의 의미가 없다.
      " DISPLAY 테이블에서는 1월부터 12월의 모든 데이터를 보여주기 때문에 유효성 검사를 위한 KEY FIELD로의 의미가 없다.
      LOOP AT LT_ROWS INTO LS_ROW.
        READ TABLE GT_DISPLAY3 INDEX LS_ROW-INDEX INTO DATA(LS_DATA).
        IF SY-SUBRC = 0.
          APPEND VALUE #( MATNR = LS_DATA-MATNR
                          PLAN_YEAR = LS_DATA-PLAN_YEAR
                          VKBUR = LS_DATA-VKBUR ) TO LT_KEY_CHECK.
        ENDIF.
      ENDLOOP.

      " 자재번호, 계획년도, 영업장을 기준으로 실제 DB에 존재하는지 여부 확인
      SELECT MATNR SPLAN
        FROM ZCC_VBBS
        INTO TABLE LT_EXISTING
        FOR ALL ENTRIES IN LT_KEY_CHECK
        WHERE MATNR = LT_KEY_CHECK-MATNR
          AND PLAN_YEAR = LT_KEY_CHECK-PLAN_YEAR
          AND VKBUR = LT_KEY_CHECK-VKBUR.

      IF SY-SUBRC EQ 0.
        " SELECT가 되는 경우에는 이미 DB에 존재하는 데이터 이므로 메시지를 출력하고 중단한다.
        MESSAGE I103 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      " SELECT가 안된 경우 선택한 행들을 DISPLAY 테이블에서 제거한다.
      LOOP AT LT_ROWS INTO LS_ROW.
        DELETE GT_DISPLAY3 INDEX LS_ROW-INDEX.
      ENDLOOP.

      CALL METHOD GO_ALV_GRID4->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' ).

    WHEN '0100'.
      " 선택한 행들의 정보를 받아온다.
      CALL METHOD GO_ALV_GRID2->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROWS.

      " LT_ROWS에는 INDEX 정보만 존재하기 때문에 삭제 가능 여부를 검토하기 위해 사용할 KEY VALUE 들을 DISPLAY TABLE에서 받아온다.
      " 이때 판매계획번호는 [ SP + 년도 + 월 ] 이므로 유효성 검사를 위한 KEY FIELD로의 의미가 없다.
      " DISPLAY 테이블에서는 1월부터 12월의 모든 데이터를 보여주기 때문에 유효성 검사를 위한 KEY FIELD로의 의미가 없다.
      LOOP AT LT_ROWS INTO LS_ROW.
        READ TABLE GT_DISPLAY2 INDEX LS_ROW-INDEX INTO DATA(LS_DATA2).
        IF SY-SUBRC = 0.
          APPEND VALUE #( MATNR = LS_DATA2-MATNR
                          PLAN_YEAR = LS_DATA2-PLAN_YEAR
                          VKBUR = LS_DATA2-VKBUR ) TO LT_KEY_CHECK.
        ENDIF.
      ENDLOOP.

      " 자재번호, 계획년도, 영업장을 기준으로 실제 DB에 존재하는지 여부 확인
      SELECT MATNR SPLAN
        FROM ZCC_VBBS
        INTO TABLE LT_EXISTING
        FOR ALL ENTRIES IN LT_KEY_CHECK
        WHERE MATNR = LT_KEY_CHECK-MATNR
          AND PLAN_YEAR = LT_KEY_CHECK-PLAN_YEAR
          AND VKBUR = LT_KEY_CHECK-VKBUR.

      IF SY-SUBRC EQ 0.
        " SELECT가 되는 경우에는 이미 DB에 존재하는 데이터 이므로 메시지를 출력하고 중단한다.
        MESSAGE I103 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      " SELECT가 안된 경우 선택한 행들을 DISPLAY 테이블에서 제거한다.
      LOOP AT LT_ROWS INTO LS_ROW.
        DELETE GT_DISPLAY2 INDEX LS_ROW-INDEX.
      ENDLOOP.

      CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY
        EXPORTING
          IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )
        EXCEPTIONS
          FINISHED  = 1                " Display was Ended (by Export)
          OTHERS    = 2.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MULTI_SAVE
*&---------------------------------------------------------------------*
FORM CONVERT_MULTI_SAVE  USING    PT_DISPLAY3 TYPE TY_DISPLAY2
                         CHANGING PT_SAVE TYPE TY_SAVE.

  FIELD-SYMBOLS <FS>.
  DATA : LV_MONTH TYPE NUMC2,
         LV_COUNT TYPE INT2,
         LS_SAVE  LIKE LINE OF PT_SAVE.

  LOOP AT PT_DISPLAY3 INTO DATA(LS_DISPLAY3).
    LV_COUNT = 00.
    DO 12 TIMES.
      " 횟수를 카운트 하면 12번 반복함으로써 각 달에 해당하는 계획량에 대한 점검을 진행
      LV_COUNT += 1.
      LV_MONTH = LV_COUNT.

      " 데이터가 들어있는 필드를 동적으로 받기 위해 변수명을 지정함.
      DATA(LV_VBBEZ) = |LS_DISPLAY3-KWMENG_{ LV_MONTH }|.

      " PS_INPUT_SINGLE-KWMENG_{ LV_MONTH }이라는 변수를 <FS>에 할당
      ASSIGN (LV_VBBEZ) TO <FS>.

      IF <FS> IS NOT INITIAL.
        " 기본 정보 채우기
        LS_SAVE-MATNR = LS_DISPLAY3-MATNR.
        LS_SAVE-VKBUR = LS_DISPLAY3-VKBUR.
        LS_SAVE-PLAN_YEAR = LS_DISPLAY3-PLAN_YEAR.
        LS_SAVE-PLAN_MONTH = LV_MONTH.
        LS_SAVE-SPART = LS_DISPLAY3-SPART.
        LS_SAVE-VBBEZ = <FS>.
        LS_SAVE-MEINS = LS_DISPLAY3-MEINS.
        LS_SAVE-STATUS = 'WT'.
        LS_SAVE-ERNAM = SY-UNAME.
        LS_SAVE-ERDAT = SY-DATUM.
        LS_SAVE-ERZET = SY-UZEIT.

        APPEND LS_SAVE TO PT_SAVE.
      ENDIF.
      UNASSIGN <FS>.
    ENDDO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW
*&---------------------------------------------------------------------*
FORM SHOW.

  CALL METHOD GO_ALV_GRID4->GET_SELECTED_CELLS
    IMPORTING
      ET_CELL = DATA(LT_CELL).                 " Selected Cells

  DESCRIBE TABLE LT_CELL LINES DATA(LV_LINES).

  IF LV_LINES NE 1.
    MESSAGE S105 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  READ TABLE LT_CELL INTO DATA(LS_CELL) INDEX 1.

  IF LS_CELL-COL_ID CS 'KWMENG_'.
    DATA(LV_LEN)    = STRLEN( LS_CELL-COL_ID ).
    DATA(LV_OFFSET) = LV_LEN - 2.
    DATA(LV_SUFFIX) = LS_CELL-COL_ID+LV_OFFSET(2).
    READ TABLE GT_DISPLAY3 INTO DATA(LS_DISPLAY) INDEX LS_CELL-ROW_ID.
    IF GV_KPI EQ 'X'.
      READ TABLE GT_KPI INTO DATA(GS_KPI) WITH KEY MATNR = LS_DISPLAY-MATNR
                                                   VKBUR = LS_DISPLAY-VKBUR
                                                   PLAN_MONTH = LV_SUFFIX.

      MESSAGE I107 WITH GS_KPI-PLAN_YEAR GS_KPI-PLAN_MONTH GS_KPI-MATNR GS_KPI-KPI.
    ELSEIF GV_PAI EQ 'X'.
      READ TABLE GT_PAI INTO DATA(GS_PAI) WITH KEY MATNR = LS_DISPLAY-MATNR
                                                   VKBUR = LS_DISPLAY-VKBUR
                                                   PLAN_MONTH = LV_SUFFIX.

      MESSAGE I120 WITH GS_PAI-PLAN_YEAR GS_PAI-PLAN_MONTH GS_PAI-MATNR GS_PAI-PAI.
    ENDIF.

  ELSE.
    MESSAGE I106 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_GRAPH
*&---------------------------------------------------------------------*
FORM SHOW_GRAPH .

  DATA : LV_MONTH TYPE I VALUE 0.

  CALL METHOD GO_ALV_GRID4->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = DATA(LT_ROW_NO).                 " Numeric IDs of Selected Rows

  DESCRIBE TABLE LT_ROW_NO LINES DATA(LV_LINES).

  IF LV_LINES NE 1.
    MESSAGE S114 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  READ TABLE LT_ROW_NO INTO DATA(LS_ROW_NO) INDEX 1.

  CLEAR : GS_DISPLAY3.
  READ TABLE GT_DISPLAY3 INTO GS_DISPLAY3 INDEX LS_ROW_NO-ROW_ID.

  IF GV_KPI EQ 'X'.

    CLEAR : GT_KPI2.

    SELECT FROM @GT_KPI AS T
      FIELDS VKBUR, MATNR, PLAN_YEAR, PLAN_MONTH, KPI
       WHERE MATNR = @GS_DISPLAY3-MATNR
         AND VKBUR = @GS_DISPLAY3-VKBUR
      INTO TABLE @GT_KPI2.

    REFRESH : Y_VALUES, X_TEXTS.

    Y_VALUES-ROWTXT = 'KPI'.
    LOOP AT GT_KPI2 INTO DATA(LS_KPI2).

      CASE LS_KPI2-PLAN_MONTH.
        WHEN 01.
          Y_VALUES-VAL1 = LS_KPI2-KPI.
        WHEN 02.
          Y_VALUES-VAL2 = LS_KPI2-KPI.
        WHEN 03.
          Y_VALUES-VAL3 = LS_KPI2-KPI.
        WHEN 04.
          Y_VALUES-VAL4 = LS_KPI2-KPI.
        WHEN 05.
          Y_VALUES-VAL5 = LS_KPI2-KPI.
        WHEN 06.
          Y_VALUES-VAL6 = LS_KPI2-KPI.
        WHEN 07.
          Y_VALUES-VAL7 = LS_KPI2-KPI.
        WHEN 08.
          Y_VALUES-VAL8 = LS_KPI2-KPI.
        WHEN 09.
          Y_VALUES-VAL9 = LS_KPI2-KPI.
        WHEN 10.
          Y_VALUES-VAL10 = LS_KPI2-KPI.
        WHEN 11.
          Y_VALUES-VAL11 = LS_KPI2-KPI.
        WHEN 12.
          Y_VALUES-VAL12 = LS_KPI2-KPI.
      ENDCASE.
    ENDLOOP.
    APPEND Y_VALUES.

  ELSEIF GV_PAI EQ 'X'.

    CLEAR : GT_PAI2.

    SELECT FROM @GT_PAI AS T
      FIELDS VKBUR, MATNR, PLAN_YEAR, PLAN_MONTH, PAI
       WHERE MATNR = @GS_DISPLAY3-MATNR
         AND VKBUR = @GS_DISPLAY3-VKBUR
      INTO TABLE @GT_PAI2.

    REFRESH : Y_VALUES, X_TEXTS.

    Y_VALUES-ROWTXT = 'KPI'.
    LOOP AT GT_PAI2 INTO DATA(LS_PAI2).

      CASE LS_PAI2-PLAN_MONTH.
        WHEN 01.
          Y_VALUES-VAL1 = LS_PAI2-PAI.
        WHEN 02.
          Y_VALUES-VAL2 = LS_PAI2-PAI.
        WHEN 03.
          Y_VALUES-VAL3 = LS_PAI2-PAI.
        WHEN 04.
          Y_VALUES-VAL4 = LS_PAI2-PAI.
        WHEN 05.
          Y_VALUES-VAL5 = LS_PAI2-PAI.
        WHEN 06.
          Y_VALUES-VAL6 = LS_PAI2-PAI.
        WHEN 07.
          Y_VALUES-VAL7 = LS_PAI2-PAI.
        WHEN 08.
          Y_VALUES-VAL8 = LS_PAI2-PAI.
        WHEN 09.
          Y_VALUES-VAL9 = LS_PAI2-PAI.
        WHEN 10.
          Y_VALUES-VAL10 = LS_PAI2-PAI.
        WHEN 11.
          Y_VALUES-VAL11 = LS_PAI2-PAI.
        WHEN 12.
          Y_VALUES-VAL12 = LS_PAI2-PAI.
      ENDCASE.
    ENDLOOP.
    APPEND Y_VALUES.

  ENDIF.

  DO 12 TIMES.
    LV_MONTH += 1.
    X_TEXTS-COLTXT = |{ LV_MONTH } 월|.
    APPEND X_TEXTS.
  ENDDO.

  CALL SCREEN 0300 STARTING AT 5 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_MAT_INFO
*&---------------------------------------------------------------------*
FORM SHOW_MAT_INFO  USING P_ROW_ID TYPE LVC_S_ROW.

  CASE SY-DYNNR.
    WHEN '0100'.
      CASE TS-ACTIVETAB.
        WHEN 'FC1'.
          READ TABLE GT_DISPLAY1 INTO DATA(LS_DISPLAY1) INDEX P_ROW_ID-INDEX.

          CLEAR : GS_MAT_INFO.

          SELECT SINGLE A~MATNR,
                        B~MAKTG,
                        A~MTART,
                        A~SPART,
                        A~COLOR,
                        A~BRGEW,
                        A~MEINS,
                        A~GEWEI,
                        A~CUSTOM
            FROM ZCC_MARA AS A
            LEFT OUTER JOIN ZCC_MAKT AS B
             ON A~MATNR EQ B~MATNR
            AND B~SPRAS EQ @SY-LANGU
            INTO CORRESPONDING FIELDS OF @GS_MAT_INFO
            WHERE A~MATNR EQ @LS_DISPLAY1-MATNR.
        WHEN 'FC2'.
          READ TABLE GT_DISPLAY2 INTO DATA(LS_DISPLAY2) INDEX P_ROW_ID-INDEX.

          CLEAR : GS_MAT_INFO.

          SELECT SINGLE A~MATNR,
                        B~MAKTG,
                        A~MTART,
                        A~SPART,
                        A~COLOR,
                        A~BRGEW,
                        A~MEINS,
                        A~GEWEI,
                        A~CUSTOM
            FROM ZCC_MARA AS A
            LEFT OUTER JOIN ZCC_MAKT AS B
             ON A~MATNR EQ B~MATNR
            AND B~SPRAS EQ @SY-LANGU
            INTO CORRESPONDING FIELDS OF @GS_MAT_INFO
            WHERE A~MATNR EQ @LS_DISPLAY2-MATNR.
      ENDCASE.


      CALL SCREEN 0310 STARTING AT 5 5.

    WHEN '0200'.
      READ TABLE GT_DISPLAY3 INTO DATA(LS_DISPLAY3) INDEX P_ROW_ID-INDEX.

      CLEAR : GS_MAT_INFO.

      SELECT SINGLE A~MATNR,
                    B~MAKTG,
                    A~MTART,
                    A~SPART,
                    A~COLOR,
                    A~BRGEW,
                    A~MEINS,
                    A~GEWEI,
                    A~CUSTOM
        FROM ZCC_MARA AS A
        LEFT OUTER JOIN ZCC_MAKT AS B
         ON A~MATNR EQ B~MATNR
        AND B~SPRAS EQ @SY-LANGU
        INTO CORRESPONDING FIELDS OF @GS_MAT_INFO
        WHERE A~MATNR EQ @LS_DISPLAY3-MATNR.

      CALL SCREEN 0310 STARTING AT 5 5.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_KPI
*&---------------------------------------------------------------------*
FORM CALCULATE_KPI  CHANGING PT_DISPLAY3 TYPE TY_DISPLAY2.

  DATA : LV_LAST_YEAR  TYPE NUMC2,
         LV_LAST_YEAR2 TYPE NUMC4,
         LS_PERF       TYPE TS_PERF,
         LT_PERF       TYPE TY_PERF,
         LS_PLAN       TYPE TS_PLAN,
         LT_PLAN       TYPE TY_PLAN.

  LV_LAST_YEAR = CONV I( SY-DATUM+2(2) ) - 1.

  " 작년도 판매실적을 가져옴
  CLEAR : GT_DATA1.

  SELECT A~VBELN,
         A~AUART,
         A~VKBUR,
         A~KUNNR,
         A~STATUS,
         A~ERDAT,
         B~MATNR,
         B~SPART,
         B~KWMENG,
         B~MEINS,
         B~NETWR_IT,
         B~WAERS
    FROM ZCC_VBAK AS A
    JOIN ZCC_VBAP AS B
      ON A~VBELN EQ B~VBELN
    WHERE SUBSTRING( A~VBELN, 3, 2 ) EQ @LV_LAST_YEAR
      AND A~STATUS EQ 'ED'
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA1.

  CONCATENATE '20' LV_LAST_YEAR INTO LV_LAST_YEAR2.

  " 작년 판매실적 가공
  LOOP AT GT_DATA1 INTO GS_DATA1.
    MOVE-CORRESPONDING GS_DATA1 TO LS_PERF.
    LS_PERF-PLAN_YEAR = CONV I( SY-DATUM+0(4) ) - 1.
    LS_PERF-PLAN_MONTH = GS_DATA1-VBELN+4(2).
    LS_PERF-KWMENG = GS_DATA1-KWMENG.

    COLLECT LS_PERF INTO LT_PERF.

  ENDLOOP.

  SORT LT_PERF BY VKBUR PLAN_MONTH MATNR.

  " 작년 판매계획 선택
  SELECT VKBUR
         MATNR
         PLAN_YEAR
         PLAN_MONTH
         VBBEZ
    FROM ZCC_VBBS
    INTO CORRESPONDING FIELDS OF TABLE LT_PLAN
    WHERE PLAN_YEAR EQ LV_LAST_YEAR2.

  SORT LT_PLAN BY VKBUR PLAN_MONTH MATNR.

  CLEAR GT_KPI.

  " 작년도 판매실적과 작년도 판매계획을 비교
  LOOP AT LT_PLAN INTO LS_PLAN.

    " LS_PLAN의 데이터를 기준으로 실적 데이터를 가져옴.
    READ TABLE LT_PERF INTO LS_PERF WITH KEY VKBUR = LS_PLAN-VKBUR
                                             PLAN_MONTH = LS_PLAN-PLAN_MONTH
                                             MATNR = LS_PLAN-MATNR
                                             BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      " KPI 계산
      GS_KPI-VKBUR = LS_PLAN-VKBUR.
      GS_KPI-PLAN_YEAR = LS_PLAN-PLAN_YEAR.
      GS_KPI-PLAN_MONTH = LS_PLAN-PLAN_MONTH.
      GS_KPI-MATNR = LS_PLAN-MATNR.
      GS_KPI-KPI = ( 100 * LS_PERF-KWMENG ) / LS_PLAN-VBBEZ.

      APPEND GS_KPI TO GT_KPI.
    ELSE.
      CONTINUE.
    ENDIF.

  ENDLOOP.

  FIELD-SYMBOLS <FS_DISPLAY3> LIKE LINE OF PT_DISPLAY3.

*  SORT PT_DISPLAY3 BY VKBUR MATNR.

  LOOP AT GT_KPI INTO GS_KPI.
    " WA에 있는 데이터를 기준으로 KPI 정보를 가지고 불러온다.
    READ TABLE PT_DISPLAY3 ASSIGNING <FS_DISPLAY3>
                            WITH KEY VKBUR = GS_KPI-VKBUR
                                     MATNR = GS_KPI-MATNR.

    IF SY-SUBRC NE 0.
      CONTINUE.
    ELSE.

      GS_COLFIELD-FNAME = |KWMENG_{ GS_KPI-PLAN_MONTH }|.  " PLAN_MONTH에 해당하는 셀을 지정
      GS_COLFIELD-COLOR-INT = '1'.
      GS_COLFIELD-COLOR-INV = '0'.

      IF GS_KPI-KPI GE 90 AND GS_KPI-KPI LE 110.
        " KPI가 90 ~ 110 사이인 경우 판매계획이 적절했다고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '5'.  " 초록색

      ELSEIF GS_KPI-KPI GE 80 AND GS_KPI-KPI LT 90.
        " KPI가 80 ~ 90인 경우 판매계획이 적절하진 않았다고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '3'.  " 노란색

      ELSEIF GS_KPI-KPI GT 110 AND GS_KPI-KPI LE 120.
        " 110 ~ 120인 경우 판매계획이 적절하진 않았다고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '3'.  " 노란색

      ELSEIF GS_KPI-KPI LT 80 OR GS_KPI-KPI GT 120.
        " KPI가 80보다 작거나 120보다 큰 경우 판매계획이 적절하지 않았다고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '6'.  " 빨간색
      ENDIF.

      APPEND GS_COLFIELD TO <FS_DISPLAY3>-IT_COLFIELD.
      UNASSIGN <FS_DISPLAY3>.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_PAI
*&---------------------------------------------------------------------*
FORM CALCULATE_PAI  CHANGING PT_DISPLAY3 TYPE TY_DISPLAY2.

  DATA : LV_LAST_YEAR TYPE NUMC2,
         LS_PERF      TYPE TS_PERF,
         LT_PERF      TYPE TY_PERF,
         LS_PLAN      TYPE TS_PLAN,
         LT_PLAN      TYPE TY_PLAN.

  LV_LAST_YEAR = CONV I( SY-DATUM+2(2) ) - 1.

  " 작년도 판매실적을 가져옴
  CLEAR : GT_DATA1.

  SELECT A~VBELN,
         A~AUART,
         A~VKBUR,
         A~KUNNR,
         A~STATUS,
         A~ERDAT,
         B~MATNR,
         B~SPART,
         B~KWMENG,
         B~MEINS,
         B~NETWR_IT,
         B~WAERS
    FROM ZCC_VBAK AS A
    JOIN ZCC_VBAP AS B
      ON A~VBELN EQ B~VBELN
    WHERE SUBSTRING( A~VBELN, 3, 2 ) EQ @LV_LAST_YEAR
      AND A~STATUS EQ 'ED'
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA1.

  " 작년 판매실적 가공
  LOOP AT GT_DATA1 INTO GS_DATA1.
    MOVE-CORRESPONDING GS_DATA1 TO LS_PERF.
    LS_PERF-PLAN_YEAR = CONV I( SY-DATUM+0(4) ) - 1.
    LS_PERF-PLAN_MONTH = GS_DATA1-VBELN+4(2).
    LS_PERF-KWMENG = GS_DATA1-KWMENG.

    COLLECT LS_PERF INTO LT_PERF.

  ENDLOOP.

  SORT LT_PERF BY VKBUR PLAN_MONTH MATNR.

  " 작년 판매계획 선택
  SELECT VKBUR
         MATNR
         PLAN_YEAR
         PLAN_MONTH
         VBBEZ
    FROM ZCC_VBBS
    INTO CORRESPONDING FIELDS OF TABLE LT_PLAN
    WHERE PLAN_YEAR EQ SY-DATUM+0(4).

  SORT LT_PLAN BY VKBUR PLAN_MONTH MATNR.

  CLEAR GT_PAI.

  " 작년도 판매실적과 작년도 판매계획을 비교
  LOOP AT LT_PLAN INTO LS_PLAN.

    " LS_PLAN의 데이터를 기준으로 실적 데이터를 가져옴.
    READ TABLE LT_PERF INTO LS_PERF WITH KEY VKBUR = LS_PLAN-VKBUR
                                             PLAN_MONTH = LS_PLAN-PLAN_MONTH
                                             MATNR = LS_PLAN-MATNR
                                             BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      " PAI 계산
      GS_PAI-VKBUR = LS_PLAN-VKBUR.
      GS_PAI-PLAN_YEAR = LS_PLAN-PLAN_YEAR.
      GS_PAI-PLAN_MONTH = LS_PLAN-PLAN_MONTH.
      GS_PAI-MATNR = LS_PLAN-MATNR.
      GS_PAI-PAI = ( 100 * LS_PLAN-VBBEZ ) / LS_PERF-KWMENG.

      APPEND GS_PAI TO GT_PAI.
    ELSE.
      CONTINUE.
    ENDIF.

  ENDLOOP.

  FIELD-SYMBOLS <FS_DISPLAY3> LIKE LINE OF PT_DISPLAY3.

*  SORT PT_DISPLAY3 BY VKBUR MATNR.

  LOOP AT GT_PAI INTO GS_PAI.
    " WA에 있는 데이터를 기준으로 KPI 정보를 가지고 불러온다.
    READ TABLE PT_DISPLAY3 ASSIGNING <FS_DISPLAY3>
                            WITH KEY VKBUR = GS_PAI-VKBUR
                                     MATNR = GS_PAI-MATNR.

    IF SY-SUBRC NE 0.
      CONTINUE.
    ELSE.

      GS_COLFIELD-FNAME = |KWMENG_{ GS_PAI-PLAN_MONTH }|.  " PLAN_MONTH에 해당하는 셀을 지정
      GS_COLFIELD-COLOR-INT = '1'.
      GS_COLFIELD-COLOR-INV = '0'.

      IF GS_PAI-PAI GE 90 AND GS_PAI-PAI LE 110.
        " PAI가 90 ~ 110 사이인 경우 판매계획이 적절하다고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '5'.  " 초록색

      ELSEIF GS_PAI-PAI GT 110 AND GS_PAI-PAI LE 130.
        " PAI가 110 ~ 130인 경우 판매계획이 다소 도전적이라고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '3'.  " 노란색

      ELSEIF GS_PAI-PAI LT 90 OR GS_PAI-PAI GT 130.
        " PAI가 90보다 작거나 130보다 큰 경우 판매계획이 과하게 보수적이거나 도전적이라고 판단할 수 있다.
        GS_COLFIELD-COLOR-COL = '6'.  " 빨간색
      ENDIF.

      APPEND GS_COLFIELD TO <FS_DISPLAY3>-IT_COLFIELD.
      UNASSIGN <FS_DISPLAY3>.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DISPLAY
*&---------------------------------------------------------------------*
FORM INIT_DISPLAY  CHANGING PT_DISPLAY3 TYPE TY_DISPLAY2.

  DATA : LS_DISPLAY3 LIKE LINE OF PT_DISPLAY3.

  LOOP AT PT_DISPLAY3 INTO LS_DISPLAY3.
    CLEAR : LS_DISPLAY3-IT_COLFIELD.
    MODIFY PT_DISPLAY3 FROM LS_DISPLAY3 TRANSPORTING IT_COLFIELD.
  ENDLOOP.

ENDFORM.
