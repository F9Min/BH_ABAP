*&---------------------------------------------------------------------*
*& Include          Z2508R010_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT A~EBELN,                        " PO 번호
         A~BEDAT,                        " 생성 일자
         A~LIFNR,                        " 공급업체
         C~NAME1,                        " 업체명
         A~ERNAM,                        " 생성자
         SUM( B~NETWR ) AS TOTAL_NETWR,  " 합계금액
         A~WAERS                         " 단위
    FROM EKKO AS A
    JOIN EKPO AS B
      ON A~EBELN EQ B~EBELN
    JOIN LFA1 AS C
      ON A~LIFNR EQ C~LIFNR
    WHERE A~LOEKZ IS INITIAL             " 삭제되지 않은 PO 정보 Listing
      AND B~LOEKZ IS INITIAL             " 삭제되지 않은 Line Item의 정보만 집계
      AND A~EKORG IN @S_EKORG
      AND A~EKGRP IN @S_EKGRP
      AND C~LIFNR IN @S_LIFNR
      AND A~BEDAT IN @S_BEDAT
    GROUP BY A~EBELN, A~BEDAT, A~LIFNR, C~NAME1, A~ERNAM, A~WAERS
    ORDER BY A~EBELN, A~BEDAT, A~LIFNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF GT_DISPLAY IS INITIAL.
    MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'.  " 출력할 데이터가 없습니다.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR : OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

  IF GT_ITEM IS NOT INITIAL.
    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .
  CREATE OBJECT GO_DOCKING
    EXPORTING
      REPID                       = SY-CPROG         " Report to Which This Docking Control is Linked
      DYNNR                       = SY-DYNNR         " Screen to Which This Docking Control is Linked
      EXTENSION                   = 5000             " Control Extension
    EXCEPTIONS
      CNTL_ERROR                  = 1                " Invalid Parent Control
      CNTL_SYSTEM_ERROR           = 2                " System Error
      CREATE_ERROR                = 3                " Create Error
      LIFETIME_ERROR              = 4                " Lifetime Error
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CREATE OBJECT GO_SPLITTER                  " 화면을 상/하단으로 분리하여 ALV를 출력하기 위해 SPLITTER CONTAINER 사용
    EXPORTING
      PARENT            = GO_DOCKING         " Parent Container
      ROWS              = 2                  " Number of Rows to be displayed
      COLUMNS           = 1                  " Number of Columns to be Displayed
    EXCEPTIONS
      CNTL_ERROR        = 1                  " See Superclass
      CNTL_SYSTEM_ERROR = 2                  " See Superclass
      OTHERS            = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_SPLITTER->GET_CONTAINER  " SPLITTER로 분할한 화면에 CONTAINER 할당
    EXPORTING
      ROW       = 1                       " Row
      COLUMN    = 1                       " Column
    RECEIVING
      CONTAINER = GO_CONTAINER1.          " Container

  CALL METHOD GO_SPLITTER->GET_CONTAINER  " SPLITTER로 분할한 화면에 CONTAINER 할당
    EXPORTING
      ROW       = 2                       " Row
      COLUMN    = 1                       " Column
    RECEIVING
      CONTAINER = GO_CONTAINER2.          " Container

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT          = GO_CONTAINER1    " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1                " Error when creating the control
      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
      ERROR_CNTL_LINK   = 3                " Error While Linking Control
      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CREATE OBJECT GO_ALV_GRID2
    EXPORTING
      I_PARENT          = GO_CONTAINER2    " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1                " Error when creating the control
      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
      ERROR_CNTL_LINK   = 3                " Error While Linking Control
      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO .

  GS_LAYO-CWIDTH_OPT = 'X'.
  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-SEL_MODE = 'D'.

* 조회된 PO의 개수를 Display 하기 위한 소스코드 블록
  DESCRIBE TABLE GT_DISPLAY LINES DATA(LV_PO_LINES).
  GS_LAYO-GRID_TITLE = |[ Found { LV_PO_LINES } PO's ]|.
  GS_LAYO-SMALLTITLE = 'X'.

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT CHANGING PT_FCAT TYPE LVC_T_FCAT.

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
  LV_COL_POS = 10.

  IF GT_ITEM IS NOT INITIAL.  " 상단 ALV에서 PO No.를 클릭할 경우 GT_ITEM에 데이터가 SELECTION 되므로 [ GT_ITEM 데이터 존재 = 상단 ALV는 이미 생성됨 = 하단 ALV의 FCAT 생성 필요 ]를 의미함
    PERFORM SET_FIELD_CATALOG USING : 'EBELN' ABAP_ON 'PO No.'                'EKKO'  'EBELN' CHANGING LV_COL_POS PT_FCAT,
                                      'EBELP' ABAP_ON 'Line No.'              'EKPO'  'EBELP' CHANGING LV_COL_POS PT_FCAT,
                                      'MATNR' ABAP_ON 'Material Code'         'EKKO'  'MATNR' CHANGING LV_COL_POS PT_FCAT,
                                      'MAKTX' SPACE   'Material Name'         'MAKT'  'MAKTX' CHANGING LV_COL_POS PT_FCAT,
                                      'LGOBE' SPACE   'Storage Location Name' 'T001L' 'LGOBE' CHANGING LV_COL_POS PT_FCAT,
                                      'MENGE' SPACE   'PO Quantity'           'EKPO'  'MENGE' CHANGING LV_COL_POS PT_FCAT,
                                      'MEINS' SPACE   'Qty. Unit'             'EKPO'  'MEINS' CHANGING LV_COL_POS PT_FCAT,
                                      'NETPR' SPACE   'Unit Price'            'EKPO'  'NETPR' CHANGING LV_COL_POS PT_FCAT,
                                      'NETWR' SPACE   'Total Amount'          'EKPO'  'NETWR' CHANGING LV_COL_POS PT_FCAT,
                                      'WAERS' SPACE   'Material Name'         'EKKO'  'WAERS' CHANGING LV_COL_POS PT_FCAT.

  ELSE.
*&---------------------------------------------------------------------< 250805 : Chain 문법을 활용한 Subroutine 반복 개선
*                                                                          ㄴ Chainging의 경우 Using 이하 Chain 구문에 포함되기 때문에 매 Block 마다 포함시켜주어야함.
    PERFORM SET_FIELD_CATALOG USING : 'EBELN'       ABAP_ON 'PO No.'       'EKKO' 'EBELN' CHANGING LV_COL_POS PT_FCAT,
                                      'BEDAT'       ABAP_ON 'Ordered Date' 'EKKO' 'BEDAT' CHANGING LV_COL_POS PT_FCAT,
                                      'LIFNR'       ABAP_ON 'Vendor'       'EKKO' 'LIFNR' CHANGING LV_COL_POS PT_FCAT,
                                      'NAME1'       SPACE   'Name'         'LFA1' 'NAME1' CHANGING LV_COL_POS PT_FCAT,
                                      'ERNAM'       SPACE   'Created By'   'EKKO' 'ERNAM' CHANGING LV_COL_POS PT_FCAT,
                                      'TOTAL_NETWR' SPACE   'PO Amount'    'EKPO' 'NETWR' CHANGING LV_COL_POS PT_FCAT,
                                      'WAERS'       SPACE   'Unit'         'EKKO' 'WAERS' CHANGING LV_COL_POS PT_FCAT.

*&---------------------------------------------------------------------> 250805 : Subroutine 반복 개선
*  PERFORM SET_FIELD_CATALOG USING 'BEDAT' ABAP_ON 'Ordered Date' 'EKKO' 'BEDAT'
*                          CHANGING LV_COL_POS GT_FCAT.
*
*  PERFORM SET_FIELD_CATALOG USING 'LIFNR' ABAP_ON 'Vendor' 'EKKO' 'LIFNR'
*                         CHANGING LV_COL_POS GT_FCAT.
*
*  PERFORM SET_FIELD_CATALOG USING 'NAME1' SPACE 'Name' 'LFA1' 'NAME1'
*                         CHANGING LV_COL_POS GT_FCAT.
*
*  PERFORM SET_FIELD_CATALOG USING 'ERNAM' SPACE 'Created By' 'EKKO' 'ERNAM'
*                         CHANGING LV_COL_POS GT_FCAT.
*
*  PERFORM SET_FIELD_CATALOG USING 'TOTAL_NETWR' SPACE 'PO Amount' 'EKPO' 'NETWR'
*                         CHANGING LV_COL_POS GT_FCAT.
*
*  PERFORM SET_FIELD_CATALOG USING 'WAERS' SPACE 'Unit' 'EKKO' 'WAERS'
*                         CHANGING LV_COL_POS GT_FCAT.
*&--------------------------------------------------------------------->

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE          " Save Layout
      IS_LAYOUT                     = GS_LAYO          " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY       " Output Table
      IT_FIELDCATALOG               = GT_FCAT          " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF GT_FCAT_ITEM IS NOT INITIAL.
    CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT       " Layout
        I_SAVE                        = GV_SAVE          " Save Layout
        IS_LAYOUT                     = GS_LAYO_ITEM     " Layout
      CHANGING
        IT_OUTTAB                     = GT_ITEM          " Output Table
        IT_FIELDCATALOG               = GT_FCAT_ITEM     " Field Catalog
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
        PROGRAM_ERROR                 = 2                " Program Errors
        TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG USING PV_FIELDNAME
                             PV_KEY
                             PV_COLTEXT
                             PV_REF_TABLE
                             PV_REF_FIELD
                    CHANGING PV_COL_POS
*&---------------------------------------------------------------------< 250806 : ALV가 복수개 발생함에 따라 어떤 FCAT 을 조작할지 받기 위해 파라미터 추가
                             PT_FCAT TYPE LVC_T_FCAT.
*&---------------------------------------------------------------------> 250805 : BASE 키워드 기반 구문 제거
*  PT_FCAT[] = VALUE #( BASE PT_FCAT[] ( FIELDNAME   = PV_FIELDNAME
*                                        KEY         = PV_KEY
*                                        COL_POS     = PV_COL_POS
*                                        COLTEXT     = PV_COLTEXT
*                                        REF_TABLE   = PV_REF_TABLE
*                                        REF_FIELD   = PV_REF_FIELD
*                                         ) ).
*&---------------------------------------------------------------------> 250805

*&---------------------------------------------------------------------< 250805 : 필드별 유동 상황에 대처하기 위한 코드 개선
*                                                                          ㄴ Case문을 활용하기 위해 BASE 키워드가 아닌 Case 문 이후 Append 구문 활용
*                                                                          ㄴ BASE 문을 활용하지 않고 Local Structure를 활용하므로 Chaiging Parameter에서 Field Catalog ITAB 제거
  DATA(LS_FCAT) = VALUE LVC_S_FCAT( FIELDNAME = PV_FIELDNAME
                                    KEY = PV_KEY
                                    COL_POS = PV_COL_POS
                                    COLTEXT = PV_COLTEXT
                                    REF_TABLE = PV_REF_TABLE
                                    REF_FIELD = PV_REF_FIELD
                                   ).

  CASE PT_FCAT.

    WHEN GT_FCAT.
      CASE PV_FIELDNAME.
        WHEN 'BEDAT' OR 'ERNAM'.
          LS_FCAT-JUST = 'C'.
        WHEN 'EBELN' OR 'LIFNR'.
          LS_FCAT-JUST = 'C'.
          LS_FCAT-HOTSPOT = ABAP_ON.
        WHEN 'TOTAL_NETWR'.
          LS_FCAT-CFIELDNAME = 'WAERS'.
          LS_FCAT-EMPHASIZE = 'X'.
      ENDCASE.

    WHEN GT_FCAT_ITEM.
      CASE PV_FIELDNAME.
        WHEN 'EBELN'.
          LS_FCAT-JUST = 'C'.
          LS_FCAT-HOTSPOT = ABAP_ON.
        WHEN 'MATNR'.
          LS_FCAT-HOTSPOT = ABAP_ON.
        WHEN 'MENGE'.
          LS_FCAT-QFIELDNAME = 'MEINS'.
          LS_FCAT-EMPHASIZE = 'X'.
        WHEN 'NETPR' OR 'NETWR'.
          LS_FCAT-CFIELDNAME = 'WAERS'.
          LS_FCAT-EMPHASIZE = 'X'.
        WHEN OTHERS.
      ENDCASE.

  ENDCASE.

  APPEND LS_FCAT TO PT_FCAT.
  PV_COL_POS += 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING PV_COLUMN_ID
                          PV_ROW_ID.

  CASE PV_COLUMN_ID.
    WHEN 'EBELN'.  " PO No. 클릭 시 ME23N으로 진입하도록 함.
      READ TABLE GT_ITEM INTO DATA(LS_ITEM) INDEX PV_ROW_ID.

      IF SY-SUBRC EQ 0.
        DATA(LV_PO) = LS_ITEM-EBELN.

*        SET PARAMETER ID 'BES' FIELD SPACE.
        SET PARAMETER ID 'BES' FIELD LV_PO.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ELSE.
        MESSAGE TEXT-E02 TYPE 'S' DISPLAY LIKE 'E'.  " 유효하지 않은 PO No. 입니다.
        RETURN.
      ENDIF.

    WHEN 'MATNR'.  " Material Number 클릭 시 MM03으로 진입하도록 함.
      READ TABLE GT_ITEM INTO LS_ITEM INDEX PV_ROW_ID.

      IF SY-SUBRC EQ 0.
        DATA(LV_MATNR) = LS_ITEM-MATNR.

*       SET PARAMETER ID 'BES' FIELD SPACE.
        SET PARAMETER ID 'MAT' FIELD LV_MATNR.

*       MM03에서 Basic View만 선택한 상태로 진입하도록 함, 이때 PARAMETER ID는 STANDARD 소스코드 상 하드코딩 된 부분이므로 소스코드 분석을 통해 알아내야함.
        SET PARAMETER ID 'MXX' FIELD 'K'.

        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

      ELSE.
        MESSAGE TEXT-E06 TYPE 'S' DISPLAY LIKE 'E'.  " 유효하지 않은 Material Code 입니다.
        RETURN.
      ENDIF.

    WHEN OTHERS.
      MESSAGE TEXT-E04 TYPE 'S' DISPLAY LIKE 'E'.  " HOTSPOT 이벤트가 존재하지 않는 열입니다.
      RETURN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .

* 상/하단 ALV 모두 PO No.에 대한 HOTSPOT EVENT가 존재하므로 서로 다른 EVENT_HANDLER를 사용
  SET HANDLER LCL_HEADER_EVENT_HANDELR=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID.
  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HEADER_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM HEADER_HOTSPOT_CLICK  USING P_COLUMN_ID
                                 P_ROW_ID.

  CASE P_COLUMN_ID.
    WHEN 'EBELN'.  " PO No. 클릭 시 하단 ALV에 해당 PO No.의 ITEM LIST 상세출력
      READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) INDEX P_ROW_ID.

      IF SY-SUBRC EQ 0.
        PERFORM SELECT_ITEM USING LS_DISPLAY-EBELN.
        IF GT_FCAT_ITEM IS INITIAL.
          " 하단 ALV가 초기상태일 때의 로직
          PERFORM SET_FIELDCAT CHANGING GT_FCAT_ITEM.
          PERFORM SET_ITEM_LAYO USING LS_DISPLAY-EBELN.

          PERFORM DISPLAY_ALV.
        ELSE.
          " 하단 ALV에 데이터가 있으나 새로운 PO No.를 클릭하여 ALV의 갱신이 필요한 경우
          PERFORM SET_ITEM_LAYO USING LS_DISPLAY-EBELN. " LAYOUT 갱신 : GRID_TITLE 변경

          " 변경된 LAYOUT 반영
          CALL METHOD GO_ALV_GRID2->SET_FRONTEND_LAYOUT
            EXPORTING
              IS_LAYOUT = GS_LAYO_ITEM.                 " Layout

          PERFORM REFRESH_ALV.  " REFESH
        ENDIF.

      ELSE.
        MESSAGE TEXT-E02 TYPE 'S' DISPLAY LIKE 'E'.  " 유효하지 않은 PO No. 입니다.
        RETURN.
      ENDIF.

    WHEN 'LIFNR'.  " Vendor 클릭 시 XK03 화면으로 이동
      READ TABLE GT_DISPLAY INTO LS_DISPLAY INDEX P_ROW_ID.

      IF SY-SUBRC EQ 0.
        DATA(LV_LIFNR) = LS_DISPLAY-LIFNR.
        DATA: KDY_VAL(8) VALUE '/110'.

        SET PARAMETER ID 'LIF' FIELD LV_LIFNR.  " 클릭한 LIFNR을 PARAMETER에 전달
        SET PARAMETER ID 'KDY' FIELD KDY_VAL.   " Address View만 선택한 상태로 화면에 진입하기 위해 파라미터 값 전달
        CALL TRANSACTION 'XK03' AND SKIP FIRST SCREEN.

      ELSE.
        MESSAGE TEXT-E03 TYPE 'S' DISPLAY LIKE 'E'.  " 유효하지 않은 Vendor 입니다.
        RETURN.
      ENDIF.

    WHEN OTHERS.
      MESSAGE TEXT-E04 TYPE 'S' DISPLAY LIKE 'E'.  " HOTSPOT 이벤트가 존재하지 않는 열입니다.
      RETURN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ITEM
*&---------------------------------------------------------------------*
FORM SELECT_ITEM  USING PV_EBELN.

  SELECT A~EBELN,
         B~EBELP,
         B~MATNR,
         C~MAKTX,
         D~LGOBE,
         B~MENGE,
         B~MEINS,
         B~NETPR,
         B~NETWR,
         A~WAERS
    FROM EKKO AS A
    JOIN EKPO AS B
      ON A~EBELN EQ B~EBELN
    LEFT OUTER JOIN MAKT AS C
      ON B~MATNR EQ C~MATNR AND C~SPRAS EQ @SY-LANGU
    JOIN T001L AS D
      ON D~WERKS EQ B~WERKS AND D~LGORT EQ B~LGORT
    WHERE A~EBELN EQ @PV_EBELN                        " 선택된 PO No.를 기준으로 ITEM 정보 SELECT
    ORDER BY B~EBELP
    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

  IF GT_ITEM IS INITIAL.
    MESSAGE TEXT-E05 TYPE 'S' DISPLAY LIKE 'E'.  " 해당 PO No.의 ITEM 데이터가 존재하지 않습니다.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM INITIAL_VALUE .
  DATA : LV_MONTH TYPE NUMC2.

  LV_MONTH = SY-DATUM+4(2) - 1 .                    " 전월

  S_BEDAT-LOW = SY-DATUM+0(4) && LV_MONTH && '01'.  " Low 값을 전월 1일로 설정
  S_BEDAT-HIGH = SY-DATUM.                          " High 값은 현재일로 설장

  APPEND S_BEDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_item_layo
*&---------------------------------------------------------------------*
FORM SET_ITEM_LAYO  USING    PV_DISPLAY_EBELN.

*&---------------------------------------------------------------------< 250807 : 하단 ALV와 GS_LAYO를 공유함에 따라 GS_LAYO_ITEM 추가
  DESCRIBE TABLE GT_ITEM LINES DATA(LV_ITEM_LINES).

  GS_LAYO_ITEM-CWIDTH_OPT = 'A'.
  GS_LAYO_ITEM-ZEBRA = 'X'.
  GS_LAYO_ITEM-SEL_MODE = 'D'.

* 선택된 PO 번호와 해당 PO 번호의 ITEM 개수를 Display 하기 위한 소스코드 블록
  GS_LAYO_ITEM-GRID_TITLE = |[ PO { PV_DISPLAY_EBELN } has { LV_ITEM_LINES } line items. ]|.
  GS_LAYO_ITEM-SMALLTITLE = 'X'.

ENDFORM.
