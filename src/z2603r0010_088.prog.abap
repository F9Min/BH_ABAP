************************************************************************
* Program ID   : Z2603R0010_088
* Title        : [EDU] 항공사별 예약현황
* Create Date  : 2026.03.11
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        |2026.03.11     |조성민    |initial coding
************************************************************************
REPORT Z2603R0010_088.

INCLUDE Z2603R0010_088_TOP.
INCLUDE Z2603R0010_088_CLS.
INCLUDE Z2603R0010_088_SCR.
INCLUDE Z2603R0010_088_PBO.
INCLUDE Z2603R0010_088_PAI.
INCLUDE Z2603R0010_088_F01.

START-OF-SELECTION.
  PERFORM GET_DATA.
  " 동적 ALV를 만드는 경우는 ABAP 이벤트의 성격을 고려해서 START-OF-SELECTION에 배치
  PERFORM SET_FIELDCAT CHANGING GT_FCAT.
  PERFORM DISPLAY_DATA.
