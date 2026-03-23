*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-H01.

  SELECT-OPTIONS : SO_NAME      FOR ZS4H088T04-NAME NO INTERVALS NO-EXTENSION,      " 사용자 명
                   SO_ID        FOR ZS4H088T04-ID,                                  " 사용자 ID
                   SO_TITLE     FOR ZS4H088T02-TITLE NO INTERVALS NO-EXTENSION,     " 도서 명
                   SO_PUB       FOR ZS4H088T02-PUBLISHER NO INTERVALS NO-EXTENSION, " 출판사
                   SO_AUT       FOR ZS4H088T02-AUTHOR NO INTERVALS NO-EXTENSION.    " 저자명

  SELECTION-SCREEN SKIP.

  PARAMETERS : PA_DEL TYPE C AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK B1.
