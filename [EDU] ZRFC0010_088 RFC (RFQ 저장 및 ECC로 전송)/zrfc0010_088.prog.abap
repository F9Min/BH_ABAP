************************************************************************
* Program ID   : ZRFC0010_088
* Title        : [EDU] RFC (RFQ 저장 및 ECC로 전송)
* Create Date  : 2025-09-09
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-09-08     |조성민    | inital Coding
************************************************************************
REPORT ZRFC0010_088.

INCLUDE ZRFC0010_088_CLS.
INCLUDE ZRFC0010_088_TOP.
INCLUDE ZRFC0010_088_SCR.

INCLUDE ZRFC0010_088_F01.
INCLUDE ZRFC0010_088_PBO.
INCLUDE ZRFC0010_088_PAI.

START-OF-SELECTION.
  PERFORM SELECT_DATA.
  PERFORM CALL_SCREEN.
