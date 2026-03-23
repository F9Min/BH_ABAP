*&---------------------------------------------------------------------*
*& Include          Z2509R0070_088_TOP
*&---------------------------------------------------------------------*
TABLES : EKKO.

TYPES : BEGIN OF TS_DATA,

          EBELN TYPE EKKO-EBELN,
          EBELP TYPE EKPO-EBELP,
          MATNR TYPE EKPO-MATNR,

        END OF TS_DATA,
        TY_DATA TYPE TABLE OF TS_DATA.

DATA : GS_DATA TYPE TS_DATA,
       GT_DATA TYPE TY_DATA.

DATA : GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID.

DATA : GT_FCAT    TYPE LVC_T_FCAT,   " 필드카탈로그
       " TYPE REF TO DATA : 데이터 객체에 대한 참조 + 타입이 정해지지 않은 상태 -> 동적 구조 또는 테이블 생성
       " 실질적인 의미는 어딘가에 존재하는 데이터 객체를 가리키는 포인터
       GT_LIST_R  TYPE REF TO DATA,  " 동적 인터널 테이블
       GS_LAYO    TYPE LVC_S_LAYO,
       GS_VARIANT TYPE DISVARIANT,
       GV_SAVE.

" TYPE STANDARD TABLE : 일반 ITAB 타입이지만 구조는 미정, 주로 필드심볼에 사용
" 실질적인 의미는 구조 미정의 테이블
FIELD-SYMBOLS <GT_LIST> TYPE STANDARD TABLE.

DATA : OK_CODE TYPE SY-UCOMM.
