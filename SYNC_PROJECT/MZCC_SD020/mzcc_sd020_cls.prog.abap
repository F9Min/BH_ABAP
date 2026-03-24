*&---------------------------------------------------------------------*
*& Include          MZCC_SD020_CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (Definition) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS :
      on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id,

      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,

      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.





ENDCLASS.

*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_hotspot_click.



*    DATA: lv_vbeln TYPE zcc_vbak-vbeln.

    READ TABLE gt_vbak INTO gs_vbak INDEX e_row_id-index.
    CHECK sy-subrc = 0 AND e_column_id = 'VBELN'.

    PERFORM get_item_data USING gs_vbak-vbeln.

  ENDMETHOD.

  METHOD on_toolbar.


    DATA : lv_green  TYPE int4,   "출고완료
           lv_yellow TYPE int4,   "출고가능
           lv_red    TYPE int4,   "출고불가
           lv_all    TYPE int4.   "전체

    LOOP AT gt_vbak INTO gs_vbak.
      CASE gs_vbak-status_icon.
        WHEN icon_green_light.
          lv_green += 1.
          lv_all += 1.
        WHEN icon_yellow_light.
          lv_yellow += 1.
          lv_all += 1.
        WHEN icon_red_light.
          lv_red += 1.
          lv_all += 1.

      ENDCASE.
    ENDLOOP.

    " 버튼생성용 WA
    DATA ls_button LIKE LINE OF e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-butn_type = 3.  " 3: 구분자
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'GI'.
    ls_button-text     = '출고요청'(l01).
    ls_button-icon     = icon_transport.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-butn_type = 3.  " 3: 구분자
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'ALL'.
    ls_button-text     = |전체 : { lv_all }|.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'GREEN'.
    ls_button-text     = |출고완료 : { lv_green }|.
    ls_button-icon     = icon_led_green.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'YELLOW'.
    ls_button-text     = |출고가능 : { lv_yellow }|.
    ls_button-icon     = icon_led_yellow.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'RED'.
    ls_button-text     = |출고불가 : { lv_red }|.
    ls_button-icon     = icon_led_red.
    APPEND ls_button TO e_object->mt_toolbar.


  ENDMETHOD.

  METHOD on_user_command.

    CASE e_ucomm.
      WHEN 'GI'.
        PERFORM get_selected_data.

      WHEN 'ALL'.
        PERFORM fillter_selected_data USING space.
      WHEN 'GREEN'.
        PERFORM fillter_selected_data USING 'DLV'.
      WHEN 'YELLOW'.
        PERFORM fillter_selected_data USING 'GM'.
      WHEN 'RED'.
        PERFORM fillter_selected_data USING 'AP'.
    ENDCASE.

    LEAVE TO SCREEN 0100.

  ENDMETHOD.

ENDCLASS.
