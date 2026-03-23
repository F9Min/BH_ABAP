************************************************************************
* Program ID   : Z2512R0010_088
* Title        : [EDU] Attachment Document
* Create Date  : 2025-12-03
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-12-03     |조성민    | inital Coding
************************************************************************
REPORT Z2512R0010_088 MESSAGE-ID ZMSG_088.

INCLUDE Z2512R0010_088_CLS.
INCLUDE Z2512R0010_088_TOP.
INCLUDE Z2512R0010_088_SCR.

INCLUDE Z2512R0010_088_F01.
INCLUDE Z2512R0010_088_PBO.
INCLUDE Z2512R0010_088_PAI.

INITIALIZATION.
  PERFORM SET_INITAL_VALUE.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.
  PERFORM DISPLAY_DATA.
