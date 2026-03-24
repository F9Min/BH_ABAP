*&---------------------------------------------------------------------*
*& Include          MZCC_SD040SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.

  SELECT-OPTIONS :so_vbeln FOR zcc_vbak-vbeln MATCHCODE OBJECT zcc_sh_vbeln_so,
                  so_kunnr FOR zcc_vbak-kunnr,
                  so_vdatu FOR zcc_vbak-vdatu  NO-EXTENSION,
                  so_auart FOR zcc_vbak-auart.
  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(12) TEXT-s04. " 승인상태

    SELECTION-SCREEN POSITION 35.
    PARAMETERS pa_ap AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 37(6) TEXT-s01 FOR FIELD pa_ap. " '승인'

    SELECTION-SCREEN POSITION 45.
    PARAMETERS pa_rj AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 47(6) TEXT-s02 FOR FIELD pa_rj. " '반려'

    SELECTION-SCREEN POSITION 55.
    PARAMETERS pa_wt AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 57(10) TEXT-s03 FOR FIELD pa_wt. "대기

  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF SCREEN 1100.
