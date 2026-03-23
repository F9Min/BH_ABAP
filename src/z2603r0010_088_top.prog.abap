*&---------------------------------------------------------------------*
*& Include          Z2603R0010_088_TOP
*&---------------------------------------------------------------------*
TABLES : SPFLI, SCARR, SBOOK.
**********************************************************************
* Variables
**********************************************************************
DATA : GV_SPMON TYPE SPMON.

DATA : GV_START_DATE TYPE SY-DATUM,
       GV_END_DATE   TYPE SY-DATUM.
**********************************************************************
* Field Symbol
**********************************************************************
FIELD-SYMBOLS : <GT_ALV>   TYPE STANDARD TABLE,
                <GS_ALV>   TYPE ANY,
                <GV_ALV>   TYPE ANY,
                <GV_COLOR> TYPE LVC_T_SCOL.
**********************************************************************
* TYPES
**********************************************************************
TYPES : BEGIN OF TS_DATA,
          CARRID   TYPE SPFLI-CARRID,     " 항공사코드
          CARRNAME TYPE SCARR-CARRNAME,   " 항공사명
          FLDATE   TYPE SBOOK-FLDATE,     " 항공편 일자
          COUNT    TYPE I,
        END OF TS_DATA,
        TY_DATA TYPE TABLE OF TS_DATA.

TYPES : BEGIN OF TS_DETAIL,
          BOOKID     TYPE SBOOK-BOOKID,       " 예약번호
          CUSTOMID   TYPE SBOOK-CUSTOMID,     " 고객번호
          CUSTTYPE   TYPE SBOOK-CUSTTYPE,     " 고객유형
          ORDER_DATE TYPE SBOOK-ORDER_DATE,   " 예약일
          INVOICE    TYPE SBOOK-INVOICE,      " 송장표시
          LOCCURAM   TYPE SBOOK-LOCCURAM,     " 현지통화 예약가격
          LOCCURKEY  TYPE SBOOK-LOCCURKEY,    " 현지통화
          CANCELLED  TYPE SBOOK-CANCELLED,    " 취소여부
        END OF TS_DETAIL,
        TY_DETAIL TYPE TABLE OF TS_DETAIL.
**********************************************************************
* ITAB
**********************************************************************
DATA : GT_DATA   TYPE TY_DATA,
       GT_DETAIL TYPE TY_DETAIL.

DATA : GT_DISPLAY TYPE REF TO DATA.

DATA : BEGIN OF GS_CAL,
         CARRID   TYPE SPFLI-CARRID,
         CARRNAME TYPE SCARR-CARRNAME,
         SUM      TYPE INT4,
         AVG      TYPE INT4,
       END OF GS_CAL,
       GT_CAL LIKE TABLE OF GS_CAL.
**********************************************************************
* ALV
**********************************************************************
DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_SAVE        VALUE 'X',
       GS_VARIANT     TYPE DISVARIANT,
       GS_LAYO        TYPE LVC_S_LAYO,
       GS_LAYO_DETAIL TYPE LVC_S_LAYO,
       GT_FCAT        TYPE LVC_T_FCAT,
       GT_FCAT_DETAIL TYPE LVC_T_FCAT.

DATA : GO_DOCKING    TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_SPLITTER   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CONTAINER1 TYPE REF TO CL_GUI_CONTAINER,
       GO_CONTAINER2 TYPE REF TO CL_GUI_CONTAINER,
       GO_ALV_GRID1  TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID2  TYPE REF TO CL_GUI_ALV_GRID.
