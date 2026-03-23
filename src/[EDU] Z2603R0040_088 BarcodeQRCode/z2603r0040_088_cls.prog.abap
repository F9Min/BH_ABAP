*&---------------------------------------------------------------------*
*& Include          Z2603R0040_088_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD HANDLE_HOTSPOT_CLICK.
    IF E_COLUMN_ID-FIELDNAME = 'MATNR'.
      " 1. 선택된 행의 자재코드 가져오기
      READ TABLE GT_DATA INTO GS_DATA INDEX E_ROW_ID-INDEX.
      " 2. 데이터 넣기
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GS_DATA-MATNR    " Any ABAP field
        IMPORTING
          OUTPUT = GS_POPUP-MATNR.  " External INPUT display, C field

      GS_POPUP-MAKTX = GS_DATA-MAKTX.
      " 3. 팝업 화면 호출
      CALL SCREEN 0150 STARTING AT 10 10.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
