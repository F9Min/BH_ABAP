************************************************************************
* Program ID   : Z2512R0020_088
* Title        : [EDU] 리시버 생산오더 그룹 생성
* Create Date  : 2025-12-08
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-12-08     |조성민    | inital Coding
************************************************************************
REPORT Z2512R0020_088 MESSAGE-ID ZMSG_088.

INCLUDE Z2512R0020_088_CLS.
INCLUDE Z2512R0020_088_TOP.
INCLUDE Z2512R0020_088_SCR.

INCLUDE Z2512R0020_088_F01.
INCLUDE Z2512R0020_088_PBO.
INCLUDE Z2512R0020_088_PAI.

INITIALIZATION.
  PERFORM GET_USER_PARAMETERS USING 'CAC'.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

AT SELECTION-SCREEN.
  PERFORM SET_RBUKRS.

START-OF-SELECTION.
  PERFORM SELECT_DATA.
  PERFORM DISPLAY_DATA.
