*&---------------------------------------------------------------------*
*& Include          Z2508R030_088_TOP
*&---------------------------------------------------------------------*
TABLES : T001, VBAK, SSCRFIELDS.

* Data Declation for Company Info
TYPES : BEGIN OF TS_COMPANY,
          BUTXT      TYPE T001-BUTXT,
          TEL_NUMBER TYPE ADRC-TEL_NUMBER,
          CITY1      TYPE ADRC-CITY1,
          STREET     TYPE ADRC-STREET,
        END OF TS_COMPANY,
        TY_COMPANY TYPE TABLE OF TS_COMPANY.

DATA : GS_COMPANY TYPE TS_COMPANY,
       GT_COMPANY TYPE TY_COMPANY.

* Data Declation for PO Header Info
TYPES : BEGIN OF TS_HEADER,
          VBELN     TYPE VBAK-VBELN,   " 판매오더
          KUNNR     TYPE VBAK-KUNNR,   " 바이어 번호
          NAME1     TYPE KNA1-NAME1,   " 바이어명
          BUYER     TYPE C LENGTH 50,  " 출력용 필드
          BSTNK     TYPE VBAK-BSTNK,   " 참조번호
          PDATE     TYPE SY-DATUM,     " 출력일
          NETWR     TYPE VBAK-NETWR,   " 총액
          WAERK     TYPE VBAK-WAERK,   " 통화
          NETWR_CUR TYPE C LENGTH 30,  " 통화를 반영한 총액
          VDATU     TYPE VBAK-VDATU,   " 배송요청일
          ZTERM     TYPE VBKD-ZTERM,   " 지급조건
          INCO1     TYPE VBKD-INCO1,   " 인도조건
        END OF TS_HEADER,
        TY_HEADER TYPE TABLE OF TS_HEADER.

DATA : GS_HEADER TYPE TS_HEADER,
       GT_HEADER TYPE TY_HEADER.

* Data Declation for PO Item Info
TYPES : BEGIN OF TS_CONTENT,
          POSNR      TYPE VBAP-POSNR,   " 항번
          MATNR      TYPE VBAP-MATNR,   " 자재
          MAKTX      TYPE MAKT-MAKTX,   " 자재명
          NETPR      TYPE VBAP-NETPR,   " 단가
          NETPR_CUR  TYPE C LENGTH 30,  " 통화 적용 단가
          WAERK      TYPE VBAP-WAERK,   " 통화
          KWMENG     TYPE VBAP-KWMENG,  " 수량
          KWMENG_QUA TYPE C LENGTH 30,  " 단위 적용 수량
          MEINS      TYPE VBAP-MEINS,   " 수량단위
          AMOUNT     TYPE VBAP-NETWR,   " 금액
          AMOUNT_CUR TYPE C LENGTH 30,  " 통화 적용 총액
          LGOBE      TYPE T001L-LGOBE,  " 창고명
        END OF TS_CONTENT,
        TY_CONTENT TYPE TABLE OF TS_CONTENT.

DATA : GS_CONTENT TYPE TS_CONTENT,
       GT_CONTENT TYPE TY_CONTENT.
