*&---------------------------------------------------------------------*
*& Include          Z2512R0010_088_TOP
*&---------------------------------------------------------------------*
TABLES : BKPF.

TYPES : BEGIN OF TS_DISPLAY,
          BUKRS     TYPE BKPF-BUKRS,       " Company Code
          BELNR     TYPE BKPF-BELNR,       " Document No.
          GJAHR     TYPE BKPF-GJAHR,       " Fiscal Year
          USNAM     TYPE BKPF-USNAM,       " User Name
          NAME_TEXT TYPE ADRP-NAME_TEXT,   " User Name Text
          BLART     TYPE BKPF-BLART,       " Document Type
          BLDAT     TYPE BKPF-BLDAT,       " Document Date
          BUDAT     TYPE BKPF-BUDAT,       " Posting Date
          ATTACH    TYPE ICON-ID,          " Attachment
          BSTAT     TYPE BKPF-BSTAT,       " Document Status
          DDTEXT    TYPE DD07T-DDTEXT,     " Document Status Text ( BSTAT의 Fixed Value )
        END OF TS_DISPLAY,
        TY_DISPLAY TYPE TABLE OF TS_DISPLAY.

DATA : GT_DISPLAY TYPE TY_DISPLAY.

DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_SAVE,
       GS_VARIANT TYPE DISVARIANT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GT_FCAT    TYPE LVC_T_FCAT.

DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.
