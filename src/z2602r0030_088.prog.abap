************************************************************************
* Program ID   : Z2602R0030_088
* Title        : [EDU] OLE를 통한 관리회계 분석
* Create Date  : 2026.02.25
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        |2026.02.25     |조성민    |initial coding
************************************************************************
REPORT Z2602R0030_088.

INCLUDE Z2602R0030_088_TOP.
INCLUDE Z2602R0030_088_SCR.
INCLUDE Z2602R0030_088_O01.
INCLUDE Z2602R0030_088_I01.
INCLUDE Z2602R0030_088_F01.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM DOWNLOAD_TEMPLATE.
  PERFORM GENERATE_REPORT.
