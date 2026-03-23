*&---------------------------------------------------------------------*
*& Include          Z2603R0020_088_TOP
*&---------------------------------------------------------------------*
DATA : GT_DATA TYPE REF TO DATA.
FIELD-SYMBOLS : <FS_TABLE> TYPE ANY TABLE.

**********************************************************************
* ALV
**********************************************************************
DATA : OK_CODE    TYPE SY-UCOMM,
       GV_SAVE    VALUE 'X',
       GS_VARIANT TYPE DISVARIANT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GT_FCAT TYPE LVC_T_FCAT.

DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.
