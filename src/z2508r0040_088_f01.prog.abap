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

  IF GT_DISPLAY IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE '출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

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

  CLEAR : LV_COL_POS.
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

  APPEND LS_FCAT TO PT_FCAT.
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXEC'.
      PERFORM CREATE_PO.
  ENDCASE.

ENDMODULE.
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
