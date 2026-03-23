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
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
FORM DOWNLOAD_TEMPLATE .

  DATA : LV_FULLPATH TYPE STRING.

  GV_KEY = 'MIZ2602R0040_088'.
  CONCATENATE 'OLE_LEVEL2_' SY-DATUM '_'  SY-UZEIT '_'  '.XLSX' INTO GV_FILE.

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

  GV_FULLPATH = LV_FULLPATH.

  IF GV_USER_ACT <> CL_GUI_FRONTEND_SERVICES=>ACTION_OK OR GV_FULLPATH IS INITIAL.
    " 사용자가 취소
    MESSAGE '작업이 취소됐습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    STOP.
  ENDIF.

  " 4. 확장자 강제 확인 로직 (대소문자 구분 없이 체크)
  IF NOT TO_UPPER( LV_FULLPATH ) CP '*.XLSX'.
    LV_FULLPATH = |{ LV_FULLPATH }.xlsx|.
  ENDIF.

  GV_FULLPATH = LV_FULLPATH.

  " 5. SMW0 템플릿 다운로드
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = GV_KEY
      DESTINATION = GV_FULLPATH.

  " 6. OLE 엑셀 실행
  IF G_EXCEL IS INITIAL.
    CREATE OBJECT G_EXCEL 'EXCEL.APPLICATION'.
  ENDIF.

  IF  SY-SUBRC NE 0.
    MESSAGE I000(00) WITH 'error during open exel'.
    STOP.
  ENDIF.

  " 팝업/경고 억제 + 화면 숨김
  SET PROPERTY OF G_EXCEL 'Visible'   = 0.
  SET PROPERTY OF G_EXCEL 'DisplayAlerts' = 0.
  CALL METHOD OF G_EXCEL 'Workbooks' = G_WORKBOOKS.

  CALL METHOD OF G_WORKBOOKS 'OPEN' = G_WORKBOOK EXPORTING #1 = GV_FULLPATH.

  CALL METHOD CL_GUI_CFW=>FLUSH.

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
        LV_DATETIME TYPE STRING,
        LV_FORMULA  TYPE STRING.

  " 1. 성능 최적화: 화면 갱신 중지
*  SET PROPERTY OF G_EXCEL 'ScreenUpdating' = 0.

  " 2. [상단 정보] 헤더 영역 매핑 (Single Values)
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

  " 3. [라인 동적 생성] 데이터 개수에 맞춰 행 삽입
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

  " 4. [데이터 리스트] 반복문 매핑 (Internal Table)
  SORT GT_REPORT BY PLAN_AMT DESCENDING
                    ACT_AMT  DESCENDING
                    KOSTL.

  LV_ROW = 10. " 템플릿의 데이터 시작 행

  LOOP AT GT_REPORT INTO GS_REPORT.
    " B열(2): 코스트센터 번호
    PERFORM FILL_CELL USING LV_ROW 2 GS_REPORT-KOSTL.
    " C열(3): 코스트센터명
    PERFORM FILL_CELL USING LV_ROW 3 GS_REPORT-KTEXT.
    " D열(4): 계획 금액
    PERFORM FILL_CELL USING LV_ROW 4 GS_REPORT-PLAN_AMT.

    IF GS_REPORT-PLAN_AMT = 0.
      CALL METHOD OF G_EXCEL 'Cells' = G_CELL EXPORTING #1 = LV_ROW #2 = 7.
      GET PROPERTY OF G_CELL 'Interior' = G_INTERIOR.
      SET PROPERTY OF G_INTERIOR 'Color' = 255.
      FREE OBJECT: G_CELL, G_INTERIOR.
    ENDIF.

    " E열(5): 실적 금액
    PERFORM FILL_CELL USING LV_ROW 5 GS_REPORT-ACT_AMT.

    " F열(6): 차이 = 계획(D) - 실적(E)
    LV_FORMULA = |=D{ LV_ROW }-E{ LV_ROW }|.
    CALL METHOD OF G_EXCEL 'Cells' = G_CELL EXPORTING #1 = LV_ROW #2 = 6.
    SET PROPERTY OF G_CELL 'Formula' = LV_FORMULA.
    FREE OBJECT G_CELL.

    " G열(7): 집행률 = 실적(E) / 계획(D) * 100 (0으로 나누기 방지 포함)
    LV_FORMULA = |=IF(D{ LV_ROW }=0, 0, E{ LV_ROW }/D{ LV_ROW })|.
    CALL METHOD OF G_EXCEL 'Cells' = G_CELL EXPORTING #1 = LV_ROW #2 = 7.
    SET PROPERTY OF G_CELL 'Formula' = LV_FORMULA.
    FREE OBJECT G_CELL.

    " 다음 행으로 이동
    LV_ROW = LV_ROW + 1.

  ENDLOOP.
  " 5. 마무리: 열 최적화 + 화면 갱신 다시 켜기 및 사용자에게 보여주기
  CALL METHOD OF G_EXCEL 'Columns' = G_COLUMNS EXPORTING #1 = 'B:E'.
  CALL METHOD OF G_COLUMNS 'AutoFit'.
  FREE OBJECT G_COLUMNS.

  CALL METHOD OF G_EXCEL 'Columns' = G_COLUMNS EXPORTING #1 = 'H:L'.
  CALL METHOD OF G_COLUMNS 'AutoFit'.
  FREE OBJECT G_COLUMNS.

  DATA(LV_ROW_NUM) = 10 + LV_LINES - 1.
  DATA(LV_LEFT_ALIGN_RANGE) = |B10:C{ LV_ROW_NUM }|.
  CALL METHOD OF G_EXCEL 'Range' = G_COLUMNS EXPORTING #1 = LV_LEFT_ALIGN_RANGE.
  SET PROPERTY OF G_COLUMNS 'HorizontalAlignment' = -4131.
  FREE OBJECT G_COLUMNS.

  CALL METHOD OF G_EXCEL 'Range' = G_COLUMNS EXPORTING #1 = 'I4:I5,L4:L5'.
  SET PROPERTY OF G_COLUMNS 'HorizontalAlignment' = -4131.
  FREE OBJECT G_COLUMNS.

  SET PROPERTY OF G_EXCEL 'ScreenUpdating' = 1.
  SET PROPERTY OF G_EXCEL 'Visible' = 1.

  " 엑셀을 맨 앞으로 가져오기 (선택 사항)
  CALL METHOD OF G_EXCEL 'Activate'.


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
*&---------------------------------------------------------------------*
*& Form GENERATE_CHART
*&---------------------------------------------------------------------*
FORM GENERATE_CHART .

  DATA : G_SHEETS TYPE OLE2_OBJECT,
         G_SHEET1 TYPE OLE2_OBJECT,
         G_RANGE  TYPE OLE2_OBJECT,
         G_CHART  TYPE OLE2_OBJECT.

  " 필요한 전역 객체 변수들은 TOP에 선언되어 있다고 가정합니다.
  DATA: LO_TITLE     TYPE OLE2_OBJECT,
        LO_CHART_OBJ TYPE OLE2_OBJECT.
  DATA: LV_LINES     TYPE I, LV_TOP_N TYPE I, LV_CHART_ROW TYPE I, LV_RANGE_STR TYPE STRING.

  " 1. 데이터 건수 확인
  DESCRIBE TABLE GT_REPORT LINES LV_LINES.
  CHECK LV_LINES > 0.

  " 2. 시트 컬랙션 확인
  GET PROPERTY OF G_WORKBOOK 'Sheets' = G_SHEETS.
  CALL METHOD OF G_SHEETS 'Item' = G_CHART EXPORTING #1 = 2. " 2번째 시트(chart)
  CALL METHOD OF G_CHART 'Activate'.

  " 2. 실제 차트 객체 생성
  CALL METHOD OF G_CHART 'ChartObjects' = LO_CHART_OBJ.
  " 시트 내부에 가로 500, 세로 300 크기의 차트 박스 추가
  CALL METHOD OF LO_CHART_OBJ 'Add' = LO_CHART_OBJ
    EXPORTING #1 = 10 #2 = 10 #3 = 500 #4 = 300.
  GET PROPERTY OF LO_CHART_OBJ 'Chart' = G_CHART.

  " 3. 데이터 범위 설정 (성공 코드 방식: 단순 주소 사용)
  " 현재 Data_Sheet가 1번이므로 시트명을 포함한 문자열 사용
  LV_CHART_ROW = 9 + 5.
  LV_RANGE_STR = |report!$C$9:$E${ LV_CHART_ROW }|.
  CALL METHOD OF G_EXCEL 'Range' = G_RANGE EXPORTING #1 = LV_RANGE_STR.

  " 4. 차트 타입 및 데이터 연결
  SET PROPERTY OF G_CHART 'ChartType' = 51. " xlColumnClustered
  CALL METHOD OF G_CHART 'SetSourceData' EXPORTING #1 = G_RANGE #2 = 2. " xlRows(2) 사용

  " 5. 제목 설정
  SET PROPERTY OF G_CHART 'HasTitle' = 1.
  GET PROPERTY OF G_CHART 'ChartTitle' = LO_TITLE.
  SET PROPERTY OF LO_TITLE 'Text' = '실적 TOP 5 부서 분석'.

  CALL METHOD CL_GUI_CFW=>FLUSH.
  MESSAGE '데이터 매핑이 완료되었습니다.' TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_and_generate_chart
*&---------------------------------------------------------------------*
FORM ADD_AND_GENERATE_CHART .

  DATA : G_SHEETS TYPE OLE2_OBJECT,
         G_SHEET1 TYPE OLE2_OBJECT,
         G_RANGE  TYPE OLE2_OBJECT,
         G_CHART  TYPE OLE2_OBJECT.

  DATA: LO_CHART_TITLE TYPE OLE2_OBJECT. " 제목 객체용 변수 분리
  DATA: LV_LINES     TYPE I,
        LV_TOP_N     TYPE I,
        LV_CHART_ROW TYPE I,
        LV_RANGE_STR TYPE STRING.

  " 1. 데이터 건수 확인 (데이터가 없으면 차트를 그리지 않음)
  DESCRIBE TABLE GT_REPORT LINES LV_LINES.
  CHECK LV_LINES > 0.

  " TOP 5 데이터 범위 계산 (9행은 헤더)
  LV_TOP_N = NMIN( VAL1 = 5 VAL2 = LV_LINES ).
  LV_CHART_ROW = 9 + LV_TOP_N. " 데이터 시작이 10행이므로 9 + 5 = 14행까지

  " 2. 데이터 시트 이름 명시 (범위 지정을 위해 필요)
  CALL METHOD OF G_EXCEL 'Sheets' = G_SHEETS.
  CALL METHOD OF G_SHEETS 'Item' = G_SHEET1 EXPORTING #1 = 1.
  SET PROPERTY OF G_SHEET1 'Name' = 'Data_Sheet'.

  " 3. 차트 데이터 범위 문자열 생성 (부서명 C열, 실적 E열)
  " 9행(헤더)부터 잡아야 차트 범례가 자동으로 생성됩니다.
  LV_RANGE_STR = |Data_Sheet!$C$9:$C${ LV_CHART_ROW },Data_Sheet!$E$9:$E${ LV_CHART_ROW }|.
  CALL METHOD OF G_EXCEL 'Range' = G_RANGE EXPORTING #1 = LV_RANGE_STR.

  " 4. [중요] 새로운 차트 시트 추가 (Add 메서드 사용)
  CALL METHOD OF G_EXCEL 'Charts' = G_CHART.
  CALL METHOD OF G_CHART 'Add' = G_CHART. " 새로운 차트 시트 생성 및 할당

  " 5. 차트 기본 설정
  SET PROPERTY OF G_CHART 'ChartType' = 51. " xlColumnClustered (묶은 세로 막대형)
  " #1: 범위 객체, #2: 데이터 방향 (1 = 열 기준)
  CALL METHOD OF G_CHART 'SetSourceData' EXPORTING #1 = G_RANGE #2 = 1.
  SET PROPERTY OF G_CHART 'Name' = 'Performance_Chart'. " 차트 탭 이름 설정

  " 6. 차트 제목 설정 (객체 덮어쓰기 방지)
  SET PROPERTY OF G_CHART 'HasTitle' = 1.
  CALL METHOD OF G_CHART 'ChartTitle' = LO_CHART_TITLE. " 별도 객체로 받음
  SET PROPERTY OF LO_CHART_TITLE 'Text' = '실적 TOP 5 부서 분석'.

  " 7. 마무리: 다시 데이터 시트로 돌아오거나 차트를 활성화
  CALL METHOD OF G_CHART 'Activate'.

  " 객체 해제
  FREE OBJECT: G_SHEETS, G_SHEET1, G_CHART, G_RANGE, LO_CHART_TITLE.

ENDFORM.
