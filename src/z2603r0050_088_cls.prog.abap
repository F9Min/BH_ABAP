*&---------------------------------------------------------------------*
*& Include          Z2603R0050_088_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:

      "DOUBLE CLICK
      ON_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK
        OF CL_GUI_ALV_GRID
        IMPORTING E_ROW
                  E_COLUMN
                  ES_ROW_NO,
      "DATA CHANGED
      DATA_CHANGED FOR EVENT DATA_CHANGED
        OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED
                  E_ONF4
                  E_ONF4_BEFORE
                  E_ONF4_AFTER
                  E_UCOMM.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD ON_DOUBLE_CLICK.

    PERFORM HANDLE_DOUBLE_CLICK USING E_ROW
                                      E_COLUMN
                                      ES_ROW_NO.
  ENDMETHOD.

  METHOD DATA_CHANGED.
    PERFORM DATA_CHANGED USING ER_DATA_CHANGED
                               E_ONF4
                               E_ONF4_BEFORE
                               E_ONF4_AFTER
                               E_UCOMM.

  ENDMETHOD.

ENDCLASS.
