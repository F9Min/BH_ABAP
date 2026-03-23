************************************************************************
* Program ID   : Z2508R0050_088
* Title        : [EDU] BDC & BAPI ( PO 변경 추가 )
* Create Date  : 2025-08-22
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-08-22     |조성민    | inital Coding
* 1.1.1  |2025-08-25     |조성민    | Item Data Selection & Modification Feature Addition
* 1.1.2  |2025-08-26     |조성민    | PO Changing Feature Addition by BAPI_PO_CHANGE
************************************************************************
REPORT Z2508R0050_088.

INCLUDE Z2508R0050_088_TOP.
INCLUDE Z2508R0050_088_SCR.
INCLUDE Z2508R0050_088_CLS.

INCLUDE Z2508R0050_088_F01.
INCLUDE Z2508R0050_088_PBO.
INCLUDE Z2508R0050_088_PAI.

INITIALIZATION.
  PERFORM SET_SELECTION_SCREEN.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELECTION_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
  PERFORM SET_PATH.

AT SELECTION-SCREEN.
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM EXCEL_DOWNLOAD.
  ENDCASE.

START-OF-SELECTION.
  CASE ABAP_ON.
    WHEN P_CREATE.
      PERFORM CHECK_PARAM.
      PERFORM DATA_UPLOAD.
    WHEN P_MODIF.
      PERFORM SELECT_MODIF_DATA.
      PERFORM MODIFY_HEADER.
      PERFORM CALL_SCREEN.
  ENDCASE.
