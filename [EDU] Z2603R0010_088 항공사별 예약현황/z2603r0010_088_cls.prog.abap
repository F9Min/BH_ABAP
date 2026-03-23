*&---------------------------------------------------------------------*
*& Include          Z2603R0010_088_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS HANDLE_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_COLUMN ES_ROW_NO.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT
*&---------------------------------------------------------------------*
CLASS LCL_EVENT IMPLEMENTATION.

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM ALV_HANDLE_DOUBLE_CLICK USING E_COLUMN ES_ROW_NO.
  ENDMETHOD.

ENDCLASS.
