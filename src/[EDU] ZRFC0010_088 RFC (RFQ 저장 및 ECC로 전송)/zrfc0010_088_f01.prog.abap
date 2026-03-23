*&---------------------------------------------------------------------*
*& Include          ZRFC0010_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  DATA : LR_SENT TYPE RANGE OF C,
         LS_SENT LIKE LINE OF LR_SENT.

  CASE ABAP_ON.
    WHEN P_NSENT.
      LS_SENT-LOW = SPACE.
      LS_SENT-OPTION = 'EQ'.
      LS_SENT-SIGN = 'I'.
    WHEN P_SENT.
      LS_SENT-LOW = SPACE.
      LS_SENT-OPTION = 'EQ'.
      LS_SENT-SIGN = 'E'.
  ENDCASE.

  APPEND LS_SENT TO LR_SENT.

  SELECT P~RFQNO,                 " RFQNO  TYPE ZMMT0520_088-RFQNO,
         P~RFQSQ,                 " RFQSQ  TYPE ZMMT0520_088-RFQSQ,
         P~RFQDT,                 " RFQDT  TYPE ZMMT0520_088-RFQDT,
         T~DLVDT,                 " DLVDT  TYPE ZMMT0510_088-DLVDT,
         P~MATNR,                 " MATNR  TYPE ZMMT0520_088-MATNR,
         P~MENGE,                 " MENGE  TYPE ZMMT0520_088-MENGE,
         P~NETPR,                 " NETPR  TYPE ZMMT0520_088-NETPR,
         P~NETWR,                 " NETWR  TYPE ZMMT0520_088-NETWR,
         P~MEINS,                 " MEINS  TYPE ZMMT0520_088-MEINS,
         P~WAERS,                 " WAERS  TYPE ZMMT0520_088-WAERS,
         T~ZIFFLG,                " ZIFFLG TYPE ZMMT0510_088-ZIFFLG,
         T~ZIFDAT,                " ZIFDAT TYPE ZMMT0510_088-ZIFDAT,
         T~ZIFTIM                 " ZIFTIM TYPE ZMMT0510_088-ZIFTIM,
    FROM ZMMT0510_088 AS T
    JOIN ZMMT0520_088 AS P
      ON T~RFQNO  EQ P~RFQNO
   WHERE P~RFQDT  IN @S_RFQDT
     AND P~RFQNO  IN @S_RFQNO
     AND T~ZIFFLG IN @LR_SENT
   ORDER BY P~RFQNO, P~RFQSQ
    INTO TABLE @DATA(LT_DATA).

  PERFORM MODIFY_DATA USING LT_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
FORM MODIFY_DATA  USING PT_DATA TYPE TY_DATA.

  MOVE-CORRESPONDING PT_DATA TO GT_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
FORM CALL_SCREEN .

  CALL SCREEN 0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
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
      I_PARENT          = GO_DOCKING        " Parent Container
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
  GS_LAYO-STYLEFNAME = 'CELLSTYL'.

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

  PERFORM SET_FIELD_CATALOG USING : 'CHECK'  SPACE   'Check'           SPACE          SPACE    CHANGING LV_COL_POS,
                                    'RFQNO'  ABAP_ON 'RFQ Number'      'ZMMT0510_088' 'RFQNO'  CHANGING LV_COL_POS,
                                    'RFQSQ'  ABAP_ON 'RFQ Line Number' 'ZMMT0520_088' 'RFQSQ'  CHANGING LV_COL_POS,
                                    'RFQDT'  SPACE   'RFQ 생성일'      'ZMMT0520_088' 'RFQDT'  CHANGING LV_COL_POS,
                                    'DLVDT'  SPACE   '배송 요청일'     'ZMMT0510_088' 'DLVDT'  CHANGING LV_COL_POS,
                                    'MATNR'  SPACE   '제품 코드'       'ZMMT0520_088' 'MATNR'  CHANGING LV_COL_POS,
                                    'MENGE'  SPACE   '수량'            'ZMMT0520_088' 'MENGE'  CHANGING LV_COL_POS,
                                    'NETPR'  SPACE   '단가'            'ZMMT0520_088' 'NETPR'  CHANGING LV_COL_POS,
                                    'NETWR'  SPACE   '금액'            'ZMMT0520_088' 'NETWR'  CHANGING LV_COL_POS,
                                    'MEINS'  SPACE   '수량 단위'       'ZMMT0520_088' 'MEINS'  CHANGING LV_COL_POS,
                                    'WAERS'  SPACE   '금액 단위'       'ZMMT0520_088' 'WAERS'  CHANGING LV_COL_POS,
                                    'ZIFFLG' SPACE   '전송 Flag'       'ZMMT0520_088' 'ZIFFLG' CHANGING LV_COL_POS,
                                    'ZIFDAT' SPACE   '전송 Date'       'ZMMT0520_088' 'ZIFDAT' CHANGING LV_COL_POS,
                                    'ZIFTIM' SPACE   '전송 Time'       'ZMMT0520_088' 'ZIFTIM' CHANGING LV_COL_POS.

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

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = VALUE #( ROW = ABAP_ON COL = ABAP_ON )    " With Stable Rows/Columns
    EXCEPTIONS
      FINISHED  = 1                                         " Display was Ended (by Export)
      OTHERS    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG  USING    VALUE(PV_FIELDNAME)
                                 PV_KEY
                                 VALUE(PV_COLTEXT)
                                 VALUE(PV_REF_TABLE)
                                 VALUE(PV_REF_FIELD)
                        CHANGING PV_COL_POS.

  DATA(LS_FCAT) = VALUE LVC_S_FCAT( FIELDNAME = PV_FIELDNAME
                                    KEY = PV_KEY
                                    COL_POS = PV_COL_POS
                                    COLTEXT = PV_COLTEXT
                                    REF_TABLE = PV_REF_TABLE
                                    REF_FIELD = PV_REF_FIELD
                                 ).

  CASE PV_FIELDNAME.
    WHEN 'CHECK'.
      LS_FCAT-CHECKBOX = ABAP_ON.
      IF P_NSENT EQ ABAP_ON.
        LS_FCAT-EDIT = ABAP_ON.
      ENDIF.
    WHEN 'NETPR'.
      LS_FCAT-CFIELDNAME = 'WAERS'.
      IF P_NSENT EQ ABAP_ON.
        LS_FCAT-EDIT = ABAP_ON.
      ENDIF.
    WHEN 'NETWR'.
      LS_FCAT-CFIELDNAME = 'WAERS'.
    WHEN 'MENGE'.
      LS_FCAT-QFIELDNAME = 'MEINS'.
      IF P_NSENT EQ ABAP_ON.
        LS_FCAT-EDIT = ABAP_ON.
      ENDIF.
    WHEN 'RFQDT' OR 'DLVDT' OR 'MATNR' OR 'MEINS' OR 'WAERS'.
      IF P_NSENT EQ ABAP_ON.
        LS_FCAT-EDIT = ABAP_ON.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  APPEND LS_FCAT TO GT_FCAT.
  PV_COL_POS = PV_COL_POS + 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_LINES
*&---------------------------------------------------------------------*
FORM ADD_LINES .

  CLEAR : GS_DISPLAY.
  GS_DISPLAY-RFQDT = SY-DATUM.
  APPEND GS_DISPLAY TO GT_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_RFQ
*&---------------------------------------------------------------------*
FORM SAVE_RFQ .
  DATA : LT_REQUIRED_FIELDS TYPE STANDARD TABLE OF FIELDNAME,
         LV_INITIAL_FOUND,
         LV_RFQNO_EXIST,
         LV_SAVE_FLAG,
         LV_NUM             TYPE NUMC4.

  LT_REQUIRED_FIELDS = VALUE #( ( 'RFQNO' ) ( 'RFQDT' ) ( 'DLVDT' ) ( 'MATNR' ) ( 'MENGE' ) ( 'NETPR' ) ( 'NETWR' ) ( 'MEINS' ) ( 'WAERS' )  ).
  LV_SAVE_FLAG = 'X'.

  LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>)
    WHERE CHECK EQ ABAP_ON.

    LOOP AT LT_REQUIRED_FIELDS INTO DATA(LV_FIELDNAME).

      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <FS_DISPLAY> TO FIELD-SYMBOL(<FS_ITEM_VALID>).

      IF LV_FIELDNAME EQ 'RFQNO'.
        IF SY-SUBRC EQ 0 AND <FS_ITEM_VALID> IS NOT INITIAL.
          LV_RFQNO_EXIST = ABAP_ON.
          EXIT.  " 필수 파라미터가 누락된 경우
        ENDIF.
      ELSE.
        IF SY-SUBRC EQ 0 AND <FS_ITEM_VALID> IS INITIAL.
          LV_INITIAL_FOUND = ABAP_ON.
          EXIT.  " 필수 파라미터가 누락된 경우
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF LV_RFQNO_EXIST EQ ABAP_ON.
      MESSAGE '저장되지 않은 데이터만 선택해주세요' TYPE 'E'.
      CLEAR : LV_RFQNO_EXIST.
      RETURN.
    ELSE.
      IF LV_INITIAL_FOUND EQ ABAP_ON.
        MESSAGE '입력 가능한 모든 데이터를 입력해주세요.' TYPE 'E'.
        CLEAR : LV_INITIAL_FOUND.
        RETURN.
      ELSE.

        " LOOP의 WHERE 조건에 의해 ITAB의 첫 행이 SKIP 되는 경우 AT FIRST 구문 사용 불가.
        IF LV_SAVE_FLAG EQ 'X'.
          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              NR_RANGE_NR             = '01'             " Number range number
              OBJECT                  = 'ZNRRFQ_088'     " Name of number range object
            IMPORTING
              NUMBER                  = LV_NUM           " Return code
            EXCEPTIONS
              INTERVAL_NOT_FOUND      = 1                " Interval not found
              NUMBER_RANGE_NOT_INTERN = 2                " Number range is not internal
              OBJECT_NOT_FOUND        = 3                " Object not defined in TNRO
              QUANTITY_IS_0           = 4                " Number of numbers requested must be > 0
              QUANTITY_IS_NOT_1       = 5                " Number of numbers requested must be 1
              INTERVAL_OVERFLOW       = 6                " Interval used up. Change not possible.
              BUFFER_OVERFLOW         = 7                " Buffer is full
              OTHERS                  = 8.

          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          DATA(LV_RFQNO) = SY-DATUM+2(6) && LV_NUM.
          DATA(LV_RFQSQ) = 10.
          CLEAR : LV_SAVE_FLAG.
        ENDIF.

        <FS_DISPLAY>-RFQNO = LV_RFQNO.
        <FS_DISPLAY>-RFQSQ = LV_RFQSQ.

        LV_RFQSQ = LV_RFQSQ + 10.

*     헤더 정보 생성
        MOVE-CORRESPONDING <FS_DISPLAY> TO GS_RFQ_H.
        GS_RFQ_H-LIFNR = 'ECC'.
        GS_RFQ_H-ERDAT = SY-DATUM.
        GS_RFQ_H-CHDAT = SY-DATUM.

*     아이템 정보 생성
        MOVE-CORRESPONDING <FS_DISPLAY> TO GS_RFQ_I.
        APPEND GS_RFQ_I TO GT_RFQ_I.

      ENDIF.
    ENDIF.

  ENDLOOP.

  INSERT INTO ZMMT0510_088 VALUES GS_RFQ_H .

  IF SY-SUBRC NE 0.
    MESSAGE '헤더 데이터 저장에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    ROLLBACK WORK.
    RETURN.
  ELSE.
    INSERT ZMMT0520_088 FROM TABLE GT_RFQ_I .

    IF SY-SUBRC NE 0.
      MESSAGE '아이템 데이터 저장에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SELECT_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_RFQ
*&---------------------------------------------------------------------*
FORM SEND_RFQ .

  DATA : BEGIN OF LS_HEAD,
           RFQNO TYPE ZMMT0510_088-RFQNO,
           LFDAT TYPE ZMMT0510_088-DLVDT,
           RFQDT TYPE ZMMT0520_088-RFQDT,
         END OF LS_HEAD.

  DATA : BEGIN OF LS_ITEM,
           RFQSQ TYPE ZMMT0520_088-RFQSQ,
           MATNR TYPE ZMMT0520_088-MATNR,
           MENGE TYPE ZMMT0520_088-MENGE,
           NETPR TYPE ZMMT0520_088-NETPR,
           NETWR TYPE ZMMT0520_088-NETWR,
           MEINS TYPE ZMMT0520_088-MEINS,
           WAERS TYPE ZMMT0520_088-WAERS,
         END OF LS_ITEM,
         LT_ITEM LIKE TABLE OF LS_ITEM.

  DATA : LV_FLAG,
         LV_MSG TYPE STRING.

  READ TABLE GT_DISPLAY INTO DATA(LS_DISPLAY) WITH KEY CHECK = ABAP_ON.

  SELECT SINGLE K~RFQNO,
                K~DLVDT AS LFDAT,
                P~RFQDT
    FROM ZMMT0510_088 AS K
    JOIN ZMMT0520_088 AS P
      ON K~RFQNO EQ P~RFQNO
   WHERE K~RFQNO = @LS_DISPLAY-RFQNO
    INTO CORRESPONDING FIELDS OF @LS_HEAD.

  SELECT RFQSQ,
         MATNR,
         MENGE,
         NETPR,
         NETWR,
         MEINS,
         WAERS
    FROM ZMMT0520_088
   WHERE RFQNO = @LS_DISPLAY-RFQNO
    INTO CORRESPONDING FIELDS OF TABLE @LT_ITEM.

  CALL FUNCTION 'ZEDU_RFQ_TO_ECC'
    DESTINATION 'ecc'
    EXPORTING
      IS_HEAD = LS_HEAD
      IT_ITEM = LT_ITEM
    IMPORTING
      EV_FLAG = LV_FLAG
      EV_MSG  = LV_MSG.

  IF LV_FLAG EQ 'S'.
    PERFORM SEND_TO_ECC USING LS_DISPLAY LV_FLAG LV_MSG
                     CHANGING GT_DISPLAY.
  ELSEIF LV_FLAG EQ 'F'.
    MESSAGE LV_MSG TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELT_LINES
*&---------------------------------------------------------------------*
FORM DELT_LINES .

  DATA : LV_SUCCESS.

  LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>)
    WHERE CHECK EQ ABAP_ON.
    IF <FS_DISPLAY>-ZIFFLG EQ 'S'.
      LV_SUCCESS = ABAP_ON.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING <FS_DISPLAY> TO GS_RFQ_H.
    MOVE-CORRESPONDING <FS_DISPLAY> TO GS_RFQ_I.

    DELETE ZMMT0510_088 FROM GS_RFQ_H.
    DELETE ZMMT0520_088 FROM GS_RFQ_I.
  ENDLOOP.

  IF LV_SUCCESS EQ ABAP_ON.
    MESSAGE '이미 전송된 RFQ 입니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ELSE.
    PERFORM SELECT_DATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
*&---------------------------------------------------------------------*
*& Data Declation
*&---------------------------------------------------------------------*
  DATA : LT_MODI TYPE LVC_T_MODI,
         LS_MODI TYPE LVC_S_MODI.

  FIELD-SYMBOLS : <FS>, <FS_VALUE>.

  LT_MODI = PR_DATA_CHANGED->MT_GOOD_CELLS.
  CLEAR : GS_DISPLAY.

*&---------------------------------------------------------------------*
*& Macro Defintion
*&---------------------------------------------------------------------*
  DEFINE __GET_VALUE.

    ASSIGN COMPONENT &1 OF STRUCTURE <FS_DISPLAY> TO <fs_value>.
    IF sy-subrc EQ 0.
      pr_data_changed->get_cell_value(
        EXPORTING
          i_row_id    = <FS_MOD>-row_id     " Row ID
          i_fieldname = &1                 " Field Name
        IMPORTING
          e_value     = <fs_value>         " Cell Content
      ).
    ENDIF.

  END-OF-DEFINITION.

  DEFINE __MODIFY_VALUE.

    ASSIGN COMPONENT &1 OF STRUCTURE <FS_DISPLAY> to <fs_value>.
    IF sy-SUBRC eq 0.
      PR_DATA_CHANGED->MODIFY_CELL(
        EXPORTING
          I_ROW_ID    = <FS_MOD>-row_id     " Row ID
          I_FIELDNAME = &1                 " Field Name
          I_VALUE     = <fs_value>         " Value
      ).
    ENDIF.
  END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*& Data Modification
*&---------------------------------------------------------------------*
  LOOP AT LT_MODI ASSIGNING FIELD-SYMBOL(<FS_MOD>).

    CLEAR : GS_DISPLAY.
    READ TABLE GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>) INDEX <FS_MOD>-ROW_ID.

    CASE <FS_MOD>-FIELDNAME.
      WHEN 'CHECK'.
        __GET_VALUE : 'CHECK'.
        LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_CHECKED>)
          WHERE RFQNO EQ <FS_DISPLAY>-RFQNO.
          <FS_CHECKED>-CHECK = <FS_DISPLAY>-CHECK.
        ENDLOOP.

      WHEN 'MATNR'.
        __GET_VALUE : 'MATNR'.

        SELECT SINGLE
          FROM MARA
          FIELDS MEINS
          WHERE MATNR = @<FS_DISPLAY>-MATNR
          INTO @<FS_DISPLAY>-MEINS.

        IF SY-SUBRC NE 0.
          MESSAGE '유효하지 않은 자재번호 입니다.' TYPE 'S' DISPLAY LIKE 'E'.
          CLEAR : <FS_DISPLAY>-MATNR.
          __MODIFY_VALUE : 'MATNR'.
          EXIT.
        ENDIF.

      WHEN 'NETPR'.

        IF <FS_DISPLAY>-WAERS IS INITIAL.
          MESSAGE '통화키를 입력해주세요' TYPE 'S' DISPLAY LIKE 'E'.
          CLEAR : <FS_MOD>-VALUE.
          __MODIFY_VALUE : 'NETPR'.
          EXIT.
        ENDIF.

        __GET_VALUE : 'NETPR'.

      WHEN 'MENGE'.

        __GET_VALUE : 'MENGE'.

    ENDCASE.

    IF <FS_DISPLAY>-NETPR IS NOT INITIAL AND <FS_DISPLAY>-MENGE IS NOT INITIAL.
      <FS_DISPLAY>-NETWR = <FS_DISPLAY>-NETPR * <FS_DISPLAY>-MENGE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_0100 .

  CALL METHOD GO_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED  " Event ID
    EXCEPTIONS
      ERROR      = 1                                 " Error
      OTHERS     = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SET HANDLER LCL_EVENT_HANDELR=>ON_DATA_CHANGED FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_TO_ECC
*&---------------------------------------------------------------------*
FORM SEND_TO_ECC USING PS_DISPLAY TYPE TS_DISPLAY
                       PV_FLAG
                       PV_MSG
              CHANGING PT_ITEM    TYPE TY_DISPLAY.

  DATA: GT_CELLSTYLE TYPE LVC_T_STYL,
        GS_CELLSTYLE TYPE LVC_S_STYL.

  SELECT SINGLE
    RFQNO,
    LIFNR,
    DLVDT,
    ERDAT,
    CHDAT,
    ZIFFLG,
    ZIFDAT,
    ZIFTIM
    FROM ZMMT0510_088
   WHERE RFQNO = @PS_DISPLAY-RFQNO
    INTO CORRESPONDING FIELDS OF @GS_RFQ_H.

  GS_RFQ_H-ZIFFLG = PV_FLAG.
  GS_RFQ_H-ZIFDAT = SY-DATUM.
  GS_RFQ_H-ZIFTIM = SY-UZEIT.

  UPDATE ZMMT0510_088 FROM GS_RFQ_H.

  LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS_DISPLAY>)
    WHERE CHECK EQ ABAP_ON.

    CLEAR : GT_CELLSTYLE, GS_CELLSTYLE.

    GS_CELLSTYLE-FIELDNAME = 'CHECK'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'DLVDT'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'RFQDT'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'MATNR'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'MENGE'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'MEINS'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'NETPR'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

    GS_CELLSTYLE-FIELDNAME = 'WAERS'.
    GS_CELLSTYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT GS_CELLSTYLE INTO TABLE <FS_DISPLAY>-CELLSTYL.

  ENDLOOP.

  MESSAGE PV_MSG TYPE 'S'.

ENDFORM.
