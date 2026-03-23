*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_TOP
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.
TABLES : ZS4H088T01, ZS4H088T02, ZS4H088T03, ZS4H088T04, ZS4H088T05.

TYPES : BEGIN OF TS_DATA,
          CODE      TYPE ZS4H088T01-CODE,      " 도서분류코드
          TEXT      TYPE ZS4H088T01-TEXT,      " 도서분류
          TITLE     TYPE ZS4H088T02-TITLE,     " 도서명
          AUTHOR    TYPE ZS4H088T02-AUTHOR,    " 저자
          PUBLISHER TYPE ZS4H088T02-PUBLISHER, " 출판사
          ISBN      TYPE ZS4H088T03-ISBN,      " ISBN
          SEQ       TYPE ZS4H088T03-SEQ,       " SEQ.
          ID        TYPE ZS4H088T04-ID,        " 이름
          NAME      TYPE ZS4H088T04-NAME,      " 사용자명, 대여자
          RDATE     TYPE ZS4H088T05-RDATE,     " 대여일
          REDATE    TYPE ZS4H088T05-REDATE,    " 반납기일
        END OF TS_DATA,
        TY_DATA TYPE TABLE OF TS_DATA.

TYPES : BEGIN OF TS_DISPLAY,
          CODE         TYPE ZS4H088T01-CODE,      " 도서분류코드
          TEXT         TYPE ZS4H088T01-TEXT,      " 도서분류
          TITLE        TYPE ZS4H088T02-TITLE,     " 도서명
          AUTHOR       TYPE ZS4H088T02-AUTHOR,    " 저자
          PUBLISHER    TYPE ZS4H088T02-PUBLISHER, " 출판사
          ID           TYPE ZS4H088T04-ID,        " 사용자 ID
          NAME         TYPE ZS4H088T04-NAME,      " 사용자명, 대여자
          RDATE        TYPE ZS4H088T05-RDATE,     " 대여일
          OVERDUE      TYPE C LENGTH 1,           " 연체여부
          ISBN         TYPE C LENGTH 17,          " ISBN-SEQ
          IT_COLFIELDS TYPE LVC_T_SCOL,           " 셀 색상을 다루는 필드
          COLOR        TYPE C LENGTH 4,           " 행 색상을 다루는 필드
        END OF TS_DISPLAY,
        TY_DISPLAY TYPE TABLE OF TS_DISPLAY.

DATA : BEGIN OF GS_BOOK,
         ID        TYPE ZS4H088T05-ID,
         NAME      TYPE ZS4H088T04-NAME,
         RDATE     TYPE ZS4H088T05-RDATE,
         REDATE2   TYPE ZS4H088T05-REDATE2,
         TITLE     TYPE ZS4H088T02-TITLE,
         AUTHOR    TYPE ZS4H088T02-AUTHOR,
         PUBLISHER TYPE ZS4H088T02-PUBLISHER,
       END OF GS_BOOK,
       GT_BOOK LIKE TABLE OF GS_BOOK.

DATA : GS_DISPLAY TYPE TS_DISPLAY,
       GT_DISPLAY TYPE TY_DISPLAY,
       GS_DATA    TYPE TS_DATA.
*       GT_DATA    TYPE TY_DATA.

DATA : OK_CODE TYPE SY-UCOMM.

* 100번 ALV 출력용 변수
DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
*       GO_CUSTOM   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.

DATA : GS_FCAT    TYPE LVC_S_FCAT,
       GT_FCAT    TYPE LVC_T_FCAT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GV_SAVE    TYPE C,
       GS_VARIANT TYPE DISVARIANT.

* 120번 ALV 출력용 변수
DATA : GO_CUSTOM2   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_GRID2 TYPE REF TO CL_GUI_ALV_GRID.

DATA : GS_FCAT2    TYPE LVC_S_FCAT,
       GT_FCAT2    TYPE LVC_T_FCAT,
       GS_LAYO2    TYPE LVC_S_LAYO,
       GV_SAVE2    TYPE C,
       GS_VARIANT2 TYPE DISVARIANT.

DATA : GV_ID     TYPE ZS4H088T04-ID,
       GV_DIALOG.

* 이벤트 객체 생성
DATA : GO_EVENT TYPE REF TO LCL_EVENT_HANDLER.
