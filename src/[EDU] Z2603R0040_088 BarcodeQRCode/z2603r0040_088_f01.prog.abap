*&---------------------------------------------------------------------*
*& Include          Z2603R0040_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT K~EBELN,
         P~EBELP,
         P~MATNR,
         T~MAKTX
    FROM EKKO AS K
    JOIN EKPO AS P
      ON K~EBELN EQ P~EBELN
    LEFT OUTER JOIN MAKT AS T
      ON P~MATNR = T~MATNR
     AND T~SPRAS = @SY-LANGU
    WHERE K~EBELN IN @SO_EBELN
    ORDER BY K~EBELN, P~EBELP
    INTO TABLE @GT_DATA.

*  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
*
*    <FS_DATA>-MATNR = |{ <FS_DATA>-MATNR ALPHA = OUT }|.
*    MODIFY GT_DATA FROM <FS_DATA>.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF GT_DATA IS INITIAL.
    MESSAGE '출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    CALL SCREEN 0100.
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

  DATA : LO_TABLE TYPE REF TO CL_ABAP_TABLEDESCR,
         LO_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_COMP  TYPE ABAP_COMPDESCR_TAB,
         LS_COMP  LIKE LINE OF LT_COMP.

  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_DATA ).
  LO_STRUC ?= LO_TABLE->GET_TABLE_LINE_TYPE( ).
  LT_COMP = LO_STRUC->COMPONENTS[].

  GT_FCAT = CORRESPONDING #( CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC )
                             MAPPING KEY       = KEYFLAG
                                     COLTEXT   = FIELDTEXT
                                     REF_TABLE = REFTABLE
                                     REF_FIELD = REFFIELD
                                     CFIELDNAME = PRECFIELD
                                     QFIELDNAME = PRECFIELD ).

  LOOP AT GT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).

    <LS_FCAT>-COL_POS = SY-TABIX.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.

    CASE <LS_FCAT>-FIELDNAME.

      WHEN 'MATNR'.

        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-KEY = 'X'.

    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .
  SET HANDLER LCL_EVENT_HANDLER=>HANDLE_HOTSPOT_CLICK FOR GO_ALV_GRID.
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
      IT_OUTTAB                     = GT_DATA          " Output Table
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
*& Form SHOW_BARCODE
*&---------------------------------------------------------------------*
FORM SHOW_BARCODE USING P_TEXT TYPE C
                        P_TYPE TYPE C
                        PO_PIC TYPE REF TO CL_GUI_PICTURE.

  DATA: LV_XSTRING TYPE XSTRING,
        LV_SIZE    TYPE I,
        LT_DATA    TYPE STANDARD TABLE OF X255,
        LV_URL     TYPE C LENGTH 255,
        LV_STRING  TYPE STRING,
        LX_BARCODE TYPE REF TO CX_RSTX_BARCODE_RENDERER.

  " 1. 파라미터 타입 캐스팅 (Type C -> Type String)
  LV_STRING = P_TEXT.

  " 2. 바코드/QR코드 이미지(XSTRING) 생성
  TRY.
      CASE P_TYPE.
        WHEN 'CODE128'.
          " 1D 바코드 (CODE128)
          CL_RSTX_BARCODE_RENDERER=>CODE_128(
            EXPORTING
              I_NARROW_MODULE_WIDTH = 2          " 바 두께 (1~30 필수)
              I_HEIGHT              = 50         " 바코드 높이 (1~32000 필수)
              I_BARCODE_TEXT        = LV_STRING
            IMPORTING
              E_BITMAP              = LV_XSTRING ).

        WHEN 'QRCODE'.
          " 2D 바코드 (QR 코드) - 캡처 로직 완벽 반영
          CL_RSTX_BARCODE_RENDERER=>QR_CODE(
            EXPORTING
              I_MODULE_SIZE      = 2             " QR 격자 1개의 픽셀 크기 (1 이상 필수)
              I_MODE             = 'U'         " 인코딩 모드 (기본값 'A'가 있으므로 생략 가능)
              " i_error_correction = 'H'         " 에러 복원 레벨 (기본값 'H'가 있으므로 생략 가능)
              I_BARCODE_TEXT     = LV_STRING
            IMPORTING
              E_BITMAP           = LV_XSTRING ).

        WHEN OTHERS.
          RETURN.
      ENDCASE.

    CATCH CX_RSTX_BARCODE_RENDERER INTO LX_BARCODE.
      " 필요한 경우 에러 로그를 남기거나 메시지를 띄움
      RETURN.
  ENDTRY.

  " 생성된 이미지가 없으면 리턴
  IF LV_XSTRING IS INITIAL.
    RETURN.
  ENDIF.

  " 3. XSTRING을 Internal Table로 변환
  LV_SIZE = XSTRLEN( LV_XSTRING ).
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = LV_XSTRING
    IMPORTING
      OUTPUT_LENGTH = LV_SIZE
    TABLES
      BINARY_TAB    = LT_DATA.

  " 4. 화면용 임시 URL 생성 (Subtype 'bmp')
  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      TYPE     = 'image'
      SUBTYPE  = 'bmp'
      SIZE     = LV_SIZE
      LIFETIME = 'T'
    TABLES
      DATA     = LT_DATA
    CHANGING
      URL      = LV_URL.

  " 5. Picture Control에 이미지 로드
  PO_PIC->LOAD_PICTURE_FROM_URL( URL = LV_URL ).
  PO_PIC->SET_DISPLAY_MODE( DISPLAY_MODE = CL_GUI_PICTURE=>DISPLAY_MODE_FIT_CENTER ).

ENDFORM.
