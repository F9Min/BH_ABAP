************************************************************************
* Program ID   : Z2508R0060_088
* Title        : [EDU] SmartForm 활용
* Create Date  : 2025-08-31
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-08-31     |조성민    | inital Coding
************************************************************************
REPORT Z2508R0060_088.

INCLUDE Z2508R0060_088_CLS.
INCLUDE Z2508R0060_088_TOP.
INCLUDE Z2508R0060_088_SCR.

INCLUDE Z2508R0060_088_F01.
INCLUDE Z2508R0060_088_PBO.
INCLUDE Z2508R0060_088_PAI.

AT SELECTION-SCREEN OUTPUT.
  PERFORM INIT_SCREEN.

INITIALIZATION.
  SSCRFIELDS-FUNCTXT_01 = ICON_XLS && ' Excel Upload'.

AT SELECTION-SCREEN.
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM EXCEL_UPLOAD.
  ENDCASE.

START-OF-SELECTION.
  PERFORM CHECK_VBELN.
  PERFORM SELECT_DATA.
  PERFORM CHECK_DATA.
