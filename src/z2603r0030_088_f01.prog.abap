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
**********************************************************************
* Ver 1.
**********************************************************************
  DATA : LO_TABLE TYPE REF TO CL_ABAP_TABLEDESCR,
         LO_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_COMP  TYPE ABAP_COMPDESCR_TAB,
         LS_COMP  LIKE LINE OF LT_COMP.

  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_DISPLAY ).
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
*          T_TABLE      = GT_DISPLAY ).
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
*  LO_TABLE ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_DISPLAY ).
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
*
*  ENDLOOP.

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
