*&---------------------------------------------------------------------*
*& Include          Z2508R010_088_CLS
*&---------------------------------------------------------------------*
CLASS LCL_HEADER_EVENT_HANDELR DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS : ON_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_COLUMN_ID E_ROW_ID.

ENDCLASS.

CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS : ON_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_COLUMN_ID E_ROW_ID.

ENDCLASS.

*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_HEADER_EVENT_HANDELR
*&---------------------------------------------------------------------*
CLASS LCL_HEADER_EVENT_HANDELR IMPLEMENTATION.

  METHOD : ON_HOTSPOT_CLICK.
    PERFORM HEADER_HOTSPOT_CLICK USING E_COLUMN_ID E_ROW_ID.
  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD : ON_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK USING E_COLUMN_ID E_ROW_ID.
  ENDMETHOD.

ENDCLASS.
