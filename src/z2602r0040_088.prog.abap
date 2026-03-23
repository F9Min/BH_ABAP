************************************************************************
* Program ID   : Z2602R0040_088
* Title        : [EDU] OLE를 통한 관리회계 분석 LEVEL 2
* Create Date  : 2026.03.04
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        |2026.02.25     |조성민    |initial coding
************************************************************************
REPORT Z2602R0040_088.

INCLUDE Z2602R0040_088_TOP.
INCLUDE Z2602R0040_088_SCR.
INCLUDE Z2602R0040_088_O01.
INCLUDE Z2602R0040_088_I01.
INCLUDE Z2602R0040_088_F01.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM DOWNLOAD_TEMPLATE.
  PERFORM GENERATE_REPORT.
  PERFORM GENERATE_CHART.
*  PERFORM ADD_AND_GENERATE_CHART.
