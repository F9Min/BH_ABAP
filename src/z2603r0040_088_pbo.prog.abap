*&---------------------------------------------------------------------*
*& Include          Z2603R0040_088_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.

    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYO.
    PERFORM SET_FIELDCAT.
    PERFORM SET_EVENT_0100.
    PERFORM DISPLAY_ALV.

  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0150 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0150 OUTPUT.

  DATA: GO_CC_BARCODE  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GO_PIC_BARCODE TYPE REF TO CL_GUI_PICTURE,
        GO_CC_QRCODE   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GO_PIC_QRCODE  TYPE REF TO CL_GUI_PICTURE,
        LV_QR          TYPE C LENGTH 50.

  " 1. 컨테이너 생성 (Screen 0100에 'CC_BARCODE', 'CC_QRCODE' 영역을 미리 그려둬야 함)
  IF GO_CC_BARCODE IS INITIAL.
    CREATE OBJECT GO_CC_BARCODE
      EXPORTING
        CONTAINER_NAME = 'CC_BARCODE'.
    CREATE OBJECT GO_PIC_BARCODE
      EXPORTING
        PARENT = GO_CC_BARCODE.
  ENDIF.

  IF GO_CC_QRCODE IS INITIAL.
    CREATE OBJECT GO_CC_QRCODE
      EXPORTING
        CONTAINER_NAME = 'CC_QRCODE'.
    CREATE OBJECT GO_PIC_QRCODE
      EXPORTING
        PARENT = GO_CC_QRCODE.
  ENDIF.

  " 2. 바코드 및 QR 코드 이미지 생성 후 Picture Control에 표시
  LV_QR = |{ GS_POPUP-MATNR }_{ GS_POPUP-MAKTX }|.
  PERFORM SHOW_BARCODE USING GS_POPUP-MATNR 'CODE128' GO_PIC_BARCODE. " 1D 바코드 (CODE128)
  PERFORM SHOW_BARCODE USING LV_QR 'QRCODE'  GO_PIC_QRCODE.  " 2D QR 코드

ENDMODULE.
