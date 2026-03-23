*&---------------------------------------------------------------------*
*& Include          Z2512R0020_088_TOP
*&---------------------------------------------------------------------*
TABLES : ACDOCA.

**********************************************************************
* Data Selection을 위한 Type, Data
**********************************************************************
TYPES : BEGIN OF TS_DATA,
          RLDNR      TYPE ACDOCA-RLDNR,
          RBUKRS     TYPE ACDOCA-RBUKRS,
          AUTYP      TYPE ACDOCA-AUTYP,
          RACCT      TYPE ACDOCA-RACCT,
          BUDAT      TYPE ACDOCA-BUDAT,
          AUFNR      TYPE ACDOCA-AUFNR,
          HSL        TYPE ACDOCA-HSL,
          XREVERSING TYPE ACDOCA-XREVERSING,
          XREVERSED  TYPE ACDOCA-XREVERSED,
        END OF TS_DATA,
        TY_DATA TYPE TABLE OF TS_DATA.

DATA : GT_DATA TYPE TY_DATA.

**********************************************************************
* Display를 위한 Type, Data
**********************************************************************
TYPES : BEGIN OF TS_DISPLAY,
          ICON      TYPE ICON-ID,            " Status
          RBUKRS    TYPE ACDOCA-RBUKRS,      " Company Code
          GJAHR     TYPE ACDOCA-GJAHR,       " Year
          POPER     TYPE C LENGTH 2,         " Period
          ORDGP     TYPE CHAR20,             " Order Group, FIELD11
          ORDGP_TXT TYPE CHAR40,             " Order Group Text, FIELD14
          HIGHEST   TYPE C,                  " Highest, FIELD01
          AUFNR     TYPE ACDOCA-AUFNR,       " Order
          HSL       TYPE ACDOCA-HSL,         " Amount
          MSG       TYPE C LENGTH 100,       " Message
        END OF TS_DISPLAY,
        TY_DISPLAY TYPE TABLE OF TS_DISPLAY.

DATA : GT_DISPLAY TYPE TY_DISPLAY.
