************************************************************************
* Program ID   : Z2602R0010_088
* Title        : [SD] 주문현황 조회
* Create Date  : 2023.06.08
* Developer    : EY27
* Tech. Script : 주문현황 조회
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        | 2023.06.08    |   EY27   |  initial coding
*        | 2026.02.19    |  S4H088  |  GET_DATA의 AMDP 전환
************************************************************************
REPORT Z2602R0010_088.

INCLUDE Z0602R0010_088_TOP.
INCLUDE Z0602R0010_088_I01.
INCLUDE Z0602R0010_088_O01.
INCLUDE Z0602R0010_088_F01.

INITIALIZATION.
  PERFORM SET_INIT_DATA.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_VARIANT USING SY-REPID CHANGING P_VARI.

START-OF-SELECTION.
  PERFORM GET_DATA.
*  PERFORM GET_DATA_AMDP.
  IF GT_DATA IS NOT INITIAL.
    CALL SCREEN 0100.
  ENDIF.
