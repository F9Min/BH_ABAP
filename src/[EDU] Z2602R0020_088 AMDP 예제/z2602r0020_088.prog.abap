************************************************************************
* Program ID   : Z2602R0020_088
* Title        : [EDU] AMDP 예제
* Create Date  : 2026.02.23
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer |Description(Reason)
************************************************************************
*        |2026.02.23     |조성민    |initial coding
************************************************************************
REPORT Z2602R0020_088.

INCLUDE Z2602R0020_088_TOP.
INCLUDE Z2602R0020_088_SCR.
INCLUDE Z2602R0020_088_F01.
INCLUDE Z2602R0020_088_PBO.
INCLUDE Z2602R0020_088_PAI.

START-OF-SELECTION.
  PERFORM GET_DATA.

  IF GT_RESULT IS NOT INITIAL.
    PERFORM GET_USER_NAME.
  ENDIF.

  PERFORM DISPLAY_DATA.
