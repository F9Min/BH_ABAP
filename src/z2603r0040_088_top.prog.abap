*&---------------------------------------------------------------------*
*& Include          Z2603R0040_088_TOP
*&---------------------------------------------------------------------*
TABLES : EKKO.
**********************************************************************
* TYPES
**********************************************************************
TYPES : BEGIN OF TS_DATA,
          EBELN TYPE EKKO-EBELN,
          EBELP TYPE EKPO-EBELP,
          MATNR TYPE EKPO-MATNR,
          MAKTX TYPE MAKT-MAKTX,
        END OF TS_DATA,
        TY_DATA TYPE TABLE OF TS_DATA.
**********************************************************************
* ITAB
**********************************************************************
DATA : GS_DATA TYPE TS_DATA,
       GT_DATA TYPE TY_DATA.

DATA : BEGIN OF GS_POPUP,
         MATNR TYPE MARA-MATNR,
         MAKTX TYPE MAKT-MAKTX,
       END   OF GS_POPUP.
**********************************************************************
* ALV
**********************************************************************
DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_SAVE,
       GS_VARIANT TYPE DISVARIANT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GT_FCAT    TYPE LVC_T_FCAT.

DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.
