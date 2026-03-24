*&---------------------------------------------------------------------*
*& Include          MZCC_SD020_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_object_0100
*&---------------------------------------------------------------------*
FORM create_object_0100 .

  CREATE OBJECT go_custom
    EXPORTING
      container_name = 'CCON1'.               " Name of the Screen CustCtrl Name to Link Container To

  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_custom                   " Parent Container
      rows    = 2                   " Number of Rows to be displayed
      columns = 1.                 " Number of Columns to be Displayed

  go_splitter->get_container(
    EXPORTING
      row       = 1                 " Row
      column    = 1                " Column
    RECEIVING
      container = go_container1                 " Container
  ).

  go_splitter->get_container(
    EXPORTING
      row       = 2                 " Row
      column    = 1                 " Column
    RECEIVING
      container = go_container2                 " Container
  ).

  CREATE OBJECT go_grid1
    EXPORTING
      i_parent = go_container1.                  " Parent Container



  CREATE OBJECT go_grid2
    EXPORTING
      i_parent = go_container2.                 " Parent Container



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0100
*&---------------------------------------------------------------------*
FORM set_layout_0100 .
  CLEAR gs_layout1.
  gs_layout1-cwidth_opt = 'A'.
  gs_layout1-zebra = 'X'.
  gs_layout1-grid_title = '판매오더 정보'(t01).

  CLEAR gs_layout2.
  gs_layout2-cwidth_opt = 'A'.
  gs_layout2-zebra = 'X'.
  gs_layout2-grid_title = '판매오더 상세정보'(t03).

  gs_variant-report = sy-cprog.
  gv_save = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_0100
*&---------------------------------------------------------------------*
FORM set_fcat_0100 .

  PERFORM set_fcat_container1.
  PERFORM set_fcat_container2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler_0100
*&---------------------------------------------------------------------*
FORM set_event_handler_0100 .

  SET HANDLER lcl_event_handler=>on_hotspot_click FOR go_grid1.
  SET HANDLER lcl_event_handler=>on_toolbar FOR go_grid1.
  SET HANDLER lcl_event_handler=>on_user_command FOR go_grid1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_0100
*&---------------------------------------------------------------------*
FORM display_alv_0100 .

  gs_variant-handle = 'SD01'.
  go_grid1->set_table_for_first_display(
  EXPORTING
    is_variant                    = gs_variant                 " Layout
    i_save                        = gv_save                 " Save Layout
    is_layout                     = gs_layout1                 " Layout
    CHANGING
      it_outtab                     = gt_vbak                 " Output Table
    it_fieldcatalog               = gt_fcat1                  " Field Catalog
).

  gs_variant-handle = 'SD02'.
  go_grid2->set_table_for_first_display(
    EXPORTING
      is_variant                    = gs_variant                 " Layout
      i_save                        = gv_save                 " Save Layout
      is_layout                     = gs_layout2                 " Layout
    CHANGING
      it_outtab                     = gt_vbap                 " Output Table
      it_fieldcatalog               = gt_fcat2                 " Field Catalog
).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_vbak_data
*&---------------------------------------------------------------------*
FORM select_vbak_data .

  DATA: lt_auart TYPE RANGE OF zcc_vbak-auart. " 판매오더 유형 저장
  CLEAR lt_auart.

* 체크박스에 따른 검색 조건
  IF pa_no = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'NO' ) TO lt_auart.  "일반주문
  ENDIF.

  IF pa_qt = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'QT' ) TO lt_auart.  "견적주문
  ENDIF.

  SELECT a~vbeln, a~kunnr, b~name1, a~auart, a~stras, a~vdatu, a~werks, status, c~name1 AS name2
    INTO CORRESPONDING FIELDS OF TABLE @gt_vbak
    FROM zcc_vbak AS a
    LEFT JOIN zcc_kna1 AS b ON a~kunnr = b~kunnr
    LEFT JOIN zcc_t001w AS c ON a~werks = c~werks
    WHERE a~vbeln IN @so_vbeln
      AND a~kunnr IN @so_kunnr
      AND a~auart IN @lt_auart
      AND a~status IN ('AP', 'GM', 'DLV').


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_CONTAINER1
*&---------------------------------------------------------------------*
FORM set_fcat_container1 .
  CLEAR gs_fcat.
  gs_fcat-col_pos = 0.
  gs_fcat-fieldname = 'STATUS_ICON'.
  gs_fcat-coltext = '출고 상태'.
  gs_fcat-icon = 'X'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 1.
  gs_fcat-fieldname = 'STATUS_TEXT'.
  gs_fcat-coltext = '출고상태내역'.
  gs_fcat-just = 'C'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 2.
  gs_fcat-fieldname = 'VBELN'.
  gs_fcat-ref_table = 'ZCC_VBAK'.
  gs_fcat-key = 'X'.
  gs_fcat-hotspot = 'X'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 3.
  gs_fcat-fieldname = 'KUNNR'.
  gs_fcat-ref_table = 'ZCC_VBAK'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 4.
  gs_fcat-fieldname = 'NAME1'.
  gs_fcat-ref_table = 'ZCC_KNA1'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 5.
  gs_fcat-fieldname = 'WERKS'.
  gs_fcat-coltext = '플랜트 코드'.

  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 6.
  gs_fcat-fieldname = 'NAME2'.
  gs_fcat-coltext = '플랜트명'.

  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 7.
  gs_fcat-fieldname = 'AUART'.
  gs_fcat-ref_table = 'ZCC_VBAK'.
  gs_fcat-just = 'C'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 8.
  gs_fcat-fieldname = 'STRAS'.
  gs_fcat-ref_table = 'ZCC_KNA1'.
  APPEND gs_fcat TO gt_fcat1.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 9.
  gs_fcat-fieldname = 'VDATU'.
  gs_fcat-ref_table = 'ZCC_VBAK'.
  APPEND gs_fcat TO gt_fcat1.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM refresh_alv .

  go_grid1->refresh_table_display( ).
  go_grid2->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_container2
*&---------------------------------------------------------------------*
FORM set_fcat_container2 .


  CLEAR gs_fcat.
  gs_fcat-col_pos = 1.
  gs_fcat-fieldname = 'VBELN'.
  gs_fcat-coltext = '판매오더 번호'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 2.
  gs_fcat-fieldname = 'POSNR'.
  gs_fcat-coltext = '아이템 번호'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 3.
  gs_fcat-fieldname = 'MATNR'.
  gs_fcat-coltext = '자재번호'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 4.
  gs_fcat-fieldname = 'MAKTX'.
  gs_fcat-coltext = '자재명'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 5.
  gs_fcat-fieldname = 'SPART'.
  gs_fcat-coltext = '제품군'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 6.
  gs_fcat-fieldname = 'SPART_NAME'.
  gs_fcat-coltext = '제품군명'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 7.
  gs_fcat-fieldname = 'KWMENG'.
  gs_fcat-coltext = '주문수량'.
  gs_fcat-qfieldname = 'MEINS'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 8.
  gs_fcat-fieldname = 'MEINS'.
  gs_fcat-coltext = '단위'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 9.
  gs_fcat-fieldname = 'NETPR'.
  gs_fcat-coltext = '단가'.
  gs_fcat-cfieldname = ' WAERS'.
  APPEND gs_fcat TO gt_fcat2.

  CLEAR gs_fcat.
  gs_fcat-col_pos = 10.
  gs_fcat-fieldname = 'WAERS'.
  gs_fcat-coltext = '통화'.
  APPEND gs_fcat TO gt_fcat2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_status
*&---------------------------------------------------------------------*
FORM modify_status .
  DATA: lv_item_total     TYPE i,
        lv_item_delivered TYPE i,
        lt_lips_posnr     TYPE SORTED TABLE OF zcc_vbap-posnr
                          WITH UNIQUE KEY table_line.

  CLEAR gs_vbak.

  LOOP AT gt_vbak INTO gs_vbak.

    CASE gs_vbak-status.
      WHEN 'AP'.  " 승인완료지만 출고준비 전
        gs_vbak-status_icon = icon_red_light.
        gs_vbak-status_text = '출고불가'.
      WHEN 'GM'.  " 자재이동 완료, 출고준비 완료
        gs_vbak-status_icon = icon_yellow_light.
        gs_vbak-status_text = '출고대기'.
      WHEN 'DLV'. " 출고 완료
        gs_vbak-status_icon = icon_green_light.
        gs_vbak-status_text = '출고완료'.
    ENDCASE.

    MODIFY gt_vbak FROM gs_vbak.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_0101
*&---------------------------------------------------------------------*
FORM create_object_0101 .

  CREATE OBJECT go_container3
    EXPORTING
      container_name = 'CCON2'.                 " Name of the Screen CustCtrl Name to Link Container To

  CREATE OBJECT go_grid3
    EXPORTING
      i_parent = go_container3.                 " Parent Container


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*

FORM display_alv_0101 .
  gs_variant-handle = 'SD03'.
  go_grid3->set_table_for_first_display(
    EXPORTING
      is_layout                     =  gs_layout2                " Layout
    CHANGING
      it_outtab                     = gt_vbap                 " Output Table
      it_fieldcatalog               = gt_fcat2                 " Field Catalog
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_alv_0101 .

  go_grid3->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_selected_data
*&---------------------------------------------------------------------*
FORM get_selected_data .

  DATA: lt_rows TYPE lvc_t_row,
        ls_row  TYPE lvc_s_row.

  " 선택된 행 가져오기
  CALL METHOD go_grid1->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  READ TABLE lt_rows INTO ls_row INDEX 1.
  IF sy-subrc <> 0.
    MESSAGE i049(zcc_msg) DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
    RETURN.
  ENDIF.

  " 선택된 아이템 데이터 가져오기
  READ TABLE gt_vbak INTO gs_vbak INDEX ls_row-index.
  IF sy-subrc <> 0.
    MESSAGE i049(zcc_msg) DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
    RETURN.
  ENDIF.

  " 이미 출고문서가 있는 경우
  IF gs_vbak-status = 'DLV'.
    MESSAGE i050(zcc_msg) DISPLAY LIKE 'E'.   "이미 생성된 출고문서가 있습니다
    RETURN.
  ENDIF.

  " 이미 출고문서가 있는 경우
  IF gs_vbak-status = 'AP'.
    MESSAGE i054(zcc_msg) DISPLAY LIKE 'E'.   "출고가 불가한 판매오더입니다.
    RETURN.
  ENDIF.

  IF gs_vbak-vbeln NE gs_vbap-vbeln.
    MESSAGE i055(zcc_msg) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.


*  " 팝업창 데이터 채우기
  PERFORM fill_popup_data.

  " 팝업 호출 가로 20칸 세로 5줄에 위치
  CALL SCREEN 0101 STARTING AT 20 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_popup_data
*&---------------------------------------------------------------------*
FORM fill_popup_data .

  MOVE-CORRESPONDING gs_vbak TO gs_screen.

  SELECT SINGLE vdatu
    INTO gs_screen-vdatu
    FROM zcc_vbak
    WHERE vbeln = gs_vbak-vbeln.

  gs_screen-etadat = sy-datum.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form number_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM number_range .

  DATA: lv_num   TYPE n LENGTH 8.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'                 " Number range number
      object      = 'ZCC_VBELN_'                 " Name of number range object
      quantity    = '1'              " Number of numbers
    IMPORTING
      number      = lv_num.                 " free number

  " 숫자 8자리 앞에 VL 붙임
  CONCATENATE 'VL' lv_num INTO gv_vbeln.






ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
FORM save_data .
*
  " 청구번호 넘버레인지
  PERFORM number_range.

  " 출고 헤더 저장 전에 중복 체크
  SELECT SINGLE vbeln
    FROM zcc_likp
    WHERE vbeln = @gs_screen-vbeln
    INTO @DATA(lv_exist_vbeln).

  " 존재 여부 판단
  IF sy-subrc <> 0. " 존재하지 않을 때만 헤더 저장
    CLEAR zcc_likp.
    "  출고헤더 저장
    zcc_likp-vbeln = gv_vbeln.
    zcc_likp-kunnr = gs_screen-kunnr.
    zcc_likp-vbeln_va = gs_screen-vbeln.
    zcc_likp-auart_va = gs_vbak-auart.
    zcc_likp-vdatu = gs_screen-vdatu.
    zcc_likp-etadat = gs_screen-etadat.
    zcc_likp-ernam = sy-uname.
    zcc_likp-erdat = sy-datum.
    zcc_likp-erzet = sy-uzeit.

    INSERT zcc_likp.
    IF sy-subrc <> 0.
      MESSAGE '출고 헤더 저장 중 오류가 발생했습니다.' TYPE 'E'.
      ROLLBACK WORK.
      RETURN.
    ENDIF.

  ENDIF.

  " 출고 아이템 저장
  CLEAR gs_vbap.
  LOOP AT gt_vbap INTO gs_vbap.

    CLEAR zcc_lips.
    zcc_lips-vbeln     = gv_vbeln.
    zcc_lips-posnr     = gs_vbap-posnr.
    zcc_lips-vbeln_va  = gs_vbap-vbeln.
    zcc_lips-posnr_va     = gs_vbap-posnr.
    zcc_lips-werks    = gs_screen-werks.
    zcc_lips-matnr     = gs_vbap-matnr.
    zcc_lips-lfimg    = gs_vbap-kwmeng.
    zcc_lips-meins     = gs_vbap-meins.
    zcc_lips-ernam = sy-uname.
    zcc_lips-erdat = sy-datum.
    zcc_lips-erzet = sy-uzeit.

    INSERT zcc_lips.
    IF sy-subrc <> 0.
      MESSAGE '출고 아이템 저장 중 오류가 발생했습니다.' TYPE 'E'.
      ROLLBACK WORK.
      RETURN.
    ENDIF.

*    출고된 판매오더 아이템 상태 업데이트
    UPDATE zcc_vbap
      SET status_it = 'DLV'
      WHERE vbeln = @gs_vbap-vbeln
        AND posnr = @gs_vbap-posnr.
    UPDATE zcc_vbak
      SET status = 'DLV'
      WHERE vbeln = @gs_screen-vbeln.

    IF sy-subrc <> 0.
      MESSAGE '상태 갱신 실패' TYPE 'E'.
      ROLLBACK WORK.
      RETURN.
    ENDIF.


  ENDLOOP.

  " 모든 작업 성공 시 실제 반영
  COMMIT WORK.
  MESSAGE i056(zcc_msg) WITH gv_vbeln DISPLAY LIKE 'S'.  "출고문서가 생성되었습니다.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0100
*&---------------------------------------------------------------------*
FORM refresh_alv_0100 .
  " ALV 메인 데이터 다시 SELECT
  PERFORM select_vbak_data.

  " 상태 아이콘 다시 계산
  PERFORM modify_status.

  CLEAR gt_vbap.
  PERFORM refresh_alv.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_item_data
*&---------------------------------------------------------------------*
FORM get_item_data  USING    pv_vbeln.
  " 아이템 데이터 조회

  SELECT
    vbeln,       "판매오더번호
    posnr,       "아이템 번호
    a~matnr,       "자재번호
    maktx,       "자재명
    spart,       "제품군
    kwmeng,      "수량
    meins,       "단위
    netpr,       "단가
    waers       "통화

INTO CORRESPONDING FIELDS OF TABLE @gt_vbap
FROM zcc_vbap AS a
JOIN zcc_makt AS b ON a~matnr = b~matnr
WHERE a~vbeln = @pv_vbeln
  AND spras = @sy-langu.

  LOOP AT gt_vbap INTO gs_vbap.

    CASE gs_vbap-spart.
      WHEN '1'.
        gs_vbap-spart_name = '건축용 내벽'.
      WHEN '2'.
        gs_vbap-spart_name = '건축용 외벽'.
      WHEN '3'.
        gs_vbap-spart_name = '건축용 친환경'.
      WHEN '4'.
        gs_vbap-spart_name = '조선용 방오도료'.
      WHEN '5'.
        gs_vbap-spart_name = '조선용 방오도료(데크)'.
      WHEN '6'.
        gs_vbap-spart_name = '조선용 코팅제'.
    ENDCASE.

    MODIFY gt_vbap FROM gs_vbap.


  ENDLOOP.

  CALL METHOD go_grid2->refresh_table_display.

  " 덤프 방지: 데이터가 있을 때만 갱신
  IF go_grid2 IS BOUND AND gt_vbap[] IS NOT INITIAL.
    CALL METHOD go_grid2->refresh_table_display.
  ELSE.
    MESSAGE '아이템 데이터가 없습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_search_fields
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_material_document
*&---------------------------------------------------------------------*
FORM create_material_document .


  DATA: ls_mkpf  TYPE zcc_mkpf,      " 헤더
        lt_mseg  TYPE zcc_mseg_tty,  " 아이템
        ls_mseg  TYPE zcc_mseg,      " 아이템 WA
        lv_msg   TYPE string,
        lv_subrc TYPE sy-subrc.

  " 헤더 세팅
  ls_mkpf-bldat = sy-datum.
  ls_mkpf-budat = sy-datum.
  ls_mkpf-bukrs = '1000'.
  ls_mkpf-bktxt = '제품 출하'.
  ls_mkpf-xblnr = gs_vbap-vbeln. " 판매오더 번호

  CLEAR gs_vbap.
  LOOP AT gt_vbap INTO gs_vbap.

    CLEAR ls_mseg.

    SELECT SINGLE lgort
      INTO ls_mseg-lgort
      FROM zcc_mard
      WHERE werks = gs_vbak-werks.

    ls_mseg-shkzg  = 'H'.
    ls_mseg-bwart  = '601'.
    ls_mseg-matnr  = gs_vbap-matnr.
    ls_mseg-werks  = gs_vbak-werks.
    ls_mseg-menge  = gs_vbap-kwmeng.
    ls_mseg-meins  = gs_vbap-meins.

    ls_mseg-vbeln  = gs_vbap-vbeln.  " 판매오더 번호
    ls_mseg-kunnr  = gs_vbak-kunnr.
    ls_mseg-posnr  = gs_vbap-posnr.

    APPEND ls_mseg TO lt_mseg.

  ENDLOOP.

  CALL FUNCTION 'ZCC_MM_GOODS_ISSUE'
    IMPORTING
      e_msg   = lv_msg
      e_subrc = lv_subrc
    CHANGING
      t_mseg  = lt_mseg
      i_mkpf  = ls_mkpf.

  IF lv_subrc = 0.
    WRITE: / ' 성공:', lv_msg.
    WRITE: / ' 생성된 문서번호:', ls_mkpf-mblnr.
  ELSE.
    WRITE: / ' 실패:', lv_msg.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_validate INPUT.

  " 1. 판매오더번호 존재 여부 확인
  LOOP AT so_vbeln.
    SELECT SINGLE vbeln FROM zcc_vbak INTO @DATA(lv_vbeln)
      WHERE vbeln = @so_vbeln-low.
    IF sy-subrc <> 0.
      MESSAGE i033(zcc_msg) WITH so_vbeln-low '고객코드' DISPLAY LIKE 'E'. " &1 은/는 유효하지 않는 &2입니다.
    ENDIF.
  ENDLOOP.

  " 고객코드 존재 여부 확인
  LOOP AT so_kunnr.
    SELECT SINGLE kunnr FROM zcc_kna1 INTO @DATA(lv_kunnr)
      WHERE kunnr = @so_kunnr-low.
    IF sy-subrc <> 0.
      MESSAGE i033(zcc_msg) WITH so_kunnr-low '고객코드' DISPLAY LIKE 'E'. " &1 은/는 유효하지 않는 &2입니다.
    ENDIF.
  ENDLOOP.



ENDMODULE.
*&---------------------------------------------------------------------*
*& Form create_document
*&---------------------------------------------------------------------*
FORM create_document .


  SELECT SINGLE vbeln, kunnr,  netwr, mwst, frbrt, waers
    INTO @DATA(ls_list)
    FROM zcc_vbak
    WHERE vbeln = @gs_screen-vbeln.

*" 테스트 데이터
  gs_list-bukrs = '1000'.
  gs_list-div   = '출고'.
  gs_list-waers = ls_list-waers.
  gs_list-bldat = sy-datum.
  gs_list-wrbtr = CONV string( ls_list-netwr ). " 문자로 변경 후 전달, 통화단위에 대한 공유 필요
  gs_list-mwskz = 'A0'.
  gs_list-mwsts = CONV string( ls_list-mwst ). " 문자로 변경 후 전달
  gs_list-frbrt = CONV string( ls_list-frbrt ).
*  gs_list-dity = CONV string(  ).

  gs_list-kunnr = ls_list-kunnr.
  gs_list-lifnr = ''.
  gs_list-vbeln_do = gv_vbeln.
  gs_list-ebeln = ''.
  gs_list-vbeln_vf = ''.
  gs_list-invno = ''.


  REFRESH gt_bdcdata.

  CLEAR gs_bdcdata.

  " BDC DATA 입력
  PERFORM bdc_data
      USING: 'X' 'ZCC_FI040' '1000',  " 입력 필드들에게 아래의 값을 한번에 입력하는 것, 순서대로 입력되는 개념이 아니라는 것.
             ' ' 'BDC_CURSOR'    'PA_BUKRS',
             ' ' 'PA_BUKRS'      gs_list-bukrs,       " 회사코드    (필수)
             ' ' 'PA_DIV'        gs_list-div,         " 전표유형    (필수) (SD: 출고, 판매송장) (MM: 입고, 구매송장)
             ' ' 'PA_WAERS'      gs_list-waers,       " 통화        (필수)
             ' ' 'PA_BLDAT'      gs_list-bldat,       " 일자        (필수) (출고일, 입고일, 송장발생일)
             ' ' 'PA_WRBTR'      gs_list-wrbtr,       " 총 금액     (필수)
             ' ' 'PA_MWSKZ'      gs_list-mwskz,       " 세금 코드   (선택)  (SD)
             ' ' 'PA_MWSTS'      gs_list-mwsts,       " 부가세 금액 (선택)  (SD)
             ' ' 'PA_FRBRT'      gs_list-frbrt,       " 배송비      (선택)  (SD)
             ' ' 'PA_DITY'       gs_list-dity,         " 관세비     (선택)  (MM)
             ' ' 'PA_KUNNR'      gs_list-kunnr,       " 고객 코드   (선택)  (SD)
             ' ' 'PA_LIFNR'      gs_list-lifnr,       " 거래처 코드 (선택)  (MM)
             ' ' 'PA_VBEDO'      gs_list-vbeln_do,    " 출고문서번호 (선택) (SD)
             ' ' 'PA_EBELN'      gs_list-ebeln,       " 구매오더번호 (선택) (MM)
             ' ' 'PA_VBEVF'      gs_list-vbeln_vf,    " 판매송장번호 (선택) (SD)
             ' ' 'PA_INVNO'      gs_list-invno,       " 구매송장번호 (선택) (MM)
             ' ' 'BDC_OKCODE'    '=ONLI'.             " F8


  " 옵션 설정
  DATA ls_options TYPE ctu_params.
  ls_options-dismode  = 'N'.           " 화면 표시 방식 지정 ('A': 전부, 'E': 에러만, 'N': 표시안함)
  ls_options-updmode  = 'S'.           " 업데이트 모드를 지정 ('A': 비동기, 'S': 동기, 'L': 로컬)
  ls_options-cattmode = ' '.           " CATT모드 사용 여부를 결정 ('N': 개별화면 제어가 없는 CATT, 'A': 개별화면 제어가 있는 CATT, ' ': CATT아님)
  ls_options-nobinpt  = ' '.           " Batch Input Mode 사용안함 ('X': 예, ' ': 아니오)
  ls_options-nobiend  = ' '.           " 배치 돌릴때 에러 발생시 Foreground로 전환, DISMODE가 'E'일 때만 사용가능 ('X': 예, ' ': 아니오)
  ls_options-defsize  = 'X'.           " 기본 윈도우 사이즈 설정 ('X': 예, ' ': 아니오)

  " 트랙잭션 호출
  CALL TRANSACTION 'ZCCFI040' USING gt_bdcdata OPTIONS FROM ls_options.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_data
*&---------------------------------------------------------------------*
FORM bdc_data  USING    VALUE(pv_screen)
                        VALUE(pv_name)
                        VALUE(pv_value).

  DATA ls_bdcdata TYPE bdcdata.

  IF pv_screen EQ 'X'.
    ls_bdcdata-dynbegin = pv_screen.  " BDC screen start "
    ls_bdcdata-program  = pv_name.    " BDC Program "
    ls_bdcdata-dynpro   = pv_value.   " BDC Screen Number "
  ELSE.
    ls_bdcdata-fnam     = pv_name.    " Field Name "
    ls_bdcdata-fval     = pv_value.   " BDC Field Value "
  ENDIF.

  APPEND ls_bdcdata TO gt_bdcdata.

  CLEAR ls_bdcdata.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fillter_selected_data
*&---------------------------------------------------------------------*
FORM fillter_selected_data  USING  pv_status TYPE zcc_vbak-status .

  DATA : lt_filt TYPE lvc_t_filt,
         ls_filt LIKE LINE OF lt_filt.

  IF pv_status EQ space.
    REFRESH lt_filt.
  ELSE.
    CLEAR ls_filt.
    ls_filt-fieldname = 'STATUS'.
    ls_filt-sign = 'I'.
    ls_filt-option = 'EQ'.
    ls_filt-low = pv_status.
    ls_filt-high = space.
    APPEND ls_filt TO lt_filt.
  ENDIF.

  go_grid1->set_filter_criteria(

      it_filter = lt_filt                 " Filter Conditions
  ).

  " ALV 리프레시
  CALL METHOD go_grid1->refresh_table_display( ).
*    PERFORM modify_status.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_all
*&---------------------------------------------------------------------*
FORM refresh_all .

  REFRESH : so_vbeln,
            so_kunnr,
            so_lfdat.

  CLEAR : gt_vbak,gt_vbap.



ENDFORM.
