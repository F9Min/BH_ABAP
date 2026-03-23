************************************************************************
* Program ID   : Z2508R0040_088
* Title        : [EDU] BDC & BAPI
* Create Date  : 2025-08-18
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-08-11     |조성민    | inital Coding
************************************************************************
REPORT Z2508R0040_088.

INCLUDE Z2508R0040_088_TOP.
INCLUDE Z2508R0040_088_SCR.
INCLUDE Z2508R0040_088_CLS.

INCLUDE Z2508R0040_088_F01.
INCLUDE Z2508R0040_088_PBO.
INCLUDE Z2508R0040_088_PAI.

INITIALIZATION.
  SSCRFIELDS-FUNCTXT_01 = ICON_XLS && ' Download Template'.

  S_EKORG-LOW = '2000'.
  APPEND S_EKORG.

  S_EKGRP-LOW = '120'.
  APPEND S_EKGRP.

  S_BUKRS-LOW = '2000'.
  APPEND S_BUKRS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
  PERFORM SET_PATH.

AT SELECTION-SCREEN.
  PERFORM CHECK_PARAM.

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM EXCEL_DOWNLOAD.
  ENDCASE.

START-OF-SELECTION.
  PERFORM DATA_UPLOAD.
