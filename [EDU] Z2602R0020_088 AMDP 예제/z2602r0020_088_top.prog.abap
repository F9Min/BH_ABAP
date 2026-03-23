*&---------------------------------------------------------------------*
*& Include          Z2602R0020_088_TOP
*&---------------------------------------------------------------------*
TABLES : VBAK.

**********************************************************************
* AMDP CLASS
**********************************************************************
DATA : GT_RESULT    TYPE ZCL_AMDP_SAELS_INCENTIVE=>TT_COMPLEX_RESULT,
       LO_INCENTIVE TYPE REF TO ZCL_AMDP_SAELS_INCENTIVE.

**********************************************************************
* Variable
**********************************************************************
DATA : OK_CODE TYPE SY-UCOMM.

**********************************************************************
* TYPES
**********************************************************************
TYPES : BEGIN OF TS_DISPLAY.
          INCLUDE TYPE ZCL_AMDP_SAELS_INCENTIVE=>TY_COMPLEX_RESULT.
TYPES :   NAME_TEXTC   TYPE USER_ADDR-NAME_TEXTC
        , BONUS_AMOUNT TYPE NETWR
        , COLOR_TAB    TYPE LVC_T_SCOL
      , END OF TS_DISPLAY
      , TT_DISPLAY TYPE TABLE OF TS_DISPLAY.

TYPES : BEGIN OF TS_NAMES
      , BNAME TYPE USER_ADDR-BNAME
      , NAME_TEXTC TYPE USER_ADDR-NAME_TEXTC
, END   OF TS_NAMES
, TT_NAMES TYPE TABLE OF TS_NAMES.

**********************************************************************
* ITAB
**********************************************************************
DATA : GS_DISPLAY TYPE TS_DISPLAY
       , GT_DISPLAY TYPE TT_DISPLAY.

DATA : GT_NAMES TYPE TT_NAMES.

**********************************************************************
* ALV
**********************************************************************
DATA : GV_SAVE,
       GS_VARIANT TYPE DISVARIANT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GT_FCAT    TYPE LVC_T_FCAT.

DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.
