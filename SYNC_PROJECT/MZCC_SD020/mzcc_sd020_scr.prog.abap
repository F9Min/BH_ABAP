*&---------------------------------------------------------------------*
*& Include          MZCC_SD020_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.

  SELECT-OPTIONS :
                  so_vbeln FOR zcc_vbak-vbeln ,  " 출고문서 번호
                  so_kunnr FOR zcc_vbak-kunnr,  " 고객 ID
                  so_lfdat FOR zcc_vbak-vdatu.  " 배송 요청일

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN COMMENT 1(12) TEXT-s03 FOR FIELD pa_no. " 일반주문

    SELECTION-SCREEN POSITION 35.
    PARAMETERS pa_no AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 37(15) TEXT-s01 FOR FIELD pa_no. " 일반주문

*    SELECTION-SCREEN POSITION 60.
    PARAMETERS pa_qt AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 65(10) TEXT-s02 FOR FIELD pa_qt. " 견적주문


  SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN END OF SCREEN 1100.
