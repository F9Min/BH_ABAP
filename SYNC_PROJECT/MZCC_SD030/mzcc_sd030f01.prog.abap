*&---------------------------------------------------------------------*
*& Include          MZCC_SD030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FILL_VBAK
*&---------------------------------------------------------------------*
FORM FILL_VBAK .
*&---------------------------------------------------------------------*
* 고객 정보로부터 가져올 수 있는 정보를 입력
*&---------------------------------------------------------------------*
  MOVE-CORRESPONDING ZCC_KNA1 TO ZCC_VBAK.

* 추가정보입력
  ZCC_VBAK-STATUS = 'WT'.
  ZCC_VBAK-MWSKZ = 'A0'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
FORM BUILD_NODE_AND_ITEM_TABLE  USING   NODE_TABLE TYPE TREEV_NTAB
                                        ITEM_TABLE TYPE ITEM_TABLE_TYPE.

  DATA: NODE TYPE TREEV_NODE,
        ITEM TYPE MTREEITM.

*&---------------------------------------------------------------------*
* 1. ROOT NODE : 제품

  CLEAR NODE.
  NODE-NODE_KEY  = 'ROOT'.         " 루트 노드의 키
  NODE-RELATKEY  = SPACE.          " 루트이므로 부모노드 없음
  NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
  NODE-HIDDEN    = ABAP_OFF.
  NODE-DISABLED  = ABAP_OFF.
  NODE-ISFOLDER  = ABAP_ON.        " 폴더처럼 보이게 하여 확장 가능
  NODE-N_IMAGE   = SPACE.          " 아이콘 없음
  NODE-EXPANDER  = ABAP_OFF.       " 루트 폴더는 항상 열려있는 상태
  APPEND NODE TO NODE_TABLE.

  CLEAR ITEM.
  ITEM-NODE_KEY   = 'ROOT'.
  ITEM-ITEM_NAME  = 'HEADTEXT'.    " 트리에서 계층 구조로 사용할 컬럼
  ITEM-TEXT       = '제품'.             " 노드에 표시될 텍스트
  APPEND ITEM TO ITEM_TABLE.

*&---------------------------------------------------------------------*
* 2-1. 제품군 노드
  CLEAR NODE.
  NODE-NODE_KEY = 'SPART'.
  NODE-RELATKEY = 'ROOT'.
  NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
  NODE-ISFOLDER = 'X'.
  NODE-EXPANDER = 'X'.
  APPEND NODE TO NODE_TABLE.

  CLEAR ITEM.
  ITEM-NODE_KEY   = 'SPART'.
  ITEM-ITEM_NAME  = 'HEADTEXT'.    " 트리에서 계층 구조로 사용할 컬럼
  ITEM-TEXT       = '제품군'.           " 노드에 표시될 텍스트
  APPEND ITEM TO ITEM_TABLE.

* 2-2. 색상 노드
  CLEAR NODE.
  NODE-NODE_KEY = 'COLOR'.
  NODE-RELATKEY = 'ROOT'.
  NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
  NODE-ISFOLDER = 'X'.
  NODE-EXPANDER = 'X'.
  APPEND NODE TO NODE_TABLE.

  CLEAR ITEM.
  ITEM-NODE_KEY = 'COLOR'.
  ITEM-ITEM_NAME = 'HEADTEXT'.
  ITEM-TEXT = '색상'.
  APPEND ITEM TO ITEM_TABLE.

*&---------------------------------------------------------------------*
* 3-1. 제품군 별 노드 & 아이템 세팅
  SELECT FROM DD07L AS A
         LEFT OUTER JOIN
              DD07T AS B ON A~DOMNAME   EQ B~DOMNAME
                        AND A~AS4LOCAL  EQ B~AS4LOCAL
                        AND A~VALPOS    EQ B~VALPOS
                        AND A~AS4VERS   EQ B~AS4VERS
         FIELDS A~DOMVALUE_L, B~DDTEXT
         WHERE A~DOMNAME    EQ 'ZCC_SPART'
           AND B~DDLANGUAGE EQ @SY-LANGU
           AND A~AS4LOCAL   EQ 'A'  " Active인 Fixed Value만 조회
         ORDER BY A~VALPOS
          INTO TABLE @DATA(LT_SPART).

  LOOP AT LT_SPART INTO DATA(LS_SPART).
    CLEAR NODE.
    NODE-NODE_KEY = 'SPART_' && LS_SPART-DOMVALUE_L.  " Domain의 Fixed Value
    NODE-RELATKEY = 'SPART'.
    NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
    NODE-ISFOLDER = 'X'.
    NODE-EXPANDER = 'X'.
    APPEND NODE TO NODE_TABLE.

    CLEAR ITEM.
    ITEM-NODE_KEY   = NODE-NODE_KEY.
    ITEM-ITEM_NAME  = 'HEADTEXT'.
    ITEM-TEXT       = LS_SPART-DDTEXT.  " Domain의 Fixed Value의 Description
    APPEND ITEM TO ITEM_TABLE.
  ENDLOOP.

*&---------------------------------------------------------------------*
* 3-2. 색상 별 노드 & 아이템 세팅
  SELECT FROM DD07L AS A
         LEFT OUTER JOIN
              DD07T AS B ON A~DOMNAME  EQ B~DOMNAME
                        AND A~AS4LOCAL EQ B~AS4LOCAL
                        AND A~VALPOS   EQ B~VALPOS
                        AND A~AS4VERS  EQ B~AS4VERS
    FIELDS A~DOMVALUE_L, B~DDTEXT
    WHERE A~DOMNAME EQ 'ZCC_COLOR'
      AND B~DDLANGUAGE EQ @SY-LANGU
      AND A~AS4LOCAL EQ 'A'
    ORDER BY A~VALPOS
      INTO TABLE @DATA(LT_COLOR).

  LOOP AT LT_COLOR INTO DATA(LS_COLOR).
    CLEAR NODE.
    IF LS_COLOR-DOMVALUE_L IS INITIAL.
      NODE-NODE_KEY = 'COLOR_N'.
    ELSE.
      NODE-NODE_KEY = 'COLOR_' && LS_COLOR-DOMVALUE_L.
    ENDIF.

    NODE-RELATKEY = 'COLOR'.
    NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
    NODE-ISFOLDER = 'X'.
    NODE-EXPANDER = 'X'.
    APPEND NODE TO NODE_TABLE.

    CLEAR ITEM.
    ITEM-NODE_KEY = NODE-NODE_KEY.
    ITEM-ITEM_NAME = 'HEADTEXT'.
    ITEM-TEXT = LS_COLOR-DDTEXT.
    APPEND ITEM TO ITEM_TABLE.
  ENDLOOP.

*&---------------------------------------------------------------------*
* 4-1. 제품군 별 완제품 노드 & 아이템 세팅
  DATA : BEGIN OF LS_PRODUCT_SPART,
           MATNR TYPE ZCC_MARA-MATNR,
           SPART TYPE ZCC_MARA-SPART,
           MAKTG TYPE ZCC_MAKT-MAKTG,
         END OF LS_PRODUCT_SPART,
         LT_PRODUCT_SPART LIKE TABLE OF LS_PRODUCT_SPART.

  SELECT A~MATNR
         A~SPART
         B~MAKTG
    INTO CORRESPONDING FIELDS OF TABLE LT_PRODUCT_SPART
    FROM ZCC_MARA AS A
    LEFT OUTER JOIN ZCC_MAKT AS B ON B~MATNR EQ A~MATNR
                                 AND B~SPRAS EQ SY-LANGU
    WHERE A~MTART EQ 'FERT'.

  SORT LT_PRODUCT_SPART BY MATNR.

  LOOP AT LT_PRODUCT_SPART INTO LS_PRODUCT_SPART.

    CLEAR NODE.
    NODE-NODE_KEY  = 'SPART_' && LS_PRODUCT_SPART-SPART && '_' && SY-TABIX.
    NODE-RELATKEY  = 'SPART_' && LS_PRODUCT_SPART-SPART.
    NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
    NODE-ISFOLDER  = ABAP_OFF.
    NODE-EXPANDER  = ABAP_OFF.
    APPEND NODE TO NODE_TABLE.

    CLEAR ITEM.
    ITEM-NODE_KEY   = NODE-NODE_KEY.
    ITEM-ITEM_NAME  = 'HEADTEXT'.
    ITEM-TEXT       = LS_PRODUCT_SPART-MATNR.
    APPEND ITEM TO ITEM_TABLE.

    ITEM-ITEM_NAME  = 'CATEGORY1'.
    ITEM-TEXT       = LS_PRODUCT_SPART-MAKTG.
    APPEND ITEM TO ITEM_TABLE.

  ENDLOOP.
* 4-2. 색상 별 완제품 노드 & 아이템 세팅
  DATA : BEGIN OF LS_PRODUCT_COLOR,
           MATNR TYPE ZCC_MARA-MATNR,
           COLOR TYPE ZCC_MARA-COLOR,
           MAKTG TYPE ZCC_MAKT-MAKTG,
         END OF LS_PRODUCT_COLOR,
         LT_PRODUCT_COLOR LIKE TABLE OF LS_PRODUCT_COLOR.

  SELECT A~MATNR
         A~COLOR
         B~MAKTG
    INTO CORRESPONDING FIELDS OF TABLE LT_PRODUCT_COLOR
    FROM ZCC_MARA AS A
    LEFT OUTER JOIN ZCC_MAKT AS B ON B~MATNR EQ A~MATNR
                                 AND B~SPRAS EQ SY-LANGU
    WHERE A~MTART EQ 'FERT'.

  SORT LT_PRODUCT_COLOR BY MATNR.

  LOOP AT LT_PRODUCT_COLOR INTO LS_PRODUCT_COLOR.

    CLEAR NODE.
    IF LS_PRODUCT_COLOR-COLOR IS INITIAL.
      NODE-NODE_KEY  = 'COLOR_N_' && SY-TABIX.
      NODE-RELATKEY  = 'COLOR_N'.
    ELSE.
      NODE-NODE_KEY  = 'COLOR_' && LS_PRODUCT_COLOR-COLOR && '_' && SY-TABIX.
      NODE-RELATKEY  = 'COLOR_' && LS_PRODUCT_COLOR-COLOR.
    ENDIF.

    NODE-RELATSHIP = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD.
    NODE-ISFOLDER  = ABAP_OFF.
    NODE-EXPANDER  = ABAP_OFF.
    APPEND NODE TO NODE_TABLE.

    CLEAR ITEM.
    ITEM-NODE_KEY  = NODE-NODE_KEY.
    ITEM-ITEM_NAME = 'HEADTEXT'.
    ITEM-TEXT      = LS_PRODUCT_COLOR-MATNR.
    APPEND ITEM TO ITEM_TABLE.

    ITEM-ITEM_NAME = 'CATEGORY1'.
    ITEM-TEXT      = LS_PRODUCT_COLOR-MAKTG.
    APPEND ITEM TO ITEM_TABLE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TREE_COLUMN
*&---------------------------------------------------------------------*
FORM ADD_TREE_COLUMN .

  CALL METHOD G_TREE->ADD_COLUMN
    EXPORTING
      NAME        = 'CATEGORY1'     " Column Name
      WIDTH       = '45'                 " Column Width
      HEADER_TEXT = '제품명'.            " Text for Header

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0120
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0120 .

  " CUSTOM CONTAINER 객체 생성
  CREATE OBJECT GO_CUSTOM
    EXPORTING
      CONTAINER_NAME              = 'CCON'
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I070(ZCC_MSG) DISPLAY LIKE 'E'. " CNTL_ERROR
      WHEN 2.
        MESSAGE I071(ZCC_MSG) DISPLAY LIKE 'E'. " CNTL_SYSTEM_ERROR
      WHEN 3.
        MESSAGE I072(ZCC_MSG) DISPLAY LIKE 'E'. " CREATE_ERROR
      WHEN 4.
        MESSAGE I073(ZCC_MSG) DISPLAY LIKE 'E'. " LIFETIME_ERROR
      WHEN 5.
        MESSAGE I074(ZCC_MSG) DISPLAY LIKE 'E'. " LIFETIME_DYNPRO_DYNPRO_LINK
      WHEN 6.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

  " SPLITTER CONTAINER 객체 생성
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT            = GO_CUSTOM                   " Parent Container
      ROWS              = 1                   " Number of Rows to be displayed
      COLUMNS           = 2                   " Number of Columns to be Displayed
    EXCEPTIONS
      CNTL_ERROR        = 1                  " See Superclass
      CNTL_SYSTEM_ERROR = 2                  " See Superclass
      OTHERS            = 3.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1 OR 2.
        MESSAGE I083(ZCC_MSG) DISPLAY LIKE 'E'. " See Superclass
      WHEN 3.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

  PERFORM SET_SPLITTER.

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT          = GO_CONTAINER2    " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1                " Error when creating the control
      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
      ERROR_CNTL_LINK   = 3                " Error While Linking Control
      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I076(ZCC_MSG) DISPLAY LIKE 'E'. " Error when creating the control
      WHEN 2.
        MESSAGE I077(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Initializing Control
      WHEN 3.
        MESSAGE I078(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Linking Control
      WHEN 4.
        MESSAGE I079(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
      WHEN 5.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

  CREATE OBJECT GO_EVENT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_LAYOUT_0120
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0120 .

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'A'.

  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-CWIDTH_OPT = 'A'.
  GS_LAYO-SEL_MODE = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT .

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'POSNR'.
  GS_FCAT-COLTEXT = '항목번호'.
  GS_FCAT-COL_POS = 10.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  GS_FCAT-JUST = 'LEFT'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'MATNR'.
  GS_FCAT-COLTEXT = '자재번호'.
  GS_FCAT-KEY = 'X'.
  GS_FCAT-COL_POS = 20.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'MAKTG'.
  GS_FCAT-COLTEXT = '자재명'.
  GS_FCAT-COL_POS = 30.
  GS_FCAT-REF_TABLE = 'ZCC_MAKT'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'SPART'.
  GS_FCAT-COLTEXT = '제품군'.
  GS_FCAT-COL_POS = 40.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'SPART_TXT'.
  GS_FCAT-COLTEXT = '제품군명'.
  GS_FCAT-COL_POS = 45.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'KWMENG'.
  GS_FCAT-COLTEXT = '주문수량'.
  GS_FCAT-COL_POS = 50.
  GS_FCAT-EDIT = 'X'.
  GS_FCAT-QFIELDNAME = 'MEINS'.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'MEINS'.
  GS_FCAT-COLTEXT = '수량단위'.
  GS_FCAT-COL_POS = 60.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'NETPR'.
  GS_FCAT-COLTEXT = '단가'.
  GS_FCAT-COL_POS = 70.
  GS_FCAT-CFIELDNAME = 'WAERS'.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'NETWR_IT'.
  GS_FCAT-COLTEXT = '순금액'.
  GS_FCAT-COL_POS = 80.
  GS_FCAT-CFIELDNAME = 'WAERS'.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR : GS_FCAT.
  GS_FCAT-FIELDNAME = 'WAERS'.
  GS_FCAT-COLTEXT = '통화단위'.
  GS_FCAT-COL_POS = 90.
  GS_FCAT-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0120
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0120 .

  CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_STRUCTURE_NAME              = 'ZCC_VBAP'                 " Internal Output Table Structure Name
      IS_VARIANT                    = GS_VARIANT                 " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
      IS_LAYOUT                     = GS_LAYO                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                  " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I080(ZCC_MSG) DISPLAY LIKE 'E'. " Wrong Parameter
      WHEN 2.
        MESSAGE I081(ZCC_MSG) DISPLAY LIKE 'E'. " Program Errors
      WHEN 3.
        MESSAGE I082(ZCC_MSG) DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
      WHEN 4.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPLITTER
*&---------------------------------------------------------------------*
FORM SET_SPLITTER .

  " SPLITTER CONTAINER로 구역을 나누어 CONTAINER 지정
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1                 " Row
      COLUMN    = 1                 " Column
    RECEIVING
      CONTAINER = GO_CONTAINER1.    " Container

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1                 " Row
      COLUMN    = 2                 " Column
    RECEIVING
      CONTAINER = GO_CONTAINER2.    " Container

  CALL METHOD GO_SPLITTER->SET_COLUMN_WIDTH
    EXPORTING
      ID                = 1                     " Column ID
      WIDTH             = 40                    " NPlWidth
    EXCEPTIONS
      CNTL_ERROR        = 1                " See CL_GUI_CONTROL
      CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
      OTHERS            = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FC1
*&---------------------------------------------------------------------*
FORM CHECK_FC1 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_ALV
*&---------------------------------------------------------------------*
FORM FILL_ALV  USING PS_MVKE TYPE ZCC_MVKE.
*&---------------------------------------------------------------------*
* DISPLAY TABLE MODIFICATION
*&---------------------------------------------------------------------*
  DATA : LV_LINES TYPE I.

  " 앞서 제품 테이블에서 읽어온 데이터( 자재번호, 제품군, 단가, 통화, 수량단위 )를 ZCC_VBAP의 구조를 포함하는 WA에 옮긴다.
  MOVE-CORRESPONDING PS_MVKE TO GS_DISPLAY.

  " 앞서 생성한 주문번호와 동일한 번호를 사용한다.
  GS_DISPLAY-VBELN = ZCC_VBAK-VBELN.
  " POSNR을 매기기 위해 GT_DATA에 있는 데이터의 총 개수를 센다.
  " 이때 POSNR은 GT_DISPLAY에 있는 행 정보가 삭제 혹은 삽입될 수 있으므로 GT_DISPLAY의 행 개수를 기준으로 설정되어야 한다.
  DESCRIBE TABLE GT_DISPLAY LINES LV_LINES.
  GS_DISPLAY-POSNR = ( LV_LINES + 1 ) * 10.
  " 제품개수의 초기값은 10개로 설정하고 이후 사용자가 변경 가능하도록 한다.
  IF GS_QUOT-KWMENG IS INITIAL.
    GS_DISPLAY-KWMENG = 1.
  ELSE.
    GS_DISPLAY-KWMENG = GS_QUOT-KWMENG.
  ENDIF.

*&---------------------------------------------------------------------*
* 가격 정보 Setting
*&---------------------------------------------------------------------*
  DATA : LV_NETPR TYPE ZCC_VBAP-NETPR.
  LV_NETPR = GS_DISPLAY-NETPR.

  IF ZCC_KNA1-LAND1 NE 'KR'.
    PERFORM CURR_EXCHANGE USING 'KRW'                 " 기준통화
                              ZCC_KNA1-WAERS        " 변환통화
                              SY-DATUM              " 적용일자
                              GS_DISPLAY-NETPR              " 환전 이전 금액
                     CHANGING GS_DISPLAY-NETPR.     " 환전 이후 금액

    GS_DISPLAY-WAERS = ZCC_KNA1-WAERS.
  ENDIF.

  GS_DISPLAY-NETWR_IT = GS_DISPLAY-NETPR * GS_DISPLAY-KWMENG.

*&---------------------------------------------------------------------*
* 제품명과 제품군명 Setting
*&---------------------------------------------------------------------*
  " 로그온 언어에 맞는 제품명을 보여주기 위해 자재명 테이블에서 자재코드에 맞는 자재명을 가져온다.
  SELECT SINGLE MAKTG
    INTO GS_DISPLAY-MAKTG
    FROM ZCC_MAKT
    WHERE MATNR EQ GS_DISPLAY-MATNR
      AND SPRAS EQ SY-LANGU.

  " 제품군에 따른 제품군명을 FIXED VALUE를 참조하여 보여주기 위해 DATA SELECTION 을 진행한다.
  SELECT SINGLE
         FROM DD07L AS A
         LEFT OUTER JOIN
              DD07T AS B ON A~DOMNAME   EQ B~DOMNAME
                        AND A~AS4LOCAL  EQ B~AS4LOCAL
                        AND A~VALPOS    EQ B~VALPOS
                        AND A~AS4VERS   EQ B~AS4VERS
         FIELDS B~DDTEXT
         WHERE A~DOMNAME    EQ 'ZCC_SPART'
           AND B~DDLANGUAGE EQ @SY-LANGU
           AND A~AS4LOCAL   EQ 'A'  " Active인 Fixed Value만 조회
           AND A~DOMVALUE_L EQ @GS_DISPLAY-SPART
          INTO @GS_DISPLAY-SPART_TXT.

  " 최종적으로 데이터를 보여줄 DISPLAY TABLE에 APPEND 한다.
  APPEND GS_DISPLAY TO GT_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DATA .

  DATA : LV_SUM TYPE INT8.

  IF ZCC_KNA1-LAND1 EQ 'KR'.
    " 국내 고객사의 경우 최소주문량 검사한다.
    LOOP AT GT_DISPLAY INTO GS_DISPLAY.
      IF GS_DISPLAY-KWMENG < 10.
        " 국내 판매의 최소주문량은 아이템 당 10(EA) 입니다.
        MESSAGE S037(ZCC_MSG) DISPLAY LIKE 'E'.
        " 데이터 검사를 통과하지 못한 경우 아이템 입력 탭이 출력되도록 OK_CODE 수정
        OK_CODE = 'FC2'.
        EXIT.
      ENDIF.

    ENDLOOP.

  ELSE.
    " 해외 고객사의 경우 최소주문량 검사한다.
    LOOP AT GT_DISPLAY INTO GS_DISPLAY.
      " 완제품의 판매 단위는 모두 EA 이므로 단순합산을 통해 최소 주문수량을 맞추었는지 점검할 수 있다.
      LV_SUM += GS_DISPLAY-KWMENG.
    ENDLOOP.

    IF LV_SUM < 100.
      " 해외 판매의 최소주문량은 총 100(EA) 입니다.
      MESSAGE S038(ZCC_MSG) DISPLAY LIKE 'E'.
      " 데이터 검사를 통과하지 못한 경우 아이템 입력 탭이 출력되도록 OK_CODE 수정
      OK_CODE = 'FC2'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_EVENT_0120
*&---------------------------------------------------------------------*
FORM SET_ALV_EVENT_0120 .

  CALL METHOD GO_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.  " Event ID

  SET HANDLER GO_EVENT->ON_DATA_CHANGED           FOR GO_ALV_GRID.
  SET HANDLER GO_EVENT->ON_DATA_CHANGED_FINISHED  FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HANDLER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM ALV_HANDLER_DATA_CHANGED  USING PO_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

* GO_EVENT -> DATA_CHANGED : INSTANCE EVENT
* DATA_CHANGED의 PARAMETER : ER_DATA_CHANGED < REFERENCE VARIABLE, CL_ALV_CHANGED_DATA_PROTOCOL
* ER_DATA_CHANGED->MT_MOD_CELLS : LVC_T_MODI, 변경된 셀의 ROW_ID, FIELDNAME, VALUE를 알아낼 수 있음.
* ER_DATA_CHANGED->MODIFY_CELL : CELL의 정보 변경 METHOD

* METHOD 여러 번 호출하는 것을 간략화 하기 위해서 매크로 사용
  DEFINE __GET_VALUE.

    ASSIGN COMPONENT &1 OF STRUCTURE GS_DISPLAY TO <FS>.
    IF SY-SUBRC EQ 0.

      PO_DATA_CHANGED->GET_CELL_VALUE(
        EXPORTING
          I_ROW_ID    = LS_MODI-ROW_ID  " Row ID
          I_FIELDNAME = &1              " Field Name
        IMPORTING
          E_VALUE     = <FS>              " Cell Content
      ).

      UNASSIGN <FS>.
    ENDIF.

  END-OF-DEFINITION.

  DEFINE __MODIFY_VALUE.

    ASSIGN COMPONENT &1 OF STRUCTURE GS_DISPLAY TO <FS>.
    IF SY-SUBRC EQ 0.

      PO_DATA_CHANGED->MODIFY_CELL(
        I_ROW_ID    = LS_MODI-ROW_ID      " Row ID
        I_FIELDNAME = &1                  " Field Name
        I_VALUE     = <FS>                " Value
      ).

      UNASSIGN <FS>.
    ENDIF.

  END-OF-DEFINITION.

  DATA : LT_MODI TYPE LVC_T_MODI,
         LS_MODI TYPE LVC_S_MODI,
         LV_P    TYPE P DECIMALS 3,
         LV_I    TYPE I.

  FIELD-SYMBOLS <FS>.

  LT_MODI = PO_DATA_CHANGED->MT_MOD_CELLS.

* 변경된 셀의 정보를 가져오며 LOOP문 진행
  LOOP AT LT_MODI INTO LS_MODI.
*   항상 FIELDNAME에 대한 검사를 진행한다.
    CASE LS_MODI-FIELDNAME.
      WHEN 'KWMENG'.
*     수량 필드의 수정에 대해서 이하 코드 블록 진행
*       숫자 데이터는 자동으로 천단위 구분기호가 생기기 때문에 천단위 구분기호(,) 제거
        REPLACE ALL OCCURRENCES OF ',' IN LS_MODI-VALUE WITH SPACE.
*       정수여부를 검사하기 위해 입력된 VALUE를 변수에 저장
        LV_I = LV_P = LS_MODI-VALUE.

*       값에 대한 정합성 검사
        IF LS_MODI-VALUE LT 0.
*         아이템 당 주문수량은 0보다 커야합니다.
*         시스템 상에서 음수는 입력 안되지만.. 일단 입력한거니까 살려놓기.
          CALL METHOD PO_DATA_CHANGED->ADD_PROTOCOL_ENTRY
            EXPORTING
              I_MSGID     = 'ZCC_MSG'         " Message ID
              I_MSGTY     = 'E'               " Message Type
              I_MSGNO     = '039'             " Message No.
              I_FIELDNAME = LS_MODI-FIELDNAME " Field Name
              I_ROW_ID    = LS_MODI-ROW_ID    " RowID
              I_TABIX     = LS_MODI-TABIX.    " Table Index
*         여러 필드를 한번에 수정했을 경우 LOOP문이 끊기지 않게 하기 위해 CONTINUE 사용.
          CONTINUE.
        ELSEIF LV_P NE LV_I.
          " 아이템 당 주문 수량은 정수로 입력되어야합니다.
          CALL METHOD PO_DATA_CHANGED->ADD_PROTOCOL_ENTRY
            EXPORTING
              I_MSGID     = 'ZCC_MSG'         " Message ID
              I_MSGTY     = 'E'               " Message Type
              I_MSGNO     = '040'             " Message No.
              I_FIELDNAME = LS_MODI-FIELDNAME " Field Name
              I_ROW_ID    = LS_MODI-ROW_ID    " RowID
              I_TABIX     = LS_MODI-TABIX.    " Table Index
          CONTINUE.
        ENDIF.

*       정합성 검사를 통과한 경우 => 수량 * 단가로 금액도 UPDATE
        __GET_VALUE: 'VBELN',
                     'POSNR',
                     'MATNR',
                     'NETPR'.

        GS_DISPLAY-NETWR_IT = LV_I * GS_DISPLAY-NETPR.

        __MODIFY_VALUE 'NETWR_IT'.

*       DB TABLE UPDATE를 위해 관련 WA와 ITAB 내용도 업데이트
        READ TABLE GT_DATA INTO GS_DATA WITH KEY VBELN = GS_DISPLAY-VBELN
                                                 POSNR = GS_DISPLAY-POSNR
                                                 MATNR = GS_DISPLAY-MATNR.
        IF SY-SUBRC EQ 0.
          GS_DATA-KWMENG   = LV_I.
          GS_DATA-NETWR_IT = GS_DISPLAY-NETWR_IT.
          MODIFY GT_DATA FROM GS_DATA INDEX SY-TABIX.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0130
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0130 .

  " CUSTOM CONTAINER 객체 생성
  CREATE OBJECT GO_CUSTOM2
    EXPORTING
      CONTAINER_NAME              = 'CCON2'
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I070(ZCC_MSG) DISPLAY LIKE 'E'. " CNTL_ERROR
      WHEN 2.
        MESSAGE I071(ZCC_MSG) DISPLAY LIKE 'E'. " CNTL_SYSTEM_ERROR
      WHEN 3.
        MESSAGE I072(ZCC_MSG) DISPLAY LIKE 'E'. " CREATE_ERROR
      WHEN 4.
        MESSAGE I073(ZCC_MSG) DISPLAY LIKE 'E'. " LIFETIME_ERROR
      WHEN 5.
        MESSAGE I074(ZCC_MSG) DISPLAY LIKE 'E'. " LIFETIME_DYNPRO_DYNPRO_LINK
      WHEN 6.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

  CREATE OBJECT GO_ALV_GRID2
    EXPORTING
      I_PARENT          = GO_CUSTOM2    " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1                " Error when creating the control
      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
      ERROR_CNTL_LINK   = 3                " Error While Linking Control
      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I076(ZCC_MSG) DISPLAY LIKE 'E'. " Error when creating the control
      WHEN 2.
        MESSAGE I077(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Initializing Control
      WHEN 3.
        MESSAGE I078(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Linking Control
      WHEN 4.
        MESSAGE I079(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
      WHEN 5.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0130
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0130 .

  CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_STRUCTURE_NAME              = 'ZCC_VBAP'                 " Internal Output Table Structure Name
      IS_VARIANT                    = GS_VARIANT                 " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
      IS_LAYOUT                     = GS_LAYO                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT2                  " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I080(ZCC_MSG) DISPLAY LIKE 'E'. " Wrong Parameter
      WHEN 2.
        MESSAGE I081(ZCC_MSG) DISPLAY LIKE 'E'. " Program Errors
      WHEN 3.
        MESSAGE I082(ZCC_MSG) DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
      WHEN 4.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT2
*&---------------------------------------------------------------------*
FORM SET_FCAT2 .

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'POSNR'.
  GS_FCAT2-COLTEXT = '항목번호'.
  GS_FCAT2-COL_POS = 10.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  GS_FCAT2-JUST = 'LEFT'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'MATNR'.
  GS_FCAT2-COLTEXT = '자재번호'.
  GS_FCAT2-KEY = 'X'.
  GS_FCAT2-COL_POS = 20.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'MAKTG'.
  GS_FCAT2-COLTEXT = '자재명'.
  GS_FCAT2-COL_POS = 30.
  GS_FCAT2-REF_TABLE = 'ZCC_MAKT'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'SPART'.
  GS_FCAT2-COLTEXT = '제품군'.
  GS_FCAT2-COL_POS = 40.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'SPART_TXT'.
  GS_FCAT2-COLTEXT = '제품군명'.
  GS_FCAT2-COL_POS = 45.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'KWMENG'.
  GS_FCAT2-COLTEXT = '주문수량'.
  GS_FCAT2-COL_POS = 50.
  GS_FCAT2-QFIELDNAME = 'MEINS'.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'MEINS'.
  GS_FCAT2-COLTEXT = '수량단위'.
  GS_FCAT2-COL_POS = 60.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'NETPR'.
  GS_FCAT2-COLTEXT = '단가'.
  GS_FCAT2-COL_POS = 70.
  GS_FCAT2-CFIELDNAME = 'WAERS'.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'NETWR_IT'.
  GS_FCAT2-COLTEXT = '순금액'.
  GS_FCAT2-COL_POS = 80.
  GS_FCAT2-CFIELDNAME = 'WAERS'.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR : GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'WAERS'.
  GS_FCAT2-COLTEXT = '통화단위'.
  GS_FCAT2-COL_POS = 90.
  GS_FCAT2-REF_TABLE = 'ZCC_VBAP'.
  APPEND GS_FCAT2 TO GT_FCAT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PRICE
*&---------------------------------------------------------------------*
FORM SET_PRICE .

  DATA : LV_NETWR  TYPE ZCC_VBAK-NETWR,
         LV_DISCNT TYPE ZCC_VBAK-DISCNT,
         " 환율이 적용된 값을 넣기 위한
         IV_WRBTR  TYPE ZCC_BSEG-WRBTR.

  LOOP AT GT_DISPLAY INTO GS_DISPLAY.
*   총 순금액은 아이템별 순금액의 총합
    ZCC_VBAK-NETWR += GS_DISPLAY-NETWR_IT.

*   할인금액은 물량할인을 적용하지만 물량 기준이 국가에 따라 상이하다.
    IF ZCC_KNA1-LAND1 EQ 'KR' AND GS_DISPLAY-KWMENG GT 100.
      " 국내 기업의 경우 아이템 당 100개 이상 구매할 경우 1% 할인
      ZCC_VBAK-DISCNT += GS_DISPLAY-NETWR_IT / 100.

    ELSEIF ZCC_KNA1-LAND1 NE 'KR' AND GS_DISPLAY-KWMENG GT 300.
      " 해외 기업의 경우 아이템 당 300개 이상 구매할 경우 1% 할인
      ZCC_VBAK-DISCNT += GS_DISPLAY-NETWR_IT / 100.

    ENDIF.
  ENDLOOP.

* 부가세는 국내만 10% 추가부여한다.
  IF ZCC_KNA1-LAND1 EQ 'KR'.
    ZCC_VBAK-MWST = ZCC_VBAK-NETWR / 10.
  ELSE.
    ZCC_VBAK-MWST = 0.
  ENDIF.

* 배송비는 국가에 따라 일괄적인 금액을 매긴다.
  IF ZCC_KNA1-LAND1 EQ 'KR'.
    ZCC_VBAK-FRBRT = '700.00'.
  ELSEIF ZCC_KNA1-LAND1 EQ 'SG'.
    PERFORM CURR_EXCHANGE USING 'KRW'               " 기준통화
                                ZCC_KNA1-WAERS      " 변환통화
                                SY-DATUM            " 적용일자
                                '8100.00'           " 환전 이전 금액
                       CHANGING ZCC_VBAK-FRBRT.     " 환전 이후 금액
  ELSEIF ZCC_KNA1-LAND1 EQ 'CN'.
    PERFORM CURR_EXCHANGE USING 'KRW'               " 기준통화
                                ZCC_KNA1-WAERS      " 변환통화
                                SY-DATUM            " 적용일자
                                '5320.00'           " 환전 이전 금액
                       CHANGING ZCC_VBAK-FRBRT.     " 환전 이후 금액
  ELSEIF ZCC_KNA1-LAND1 EQ 'JP'.
    PERFORM CURR_EXCHANGE USING 'KRW'               " 기준통화
                                ZCC_KNA1-WAERS      " 변환통화
                                SY-DATUM            " 적용일자
                                '4095.00'           " 환전 이전 금액
                       CHANGING ZCC_VBAK-FRBRT.     " 환전 이후 금액
  ENDIF.

  GV_TOTAL_COST = ZCC_VBAK-NETWR + ZCC_VBAK-MWST + ZCC_VBAK-FRBRT - ZCC_VBAK-DISCNT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FINAL_SAVE
*&---------------------------------------------------------------------*
FORM FINAL_SAVE .
*&---------------------------------------------------------------------*
* 자동채번로직
*&---------------------------------------------------------------------*
  IF GV_CHECK EQ 'X'.
    " 최소주문수량을 맞추었는지 검사
    PERFORM CHECK_DATA.
    PERFORM SET_DATA USING GT_DISPLAY.

    ZCC_VBAK-ERNAM = SY-UNAME.
    ZCC_VBAK-ERDAT = SY-DATUM.
    ZCC_VBAK-ERZET = SY-UZEIT.

    " 데이터 저장
    INSERT ZCC_VBAK FROM ZCC_VBAK.
    INSERT ZCC_VBAP FROM TABLE GT_DATA.

    " 여신점검
    SUBMIT ZCC_SD070 WITH P_VBELN = ZCC_VBAK-VBELN
                     WITH P_KUNNR = SPACE
                     WITH P_AMOUNT = SPACE
                     AND RETURN.

    SELECT SINGLE STATUS
      FROM ZCC_VBAK
      INTO @DATA(LV_STATUS)
      WHERE VBELN = @ZCC_VBAK-VBELN.

    IF LV_STATUS EQ 'RG'.
      MESSAGE '반려되었습니다' TYPE 'E'.
      EXIT.
    ENDIF.

    IF SY-SUBRC NE 0.
      MESSAGE S046(ZCC_MSG) DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ELSE.
      MESSAGE S047(ZCC_MSG).
      IF GS_QUOT IS NOT INITIAL.
        PERFORM UPDATE_QUOT USING GS_QUOT
                         CHANGING ZCC_QUOT.
      ENDIF.
    ENDIF.

  ELSE.
    MESSAGE S045(ZCC_MSG) DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CURR_EXCHANGE
*&---------------------------------------------------------------------*
FORM CURR_EXCHANGE  USING    VALUE(P_KRW) TYPE ZCC_FCURR        " 기준통화
                             P_WAERS      TYPE ZCC_TCURR        " 변환통화
                             P_DATUM      TYPE ZCC_ZCURR_GDATU  " 적용일자
                             P_DISCNT     TYPE ZCC_WRBTR        " 환전 이전 금액
                    CHANGING P_VBAK       TYPE ZCC_WRBTR.       " 환전 이후 금액

  CALL FUNCTION 'ZCC_FI_CURR_EXCHANGE_DB'
    EXPORTING
      IM_FCURR          = P_KRW          " 기준 통화
      IM_TCURR          = P_WAERS        " 변환 통화
      IM_GDATU          = P_DATUM        " 적용 일자
      IM_WRBTR          = P_DISCNT       " 환전 금액
    IMPORTING
      EV_WRBTR          = P_VBAK         " 환전 금액
    EXCEPTIONS
      NO_DATA_EXCEPTION = 1              " 환율 데이터가 없습니다.
      OTHERS            = 2.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA
*&---------------------------------------------------------------------*
FORM SET_DATA  USING PT_DISPLAY TYPE TT_DISPLAY.

  DATA : LV_NUM TYPE STRING.

  MOVE-CORRESPONDING PT_DISPLAY TO GT_DATA.

* 사용자가 최종 확인을 위한 체크박스에 체크를 완료한 경우 저장 진행
* 저장할 때 자동채번 진행을 위한 함수 사용
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '1'                 " Number range number
      OBJECT                  = 'ZCC_VB_SO'          " Name of number range object
    IMPORTING
      NUMBER                  = LV_NUM               " free number
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1 " Interval not found
      NUMBER_RANGE_NOT_INTERN = 2 " Number range is not internal
      OBJECT_NOT_FOUND        = 3 " Object not defined in TNRO
      QUANTITY_IS_0           = 4 " Number of numbers requested must be > 0
      QUANTITY_IS_NOT_1       = 5 " Number of numbers requested must be 1
      INTERVAL_OVERFLOW       = 6 " Interval used up. Change not possible.
      BUFFER_OVERFLOW         = 7 " Buffer is full
      OTHERS                  = 8.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Interval not found'.
      WHEN 2.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Number range is not internal'.
      WHEN 3.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Object not defined in TNRO'.
      WHEN 4.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Number of numbers requested must be > 0'.
      WHEN 5.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Number of numbers requested must be 1'.
      WHEN 6.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Interval used up. Change not possible.'.
      WHEN 7.
        MESSAGE I000(ZCC_MSG) DISPLAY LIKE 'E' WITH 'Buffer is full'.
      WHEN 8.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'.
    ENDCASE.

  ENDIF.

* 숫자 4자리 앞에 SO[ 년도 뒷 2자리 ][ 월 ]  붙임
  CONCATENATE 'SO' SY-DATUM+2(4) LV_NUM INTO ZCC_VBAK-VBELN.

  LOOP AT GT_DATA INTO GS_DATA.
    " 자동채번 숫자를 아이템 테이블에도 반영
    GS_DATA-VBELN = ZCC_VBAK-VBELN.
    GS_DATA-STATUS_IT = 'WT'.
    GS_DATA-ERNAM = SY-UNAME.
    GS_DATA-ERDAT = SY-DATUM.
    GS_DATA-ERZET = SY-UZEIT.

    MODIFY GT_DATA FROM GS_DATA.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_QUOT_DIALOG
*&---------------------------------------------------------------------*
FORM CALL_QUOT_DIALOG .

  CALL SCREEN 0140 STARTING AT 5 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0140
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0140 .

  " CUSTOM CONTAINER 객체 생성
  CREATE OBJECT GO_CUSTOM3
    EXPORTING
      CONTAINER_NAME              = 'CCON3'
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I070(ZCC_MSG) DISPLAY LIKE 'E'. " CNTL_ERROR
      WHEN 2.
        MESSAGE I071(ZCC_MSG) DISPLAY LIKE 'E'. " CNTL_SYSTEM_ERROR
      WHEN 3.
        MESSAGE I072(ZCC_MSG) DISPLAY LIKE 'E'. " CREATE_ERROR
      WHEN 4.
        MESSAGE I073(ZCC_MSG) DISPLAY LIKE 'E'. " LIFETIME_ERROR
      WHEN 5.
        MESSAGE I074(ZCC_MSG) DISPLAY LIKE 'E'. " LIFETIME_DYNPRO_DYNPRO_LINK
      WHEN 6.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

  CREATE OBJECT GO_ALV_GRID3
    EXPORTING
      I_PARENT          = GO_CUSTOM3    " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1                " Error when creating the control
      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
      ERROR_CNTL_LINK   = 3                " Error While Linking Control
      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I076(ZCC_MSG) DISPLAY LIKE 'E'. " Error when creating the control
      WHEN 2.
        MESSAGE I077(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Initializing Control
      WHEN 3.
        MESSAGE I078(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Linking Control
      WHEN 4.
        MESSAGE I079(ZCC_MSG) DISPLAY LIKE 'E'. " Error While Creating DataProvider Control
      WHEN 5.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_LAYOUT_0140
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0140 .

  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'A'.

  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-CWIDTH_OPT = 'A'.
  GS_LAYO-SEL_MODE = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_140
*&---------------------------------------------------------------------*
FORM SET_FCAT_140 .

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'QUOT_ID'.
  GS_FCAT3-COLTEXT = '견적서 ID'.
  GS_FCAT3-COL_POS = 10.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  GS_FCAT3-KEY = 'X'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'QNA_ID'.
  GS_FCAT3-COLTEXT = '고객문의 번호'.
  GS_FCAT3-COL_POS = 12.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'VKBUR'.
  GS_FCAT3-COLTEXT = '계약 영업장'.
  GS_FCAT3-COL_POS = 15.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  GS_FCAT3-OUTPUTLEN = 30.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'KUNNR'.
  GS_FCAT3-COLTEXT = '고객 ID'.
  GS_FCAT3-COL_POS = 20.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'NAME1'.
  GS_FCAT3-COLTEXT = '고객명'.
  GS_FCAT3-COL_POS = 30.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'VDATU'.
  GS_FCAT3-COLTEXT = '배송 요청일'.
  GS_FCAT3-COL_POS = 40.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT.
  GS_FCAT3-FIELDNAME = 'STRAS'.
  GS_FCAT3-COLTEXT = '배송지'.
  GS_FCAT3-COL_POS = 50.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'NAME2'.
  GS_FCAT3-COLTEXT = '담당자명'.
  GS_FCAT3-COL_POS = 60.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'EMAIL'.
  GS_FCAT3-COLTEXT = '담당자 이메일'.
  GS_FCAT3-COL_POS = 70.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'TELF'.
  GS_FCAT3-COLTEXT = '담당자 전화번호'.
  GS_FCAT3-COL_POS = 80.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'MATNR'.
  GS_FCAT3-COLTEXT = '계약 제품 ID'.
  GS_FCAT3-COL_POS = 100.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'KWMENG'.
  GS_FCAT3-COLTEXT = '계약 수량'.
  GS_FCAT3-COL_POS = 110.
  GS_FCAT3-QFIELDNAME = 'MEINS'.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

  CLEAR : GS_FCAT3.
  GS_FCAT3-FIELDNAME = 'MEINS'.
  GS_FCAT3-COLTEXT = '단위'.
  GS_FCAT3-COL_POS = 120.
  GS_FCAT3-REF_TABLE = 'ZCC_QUOT'.
  APPEND GS_FCAT3 TO GT_FCAT3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0140
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0140 .

  PERFORM SELECT_QUOT USING ZCC_QUOT-KUNNR ZCC_QUOT-NAME1
                      CHANGING GT_QUOT.

  CALL METHOD GO_ALV_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_STRUCTURE_NAME              = 'ZCC_VBAP'                 " Internal Output Table Structure Name
      IS_VARIANT                    = GS_VARIANT                 " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
      IS_LAYOUT                     = GS_LAYO                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_QUOT                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT3                  " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I080(ZCC_MSG) DISPLAY LIKE 'E'. " Wrong Parameter
      WHEN 2.
        MESSAGE I081(ZCC_MSG) DISPLAY LIKE 'E'. " Program Errors
      WHEN 3.
        MESSAGE I082(ZCC_MSG) DISPLAY LIKE 'E'. " Too many Rows in Ready for Input Grid
      WHEN 4.
        MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_QUOT
*&---------------------------------------------------------------------*
FORM SELECT_QUOT USING PV_KUNNR TYPE ZCC_QUOT-KUNNR
                       PV_NAME1 TYPE ZCC_QUOT-NAME1
              CHANGING PT_QUOT TYPE TY_QUOT.

  DATA : LR_KUNNR TYPE RANGE OF ZCC_QUOT-KUNNR,
         LS_KUNNR LIKE LINE OF LR_KUNNR,
         LR_NAME1 TYPE RANGE OF ZCC_QUOT-NAME1,
         LS_NAME1 LIKE LINE OF LR_NAME1.

  IF PV_KUNNR IS NOT INITIAL.
    LS_KUNNR-LOW = PV_KUNNR.
    LS_KUNNR-OPTION = 'EQ'.
    LS_KUNNR-SIGN = 'I'.

    APPEND LS_KUNNR TO LR_KUNNR.
  ENDIF.

  IF PV_NAME1 IS NOT INITIAL.
    LS_NAME1-LOW = PV_NAME1.
    LS_NAME1-OPTION = 'EQ'.
    LS_NAME1-SIGN = 'I'.

    APPEND LS_NAME1 TO LR_NAME1.
  ENDIF.

  SELECT QUOT_ID
         KUNNR
         NAME1
         VDATU
         QNA_ID
         STRAS
         NAME2
         EMAIL
         TELF
         VKBUR
         KWMENG
         MATNR
         MEINS
         QUOT_STAT
    FROM ZCC_QUOT
    INTO CORRESPONDING FIELDS OF TABLE GT_QUOT
    WHERE QUOT_STAT NE 'X'
      AND KUNNR IN LR_KUNNR
      AND NAME1 IN LR_NAME1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_QUOT
*&---------------------------------------------------------------------*
FORM UPDATE_QUOT  USING    PT_QUOT TYPE TS_QUOT
                  CHANGING PCC_QUOT TYPE ZCC_QUOT.

  MOVE-CORRESPONDING PT_QUOT TO PCC_QUOT.

  PCC_QUOT-AEDAT = SY-DATUM.
  PCC_QUOT-AENAM = SY-UNAME.
  PCC_QUOT-AEZET = SY-UZEIT.

  UPDATE ZCC_QUOT FROM PCC_QUOT.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
