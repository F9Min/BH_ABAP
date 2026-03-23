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
    WHERE A~LOEKZ IS INITIAL
      AND B~LOEKZ IS INITIAL
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
    MESSAGE '출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .
  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
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

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT          = GO_DOCKING                 " Parent Container
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

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT .

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
  LV_COL_POS = 10.

*&---------------------------------------------------------------------< 250805 : Chain 문법을 활용한 Subroutine 반복 개선
*                                                                          ㄴ Chainging의 경우 Using 이하 Chain 구문에 포함되기 때문에 매 Block 마다 포함시켜주어야함.
  PERFORM SET_FIELD_CATALOG USING : 'EBELN' ABAP_ON 'PO No.' 'EKKO' 'EBELN' CHANGING LV_COL_POS,
                                    'BEDAT' ABAP_ON 'Ordered Date' 'EKKO' 'BEDAT' CHANGING LV_COL_POS,
                                    'LIFNR' ABAP_ON 'Vendor' 'EKKO' 'LIFNR' CHANGING LV_COL_POS,
                                    'NAME1' SPACE 'Name' 'LFA1' 'NAME1' CHANGING LV_COL_POS,
                                    'ERNAM' SPACE 'Created By' 'EKKO' 'ERNAM' CHANGING LV_COL_POS,
                                    'TOTAL_NETWR' SPACE 'PO Amount' 'EKPO' 'NETWR' CHANGING LV_COL_POS,
                                    'WAERS' SPACE 'Unit' 'EKKO' 'WAERS' CHANGING LV_COL_POS.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG USING PV_FIELDNAME
                             PV_KEY
                             PV_COLTEXT
                             PV_REF_TABLE
                             PV_REF_FIELD
                    CHANGING PV_COL_POS.
*&---------------------------------------------------------------------> 250805
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

  CASE PV_FIELDNAME.
    WHEN 'BEDAT' OR 'LIFNR' OR 'ERNAM'.
      LS_FCAT-JUST = 'C'.
    WHEN 'EBELN'.
      LS_FCAT-JUST = 'C'.
      LS_FCAT-HOTSPOT = ABAP_ON.
    WHEN 'TOTAL_NETWR'.
      LS_FCAT-CFIELDNAME = 'WAERS'.
  ENDCASE.

  APPEND LS_FCAT TO GT_FCAT.
  PV_COL_POS += 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING PV_COLUMN_ID
                          PV_ROW_ID.

  CASE PV_COLUMN_ID.
    WHEN 'EBELN'.
      READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) INDEX PV_ROW_ID.

      IF SY-SUBRC EQ 0.
        DATA(LV_PO) = LS_DISPLAY-EBELN.

*        SET PARAMETER ID 'BES' FIELD SPACE.
        SET PARAMETER ID 'BES' FIELD LV_PO.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ELSE.
        MESSAGE '유효하지 않은 Po Number 입니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN OTHERS.
      MESSAGE 'HOTSPOT 이벤트가 존재하지 않는 열입니다.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .

  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID.

ENDFORM.
