*&---------------------------------------------------------------------*
*& Include          Z2508R0040_088_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS : HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_COLUMN_ID E_ROW_ID.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD HOTSPOT_CLICK.

    CASE E_COLUMN_ID.
      WHEN 'EBELN'.
        READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) INDEX E_ROW_ID.

        SET PARAMETER ID 'BES' FIELD LS_DISPLAY-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
