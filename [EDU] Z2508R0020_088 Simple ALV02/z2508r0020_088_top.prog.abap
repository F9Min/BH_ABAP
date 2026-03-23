*&---------------------------------------------------------------------*
*& Include          Z2508R010_088_TOP
*&---------------------------------------------------------------------*
TABLES : EKKO.

TYPES : BEGIN OF TS_DISPLAY,
          EBELN       TYPE EKKO-EBELN,
          BEDAT       TYPE EKKO-BEDAT,
          LIFNR       TYPE EKKO-LIFNR,
          NAME1       TYPE LFA1-NAME1,
          ERNAM       TYPE EKKO-ERNAM,
          TOTAL_NETWR TYPE EKPO-NETWR,
          WAERS       TYPE EKKO-WAERS,
        END OF TS_DISPLAY,
        TY_DISPLAY TYPE TABLE OF TS_DISPLAY.

DATA : GS_DISPLAY TYPE TS_DISPLAY,
       GT_DISPLAY TYPE TY_DISPLAY.

*&---------------------------------------------------------------------< 250806 : ITEM ITAB 추가
TYPES : BEGIN OF TS_ITEM,
          EBELN TYPE EKPO-EBELN,
          EBELP TYPE EKPO-EBELP,
          MATNR TYPE EKPO-MATNR,
          MAKTX TYPE MAKT-MAKTX,
          LGOBE TYPE T001L-LGOBE,
          MENGE TYPE EKPO-MENGE,
          MEINS TYPE EKPO-MEINS,
          NETPR TYPE EKPO-NETPR,
          NETWR TYPE EKPO-NETWR,
          WAERS TYPE EKKO-WAERS,
        END OF TS_ITEM,
        TY_ITEM TYPE TABLE OF TS_ITEM.

DATA : GS_ITEM TYPE TS_ITEM,
       GT_ITEM TYPE TY_ITEM.

DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_SAVE,
       GS_VARIANT   TYPE DISVARIANT,
       GS_LAYO      TYPE LVC_S_LAYO,
       GS_LAYO_ITEM TYPE LVC_S_LAYO,
       GT_FCAT      TYPE LVC_T_FCAT,
*&---------------------------------------------------------------------< 250806 : ITEM ALV의 FCAT 추가
       GT_FCAT_ITEM TYPE LVC_T_FCAT.

DATA : GO_DOCKING    TYPE REF TO CL_GUI_DOCKING_CONTAINER,
*&---------------------------------------------------------------------< 250806 : 스펙서에 따른 SPLITTER CONTAINER 도입
       GO_SPLITTER   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CONTAINER1 TYPE REF TO CL_GUI_CONTAINER,
       GO_CONTAINER2 TYPE REF TO CL_GUI_CONTAINER,
       GO_ALV_GRID   TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID2  TYPE REF TO CL_GUI_ALV_GRID.
