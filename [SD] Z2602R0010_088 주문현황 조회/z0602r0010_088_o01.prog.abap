*&---------------------------------------------------------------------*
*& Include          ZSDR0160O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS '0100'.
 SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv OUTPUT.
IF go_grid IS INITIAL.
    PERFORM : create_instance       USING  go_grid go_docking,
              set_grid_exclude      USING  gt_func,
              set_grid_fieldcat     ,
              create_event_receiver USING  go_grid,
              display_grid          TABLES gt_data
                                           gt_fcat
                                           gt_sort
                                           gt_func
                                    USING  go_grid
                                           gs_variant
                                           gs_layout.
  ENDIF.
ENDMODULE.
