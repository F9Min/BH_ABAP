*&---------------------------------------------------------------------*
*& Include MZCC_SD040TOP                            - Module Pool      SAPMZCC_SD040
*&---------------------------------------------------------------------*
PROGRAM sapmzcc_sd040 MESSAGE-ID zcc_msg.

TABLES : zcc_vbak,zcc_vbap, zcc_kna1,zcc_mard,zcc_makt,zcc_knkk.

TYPES : BEGIN OF ty_display,
          status    TYPE icon-id,
          vbeln     TYPE zcc_vbak-vbeln,
          posnr     TYPE zcc_vbap-posnr,
          kunnr     TYPE zcc_vbak-kunnr,
          name1     TYPE zcc_kna1-name1,
          stras     TYPE zcc_kna1-stras,
          matnr     TYPE zcc_vbap-matnr,
          spart     TYPE zcc_vbap-spart,
          kwmeng    TYPE zcc_vbap-kwmeng,
          meins     TYPE zcc_vbap-meins,
          netwr_it  TYPE zcc_vbap-netwr_it,
          waers     TYPE zcc_vbak-waers,
          status_it TYPE zcc_vbap-status_it,
        END OF ty_display.

DATA gs_display TYPE ty_display.

** 제품 상세 정보 조회
*DATA : BEGIN OF gs_material_info,
*         matnr TYPE zcc_mard-matnr,
*         maktx TYPE zcc_makt-maktx,
*         labst TYPE zcc_mard-labst,
*         meins TYPE zcc_mard-meins,
*       END OF gs_material_info.

* 고객 정보 조회
*DATA: BEGIN OF gs_customer_info,
*        kunnr  TYPE zcc_kna1-kunnr,   " 고객코드
*        name1  TYPE zcc_kna1-name1,   " 고객명
*        stras  TYPE zcc_kna1-stras,   " 주소
*        land1  TYPE zcc_kna1-land1,   " 국가코드
*        email  TYPE zcc_kna1-email,   " 이메일
*        telf   TYPE zcc_kna1-telf,    " 전화번호
*        rating TYPE zcc_knkk-rating,  " 여신등급
*        klimk  TYPE zcc_knkk-klimk,   " 여신한도
*      END OF gs_customer_info.



DATA gt_display LIKE TABLE OF gs_display.

DATA ok_code TYPE sy-ucomm.

DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

DATA : gs_fcat TYPE lvc_S_fcat,
       gt_fcat TYPE lvc_t_fcat.

DATA : gs_variant TYPE disvariant,
       gv_save    TYPE c,
       gs_layout  TYPE lvc_s_layo.
