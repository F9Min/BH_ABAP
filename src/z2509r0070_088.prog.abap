************************************************************************
* Program ID   : Z2508R0070_088
* Title        : [EDU] PO 동적 필드 ALV
* Create Date  : 2025-09-08
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-09-08     |조성민    | inital Coding
* 1.0.1  |2025-09-09     |조성민    | Finalize Coding
************************************************************************
REPORT Z2509R0070_088.

INCLUDE Z2509R0070_088_CLS.
INCLUDE Z2509R0070_088_TOP.
INCLUDE Z2509R0070_088_SCR.

INCLUDE Z2509R0070_088_F01.
INCLUDE Z2509R0070_088_PBO.
INCLUDE Z2509R0070_088_PAI.

START-OF-SELECTION.
  PERFORM SELECT_DATA.
  PERFORM CALL_SCREEN.
