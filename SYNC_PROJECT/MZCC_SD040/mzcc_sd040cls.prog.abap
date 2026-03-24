*&---------------------------------------------------------------------*
*& Include          MZCC_SD040CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (Definition) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.

    "ALV 툴바 이벤트를 다루기 위한 핸들러 메소드
    CLASS-METHODS on_toolbar

      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object.

    CLASS-METHODS on_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    CLASS-METHODS on_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row.


ENDCLASS.

*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_toolbar.

    DATA ls_button LIKE LINE OF e_object->mt_toolbar." mt_toolbar 모양의 작업공간
    DATA : lv_green  TYPE int4,   "승인완료
           lv_yellow TYPE int4,   "승인대기
           lv_red    TYPE int4,   "반려
           lv_all    TYPE int4.   "전체

    LOOP AT gt_display INTO gs_display.
      CASE gs_display-status.
        WHEN icon_led_green.
          lv_green += 1.
          lv_all += 1.
        WHEN icon_led_yellow.
          lv_yellow += 1.
          lv_all += 1.
        WHEN icon_led_red.
          lv_red += 1.
          lv_all += 1.


      ENDCASE.
    ENDLOOP.

    " 구분선
    CLEAR ls_button.
    ls_button-butn_type = 3.
    APPEND ls_button TO e_object->mt_toolbar.


    CLEAR ls_button.
    ls_button-function = 'APPROVE'.
    ls_button-text = '주문 승인'.
    ls_button-icon = icon_checked.
    ls_button-butn_type = '0'.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'REJECT'.
    ls_button-text = '주문 반려'.
    ls_button-icon = icon_reject.
    ls_button-butn_type = '0'.
    APPEND ls_button TO e_object->mt_toolbar.

    " 구분선
    CLEAR ls_button.
    ls_button-butn_type = 3.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'ALL'.
    ls_button-text     = |전체 : { lv_all }|.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'GREEN'.
    ls_button-text     = |승인완료 : { lv_green }|.
    ls_button-icon     = icon_led_green.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'YELLOW'.
    ls_button-text     = |승인대기 : { lv_yellow }|.
    ls_button-icon     = icon_led_yellow.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function = 'RED'.
    ls_button-text     = |반려 : { lv_red }|.
    ls_button-icon     = icon_led_red.
    APPEND ls_button TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD on_user_command.

    CASE e_ucomm.
        " 승인 버튼 누르면 status_it 값 AP로 바꾸고 필드 icon을 icon_led_green로 바꿈.
      WHEN 'APPROVE'.
        DATA(lv_answer) = ''.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = '주문 승인'
            text_question         = '이 주문을 승인하시겠습니까?'
            text_button_1         = '확인'     " → 승인 처리로 연결
            text_button_2         = '취소'    "  → 아무것도 하지 않음
            default_button        = '2'
            display_cancel_button = ' '
          IMPORTING
            answer                = lv_answer
          EXCEPTIONS
            OTHERS                = 1.

        " 팝업 실패 시 중단
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        " 사용자가 '확인' 버튼 눌렀을 때만 승인 처리
        IF lv_answer = '1'.
          PERFORM update_order_status USING 'AP' icon_led_green.
          IF sy-subrc = 0.
            MESSAGE s057(zcc_msg).
          ENDIF.
        ENDIF.

      WHEN 'REJECT'.

        CLEAR :lv_answer.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = '주문 반려'
            text_question         = '이 주문을 반려하시겠습니까?'
            text_button_1         = '확인'     " → 반려 처리로 연결
            text_button_2         = '취소'     " → 아무것도 하지 않음
            default_button        = '2'
            display_cancel_button = ' '
          IMPORTING
            answer                = lv_answer
          EXCEPTIONS
            OTHERS                = 1.

        " 팝업 실패 시 중단
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        " 사용자가 '확인' 버튼 눌렀을 때만 승인 처리
        IF lv_answer = '1'.
          PERFORM update_order_status USING 'RJ' icon_led_red.
          IF sy-subrc = 0.
            MESSAGE s058(zcc_msg).
          ENDIF.
        ENDIF.


      WHEN 'ALL'.
        PERFORM fillter_selected_data USING space.
      WHEN 'GREEN'.
        PERFORM fillter_selected_data USING 'AP'.
      WHEN 'YELLOW'.
        PERFORM fillter_selected_data USING 'WT'.
      WHEN 'RED'.
        PERFORM fillter_selected_data USING 'RJ'.
    ENDCASE.

    LEAVE TO SCREEN 100.

  ENDMETHOD.

  METHOD on_double_click.

    " 선택한 행 정보 ls_display에 저장
    READ TABLE gt_display INTO DATA(ls_display) INDEX e_row-index.
    IF sy-subrc <> 0.
      MESSAGE i019(zcc_msg) DISPLAY LIKE 'E'.  "선택된 행이 없습니다.
    ENDIF.

    " --- 자재 정보 조회(가용성 점검) ---
    CLEAR : zcc_mard, zcc_makt, zcc_vbap.
    SELECT SINGLE a~matnr, b~maktx, a~labst, a~meins
    INTO (@zcc_mard-matnr, @zcc_makt-maktx, @zcc_mard-labst, @zcc_mard-meins)
    FROM zcc_mard AS a
    JOIN zcc_makt AS b ON a~matnr = b~matnr
    WHERE a~matnr = @ls_display-matnr
      AND a~werks LIKE 'W%'.


    zcc_vbap-kwmeng = TRUNC( ls_display-kwmeng ).

    " 재고 부족 시 경고
    IF zcc_mard-labst < zcc_vbap-kwmeng.
      "[주의] 가용재고 &1가 주문수량 &2보다 적습니다
      MESSAGE i059(zcc_msg) WITH zcc_mard-labst zcc_vbap-kwmeng DISPLAY LIKE 'E'.
    ENDIF.

    " --- 고객 정보 조회 (여신 점검)---
    CLEAR: zcc_kna1,zcc_knkk.
    SELECT SINGLE a~kunnr, name1, stras, land1, email, telf, rating, klimk
      INTO (@zcc_kna1-kunnr, @zcc_kna1-name1, @zcc_kna1-stras, @zcc_kna1-land1, @zcc_kna1-email, @zcc_kna1-telf, @zcc_knkk-rating, @zcc_knkk-klimk)
      FROM zcc_kna1 AS a
      JOIN zcc_knkk AS b ON a~kunnr = b~kunnr
      WHERE a~kunnr = @ls_display-kunnr.

    " 값 새로고침
    LEAVE TO SCREEN 100.


  ENDMETHOD.
ENDCLASS.
