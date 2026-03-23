*&---------------------------------------------------------------------*
*& Include          Z2512R0010_088_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS : ON_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD : ON_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK USING E_COLUMN_ID E_ROW_ID.
  ENDMETHOD.

ENDCLASS.
