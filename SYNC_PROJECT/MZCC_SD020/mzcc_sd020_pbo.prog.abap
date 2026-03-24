*&---------------------------------------------------------------------*
*& Include          MZCC_SD020_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE clear_ok_code OUTPUT.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE init_alv_0100 OUTPUT.

  IF go_custom IS INITIAL.


    " Container와 ALV 생성
    PERFORM create_object_0100.

    " ALV Layout 설정
    PERFORM set_layout_0100.

    " ALV Field Catalog 설정
    PERFORM set_fcat_0100.

    " EVENT HANDELR SET
    PERFORM set_event_handler_0100.

    " 값 설정
    PERFORM display_alv_0100.

  ELSE.

    PERFORM refresh_alv.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'S0101'.
  SET TITLEBAR 'T0101'.



ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_LISTBOX OUTPUT
*&---------------------------------------------------------------------*
MODULE set_listbox OUTPUT.

  DATA: lt_list  TYPE vrm_values,
        ls_value TYPE vrm_value.

  CLEAR lt_list.

  ls_value-key = 'NO'.
  ls_value-text = '일반주문'.
  APPEND ls_value TO lt_list.

  ls_value-key = 'QT'.
  ls_value-text = '맞춤주문'.
  APPEND ls_value TO lt_list.

  ls_value-key = 'ALL'.
  ls_value-text = '전체주문'.
  APPEND ls_value TO lt_list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'S_LIST'      " 리스트박스의 이름
      values = lt_list.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0101 OUTPUT.
  IF go_container3 IS INITIAL.
    " Container와 ALV 생성
    PERFORM create_object_0101.

    PERFORM display_alv_0101.

  ELSE.

    PERFORM refresh_alv_0101.

  ENDIF.
ENDMODULE.
