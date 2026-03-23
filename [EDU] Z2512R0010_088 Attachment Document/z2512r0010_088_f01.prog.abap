*&---------------------------------------------------------------------*
*& Include          Z2512R0010_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INITAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITAL_VALUE .

  S_BUKRS-LOW = 1000.
  APPEND S_BUKRS.

  S_GJAHR-LOW = 2024.
  APPEND S_GJAHR.

  S_MONAT-LOW = 05.
  APPEND S_MONAT.

  S_BELNR-LOW = 1900000007.
  APPEND S_BELNR.

  S_USNAM-LOW = 'S4H0**'.
  APPEND S_USNAM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM GET_DATA .

  SELECT FROM      BKPF  AS F
   INNER JOIN      USR21 AS U ON F~USNAM = U~BNAME
   LEFT OUTER JOIN ADRP  AS A ON U~PERSNUMBER = A~PERSNUMBER
   LEFT OUTER JOIN DD07T AS T ON F~BSTAT = T~DOMVALUE_L
                             AND T~DDLANGUAGE = @SY-LANGU
                             AND T~DOMNAME = 'BSTAT'
  FIELDS F~BUKRS,       " Company Code
         F~BELNR,       " Document No.
         F~GJAHR,       " Fiscal Year
         F~USNAM,       " User Name
         A~NAME_TEXT,   " User Name Text
         F~BLART,       " Document Type
         F~BLDAT,       " Document Date
         F~BUDAT,       " Posting Date
                        " Attachment
         F~BSTAT,       " Document Status
         T~DDTEXT       " Document Status Text ( BSTAT의 Fixed Value )
   WHERE BUKRS    IN @S_BUKRS
     AND F~GJAHR  IN @S_GJAHR
     AND F~MONAT  IN @S_MONAT
     AND F~BELNR  IN @S_BELNR
     AND F~USNAM  IN @S_USNAM
     AND F~BSTAT  EQ 'V'
     AND F~BLART  EQ 'KR'
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

  LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>).

    <FS_DISPLAY>-ATTACH = ICON_GOS_SERVICES.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF GT_DISPLAY IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E'.
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

  DATA : LV_COL_POS TYPE LVC_S_FCAT-COL_POS.

  CLEAR : LV_COL_POS.
  LV_COL_POS = 10.

*BUKRS     TYPE BKPF-BUKRS,       " Company Code
*BELNR     TYPE BKPF-BELNR,       " Document No.
*GJAHR     TYPE BKPF-GJAHR,       " Fiscal Year
*USNAM     TYPE BKPF-USNAM,       " User Name
*NAME_TEXT TYPE ADRP-NAME_TEXT,   " User Name Text
*BLART     TYPE BKPF-BLART,       " Document Type
*BLDAT     TYPE BKPF-BLDAT,       " Document Date
*BUDAT     TYPE BKPF-BUDAT,       " Posting Date
*ATTACH    TYPE ICON-ID,          " Attachment
*BSTAT     TYPE BKPF-BSTAT,       " Document Status
*DDTEXT    TYPE DD07T-DDTEXT,     " Document Status Text ( BSTAT의 Fixed Value )

  PERFORM SET_FIELD_CATALOG USING : 'BUKRS'     ABAP_ON 'Company Code'         'BKPF'  'BUKRS'     CHANGING LV_COL_POS,
                                    'BELNR'     ABAP_ON 'Document No.'         'BKPF'  'BELNR'     CHANGING LV_COL_POS,
                                    'GJAHR'     SPACE   'Fiscal Year'          'BKPF'  'GJAHR'     CHANGING LV_COL_POS,
                                    'USNAM'     SPACE   'User Name'            'BKPF'  'BUKRS'     CHANGING LV_COL_POS,
                                    'NAME_TEXT' SPACE   'User Name Text'       'ADRP'  'NAME_TEXT' CHANGING LV_COL_POS,
                                    'BLART'     SPACE   'Document Type'        'BKPF'  'BLART'     CHANGING LV_COL_POS,
                                    'BLDAT'     SPACE   'Document Date'        'BKPF'  'BLDAT'     CHANGING LV_COL_POS,
                                    'BUDAT'     SPACE   'Posting Date'         'BKPF'  'BUDAT'     CHANGING LV_COL_POS,
                                    'ATTACH'    SPACE   'Attachment'           SPACE   'ATTACH'    CHANGING LV_COL_POS,
                                    'BSTAT'     SPACE   'Document Status'      'BKPF'  'BSTAT'     CHANGING LV_COL_POS,
                                    'DDTEXT'    SPACE   'Document Status Text' 'DD07T' 'DDTEXT'    CHANGING LV_COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .

  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID.

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
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG  USING PV_FIELDNAME
                              PV_KEY
                              PV_COLTEXT
                              PV_REF_TABLE
                              PV_REF_FIELD
                     CHANGING PV_COL_POS.

  DATA(LS_FCAT) = VALUE LVC_S_FCAT( FIELDNAME = PV_FIELDNAME
                                  KEY = PV_KEY
                                  COL_POS = PV_COL_POS
                                  COLTEXT = PV_COLTEXT
                                  REF_TABLE = PV_REF_TABLE
                                  REF_FIELD = PV_REF_FIELD
                                 ).

  CASE PV_FIELDNAME.
    WHEN 'ATTACH'.
      LS_FCAT-HOTSPOT = ABAP_ON.
  ENDCASE.

  APPEND LS_FCAT TO GT_FCAT.
  PV_COL_POS += 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DOC
*&---------------------------------------------------------------------*
FORM DISPLAY_DOC .

  DATA : LT_ROWS TYPE LVC_T_ROW,
         LS_ROW  LIKE LINE OF LT_ROWS.

  CALL METHOD GO_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS.                 " Indexes of Selected Rows

  DESCRIBE TABLE LT_ROWS LINES DATA(LV_ROWS_NUM).

  IF LV_ROWS_NUM NE 1.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ELSE.

    READ TABLE LT_ROWS INTO LS_ROW INDEX 1.

    IF LS_ROW-ROWTYPE IS NOT INITIAL.
      MESSAGE S002 DISPLAY LIKE 'E'.
    ELSE.

      READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) INDEX LS_ROW-INDEX.

      SET PARAMETER ID 'BLN' FIELD LS_DISPLAY-BELNR.
      SET PARAMETER ID 'BUK' FIELD LS_DISPLAY-BUKRS.
      SET PARAMETER ID 'GJR' FIELD LS_DISPLAY-GJAHR.

      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
*      CALL TRANSACTION 'FB03'.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ATTACH_DOC
*&---------------------------------------------------------------------*
FORM ATTACH_DOC USING PS_DISPLAY TYPE TS_DISPLAY.

  DATA : LS_OBJECT TYPE SIBFLPORB,
         LV_SAVE   TYPE SGS_FLAG.

  DATA(LV_KEY) = PS_DISPLAY-BUKRS && PS_DISPLAY-BELNR && PS_DISPLAY-GJAHR.

  LS_OBJECT-INSTID = LV_KEY.
  LS_OBJECT-TYPEID = 'BKPF'.
  LS_OBJECT-CATID = 'BO'.

  CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
    EXPORTING
      IS_OBJECT       = LS_OBJECT         " Local Persistent Object Reference (LPOR) - BOR Compatible
      IP_CHECK_ARL    = ' '
      IP_CHECK_BDS    = ' '
      IP_NOTES        = ' '              " Display notes
      IP_ATTACHMENTS  = 'X'              " Display attachments
      IP_URLS         = ' '
      IP_MODE         = 'C'
    IMPORTING
      EP_SAVE_REQUEST = LV_SAVE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    P_COLUMN_ID
                             P_ROW_ID.

  DATA : LT_CELL TYPE LVC_T_CELL,
         LS_CELL LIKE LINE OF LT_CELL.


  CALL METHOD GO_ALV_GRID->GET_SELECTED_CELLS
    IMPORTING
      ET_CELL = LT_CELL.                 " Selected Cells

  DESCRIBE TABLE LT_CELL LINES DATA(LV_CELL_NUM).

  IF LV_CELL_NUM NE 1.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ELSE.

    READ TABLE LT_CELL INTO LS_CELL INDEX 1.
    READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) INDEX LS_CELL-ROW_ID.
    PERFORM ATTACH_DOC USING LS_DISPLAY.

  ENDIF.

ENDFORM.
