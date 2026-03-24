*&---------------------------------------------------------------------*
*& Include MZCC_SD030TOP                            - Module Pool      SAPMZCC_SD030
*&---------------------------------------------------------------------*
PROGRAM SAPMZCC_SD030.
CLASS LCL_APPLICATION   DEFINITION DEFERRED.
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.

TABLES : ZCC_VBAK, ZCC_KNA1, ZCC_VBAP, ZCC_T001, ZCC_QUOT.

* OK_CODE
DATA OK_CODE TYPE SY-UCOMM.

* 필드 잠금을 위한 FLAG 변수
DATA : GV_CLOSE.

* SUBSCEEN의 번호를 담당할 변수
DATA : DYNNR  TYPE SY-DYNNR.

* Tab Strip을 위한 변수 선언
CONTROLS : MY_TAB_STRIP TYPE TABSTRIP.

* 총액을 기록하기 위한 변수
DATA : GV_TOTAL_COST TYPE ZCC_VBAK-NETWR,
* 지불조건을 기록하기 위한 변수
       ZTERM_TXT     TYPE STRING,
* 최종 확인을 위한 변수
       GV_CHECK      TYPE C LENGTH 1,
* 140번 화면 검색 조건을 위한 변수
       GV_KUNNR      TYPE ZCC_QUOT-KUNNR,
       GV_NAME1      TYPE ZCC_QUOT-NAME1.

*&---------------------------------------------------------------------*
* Column Tree를 위한 선언부
*&---------------------------------------------------------------------*
* Tree에 노드를 넣기 위한 Table TYPE 선언
TYPES : ITEM_TABLE_TYPE LIKE TABLE OF MTREEITM.

DATA: NODE_TABLE       TYPE TREEV_NTAB,
      " 노드 데이터를 담는 ITAB 선언
      " 트리 노드에 필요한 키, 관계, 텍스트, 이미지, 상태 등의 필드를 포함
      " 트리 컨트롤에서 노드 데이터를 일괄 전달할 때 사용

      ITEM_TABLE       TYPE ITEM_TABLE_TYPE,        " TREE에 노드를 추가하기 위해 선언한 TABLE TYPE을 통해 ITAB 생성

      " 이벤트의 종류만을 등록하여 프로그램에서 어떤 이벤트를 처리할 것인지 알려주는 역할
      EVENT            TYPE CNTL_SIMPLE_EVENT,      " 단일 이벤트를 표현하는 WA
      EVENTS           TYPE CNTL_SIMPLE_EVENTS,     " 여러 개의 이벤트를 추가하고 트리 컨트롤에 등록하는 ITAB

      " CLASS에는 실제로 이벤트가 발생했을 때 발생할 코드를 작성
      GO_APPLICATION   TYPE REF TO LCL_APPLICATION,

      HIERARCHY_HEADER TYPE TREEV_HHDR.             " 트리 ALV의 각 컬럼의 속성 정의

* DRAG & DROP에 의해 아이템을 추가하기 위해 객체참조변수 생성.
*DATA : GO_DRAGDROP TYPE REF TO CL_DRAGDROP.

* SPLITTER를 위한 객체참조변수 선언
DATA : GO_SPLITTER   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CUSTOM     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

       " SPLITTER CONTAINER를 위한 CONTAINER 선언
       GO_CONTAINER1 TYPE REF TO CL_GUI_CONTAINER,
       GO_CONTAINER2 TYPE REF TO CL_GUI_CONTAINER,

       " ALV를 출력하기 위한 ALV GRID 객체참조변수
       GO_ALV_GRID   TYPE REF TO CL_GUI_ALV_GRID.

DATA : GS_VARIANT TYPE DISVARIANT,
       GV_SAVE,
       GS_LAYO    TYPE LVC_S_LAYO,
       GS_FCAT    TYPE LVC_S_FCAT,
       GT_FCAT    TYPE LVC_T_FCAT.

" Column Tree 생성을 위한 객체참조변수
DATA : G_TREE       TYPE REF TO CL_GUI_COLUMN_TREE.

DATA : GV_KUNNR_SEA VALUE 'X',
       GV_NAME1_SEA.

" 130번 화면을 위한 객체 참조 변수 선언
DATA : GO_CUSTOM2   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_GRID2 TYPE REF TO CL_GUI_ALV_GRID,
       GS_FCAT2     TYPE LVC_S_FCAT,
       GT_FCAT2     TYPE LVC_T_FCAT.

" 140번 화면을 위한 객체 참조 변수 선언
DATA : GO_CUSTOM3   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_GRID3 TYPE REF TO CL_GUI_ALV_GRID,
       GS_FCAT3     TYPE LVC_S_FCAT,
       GT_FCAT3     TYPE LVC_T_FCAT.

*&---------------------------------------------------------------------*
* DATA DISPLAY를 위한 WA와 ITAB 선언
*&---------------------------------------------------------------------*
DATA : BEGIN OF GS_DATA.
         INCLUDE TYPE ZCC_VBAP.
DATA : END OF GS_DATA.
DATA : GT_DATA LIKE TABLE OF GS_DATA.

TYPES : BEGIN OF TS_DISPLAY,
          VBELN     TYPE ZCC_VBAP-VBELN,
          POSNR     TYPE ZCC_VBAP-POSNR,
          MATNR     TYPE ZCC_VBAP-MATNR,
          MAKTG     TYPE ZCC_MAKT-MAKTG,
          SPART     TYPE ZCC_VBAP-SPART,
          SPART_TXT TYPE STRING,
          KWMENG    TYPE ZCC_VBAP-KWMENG,
          MEINS     TYPE ZCC_VBAP-MEINS,
          NETPR     TYPE ZCC_VBAP-NETPR,
          NETWR_IT  TYPE ZCC_VBAP-NETWR_IT,
          WAERS     TYPE ZCC_VBAP-WAERS,
        END OF TS_DISPLAY,
        TT_DISPLAY TYPE TABLE OF TS_DISPLAY.
DATA : GS_DISPLAY TYPE TS_DISPLAY,
       GT_DISPLAY LIKE TABLE OF GS_DISPLAY.

TYPES : BEGIN OF TS_QUOT,
          QUOT_ID   TYPE ZCC_QUOT-QUOT_ID,
          KUNNR     TYPE ZCC_QUOT-KUNNR,
          NAME1     TYPE ZCC_QUOT-NAME1,
          VDATU     TYPE ZCC_QUOT-VDATU,
          QNA_ID    TYPE ZCC_QUOT-QNA_ID,
          STRAS     TYPE ZCC_QUOT-STRAS,
          NAME2     TYPE ZCC_QUOT-NAME2,
          EMAIL     TYPE ZCC_QUOT-EMAIL,
          TELF      TYPE ZCC_QUOT-TELF,
          VKBUR     TYPE ZCC_QUOT-VKBUR,
          KWMENG    TYPE ZCC_QUOT-KWMENG,
          MATNR     TYPE ZCC_QUOT-MATNR,
          MEINS     TYPE ZCC_QUOT-MEINS,
          QUOT_STAT TYPE ZCC_QUOT-QUOT_STAT,
        END OF TS_QUOT,
        TY_QUOT TYPE TABLE OF TS_QUOT.

DATA : GS_QUOT TYPE TS_QUOT,
       GT_QUOT TYPE TY_QUOT.

*&---------------------------------------------------------------------*
* DATA UPDATE를 위한 ITAB 선언
*&---------------------------------------------------------------------*
DATA : GT_VBAK LIKE TABLE OF ZCC_VBAK,
       GT_VBAP LIKE TABLE OF ZCC_VBAP.

" 이벤트 객체 참조 변수 생성
DATA : GO_EVENT TYPE REF TO LCL_EVENT_HANDLER.
