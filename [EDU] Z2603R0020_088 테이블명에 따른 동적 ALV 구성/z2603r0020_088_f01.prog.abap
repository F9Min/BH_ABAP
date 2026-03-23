*&---------------------------------------------------------------------*
*& Include          Z2603R0020_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_ITAB
*&---------------------------------------------------------------------*
FORM SET_ITAB .

  DATA : LT_COMP   TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
         LS_COMP   LIKE LINE OF LT_COMP,
         LO_STRUCT TYPE REF TO CL_ABAP_STRUCTDESCR,
         LO_TABLE  TYPE REF TO CL_ABAP_TABLEDESCR.

  " 입력받은 테이블 명 기준으로 type 가져오기
  LO_STRUCT ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( P_TABN ).
  LO_TABLE = CL_ABAP_TABLEDESCR=>CREATE( P_LINE_TYPE = LO_STRUCT ).

  CREATE DATA GT_DATA TYPE HANDLE LO_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM GET_DATA .

  ASSIGN GT_DATA->* TO <FS_TABLE>.

  SELECT *
    FROM (P_TABN)
    WHERE 1 = 1
    INTO CORRESPONDING FIELDS OF TABLE @<FS_TABLE>
   UP TO @P_LINEN ROWS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF <FS_TABLE> IS INITIAL.
    MESSAGE '출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
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

  GS_LAYO-CWIDTH_OPT = 'A'.
  GS_LAYO-ZEBRA = 'X'.
  GS_LAYO-SEL_MODE = 'D'.

  GS_VARIANT-REPORT = SY-REPID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT .
**********************************************************************
* Ver 1.
**********************************************************************
  DATA : LO_TABLE TYPE REF TO CL_ABAP_TABLEDESCR,
         LO_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_COMP  TYPE ABAP_COMPDESCR_TAB,
         LS_COMP  LIKE LINE OF LT_COMP.

  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( <FS_TABLE> ).
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
*    CASE <ls_fcat>-fieldname.
*      WHEN 'CONNID' OR 'CURRENCY'.
*        <ls_fcat>-fix_column = 'X'.
*        <ls_fcat>-key        = 'X'.
*      WHEN OTHERS.
*    ENDCASE.
  ENDLOOP.
**********************************************************************
* Ver 2.
**********************************************************************
*  DATA: LO_SALV TYPE REF TO CL_SALV_TABLE.
*
*  " 1. Display Data를 통해 가상의 SALV 객체를 만듦
*  TRY.
*      CL_SALV_TABLE=>FACTORY(
*        IMPORTING
*          R_SALV_TABLE = LO_SALV
*        CHANGING
*          T_TABLE      = <FS_TABLE> ).
*    CATCH CX_SALV_MSG.
*      " 에러 처리
*  ENDTRY.
*
*  " 2. 가상 SALV 객체에 세팅된 컬럼 정보를 LVC_T_FCAT 타입으로 변환하여 추출
*  GT_FCAT = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
*              R_COLUMNS      = LO_SALV->GET_COLUMNS( )
*              R_AGGREGATIONS = LO_SALV->GET_AGGREGATIONS( ) ).
*
*  " 이제 gt_fcat에는 완벽하게 세팅된 필드 카탈로그가 들어있습니다.
**********************************************************************
* Ver 3.
**********************************************************************
*  DATA : LO_TABLE TYPE REF TO CL_ABAP_TABLEDESCR,
*         LO_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
*         LT_COMP  TYPE ABAP_COMPDESCR_TAB,
*         LS_COMP  LIKE LINE OF LT_COMP,
*         LT_DFIES TYPE DFIES_TAB,
*         LS_DFIES TYPE DFIES,
*         LS_FCAT  TYPE LVC_S_FCAT.
*
*  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( <FS_TABLE> ).
*  LO_STRUC ?= LO_TABLE->GET_TABLE_LINE_TYPE(  ).
*  LT_COMP = LO_STRUC->COMPONENTS.
*
*  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC ).
*
*  CLEAR GT_FCAT.
*  LOOP AT LT_DFIES INTO LS_DFIES.
*    CLEAR LS_FCAT.
*
*    " 이름이 같은 필드들(FIELDNAME, DATATYPE 등)은 자동으로 복사
*    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
*
*    LS_FCAT-KEY        = LS_DFIES-KEYFLAG.
*    LS_FCAT-COLTEXT    = LS_DFIES-FIELDTEXT.
*    LS_FCAT-REF_TABLE  = LS_DFIES-REFTABLE.
*    LS_FCAT-REF_FIELD  = LS_DFIES-REFFIELD.
*    LS_FCAT-CFIELDNAME = LS_DFIES-PRECFIELD. " 통화 필드
*    LS_FCAT-QFIELDNAME = LS_DFIES-PRECFIELD. " 수량 필드
*
*    APPEND LS_FCAT TO GT_FCAT.
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT       " Layout
      I_SAVE                        = GV_SAVE         " Save Layout
      IS_LAYOUT                     = GS_LAYO                 " Layout
    CHANGING
      IT_OUTTAB                     = <FS_TABLE>                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
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
