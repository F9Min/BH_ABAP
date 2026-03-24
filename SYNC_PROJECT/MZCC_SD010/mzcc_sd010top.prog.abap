*&---------------------------------------------------------------------*
*& Include MZCC_SD010TOP                            - Module Pool      SAPMZCC_SD010
*&---------------------------------------------------------------------*
PROGRAM SAPMZCC_SD010 MESSAGE-ID ZCC_MSG.
TABLES : ZCC_VBAK, ZCC_VBBS, SSCRFIELDS.
TYPE-POOLS : GFW.

* DATA DISPLAY 를 위한 GLOBAL TYPE 선언
TYPES : BEGIN OF TS_DISPLAY,
          VKBUR     TYPE ZCC_VBBS-VKBUR,       " 영업장
          MATNR     TYPE ZCC_VBAP-MATNR,       " 자재번호
          MAKTG     TYPE ZCC_MAKT-MAKTG,       " 자재명
          SPART     TYPE ZCC_VBAP-SPART,       " 제품군 번호
          SPART_TXT TYPE STRING,               " 제품군명
          PLAN_YEAR TYPE ZCC_VBBS-PLAN_YEAR,    " 년도
          KWMENG_01 TYPE ZCC_VBAP-KWMENG,      " 1월 판매량
          KWMENG_02 TYPE ZCC_VBAP-KWMENG,      " 2월 판매량
          KWMENG_03 TYPE ZCC_VBAP-KWMENG,      " 3월 판매량
          KWMENG_04 TYPE ZCC_VBAP-KWMENG,      " 4월 판매량
          KWMENG_05 TYPE ZCC_VBAP-KWMENG,      " 5월 판매량
          KWMENG_06 TYPE ZCC_VBAP-KWMENG,      " 6월 판매량
          KWMENG_07 TYPE ZCC_VBAP-KWMENG,      " 7월 판매량
          KWMENG_08 TYPE ZCC_VBAP-KWMENG,      " 8월 판매량
          KWMENG_09 TYPE ZCC_VBAP-KWMENG,      " 9월 판매량
          KWMENG_10 TYPE ZCC_VBAP-KWMENG,      " 10월 판매량
          KWMENG_11 TYPE ZCC_VBAP-KWMENG,      " 11월 판매량
          KWMENG_12 TYPE ZCC_VBAP-KWMENG,      " 12월 판매량
          MEINS     TYPE ZCC_VBAP-MEINS,       " 수량 단위
        END OF TS_DISPLAY,
        TY_DISPLAY TYPE TABLE OF TS_DISPLAY.

TYPES : BEGIN OF TS_DISPLAY2,
          VKBUR       TYPE ZCC_VBBS-VKBUR,       " 영업장
          MATNR       TYPE ZCC_VBAP-MATNR,       " 자재번호
          MAKTG       TYPE ZCC_MAKT-MAKTG,       " 자재명
          SPART       TYPE ZCC_VBAP-SPART,       " 제품군 번호
          SPART_TXT   TYPE STRING,               " 제품군명
          PLAN_YEAR   TYPE ZCC_VBBS-PLAN_YEAR,    " 년도
          KWMENG_01   TYPE ZCC_VBAP-KWMENG,      " 1월 판매량
          KWMENG_02   TYPE ZCC_VBAP-KWMENG,      " 2월 판매량
          KWMENG_03   TYPE ZCC_VBAP-KWMENG,      " 3월 판매량
          KWMENG_04   TYPE ZCC_VBAP-KWMENG,      " 4월 판매량
          KWMENG_05   TYPE ZCC_VBAP-KWMENG,      " 5월 판매량
          KWMENG_06   TYPE ZCC_VBAP-KWMENG,      " 6월 판매량
          KWMENG_07   TYPE ZCC_VBAP-KWMENG,      " 7월 판매량
          KWMENG_08   TYPE ZCC_VBAP-KWMENG,      " 8월 판매량
          KWMENG_09   TYPE ZCC_VBAP-KWMENG,      " 9월 판매량
          KWMENG_10   TYPE ZCC_VBAP-KWMENG,      " 10월 판매량
          KWMENG_11   TYPE ZCC_VBAP-KWMENG,      " 11월 판매량
          KWMENG_12   TYPE ZCC_VBAP-KWMENG,      " 12월 판매량
          MEINS       TYPE ZCC_VBAP-MEINS,       " 수량 단위
          IT_COLFIELD TYPE LVC_T_SCOL,           " 셀 색상 표기를 위한 필드
          STYLE       TYPE LVC_T_STYL,           " 현재 월에 따라 키 필드의 편집 가능 여부를 제한하기 위한 STYLE 필드
        END OF TS_DISPLAY2,
        TY_DISPLAY2 TYPE TABLE OF TS_DISPLAY2.

TYPES : TY_SAVE TYPE TABLE OF ZCC_VBBS.

*&---------------------------------------------------------------------*
* 판매실적을 위한 DATA 선언
DATA : BEGIN OF GS_DATA1,
         VBELN     TYPE ZCC_VBAK-VBELN,    " 판매오더번호
         AUART     TYPE ZCC_VBAK-AUART,    " 판매오더유형
         VKBUR     TYPE ZCC_VBAK-VKBUR,    " 영업장
         KUNNR     TYPE ZCC_VBAK-KUNNR,    " 고객ID
         STATUS    TYPE ZCC_VBAK-STATUS,   " 판매오더상태
         ERDAT     TYPE ZCC_VBAK-ERDAT,    " 생산 날짜
         MATNR     TYPE ZCC_VBAP-MATNR,    " 자재번호
         MAKTG     TYPE ZCC_MAKT-MAKTG,    " 자재명
         SPART     TYPE ZCC_VBAP-SPART,    " 제품군
         SPART_TXT TYPE STRING,            " 제품군명
         KWMENG    TYPE ZCC_VBAP-KWMENG,   " 주문수량
         MEINS     TYPE ZCC_VBAP-MEINS,    " 수량단위
         NETWR_IT  TYPE ZCC_VBAP-NETWR_IT, " 아이템 별 순금액 합계
         WAERS     TYPE ZCC_VBAP-WAERS,    " 통화단위
       END OF GS_DATA1,
       GT_DATA1 LIKE TABLE OF GS_DATA1.

DATA : GS_DISPLAY1 TYPE TS_DISPLAY,
       GT_DISPLAY1 TYPE TY_DISPLAY.

* 판매계획생성을 위한 선언
DATA : GT_DATA2 LIKE TABLE OF ZCC_VBBS.

DATA : GS_DISPLAY2 TYPE TS_DISPLAY,
       GT_DISPLAY2 TYPE TY_DISPLAY.

* 셀 색상 정보를 다루기 위한 필드를 추가한 WA 선언
DATA : GS_DISPLAY3 TYPE TS_DISPLAY2,
       GT_DISPLAY3 LIKE TABLE OF GS_DISPLAY3,
       GS_COLFIELD LIKE LINE OF GS_DISPLAY3-IT_COLFIELD.

* 판매계획 단건생성을 위한 WA
DATA : GS_INPUT_SINGLE TYPE TS_DISPLAY.

* 판매계획 저장을 위한 선언
DATA : GT_SAVE  TYPE TY_SAVE.

*&---------------------------------------------------------------------*
* ALV 출력을 위한 객체 참조 변수 선언
DATA : GO_CUSTOM1   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_CUSTOM2   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_CUSTOM3   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_SPLITTER  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON1      TYPE REF TO CL_GUI_CONTAINER,
       GO_CON2      TYPE REF TO CL_GUI_CONTAINER,
       GO_CON3      TYPE REF TO CL_GUI_CONTAINER,
       GO_ALV_GRID1 TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID2 TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID3 TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID4 TYPE REF TO CL_GUI_ALV_GRID.

DATA : GS_FCAT     TYPE LVC_S_FCAT,
       GT_FCAT     TYPE LVC_T_FCAT,
       GT_FCAT2    TYPE LVC_T_FCAT,
       GS_LAYO     TYPE LVC_S_LAYO,
       GS_LAYO2    TYPE LVC_S_LAYO,
       GS_VARIANT  TYPE DISVARIANT,
       GS_VARIANT2 TYPE DISVARIANT,
       GV_SAVE     TYPE C LENGTH 1.

" Top-of-page를 위한 DATA 선언
DATA : GO_DOCUMENT TYPE REF TO CL_DD_DOCUMENT.
DATA : GO_HTML TYPE REF TO CL_GUI_HTML_VIEWER.

*&---------------------------------------------------------------------*
* 추가 데이터 선언
CONSTANTS : GC_PERFORM(4) VALUE 'PERF',
            GC_PLAN(4)    VALUE 'PLAN'.

* OK_CODE 선언
DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_BLOCK_VISIBLE TYPE C LENGTH 1,
       GV_EDIT.

DATA : GV_TITLE TYPE SY-TITLE.
DATA : GV_TABTYPE(4).
DATA : GV_HIDE01 ,
       GV_HIDE02.

*&---------------------------------------------------------------------*
* TABSTRIP을 제어하기 위한 변수
CONTROLS : TS TYPE TABSTRIP.
DATA : DYNNR  TYPE SY-DYNNR.

*&---------------------------------------------------------------------*
* 그래프를 출력하기 위한 변수
DATA : Y_VALUES TYPE TABLE OF GPRVAL WITH HEADER LINE,
       X_TEXTS  TYPE TABLE OF GPRTXT WITH HEADER LINE.

*&---------------------------------------------------------------------*
* 자재 정보를 보관하기 위한 WA
DATA : BEGIN OF GS_MAT_INFO,
         MATNR  TYPE ZCC_MARA-MATNR,
         MAKTG  TYPE ZCC_MAKT-MAKTG,
         MTART  TYPE ZCC_MARA-MTART,
         SPART  TYPE ZCC_MARA-SPART,
         COLOR  TYPE ZCC_MARA-COLOR,
         BRGEW  TYPE ZCC_MARA-BRGEW,
         MEINS  TYPE ZCC_MARA-MEINS,
         GEWEI  TYPE ZCC_MARA-GEWEI,
         CUSTOM TYPE ZCC_MARA-CUSTOM,
       END OF GS_MAT_INFO.

*&---------------------------------------------------------------------*
* KPI와 PAI를 관리하기 위한 WA와 ITAB

* KPI 관리를 위한 WA와 ITAB 선언
DATA : BEGIN OF GS_KPI,
         VKBUR      TYPE ZCC_VBBS-VKBUR,        " 영업장
         MATNR      TYPE ZCC_VBBS-MATNR,        " 자재번호
         PLAN_YEAR  TYPE ZCC_VBBS-PLAN_YEAR,    " 년도
         PLAN_MONTH TYPE ZCC_VBBS-PLAN_MONTH,   " 월
         KPI        TYPE P DECIMALS 2,          " KPI
       END OF GS_KPI,
       GT_KPI  LIKE TABLE OF GS_KPI,
       " 그래프를 출력하기 위한 KPI ITAB 선언
       GT_KPI2 LIKE TABLE OF GS_KPI.

* PAI 관리를 위한 WA와 ITAB 선언
DATA : BEGIN OF GS_PAI,
         VKBUR      TYPE ZCC_VBBS-VKBUR,        " 영업장
         MATNR      TYPE ZCC_VBBS-MATNR,        " 자재번호
         PLAN_YEAR  TYPE ZCC_VBBS-PLAN_YEAR,    " 년도
         PLAN_MONTH TYPE ZCC_VBBS-PLAN_MONTH,   " 월
         PAI        TYPE P DECIMALS 2,          " PAI
       END OF GS_PAI,
       GT_PAI  LIKE TABLE OF GS_PAI,
       " 그래프를 출력하기 위한 PAI ITAB 선언
       GT_PAI2 LIKE TABLE OF GS_PAI.

* 판매실적을 담기 위한 TYPES 선언
TYPES : BEGIN OF TS_PERF,
          VKBUR      TYPE ZCC_VBAK-VKBUR,         " 계약 영업장
          MATNR      TYPE ZCC_VBAP-MATNR,         " 주문 제품 ID
          PLAN_YEAR  TYPE ZCC_VBBS-PLAN_YEAR,     " 주문 년도
          PLAN_MONTH TYPE ZCC_VBBS-PLAN_MONTH,    " 주문 월
          KWMENG     TYPE ZCC_VBAP-KWMENG,        " 주문수량
        END OF TS_PERF,
        TY_PERF TYPE TABLE OF TS_PERF.

* 판매계획을 담기 위한 TYPES 선언
TYPES : BEGIN OF TS_PLAN,
          VKBUR      TYPE ZCC_VBBS-VKBUR,         " 계획 영업장
          MATNR      TYPE ZCC_VBBS-MATNR,         " 계획 제품 ID
          PLAN_YEAR  TYPE ZCC_VBBS-PLAN_YEAR,     " 주문 년도
          PLAN_MONTH TYPE ZCC_VBBS-PLAN_MONTH,    " 주문 월
          VBBEZ      TYPE ZCC_VBBS-VBBEZ,         " 계획량
        END OF TS_PLAN,
        TY_PLAN TYPE TABLE OF TS_PLAN.

* 판매계획을 담기 위한 TYPES 선언

* KPI와 PAI 적용 버튼 관리를 위한 변수 선언
DATA : GV_KPI,
       GV_PAI.
