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

DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_SAVE,
       GS_VARIANT TYPE DISVARIANT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GT_FCAT    TYPE LVC_T_FCAT.

DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.
