*&---------------------------------------------------------------------*
*& Include          MZCC_SD020_TOP
*&---------------------------------------------------------------------*
PROGRAM sapmzcc_sd050.

TABLES :zcc_vbak,zcc_kna1,zcc_likp,zcc_lips,zcc_t001w,zcc_vbap.


* 판매오더 헤더 ALV1 출력용
TYPES : BEGIN OF ty_vbak,
          status_icon TYPE icon-id,         "출고문서 유무
          status_text TYPE c LENGTH 7,
          vbeln       TYPE zcc_vbak-vbeln,  "판매문서번호
          kunnr       TYPE zcc_vbak-vbeln,  "고객코드
          name1       TYPE zcc_kna1-name1,  "고객이름
          auart       TYPE zcc_vbak-auart,  "주문유형
          stras       TYPE zcc_kna1-stras,  "배송지
          vdatu       TYPE zcc_vbak-vdatu,
          werks       TYPE zcc_vbak-werks,
          name2       TYPE zcc_t001w-name1,
          status      TYPE zcc_vbak-status,
        END OF ty_vbak.

DATA: gs_vbak TYPE ty_vbak,
      gt_vbak LIKE TABLE OF gs_vbak.

* 판매오더 아이템 ALV2 출력용
TYPES : BEGIN OF ty_vbap,
*          vbeln       TYPE zcc_lips-vbeln,   "출고문서 번호
          vbeln      TYPE zcc_lips-vbeln_va, "판매문서 번호
          posnr      TYPE zcc_vbap-posnr,   "아이템 번호
          matnr      TYPE zcc_vbap-matnr,   "자재번호
          maktx      TYPE zcc_makt-maktx,  " 자재명
          spart      TYPE zcc_vbap-spart,  " 제품군
          spart_name TYPE zcc_makt-maktx,  " 제품군명
          kwmeng     TYPE zcc_vbap-kwmeng, " 수량
          meins      TYPE zcc_VBAP-meins,  " 단위
          netpr      TYPE zcc_vbap-netpr,  " 단가
          waers      TYPE zcc_vbak-waers,  " 통화

        END OF ty_vbap.

DATA: gs_vbap TYPE ty_vbap,
      gt_vbap LIKE TABLE OF gs_vbap.

" 출고문서 팝업용 데이터 선언
TYPES: BEGIN OF ty_screen,
         vbeln  TYPE zcc_vbak-vbeln,
         kunnr  TYPE zcc_vbak-kunnr,
         name1  TYPE zcc_kna1-name1,
         stras  TYPE zcc_vbak-stras,
         werks  TYPE zcc_vbak-werks,
         name2  TYPE zcc_t001w-name1,
         vdatu  TYPE zcc_vbak-vdatu,
         etadat TYPE zcc_likp-etadat,
       END OF ty_screen.

DATA: gs_screen TYPE ty_screen.

" 출고문서 넘버레인지용
DATA : gv_vbeln TYPE zcc_likp-vbeln.

* -- 전표 생성을 위한 데이터 선언 --
  DATA gt_bdcdata TYPE TABLE OF bdcdata.
  DATA gs_bdcdata TYPE bdcdata.

  DATA: BEGIN OF gs_list.
  DATA: bukrs    TYPE zcc_bkpf-bukrs,    " 회사코드
        div      TYPE c LENGTH 4,        " 전표유형 (SD: 출고, 판매송장) (MM: 입고, 구매송장)
        waers    TYPE zcc_bkpf-waers,    " 통화
        bldat    TYPE zcc_bkpf-bldat,    " 전기일자
        wrbtr    TYPE c LENGTH 20,       " 총 금액
        mwskz    TYPE zcc_bseg-mwskz,    " 세금 코드
        mwsts    TYPE c LENGTH 20,       " 부가세 금액
        frbrt    TYPE c LENGTH 20,       " 배송비 (KRW)
        dity     TYPE c LENGTH 20,       " 관세 (KRW)
        kunnr    TYPE zcc_bseg-kunnr,    " 고객 코드
        lifnr    TYPE zcc_bseg-lifnr,    " 거래처 코드
        vbeln_do TYPE zcc_bseg-vbeln,    " 출고문서번호
        ebeln    TYPE zcc_bseg-ebeln,    " 구매오더번호
        vbeln_vf TYPE zcc_bseg-vbeln_vf,
        invno    TYPE zcc_bseg-invno,
        END OF gs_list.

DATA        ok_code TYPE sy-ucomm.

* splitter 할 큰 custom container
DATA : go_custom TYPE REF TO cl_gui_custom_container.

DATA go_splitter TYPE REF TO cl_gui_splitter_container.

* splitter 된 두개의 CONTAINER + 팝업용 ALV + 재고 조회용.
DATA : go_container1 TYPE REF TO cl_gui_container,
       go_container2 TYPE REF TO cl_gui_container,
       go_container3 TYPE REF TO cl_gui_custom_container.

* 두 CONTAINER에 연결될 ALV GRID
DATA : go_grid1 TYPE REF TO cl_gui_alv_grid,
       go_grid2 TYPE REF TO cl_gui_alv_grid,
       go_grid3 TYPE REF TO cl_gui_alv_grid.

DATA : gs_fcat TYPE lvc_s_fcat.

DATA : gt_fcat1 TYPE lvc_t_fcat,
       gt_fcat2 TYPE lvc_t_fcat,
       gt_fcat3 TYPE lvc_t_fcat.

DATA : gs_layout1 TYPE lvc_s_layo,
       gs_layout2 TYPE lvc_s_layo,
       gs_layout3 TYPE lvc_s_layo.

DATA: gs_variant TYPE disvariant,
      gv_save    TYPE c.
