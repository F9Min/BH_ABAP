*&---------------------------------------------------------------------*
*& Include          MZCC_SD010SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& 판매실적 SUBSCREEN
*&---------------------------------------------------------------------*
* Subscreen을 활용한 Selection 생성을 위한 SELECTION-SCREEN 생성
SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-H01.

    PARAMETERS : P_GJAHR TYPE ZCC_VBBS-PLAN_YEAR OBLIGATORY MODIF ID R1.                         " 판매년도
    SELECT-OPTIONS : SO_VKBUR FOR ZCC_VBBS-VKBUR MODIF ID R1,                                    " 영업장
                     SO_KUNNR FOR ZCC_VBAK-KUNNR MODIF ID R1,                                    " 고객사
                     SO_VBELN FOR ZCC_VBAK-VBELN MODIF ID R1 MATCHCODE OBJECT ZCC_SH_VBELN_SO,   " 판매오더번호
                     SO_MONAT FOR ZCC_VBBS-PLAN_MONTH MODIF ID R1,                               " 조회월
                     SO_SPART FOR ZCC_VBBS-SPART MODIF ID R1,                                    " 제품군
                     SO_MATNR FOR ZCC_VBBS-MATNR MODIF ID R1.                                    " 자재번호

*    SELECTION-SCREEN PUSHBUTTON /POS_LOW(30) BTN_TXT USER-COMMAND SHOW_AND_HIDE MODIF ID R1.

  SELECTION-SCREEN END OF BLOCK B1.
SELECTION-SCREEN END OF SCREEN 1100.
*&---------------------------------------------------------------------*
*& 판매계획 SUBSCREEN
*&---------------------------------------------------------------------*
* Subscreen을 활용한 Selection 생성을 위한 SELECTION-SCREEN 생성
SELECTION-SCREEN BEGIN OF SCREEN 1200 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-H01.

    PARAMETERS : P_GJAHR2 TYPE ZCC_VBBS-PLAN_YEAR OBLIGATORY MODIF ID R2.       " 계획년도
    SELECT-OPTIONS : SO_VKBU2 FOR ZCC_VBBS-VKBUR MODIF ID R2,                   " 영업장
                     SO_VBEL2 FOR ZCC_VBBS-SPLAN MODIF ID R2,                   " 판매계획번호
                     SO_MONA2 FOR ZCC_VBBS-PLAN_MONTH MODIF ID R2,              " 계획월
                     SO_MATN2 FOR ZCC_VBBS-MATNR MODIF ID R2.                   " 자재번호

*    SELECTION-SCREEN PUSHBUTTON /POS_LOW(30) BTN_TXT USER-COMMAND SHOW_AND_HIDE MODIF ID R1.

  SELECTION-SCREEN END OF BLOCK B2.
SELECTION-SCREEN END OF SCREEN 1200.
