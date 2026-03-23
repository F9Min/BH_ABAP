*&---------------------------------------------------------------------*
*& Include          Z2508R0040_088_TOP
*&---------------------------------------------------------------------*
TABLES : SSCRFIELDS, EKKO, EKPO, LFA1, MAKT, T001W, MARA, EKET.
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.
**********************************************************************
* PO CRAETE
**********************************************************************

*&---------------------------------------------------------------------*
*& 엑셀의 데이터를 받기 위한 테이블
*&---------------------------------------------------------------------*
DATA : GT_TABLINE TYPE TABLE OF ALSMEX_TABLINE.

TYPES : BEGIN OF TS_EXCEL,
          LIFNR TYPE EKKO-LIFNR,  " VENDOR
          MATNR TYPE EKPO-MATNR,  " MATNR
          MENGE TYPE EKPO-MENGE,  " QUANTITY
          MEINS TYPE EKPO-MEINS,  " UNIT
          NETPR TYPE EKPO-NETPR,  " UNITPRICE
          WAERS TYPE EKKO-WAERS,  " CURRENCY
          WERKS TYPE EKPO-WERKS,  " PLANT
          LGORT TYPE EKPO-LGORT,  " STORAGE LOCATION
        END OF TS_EXCEL,
        TY_EXCEL TYPE TABLE OF TS_EXCEL.

DATA : GS_EXCEL TYPE TS_EXCEL,
       GT_EXCEL TYPE TY_EXCEL.
*&---------------------------------------------------------------------*
*& ALV 표시를 위한 테이블
*&---------------------------------------------------------------------*
TYPES : BEGIN OF TS_DISPLAY,
          LIGHT TYPE C LENGTH 4,   " ICON
          LIFNR TYPE EKKO-LIFNR,   " VENDOR
          NAME1 TYPE LFA1-NAME1,   " VENDOR NAME
          MATNR TYPE EKPO-MATNR,   " MATNR
          MAKTX TYPE MAKT-MAKTX,   " MATERIAL NAME
          MENGE TYPE EKPO-MENGE,   " QUANTITY
          MEINS TYPE EKPO-MEINS,   " UNIT
          NETPR TYPE EKPO-NETPR,   " UNITPRICE
          SUM   TYPE EKPO-NETPR,   " SUM
          WAERS TYPE EKKO-WAERS,   " CURRENCY
          WERKS TYPE EKPO-WERKS,   " PLANT
          LGORT TYPE EKPO-LGORT,   " STORAGE LOCATION
          EBELN TYPE EKKO-EBELN,   " PO NUMBER
          MSG   TYPE STRING,       " MESSAGE
        END OF TS_DISPLAY,
        TY_DISPLAY TYPE TABLE OF TS_DISPLAY.

DATA : GS_DISPLAY TYPE TS_DISPLAY,
       GT_DISPLAY TYPE TY_DISPLAY.

*&---------------------------------------------------------------------*
*& 유효성 검사를 위한 테이블
*&---------------------------------------------------------------------*
TYPES : BEGIN OF TS_LFA1,
          LIFNR TYPE LFA1-LIFNR,
          NAME1 TYPE LFA1-NAME1,
        END OF TS_LFA1,
        TY_LFA1 TYPE TABLE OF TS_LFA1,

        BEGIN OF TS_MAKT,
          MATNR TYPE MAKT-MATNR,
          MAKTX TYPE MAKT-MAKTX,
        END OF TS_MAKT,
        TY_MAKT TYPE TABLE OF TS_MAKT.

*&---------------------------------------------------------------------*
*& BDC 사용을 위한 데이터 선언
*&---------------------------------------------------------------------*
DATA : GT_BDCDATA TYPE TABLE OF BDCDATA,    " BDC 데이터 관련
       GT_BDCMSG  TYPE TABLE OF BDCMSGCOLL, " BDC 메시지 관련
       GS_BDCMSG  TYPE BDCMSGCOLL,
       GS_OPT     TYPE CTU_PARAMS.          " BDC 옵션 관련

DATA : GV_EXCLUDE.                          " APPLICATION TOOLBAR 버튼의 동적 조절을 위한 변수 선언

*&---------------------------------------------------------------------*
*& ALV를 표기하기 위한 변수 선언
*&---------------------------------------------------------------------*
DATA : GO_DOCKING    TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_SPLITTER   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CONTAINER1 TYPE REF TO CL_GUI_CONTAINER,
       GO_CONTAINER2 TYPE REF TO CL_GUI_CONTAINER,
       GO_ALV_GRID   TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID2  TYPE REF TO CL_GUI_ALV_GRID,
       GS_VARIANT    TYPE DISVARIANT,
       GV_SAVE.

DATA : GT_FCAT  TYPE LVC_T_FCAT,
       GT_FCAT2 TYPE LVC_T_FCAT,
       GS_LAYO  TYPE LVC_S_LAYO,
       GS_LAYO2 TYPE LVC_S_LAYO.

**********************************************************************
* PO MODIFICATION
**********************************************************************
TYPES : TS_EKKO   TYPE BAPIMEPOHEADER,
        TS_EKKOX  TYPE BAPIMEPOHEADERX,
        TY_RETURN LIKE TABLE OF BAPIRET2,
        TY_EKPO   LIKE TABLE OF BAPIMEPOITEM,
        TY_EKPOX  LIKE TABLE OF BAPIMEPOITEMX,
        TY_EKET   LIKE TABLE OF BAPIMEPOSCHEDULE,
        TS_EKET   TYPE LINE OF TY_EKET,
        TY_EKETX  LIKE TABLE OF BAPIMEPOSCHEDULX,
        TS_EKETX  TYPE LINE OF TY_EKETX.

TYPES : BEGIN OF TS_HEADER,
          BTN            TYPE ICON_D,
          WERKS          TYPE EKPO-WERKS,
          LIFNR          TYPE EKKO-LIFNR,
          NAME1          TYPE LFA1-NAME1,
          PO_COUNT       TYPE I,              " 누적 PO 수 : TYPE에 대한 확인 필요
          PO_TOTAL_COUNT TYPE I,              " 총 수량 : PO의 누적 수량
          MEINS          TYPE EKPO-MEINS,     " 단위에 따라 누적 PO와 총 수량 구분해서 표기 < 하나의 플랜트 공급업체가 여러 번 출력될 수도 있음.
          TOTAL_NETWR    TYPE EKPO-NETWR,
          WAERS          TYPE EKKO-WAERS,
          LOEKZ,
        END OF TS_HEADER,
        TY_HEADER TYPE TABLE OF TS_HEADER,

        BEGIN OF TS_ITEM,
          EDIT       TYPE C,
          STATUS     TYPE ICON-ID,
          EBELN      TYPE EKPO-EBELN,
          EBELP      TYPE EKPO-EBELP,
          MATNR      TYPE EKPO-MATNR,
          MAKTX      TYPE MAKT-MAKTX,
*          PAST_PO  TYPE I,                    " 과거 PO 수 : TYPE에 대한 확인 필요
*          LADAT    TYPE SY-DATUM,
*          INV_STAT TYPE ICON-STATUS,
*          AMT_STAT TYPE ICON-STATUS,
*          ELD_STAT TYPE ICON-STATUS,
          MENGE      TYPE EKPO-MENGE,
          MEINS      TYPE EKPO-MEINS,
          NETPR      TYPE EKPO-NETPR,
          WAERS      TYPE EKKO-WAERS,
          SUM        TYPE EKPO-NETWR,
          EINDT      TYPE EKET-EINDT,          " 납품일
          BEDAT      TYPE EKKO-BEDAT,          " 증빙일
          MSG        TYPE C LENGTH 100,
          LOEKZ,
          CHANGED,
          CELLSTYL   TYPE LVC_T_STYL,
          RETURN_MSG TYPE BAPIRET2_T,
          COLOR      TYPE C LENGTH 4,
        END OF TS_ITEM,
        TY_ITEM TYPE TABLE OF TS_ITEM.

DATA : GT_HEADER      TYPE TY_HEADER,
       GS_HEADER      TYPE TS_HEADER,
       GT_ITEM        TYPE TY_ITEM,
       GS_ITEM        TYPE TS_ITEM,
       GT_ITEM_BACKUP TYPE TY_ITEM.

*&---------------------------------------------------------------------*
*& 기타 데이터 선언
*&---------------------------------------------------------------------*
DATA : OK_CODE   TYPE SY-UCOMM,
       GV_OFF,
       GV_RESULT.
