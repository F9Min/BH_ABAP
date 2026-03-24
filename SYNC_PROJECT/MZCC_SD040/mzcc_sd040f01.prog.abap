*&---------------------------------------------------------------------*
*& Include          MZCC_SD040F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_object_0100
*&---------------------------------------------------------------------*
FORM create_object_0100 .

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CCON'.                 " Name of the Screen CustCtrl Name to Link Container To

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.                 " Parent Container



ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_0100
*&---------------------------------------------------------------------*
FORM display_alv_0100 .

  go_alv_grid->set_table_for_first_display(
    EXPORTING
*      i_structure_name              =                  " Internal Output Table Structure Name
      is_variant                    = gs_variant                 " Layout
      i_save                        = gv_save                 " Save Layout
*      i_default                     = 'X'              " Default Display Variant
      is_layout                     = gs_layout                 " Layout
*      is_print                      =                  " Print Control
*      it_special_groups             =                  " Field Groups
*      it_toolbar_excluding          =                  " Excluded Toolbar Standard Functions
*      it_hyperlink                  =                  " Hyperlinks
*      it_alv_graphics               =                  " Table of Structure DTC_S_TC
*      it_except_qinfo               =                  " Table for Exception Quickinfo
*      ir_salv_adapter               =                  " Internal Usage only !!! - obsolete
    CHANGING
      it_outtab                     = gt_display                 " Output Table
      it_fieldcatalog               = gt_fcat                 " Field Catalog
).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_0100
*&---------------------------------------------------------------------*
FORM set_fcat_0100 .

  CLEAR gs_fcat.
  gs_fcat-col_pos = 1.
  gs_fcat-fieldname = 'STATUS'.
  gs_fcat-coltext = '판매오더 상태'.
  gs_fcat-icon = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 2.
  gs_fcat-fieldname = 'VBELN'.
  gs_fcat-coltext = '판매 오더 번호'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 3.
  gs_fcat-fieldname = 'POSNR'.
  gs_fcat-coltext = '아이템 번호'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 4.
  gs_fcat-fieldname = 'KUNNR'.
  gs_fcat-coltext = '고객 번호'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 5.
  gs_fcat-fieldname = 'NAME1'.
  gs_fcat-coltext = '고객 이름'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 6.
  gs_fcat-fieldname = 'STRAS'.
  gs_fcat-coltext = '배송지 주소'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 7.
  gs_fcat-fieldname = 'MATNR'.
  gs_fcat-coltext = '자재번호'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 8.
  gs_fcat-fieldname = 'SPART'.
  gs_fcat-coltext = '제품군'.
  APPEND gs_fcat TO gt_fcat.


  CLEAR gs_fcat.
  gs_fcat-col_pos = 9.
  gs_fcat-fieldname = 'KWMENG'.
  gs_fcat-coltext = '주문 수량'.
  gs_fcat-qfieldname = 'MEINS'.
  APPEND gs_fcat TO gt_fcat.


  CLEAR gs_fcat.
  gs_fcat-col_pos = 10.
  gs_fcat-fieldname = 'MEINS'.
  gs_fcat-coltext = '단위'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 11.
  gs_fcat-fieldname = 'NETWR_IT'.
  gs_fcat-coltext = '가격'.
  gs_fcat-cfieldname = 'WAERS'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 12.
  gs_fcat-fieldname = 'WAERS'.
  gs_fcat-coltext = '통화'.
  APPEND gs_fcat TO gt_fcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_layout_0100 .

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-zebra = 'X'.
  gs_layout-grid_title = '주문 상세 정보'.
  gs_layout-sel_mode = 'A'.

  gs_variant-report = sy-cprog.
  gv_save = 'A'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM select_data .


  DATA: lt_status TYPE RANGE OF zcc_vbap-status_it. " 판매오더 아이템별 승인상태 저장

  CLEAR: zcc_mard, zcc_makt, zcc_vbap.
  CLEAR lt_status.

* 체크박스에 따른 검색 조건
  IF pa_ap = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'AP' ) TO lt_status.  "승인
  ENDIF.

  IF pa_rj = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'RJ' ) TO lt_status.  "반려
  ENDIF.

  IF pa_wt = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'WT' ) TO lt_status.  "대기
  ENDIF.

  SELECT
           b~vbeln AS vbeln
           a~kunnr AS kunnr
           c~name1 AS name1
           c~stras AS stras
           b~matnr AS matnr
           b~spart AS spart
           b~kwmeng AS kwmeng
           b~meins AS meins
           b~netwr_it
           b~waers AS waers
           b~status_it
           b~posnr

    FROM zcc_vbak AS a
    JOIN zcc_vbap AS b
    ON a~vbeln = b~vbeln
    JOIN zcc_kna1 AS c
    ON a~kunnr = c~kunnr
    INTO CORRESPONDING FIELDS OF TABLE gt_display
    WHERE
       a~vbeln IN so_vbeln
      AND a~kunnr IN so_kunnr
      AND a~vdatu IN so_vdatu
      AND a~auart  IN so_auart
      AND b~status_it IN lt_status
      ORDER BY b~vbeln.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0100
*&---------------------------------------------------------------------*

FORM refresh_alv_0100 .

  go_alv_grid->refresh_table_display(
   EXPORTING
      is_stable = VALUE lvc_s_stbl( row = 'X' col = 'X' )
      ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_status
*&---------------------------------------------------------------------*
FORM modify_status .

  LOOP AT gt_display INTO gs_display.


    CASE gs_display-status_it.
      WHEN 'AP'.
        gs_display-status = icon_led_green.
      WHEN 'RJ'.
        gs_display-status = icon_led_red.
      WHEN 'WT'.
        gs_display-status = icon_led_yellow.
    ENDCASE.

    MODIFY gt_display FROM gs_display.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler_0100
*&---------------------------------------------------------------------*
FORM set_event_handler_0100 .

  SET HANDLER lcl_event_handler=>on_toolbar FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_user_command FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_double_click FOR go_alv_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_order_status
*&---------------------------------------------------------------------*

FORM update_order_status USING p_status_it TYPE zcc_vbap-status_it
                               p_icon      TYPE icon-id.

  DATA: lt_rows  TYPE lvc_t_row,
        ls_row   TYPE lvc_s_row,
        lv_index TYPE sy-tabix,
        lt_vbeln TYPE SORTED TABLE OF zcc_vbak-vbeln
                 WITH UNIQUE KEY table_line,
        lv_vbeln TYPE zcc_vbak-vbeln.

  go_alv_grid->get_selected_rows(
    IMPORTING
      et_index_rows = lt_rows ).

  IF lt_rows IS INITIAL.
    MESSAGE '하나 이상의 아이템을 선택해주세요.' TYPE 'I'.
    RETURN.
  ENDIF.




  LOOP AT lt_rows INTO ls_row.
    lv_index = ls_row-index.
    READ TABLE gt_display INDEX lv_index INTO gs_display.
    IF sy-subrc <> 0 OR gs_display-status_it <> 'WT'.
      CONTINUE.
    ENDIF.

    " 화면 데이터 상태 변경
    gs_display-status_it = p_status_it.
    gs_display-status    = p_icon.
    MODIFY gt_display FROM gs_display INDEX lv_index.

    " DB 업데이트 - VBAP
    UPDATE zcc_vbap
      SET status_it = p_status_it
      WHERE vbeln = gs_display-vbeln
        AND posnr = gs_display-posnr.

    " 중복 없이 판매오더 번호 수집
    INSERT gs_display-vbeln INTO TABLE lt_vbeln.
  ENDLOOP.

  " 판매오더별 승인 상태 점검
  LOOP AT lt_vbeln INTO lv_vbeln.
    SELECT status_it
      FROM zcc_vbap
      INTO TABLE @DATA(lt_status_check)
      WHERE vbeln = @lv_vbeln.

    " 하나라도 'AP'가 아닌 게 있으면 제외
    DATA(lv_all_ap) = abap_true.
    LOOP AT lt_status_check INTO DATA(lv_status).
      IF lv_status <> 'AP'.
        lv_all_ap = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    " 모든 아이템이 'AP'이면 VBAK도 'AP'로 변경
    IF lv_all_ap = abap_true.
      UPDATE zcc_vbak
        SET status = 'AP'
        WHERE vbeln = lv_vbeln.
    ENDIF.
  ENDLOOP.

  PERFORM modify_status.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form fillter_selected_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SPACE
*&---------------------------------------------------------------------*
FORM fillter_selected_data  USING   pv_status TYPE zcc_vbap-status_it.

  DATA : lt_filt TYPE lvc_t_filt,
         ls_filt LIKE LINE OF lt_filt.

  IF pv_status EQ space.
    REFRESH lt_filt.
  ELSE.
    CLEAR ls_filt.
    ls_filt-fieldname = 'STATUS_IT'.
    ls_filt-sign = 'I'.
    ls_filt-option = 'EQ'.
    ls_filt-low = pv_status.
    ls_filt-high = space.
    APPEND ls_filt TO lt_filt.
  ENDIF.

  go_alv_grid->set_filter_criteria(

      it_filter = lt_filt                 " Filter Conditions
  ).

  " ALV 리프레시
  CALL METHOD go_alv_grid->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_validate
*&---------------------------------------------------------------------*
FORM check_validate.

  " 1. 판매오더번호 존재 여부 확인

  LOOP AT so_vbeln INTO DATA(ls_so).

    IF ls_so-low IS NOT INITIAL.
      IF strlen( ls_so-low ) <> 10 OR ls_so-low(2) <> 'SO' OR ls_so-low+2(8) NA '0123456789'.
        MESSAGE s069 WITH ls_so-low DISPLAY LIKE 'E'.
      ELSE.
        SELECT SINGLE vbeln INTO @DATA(lv_exist_so)
          FROM zcc_vbak
          WHERE vbeln = @ls_so-low.
        IF sy-subrc <> 0.
          MESSAGE s033 WITH ls_so-low '판매오더 번호' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ls_so-high IS NOT INITIAL.
      IF strlen( ls_so-high ) <> 10 OR ls_so-high(2) <> 'SO' OR ls_so-high+2(8) NA '0123456789'.
        MESSAGE s069 WITH ls_so-high DISPLAY LIKE 'E'.
      ELSE.
        SELECT SINGLE vbeln INTO @DATA(lv_exist_so_h)
          FROM zcc_vbak
          WHERE vbeln = @ls_so-high.
        IF sy-subrc <> 0.
          MESSAGE s033 WITH ls_so-high '판매오더 번호' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

* 고객코드 유효성 검사
  LOOP AT so_kunnr INTO DATA(ls_kunnr).

    IF ls_kunnr-low IS NOT INITIAL.
      IF strlen( ls_kunnr-low ) <> 8 OR ls_kunnr-low(4) <> 'CUST' OR ls_kunnr-low+4(4) NA '0123456789'.
        MESSAGE s067 DISPLAY LIKE 'E'.  " 고객 ID 형식 오류
      ELSE.
        SELECT SINGLE kunnr INTO @DATA(lv_exist_kunnr)
          FROM zcc_kna1
          WHERE kunnr = @ls_kunnr-low.
        IF sy-subrc <> 0.
          MESSAGE s033 WITH ls_kunnr-low '고객 ID' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ls_kunnr-high IS NOT INITIAL.
      IF strlen( ls_kunnr-high ) <> 8 OR ls_kunnr-high(4) <> 'CUST' OR ls_kunnr-high+4(4) NA '0123456789'.
        MESSAGE s067 DISPLAY LIKE 'E'.
      ELSE.
        SELECT SINGLE kunnr INTO @DATA(lv_exist_kunnr_h)
          FROM zcc_kna1
          WHERE kunnr = @ls_kunnr-high.
        IF sy-subrc <> 0.
          MESSAGE s033 WITH ls_kunnr-high '고객 ID' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT so_auart INTO DATA(ls_auart).

    IF ls_auart-low IS NOT INITIAL.
      SELECT SINGLE auart INTO @DATA(lv_exist_auart)
        FROM zcc_vbak
        WHERE auart = @ls_auart-low.
      IF sy-subrc <> 0.
        MESSAGE s033 WITH ls_auart-low '판매문서 유형' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.

    IF ls_auart-high IS NOT INITIAL.
      SELECT SINGLE auart INTO @DATA(lv_exist_auart_h)
        FROM zcc_vbak
        WHERE auart = @ls_auart-high.
      IF sy-subrc <> 0.
        MESSAGE s033 WITH ls_auart-high '판매문서 유형' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF pa_ap = abap_false AND
     pa_rj = abap_false AND
     pa_wt = abap_false.

    MESSAGE '최소 하나 이상의 승인 상태를 선택해주세요.' TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.
