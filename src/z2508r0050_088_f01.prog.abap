*&---------------------------------------------------------------------*
*& Include          Z2508R0040_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form EXCEL_DOWNLOAD
*&---------------------------------------------------------------------*
FORM EXCEL_DOWNLOAD .

  DATA : LV_RESULT,
         LV_TITLE TYPE STRING.

  LV_TITLE = |PO 템플릿 { SY-DATUM } { SY-UZEIT }|.

  CALL METHOD ZCL_UTIL=>SMW0_DOWNLOAD
    EXPORTING
      I_RELID  = 'MI'                        " Area in IMPORT/EXPORT record
      I_OBJID  = 'ZUPLOADTEMPLATE_CREATEPO'  " SAP WWW Gateway Object Name, 대소문자 주의!
      I_TITLE  = LV_TITLE                    " Filename
      I_EXCUTE = SPACE                       " Excute Flag
    RECEIVING
      R_RESULT = LV_RESULT.                  " S or E

  CASE LV_RESULT.
    WHEN 'S'.
      MESSAGE TEXT-S01 TYPE 'S'.  " SMW0를 통한 템플릿 다운로드에 성공했습니다.
    WHEN 'E'.
      MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'.  " SMW0를 통한 템플릿 다운로드에 실패했습니다.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PATH
*&---------------------------------------------------------------------*
FORM SET_PATH .

  DATA : LV_FILE_NAME TYPE STRING,
         LV_MSG       TYPE STRING.

  LV_FILE_NAME = |{ SY-REPID } { SY-DATUM } { SY-UZEIT }|.

  " 해당 프로그램에서 여러번 경로를 지정할 경우 사용자가 이전에 선택했던 경로를 출력함.
  CALL METHOD ZCL_UTIL=>FILE_OPEN_DIALOG
    EXPORTING
      I_TITLE       = '경로 선택'                          " 파일 선택 창의 제목
*     I_DEF_EXT     = " 기본 확장자
      I_DEF_NAME    = LV_FILE_NAME                         " 기본 파일명
      I_FILE_FILTER = 'Excel files (*.XLS;*.XLSX)|*.XLSX'  " 파일 필터
      I_DIRECTORY   = P_PATH                               " 대화상자가 처음 열릴 디렉토리 설정
    IMPORTING
      E_MSG         = LV_MSG                               " 오류 발생 시 텍스트가 저장되는 출력 파라미터
    RECEIVING
      R_FULLPATH    = P_PATH.                              " 사용자가 선택한 파일의 전체 경로

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_param
*&---------------------------------------------------------------------*
FORM CHECK_PARAM .

  IF P_PATH IS INITIAL.
    MESSAGE TEXT-E02 TYPE 'S' DISPLAY LIKE 'E'.  " 저장경로를 선택해주세요.
    STOP.
  ENDIF.

  " 회사코드 유효성 검사
  SELECT SINGLE BUKRS
    FROM T001
    INTO @DATA(LS_T001)
    WHERE BUKRS IN @S_BUKRS.

  IF SY-SUBRC NE 0.
    MESSAGE TEXT-E03 TYPE 'S' DISPLAY LIKE 'E'.  " 올바른 회사코드를 입력해주세요.
    STOP.
  ENDIF.

  " 구매조직 유효성 검사
  SELECT SINGLE EKORG
    FROM T024E
    INTO @DATA(LS_T024E)
    WHERE EKORG IN @S_EKORG.

  IF SY-SUBRC NE 0.
    MESSAGE TEXT-E04 TYPE 'S' DISPLAY LIKE 'E'.  " 올바른 구매조직을 입력해주세요.
    STOP.
  ENDIF.

  " 구매그룹 유효성 검사
  SELECT SINGLE EKGRP
    FROM T024
    INTO @DATA(LS_T024)
    WHERE EKGRP IN @S_EKGRP.

  IF SY-SUBRC NE 0.
    MESSAGE TEXT-E05 TYPE 'S' DISPLAY LIKE 'E'.  " 올바른 구매그룹을 입력해주세요.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_UPLOAD
*&---------------------------------------------------------------------*
FORM DATA_UPLOAD .

*&---------------------------------------------------------------------*
*& ALSM_EXCEL_TO_INTERNAL_TABLE 사용 방식
*&---------------------------------------------------------------------*
  PERFORM EXCEL_TO_INTERNAL_TABLE.
  PERFORM TYPE_CONVERSION.
  PERFORM SELECT_DATA.
  PERFORM CALL_SCREEN.

*&---------------------------------------------------------------------*
*& GUI_UPLOAD 사용 방식
*&---------------------------------------------------------------------*
*  DATA: LO_EXCEL     TYPE OLE2_OBJECT,
*        LO_WORKBOOKS TYPE OLE2_OBJECT,
*        LO_WORKBOOK  TYPE OLE2_OBJECT.
*  DATA: LV_CSV_FILE   TYPE STRING.
*
*  " 1) Excel.Application 생성
*  CREATE OBJECT LO_EXCEL 'Excel.Application'.
*
*  " 2) 보이지 않게 + 경고 끄기
*  SET PROPERTY OF LO_EXCEL 'Visible'       = 0.
*  SET PROPERTY OF LO_EXCEL 'DisplayAlerts' = 0.
*
*  " 3) Workbooks 핸들 얻고, Open의 반환으로 workbook 받기
*  CALL METHOD OF LO_EXCEL 'Workbooks' = LO_WORKBOOKS.
*  CALL METHOD OF LO_WORKBOOKS 'Open' = LO_WORKBOOK
*    EXPORTING
*      #1 = GV_FILE_PATH.   " 전체 경로
*
*  " 4) CSV 경로 만들기 (대소문자 무시)
*  LV_CSV_FILE = GV_FILE_PATH.
*  REPLACE '.XLSX' WITH '.CSV' INTO LV_CSV_FILE.
*
*  " 5) CSV 저장 (FileFormat = 6 = xlCSV)
*  CALL METHOD OF LO_WORKBOOK 'SaveAs'
*    EXPORTING
*      #1 = LV_CSV_FILE  " Filename
*      #2 = 6.           " FileFormat: xlCSV
*
*  " 6) 워크북 닫기 후 Excel 종료
*  CALL METHOD OF LO_WORKBOOK 'Close' EXPORTING #1 = 0.
*  CALL METHOD OF LO_EXCEL 'Quit'.
*
*  " 7) OLE 객체 해제
*  FREE OBJECT: LO_WORKBOOK, LO_WORKBOOKS, LO_EXCEL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_TO_INTERNAL_TABLE
*&---------------------------------------------------------------------*
FORM EXCEL_TO_INTERNAL_TABLE .

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_PATH        " 읽어올 Excel 파일의 전체 경로
      I_BEGIN_COL             = 1             " 시작 열
      I_BEGIN_ROW             = 2             " 시작 행
      I_END_COL               = 8             " 끝 열
      I_END_ROW               = 1000000       " 끝 행
    TABLES
      INTERN                  = GT_TABLINE    " 읽어온 Excel 데이터를 담는 구조( ALSMEX_TABLINE ), 한 셀 단위로 데이터가 저장됨.
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TYPE_CONVERSION
*&---------------------------------------------------------------------*
FORM TYPE_CONVERSION .

  DATA : LT_EKKO TYPE TABLE OF DFIES,
         LT_EKPO TYPE TABLE OF DFIES.

  " EKKO의 필드 정보 ITAB에 저장
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'EKKO'           " Name of the Table (of the Type) for which Information is Required
    TABLES
      DFIES_TAB      = LT_EKKO          " Field List if Necessary
    EXCEPTIONS
      NOT_FOUND      = 1                " Nothing found
      INTERNAL_ERROR = 2                " Internal error occurred
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  " EKPO의 필드 정보 ITAB에 저장
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'EKPO'                 " Name of the Table (of the Type) for which Information is Required
    TABLES
      DFIES_TAB      = LT_EKPO          " Field List if Necessary
    EXCEPTIONS
      NOT_FOUND      = 1                " Nothing found
      INTERNAL_ERROR = 2                " Internal error occurred
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SORT GT_TABLINE BY ROW COL. " 올바른 순서대로 GT_EXCEL에 삽입하기 위한 SORT

  " GS_EXCEL 구조체의 메타정보(타입 정보)를 런타임에서 가져오고, 그걸 구조체 기술 객체인 CL_ABAP_STRUCTDESCR로 캐스팅
  DATA(LO_DESCR) = CAST CL_ABAP_STRUCTDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GS_EXCEL ) ).

  LOOP AT GT_TABLINE INTO DATA(LS_ALSMEX).
    " 1. EXCEL에서 가져온 데이터를 넣어줄 필드를 ASSIGN
    ASSIGN COMPONENT LS_ALSMEX-COL OF STRUCTURE GS_EXCEL TO FIELD-SYMBOL(<FS_FIELD>).

    " 2. COL을 기준으로 GS_EXCEL의 필드 메타데이터 읽기
    READ TABLE LO_DESCR->COMPONENTS INTO DATA(LS_COMPONENT) INDEX LS_ALSMEX-COL.

    " 3. GS_EXCEL의 필드 메타데이터 중 필드명을 통해 EKKO 혹은 EKPO에서 데이터 읽어오기
    READ TABLE LT_EKKO INTO DATA(LS_DFIES) WITH KEY FIELDNAME = LS_COMPONENT-NAME.

    IF SY-SUBRC NE 0.
      " EKKO에 없는 필드인 경우 EKPO에서 필드 정보를 가져옴
      READ TABLE LT_EKPO INTO LS_DFIES WITH KEY FIELDNAME = LS_COMPONENT-NAME.
    ENDIF.

    " 4. 타입에 맞는 후처리 작업 진행 ( 엑셀 양식을 SAP 양식으로 변환, CONVEXIT 진행 등 )
    CASE LS_DFIES-INTTYPE.
      WHEN 'P' OR 'F' OR 'I'. " 숫자 타입 (Packed, Float, Integer)
        " 쉼표 제거, 소수점 허용
        DATA(LV_CLEANED) = LS_ALSMEX-VALUE.
        REPLACE ALL OCCURRENCES OF ',' IN LV_CLEANED WITH ''.
        CONDENSE LV_CLEANED NO-GAPS.
        " 숫자인지 검증: 0-9
        FIND REGEX '[0-9]+([.][0-9]+)?' IN LV_CLEANED.
        IF SY-SUBRC = 0.
          " 숫자 형식 맞음
          " 숫자 변환 후 유효성 검사
          DATA(LV_VALUE_NUM) = LV_CLEANED.

          IF LS_DFIES-FIELDNAME = 'MENGE' OR LS_DFIES-FIELDNAME = 'NETPR'.
            IF LV_VALUE_NUM <= 0.
              LS_ALSMEX-VALUE = 0.
              CONTINUE.
            ENDIF.
          ENDIF.
        ELSE.
          " 숫자 아님
          " 숫자가 아닌 경우
          LS_ALSMEX-VALUE = 0.
          CONTINUE.
        ENDIF.
      WHEN 'D'.  " Date Type
        REPLACE ALL OCCURRENCES OF '-' IN LS_ALSMEX-VALUE WITH SPACE.
        IF LS_ALSMEX-VALUE CP '########'. " YYYYMMDD 형태
          " pass
        ELSE.
          LS_ALSMEX-VALUE = '00000000'.
          CONTINUE.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    IF LS_DFIES-CONVEXIT IS NOT INITIAL.
      DATA(FUNCTION_NAME) = 'CONVERSION_EXIT_' && LS_DFIES-CONVEXIT && '_INPUT'.

      CALL FUNCTION FUNCTION_NAME
        EXPORTING
          INPUT  = LS_ALSMEX-VALUE
        IMPORTING
          OUTPUT = <FS_FIELD>.  " GS_EXCEL 의 필드의 타입에 맞게 CONVERSION 진행

    ELSE.
      " 열 별 FIELD SYMBOL ASSIGN이 성공된 경우 값을 GS_EXCEL에 지정
      <FS_FIELD> = LS_ALSMEX-VALUE.
    ENDIF.

    AT END OF ROW.
      APPEND GS_EXCEL TO GT_EXCEL.
      CLEAR : GS_EXCEL.
    ENDAT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DISPLAY_TABLE
*&---------------------------------------------------------------------*
FORM MODIFY_DISPLAY_TABLE USING PT_LFA1 TYPE TY_LFA1
                                PT_MAKT TYPE TY_MAKT
                       CHANGING GT_DISPLAY TYPE TY_DISPLAY.
  " 통화키 유효성 검사를 위한 Data Selection
  SELECT WAERS
    FROM TCURC
    INTO TABLE @DATA(LT_WAERS).

  " 단위 유효성 검사를 위한 Data Selection
  SELECT MSEHI
    FROM T006
    INTO TABLE @DATA(LT_UNIT).

  " BINARY SEARCH 를 위한 정렬
  SORT PT_LFA1 BY LIFNR.
  SORT PT_MAKT BY MATNR.
  SORT LT_WAERS BY WAERS.
  SORT LT_UNIT BY MSEHI.

  LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>).
    " Vendor 유효성 검사
    READ TABLE PT_LFA1 INTO DATA(LS_LFA1) WITH KEY LIFNR = <FS_DISPLAY>-LIFNR BINARY SEARCH.
    <FS_DISPLAY>-NAME1 = LS_LFA1-NAME1.

    IF SY-SUBRC NE 0.
      <FS_DISPLAY>-MSG = |[ { <FS_DISPLAY>-LIFNR } 없음 ]|.
    ENDIF.

    " Material No. 유효성 검사
    READ TABLE PT_MAKT INTO DATA(LS_MAKT) WITH KEY MATNR = <FS_DISPLAY>-MATNR BINARY SEARCH.
    <FS_DISPLAY>-MAKTX = LS_MAKT-MAKTX.

    IF SY-SUBRC NE 0.
      <FS_DISPLAY>-MSG = |{ <FS_DISPLAY>-MSG } [ { <FS_DISPLAY>-MATNR } 없음 ]|.
    ENDIF.

    " 통화키 검사
    READ TABLE LT_WAERS INTO DATA(LS_WAERS) WITH KEY WAERS = <FS_DISPLAY>-WAERS BINARY SEARCH.

    IF SY-SUBRC NE 0.
      <FS_DISPLAY>-MSG = |{ <FS_DISPLAY>-MSG } [ { <FS_DISPLAY>-WAERS } 없음 ]|.
    ENDIF.

    " 단위 검사
    READ TABLE LT_UNIT INTO DATA(LS_UNIT) WITH KEY MSEHI = <FS_DISPLAY>-MEINS BINARY SEARCH.

    IF SY-SUBRC NE 0.
      <FS_DISPLAY>-MSG = |{ <FS_DISPLAY>-MSG } [ { <FS_DISPLAY>-MEINS } 없음 ]|.
    ENDIF.

    " 단가 유효성 검사
    IF <FS_DISPLAY>-NETPR EQ 0.
      <FS_DISPLAY>-MSG = |{ <FS_DISPLAY>-MSG } [ 단가를 점검해주세요 ]|.
    ENDIF.

    " 수량 유효성 검사
    IF <FS_DISPLAY>-MENGE EQ 0.
      <FS_DISPLAY>-MSG = |{ <FS_DISPLAY>-MSG } [ 수량을 점검해주세요 ]|.
    ENDIF.

    " 신호등 넣기
    IF <FS_DISPLAY>-MSG IS NOT INITIAL.
      <FS_DISPLAY>-LIGHT = ICON_RED_LIGHT.
      GV_EXCLUDE = 'X'.
    ELSE.
      <FS_DISPLAY>-LIGHT = ICON_YELLOW_LIGHT.
      <FS_DISPLAY>-SUM = <FS_DISPLAY>-NETPR * <FS_DISPLAY>-MENGE.
    ENDIF.

    CLEAR : LS_LFA1, LS_MAKT, LS_WAERS, LS_UNIT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  IF GT_EXCEL IS NOT INITIAL.

    PERFORM MODIFY_EXCEL.  " SAP DB 형태로 DATA 가공

    MOVE-CORRESPONDING GT_EXCEL TO GT_DISPLAY.

    DATA : LT_LFA1 TYPE TY_LFA1.
    DATA : LT_MAKT TYPE TY_MAKT.

    " LIFNR 유효성 검사
    SELECT DISTINCT A~LIFNR,
                    A~NAME1
      FROM LFA1 AS A
      JOIN @GT_EXCEL AS T
        ON  A~LIFNR EQ T~LIFNR
      INTO CORRESPONDING FIELDS OF TABLE @LT_LFA1.

    IF SY-SUBRC NE 0.
      GV_EXCLUDE = 'X'.
    ENDIF.

    " MATNR 유효성 검사
    SELECT DISTINCT T~MATNR,
                    K~MAKTX
      FROM MARC AS C
      JOIN @GT_EXCEL AS T
        ON T~MATNR EQ C~MATNR
       AND T~WERKS EQ C~WERKS
      LEFT OUTER JOIN MAKT AS K
        ON K~MATNR EQ T~MATNR
       AND K~SPRAS EQ @SY-LANGU
      INTO CORRESPONDING FIELDS OF TABLE @LT_MAKT.

*    SELECT DISTINCT T~MATNR,
*                    K~MAKTX
*      FROM @GT_EXCEL AS T
*      LEFT OUTER JOIN MAKT AS K
*        ON K~MATNR EQ T~MATNR
*       AND K~SPRAS EQ @SY-LANGU
*      INTO CORRESPONDING FIELDS OF TABLE @LT_MAKT.

    IF SY-SUBRC NE 0.
      GV_EXCLUDE = 'X'.
    ENDIF.

  ENDIF.

  PERFORM MODIFY_DISPLAY_TABLE USING LT_LFA1 LT_MAKT
                            CHANGING GT_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
FORM CALL_SCREEN .

  CASE ABAP_ON.
    WHEN P_CREATE.
      IF GT_DISPLAY IS NOT INITIAL.
        CALL SCREEN 0100.
      ELSE.
        MESSAGE '출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    WHEN P_MODIF.
      IF GT_HEADER IS NOT INITIAL.
        CALL SCREEN 0200.
      ELSE.
        MESSAGE '출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  CREATE OBJECT GO_DOCKING
    EXPORTING
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

*  CREATE OBJECT GO_SPILTTER
*    EXPORTING
*      PARENT            = GO_DOCKING         " Parent Container
*      ROWS              = 2                  " Number of Rows to be displayed
*      COLUMNS           = 1                  " Number of Columns to be Displayed
*    EXCEPTIONS
*      CNTL_ERROR        = 1                  " See Superclass
*      CNTL_SYSTEM_ERROR = 2                  " See Superclass
*      OTHERS            = 3.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

*  CALL METHOD GO_SPILTTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 1                " Row
*      COLUMN    = 1                " Column
*    RECEIVING
*      CONTAINER = GO_CONTAINER1.    " Container

*  CALL METHOD GO_SPILTTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 2                " Row
*      COLUMN    = 1                " Column
*    RECEIVING
*      CONTAINER = GO_CONTAINER2.    " Container

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT          = GO_DOCKING       " Parent Container
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

*  CREATE OBJECT GO_ALV_GRID2
*    EXPORTING
*      I_PARENT          = GO_CONTAINER2    " Parent Container
*    EXCEPTIONS
*      ERROR_CNTL_CREATE = 1                " Error when creating the control
*      ERROR_CNTL_INIT   = 2                " Error While Initializing Control
*      ERROR_CNTL_LINK   = 3                " Error While Linking Control
*      ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
*      OTHERS            = 5.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO .

  GV_SAVE = 'A'.
  GS_VARIANT-REPORT = SY-CPROG.

  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-CWIDTH_OPT = 'A'.
  GS_LAYO-SEL_MODE = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT .

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS, GT_FCAT.
  LV_COL_POS = 10.

  PERFORM SET_FIELD_CATALOG USING : 'LIGHT' SPACE   'Light'            SPACE  SPACE   CHANGING LV_COL_POS GT_FCAT,
                                    'LIFNR' ABAP_ON 'Vendor'           'EKKO' 'LIFNR' CHANGING LV_COL_POS GT_FCAT,
                                    'NAME1' SPACE   'Name'             'LFA1' 'NAME1' CHANGING LV_COL_POS GT_FCAT,
                                    'MATNR' ABAP_ON 'Material Code'    'EKPO' 'MATNR' CHANGING LV_COL_POS GT_FCAT,
                                    'MAKTX' SPACE   'Name'             'MAKT' 'MAKTX' CHANGING LV_COL_POS GT_FCAT,
                                    'MENGE' SPACE   'Quantity'         'EKPO' 'MENGE' CHANGING LV_COL_POS GT_FCAT,
                                    'MEINS' SPACE   'Unit'             'EKPO' 'MEINS' CHANGING LV_COL_POS GT_FCAT,
                                    'NETPR' SPACE   'UnitPrice'        'EKPO' 'NETPR' CHANGING LV_COL_POS GT_FCAT,
                                    'SUM'   SPACE   'Sum'              SPACE  SPACE   CHANGING LV_COL_POS GT_FCAT,
                                    'WAERS' SPACE   'Currency'         'EKKO' 'WAERS' CHANGING LV_COL_POS GT_FCAT,
                                    'WERKS' SPACE   'Plant'            'EKPO' 'WERKS' CHANGING LV_COL_POS GT_FCAT,
                                    'LGORT' SPACE   'Storage Location' 'EKPO' 'LGORT' CHANGING LV_COL_POS GT_FCAT,
                                    'EBELN' SPACE   'Po'               'EKKO' 'EBELN' CHANGING LV_COL_POS GT_FCAT,
                                    'MSG'   SPACE   'Message'          SPACE  SPACE   CHANGING LV_COL_POS GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG  USING PV_FIELDNAME
                              PV_KEY
                              PV_COLTEXT
                              PV_REF_TABLE
                              PV_REF_FIELD
                     CHANGING PV_COL_POS
                              PT_FCAT TYPE LVC_T_FCAT.

  DATA(LS_FCAT) = VALUE LVC_S_FCAT( FIELDNAME = PV_FIELDNAME
                                    KEY = PV_KEY
                                    COL_POS = PV_COL_POS
                                    COLTEXT = PV_COLTEXT
                                    REF_TABLE = PV_REF_TABLE
                                    REF_FIELD = PV_REF_FIELD
                                   ).
  CASE PT_FCAT.
    WHEN GT_FCAT.
      CASE ABAP_ON.
        WHEN P_CREATE.
          CASE PV_FIELDNAME.
            WHEN 'LIGHT'.
              LS_FCAT-ICON = 'X'.
            WHEN 'MENGE'.
              LS_FCAT-QFIELDNAME = 'MEINS'.
            WHEN 'NETPR' OR 'SUM'.
              LS_FCAT-CFIELDNAME = 'WAERS'.
            WHEN 'EBELN'.
              LS_FCAT-HOTSPOT = 'X'.
          ENDCASE.
        WHEN P_MODIF.
          CASE PV_FIELDNAME.
            WHEN 'BTN'.
              LS_FCAT-JUST = 'C'.
              LS_FCAT-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
            WHEN 'MENGE'.
              LS_FCAT-QFIELDNAME = 'MEINS'.
            WHEN 'TOTAL_NETWR'.
              LS_FCAT-CFIELDNAME = 'WAERS'.
          ENDCASE.
      ENDCASE.

      APPEND LS_FCAT TO PT_FCAT.
    WHEN GT_FCAT2.
      CASE PV_FIELDNAME.
        WHEN 'EDIT'.
          LS_FCAT-CHECKBOX = ABAP_ON.
          LS_FCAT-EDIT = ABAP_ON.
        WHEN 'STATUS'.
          LS_FCAT-ICON = ABAP_ON.
        WHEN 'MENGE'.
          LS_FCAT-QFIELDNAME = 'MEINS'.
          LS_FCAT-EDIT = ABAP_ON.
        WHEN 'NETPR'.
          LS_FCAT-CFIELDNAME = 'WAERS'.
          LS_FCAT-EDIT = ABAP_ON.
        WHEN 'SUM'.
          LS_FCAT-CFIELDNAME = 'WAERS'.
        WHEN 'MSG' OR 'EBELN'.
          LS_FCAT-HOTSPOT = ABAP_ON.
        WHEN 'EINDT'.
          LS_FCAT-EDIT = ABAP_ON.
      ENDCASE.

      APPEND LS_FCAT TO PT_FCAT.
  ENDCASE.

  PV_COL_POS += 10.

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

*  CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
*    EXPORTING
*      IS_VARIANT                    = GS_VARIANT       " Layout
*      I_SAVE                        = GV_SAVE          " Save Layout
*      IS_LAYOUT                     = GS_LAYO          " Layout
*    CHANGING
*      IT_OUTTAB                     = GT_DISPLAY       " Output Table
*      IT_FIELDCATALOG               = GT_FCAT          " Field Catalog
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
*      PROGRAM_ERROR                 = 2                " Program Errors
*      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
*      OTHERS                        = 4.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO
*&---------------------------------------------------------------------*
FORM CREATE_PO .

  PERFORM SET_BDC_OPT.
  PERFORM USING_BDC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USING_BDC
*&---------------------------------------------------------------------*
FORM USING_BDC .

  DATA : LV_INDEX      TYPE NUMC2,
         LV_FIELD_NAME TYPE STRING,
         LV_START      TYPE NUMC4,
         LV_END        TYPE NUMC4,
         LV_MENGE      TYPE C LENGTH 30,
         LV_NETPR      TYPE C LENGTH 30.

  SORT GT_EXCEL BY LIFNR.

  LOOP AT GT_EXCEL ASSIGNING FIELD-SYMBOL(<FS_EXCEL>).
* 레코딩은 아래와 같이 BDCDATA를 세팅하기 위한 참고자료일 뿐
* Header : LIFNR을 기준으로 최초 1번만 실행되면 되기 때문에 AT NEW 구문을 통해 진행.
    AT NEW LIFNR.
      " Vendor Code
      LV_INDEX = 01.  " LIFNR이 바뀔 경우 다시 01부터 시작하여 데이터가 할당되어야하기 때문에 헤더 생성 시 다시 초기화.
      LV_START = SY-TABIX.
      PERFORM BDC_DATA_SET USING : ABAP_ON 'SAPLMEGUI'  '0014',
                                   SPACE   'BDC_OKCODE' '=MEV4000BUTTON',
                                   ABAP_ON 'SAPLMEGUI'  '0014',
                                   SPACE   'BDC_OKCODE' '=MEV4001BUTTON'.

      PERFORM BDC_DATA_SET USING : ABAP_ON 'SAPLMEGUI'  '0014',
                                   SPACE   'BDC_OKCODE' '=TABHDT8',
                                   SPACE   'MEPO_TOPLINE-SUPERFIELD' <FS_EXCEL>-LIFNR,

                                   " Org. Data
                                   ABAP_ON 'SAPLMEGUI'  '0014',
                                   SPACE   'BDC_OKCODE' '=TABHDT1',
                                   SPACE   'MEPO1222-EKORG' S_EKORG-LOW,
                                   SPACE   'MEPO1222-EKGRP' S_EKGRP-LOW,
                                   SPACE   'MEPO1222-BUKRS' S_BUKRS-LOW,

                                   " Delivery/Invoice
                                   ABAP_ON 'SAPLMEGUI'  '0014',
                                   SPACE   'MEPO1226-ZTERM' 'CV01'.
    ENDAT.

* Item : 아이템은 기본적으로 반복 생성
    LV_FIELD_NAME = |MEPO1211-EMATN({ LV_INDEX })|.
    PERFORM BDC_DATA_SET USING SPACE LV_FIELD_NAME <FS_EXCEL>-MATNR.

    WRITE <FS_EXCEL>-MENGE UNIT <FS_EXCEL>-MEINS TO LV_MENGE.  " 단위 적용
    CONDENSE LV_MENGE NO-GAPS.  " 자리수에 맞춰 공백이 생기고 이로인해 ME21N DYNPRO 길이보다 길어지기 때문에 CONDENSE 진행
    LV_FIELD_NAME = |MEPO1211-MENGE({ LV_INDEX })|.
    PERFORM BDC_DATA_SET USING SPACE LV_FIELD_NAME LV_MENGE.

    WRITE <FS_EXCEL>-NETPR CURRENCY <FS_EXCEL>-WAERS TO LV_NETPR.
    CONDENSE LV_NETPR NO-GAPS.
    LV_FIELD_NAME = |MEPO1211-NETPR({ LV_INDEX })|.
    PERFORM BDC_DATA_SET USING SPACE LV_FIELD_NAME LV_NETPR.

    LV_FIELD_NAME = |MEPO1211-NAME1({ LV_INDEX })|.
    PERFORM BDC_DATA_SET USING SPACE LV_FIELD_NAME <FS_EXCEL>-WERKS.

    LV_FIELD_NAME = |MEPO1211-LGOBE({ LV_INDEX })|.
    PERFORM BDC_DATA_SET USING SPACE LV_FIELD_NAME <FS_EXCEL>-LGORT.

    LV_INDEX += 1.

    AT END OF LIFNR.
      LV_END = SY-TABIX.
      " Excel 문서 내 Vendor No. 이 여러 개라면 ME21N을 Vendor No. 마다 호출 및 저장해줘야함.
      PERFORM BDC_DATA_SET USING SPACE 'BDC_OKCODE' '=MESAVE'.

      CALL TRANSACTION 'ME21N'
                 USING GT_BDCDATA
          OPTIONS FROM GS_OPT
         MESSAGES INTO GT_BDCMSG.

      IF SY-SUBRC EQ 0.
        PERFORM GET_MESSAGE USING LV_START LV_END.
      ENDIF.

      CLEAR : GT_BDCDATA,  " LIFNR을 기준으로 저장까지 완료했다면 해당 BDC 데이터를 CLEAR 해서 새로운 정보를 저장할 수 있도록 함.
              GT_BDCMSG.
    ENDAT.

  ENDLOOP.

  GV_EXCLUDE = ABAP_ON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_DATA_SET
*&---------------------------------------------------------------------*
FORM BDC_DATA_SET  USING PV_SCREEN
                         PV_NAME
                         PV_VALUE.

  DATA : LS_BDCDATA TYPE BDCDATA.

  IF PV_SCREEN EQ ABAP_ON.

    LS_BDCDATA-DYNBEGIN = PV_SCREEN.
    LS_BDCDATA-PROGRAM = PV_NAME.
    LS_BDCDATA-DYNPRO = PV_VALUE.

  ELSE.

    LS_BDCDATA-FNAM = PV_NAME.
    LS_BDCDATA-FVAL = PV_VALUE.

  ENDIF.

  APPEND LS_BDCDATA TO GT_BDCDATA.
  CLEAR : LS_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BDC_OPT
*&---------------------------------------------------------------------*
FORM SET_BDC_OPT .

  GS_OPT-DISMODE = 'E'.
  GS_OPT-CATTMODE = 'A'.
  GS_OPT-UPDMODE = 'A'.
  GS_OPT-DEFSIZE = 'X'.
  GS_OPT-NOBINPT = ' '.
  GS_OPT-NOBIEND = ' '.
  GS_OPT-RACOMMIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MESSAGE
*&---------------------------------------------------------------------*
FORM GET_MESSAGE USING PV_START PV_END.

  DATA : LV_MESSAGE TYPE STRING.

* 성공 메시지 추출
  READ TABLE GT_BDCMSG INTO DATA(LS_BDCMSG) WITH KEY MSGID = '06' MSGNR = '017'.  " MSGID는 MESSAGE CLASS ID, MSGNR은 MESSAGE CLASS 내부의 번호
* 성공 메시지 없으면 실패 메시지 추출
  IF SY-SUBRC <> 0.
    READ TABLE GT_BDCMSG INTO LS_BDCMSG WITH KEY MSGTYP = 'E'.
  ENDIF.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = LS_BDCMSG-MSGID            " Message ID
      MSGNR               = LS_BDCMSG-MSGNR            " Number of message
      MSGV1               = LS_BDCMSG-MSGV1            " Parameter 1, &1에 들어갈 값
      MSGV2               = LS_BDCMSG-MSGV2            " Parameter 2, &2에 들어갈 값
      MSGV3               = LS_BDCMSG-MSGV3            " Parameter 3, &3에 들어갈 값
      MSGV4               = LS_BDCMSG-MSGV4            " Parameter 4, &4에 들어갈 값
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_MESSAGE.                " Output message text

  LOOP AT GT_DISPLAY FROM PV_START TO PV_END ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>).

    IF LS_BDCMSG-MSGTYP EQ 'S'.      " 성공 메시지인 경우
      <FS_DISPLAY>-LIGHT = ICON_GREEN_LIGHT.
      <FS_DISPLAY>-MSG   = LV_MESSAGE.
      <FS_DISPLAY>-EBELN = LS_BDCMSG-MSGV2.

    ELSEIF LS_BDCMSG-MSGTYP EQ 'E'.  " 에러 메시지인 경우
      <FS_DISPLAY>-LIGHT = ICON_RED_LIGHT.
      <FS_DISPLAY>-MSG   = LV_MESSAGE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
FORM SET_EVENT .

  SET HANDLER LCL_EVENT_HANDLER=>HOTSPOT_CLICK FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_EXCEL
*&---------------------------------------------------------------------*
FORM MODIFY_EXCEL .

  DATA : LV_NETPR TYPE BAPICURR-BAPICURR,
         LV_WAERS TYPE TCURC-WAERS.

  LOOP AT GT_EXCEL ASSIGNING FIELD-SYMBOL(<FS_EXCEL>).

    LV_NETPR = <FS_EXCEL>-NETPR.
    LV_WAERS = <FS_EXCEL>-WAERS.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        AMOUNT_EXTERNAL      = LV_NETPR
        CURRENCY             = LV_WAERS
        MAX_NUMBER_OF_DIGITS = 14
      IMPORTING
        AMOUNT_INTERNAL      = <FS_EXCEL>-NETPR.

    TRANSLATE <FS_EXCEL>-MATNR TO UPPER CASE.
    TRANSLATE <FS_EXCEL>-WAERS TO UPPER CASE.
    TRANSLATE <FS_EXCEL>-MEINS TO UPPER CASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM MODIFY_SELECTION_SCREEN .

  CASE ABAP_ON.
    WHEN P_MODIF.

      DATA : LT_EXCLUDE TYPE TABLE OF RSEXFCODE,
             LS_EXCLUDE LIKE LINE OF LT_EXCLUDE.

      " 제외할 버튼은 Function Code를 APPEND
      LS_EXCLUDE-FCODE = 'FC01'.
      APPEND LS_EXCLUDE TO LT_EXCLUDE.

      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'M1'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN P_CREATE.
      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'M2'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

  ENDCASE.

  " Radio Button 에 따른 동적제어를 위해서 AT SELECTION-SCREEN OUTPUT 실행될 때마다 호출해야함.
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      P_STATUS  = SY-PFKEY         " Status To Be Set
    TABLES
      P_EXCLUDE = LT_EXCLUDE.      " Table of OK codes to be excluded

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_selection_screen
*&---------------------------------------------------------------------*
FORM SET_SELECTION_SCREEN .

  SSCRFIELDS-FUNCTXT_01 = ICON_XLS && ' Download Template'.

  S_EKORG-LOW = '2000'.
  APPEND S_EKORG.

  S_EKGRP-LOW = '120'.
  APPEND S_EKGRP.

  S_BUKRS-LOW = '2000'.
  APPEND S_BUKRS.

  S_WERKS-LOW = '2100'.
  APPEND S_WERKS.

  DATA(LV_MONTH) = SY-DATUM+4(2).
  LV_MONTH -= 1.

  DATA(LV_LAST_MONTH) = |{ SY-DATUM+0(4) }{ LV_MONTH }01|.

  S_BEDAT-LOW = LV_LAST_MONTH.
  S_BEDAT-HIGH = SY-DATUM.
  APPEND S_BEDAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_MODIF_DATA
*&---------------------------------------------------------------------*
FORM SELECT_MODIF_DATA .
  DATA : LR_LOEKZ TYPE RANGE OF C,
         LS_LOEKZ LIKE LINE OF LR_LOEKZ.

  IF P_LOEKZ NE ABAP_ON.
    " 삭제 아이템을 포함하지 않은 경우 LOEKZ가 공백일 경우만 포함.
    SELECT DISTINCT
           P~WERKS,                                     " WERKS          TYPE EKPO-WERKS,
           K~LIFNR,                                     " LIFNR          TYPE EKKO-LIFNR,
           A~NAME1,                                     " NAME1          TYPE LFA1-NAME1,
           COUNT( P~EBELN ) AS PO_COUNT,                " PO_COUNT       TYPE I,
           SUM( P~MENGE ) AS PO_TOTAL_COUNT,            " PO_TOTAL_COUNT TYPE I,
           P~MEINS,                                     " MEINS          TYPE EKPO-MEINS,
           SUM( P~MENGE * P~NETPR ) AS TOTAL_NETWR,     " TOTAL_NETWR    TYPE EKPO-NETWR,
           K~WAERS                                      " WAERS          TYPE EKKO-WAERS,
      FROM EKPO AS P
      JOIN EKKO AS K
        ON P~EBELN EQ K~EBELN
      JOIN LFA1 AS A
        ON K~LIFNR EQ A~LIFNR
      JOIN EKET AS E
        ON E~EBELN EQ K~EBELN
       AND E~EBELP EQ P~EBELP
     WHERE K~EBELN IN @S_EBELN
       AND P~EBELP IN @S_EBELP
       AND K~BEDAT IN @S_BEDAT
       AND E~ELDAT IN @S_DELDT
       AND P~WERKS IN @S_WERKS
       AND P~LOEKZ = @SPACE
     GROUP BY P~WERKS, K~LIFNR, A~NAME1, P~MEINS, K~WAERS
     ORDER BY K~LIFNR
     INTO CORRESPONDING FIELDS OF TABLE @GT_HEADER.

  ELSE.

    SELECT DISTINCT
         P~WERKS,                                     " WERKS          TYPE EKPO-WERKS,
         K~LIFNR,                                     " LIFNR          TYPE EKKO-LIFNR,
         A~NAME1,                                     " NAME1          TYPE LFA1-NAME1,
         COUNT( P~EBELN ) AS PO_COUNT,                " PO_COUNT       TYPE I,
         SUM( P~MENGE ) AS PO_TOTAL_COUNT,            " PO_TOTAL_COUNT TYPE I,
         P~MEINS,                                     " MEINS          TYPE EKPO-MEINS,
         SUM( P~MENGE * P~NETPR ) AS TOTAL_NETWR,     " TOTAL_NETWR    TYPE EKPO-NETWR,
         K~WAERS                                      " WAERS          TYPE EKKO-WAERS,
    FROM EKPO AS P
    JOIN EKKO AS K
      ON P~EBELN EQ K~EBELN
    JOIN LFA1 AS A
      ON K~LIFNR EQ A~LIFNR
    JOIN EKET AS E
      ON E~EBELN EQ K~EBELN
     AND E~EBELP EQ P~EBELP
    WHERE K~EBELN IN @S_EBELN
     AND P~EBELP IN @S_EBELP
     AND K~BEDAT IN @S_BEDAT
     AND E~ELDAT IN @S_DELDT
     AND P~WERKS IN @S_WERKS
    GROUP BY P~WERKS, K~LIFNR, A~NAME1, P~MEINS, K~WAERS
    ORDER BY K~LIFNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_HEADER.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_HEADER
*&---------------------------------------------------------------------*
FORM MODIFY_HEADER .

  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<FS_HEADER>).
    <FS_HEADER>-BTN = ICON_ENTER_MORE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module INIT_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0200 OUTPUT.

  IF GO_SPLITTER IS INITIAL.
    PERFORM CREATE_OBJECT_0200.
    PERFORM SET_EVENT_HANDELR_0200.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT_0200.
    PERFORM DISPLAY_ALV_0200.
  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0200
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0200 .

  IF GO_DOCKING IS INITIAL.
    CREATE OBJECT GO_DOCKING
      EXPORTING
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
  ENDIF.

  CREATE OBJECT GO_SPLITTER
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

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1                " Row
      COLUMN    = 1                " Column
    RECEIVING
      CONTAINER = GO_CONTAINER1.    " Container

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_0200
*&---------------------------------------------------------------------*
FORM SET_FCAT_0200 .

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS, GT_FCAT, GT_FCAT2.
  LV_COL_POS = 10.

  PERFORM SET_FIELD_CATALOG USING : 'BTN'            SPACE '상세정보'     SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT,
                                    'WERKS'          SPACE '플렌트'       'EKPO'  'WERKS' CHANGING LV_COL_POS GT_FCAT,
                                    'LIFNR'          SPACE '공급업체'     'EKKO'  'LIFNR' CHANGING LV_COL_POS GT_FCAT,
                                    'NAME1'          SPACE '공급업체이름' 'LFA1'  'NAME1' CHANGING LV_COL_POS GT_FCAT,
                                    'PO_COUNT'       SPACE 'PO 건수'      SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT,
                                    'PO_TOTAL_COUNT' SPACE '총 수량'      SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT,
                                    'MEINS'          SPACE '단위'         'EKPO'  'MEINS' CHANGING LV_COL_POS GT_FCAT,
                                    'TOTAL_NETWR'    SPACE '총 금액'      'EKPO'  'NETWR' CHANGING LV_COL_POS GT_FCAT,
                                    'WAERS'          SPACE '통화'         'EKKO'  'WAERS' CHANGING LV_COL_POS GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0200
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0200 .

  CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE          " Save Layout
      IS_LAYOUT                     = GS_LAYO          " Layout
    CHANGING
      IT_OUTTAB                     = GT_HEADER        " Output Table
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
*& Form ALV_CL_BUTTON_CLICK
*&---------------------------------------------------------------------*
FORM ALV_CL_BUTTON_CLICK  USING PS_COL_ID
                                PS_ROW_NO TYPE LVC_S_ROID.

  CASE PS_COL_ID.
    WHEN 'BTN'.
      DATA : LV_INDEX TYPE I.
      LV_INDEX = PS_ROW_NO-ROW_ID.

      PERFORM CHANGE_ICON USING LV_INDEX.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ICON
*&---------------------------------------------------------------------*
FORM CHANGE_ICON  USING PV_INDEX.

  IF GV_OFF EQ SPACE.
    " 클릭된 상세보기가 없을 경우 : 클릭된 행에 대한 작업만 처리하면 됨.
    READ TABLE GT_HEADER INTO GS_HEADER INDEX PV_INDEX.  " 클릭한 행의 정보를 READ TABLE
    GS_HEADER-BTN = ICON_DISPLAY_MORE.
    MODIFY GT_HEADER FROM GS_HEADER INDEX PV_INDEX.

    GV_OFF = ABAP_ON.

    PERFORM SELECT_ITEM USING PV_INDEX.  " ITEM SELECTION
    PERFORM MODIFY_ITEM.
    PERFORM LOCK_DELETED_ROWS.
    PERFORM SET_ITEM_ALV.

  ELSE.
    " 클릭된 상세보기가 있는 경우 : 한 행만 상세보기 아이콘 활성화되어야 하기 때문에 전체 ITAB에 대한 작업을 진행
    READ TABLE GT_HEADER INTO GS_HEADER INDEX PV_INDEX.  " 클릭한 행의 정보를 READ TABLE
    IF GS_HEADER-BTN EQ ICON_DISPLAY_MORE.
      " 클릭된 행의 상세보기 아이콘이 활성화 된 경우 = 상세보기 아이콘을 원상복구
      GS_HEADER-BTN = ICON_ENTER_MORE.
      GV_OFF = SPACE.  " 전체 ITAB에 상세보기된 행이 없다는 것을 의미함.
      MODIFY GT_HEADER FROM GS_HEADER INDEX PV_INDEX.  " 변경사항 반영

      " ITEM ALV를 비우고 REFRESH : 하단 ALV에 출력되는 데이터가 없도록 함.
      CLEAR : GT_ITEM.
      CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY.

    ELSE.
      " 현재 상세조회 하고 있지 않은 다른 행을 클릭하고 있는 경우 : 현재 상세조회하고 있는 행의 아이콘을 초기화 시켜야함.
      LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<FS_HEADER>).
        IF SY-TABIX EQ PV_INDEX.
          <FS_HEADER>-BTN = ICON_DISPLAY_MORE.
          PERFORM SELECT_ITEM USING PV_INDEX.  " ITEM SELECTION
          PERFORM MODIFY_ITEM.
          PERFORM SET_ITEM_ALV.
        ELSE.
          <FS_HEADER>-BTN = ICON_ENTER_MORE.  " 아이콘 원상복구
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDIF.
  " 헤더 테이블 REFRESH
  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ITEM
*&---------------------------------------------------------------------*
FORM SELECT_ITEM  USING PV_INDEX.

  CLEAR : GT_ITEM, GT_ITEM_BACKUP.

  IF P_LOEKZ EQ ABAP_ON.

    SELECT DISTINCT                                   " STATUS   TYPE ICON-STATUS,
         P~EBELN,                                     " EBELN    TYPE EKPO-EBELN,
         P~EBELP,                                     " EBELP    TYPE EKPO-EBELP,
         P~MATNR,                                     " MATNR    TYPE EKPO-MATNR,
         T~MAKTX,                                     " MAKTX    TYPE MAKT-MAKTX,
         P~AEDAT,                                     " LADAT    TYPE SY-DATUM,
         P~MENGE,                                     " MENGE    TYPE EKPO-MENGE,
         P~MEINS,                                     " MEINS    TYPE EKPO-MEINS,
         P~NETPR,                                     " NETPR    TYPE EKPO-NETPR,
         K~WAERS,                                     " WAERS    TYPE EKKO-WAERS,
         P~MENGE * P~NETPR AS SUM,                    " SUM      TYPE EKPO-NETPR,
         E~EINDT,                                     " EINDT    TYPE EKET-EINDT,
         K~BEDAT,                                      " BEDAT    TYPE EKKO-BEDAT,
         P~LOEKZ
    FROM EKKO AS K
    JOIN EKPO AS P
      ON K~EBELN EQ P~EBELN
     AND K~LIFNR EQ @GS_HEADER-LIFNR
     AND P~WERKS EQ @GS_HEADER-WERKS
     AND K~WAERS EQ @GS_HEADER-WAERS
    JOIN EKET AS E
      ON E~EBELN EQ P~EBELN
     AND E~EBELP EQ P~EBELP
    LEFT OUTER JOIN MAKT AS T
      ON T~MATNR EQ P~MATNR
     AND T~SPRAS EQ @SY-LANGU
   WHERE K~EBELN IN @S_EBELN
     AND P~EBELP IN @S_EBELP
     AND K~BEDAT IN @S_BEDAT
     AND E~ELDAT IN @S_DELDT
     AND P~WERKS IN @S_WERKS
    ORDER BY P~EBELN, P~EBELP
   INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

  ELSE.

    SELECT DISTINCT                                   " STATUS   TYPE ICON-STATUS,
         P~EBELN,                                     " EBELN    TYPE EKPO-EBELN,
         P~EBELP,                                     " EBELP    TYPE EKPO-EBELP,
         P~MATNR,                                     " MATNR    TYPE EKPO-MATNR,
         T~MAKTX,                                     " MAKTX    TYPE MAKT-MAKTX,
         P~AEDAT,                                     " LADAT    TYPE SY-DATUM,
         P~MENGE,                                     " MENGE    TYPE EKPO-MENGE,
         P~MEINS,                                     " MEINS    TYPE EKPO-MEINS,
         P~NETPR,                                     " NETPR    TYPE EKPO-NETPR,
         K~WAERS,                                     " WAERS    TYPE EKKO-WAERS,
         P~MENGE * P~NETPR AS SUM,                    " SUM      TYPE EKPO-NETPR,
         E~EINDT,                                     " EINDT    TYPE EKET-EINDT,
         K~BEDAT                                      " BEDAT    TYPE EKKO-BEDAT,
    FROM EKKO AS K
    JOIN EKPO AS P
      ON K~EBELN EQ P~EBELN
     AND K~LIFNR EQ @GS_HEADER-LIFNR
     AND P~WERKS EQ @GS_HEADER-WERKS
     AND K~WAERS EQ @GS_HEADER-WAERS
    JOIN EKET AS E
      ON E~EBELN EQ P~EBELN
     AND E~EBELP EQ P~EBELP
    LEFT OUTER JOIN MAKT AS T
      ON T~MATNR EQ P~MATNR
     AND T~SPRAS EQ @SY-LANGU
   WHERE K~EBELN IN @S_EBELN
     AND P~EBELP IN @S_EBELP
     AND K~BEDAT IN @S_BEDAT
     AND E~ELDAT IN @S_DELDT
     AND P~WERKS IN @S_WERKS
     AND P~LOEKZ = @SPACE
    ORDER BY P~EBELN, P~EBELP
   INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDELR_0200
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDELR_0200 .

  SET HANDLER LCL_MODIFICATION_EVENT_HANDLER=>HANDLE_BUTTON_CLICK FOR GO_ALV_GRID.
  SET HANDLER LCL_MODIFICATION_EVENT_HANDLER=>ON_TOOLBAR FOR GO_ALV_GRID.
  SET HANDLER LCL_MODIFICATION_EVENT_HANDLER=>ON_USER_COMMAND FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_ALV
*&---------------------------------------------------------------------*
FORM SET_ITEM_ALV .

  IF GO_ALV_GRID2 IS INITIAL.

    PERFORM CREATE_ITEM_OBJECT.
    PERFORM SET_LAYO_ITEM.
    PERFORM CREATE_FCAT_ITEM.
    PERFORM SET_HANDLER_ITEM.
    PERFORM DISPLAY_ITEM_ALV.

  ELSE.
    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ITEM_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_ITEM_OBJECT .

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2                " Row
      COLUMN    = 1                " Column
    RECEIVING
      CONTAINER = GO_CONTAINER2.    " Container

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
*& Form CREATE_FCAT_ITEM
*&---------------------------------------------------------------------*
FORM CREATE_FCAT_ITEM .

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS, GT_FCAT2.
  LV_COL_POS = 10.

  PERFORM SET_FIELD_CATALOG USING : 'EDIT'   SPACE   '체크박스'     SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT2,
                                    'STATUS' SPACE   '상태'         SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT2,
                                    'EBELN'  ABAP_ON '구매오더번호' 'EKPO'  'EBELN' CHANGING LV_COL_POS GT_FCAT2,
                                    'EBELP'  ABAP_ON '구매오더품목' 'EKPO'  'EBELP' CHANGING LV_COL_POS GT_FCAT2,
                                    'MATNR'  ABAP_ON '자재'         'EKPO'  'MATNR' CHANGING LV_COL_POS GT_FCAT2,
                                    'MAKTX'  SPACE   '자재내역'     'MAKT'  'MAKTX' CHANGING LV_COL_POS GT_FCAT2,
                                    'MENGE'  SPACE   '수량'         'EKPO'  'MENGE' CHANGING LV_COL_POS GT_FCAT2,
                                    'MEINS'  SPACE   '단위'         'EKPO'  'MEINS' CHANGING LV_COL_POS GT_FCAT2,
                                    'NETPR'  SPACE   '금액'         'EKPO'  'NETPR' CHANGING LV_COL_POS GT_FCAT2,
                                    'WAERS'  SPACE   '통화'         'EKKO'  'WAERS' CHANGING LV_COL_POS GT_FCAT2,
                                    'SUM'    SPACE   '총액'         SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT2,
                                    'EINDT'  SPACE   '납품일'       'EKET'  'EINDT' CHANGING LV_COL_POS GT_FCAT2,
                                    'BEDAT'  SPACE   '증빙일'       'EKKO'  'BEDAT' CHANGING LV_COL_POS GT_FCAT2,
                                    'MSG'    SPACE   '메시지'       SPACE   SPACE   CHANGING LV_COL_POS GT_FCAT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO_ITEM
*&---------------------------------------------------------------------*
FORM SET_LAYO_ITEM .

  GS_LAYO2-ZEBRA = ABAP_ON.
  GS_LAYO2-CWIDTH_OPT = 'A'.
  GS_LAYO2-SEL_MODE = 'D'.
  GS_LAYO2-STYLEFNAME = 'CELLSTYL'.
  GS_LAYO2-INFO_FNAME = 'COLOR'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ITEM_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ITEM_ALV .

  CALL METHOD GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE          " Save Layout
      IS_LAYOUT                     = GS_LAYO2         " Layout
    CHANGING
      IT_OUTTAB                     = GT_ITEM          " Output Table
      IT_FIELDCATALOG               = GT_FCAT2         " Field Catalog
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
*& Form MODIFY_ITEM
*&---------------------------------------------------------------------*
FORM MODIFY_ITEM .

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
    <FS_ITEM>-STATUS = ICON_LIGHT_OUT.

    IF <FS_ITEM>-LOEKZ IS NOT INITIAL.
      <FS_ITEM>-COLOR = 'C' && COL_NEGATIVE && '01'.
    ENDIF.

  ENDLOOP.

  MOVE-CORRESPONDING GT_ITEM TO GT_ITEM_BACKUP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR CHANGING P_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA LS_BUTTON LIKE LINE OF P_OBJECT->MT_TOOLBAR.

  CLEAR : LS_BUTTON.
  LS_BUTTON-BUTN_TYPE = 3.
  APPEND LS_BUTTON TO P_OBJECT->MT_TOOLBAR.

  CLEAR : LS_BUTTON.
  LS_BUTTON-FUNCTION = 'REFRESH'.
  LS_BUTTON-ICON = ICON_REFRESH.
  LS_BUTTON-TEXT = ' 새로고침'.
  APPEND LS_BUTTON TO P_OBJECT->MT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING P_UCOMM TYPE SY-UCOMM.

  CASE P_UCOMM.
    WHEN 'REFRESH'.
      PERFORM REFRESH_PO.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PO
*&---------------------------------------------------------------------*
FORM CHANGE_PO .

  IF GT_ITEM IS INITIAL.
    MESSAGE '변경할 구매오더가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*&---------------------------------------------------------------------*
*& DATA DECLATION
*&---------------------------------------------------------------------*
  DATA : LS_EKKO  TYPE TS_EKKO,
         LS_EKKOX TYPE TS_EKKOX.

  DATA : LT_RETURN TYPE TY_RETURN,
         LT_EKPO   TYPE TY_EKPO,
         LT_EKPOX  TYPE TY_EKPOX,
         LT_EKET   TYPE TY_EKET,
         LS_EKET   TYPE TS_EKET,
         LT_EKETX  TYPE TY_EKETX,
         LS_EKETX  TYPE TS_EKETX.

  DATA : LV_DUMMY     TYPE IHREZ,
         LV_NETPR(15) TYPE C,
         LV_FLAG_X    TYPE C,
         LV_BDMNG     TYPE P DECIMALS 2.

  DATA : LV_START TYPE I,
         LV_END   TYPE I.

  FIELD-SYMBOLS : <FS_EKET>  TYPE BAPIMEPOSCHEDULE,
                  <FS_EKETX> TYPE BAPIMEPOSCHEDULX.
*&---------------------------------------------------------------------*

  SORT GT_ITEM BY EBELN.

  LOOP AT GT_ITEM INTO DATA(LS_ITEM)
    WHERE EDIT = 'X' AND CHANGED = 'X' AND STATUS NE ICON_GREEN_LIGHT
    GROUP BY ( EBELN = LS_ITEM-EBELN ) ASSIGNING FIELD-SYMBOL(<FS_GROUP>) .
*--------------------------------------------------------------------*
* EKKO
*--------------------------------------------------------------------*
    LS_EKKO-PO_NUMBER = <FS_GROUP>-EBELN.  " KEY 필드는 필드에 데이터를 넣어줘야함..
    LS_EKKOX-PO_NUMBER = ABAP_ON.

    LOOP AT GROUP <FS_GROUP> ASSIGNING FIELD-SYMBOL(<FS_ITEM>).  " Item Line : Group 별 작업 진행
      DATA(LV_INDEX) = SY-TABIX.
*--------------------------------------------------------------------*
* EKPO
*--------------------------------------------------------------------*
      APPEND INITIAL LINE TO LT_EKPO ASSIGNING FIELD-SYMBOL(<FS_EKPO>).
      " APPEND INITIAL LINE : LT_EKPO에 INITIAL 상태의 빈 행 하나 추가
      " ASSIGNING FIELD-SYMBOL <FS_EKPO> : 방금 추가된 빈 행을 <FS_EKPO>에 연결 > 이후 FS를 통해 직접 값을 입력
      APPEND INITIAL LINE TO LT_EKPOX ASSIGNING FIELD-SYMBOL(<FS_EKPOX>).
*--------------------------------------------------------------------*
      " 변경하고 싶은 필드들을 표시( 품목번호는 키필드 + 수량, 금액 )
      <FS_EKPOX>-PO_ITEM = <FS_ITEM>-EBELP.   " 품목번호 : KEY 필드는 필드에 데이터를 넣어줘야함..
      <FS_EKPOX>-NET_PRICE = ABAP_TRUE.       " BAPI에 대한 통화 금액(9 소수 자릿수)
*--------------------------------------------------------------------*
      " 변경 내용을 입력
      <FS_EKPO>-PO_ITEM = <FS_ITEM>-EBELP.                         " 품목번호

      IF <FS_ITEM>-MENGE EQ 0.                                     " 수량에 0 들어가면 삭제처리
        <FS_EKPOX>-DELETE_IND = ABAP_TRUE.                         " 삭제지시자
        <FS_EKPO>-DELETE_IND = 'X'.
      ELSE.
        <FS_EKPOX>-QUANTITY = ABAP_TRUE.        " 구매 오더 수량
        <FS_EKPO>-QUANTITY = <FS_ITEM>-MENGE.                      " 구매 오더 수량
      ENDIF.

      WRITE <FS_ITEM>-NETPR TO LV_NETPR CURRENCY <FS_ITEM>-WAERS.  " 통화키 적용
      CONDENSE LV_NETPR NO-GAPS.
      REPLACE ALL OCCURRENCES OF ',' IN LV_NETPR WITH ''.
      <FS_EKPO>-NET_PRICE = LV_NETPR.                              " BAPI에 대한 통화 금액(9 소수 자릿수)

*--------------------------------------------------------------------*
* EKET
*--------------------------------------------------------------------*
      APPEND INITIAL LINE TO LT_EKET ASSIGNING <FS_EKET>.
      APPEND INITIAL LINE TO LT_EKETX ASSIGNING <FS_EKETX>.

      <FS_EKETX>-PO_ITEM = <FS_ITEM>-EBELP.                         " 품목번호
      <FS_EKETX>-DELIVERY_DATE = ABAP_TRUE.

      <FS_EKET>-PO_ITEM = <FS_ITEM>-EBELP.                          " 품목번호
      <FS_EKET>-DELIVERY_DATE = <FS_ITEM>-EINDT.                    " 납품일

    ENDLOOP.

*--------------------------------------------------------------------*
* BAPI FUNCTION
*--------------------------------------------------------------------*
    PERFORM CALL_BAPI_PO_CHANGE USING <FS_ITEM>-EBELN LV_INDEX
                             CHANGING LS_EKKO LS_EKKOX
                                      LT_RETURN
                                      <FS_ITEM>
                                      LT_EKPO LT_EKPOX
                                      LT_EKET LT_EKETX.
    CLEAR : LV_START, LV_END.

  ENDLOOP.

*  SORT GT_ITEM BY EDIT DESCENDING EBELN.  " AT 구문 사용을 위한 SORT

*  LOOP AT GT_ITEM INTO DATA(LS_ITEM) GROUP BY ( EBELN = LS_ITEM-EBELN ).
*
*  ENDLOOP.

*  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WHERE EDIT EQ 'X'.
*    AT NEW EBELN.  " 최초로 PO 번호가 인지될 경우
*      CLEAR : LT_EKPO, LT_EKET, GV_RESULT.
*      LS_EKKO-PO_NUMBER = <FS_ITEM>-EBELN.  " KEY 필드는 필드에 데이터를 넣어줘야함..
*      LS_EKKOX-PO_NUMBER = ABAP_ON.
*    ENDAT.
*
*    <FS_ITEM>-CHANGED = ABAP_ON.
*
*    APPEND INITIAL LINE TO LT_EKPO ASSIGNING FIELD-SYMBOL(<FS_EKPO>).
*    " APPEND INITIAL LINE : LT_EKPO에 INITIAL 상태의 빈 행 하나 추가
*    " ASSIGNING FIELD-SYMBOL <FS_EKPO> : 방금 추가된 빈 행을 <FS_EKPO>에 연결 > 이후 FS를 통해 직접 값을 입력
*    APPEND INITIAL LINE TO LT_EKPOX ASSIGNING FIELD-SYMBOL(<FS_EKPOX>).
*
*    <FS_EKPOX>-PO_ITEM = <FS_ITEM>-EBELP.   " 품목번호 : KEY 필드는 필드에 데이터를 넣어줘야함..
*    <FS_EKPOX>-QUANTITY = ABAP_TRUE.        " 구매 오더 수량
*    <FS_EKPOX>-NET_PRICE = ABAP_TRUE.       " BAPI에 대한 통화 금액(9 소수 자릿수)
*
*    <FS_EKPO>-PO_ITEM = <FS_ITEM>-EBELP.                         " 품목번호
*    <FS_EKPO>-QUANTITY = <FS_ITEM>-MENGE.                        " 구매 오더 수량
*
*    WRITE <FS_ITEM>-NETPR TO LV_NETPR CURRENCY <FS_ITEM>-WAERS.  " 통화키 적용
*    CONDENSE LV_NETPR NO-GAPS.
*    REPLACE ALL OCCURRENCES OF ',' IN LV_NETPR WITH ''.
*    <FS_EKPO>-NET_PRICE = LV_NETPR.                              " BAPI에 대한 통화 금액(9 소수 자릿수)
*
*    APPEND INITIAL LINE TO LT_EKET ASSIGNING <FS_EKET>.
*    APPEND INITIAL LINE TO LT_EKETX ASSIGNING <FS_EKETX>.
*
*    <FS_EKETX>-DELIVERY_DATE = ABAP_TRUE.
*    <FS_EKET>-DELIVERY_DATE = <FS_ITEM>-EINDT.
*
*    IF <FS_EKPO>-QUANTITY EQ 0.               " 수량에 0 들어가면 삭제처리
*      <FS_EKPOX>-DELETE_IND = ABAP_TRUE.      " 삭제지시자
*      <FS_EKPO>-DELETE_IND = 'X'.
*    ENDIF.
*
*    AT END OF EBELN.  " 현재 작업 중인 구매오더 번호의 마지막에 헤더 정보, 아이템 정보를 BAPI에 태움.
*      DESCRIBE TABLE LT_EKPO LINES DATA(LV_EKPO).
*
*      CALL FUNCTION 'BAPI_PO_CHANGE'
*        EXPORTING
*          PURCHASEORDER = <FS_ITEM>-EBELN    " Purchasing Document Number
*          POHEADER      = LS_EKKO            " Header Data
*          POHEADERX     = LS_EKKOX           " Header Data (Change Parameter)
*        TABLES
*          RETURN        = LT_RETURN          " Return Parameter
*          POITEM        = LT_EKPO            " Item Data
*          POITEMX       = LT_EKPOX           " Item Data (Change Parameter)
*          POSCHEDULE    = LT_EKET            " Delivery Schedule
*          POSCHEDULEX   = LT_EKETX.          " Delivery Schedule (Change Parameter)
**--------------------------------------------------------------------*
** TRANSCATION COMMIT OR ROLLBACK
**--------------------------------------------------------------------*
*      DATA LV_NUM_SUCCESS TYPE I.
*      LV_NUM_SUCCESS = 0.
*
*      LOOP AT LT_RETURN ASSIGNING FIELD-SYMBOL(<FS_RETURN>).
*
*        IF <FS_RETURN>-ID EQ '06' AND <FS_RETURN>-NUMBER EQ '023'.
*          LV_NUM_SUCCESS += 1.
*        ENDIF.
*
*      ENDLOOP.
*
*      IF LV_NUM_SUCCESS EQ LV_EKPO.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = 'X'.                 " Use of Command `COMMIT AND WAIT`
*
*        GV_RESULT = 'S'.
*      ELSE.
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*        GV_RESULT = 'F'.
*      ENDIF.
*
*      PERFORM LOCK_FIELD.
*    ENDAT.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_PO
*&---------------------------------------------------------------------*
FORM REFRESH_PO .

  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<FS_HEADER>) WHERE BTN EQ ICON_DISPLAY_MORE.
    <FS_HEADER>-BTN = ICON_ENTER_MORE.
    MODIFY GT_HEADER FROM <FS_HEADER>.
  ENDLOOP.

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

  IF GO_ALV_GRID2 IS NOT INITIAL.

    CLEAR : GT_ITEM.
    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HANDLER_ITEM
*&---------------------------------------------------------------------*
FORM SET_HANDLER_ITEM .

  GO_ALV_GRID2->REGISTER_EDIT_EVENT(
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED                 " Event ID
    EXCEPTIONS
      ERROR      = 1                " Error
      OTHERS     = 2
  ).

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SET HANDLER LCL_ITEM_EVENT_HANDLER=>ON_TOOLBAR FOR GO_ALV_GRID2.
  SET HANDLER LCL_ITEM_EVENT_HANDLER=>ON_USER_COMMAND FOR GO_ALV_GRID2.
  SET HANDLER LCL_ITEM_EVENT_HANDLER=>ON_DATA_CHANGED FOR GO_ALV_GRID2.
  SET HANDLER LCL_ITEM_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_ITEM_TOOLBAR  CHANGING P_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA LS_BUTTON LIKE LINE OF P_OBJECT->MT_TOOLBAR.

  CLEAR : LS_BUTTON.
  LS_BUTTON-BUTN_TYPE = 3.
  APPEND LS_BUTTON TO P_OBJECT->MT_TOOLBAR.

  CLEAR : LS_BUTTON.
  LS_BUTTON-FUNCTION = 'ASELECT'.
  LS_BUTTON-ICON = ICON_SELECT_ALL.
  LS_BUTTON-TEXT = ' 전체선택'.
  APPEND LS_BUTTON TO P_OBJECT->MT_TOOLBAR.

  CLEAR : LS_BUTTON.
  LS_BUTTON-FUNCTION = 'DSELECT'.
  LS_BUTTON-ICON = ICON_DESELECT_ALL.
  LS_BUTTON-TEXT = ' 전체해제'.
  APPEND LS_BUTTON TO P_OBJECT->MT_TOOLBAR.

  CLEAR : LS_BUTTON.
  LS_BUTTON-FUNCTION = 'SELECT'.
  LS_BUTTON-ICON = ICON_SELECT_BLOCK.
  LS_BUTTON-TEXT = ' 지정선택'.
  APPEND LS_BUTTON TO P_OBJECT->MT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_ITEM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_ITEM  USING P_UCOMM TYPE SY-UCOMM.

  CASE P_UCOMM.
    WHEN 'ASELECT'.
      LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
        IF <FS_ITEM>-CHANGED = 'X'.
          <FS_ITEM>-EDIT = 'X'.
        ENDIF.
      ENDLOOP.
    WHEN 'DSELECT'.
      LOOP AT GT_ITEM ASSIGNING <FS_ITEM>
        WHERE EDIT = 'X'.
        <FS_ITEM>-EDIT = SPACE.
      ENDLOOP.
    WHEN 'SELECT'.
      DATA : LT_INDEX_ROWS TYPE LVC_T_ROW.

      CALL METHOD GO_ALV_GRID2->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_INDEX_ROWS.                 " Indexes of Selected Rows

      LOOP AT LT_INDEX_ROWS ASSIGNING FIELD-SYMBOL(<LS_INDEX_ROW>).
        IF <LS_INDEX_ROW>-ROWTYPE EQ 0.
          READ TABLE GT_ITEM INTO GS_ITEM INDEX <LS_INDEX_ROW>-INDEX.
          IF GS_ITEM-CHANGED EQ 'X'.
            GS_ITEM-EDIT = 'X'.
            MODIFY GT_ITEM FROM GS_ITEM INDEX <LS_INDEX_ROW>-INDEX.
          ENDIF.
        ENDIF.

      ENDLOOP.
  ENDCASE.

  CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HANDER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM ALV_HANDER_DATA_CHANGED  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LT_MODI   TYPE LVC_T_MODI,
         LS_MODI   TYPE LVC_S_MODI,
         LV_ROW_ID TYPE INT4,
         LS_ITEM   TYPE TS_ITEM,
         LS_P      TYPE P DECIMALS 2.

  FIELD-SYMBOLS <FS>.

  LT_MODI = PR_DATA_CHANGED->MT_MOD_CELLS.

*--------------------------------------------------------------------*
* Macro Definition
*--------------------------------------------------------------------*
  DEFINE   __GET_VALUE.

    ASSIGN COMPONENT &1 OF STRUCTURE GS_ITEM TO <FS>.
    IF SY-SUBRC EQ 0.
      PR_DATA_CHANGED->GET_CELL_VALUE(
        EXPORTING
          I_ROW_ID    = LS_MODI-ROW_ID    " Row ID
          I_FIELDNAME = &1                " Field Name
        IMPORTING
          E_VALUE     = <FS>              " Cell Content
      ).
      UNASSIGN <FS>.
    ENDIF.
  END-OF-DEFINITION.

  DEFINE __MODIFY_VALUE.

    ASSIGN COMPONENT &1 OF STRUCTURE GS_ITEM TO <FS>.
    IF SY-SUBRC EQ 0.
      PR_DATA_CHANGED->MODIFY_CELL(
        I_ROW_ID    = LS_MODI-ROW_ID     " Row ID
        I_FIELDNAME = &1                 " Field Name
        I_VALUE     = <FS>               " Value
      ).
      UNASSIGN <FS>.
    ENDIF.

  END-OF-DEFINITION.

  LOOP AT LT_MODI INTO LS_MODI.

    CASE LS_MODI-FIELDNAME.     " FIELDNAME 기준
      WHEN 'MENGE' OR 'NETPR'.  " 수량 혹은 단가가 변경된 경우
        READ TABLE GT_ITEM INTO GS_ITEM INDEX LS_MODI-ROW_ID.
        IF SY-SUBRC EQ 0.
          __GET_VALUE : 'MENGE',
                        'NETPR'.

          GS_ITEM-SUM = GS_ITEM-MENGE * GS_ITEM-NETPR.

          __MODIFY_VALUE : 'SUM'.
        ENDIF.

      WHEN 'EINDT'.             " 납품일이 변경된 경우
        READ TABLE GT_ITEM INTO GS_ITEM INDEX LS_MODI-ROW_ID.
        IF SY-SUBRC EQ 0.
          __GET_VALUE : 'EINDT'.

          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              DATE                      = GS_ITEM-EINDT    " Transfer of date to be checked
            EXCEPTIONS
              PLAUSIBILITY_CHECK_FAILED = 1                " Date is not plausible
              OTHERS                    = 2.

          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ELSE.
            __MODIFY_VALUE : 'EINDT'.
          ENDIF.
        ENDIF.

    ENDCASE.

    GS_ITEM-STATUS = ICON_YELLOW_LIGHT.
    __MODIFY_VALUE : 'STATUS'.

    GS_ITEM-CHANGED = 'X'.
    MODIFY GT_ITEM FROM GS_ITEM INDEX LS_MODI-ROW_ID.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOCK_FIELD
*&---------------------------------------------------------------------*
FORM LOCK_FIELD USING PV_RESULT
             CHANGING PS_ITEM TYPE TS_ITEM.

  DATA: GT_CELLSTYLE TYPE LVC_T_STYL,
        GS_CELLSTYLE TYPE LVC_S_STYL.

  CLEAR GT_CELLSTYLE.
  IF PV_RESULT EQ 'S'.

    GS_CELLSTYLE-FIELDNAME = 'EDIT'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE PS_ITEM-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'MENGE'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE PS_ITEM-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'NETPR'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE PS_ITEM-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'EINDT'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE PS_ITEM-CELLSTYL.

    PS_ITEM-STATUS = ICON_GREEN_LIGHT.
  ELSEIF PV_RESULT EQ 'F'.
    PS_ITEM-STATUS = ICON_RED_LIGHT.
  ELSEIF PV_RESULT EQ 'W'.
    PS_ITEM-STATUS = ICON_YELLOW_LIGHT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SUCCESS_OR_FAIL
*&---------------------------------------------------------------------*
FORM CHECK_SUCCESS_OR_FAIL USING PT_RETURN TYPE BAPIRET2
                                 PT_EKPO TYPE BAPIMEPOITEM.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_PO_CHANGE
*&---------------------------------------------------------------------*
FORM CALL_BAPI_PO_CHANGE  USING VALUE(PV_EBELN) VALUE(PV_INDEX)
                       CHANGING PS_EKKO TYPE TS_EKKO
                                PS_EKKOX TYPE TS_EKKOX
                                PT_RETURN TYPE TY_RETURN
                                PS_ITEM TYPE TS_ITEM
                                PT_EKPO TYPE TY_EKPO
                                PT_EKPOX TYPE TY_EKPOX
                                PT_EKET TYPE TY_EKET
                                PT_EKETX TYPE TY_EKETX.
  DATA : LV_RESULT.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = PV_EBELN           " Purchasing Document Number
      POHEADER      = PS_EKKO            " Header Data
      POHEADERX     = PS_EKKOX           " Header Data (Change Parameter)
    TABLES
      RETURN        = PT_RETURN          " Return Parameter
      POITEM        = PT_EKPO            " Item Data
      POITEMX       = PT_EKPOX           " Item Data (Change Parameter)
      POSCHEDULE    = PT_EKET            " Delivery Schedule
      POSCHEDULEX   = PT_EKETX.          " Delivery Schedule (Change Parameter)

  CLEAR : PT_EKPO, PT_EKPOX, PT_EKET, PT_EKETX.
  MOVE PT_RETURN TO PS_ITEM-RETURN_MSG.

* COMMIT 여부 결정
  READ TABLE PT_RETURN ASSIGNING FIELD-SYMBOL(<FS_RETURN>) WITH KEY TYPE = 'S' NUMBER = '023'.

  IF SY-SUBRC = 0.
    LV_RESULT = 'S'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.
  ELSE.
    LV_RESULT = 'F'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    READ TABLE PT_RETURN ASSIGNING <FS_RETURN> INDEX 1.
  ENDIF.

* 고정단가 점검
  READ TABLE PT_RETURN ASSIGNING <FS_RETURN> WITH KEY ID = 'ME' NUMBER = '664'.

  IF SY-SUBRC = 0.  " 고정단가로 인해 값이 변하지 않았다는 것.
    LV_RESULT = 'W'.  " Edit을 잠구지 못하도록 별도의 상태값 부여

    READ TABLE GT_ITEM_BACKUP INTO DATA(LS_ITEM_BACKUP) INDEX PV_INDEX.  " 백업 테이블에서 데이터 가져오기
    PS_ITEM-NETPR = LS_ITEM_BACKUP-NETPR.  " 데이터 원복

  ENDIF.

  PS_ITEM-MSG = <FS_RETURN>-MESSAGE.
  PERFORM LOCK_FIELD USING LV_RESULT
                  CHANGING PS_ITEM.

  PERFORM ADJUST_HEADER USING PS_ITEM.

  CLEAR : PT_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK_ITEM
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_ITEM  USING P_COLUMN_ID TYPE LVC_S_COL
                               P_ROW_ID TYPE LVC_S_ROW.

  IF P_ROW_ID-ROWTYPE EQ 0.
    CASE P_COLUMN_ID-FIELDNAME.
      WHEN 'EBELN'.
        READ TABLE GT_ITEM INTO DATA(LS_ITEM) INDEX P_ROW_ID-INDEX.
        SET PARAMETER ID 'BES' FIELD LS_ITEM-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      WHEN 'MSG'.
        READ TABLE GT_ITEM INTO LS_ITEM INDEX P_ROW_ID-INDEX.
        IF SY-SUBRC EQ 0.
          "Display messages from bapiret2
          CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
            TABLES
              IT_RETURN = LS_ITEM-RETURN_MSG.
        ENDIF.
    ENDCASE.
  ELSE.
    MESSAGE '일반행을 더블클릭 해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADJUST_HEADER
*&---------------------------------------------------------------------*
FORM ADJUST_HEADER  USING PS_ITEM TYPE TS_ITEM.

  READ TABLE GT_HEADER INTO DATA(LS_HEADER) WITH KEY BTN = ICON_DISPLAY_MORE.

  IF SY-SUBRC EQ 0.
    DATA(LV_INDEX) = SY-TABIX.
  ENDIF.

  READ TABLE GT_ITEM_BACKUP INTO DATA(LS_ITEM_OLD) WITH KEY EBELN = PS_ITEM-EBELN EBELP = PS_ITEM-EBELP.

  IF PS_ITEM-MENGE = 0.

    LS_HEADER-PO_COUNT -= 1.
    LS_HEADER-PO_TOTAL_COUNT = LS_HEADER-PO_TOTAL_COUNT - LS_ITEM_OLD-MENGE + PS_ITEM-MENGE.
    LS_HEADER-TOTAL_NETWR = LS_HEADER-TOTAL_NETWR - LS_ITEM_OLD-SUM + PS_ITEM-SUM .

  ELSE.

    LS_HEADER-PO_TOTAL_COUNT = LS_HEADER-PO_TOTAL_COUNT - LS_ITEM_OLD-MENGE + PS_ITEM-MENGE.
    LS_HEADER-TOTAL_NETWR = LS_HEADER-TOTAL_NETWR - LS_ITEM_OLD-SUM + PS_ITEM-SUM .

  ENDIF.

  MODIFY GT_HEADER FROM LS_HEADER INDEX LV_INDEX TRANSPORTING PO_COUNT PO_TOTAL_COUNT TOTAL_NETWR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOCK_DELETED_ROWS
*&---------------------------------------------------------------------*
FORM LOCK_DELETED_ROWS .

  DATA: GT_CELLSTYLE TYPE LVC_T_STYL,
        GS_CELLSTYLE TYPE LVC_S_STYL.

  CLEAR GT_CELLSTYLE.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
    IF <FS_ITEM>-LOEKZ IS NOT INITIAL.
      GS_CELLSTYLE-FIELDNAME = 'EDIT'.
      GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT GS_CELLSTYLE INTO TABLE <FS_ITEM>-CELLSTYL.

      GS_CELLSTYLE-FIELDNAME = 'MENGE'.
      GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT GS_CELLSTYLE INTO TABLE <FS_ITEM>-CELLSTYL.

      GS_CELLSTYLE-FIELDNAME = 'NETPR'.
      GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT GS_CELLSTYLE INTO TABLE <FS_ITEM>-CELLSTYL.

      GS_CELLSTYLE-FIELDNAME = 'EINDT'.
      GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT GS_CELLSTYLE INTO TABLE <FS_ITEM>-CELLSTYL.

      <FS_ITEM>-STATUS = ICON_RED_LIGHT.
      <FS_ITEM>-MSG = TEXT-M01.  " 이미 삭제된 구매오더 입니다.
    ENDIF.
  ENDLOOP.

ENDFORM.
