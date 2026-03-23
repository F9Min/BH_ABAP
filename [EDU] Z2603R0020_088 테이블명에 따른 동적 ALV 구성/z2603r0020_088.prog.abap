************************************************************************
* Program ID   : Z2603R0020_088
* Title        : [EDU] 테이블명에 따른 동적 ALV 구성
* Create Date  : 2026.03.12
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        |2026.03.12     |조성민    |initial coding
************************************************************************
REPORT Z2603R0020_088.

INCLUDE Z2603R0020_088_TOP.
INCLUDE Z2603R0020_088_SCR.
INCLUDE Z2603R0020_088_F01.
INCLUDE Z2603R0020_088_PBO.
INCLUDE Z2603R0020_088_PAI.

START-OF-SELECTION.
  PERFORM SET_ITAB.
  PERFORM GET_DATA.
  PERFORM DISPLAY_DATA.
