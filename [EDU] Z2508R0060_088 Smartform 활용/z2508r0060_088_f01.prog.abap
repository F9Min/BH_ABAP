*&---------------------------------------------------------------------*
*& Include          Z2508R030_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

* DATA SELECTION Based On BUKRS
  SELECT SINGLE B~BUTXT,
                A~TEL_NUMBER,
                A~CITY1,
                A~STREET
    FROM ADRC AS A
    JOIN T001 AS B
      ON B~ADRNR EQ A~ADDRNUMBER
    WHERE B~BUKRS EQ @P_BUKRS
    INTO CORRESPONDING FIELDS OF @GS_COMPANY.

* HEADER DATA SELECTION Based On VBELN
  SELECT SINGLE K~VBELN,                              " 판매오더
                K~KUNNR,                              " 바이어 번호
                A~NAME1,                              " 바이어명
                K~BSTNK,                              " 참조번호
                SUM( P~NETPR * P~KWMENG ) AS NETWR,   " 총액
                K~WAERK,                              " 통화
                K~VDATU,                              " 배송요청일
                D~ZTERM,                              " 지급조건
                D~INCO1                               " 인도조건
    FROM VBAK AS K
    JOIN VBAP AS P
      ON K~VBELN EQ P~VBELN
    JOIN VBKD AS D
      ON K~VBELN EQ D~VBELN
    JOIN KNA1 AS A
      ON K~KUNNR EQ A~KUNNR
    WHERE K~VBELN EQ @P_VBELN
    GROUP BY K~VBELN, K~KUNNR, A~NAME1, K~BSTNK, K~WAERK, K~VDATU, D~ZTERM, D~INCO1
    INTO CORRESPONDING FIELDS OF @GS_HEADER.

  GS_HEADER-PDATE = SY-DATUM. " Enter the current date to indicate the output date

* ITEM DATA SELECTION Based On VBELN
  SELECT P~POSNR,                        " 항번
         P~MATNR,                        " 자재
         T~MAKTX,                        " 자재명
         P~NETPR,                        " 단가
         P~WAERK,                        " 통화
         P~KWMENG,                       " 수량
         P~MEINS,                        " 수량단위
         P~NETPR * P~KWMENG AS AMOUNT,   " 금액
         L~LGOBE                         " 창고명
  FROM VBAP AS P
  LEFT OUTER JOIN MAKT AS T
    ON P~MATNR EQ T~MATNR AND T~SPRAS EQ @SY-LANGU
  LEFT OUTER JOIN T001L AS L
    ON L~LGORT EQ P~LGORT AND L~WERKS EQ P~WERKS
  WHERE P~VBELN EQ @P_VBELN
  ORDER BY P~POSNR
  INTO CORRESPONDING FIELDS OF TABLE @GT_CONTENT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DATA .

  IF GS_COMPANY IS INITIAL.
    " 회사정보에 대한 데이터 정합성 점검
    MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'. " 회사정보가 없습니다.
  ELSE.
    IF GT_CONTENT IS INITIAL.
      " 판매오더에 대한 데이터 정합성 점검
      MESSAGE TEXT-E02 TYPE 'S' DISPLAY LIKE 'E'. " 판매오더 정보가 없습니다.
    ELSE.
      CASE ABAP_ON.
        WHEN P_OLE.
          " OLE 활용해서 EXCEL에 업로드 하는 기능의 SUBROUTINE 작성
          PERFORM OPEN_DOCUMENT.
        WHEN P_SFORM.
          " Smart Form 활용관련 SUBROUTINE
          PERFORM USE_SMARTFORM.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form OPEN_DOCUMENT
*&---------------------------------------------------------------------*
FORM OPEN_DOCUMENT .

  DATA : LV_FILENAME TYPE STRING,
         LV_PATH     TYPE STRING,
         LV_FULLPATH TYPE STRING.

  DATA(LV_DEFAULT_FILE_NAME) = |PO_{ GS_HEADER-VBELN }_{ SY-DATUM }|.

  " Logic to import storage path.
  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
*      DEFAULT_EXTENSION         =   'XLSX'                                       " Default Extensions
      DEFAULT_FILE_NAME         = LV_DEFAULT_FILE_NAME                            " File Name
      " File extension default exit settings (if not entered, show all extensions in a list box)
      " The default extension is fixed to .XLSX only when entered as below.
      FILE_FILTER               = 'Excel files (*.XLS;*.XLSX)|*.XLSX'
      INITIAL_DIRECTORY         = 'C:\Users\bhadm\Desktop'                        " Default Path
    CHANGING
         FILENAME               =   LV_FILENAME                                   " File Name
         PATH                   =   LV_PATH                                       " Directory Path
         FULLPATH               =   LV_FULLPATH                                   " Directory + File Name
    EXCEPTIONS
      CNTL_ERROR                =   1
      ERROR_NO_GUI              =   2
      NOT_SUPPORTED_BY_GUI      =   3
      INVALID_DEFAULT_FILE_NAME =   4
      OTHERS                    =   5
     ).

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE 'E'.
  ENDIF.

  PERFORM SAVE_DOCUMENT USING LV_FULLPATH.  " Download TEMPLATE from SMW0 to the storage path based on directory + filename
  PERFORM INSERT_DATA USING LV_FULLPATH.    " Insert data through OLE into TEMPLATE

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DOCUMENT
*&---------------------------------------------------------------------*
FORM SAVE_DOCUMENT USING LV_FULLPATH.

  DATA : LS_WWWDATA  TYPE WWWDATATAB,
         LV_FILENAME TYPE RLGRAP-FILENAME.

  SELECT SINGLE *
    FROM WWWDATA
   WHERE OBJID = 'Z2508R030_088'  " File name saved by SMW0
    INTO CORRESPONDING FIELDS OF @LS_WWWDATA.

  IF SY-SUBRC = 0. " If you don't have data, you don't have to run logic..

    LV_FILENAME = LV_FULLPATH. " Directory path from above

    " Function that download template from SMW0
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        KEY         = LS_WWWDATA
        DESTINATION = LV_FILENAME.

*    IF SY-SUBRC = 0. " From here on, if you want to download it and run it right away, write it down.
*
*      CL_GUI_FRONTEND_SERVICES=>EXECUTE(
*          EXPORTING
*            DOCUMENT               = LV_FULLPATH
*          EXCEPTIONS
*            CNTL_ERROR             = 1
*            ERROR_NO_GUI           = 2
*            BAD_PARAMETER          = 3
*            FILE_NOT_FOUND         = 4
*            PATH_NOT_FOUND         = 5
*            FILE_EXTENSION_UNKNOWN = 6
*            ERROR_EXECUTE_FAILED   = 7
*            SYNCHRONOUS_FAILED     = 8
*            NOT_SUPPORTED_BY_GUI   = 9
*            OTHERS                 = 10
*        ).
*
*      IF SY-SUBRC <> 0.
*        MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
*          DISPLAY LIKE 'E'.
*      ENDIF.
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_DATA
*&---------------------------------------------------------------------*
FORM INSERT_DATA  USING PV_FULLPATH TYPE STRING.

  DATA : LV_APPLICATION TYPE OLE2_OBJECT,
         LV_WORKBOOK    TYPE OLE2_OBJECT,
         LV_WORKSHEET   TYPE OLE2_OBJECT,
         LV_COLS        TYPE OLE2_OBJECT,
         LV_NAME        TYPE STRING,
         LS_EXCEL       TYPE C LENGTH 1500,
         LT_EXCEL       LIKE TABLE OF LS_EXCEL,
         DELI           TYPE C,
         LV_RC          TYPE I,
         W_CELL1        TYPE OLE2_OBJECT.

  FIELD-SYMBOLS : <FS_HEADER>,
                  <FS_COMPANY>.

*&---------------------------------------------------------------------*
*& Macro Definition
*&---------------------------------------------------------------------*
  DEFINE __SET_HEADER.
    ASSIGN COMPONENT &1 OF STRUCTURE GS_HEADER TO <FS_HEADER>.

    IF SY-SUBRC EQ 0.
      CALL METHOD OF LV_WORKSHEET 'CELLS' = W_CELL1
        EXPORTING
          #1 = &2    " Row
          #2 = &3.   " Column

      CASE &1.
        WHEN 'VBELN' or 'KUNNR' or 'BSTNK' or 'PDATE'or 'VDATU' or 'ZTERM' or 'INCO1'.
          SET PROPERTY OF W_CELL1 'HORIZONTALALIGNMENT' = 2.
      ENDCASE.

      CALL METHOD OF W_CELL1 'SELECT'.

      SET PROPERTY OF W_CELL1 'VALUE' = <FS_HEADER>.
    ENDIF.

    UNASSIGN <FS_HEADER>.

  END-OF-DEFINITION.

  DEFINE __SET_COMPANY.
    ASSIGN COMPONENT &1 OF STRUCTURE GS_COMPANY TO <FS_COMPANY>.

    IF SY-SUBRC EQ 0.
      CALL METHOD OF LV_WORKSHEET 'CELLS' = W_CELL1
        EXPORTING
          #1 = &2    " Row
          #2 = &3.   " Column

      CALL METHOD OF W_CELL1 'SELECT'.

      SET PROPERTY OF W_CELL1 'VALUE' = <FS_COMPANY>.
    ENDIF.

    UNASSIGN <FS_COMPANY>.

  END-OF-DEFINITION.

* 1. OLE Activate When Template Exists
  CREATE OBJECT LV_APPLICATION 'EXCEL.APPLICATION'.

  CALL METHOD OF LV_APPLICATION 'WORKBOOKS' = LV_WORKBOOK.
  CALL METHOD OF LV_WORKBOOK 'OPEN' = LV_WORKBOOK
    EXPORTING
      #1 = PV_FULLPATH.

* 2. WorkSheet Activate
  GET PROPERTY OF LV_APPLICATION 'ACTIVESHEET' = LV_WORKSHEET.

  LV_NAME = 'PO No.' && P_VBELN && ' Info'.
  SET PROPERTY OF LV_WORKSHEET 'Name' = LV_NAME.  " LV_WORKSHEET의 이름을 변경

  SET PROPERTY OF LV_APPLICATION 'VISIBLE' = 1.

  PERFORM CHECK_ADD_ROWS USING LV_WORKSHEET.  " 라인수를 체크해서 행 추가하는 Subroutine

  DELI = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

  LOOP AT GT_CONTENT ASSIGNING FIELD-SYMBOL(<FS_CONTENT>).

    WRITE <FS_CONTENT>-NETPR CURRENCY <FS_CONTENT>-WAERK TO <FS_CONTENT>-NETPR_CUR.
    WRITE <FS_CONTENT>-AMOUNT CURRENCY <FS_CONTENT>-WAERK TO <FS_CONTENT>-AMOUNT_CUR.
    WRITE <FS_CONTENT>-KWMENG UNIT <FS_CONTENT>-MEINS TO <FS_CONTENT>-KWMENG_QUA.

    LS_EXCEL = |{ <FS_CONTENT>-POSNR } {
DELI } { <FS_CONTENT>-MATNR } { DELI } { <FS_CONTENT>-MAKTX } { DELI } { <FS_CONTENT>-NETPR_CUR } { DELI } { <FS_CONTENT>-WAERK } { DELI } { <FS_CONTENT>-KWMENG_QUA } { DELI } { <FS_CONTENT>-MEINS } { DELI } { <FS_CONTENT>-AMOUNT_CUR } { DELI } {
<FS_CONTENT>-LGOBE
}|.

    APPEND LS_EXCEL TO LT_EXCEL.
    CLEAR : LS_EXCEL.

  ENDLOOP.

* 3. Copy the content of ITAB at Clipboard
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
    EXPORTING
      NO_AUTH_CHECK        = 'X'              " Switch off Check for Access Rights
    IMPORTING
      DATA                 = LT_EXCEL         " Data
    CHANGING
      RC                   = LV_RC            " Return Code
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

* 4. Select Cell
  CALL METHOD OF LV_WORKSHEET 'CELLS' = W_CELL1
    EXPORTING
      #1 = 16   " Row
      #2 = 2.   " Column

  CALL METHOD OF W_CELL1 'SELECT'.

* 5. Paste the content of Clipboard to Selected Cell
  CALL METHOD OF LV_WORKSHEET 'PASTE'.
*&---------------------------------------------------------------------*
*& Company Data Setting
*&---------------------------------------------------------------------*
  __SET_COMPANY : 'BUTXT' 5 5,
                  'TEL_NUMBER' 6 5.

* Save Logic of Address Info : CITY1 FIELD + STREET
  CALL METHOD OF LV_WORKSHEET 'CELLS' = W_CELL1
    EXPORTING
      #1 = 7    " Row
      #2 = 5.   " Column

  CALL METHOD OF W_CELL1 'SELECT'.

  DATA(LV_ADDRESS) = |{ GS_COMPANY-CITY1 } { GS_COMPANY-STREET }|.
  SET PROPERTY OF W_CELL1 'VALUE' = LV_ADDRESS.

  WRITE GS_HEADER-NETWR CURRENCY GS_HEADER-WAERK TO GS_HEADER-NETWR_CUR.
  CONDENSE GS_HEADER-NETWR_CUR NO-GAPS.
  GS_HEADER-NETWR_CUR = |{ GS_HEADER-NETWR_CUR } { GS_HEADER-WAERK }|.

  GS_HEADER-KUNNR = |{ GS_HEADER-KUNNR ALPHA = OUT }|.
  GS_HEADER-BUYER = |{ GS_HEADER-KUNNR }( { GS_HEADER-NAME1 } )|.

*&---------------------------------------------------------------------*
*& Header Data Setting
*&---------------------------------------------------------------------*
  __SET_HEADER : 'VBELN'     10 3,
                 'BUYER'     11 3,
                 'BSTNK'     12 3,
                 'PDATE'     13 3,
                 'NETWR_CUR' 10 6,
                 'VDATU'     11 6,
                 'ZTERM'     12 6,
                 'INCO1'     13 6.

  CALL METHOD OF LV_WORKSHEET 'Columns' = LV_COLS.
  CALL METHOD OF LV_COLS 'AutoFit'.

  PERFORM FIT_COLUMN_WIDTH USING LV_WORKSHEET LV_COLS 'D' 'D' 40 'I'.
  PERFORM FIT_COLUMN_WIDTH USING LV_WORKSHEET LV_COLS 'E' 'E' 15 'D'.

* Save Final File to Template Save Path
  CALL METHOD OF LV_WORKBOOK 'SaveAs'
    EXPORTING
      #1 = PV_FULLPATH
      " If you give it as 1, it is automatically saved in the form of .xls when saved.
      " If you give it as 51, it can be saved as xlsx. (Regardless of file extension)
      #2 = 51.

  IF P_PDF EQ ABAP_ON.
    DATA : LV_PDF_PATH  TYPE STRING,
           LO_PAGESETUP TYPE OLE2_OBJECT.

    LV_PDF_PATH = PV_FULLPATH.

    " 1) 페이지 방향 설정
    GET PROPERTY OF LV_WORKSHEET 'PageSetup' = LO_PAGESETUP.
    SET PROPERTY OF LO_PAGESETUP 'Orientation' = 2.  " Landscape
*    SET PROPERTY OF LO_PAGESETUP 'Zoom' = ABAP_FALSE.

* FitToPagesWide, FitToPagesTall can be set to {1,0} in the back.
    CALL METHOD OF LV_APPLICATION 'ExecuteExcel4Macro'
      EXPORTING
        #1 = 'PAGE.SETUP(,,,,,,,,,,,,{1,0})'.

    " 2) Save as PDF
    IF LV_PDF_PATH CP '*.xls*'.
      REPLACE REGEX '\.xlsx?$' IN LV_PDF_PATH WITH '.pdf' IGNORING CASE.
    ELSE.
      LV_PDF_PATH = PV_FULLPATH &&'.pdf'.
    ENDIF.

    CALL METHOD OF LV_WORKBOOK 'ExportAsFixedFormat'
      EXPORTING
        #1 = 0              " Type: 0 = xlTypePDF
        #2 = LV_PDF_PATH.   " Filename
  ENDIF.

* Workbook closing logic
*  CALL METHOD OF LV_WORKBOOK 'Close'.
*  CALL METHOD OF LV_APPLICATION 'Quit'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ADD_ROWS
*&---------------------------------------------------------------------*
FORM CHECK_ADD_ROWS USING PV_WORKSHEET TYPE OLE2_OBJECT.

  DESCRIBE TABLE GT_CONTENT LINES DATA(LV_LINES).

  IF LV_LINES > 11.

    DATA: LV_TIMES TYPE I,            " Number of rows to insert
          LV_ROW   TYPE I VALUE 17,   " Insertion start position
          LV_SPEC  TYPE STRING,
          GO_ROWS  TYPE OLE2_OBJECT.  " Rows Object

    LV_TIMES = LV_LINES - 11.
    LV_SPEC  = |{ LV_ROW }:{ LV_ROW + LV_TIMES - 1 }|.

    " Insert before line 17 (slides down)
    CALL METHOD OF PV_WORKSHEET 'Rows' = GO_ROWS
      EXPORTING #1 = LV_SPEC.
    CALL METHOD OF GO_ROWS 'Insert'.

    " Range the area you just inserted
    DATA: GO_RNG     TYPE OLE2_OBJECT,
          GO_BORDERS TYPE OLE2_OBJECT.

    DATA(START) = |B{ LV_ROW }|.
    DATA(END)   = |J{ LV_ROW + LV_TIMES - 1 }|.

    CALL METHOD OF PV_WORKSHEET 'Range' = GO_RNG
      EXPORTING
        #1 = START
        #2 = END.

    " Show border line
    DO 5 TIMES.
      DATA(LV_NUM) = SY-INDEX + 6.
      CALL METHOD OF GO_RNG 'Borders' = GO_BORDERS EXPORTING #1 = LV_NUM.
      SET PROPERTY OF GO_BORDERS 'LineStyle' = 1.
    ENDDO.

  ELSE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_UPLOAD
*&---------------------------------------------------------------------*
FORM EXCEL_UPLOAD .

  CALL TRANSACTION 'SMW0'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIT_COLUMN_WIDTH
*&---------------------------------------------------------------------*
FORM FIT_COLUMN_WIDTH  USING PV_WORKSHEET TYPE OLE2_OBJECT
                             PV_COLS      TYPE OLE2_OBJECT
                             PV_START_COL TYPE C
                             PV_END_COL   TYPE C
                             PV_WIDTH     TYPE I
                             PV_MODE      TYPE C.

  DATA : LV_RANGE_S TYPE STRING,
         LV_RANGE   TYPE OLE2_OBJECT,
         LV_CNT     TYPE I,
         LV_COL     TYPE OLE2_OBJECT,
         LV_WIDTH   TYPE F.

  LV_RANGE_S = |${ PV_START_COL }:${ PV_END_COL }|.

  CALL METHOD OF PV_WORKSHEET 'RANGE' = LV_RANGE
    EXPORTING
      #1 = LV_RANGE_S.

  GET PROPERTY OF LV_RANGE 'ENTIRECOLUMN' = PV_COLS.

  GET PROPERTY OF PV_COLS 'COUNT' = LV_CNT.

  DO LV_CNT TIMES.
    CALL METHOD OF PV_COLS 'ITEM' = LV_COL EXPORTING #1 = SY-INDEX.
    GET PROPERTY OF LV_COL 'COLUMNWIDTH' = LV_WIDTH.
    CASE PV_MODE.
      WHEN 'I'.
        IF LV_WIDTH LT PV_WIDTH.
          SET PROPERTY OF LV_COL 'COLUMNWIDTH' = PV_WIDTH.
        ENDIF.
      WHEN 'D'.
        IF LV_WIDTH GT PV_WIDTH.
          SET PROPERTY OF LV_COL 'COLUMNWIDTH' = PV_WIDTH.
        ENDIF.
    ENDCASE.
  ENDDO.

  CALL FUNCTION 'CONTROL_FLUSH'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USE_SMARTFORM
*&---------------------------------------------------------------------*
FORM USE_SMARTFORM .

  DATA : LV_FORMNAME TYPE TDSFNAME.

*&---------------------------------------------------------------------*
*& GET SMARTFORM FUNCTION NAME
*&---------------------------------------------------------------------*
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZEDUSF0020_088'  " Form name
    IMPORTING
      FM_NAME            = LV_FORMNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*&---------------------------------------------------------------------*
*& HEADER DATA MODIFICATION
*&---------------------------------------------------------------------*
  WRITE GS_HEADER-NETWR CURRENCY GS_HEADER-WAERK TO GS_HEADER-NETWR_CUR.
  CONDENSE GS_HEADER-NETWR_CUR NO-GAPS.
  GS_HEADER-NETWR_CUR = |{ GS_HEADER-NETWR_CUR } { GS_HEADER-WAERK }|.

  GS_HEADER-KUNNR = |{ GS_HEADER-KUNNR ALPHA = OUT }|.
  GS_HEADER-BUYER = |{ GS_HEADER-KUNNR }( { GS_HEADER-NAME1 } )|.

*&---------------------------------------------------------------------*
*& ITEM DATA MODIFICATION
*&---------------------------------------------------------------------*
  LOOP AT GT_CONTENT ASSIGNING FIELD-SYMBOL(<FS_CONTENT>).

    WRITE <FS_CONTENT>-NETPR CURRENCY <FS_CONTENT>-WAERK TO <FS_CONTENT>-NETPR_CUR.
    WRITE <FS_CONTENT>-AMOUNT CURRENCY <FS_CONTENT>-WAERK TO <FS_CONTENT>-AMOUNT_CUR.
    WRITE <FS_CONTENT>-KWMENG UNIT <FS_CONTENT>-MEINS TO <FS_CONTENT>-KWMENG_QUA.

    CONDENSE <FS_CONTENT>-NETPR_CUR NO-GAPS.
    CONDENSE <FS_CONTENT>-AMOUNT_CUR NO-GAPS.
    CONDENSE <FS_CONTENT>-KWMENG_QUA NO-GAPS.

  ENDLOOP.

*&---------------------------------------------------------------------*
*& CALL SMARTFORM FUNCTION
*&---------------------------------------------------------------------*
  CALL FUNCTION LV_FORMNAME
    EXPORTING
      IS_HEADER        = GS_HEADER
      IS_COMPANY       = GS_COMPANY
      IT_ITEM          = GT_CONTENT
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      USER_CANCELED    = 4
      OTHERS           = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN
*&---------------------------------------------------------------------*
FORM INIT_SCREEN .

  CASE ABAP_ON.
    WHEN P_SFORM.
      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'G1'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_VBELN
*&---------------------------------------------------------------------*
FORM CHECK_VBELN .

  IF P_VBELN IS INITIAL.
    MESSAGE TEXT-E03 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

ENDFORM.
