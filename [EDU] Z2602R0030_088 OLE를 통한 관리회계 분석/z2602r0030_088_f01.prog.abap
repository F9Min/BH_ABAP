*&---------------------------------------------------------------------*
*& Include          Z2602R0030_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA: LV_FIELDNAME TYPE STRING,
        LV_SUM       TYPE COSP-WKG001.
  FIELD-SYMBOLS: <FS_VALUE> TYPE ANY.

  " 모든 기간 컬럼(WKG001~016)을 조회
  SELECT B~KOSTL,
         C~KTEXT,
         A~WRTTP,
         A~WKG001, A~WKG002, A~WKG003, A~WKG004, A~WKG005, A~WKG006,
         A~WKG007, A~WKG008, A~WKG009, A~WKG010, A~WKG011, A~WKG012,
         A~WKG013, A~WKG014, A~WKG015, A~WKG016
      FROM COSP AS A
      INNER JOIN CSKS AS B ON A~OBJNR = B~OBJNR  " OBJNR로 두 테이블 연결
    LEFT OUTER JOIN CSKT AS C ON B~KOKRS = C~KOKRS
                             AND B~KOSTL = C~KOSTL
                             AND C~SPRAS = @SY-LANGU
      INTO TABLE @DATA(LT_RAW)
      WHERE B~KOKRS = @P_KOKRS      " CSKS의 관리영역
        AND A~GJAHR = @P_GJAHR      " COSP의 연도
        AND B~KOSTL IN @S_KOSTL     " 사용자가 입력한 KOSTL 범위
        AND A~WRTTP IN ('01', '04').

  LOOP AT LT_RAW INTO DATA(LS_RAW).
    CLEAR: LV_SUM, GS_REPORT.

    " 사용자가 선택한 기간(S_PERBL)에 해당하는 컬럼만 동적으로 합산
    DO 16 TIMES.
      IF SY-INDEX IN S_PERBL.
        LV_FIELDNAME = |WKG{ SY-INDEX WIDTH = 3 ALIGN = RIGHT PAD = '0' }|.
        ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE LS_RAW TO <FS_VALUE>.
        IF <FS_VALUE> IS ASSIGNED.
          LV_SUM = LV_SUM + <FS_VALUE>.
        ENDIF.
      ENDIF.
    ENDDO.

    GS_REPORT-KOSTL = LS_RAW-KOSTL.
    GS_REPORT-KTEXT = LS_RAW-KTEXT.

    IF LS_RAW-WRTTP = '01'.
      GS_REPORT-PLAN_AMT = LV_SUM.
    ELSE.
      GS_REPORT-ACT_AMT = LV_SUM.
    ENDIF.
    COLLECT GS_REPORT INTO GT_REPORT.
  ENDLOOP.

  IF GT_REPORT IS INITIAL.
    MESSAGE '조회된 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.

  ELSE.

    DATA : LV_RC        TYPE I,
           LV_DATA      TYPE STRING,
           LS_CLIPBOARD TYPE C LENGTH 1024,
           LT_CLIPBOARD LIKE TABLE OF LS_CLIPBOARD,
           LV_TAB       TYPE C VALUE CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

    SORT GT_REPORT BY PLAN_AMT DESCENDING
                      ACT_AMT DESCENDING
                      KOSTL.

    LOOP AT GT_REPORT INTO GS_REPORT.

      LV_DATA = |{ GS_REPORT-KOSTL }{ LV_TAB }{ GS_REPORT-KTEXT }{ LV_TAB }{ GS_REPORT-PLAN_AMT }{ LV_TAB }{ GS_REPORT-ACT_AMT }|.
      APPEND LV_DATA TO LT_CLIPBOARD.
      CLEAR : LV_DATA.

    ENDLOOP.

    CALL METHOD CL_GUI_CFW=>FLUSH.

    " 4-2 클립보드로 데이터 전송
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
      EXPORTING
        NO_AUTH_CHECK        = 'X'
      IMPORTING
        DATA                 = LT_CLIPBOARD                 " Data
      CHANGING
        RC                   = LV_RC                 " Return Code
      EXCEPTIONS
        CNTL_ERROR           = 1                " Control error
        ERROR_NO_GUI         = 2                " No GUI available
        NOT_SUPPORTED_BY_GUI = 3                " GUI does not support this
        NO_AUTHORITY         = 4                " Authorization check failed
        OTHERS               = 5.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
FORM DOWNLOAD_TEMPLATE .

  DATA : LV_FULLPATH TYPE STRING.

  GV_KEY = 'MIZ2602R0030_088_1'.
  CONCATENATE 'OLE_LEVEL1_' SY-DATUM '_'  SY-UZEIT '_'  '.XLSX' INTO GV_FILE.

  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
      WINDOW_TITLE              = '파일 다운로드'                                       " Window Title
      DEFAULT_EXTENSION         = 'XLSX'                                                " Default Extension
      DEFAULT_FILE_NAME         = GV_FILE                                               " Default File Name
      FILE_FILTER               = 'Excel Workbook (*.xlsx)|*.xlsx|All Files (*.*)|*.*'  " File Type Filter Table
    CHANGING
      FILENAME                  = GV_FILE                                               " File Name to Save
      PATH                      = GV_PATH                                               " Path to File
      FULLPATH                  = LV_FULLPATH                                           " Path + File Name
      USER_ACTION               = GV_USER_ACT                                           " User Action (C Class Const ACTION_OK, ACTION_OVERWRITE etc)
  EXCEPTIONS
    CNTL_ERROR                = 1                                                       " Control error
    ERROR_NO_GUI              = 2                                                       " No GUI available
    NOT_SUPPORTED_BY_GUI      = 3                                                       " GUI does not support this
    INVALID_DEFAULT_FILE_NAME = 4                                                       " Invalid default file name
    OTHERS                    = 5
  ).

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF NOT TO_UPPER( LV_FULLPATH ) CP '*.XLSX'.
    LV_FULLPATH = |{ LV_FULLPATH }.xlsx|.
  ENDIF.

  GV_FULLPATH = LV_FULLPATH.

  IF GV_USER_ACT <> CL_GUI_FRONTEND_SERVICES=>ACTION_OK OR GV_FULLPATH IS INITIAL.
    " 사용자가 취소
    MESSAGE '작업이 취소됐습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    STOP.
  ENDIF.

  " SMW0 템플릿 다운로드
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = GV_KEY
      DESTINATION = GV_FULLPATH.

  " OLE 엑셀 실행
  IF G_EXCEL IS INITIAL.
    CREATE OBJECT G_EXCEL 'EXCEL.APPLICATION'.
  ENDIF.

  IF  SY-SUBRC NE 0.
    MESSAGE I000(00) WITH 'error during open exel'.
    STOP.
  ENDIF.

  " 팝업/경고 억제 + 화면 숨김
  SET  PROPERTY OF G_EXCEL 'Visible'   = 0.
  SET PROPERTY OF G_EXCEL 'DisplayAlerts' = 0.
  CALL METHOD OF G_EXCEL 'Workbooks' = G_WORKBOOKS.

  CALL METHOD OF G_WORKBOOKS 'OPEN' EXPORTING #1 = GV_FULLPATH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GENERATE_REPORT
*&---------------------------------------------------------------------*
FORM GENERATE_REPORT .

  DATA: LV_LOW      TYPE NUMC2,
        LV_HIGH     TYPE NUMC2,
        LV_ROW      TYPE I,
        LV_INS_ROW  TYPE I,
        LV_LINES    TYPE I,
        LV_PERIOD   TYPE STRING,
        LV_DATETIME TYPE STRING.
**********************************************************************
* 1. 성능 최적화: 화면 갱신 중지
**********************************************************************
  SET PROPERTY OF G_EXCEL 'ScreenUpdating' = 1.
**********************************************************************
* 2. [상단 정보] 헤더 영역 매핑 (Single Values)
**********************************************************************
  " 2-1. 관리회계 영역 코드 입력
  PERFORM FILL_CELL USING 4 9 P_KOKRS.
  " 2-2. 조회 기간 정보 입력 (예: 1 ~ 12)
  LV_LOW = S_PERBL-LOW.
  LV_HIGH = S_PERBL-HIGH.
  LV_PERIOD = |{ LV_LOW }월 ~ { LV_HIGH }월|.
  PERFORM FILL_CELL USING 5 9 LV_PERIOD.
  " 2-3. 회계연도
  PERFORM FILL_CELL USING 4 12 P_GJAHR.
  " 2-4.출력 일시
  LV_DATETIME = |{ SY-DATUM+0(4) }.{ SY-DATUM+4(2) }.{ SY-DATUM+6(2) } { SY-UZEIT+0(2) }:{ SY-UZEIT+2(2) }|.
  PERFORM FILL_CELL USING 5 12 LV_DATETIME.
**********************************************************************
* 3. [라인 동적 생성] 데이터 개수에 맞춰 행 삽입
**********************************************************************
  DESCRIBE TABLE GT_REPORT LINES LV_LINES.

  " 템플릿에 기본으로 데이터용 2행(10, 11행)이 있다고 가정할 때,
  " 데이터가 2건을 초과하면 11행 위치에 필요한 만큼 행을 삽입합니다.
  IF LV_LINES > 2.
    LV_INS_ROW = LV_LINES - 2.
    DO LV_INS_ROW TIMES.
      " 11행을 선택하여 행 삽입 (기존 11행 서식이 복사되며 합계 행이 아래로 밀림)
      CALL METHOD OF G_EXCEL 'Rows' = G_ROWS EXPORTING #1 = 11.
      CALL METHOD OF G_ROWS 'Insert'.
    ENDDO.
  ENDIF.
**********************************************************************
* 4. [데이터 리스트] 반복문 매핑 (Internal Table)
**********************************************************************
  " 붙여넣기
  CALL METHOD OF G_EXCEL 'Cells' = G_CELL
    EXPORTING #1 = 10 #2 = 2.

  CALL METHOD OF G_CELL 'Select'.

  DATA : LV_WORKSHEET TYPE OLE2_OBJECT.
  CALL METHOD OF G_EXCEL 'ACTIVESHEET' = LV_WORKSHEET.

  CALL METHOD OF LV_WORKSHEET 'Paste'.

**********************************************************************
* 5. 마무리: 열 최적화 + 화면 갱신 다시 켜기 및 사용자에게 보여주기
**********************************************************************
  CALL METHOD OF G_EXCEL 'Columns' = G_COLUMNS EXPORTING #1 = 'B:E'.
  CALL METHOD OF G_COLUMNS 'AutoFit'.
  FREE OBJECT G_COLUMNS.

  CALL METHOD OF G_EXCEL 'Columns' = G_COLUMNS EXPORTING #1 = 'H:L'.
  CALL METHOD OF G_COLUMNS 'AutoFit'.
  FREE OBJECT G_COLUMNS.

  CALL METHOD OF G_EXCEL 'Columns' = G_COLUMNS EXPORTING #1 = 'B:C'.
  SET PROPERTY OF G_COLUMNS 'HorizontalAlignment' = -4131.
  FREE OBJECT G_COLUMNS.

  CALL METHOD OF G_EXCEL 'Range' = G_COLUMNS EXPORTING #1 = 'I4:I5,L4:L5'.
  SET PROPERTY OF G_COLUMNS 'HorizontalAlignment' = -4131.
  FREE OBJECT G_COLUMNS.

  SET PROPERTY OF G_EXCEL 'ScreenUpdating' = 1.
  SET PROPERTY OF G_EXCEL 'Visible' = 1.

  " 엑셀을 맨 앞으로 가져오기 (선택 사항)
  CALL METHOD OF G_EXCEL 'Activate'.
  MESSAGE '데이터 매핑이 완료되었습니다.' TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CELL
*&---------------------------------------------------------------------*
FORM FILL_CELL  USING VALUE(PV_ROW)
                      VALUE(PV_COL)
                            PV_VAL.

  CALL METHOD OF G_EXCEL 'Cells' = G_CELL
    EXPORTING
      #1 = PV_ROW
      #2 = PV_COL.

  SET PROPERTY OF G_CELL 'Value' = PV_VAL.

ENDFORM.
