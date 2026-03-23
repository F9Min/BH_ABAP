*&---------------------------------------------------------------------*
*& Include          ZSDR0160TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES : vbak, vbap, vbkd, vbpa.


*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
CLASS: lcl_event_receiver DEFINITION DEFERRED.

DATA : go_grid           TYPE REF TO cl_gui_alv_grid,
       go_custom         TYPE REF TO cl_gui_custom_container,
       go_docking        TYPE REF TO cl_gui_docking_container,
       go_splitter       TYPE REF TO cl_gui_splitter_container,
       go_parent_top     TYPE REF TO cl_gui_container,
       go_parent_grid    TYPE REF TO cl_gui_container,
       go_dyndoc_id      TYPE REF TO cl_dd_document,
       go_html_cntrl     TYPE REF TO cl_gui_html_viewer,
       go_tree           TYPE REF TO cl_gui_list_tree,
       go_event_receiver TYPE REF TO lcl_event_receiver,
       go_dialog         TYPE REF TO cl_gui_dialogbox_container.

DATA : gs_variant TYPE disvariant,
       gs_layout  TYPE lvc_s_layo,
       gs_toolbar TYPE stb_button,
       gs_func    TYPE ui_func,
       gt_func    TYPE ui_functions,
       gs_fcat    TYPE lvc_s_fcat,
       gt_fcat    TYPE lvc_t_fcat WITH HEADER LINE,
       gs_sort    TYPE lvc_s_sort,
       gt_sort    TYPE lvc_t_sort,
       gs_filt    TYPE lvc_s_filt,
       gt_filt    TYPE lvc_t_filt,
       gs_f4      TYPE lvc_s_f4,
       gt_f4      TYPE lvc_t_f4,
       gs_drop    TYPE lvc_s_drop,
       gt_drop    TYPE lvc_t_drop,
       gs_dral    TYPE lvc_s_dral,
       gt_dral    TYPE lvc_t_dral,
       gs_rows    TYPE lvc_s_roid,
       gt_rows    TYPE lvc_t_roid,
       gs_celltab TYPE lvc_s_styl,
       gt_celltab TYPE lvc_t_styl,
       gs_coltab  TYPE lvc_s_scol,
       gt_coltab  TYPE lvc_t_scol.



DATA : BEGIN OF gt_fcode OCCURS 20,
         fcode LIKE rsmpe-func,
       END OF gt_fcode.

DATA : ok_code LIKE sy-ucomm.

DATA: gs_row TYPE lvc_s_row,
      gt_row TYPE lvc_t_row.

*----------------------------------------------------------------------*
* Data Variables
*----------------------------------------------------------------------*


DATA : gv_return(1).

DATA : BEGIN OF gs_data,
         vbeln     LIKE vbak-vbeln,
         posnr     LIKE vbap-posnr,
         erdat     LIKE vbak-erdat,
         audat     LIKE vbak-audat,
         bstnk     LIKE vbak-bstnk,
         bstkd     LIKE vbkd-bstkd,
         vtweg     LIKE vbak-vtweg,
         vtwegt    LIKE tvtwt-vtext,
         vkbur     LIKE vbak-vkbur,
         vkburt    LIKE tvkbt-bezei,
         vkgrp     LIKE vbak-vkgrp,
         vkgrpt    LIKE tvgrt-bezei,
         kunnr     LIKE vbak-kunnr,
         kunnm     LIKE but000-name_org1,
         spras     LIKE kna1-spras,
         rgnr      LIKE vbpa-kunnr,
         rgnm      LIKE but000-name_org1,
         kdgrp     LIKE vbkd-kdgrp,
         kdgrpt    LIKE t151t-ktext,
         vbelv     LIKE vbfa-vbelv,
         posnv     LIKE vbfa-posnv,
         podkz     LIKE vbkd-podkz,
         auart     LIKE vbak-auart,
         auartt    LIKE tvakt-bezei,
         vbtyp     LIKE vbak-vbtyp,

         spart     LIKE vbap-spart,
         matnr     LIKE vbap-matnr,
         arktx     LIKE vbap-arktx,
         mvgr1     LIKE vbap-mvgr1,
         mvgr1t    LIKE tvm1t-bezei,
         mvgr2     LIKE vbap-mvgr2,
         mvgr2t    LIKE tvm2t-bezei,
         mvgr3     LIKE vbap-mvgr3,
         mvgr3t    LIKE tvm3t-bezei,
         mvgr4     LIKE vbap-mvgr4,
         mvgr4t    LIKE tvm4t-bezei,
         mvgr5     LIKE vbap-mvgr5,
         mvgr5t    LIKE tvm5t-bezei,
         ordqty_bu LIKE vbep-ordqty_bu, "주문수량
         werks     LIKE vbap-werks,
         lgort     LIKE vbap-lgort,
         vstel     LIKE vbap-vstel,
         li_vbeln  LIKE likp-vbeln,
         li_posnr  LIKE lips-posnr,
         lfimg     LIKE lips-lfimg,
         charg     LIKE lips-charg,
         vfdat     LIKE mcha-vfdat,
         hsdat     LIKE mcha-hsdat,
         wadat_ist LIKE likp-wadat_ist,
         podat     LIKE likp-podat,
         meins     TYPE meins,
         kwmeng    LIKE vbap-kwmeng,
         waerk     LIKE vbap-waerk,
         netwr     LIKE vbap-netwr,
         mwsbp     LIKE vbap-mwsbp,
         totamt    LIKE vbap-netwr,
         senr      LIKE vbpa-kunnr,
         senm      LIKE but000-name_org1,
*         zzaddrs   LIKE vbap-zzaddrs, "소비자 주소      "USER-EXIT
*         zzpstlz   LIKE vbap-zzpstlz, "우편번호
*         zzpname   LIKE vbap-zzpname, "수취인명
*         zztelno   LIKE vbap-zztelno, "전화번호
*         zzmobno   LIKE vbap-zzmobno, "핸드폰번호
*         zzdlmsg   LIKE vbap-zzdlmsg, "배송메세지
*         zzextso   LIKE vbap-zzextso, "온라인주문번호
*         zzsbnso   LIKE vbap-zzsbnso, "사방넷 주문번호
*
*         zzexmat   LIKE vbap-zzexmat, "온라인상품코드
*         zzexqty   LIKE vbap-zzexqty, "외부주문수량
*         zzexamt   LIKE vbap-zzexamt,
*         zzwaers   LIKE vbap-zzwaers, "외부주문통화
         vrkme     LIKE vbap-vrkme,
         dlv_txt   TYPE c LENGTH 100,
       END OF gs_data,
       gt_data LIKE TABLE OF gs_data.



*----------------------------------------------------------------------*
* Global variables
*----------------------------------------------------------------------*
DATA : g_bh_vkorg     TYPE vbak-vkorg  VALUE '1000'.  "영업조직


*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS           lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

*    METHODS : handle_top_of_page
*      FOR EVENT top_of_page OF cl_gui_alv_grid
*      IMPORTING e_dyndoc_id table_index.
    METHODS : handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column es_row_no,

      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
        FOR EVENT user_command OF  cl_gui_alv_grid
        IMPORTING e_ucomm.

ENDCLASS. "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
* LOCAL CLASSES: Implementation
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_double_click.
    PERFORM handel_double_click USING e_row e_column es_row_no.
  ENDMETHOD.

  METHOD handle_toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.
*
*  METHOD handle_top_of_page.
*    PERFORM HANDLE_TOP_OF_PAGE USING e_dyndoc_id.
*  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION



*----------------------------------------------------------------------*
*-- Selection Screen for User
*----------------------------------------------------------------------*
*
SELECTION-SCREEN BEGIN OF BLOCK b00 WITH FRAME.

  SELECT-OPTIONS : s_vkorg FOR vbak-vkorg DEFAULT g_bh_vkorg NO INTERVALS NO-EXTENSION, "G_BH_VKORG = 1000
                   s_erdat FOR vbak-erdat OBLIGATORY,
                   s_vtweg FOR vbak-vtweg,
                   s_auart FOR vbak-auart,
                   s_vkbur FOR vbak-vkbur,
                   s_vkgrp FOR vbak-vkgrp,
                   s_kdgrp FOR vbkd-kdgrp,
                   s_kunnr FOR vbak-kunnr,
                   s_werks FOR vbap-werks,
                   s_spart FOR vbap-spart,
                   s_matnr FOR vbap-matnr,
                   s_vstel FOR vbap-vstel,
                   s_lifnr FOR vbpa-lifnr,
                   s_vbeln FOR vbak-vbeln,
                   s_bstkd FOR vbkd-bstkd.

SELECTION-SCREEN END OF BLOCK b00.

SELECTION-SCREEN SKIP 1.

PARAMETERS p_vari TYPE disvariant-variant.
