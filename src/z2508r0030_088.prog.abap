************************************************************************
* Program ID   : Z2508R0030_088
* Title        : [EDU] OLE 활용
* Create Date  : 2025-08-11
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-08-11     |조성민    | inital Coding
* 1.1.   |2025-08-12     |조성민    | Seperate Header and Item Info
*        |2025-08-12     |조성민    | Add Template Download Feature
*        |2025-08-12     |조성민    | Add Data Insertion and Save Feature by OLE
* 2.0.   |2025-08-12     |조성민    | Fix Final Excel File Feature ( .xls -> .xlsx )
*        |2025-08-12     |조성민    | Fix PDF Download Feature ( AutoWidth )
************************************************************************
REPORT Z2508R0030_088.

INCLUDE Z2508R0030_088_CLS.
INCLUDE Z2508R0030_088_TOP.
INCLUDE Z2508R0030_088_SCR.

INCLUDE Z2508R0030_088_F01.
INCLUDE Z2508R0030_088_PBO.
INCLUDE Z2508R0030_088_PAI.

INITIALIZATION.
  SSCRFIELDS-FUNCTXT_01 = ICON_XLS && ' Excel Upload'.

AT SELECTION-SCREEN.
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM EXCEL_UPLOAD.
  ENDCASE.

START-OF-SELECTION.
  PERFORM SELECT_DATA.
  PERFORM CHECK_DATA.
