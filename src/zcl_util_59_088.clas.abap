class ZCL_UTIL_59_088 definition
  public
  final
  create public .

public section.

  types:
    tt_dd03t TYPE TABLE OF dd03t .
  types:
    BEGIN OF ts_return,
        type TYPE bapi_mtype,
        msg  TYPE bapi_msg,
      END OF ts_return .
  types:
    BEGIN OF ts_auth,
        varbl TYPE  agrorgvar,
        low   TYPE  agval,
        high  TYPE  agval,
      END OF ts_auth .
  types:
    tt_auth TYPE TABLE OF ts_auth .

  constants CONFIRM_YES type C value 'Y' ##NO_TEXT.
  constants CONFIRM_NO type C value 'N' ##NO_TEXT.

  class-methods CONV_CURR
    importing
      value(I_IN) type FLAG default 'X'
      value(I_CURRENCY) type TCURC-WAERS
      value(I_AMOUNT) type ANY
    exporting
      value(E_AMOUNT) type ANY .
  class-methods SIGN_IN_FRONT
    changing
      !V_DATA type ANY .
  class-methods F4_VALUE_REQUEST
    importing
      value(I_RETFIELD) type CLIKE
      value(I_ITAB) type STANDARD TABLE
    returning
      value(R_VALUE) type SHVALUE_D .
  class-methods POPUP_TO_CONFIRM
    importing
      value(I_TITLEBAR) type SY-TITLE default SY-TITLE
      value(I_TEXT_QUESTION) type ANY optional
      value(I_TEXT_BUTTON_1) type ANY default 'Yes'
      value(I_TEXT_BUTTON_2) type ANY default 'No'
      value(I_DEFAULT_BUTTON) type CHAR01 default '2'
      value(I_DISPLAY_CANCEL_BUTTON) type CHAR01 optional
      value(I_KEY) type TEXTPOOL-KEY optional
    returning
      value(R_ANSWER) type CHAR01 .
  class-methods TEXT_POOL
    importing
      value(I_CPROG) type SY-CPROG
      value(I_ID) type TEXTPOOL-ID default 'I'
      value(I_KEY) type TEXTPOOL-KEY
    exporting
      value(E_ENTRY) type CLIKE .
  class-methods SALV_POPUP
    importing
      value(IT_TAB) type STANDARD TABLE
      value(IT_FCAT) type LVC_T_FCAT optional
      value(IV_TITLE) type SY-TITLE default SY-TITLE
      !IV_DO_SUM type CHAR1 default 'X'
      !IV_WIDTH type INT1 default 110
      !IV_HEIGHT type INT1 default 20 .
  class-methods SALV
    importing
      value(IT_TAB) type STANDARD TABLE
      value(IT_FCAT) type LVC_T_FCAT optional
      value(IV_TITLE) type SY-TITLE default SY-TITLE
      value(IV_DO_SUM) type CHAR1 default 'X'
      value(IV_POPUP) type CHAR1 default SPACE
      value(IV_WIDTH) type INT1 optional
      value(IV_HEIGHT) type INT1 optional .
  class-methods TABLE_TO_FIELDCATALOG
    importing
      value(IT_TAB) type STANDARD TABLE
      value(I_CFIELD) type CHAR1 default 'X'
      value(I_CL_ABAP_TABLEDESCR) type CHAR1 optional
      value(I_LANGU) type SPRAS default SY-LANGU
    returning
      value(RT_FIELDCATALOG) type LVC_T_FCAT
    exceptions
      NOT_A_STRUCTURE
      NO_DDIC .
  class-methods GET_ELEMENTS
    importing
      value(IT_COMP) type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE optional
    returning
      value(RT_COMP) type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE .
  class-methods SEND_MAIL
    importing
      value(IV_SUBJECT) type SO_OBJ_DES
      value(IV_SENDER) type AD_SMTPADR
      value(IV_CONTENTS) type BCSY_TEXT
      value(IV_TYPE) type SO_OBJ_TP default 'RAW'
      value(IT_RECT) type SAFM_APT_PP_EMAIL
      value(IT_ATTACH) type FILETABLE
    returning
      value(R_MESSAGE) type STRING .
  class-methods PATH_FILE_SPLIT
    importing
      value(IV_PATHFILE) type STRING
    exporting
      value(EV_PATHNAME) type CHAR255
      value(EV_FILENAME) type CHAR255
      value(EV_EXTENSION) type CHAR3 .
  class-methods ERR_POPUP_SHOW
    importing
      value(IV_TITLE) type ANY default 'Error'
      value(IT_MSG) type BAPIRET2_T
    returning
      value(R_TYPE) type BAPI_MTYPE .
  class-methods GOS_ATTACHMENT
    importing
      value(IV_OBJTYPE) type SWO_OBJTYP
      value(IV_OBJKEY) type SWO_TYPEID
      value(IV_MODE) type C default 'D' .
  class-methods GOS_ATTACHMENT_LIST_POPUP
    importing
      value(IV_OBJECT) type SIBFLPORB
      value(IV_ATTACH) type SGS_FLAG optional
      value(IV_MODE) type CHAR1 default 'D'
      value(IV_INSTID) type SIBFBORIID
      value(IV_TYPEID) type SIBFTYPEID
      value(IV_CATID) type SIBFCATID default 'BO'
    exporting
      !EV_SAVE type SGS_FLAG .
  class-methods SMW0_DOWNLOAD
    importing
      value(I_RELID) type W3_RELID default 'MI'
      value(I_OBJID) type W3OBJID
      value(I_TITLE) type STRING
      value(I_EXCUTE) type ANY default SPACE
    returning
      value(R_RESULT) type CHAR1 .
  class-methods DOWN_ITAB_2_XLS
    changing
      !I_TAB type STANDARD TABLE
    returning
      value(EV_MSG) type STRING .
  class-methods DIRECTORY_BROWSE
    importing
      value(I_INITIAL) type STRING optional
    returning
      value(R_FOLDER) type STRING .
  class-methods FILE_SAVE_DIALOG
    importing
      value(I_TITLE) type ANY optional
      value(I_DEF_EXT) type ANY optional
      value(I_DEF_NAME) type ANY optional
      value(I_FILE_FILTER) type ANY optional
      value(I_DIRECTORY) type ANY optional
    exporting
      value(E_MSG) type ANY
    returning
      value(R_FULLPATH) type STRING .
  class-methods FILE_OPEN_DIALOG
    importing
      value(I_TITLE) type ANY optional
      value(I_DEF_EXT) type ANY optional
      value(I_DEF_NAME) type ANY optional
      value(I_FILE_FILTER) type ANY optional
      value(I_DIRECTORY) type ANY optional
    exporting
      value(E_MSG) type ANY
    returning
      value(R_FULLPATH) type STRING .
  class-methods LAST_DAY
    importing
      value(I_DAY) type D
    returning
      value(R_DAY) type D .
  class-methods NUMC_ROUND
    importing
      value(I_RTYPE) type VTBLEISTE-RTYPE default '-'
      value(I_RUNIT) type VTBFIMA-RUNIT default '0.01'
      value(I_VALUE) type ANY
    exporting
      value(E_VALUE) type ANY .
  class-methods ITAB_TO_XML_STR
    importing
      value(I_TAB) type STANDARD TABLE
      value(I_NAME) type STRING
    returning
      value(R_XML) type STRING .
  class-methods XML_DOWNLOAD
    importing
      value(I_TAB) type STANDARD TABLE
      value(I_NAME) type STRING .
  class-methods AUTHORIZED_CHECK
    importing
      value(IV_UNAME) type SY-UNAME default SY-UNAME
      value(IT_AUTH) type TT_AUTH
    returning
      value(RS_RETURN) type TS_RETURN .
  class-methods AUTHORITY_CHECK
    importing
      value(I_FNAME) type ANY
      value(I_VALUE) type ANY
      value(I_UNAME) type SY-UNAME default SY-UNAME
    returning
      value(R_RETURN) type TS_RETURN .
  class-methods CALC_DATE
    importing
      value(I_DATE) type D
      value(I_DAYS) type ANY default '0'
      value(I_MONTHS) type ANY default '0'
      value(I_YEARS) type ANY default '0'
      value(I_SIGNUM) type ANY default '+'
    returning
      value(R_DATE) type D .
  class-methods REGEX_FIND
    importing
      value(I_DATA) type STRING
      value(I_LOWER) type ABAP_BOOL default SPACE
      value(I_UPPER) type ABAP_BOOL default SPACE
      value(I_ALPHA) type ABAP_BOOL default SPACE
      value(I_DIGIT) type ABAP_BOOL default SPACE
      value(I_SPACE) type ABAP_BOOL default SPACE
      value(I_BLANK) type ABAP_BOOL default SPACE
      value(I_PUNCT) type ABAP_BOOL default SPACE
      value(I_ALNUM) type ABAP_BOOL default SPACE
      value(I_GRAPH) type ABAP_BOOL default SPACE
      value(I_PRINT) type ABAP_BOOL default SPACE
    returning
      value(R_FIND) type ABAP_BOOL .
  class-methods REGEX_REPLACE
    importing
      !I_DATA type CLIKE
      value(I_LOWER) type ABAP_BOOL default SPACE
      value(I_UPPER) type ABAP_BOOL default SPACE
      value(I_ALPHA) type ABAP_BOOL default SPACE
      value(I_DIGIT) type ABAP_BOOL default SPACE
      value(I_SPACE) type ABAP_BOOL default SPACE
      value(I_BLANK) type ABAP_BOOL default SPACE
      value(I_PUNCT) type ABAP_BOOL default SPACE
      value(I_ALNUM) type ABAP_BOOL default SPACE
      value(I_GRAPH) type ABAP_BOOL default SPACE
      value(I_PRINT) type ABAP_BOOL default SPACE
    returning
      value(R_DATA) type STRING .
  class-methods GET_FIELD_TEXT
    importing
      value(IV_TABNAME) type TABNAME
    exporting
      value(ET_DD03T) type TT_DD03T .
  class-methods EXCEL_PIVOT
    importing
      value(IV_FILENAME) type STRING optional
      value(IV_TITLE) type SY-TITLE default SY-TITLE
      value(IV_KEYNUM) type N optional
      value(IT_DATA) type STANDARD TABLE .
  class-methods REPLACE_DATE
    importing
      value(IV_STR) type ANY
    exporting
      value(EV_STR) type ANY .
  class-methods SET_DROPDOWN_VALUE
    importing
      value(IT_DATA) type STANDARD TABLE
      value(IV_PARAM) type ANY
      value(IV_KEYFNAME) type ANY
      value(IV_TXTFNAME) type ANY .
  class-methods SET_DATE_RANGE
    importing
      value(I_DATE) type DATS optional
      value(I_TYPE) type ANY
    changing
      value(E_DATE_FR) type DATS optional
      value(E_DATE_TO) type DATS optional
      value(E_MONTH_FR) type ANY optional
      value(E_MONTH_TO) type ANY optional .
  class-methods POPUP_MONTH
    changing
      value(P_YYYYMM) type ANY default SY-DATUM(6) .
  class-methods INDICATOR
    importing
      value(IV_PERC) type ANY
      value(IV_TEXT) type ANY default 'Processing...' .
  class-methods KOKRS_BUKRS
    importing
      value(IV_KOKRS) type KOKRS optional
      value(IV_BUKRS) type BUKRS optional
    exporting
      value(EV_KOKRS) type KOKRS
      value(EV_BUKRS) type BUKRS
      value(EV_BEZEI) type ANY
      value(EV_BUTXT) type ANY .
  class-methods GET_KOKRS_TEXT
    importing
      value(IV_KOKRS) type KOKRS
    returning
      value(RV_BEZEI) type BEZEI .
  class-methods GET_BUKRS_TEXT
    importing
      value(IV_BUKRS) type BUKRS
    returning
      value(RV_BUTXT) type BUTXT .
  class-methods CONV_JAHRPER
    importing
      value(IV_DATE) type ANY optional
    returning
      value(RV_JAHRPER) type JAHRPER .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_UTIL_59_088 IMPLEMENTATION.


  METHOD AUTHORITY_CHECK.

    DATA : lt_auth TYPE tt_auth,
           ls_auth TYPE ts_auth.

    ls_auth-varbl = '$' && i_fname.
    ls_auth-low = i_value.
    INSERT ls_auth INTO TABLE lt_auth.

    r_return = authorized_check( iv_uname = i_uname it_auth  = lt_auth ).

  ENDMETHOD.


  METHOD AUTHORIZED_CHECK.

    DATA : lv_flg,
           lrt_value TYPE RANGE OF string,
           lrs_value LIKE LINE OF lrt_value.

    IF sy-uname = 'BATCHJOB'.
      EXIT.
    ENDIF.

    IF it_auth[] IS INITIAL.
      rs_return-type = 'E'.
      rs_return-msg = 'Check Data Not Found!!'.
      EXIT.
    ENDIF.

    SELECT DISTINCT t2~varbl, t2~low, t2~high, t3~vtext
      FROM agr_users AS t1 INNER JOIN agr_1252 AS t2
                                   ON t2~agr_name EQ t1~agr_name
                           LEFT OUTER JOIN usvart AS t3
                                   ON t3~varbl EQ t2~varbl
                                  AND t3~langu EQ @sy-langu
      WHERE t1~uname    EQ @iv_uname
        AND t1~from_dat LE @sy-datum
        AND t1~to_dat   GE @sy-datum
      ORDER BY t2~varbl, t2~low
      INTO TABLE @DATA(lt_agr).

    IF lt_agr[] IS INITIAL.
      rs_return-type = 'E'.
      rs_return-msg  = 'Role is not found!'.
      EXIT.
    ENDIF.

***Role이 여러개일 경우 합집합으로 체크한다***
    LOOP AT it_auth INTO DATA(ls_auth).
      CLEAR : lrs_value, lrt_value[].

      LOOP AT lt_agr INTO DATA(ls_agr)
                     WHERE varbl EQ ls_auth-varbl.
        CLEAR lrs_value.

        IF ls_agr-low EQ '*'. ""ALL.
          lrs_value = VALUE #( sign = 'I'  option = 'CP' low = ls_agr-low ).

        ELSEIF NOT ls_agr-high IS INITIAL.
          lrs_value = VALUE #( sign = 'I'  option = 'BT' low = ls_agr-low high = ls_agr-high ).

        ELSE.
          lrs_value = VALUE #( sign = 'I'  option = 'EQ' low = ls_agr-low ).
        ENDIF.

        INSERT lrs_value INTO TABLE lrt_value.
      ENDLOOP.

      IF lrt_value[] IS INITIAL.
        rs_return-type = 'E'.
        rs_return-msg  = |You are not authorized(| && ls_agr-vtext && |=>| && ls_auth-low && |)|.
        EXIT.
      ENDIF.

      IF ls_auth-low NOT IN lrt_value.
        rs_return-type = 'E'.
        rs_return-msg  = |You are not authorized(| && ls_agr-vtext && |=>| && ls_auth-low && |)|.
        EXIT.

      ELSE.
        IF NOT ls_auth-high IS INITIAL.
          IF ls_auth-high NOT IN lrt_value.
            rs_return-type = 'E'.
            rs_return-msg  = |You are not authorized(| && ls_agr-vtext && |=>| && ls_auth-high && |)|.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

***권한체크 통과***
    CHECK rs_return-type IS INITIAL.

    rs_return-type = 'S'.
    rs_return-msg  = 'Pass'.

  ENDMETHOD.


  METHOD CALC_DATE.

    DATA : lv_date      TYPE p0001-begda,
           lv_days      TYPE t5a4a-dlydy,
           lv_months    TYPE t5a4a-dlymo,
           lv_signum    TYPE t5a4a-split,
           lv_years     TYPE t5a4a-dlyyr,
           lv_calc_date TYPE p0001-begda.

    lv_date    = i_date.
    lv_days    = i_days.
    lv_months  = i_months.
    lv_years   = i_years.
    lv_signum  = i_signum.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = lv_date
        days      = lv_days
        months    = lv_months
        signum    = lv_signum
        years     = lv_years
      IMPORTING
        calc_date = lv_calc_date.

    r_date = lv_calc_date.

  ENDMETHOD.


  METHOD CONV_CURR.

    DATA : lv_amt TYPE string.

    IF i_amount = 0 OR i_amount IS INITIAL.
      e_amount = i_amount.
    ENDIF.

    lv_amt = i_amount.

    IF i_in = 'X'.

      CALL FUNCTION 'CURRENCY_AMOUNT_IDOC_TO_SAP'
        EXPORTING
          currency    = i_currency
          idoc_amount = lv_amt
        IMPORTING
          sap_amount  = lv_amt.

    ELSE.

      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
        EXPORTING
          currency    = i_currency
          sap_amount  = lv_amt
        IMPORTING
          idoc_amount = lv_amt.

      sign_in_front( CHANGING v_data = lv_amt ).

    ENDIF.

    e_amount = lv_amt.

  ENDMETHOD.


  METHOD CONV_JAHRPER.
    DATA : lv_date TYPE d
          ,lo_descr TYPE REF TO cl_abap_typedescr
          .
    IF iv_date IS INITIAL.
      lv_date = sy-datum.
    ELSE.

      lo_descr = cl_abap_typedescr=>describe_by_data( iv_date ).
      CHECK lo_descr->type_kind = 'D'
         OR lo_descr->type_kind = 'N'.

      lv_date = COND #( WHEN strlen( iv_date ) = 6
                        THEN |{ iv_date }01|
                        WHEN strlen( iv_date ) = 8
                        THEN iv_date ).

      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_date
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDIF.

    rv_jahrper = |{ lv_date(4) }0{ lv_date+4(2) } |.

  ENDMETHOD.


  METHOD DIRECTORY_BROWSE.

    CALL METHOD cl_gui_frontend_services=>directory_browse
      EXPORTING
*       window_title         =
        initial_folder       = i_initial
      CHANGING
        selected_folder      = r_folder
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD DOWN_ITAB_2_XLS.

    DATA: l_filename   TYPE string,
          l_path       TYPE string,
          l_fullpath   TYPE string,
          l_filelength TYPE i.

    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        window_title         = 'Download excel file'
        default_file_name    = '*.xls'
      CHANGING
        filename             = l_filename
        path                 = l_path
        fullpath             = l_fullpath
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3.

    IF sy-subrc NE 0 OR l_filename IS INITIAL.
      ev_msg = 'User Cancelled'.
      EXIT.
    ENDIF.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename   = l_fullpath
        filetype   = 'DBF'
        codepage   = '8500'
      IMPORTING
        filelength = l_filelength
      CHANGING
        data_tab   = i_tab.

    CALL METHOD cl_gui_frontend_services=>execute
      EXPORTING
        document               = l_fullpath
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9.

  ENDMETHOD.


  METHOD ERR_POPUP_SHOW.

    DATA: ls_log             TYPE bal_s_msg.
    DATA: ls_log_handle      TYPE balloghndl.
    DATA: ls_display_profile TYPE bal_s_prof.
    DATA: ls_logn TYPE bal_s_log.

*    CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
*      TABLES
*        it_return = ct_bapiret2.

    CLEAR r_type.

*   log_create
    ls_logn-extnumber  = 'LOG'.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = ls_log_handle
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_logn
      IMPORTING
        e_log_handle            = ls_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

*  POPUP PROFILE.
    CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
      IMPORTING
        e_s_display_profile = ls_display_profile.

    CALL FUNCTION 'BAL_DSP_OUTPUT_INIT'
      EXPORTING
        i_s_display_profile = ls_display_profile.

*  log_insert
    LOOP AT it_msg INTO DATA(wa_msg).

      CLEAR: ls_log.
      IF wa_msg-id IS NOT INITIAL.
        ls_log-msgid     = wa_msg-id.
      ELSE.
        ls_log-msgid     =  'ZCOM'.
      ENDIF.
      IF wa_msg-number IS NOT INITIAL.
        ls_log-msgno     = wa_msg-number.
      ELSE.
        ls_log-msgno     =  '000'.
      ENDIF.

      IF wa_msg-message IS NOT INITIAL.
        ls_log-msgv1     =  wa_msg-message.
      ELSE.
        ls_log-msgv1     = wa_msg-message_v1.
        ls_log-msgv2     = wa_msg-message_v2.
        ls_log-msgv3     = wa_msg-message_v3.
        ls_log-msgv4     = wa_msg-message_v4.
      ENDIF.

      ls_log-msgty       =  wa_msg-type.
      ls_log-probclass   =  '1'.

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = ls_log_handle
          i_s_msg          = ls_log
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.

      r_type  = 'E'.

    ENDLOOP.

*   log_display
    ls_display_profile-use_grid = 'X'.
    ls_display_profile-disvariant-report = sy-repid.
    ls_display_profile-disvariant-handle = 'LOG'. "'LOG'.
    ls_display_profile-title      = iv_title.
    ls_display_profile-cwidth_opt = 'X'.
    ls_display_profile-no_toolbar = 'X'.
    ls_display_profile-start_col  = '10'.
    ls_display_profile-start_row  = '5'.

    CHECK r_type = 'E'.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.

    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle = ls_log_handle
      EXCEPTIONS
        OTHERS       = 1.

  ENDMETHOD.


  METHOD EXCEL_PIVOT.

    DATA : gv_filename TYPE gxxlt_f-file,
           gv_header_1 TYPE gxxlt_p-text,
           gv_att_cols TYPE sytabix,
           gv_hrz_keys TYPE n,
           gv_vrt_keys TYPE n,
           gv_so_title TYPE gxxlt_f-so_title.

    DATA : gt_sflight     TYPE TABLE OF sflight,
           gt_hkey        TYPE TABLE OF gxxlt_h,
           gt_online_text TYPE TABLE OF gxxlt_o,
           gt_print_text  TYPE TABLE OF gxxlt_p,
           gt_sema        TYPE TABLE OF gxxlt_s,
           gt_vkey        TYPE TABLE OF gxxlt_v.

    DATA : gs_sflight     TYPE sflight,
           gs_hkey        TYPE gxxlt_h,
           gs_online_text TYPE gxxlt_o,
           gs_print_text  TYPE gxxlt_p,
           gs_sema        TYPE gxxlt_s,
           gs_vkey        TYPE gxxlt_v.

    DATA : gt_fcat TYPE lvc_t_fcat,
           gs_fcat TYPE lvc_s_fcat.

    gv_filename = iv_filename.

    gt_fcat = zcl_util_59=>table_to_fieldcatalog( it_tab   = it_data
                                                    i_cfield = 'X' ).

    LOOP AT gt_fcat INTO gs_fcat.

      CLEAR gs_sema.
      gs_sema-col_no   = sy-tabix.
      gs_sema-col_src  = sy-tabix.

      CASE gs_fcat-inttype.
        WHEN 'Z'.
          gs_sema-col_typ  = 'NUM'.
          gs_sema-col_ops  = 'AVG'.
        WHEN 'C'.
          gs_sema-col_typ  = 'STR'.
          gs_sema-col_ops  = 'NOP'.
        WHEN 'X'.
          gs_sema-col_typ  = 'STR'.
          gs_sema-col_ops  = 'NOP'.
        WHEN 'T'.
          gs_sema-col_typ  = 'STR'.
          gs_sema-col_ops  = 'NOP'.
        WHEN 'P'.
          gs_sema-col_typ  = 'NUM'.
          gs_sema-col_ops  = 'ADD'.
        WHEN 'F'.
          gs_sema-col_typ  = 'NUM'.
          gs_sema-col_ops  = 'ADD'.
        WHEN 'I'.
          gs_sema-col_typ  = 'NUM'.
          gs_sema-col_ops  = 'ADD'.
        WHEN 'N'.
          gs_sema-col_typ  = 'NUM'.
          gs_sema-col_ops  = 'ADD'.
        WHEN 'D'.
          gs_sema-col_typ  = 'DAT'.
          gs_sema-col_ops  = 'NOP'.
        WHEN OTHERS.
          gs_sema-col_typ  = 'STR'.
          gs_sema-col_ops  = 'NOP'.
      ENDCASE.
      INSERT gs_sema INTO TABLE gt_sema.

*--- Spaltenüberschriften ------------------------------------------
      CLEAR : gs_hkey.
      gs_hkey-col_no   = sy-tabix.
      gs_hkey-row_no   = 1.
      gs_hkey-col_name = gs_fcat-scrtext_m.
      INSERT gs_hkey INTO TABLE gt_hkey.

    ENDLOOP.

    gv_att_cols = lines( gt_sema ).
    gv_so_title = iv_title.

    IF iv_keynum IS NOT INITIAL.
      gv_vrt_keys = iv_keynum.
    ELSE.
      CALL FUNCTION 'PM_NUMBER_OF_KEY_COL'
        EXPORTING
          key_col_default = 1
          key_col_max     = gv_att_cols
        IMPORTING
          key_col         = gv_vrt_keys
        EXCEPTIONS
          cancel          = 01.

      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDIF.

    DO gv_vrt_keys TIMES.
      DATA(gv_index) = sy-index.
      READ TABLE gt_sema INTO gs_sema INDEX gv_index.
      gs_sema-col_ops = 'DFT'.
      MODIFY gt_sema FROM gs_sema INDEX gv_index.
      READ TABLE gt_hkey INTO gs_hkey INDEX 1.
      gs_vkey-col_no = gv_index.
*    gs_vkey-row_no = 1.
      gs_vkey-col_name = gs_hkey-col_name.
      APPEND gs_vkey TO gt_vkey.
      DELETE gt_hkey INDEX 1.
    ENDDO.

    LOOP AT gt_hkey INTO gs_hkey.
      gs_hkey-col_no = sy-tabix.
      MODIFY gt_hkey FROM gs_hkey.
    ENDLOOP.

    gv_att_cols = gv_att_cols - gv_vrt_keys.

    CALL FUNCTION 'XXL_FULL_API'
      EXPORTING
        filename          = gv_filename
        header_1          = gv_header_1
        no_dialog         = ' '
        no_start          = ' '
        n_att_cols        = gv_att_cols
        n_hrz_keys        = 1
        n_vrt_keys        = gv_vrt_keys
        sema_type         = 'X'
        so_title          = gv_so_title
      TABLES
        data              = it_data
        hkey              = gt_hkey
        online_text       = gt_online_text
        print_text        = gt_print_text
        sema              = gt_sema
        vkey              = gt_vkey
      EXCEPTIONS
        cancelled_by_user = 1
        data_too_big      = 2
        dim_mismatch_data = 3
        dim_mismatch_sema = 4
        dim_mismatch_vkey = 5
        error_in_hkey     = 6
        error_in_sema     = 7
        file_open_error   = 8
        file_write_error  = 9
        inv_data_range    = 10
        inv_winsys        = 11
        inv_xxl           = 12
        OTHERS            = 13.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD F4_VALUE_REQUEST.

    DATA : lt_return TYPE TABLE OF ddshretval.

    DATA : lv_retfield TYPE dfies-fieldname.
*           lv_return   TYPE shvalue_d.

    lv_retfield = i_retfield.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield   = lv_retfield
        value_org  = 'S'
      TABLES
        value_tab  = i_itab     " Search Help에서 보여지는 데이터
        return_tab = lt_return. " Search Help에서 선택한 값들이 담겨있는 테이블.

    CHECK lt_return IS NOT INITIAL.

    READ TABLE lt_return INTO DATA(ls_return) INDEX 1.

    r_value = ls_return-fieldval.

  ENDMETHOD.


  METHOD FILE_OPEN_DIALOG.

    DATA : lv_title       TYPE string,
           lv_def_ext     TYPE string,
           lv_def_name    TYPE string,
           lv_file_filter TYPE string,
           lv_directory   TYPE string,
           lv_filename    TYPE string,
           lv_path        TYPE string,
           lv_fullpath    TYPE string,
           lv_msg         TYPE string.

    DATA : lt_filetab TYPE filetable,
           lv_rc      TYPE i.

    lv_title       = i_title.
    lv_def_ext     = i_def_ext.
    lv_def_name    = i_def_name.
    lv_file_filter = i_file_filter.
    lv_directory   = i_directory.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title            = lv_title
        default_extension       = lv_def_ext
        default_filename        = lv_def_name
        file_filter             = lv_file_filter
*       with_encoding           =
        initial_directory       = lv_directory
*       multiselection          =
      CHANGING
        file_table              = lt_filetab
        rc                      = lv_rc
*       user_action             =
*       file_encoding           =
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty
      NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO e_msg.
    ENDIF.

    CHECK lt_filetab IS NOT INITIAL.

    READ TABLE lt_filetab INTO DATA(ls_filetab) INDEX 1.

    r_fullpath = ls_filetab-filename.

  ENDMETHOD.


  METHOD FILE_SAVE_DIALOG.

    DATA : lv_title       TYPE string,
           lv_def_ext     TYPE string,
           lv_def_name    TYPE string,
           lv_file_filter TYPE string,
           lv_directory   TYPE string,
           lv_filename    TYPE string,
           lv_path        TYPE string,
           lv_fullpath    TYPE string,
           lv_msg         TYPE string.

    lv_title       = i_title.
    lv_def_ext     = i_def_ext.
    lv_def_name    = i_def_name.
    lv_file_filter = i_file_filter.
    lv_directory   = i_directory.

    IF lv_file_filter IS INITIAL.
      lv_file_filter = 'Microsoft Excel Files (*.XLS;*.XLSX;*.XLSM)|*.XLS;*.XLSX;*.XLSM|'.
    ENDIF.

    IF lv_directory IS INITIAL.
      lv_directory = 'C:\'.
    ENDIF.

    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        window_title              = lv_title
        default_extension         = lv_def_ext
        default_file_name         = lv_def_name
        file_filter               = lv_file_filter
        initial_directory         = lv_directory
      CHANGING
        filename                  = lv_filename
        path                      = lv_path
        fullpath                  = lv_fullpath
      EXCEPTIONS
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        OTHERS                    = 5.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
      MESSAGE ID sy-msgid TYPE sy-msgty
      NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO e_msg.
    ENDIF.

    r_fullpath = lv_fullpath.

  ENDMETHOD.


  METHOD GET_BUKRS_TEXT.

    SELECT SINGLE butxt
      FROM t001
     WHERE bukrs = @iv_bukrs
      INTO @rv_butxt.

  ENDMETHOD.


  METHOD GET_ELEMENTS.

    DATA: lt_comp   TYPE cl_abap_structdescr=>component_table, "CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE
          ls_comp   LIKE LINE OF lt_comp,
          lt_comp_d LIKE lt_comp,
*          lt_comp_r LIKE lt_comp,
          lt_comp_r TYPE cl_abap_structdescr=>component_table,
*          ls_comp_d LIKE lt_comp,
          ls_comp_d LIKE LINE OF lt_comp,
          lrf_stru  TYPE REF TO cl_abap_structdescr,
          lv_index  TYPE sy-index.

    lt_comp[] = it_comp[].
    LOOP AT lt_comp INTO ls_comp WHERE as_include = 'X'.
      lv_index = sy-tabix.
      DELETE lt_comp.
      lrf_stru ?= ls_comp-type.
      lt_comp_d = lrf_stru->get_components( ).
      lt_comp_r = zcl_util_59=>get_elements( lt_comp_d ).
*      lt_comp_r = zcl_util_59=>get_delments( lt_comp_d ).

      LOOP AT lt_comp_r INTO ls_comp_d.
        INSERT ls_comp_d INTO lt_comp INDEX lv_index.
        lv_index = lv_index + 1.
        CLEAR ls_comp_d.
      ENDLOOP.
      CLEAR : ls_comp, lt_comp_r[].
    ENDLOOP.

    rt_comp = lt_comp.

  ENDMETHOD.


  METHOD GET_FIELD_TEXT.

    SELECT a~fieldname, a~ddtext
      FROM dd03t AS a
     WHERE a~tabname = @iv_tabname
       AND a~ddlanguage = @sy-langu
     ORDER BY a~fieldname
      INTO CORRESPONDING FIELDS OF TABLE @et_dd03t.

  ENDMETHOD.


  METHOD GET_KOKRS_TEXT.

    SELECT SINGLE bezei
      FROM tka01
     WHERE kokrs = @iv_kokrs
      INTO @rv_bezei.

  ENDMETHOD.


  METHOD GOS_ATTACHMENT.

    DATA: lo_manager TYPE REF TO cl_gos_manager,
          la_obj     TYPE borident.
*  CONSTANTS: objtype TYPE borident-objtype VALUE 'BUS2093'. "예약
*  CONSTANTS: objtype TYPE borident-objtype VALUE 'BUS2105'. "PR


    " Set object Key
    la_obj-objtype = iv_objtype.
    la_obj-objkey  = iv_objkey . "문서번호


    " GOS toolbar
    CREATE OBJECT lo_manager
      EXPORTING
        is_object    = la_obj
*       ip_no_instance = 'X'
        ip_no_commit = 'X'
        ip_mode      = iv_mode   " E : Edit, D : Display
      EXCEPTIONS
        OTHERS       = 1.


    "After Save when Key is avaiable
    CALL METHOD lo_manager->set_id_of_published_object
      EXPORTING
        is_object = la_obj.
    COMMIT WORK AND WAIT.


    CREATE OBJECT lo_manager
      EXPORTING
        ip_no_commit = 'R'
      EXCEPTIONS
        OTHERS       = 1.

    CALL METHOD lo_manager->start_service_direct
      EXPORTING
        ip_service       = 'VIEW_ATTA' "변경
        is_object        = la_obj
      " ip_no_check      = gc_x        "지시자
      EXCEPTIONS
        no_object        = 1
        object_invalid   = 2
        execution_failed = 3
        OTHERS           = 4.

    IF sy-subrc NE 0.
      CALL METHOD lo_manager->start_service_direct
        EXPORTING
          ip_service       = 'PCATTA_CREA'  "생성
          is_object        = la_obj
        EXCEPTIONS
          no_object        = 1
          object_invalid   = 2
          execution_failed = 3
          OTHERS           = 4.

*      MESSAGE 'No object found' TYPE 'S'.

    ENDIF.

  ENDMETHOD.


  METHOD GOS_ATTACHMENT_LIST_POPUP.

    DATA : ls_object TYPE sibflporb,
           lv_save   TYPE sgs_flag.

    ls_object-instid = iv_instid.   "KEY for attachment  : key1 && key2 && key3.....
    ls_object-typeid = iv_typeid.   "Business Object name (BO) - Tcode SWO1
    ls_object-catid  = iv_catid .


    CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
      EXPORTING
        is_object       = ls_object       " Local Persistent Object Reference (LPOR) - BOR Compatible
        ip_attachments  = 'X'              " Display attachments
        ip_mode         = 'C'
      IMPORTING
        ep_save_request = lv_save.

    cl_gui_cfw=>set_new_ok_code( EXPORTING new_code = 'REFRESH'  ).   " New OK_CODE


  ENDMETHOD.


  METHOD INDICATOR.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = iv_perc
        text       = iv_text.

  ENDMETHOD.


  METHOD ITAB_TO_XML_STR.

    DATA: l_dom      TYPE REF TO if_ixml_element,
          m_document TYPE REF TO if_ixml_document,
          g_ixml     TYPE REF TO if_ixml,
          w_string   TYPE xstring,
          w_size     TYPE i,
          w_result   TYPE i,
          w_line     TYPE string,
          it_xml     TYPE dcxmllines,
          s_xml      LIKE LINE OF it_xml,
          w_rc       LIKE sy-subrc.

    DATA : lv_string TYPE string.

    DATA: xml TYPE dcxmllines.
    DATA: rc TYPE sy-subrc.

    CLASS cl_ixml DEFINITION LOAD.
    g_ixml = cl_ixml=>create( ).
    CHECK NOT g_ixml IS INITIAL.
    m_document = g_ixml->create_document( ).
    CHECK NOT m_document IS INITIAL.

    CALL FUNCTION 'SDIXML_DATA_TO_DOM'
      EXPORTING
        name         = i_name
        dataobject   = i_tab[]
      IMPORTING
        data_as_dom  = l_dom
      CHANGING
        document     = m_document
      EXCEPTIONS
        illegal_name = 1
        OTHERS       = 2.

    CHECK sy-subrc = 0.
    CHECK l_dom IS NOT INITIAL.
    w_rc = m_document->append_child( new_child = l_dom ).
    CHECK w_rc IS INITIAL.

    CALL FUNCTION 'SDIXML_DOM_TO_XML'
      EXPORTING
        document      = m_document
*       pretty_print  = 'X'
      IMPORTING
        xml_as_string = w_string
        size          = w_size
      TABLES
        xml_as_table  = it_xml
      EXCEPTIONS
        no_document   = 1
        OTHERS        = 2.

    CHECK sy-subrc = 0.

    CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
      EXPORTING
        im_xstring  = w_string
        im_encoding = 'UTF-8'
      IMPORTING
        ex_string   = lv_string.
*

    r_xml = lv_string.

  ENDMETHOD.


  METHOD KOKRS_BUKRS.

    DATA : lv_kokrs TYPE kokrs,
           lv_bukrs TYPE bukrs.

    lv_kokrs = iv_kokrs.
    lv_bukrs = iv_bukrs.

    IF iv_kokrs IS NOT INITIAL.

      SELECT SINGLE bukrs
        FROM tka02
       WHERE kokrs = @iv_kokrs
        INTO @lv_bukrs.

    ELSE.

      SELECT SINGLE kokrs
        FROM tka02
       WHERE bukrs = @iv_bukrs
        INTO @lv_kokrs.

    ENDIF.

    CHECK lv_kokrs IS NOT INITIAL AND lv_bukrs IS NOT INITIAL.

    ev_kokrs = lv_kokrs.
    ev_bukrs = lv_bukrs.
    ev_bezei = zcl_util_59=>get_kokrs_text( lv_kokrs ).
    ev_butxt = zcl_util_59=>get_bukrs_text( lv_bukrs ).

  ENDMETHOD.


  METHOD LAST_DAY.

    DATA : lv_date TYPE sy-datum.

    lv_date = i_day.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_date
      IMPORTING
        last_day_of_month = lv_date
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    r_day = lv_date.

  ENDMETHOD.


  METHOD NUMC_ROUND.

    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        i_rtype     = i_rtype
        i_runit     = i_runit
        i_value     = i_value
      IMPORTING
        e_value_rnd = e_value.

  ENDMETHOD.


  METHOD PATH_FILE_SPLIT.

    DATA : lt_itab TYPE TABLE OF string,
           ls_itab TYPE string.

    CHECK iv_pathfile IS NOT INITIAL.

    CALL FUNCTION 'RPM_DX_PATH_FILE_SPLIT'
      EXPORTING
        iv_pathfile = iv_pathfile
      IMPORTING
        ev_pathname = ev_pathname
        ev_filename = ev_filename.

    SPLIT ev_filename AT '.' INTO DATA(fname) ev_extension. "확장자

    "테이블로 담기
*    SPLIT ev_filename  AT '.' INTO TABLE lt_itab.

  ENDMETHOD.


  METHOD POPUP_MONTH.

    DATA : lv_yyyymm TYPE spmon,
           lv_return TYPE sy-subrc.

    IF p_yyyymm IS INITIAL.
      p_yyyymm = sy-datum(6).
    ENDIF.

    lv_yyyymm = p_yyyymm.

    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        actual_month               = lv_yyyymm
      IMPORTING
        selected_month             = lv_yyyymm
        return_code                = lv_return
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        month_not_found            = 3
        OTHERS                     = 4.

    IF sy-subrc = 0 AND lv_return <> 4.
      p_yyyymm = lv_yyyymm.
    ENDIF.

  ENDMETHOD.


  METHOD POPUP_TO_CONFIRM.

    DATA: lv_text_question TYPE string,
          lv_text_button_1 TYPE string,
          lv_text_button_2 TYPE string.

    lv_text_button_1 = i_text_button_1. "TEXT-001. "Yes
    lv_text_button_2 = i_text_button_2. "TEXT-002. "No

    IF i_key IS INITIAL.
      lv_text_question = i_text_question.
    ELSE.
      zcl_util_59=>text_pool( EXPORTING i_cprog = sy-cprog
                                          i_key   = i_key
                                IMPORTING e_entry = lv_text_question ).
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = i_titlebar
        text_question         = lv_text_question
        text_button_1         = lv_text_button_1
        text_button_2         = lv_text_button_2
        default_button        = i_default_button
        display_cancel_button = i_display_cancel_button
      IMPORTING
        answer                = r_answer.

    IF r_answer = '1'.
      r_answer = 'Y'.
    ELSEIF r_answer = '2'.
      r_answer = 'N'.
    ENDIF.

  ENDMETHOD.


  METHOD REGEX_FIND.

    DATA : lv_regex TYPE string.

    CASE abap_true.
      WHEN i_lower.
        lv_regex = '[[:lower:]]'.
      WHEN i_upper.
        lv_regex = '[[:upper:]]'.
      WHEN i_alpha.
        lv_regex = '[[:alpha:]]'.
      WHEN i_digit.
        lv_regex = '[[:digit:]]'.
      WHEN i_space.
        lv_regex = '[[:space:]]'.
      WHEN i_blank.
        lv_regex = '[[:blank:]]'.
      WHEN i_punct.
        lv_regex = '[[:punct:]]'.
      WHEN i_alnum.
        lv_regex = '[[:alnum:]]'.
      WHEN i_graph.
        lv_regex = '[[:graph:]]'.
      WHEN i_print.
        lv_regex = '[[:print:]]'.
      WHEN OTHERS.
        r_find = abap_false.
        EXIT.
    ENDCASE.

    FIND REGEX lv_regex IN i_data IGNORING CASE.
    IF sy-subrc = 0.
      r_find = abap_true.
    ELSE.
      r_find = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD REGEX_REPLACE.

    DATA : lv_regex TYPE string.
    DATA : lv_str TYPE string.

    lv_str = i_data.

    " https://help.sap.com/doc/abapdocu_731_index_htm/7.31/en-US/abenregex_syntax_signs.htm

    CASE abap_true.
      WHEN i_lower.
        lv_regex = '[[:lower:]]'.
      WHEN i_upper.
        lv_regex = '[[:upper:]]'.
      WHEN i_alpha.
        lv_regex = '[[:alpha:]]'.
      WHEN i_digit.
        lv_regex = '[[:digit:]]'.
      WHEN i_space.
        lv_regex = '[[:space:]]'.
      WHEN i_blank.
        lv_regex = '[[:blank:]]'.
      WHEN i_punct.
        lv_regex = '[[:punct:]]'.
      WHEN i_alnum.
        lv_regex = '[[:alnum:]]'.
      WHEN i_graph.
        lv_regex = '[[:graph:]]'.
      WHEN i_print.
        lv_regex = '[[:print:]]'.
      WHEN OTHERS.
        r_data = i_data.
        EXIT.
    ENDCASE.

    REPLACE ALL OCCURRENCES OF REGEX lv_regex IN lv_str  WITH ''.

    r_data = lv_str.

  ENDMETHOD.


  METHOD REPLACE_DATE.

    DATA : lv_str TYPE string.

    lv_str = iv_str.
    CONDENSE : lv_str NO-GAPS.

    REPLACE ALL OCCURRENCES OF '.' IN lv_str WITH ''.
    REPLACE ALL OCCURRENCES OF '-' IN lv_str WITH ''.

    ev_str = lv_str.

  ENDMETHOD.


  METHOD SALV.

    "SALV
    DATA: gr_alv           TYPE REF TO cl_salv_table,
          gr_columns       TYPE REF TO cl_salv_columns_table,
          gr_column        TYPE REF TO cl_salv_column,
          gr_agg           TYPE REF TO cl_salv_aggregations,
          gr_layout        TYPE REF TO cl_salv_layout,
          gr_groups        TYPE REF TO cl_salv_sorts,
          display_settings TYPE REF TO cl_salv_display_settings.


    DATA: functions TYPE REF TO cl_salv_functions_list,
          not_found TYPE REF TO cx_salv_not_found.

    DATA:  lo_sort_column TYPE REF TO cl_salv_sort.

    DATA: lo_cols  TYPE REF TO cl_salv_columns_table,
          lo_col   TYPE REF TO cl_salv_column_table,
          ls_color TYPE lvc_s_colo.

    FIELD-SYMBOLS <fname> TYPE any.

    CHECK it_tab[] IS NOT INITIAL.

    "FCATLOG - 수량필드 SUM 하기위해서
    DATA  lt_fcat   TYPE lvc_t_fcat.
    zcl_util_59=>table_to_fieldcatalog( EXPORTING  it_tab          = it_tab
                                                     i_cfield        = 'X'
                                          RECEIVING  rt_fieldcatalog = lt_fcat
                                          EXCEPTIONS not_a_structure = 1
                                                     no_ddic         = 2
                                                     OTHERS          = 3 ).



    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = gr_alv
                                CHANGING  t_table      = it_tab ).

        "layout_settings
        DATA: lv_key  TYPE  salv_s_layout_key.

        lv_key-report = sy-repid.

        gr_layout = gr_alv->get_layout( ).
        gr_layout->set_key( lv_key ).
        gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
        gr_layout->set_default( 'X' ).

        "optimize_column_width
        gr_columns = gr_alv->get_columns( ).
        gr_columns->set_optimize('X').

        "set_toolbar
        functions = gr_alv->get_functions( ).
        functions->set_all( ).

        DATA: lr_selections TYPE REF TO cl_salv_selections.
*
*        "Selektion
        lr_selections = gr_alv->get_selections( ).
        lr_selections->set_selection_mode( lr_selections->single ).

        LOOP AT lt_fcat INTO DATA(ls_fcat).

          TRY .

              READ TABLE it_fcat INTO DATA(is_fcat) WITH KEY fieldname = ls_fcat-fieldname.
              IF sy-subrc = 0.
                gr_column = gr_columns->get_column( ls_fcat-fieldname ).
                IF is_fcat-scrtext_s IS NOT INITIAL.
                  gr_column->set_short_text( is_fcat-scrtext_s ).
                ENDIF.
                IF is_fcat-scrtext_m IS NOT INITIAL.
                  gr_column->set_medium_text( is_fcat-scrtext_m ).
                ENDIF.
                IF is_fcat-scrtext_l IS NOT INITIAL.
                  gr_column->set_long_text( is_fcat-scrtext_l ).
                ENDIF.
                IF is_fcat-tech IS NOT INITIAL.
                  gr_column->set_technical( is_fcat-tech ).
                ENDIF.
                IF is_fcat-qfieldname IS NOT INITIAL.
                  gr_column->set_quantity_column( is_fcat-qfieldname ).
                ENDIF.
                IF is_fcat-cfieldname IS NOT INITIAL.
                  gr_column->set_currency_column( is_fcat-cfieldname ).
                ENDIF.
                IF is_fcat-currency IS NOT INITIAL.
                  gr_column->set_currency( is_fcat-currency ).
                ENDIF.
*                IF is_fcat-no_out IS NOT INITIAL.
*                  gr_column->set_visible( xsdbool( is_fcat-no_out = space ) ).
*                ENDIF.
              ENDIF.

            CATCH cx_salv_data_error cx_salv_not_found. "#EC NO_HANDLER

          ENDTRY.

        ENDLOOP.

        "display_settings
        display_settings = gr_alv->get_display_settings( ).
        display_settings->set_striped_pattern( if_salv_c_bool_sap=>true ).
        display_settings->set_list_header( iv_title ).


        " row selection mode - MARK 보이게
        DATA(lo_selections) = gr_alv->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

        "Show total for column 'COLUMNNAME'
        DATA(lo_aggregations) = gr_alv->get_aggregations( ).


        "SORT
        gr_groups = gr_alv->get_sorts( ) .
        gr_groups->clear( ).


        IF iv_do_sum = 'X'.
          LOOP AT lt_fcat INTO ls_fcat WHERE inttype = 'P'. "수량/금액 SUM

            lo_aggregations->add_aggregation( columnname  = ls_fcat-fieldname
                                              aggregation = if_salv_c_aggregation=>total ).

            lo_aggregations->set_aggregation_before_items( 'X' ). "Display Aggregation Before Data Entries

          ENDLOOP.
        ENDIF.

        IF iv_popup = 'X'.
          "POP WINDOW
          gr_alv->set_screen_popup( start_column = 10
                                    end_column   = 20 + iv_width
                                    start_line   = 5
                                    end_line     = 10 + iv_height ).
        ENDIF.


        "Displaying the ALV
        gr_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lv_msg).

    ENDTRY.

  ENDMETHOD.


  METHOD SALV_POPUP.

    "SALV
    DATA: gr_alv           TYPE REF TO cl_salv_table,
          gr_columns       TYPE REF TO cl_salv_columns_table,
          gr_column        TYPE REF TO cl_salv_column,
          gr_agg           TYPE REF TO cl_salv_aggregations,
          gr_layout        TYPE REF TO cl_salv_layout,
          gr_groups        TYPE REF TO cl_salv_sorts,
          display_settings TYPE REF TO cl_salv_display_settings.


    DATA: functions TYPE REF TO cl_salv_functions_list,
          not_found TYPE REF TO cx_salv_not_found.

    DATA:  lo_sort_column TYPE REF TO cl_salv_sort.

    DATA: lo_cols  TYPE REF TO cl_salv_columns_table,
          lo_col   TYPE REF TO cl_salv_column_table,
          ls_color TYPE lvc_s_colo.

    FIELD-SYMBOLS <fname> TYPE any.

    CHECK it_tab[] IS NOT INITIAL.

    "FCATLOG - 수량필드 SUM 하기위해서
    DATA  lt_fcat   TYPE lvc_t_fcat.
    zcl_util_59=>table_to_fieldcatalog( EXPORTING  it_tab          = it_tab
                                                     i_cfield        = 'X'
                                          RECEIVING  rt_fieldcatalog = lt_fcat
                                          EXCEPTIONS not_a_structure = 1
                                                     no_ddic         = 2
                                                     OTHERS          = 3 ).



    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = gr_alv
                                CHANGING  t_table      = it_tab ).

        "layout_settings
        DATA: lv_key  TYPE  salv_s_layout_key.

        lv_key-report = sy-repid.

        gr_layout = gr_alv->get_layout( ).
        gr_layout->set_key( lv_key ).
        gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
        gr_layout->set_default( 'X' ).

        "optimize_column_width
        gr_columns = gr_alv->get_columns( ).
        gr_columns->set_optimize('X').

        "set_toolbar
        functions = gr_alv->get_functions( ).
        functions->set_all( ).

        DATA: lr_selections TYPE REF TO cl_salv_selections.
*
*      "Selektion
        lr_selections = gr_alv->get_selections( ).
        lr_selections->set_selection_mode( lr_selections->single ).

        "수량참조 필드 단위가 두개 있을때 문제있음
*      LOOP AT lt_fcat INTO DATA(ls_fcat) WHERE inttype = 'P'. "수량/금액 SUM
        LOOP AT lt_fcat ASSIGNING FIELD-SYMBOL(<fs>) WHERE inttype = 'P'. "수량/금액 SUM

          TRY.
              " --------------  CHOI  2023.02.03  -------------------
              " CASE 로 datatype 구분( CURR / other ) 하여, DFIELDNAME, QFIELDNAME 지정
              CASE <fs>-datatype .
                WHEN 'CURR' .

                  READ TABLE lt_fcat INTO DATA(wa_fcata) WITH KEY datatype = 'CUKY'.
                  IF sy-subrc = 0.

                    gr_column = gr_columns->get_column( <fs>-fieldname ).
                    gr_column->set_currency_column( wa_fcata-fieldname ) .

                  ENDIF.

                WHEN OTHERS .
                  " --------------  CHOI  2023.02.03  -------------------

                  READ TABLE lt_fcat INTO DATA(wa_fcatb) WITH KEY datatype = 'UNIT'.
                  IF sy-subrc = 0.
                    " DATA(wa_fcat) = lt_fcat[ datatype = 'UNIT' ]. "수량참조 필드 찾기

                    gr_column = gr_columns->get_column( <fs>-fieldname ).
                    gr_column->set_quantity_column( wa_fcatb-fieldname ) .  "수량
*            gr_column->set_currency_column( 'KWAEH' ) .           "금액
                  ENDIF.

                  " --------------  CHOI  2023.02.03  -------------------
              ENDCASE .
              " --------------  CHOI  2023.02.03  -------------------

            CATCH cx_salv_data_error cx_salv_not_found. "#EC NO_HANDLER

          ENDTRY.

        ENDLOOP.

        LOOP AT lt_fcat INTO DATA(ls_fcat).

          TRY .

              READ TABLE it_fcat INTO DATA(is_fcat) WITH KEY fieldname = ls_fcat-fieldname.
              IF sy-subrc = 0.
                gr_column = gr_columns->get_column( ls_fcat-fieldname ).
                gr_column->set_short_text( is_fcat-scrtext_s ).
                gr_column->set_medium_text( is_fcat-scrtext_m ).
                gr_column->set_long_text( is_fcat-scrtext_l ).
                gr_column->set_technical( is_fcat-tech ).
                gr_column->set_quantity_column( is_fcat-qfieldname ).
                gr_column->set_currency_column( is_fcat-cfieldname ).
                gr_column->set_currency( is_fcat-currency ).
                gr_column->set_visible( xsdbool( is_fcat-no_out = space ) ).
              ENDIF.

            CATCH cx_salv_data_error cx_salv_not_found. "#EC NO_HANDLER

          ENDTRY.

        ENDLOOP.

*      "hide_client_column
*      TRY.
*          gr_column = gr_columns->get_column( 'BOX' ).
*          gr_column->set_visible( if_salv_c_bool_sap=>false ).
*
*        CATCH cx_salv_not_found INTO not_found.  " error handling
*
*      ENDTRY.

        "fcat_text
*      TRY.
*          gr_column = gr_columns->get_column( 'MANDT_H' ).
*          gr_column->set_short_text( '컬럼텍스트' ).
*          gr_column->set_medium_text( '컬럼텍스트' ).
*          gr_column->set_long_text( '컬럼텍스트' ).
*        CATCH cx_salv_not_found INTO not_found. " error handling
*      ENDTRY.


*      "set_column_color
*      TRY.
*          ls_color-col = '6'.
*          ls_color-int = '1'.
*          ls_color-inv = '0'.
*
*          lo_cols = gr_alv->get_columns( ).
*          lo_col ?= lo_cols->get_column( 'KOSTL_H' ).  "?= source_ref.
*          lo_col->set_color( ls_color ).
*
*          lo_col ?= lo_cols->get_column( 'ANLN1_H' ).  "?= source_ref.
*          lo_col->set_color( ls_color ).
*
*        CATCH cx_salv_not_found INTO not_found. " error handling
*      ENDTRY.

        "display_settings
        display_settings = gr_alv->get_display_settings( ).
        display_settings->set_striped_pattern( if_salv_c_bool_sap=>true ).
        display_settings->set_list_header( iv_title ).


        " row selection mode - MARK 보이게
        DATA(lo_selections) = gr_alv->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

        "Show total for column 'COLUMNNAME'
        DATA(lo_aggregations) = gr_alv->get_aggregations( ).


        "SORT
        gr_groups = gr_alv->get_sorts( ) .
        gr_groups->clear( ).


        IF iv_do_sum = 'X'.
          LOOP AT lt_fcat ASSIGNING <fs> WHERE inttype = 'P'. "수량/금액 SUM

            lo_aggregations->add_aggregation( columnname  = <fs>-fieldname
                                              aggregation = if_salv_c_aggregation=>total ).

            lo_aggregations->set_aggregation_before_items( 'X' ). "Display Aggregation Before Data Entries

          ENDLOOP.
        ENDIF.

        "POP WINDOW
        gr_alv->set_screen_popup( start_column = 20
                                  end_column   = 20 + iv_width
                                  start_line   = 10
                                  end_line     = 10 + iv_height ).

        "Displaying the ALV
        gr_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lv_msg).

    ENDTRY.

  ENDMETHOD.


  METHOD SEND_MAIL.

    DATA: send_request       TYPE REF TO cl_bcs.
    " DATA: lt_ctext           TYPE bcsy_text.
    DATA: ls_ctext           TYPE soli.
    DATA: document           TYPE REF TO cl_document_bcs.
    DATA: sender             TYPE REF TO cl_sapuser_bcs.
    DATA: recipient          TYPE REF TO if_recipient_bcs.
    DATA: bcs_exception      TYPE REF TO cx_bcs.
    DATA: sent_to_all        TYPE os_boolean.
    DATA: l_sender           TYPE REF TO if_sender_bcs.
    DATA: status_mail        TYPE bcs_stml.

    DATA: content_bin TYPE solix_tab. "첨부파일 binary 변환
    DATA: bin_data    TYPE w3mimetabtype. "첨부파일 binary 변환
    DATA: xstring     TYPE xstring.
    DATA: file_size   TYPE i.
    DATA: filename TYPE string.

    DATA: ev_pathname  TYPE char255,
          ev_filename  TYPE char255,
          ev_extension TYPE char3.

    TRY.

*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).

        document = cl_document_bcs=>create_document( i_type    = iv_type "'RAW'  "오브젝트 유형 'RAW:텍스트 / HTM(HTML형식)
                                                     i_subject = iv_subject   "메일제목
                                                     i_text    = iv_contents ).  "본문내용
        " i_length  = '12' ).     "Size of Document Content


        "발신자 ************************************************************
        IF iv_sender IS INITIAL. "발신자 정보 없을떄 sap 아이디로 대체
          sender = cl_sapuser_bcs=>create( sy-uname ).
          CALL METHOD send_request->set_sender
            EXPORTING
              i_sender = sender.

        ELSE.
          l_sender = cl_cam_address_bcs=>create_internet_address( iv_sender ). "메일주소
          CALL METHOD send_request->set_sender
            EXPORTING
              i_sender = l_sender.
        ENDIF.


        "수신자 ************************************************************
        LOOP AT it_rect INTO DATA(ls_rect).

          recipient = cl_cam_address_bcs=>create_internet_address( ls_rect ). "메일주소
          CALL METHOD send_request->add_recipient
            EXPORTING
              i_recipient = recipient
              i_express   = 'X'.    "속달
          " i_COPY   = 'X'.      "참조자 여부

        ENDLOOP.


        "첨부파일경로
        LOOP AT it_attach INTO DATA(ls_attach).

          filename = ls_attach-filename. "full path!


          "파일명/확장자
          zcl_util_59=>path_file_split( EXPORTING iv_pathfile  = filename
                                          IMPORTING ev_pathname  = ev_pathname
                                                    ev_filename  = ev_filename
                                                    ev_extension = ev_extension ).

          CLEAR: file_size, content_bin, content_bin[],
                 bin_data, bin_data[], xstring , file_size.
          cl_gui_frontend_services=>gui_upload( EXPORTING  filename                = filename  "full path!
                                                           filetype                = 'BIN'
                                                IMPORTING  filelength              = file_size
                                                CHANGING   data_tab                = bin_data
                                                EXCEPTIONS file_open_error         = 1
                                                           file_read_error         = 2
                                                           no_batch                = 3
                                                           gui_refuse_filetransfer = 4
                                                           invalid_type            = 5
                                                           no_authority            = 6
                                                           unknown_error           = 7
                                                           bad_data_format         = 8
                                                           header_not_allowed      = 9
                                                           separator_not_allowed   = 10
                                                           header_too_long         = 11
                                                           unknown_dp_error        = 12
                                                           access_denied           = 13
                                                           dp_out_of_memory        = 14
                                                           disk_full               = 15
                                                           dp_timeout              = 16
                                                           OTHERS                  = 17 ).


          CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
            EXPORTING
              input_length = file_size
            IMPORTING
              buffer       = xstring
            TABLES
              binary_tab   = bin_data.

          " xstring -> solix
          DATA(it_bin_data) = cl_bcs_convert=>xstring_to_solix( xstring ).
          content_bin[] = it_bin_data[]. "첨부파일



          IF content_bin[] IS NOT INITIAL.
            CALL METHOD document->add_attachment
              EXPORTING
                i_attachment_type    = ev_extension  "Attachment 확장자
                i_attachment_subject = CONV so_obj_des( ev_filename )   "Attachment Title
                i_att_content_hex    = content_bin.  "binary_content.   "Content (Binary)
          ENDIF.


        ENDLOOP.

        "add document to send request
        CALL METHOD send_request->set_document( document ).

*     Set that you don't need a Return Status E-mail
*      N  안 함
*      E  오류가 발생한 경우만
*      D  보낸 경우
*      R  읽은 경우
*      A  항상
        status_mail = 'N'.

        CALL METHOD send_request->set_status_attributes
          EXPORTING
            i_requested_status = status_mail
            i_status_mail      = status_mail.

        " set send immediately flag
        send_request->set_send_immediately( 'X' ). "즉시발송

*     ---------- send document ---------------------------------------
        CALL METHOD send_request->send(
          EXPORTING
            i_with_error_screen = 'X'
          RECEIVING
            result              = sent_to_all ).

        IF sent_to_all = 'X'.
          WRITE TEXT-003.
        ENDIF.

        COMMIT WORK.

* -----------------------------------------------------------
* *                     exception handling
* -----------------------------------------------------------
* * replace this very rudimentary exception handling
* * with your own one !!!
* -----------------------------------------------------------
      CATCH cx_bcs INTO bcs_exception.
        r_message = bcs_exception->get_text( ).
        " RAISE mail_sent_failed.
    ENDTRY.

  ENDMETHOD.


  METHOD SET_DATE_RANGE.

    DATA : lv_type TYPE i.
    DATA : lv_date_fr TYPE sy-datum,
           lv_date_to TYPE sy-datum.

    lv_type = i_type.

    CASE i_type.
      WHEN 1.  " 월
        lv_date_fr = |{ i_date+0(6) }01|.
        lv_date_to = i_date.

      WHEN 2.  " 분기
        IF i_date+4(2) < '04'.      " 1분기
          lv_date_fr = |{ i_date+0(4) }0101|.
          lv_date_to = |{ i_date+0(4) }0301|.
        ELSEIF i_date+4(2) < '07'.  " 2분기
          lv_date_fr = |{ i_date+0(4) }0401|.
          lv_date_to = |{ i_date+0(4) }0601|.
        ELSEIF i_date+4(2) < '10'.  " 3분기
          lv_date_fr = |{ i_date+0(4) }0701|.
          lv_date_to = |{ i_date+0(4) }0901|.
        ELSE.                 " 4분기
          lv_date_fr = |{ i_date+0(4) }1001|.
          lv_date_to = |{ i_date+0(4) }1201|.
        ENDIF.
      WHEN 3.  " 반기
        IF i_date+4(2) < '07'.
          lv_date_fr = |{ i_date+0(4) }0101|.
          lv_date_to = |{ i_date+0(4) }0601|.
        ELSE.
          lv_date_fr = |{ i_date+0(4) }0701|.
          lv_date_to = |{ i_date+0(4) }1201|.
        ENDIF.
      WHEN 4.  " 년
        lv_date_fr = |{ i_date+0(4) }0101|.
        lv_date_to = |{ i_date+0(4) }1201|.
      WHEN OTHERS.
    ENDCASE.

    lv_date_to = last_day( lv_date_to ).

    e_date_fr  = lv_date_fr.
    e_date_to  = lv_date_to.
    e_month_fr = lv_date_fr+4(2).
    e_month_to = lv_date_to+4(2).

  ENDMETHOD.


  METHOD SET_DROPDOWN_VALUE.

    DATA : lv_id    TYPE vrm_id,
           lt_value TYPE TABLE OF vrm_value,
           ls_value TYPE vrm_value.

    DATA : lo_tab TYPE REF TO data,
           lo_str TYPE REF TO data.

    FIELD-SYMBOLS : <lt_data> TYPE ANY TABLE,
                    <ls_data> TYPE any.

    CREATE DATA lo_tab LIKE it_data.
    ASSIGN lo_tab->* TO <lt_data>.

    CREATE DATA lo_str LIKE LINE OF <lt_data>.
    ASSIGN lo_str->* TO <ls_data>.

    <lt_data>[] = it_data[].
    lv_id = iv_param.

    LOOP AT <lt_data> INTO <ls_data>.

      ASSIGN COMPONENT iv_keyfname OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<lv_key>).
      ASSIGN COMPONENT iv_txtfname OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<lv_txt>).

      CHECK <lv_key> IS ASSIGNED.
      CHECK <lv_txt> IS ASSIGNED.

      CLEAR ls_value.
      ls_value-key  = <lv_key>.
      ls_value-text = <lv_txt>.
      INSERT ls_value INTO TABLE lt_value.

      UNASSIGN : <lv_key>, <lv_txt>.

    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = lv_id
        values          = lt_value
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD SIGN_IN_FRONT.

    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = v_data.

  ENDMETHOD.


  METHOD SMW0_DOWNLOAD.

    DATA(lv_fname) = |{ i_title }.XLSX|.
    DATA: ls_key        TYPE wwwdatatab,
          lv_save_fname TYPE string,
          lv_path       TYPE string,
          lv_fullpath   TYPE string,
          lv_file       TYPE rlgrap-filename,
          lv_rc         TYPE sy-subrc.

*-- SMW0 데이터 가져오기
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF @ls_key
      FROM wwwdata
     WHERE relid = @i_relid
       AND objid = @i_objid.

    IF sy-subrc <> 0.
      r_result = 'E'. "엑셀파일이 없습니다'
      EXIT.
    ENDIF.

*-- 저장경로 설정
    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        default_file_name         = lv_fname
        file_filter               = 'Excel files (*.XLS; *.XLSX)|*.XLSX'
        initial_directory         = 'C:\'
      CHANGING
        filename                  = lv_save_fname
        path                      = lv_path
        fullpath                  = lv_fullpath
      EXCEPTIONS
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        OTHERS                    = 5.

    IF sy-subrc <> 0.
      r_result = 'E'. "파일 위치가 잘못되었습니다'
      EXIT.
    ENDIF.

    IF lv_fullpath IS INITIAL.
      r_result = ''. " 취소하셨습니다.
      EXIT.
    ENDIF.

    lv_file = lv_fullpath.

*-- 다운로드
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        key         = ls_key
        destination = lv_file
      IMPORTING
        rc          = lv_rc.

    IF lv_rc <> 0.
      r_result = 'E'. " 다운로드 실패
      EXIT.
    ENDIF.

    r_result = 'S'. " 성공

    CHECK r_result = 'S'.

    IF i_excute = 'X'.
      cl_gui_frontend_services=>execute(
        EXPORTING
          document               = lv_fullpath      " Path+Name to Document
          operation              = 'OPEN'           " Reserved: Verb for ShellExecute
        EXCEPTIONS
          cntl_error             = 1       " Control error
          error_no_gui           = 2       " No GUI available
          bad_parameter          = 3       " Incorrect parameter combination
          file_not_found         = 4       " File not found
          path_not_found         = 5       " Path not found
          file_extension_unknown = 6       " Could not find application for specified extension
          error_execute_failed   = 7       " Could not execute application or document
          synchronous_failed     = 8       " Cannot Call Application Synchronously
          not_supported_by_gui   = 9       " GUI does not support this
          OTHERS                 = 10
      ).
    ENDIF.

  ENDMETHOD.


  METHOD TABLE_TO_FIELDCATALOG.

    FIELD-SYMBOLS: <LFS_WA>  TYPE ANY,
                   <LFS_CP>  TYPE ANY,
                   <LFS_TAB> TYPE STANDARD TABLE.


    DATA: LRF_SREF     TYPE REF TO DATA,
          LRF_CREF     TYPE REF TO DATA,
          LRF_TABLE    TYPE REF TO DATA,
          LRF_STRU     TYPE REF TO CL_ABAP_STRUCTDESCR,
          LRF_CLSS     TYPE REF TO CL_ABAP_CLASSDESCR,
          LRF_ELEM     TYPE REF TO CL_ABAP_ELEMDESCR,
          LRF_TAB      TYPE REF TO CL_ABAP_TABLEDESCR,
          LT_COMP      TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
          LT_COMP_     LIKE LT_COMP,
          LS_COMP      LIKE LINE OF LT_COMP,
          LV_HLPID     TYPE STRING,
          LV_SNAME     TYPE STRING,
          LS_FCAT      TYPE LVC_S_FCAT,
          LS_DFIES     TYPE DFIES,
          LT_TAB       TYPE TABLE OF STRING,
          LV_REFSTRUCT TYPE SWCONTDEF-REFSTRUCT,
          LV_REFFIELD  TYPE SWCONTDEF-REFFIELD,
          LS_DD04V     TYPE DD04V,
          LS_DD03V     TYPE DD03V,
          LV_LEN       TYPE I,
          LV_COL_POS   TYPE I.


    CREATE DATA LRF_TABLE LIKE IT_TAB.  " Input Table 기준으로 테이블 구조 맞춤
    ASSIGN LRF_TABLE->* TO <LFS_TAB>.

    LRF_TAB  ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( <LFS_TAB> ).  " 런타임 타입 정보 반환 후 다운 캐스팅을 통해 테이블 타입 데이터 타입 객체 생성
    LRF_STRU ?= LRF_TAB->GET_TABLE_LINE_TYPE( ).  " 생성된 테이블 타입 객체의 라인 타입을 기준으로 구조체 타입 객체 생성

    LRF_CLSS ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_OBJECT_REF( LRF_STRU ).  " RTTI 객체 반환
    IF LRF_CLSS->GET_RELATIVE_NAME( ) <> 'CL_ABAP_STRUCTDESCR'.  " 구조체 타입이 아닌 경우 Exception 반환
      RAISE NOT_A_STRUCTURE.
    ENDIF.

    LT_COMP_ = LRF_STRU->GET_COMPONENTS( ).  " 구조체 타입의 필드 리스트 반환
    LOOP AT LT_COMP_ INTO LS_COMP.
      LRF_CLSS ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_OBJECT_REF( LS_COMP-TYPE ).
      IF LRF_CLSS->GET_RELATIVE_NAME( ) = 'CL_ABAP_TABLEDESCR'.  " 필드 중 테이블 타입이 존재하는 경우 Deep Structure 판단 및 해당 필드 제거
        ".. Deep Structure
        IF I_CL_ABAP_TABLEDESCR = ' '.  " Input Parameter 중 하나가 ' ' 라면 해당 필드를 딥 스트럭쳐로 판단하고 제거
          DELETE LT_COMP_.
        ENDIF.
      ENDIF.
      CLEAR: LS_COMP.
    ENDLOOP.

*****    DATA: l_elem TYPE REF TO if_wd_context_element.
*****    lt_comp  = l_elem->get_elements( lt_comp_ ).
****
*****  DATA :
*****    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
*****    LR_DATA     TYPE REF TO DATA,
*****    LT_DFIES    TYPE DDFIELDS,
*****    LS_DFIES    TYPE DFIES,
*****    LS_FIELDCAT TYPE LVC_S_FCAT.
*****
*****
*****  CLEAR GT_FIELDCAT_1.
*****  CREATE DATA LR_DATA LIKE LINE OF GT_DATA.
*****
*****  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LR_DATA ).
*****
*****  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ).
*****
*****  LOOP AT LT_DFIES INTO LS_DFIES.
*****
*****    CLEAR LS_FIELDCAT.
*****
*****    MOVE-CORRESPONDING LS_DFIES TO LS_FIELDCAT.
*****
*****    APPEND LS_FIELDCAT TO GT_FIELDCAT_1.
*****
*****  ENDLOOP.
****
****
*****
*****    DATA: l_elem TYPE REF TO if_wd_context_element.
*****    lt_comp  = l_elem->get_elements( lt_comp_ ).

    LT_COMP  = ZCL_UTIL_59_088=>GET_ELEMENTS( LT_COMP_ ).
    LV_SNAME = LRF_STRU->ABSOLUTE_NAME.

    CREATE DATA LRF_SREF TYPE HANDLE LRF_STRU.
    ASSIGN LRF_SREF->* TO <LFS_WA>.

    LOOP AT LT_COMP INTO LS_COMP.
      ASSIGN COMPONENT LS_COMP-NAME OF STRUCTURE <LFS_WA> TO <LFS_CP>.
      DESCRIBE FIELD <LFS_CP> HELP-ID LV_HLPID.

      CLEAR: LT_TAB.
      SPLIT LV_HLPID AT '-' INTO TABLE LT_TAB.
      LV_LEN = LINES( LT_TAB ).

      IF LV_LEN = 2.  "Struct + Field
        READ TABLE LT_TAB INTO LV_REFSTRUCT INDEX 1.
        READ TABLE LT_TAB INTO LV_REFFIELD  INDEX 2.

        CALL FUNCTION 'SWP_DDIC_FIELD_INFO_GET'
          EXPORTING
            REFSTRUCT            = LV_REFSTRUCT
            REFFIELD             = LV_REFFIELD
            LANGUAGE             = I_LANGU
          IMPORTING
            FIELD_ATTRIBUTES     = LS_DFIES
          EXCEPTIONS
            FIELD_INFO_NOT_FOUND = 1
            OTHERS               = 9.
        IF SY-SUBRC = 0 AND LS_DFIES IS NOT INITIAL.
          MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
          LS_FCAT-REF_TABLE = LV_REFSTRUCT.
          LS_FCAT-TABNAME   = ''.
          LS_FCAT-TOOLTIP   = LS_FCAT-REPTEXT.
          LS_FCAT-REPTEXT   = LS_FCAT-COLTEXT = LS_FCAT-SCRTEXT_L.

          IF LV_REFFIELD <> LS_COMP-NAME.
            LS_FCAT-REF_FIELD = LV_REFFIELD.
            LS_FCAT-FIELDNAME = LS_COMP-NAME.
          ENDIF.

          ADD 10 TO LV_COL_POS. LS_FCAT-COL_POS = LV_COL_POS.
          APPEND LS_FCAT TO RT_FIELDCATALOG.
        ENDIF.
      ELSEIF LV_LEN = 1.  "DataElement
        READ TABLE LT_TAB INTO LV_REFFIELD INDEX 1.

        CALL FUNCTION 'DDIF_DTEL_GET'
          EXPORTING
            NAME          = LV_REFFIELD
            LANGU         = I_LANGU
          IMPORTING
            DD04V_WA      = LS_DD04V
          EXCEPTIONS
            ILLEGAL_INPUT = 1
            OTHERS        = 2.

        IF SY-SUBRC = 0 AND LS_DD04V IS NOT INITIAL.
          MOVE-CORRESPONDING LS_DD04V TO LS_FCAT.
          LS_FCAT-REF_TABLE = ''.
          LS_FCAT-TABNAME   = ''.
          LS_FCAT-REPTEXT   = LS_FCAT-COLTEXT = LS_FCAT-SCRTEXT_L.

          IF LV_REFFIELD <> LS_COMP-NAME.
            LS_FCAT-REF_FIELD = LV_REFFIELD.
            LS_FCAT-FIELDNAME = LS_COMP-NAME.
          ENDIF.

          IF LS_FCAT-FIELDNAME IS INITIAL.
            LS_FCAT-FIELDNAME = LS_COMP-NAME.
          ENDIF.

          ADD 10 TO LV_COL_POS. LS_FCAT-COL_POS = LV_COL_POS.
          APPEND LS_FCAT TO RT_FIELDCATALOG.
        ENDIF.

      ELSEIF LV_LEN = 0 AND I_CFIELD = 'X'.  ".. Deep structure
        LRF_CLSS ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_OBJECT_REF( LS_COMP-TYPE ).
        IF LRF_CLSS->GET_RELATIVE_NAME( ) = 'CL_ABAP_TABLEDESCR'
         AND I_CL_ABAP_TABLEDESCR = 'X'.
          CLEAR: LS_FCAT, LS_COMP, LV_REFFIELD, LV_REFSTRUCT, LS_DD04V, LS_DFIES, LRF_ELEM, LT_TAB[].
          CONTINUE.
        ELSEIF LV_LEN = 0 AND I_CFIELD = 'X'.  "Custom Field
          LRF_ELEM ?= LS_COMP-TYPE.
          LS_FCAT-FIELDNAME = LS_COMP-NAME.
          LS_FCAT-INTTYPE = LRF_ELEM->TYPE_KIND.
          LS_FCAT-INTLEN = LRF_ELEM->LENGTH.
          LS_FCAT-DECIMALS = LS_FCAT-DECIMALS_O = LRF_ELEM->DECIMALS.
          LS_FCAT-OUTPUTLEN = LRF_ELEM->OUTPUT_LENGTH.
          ADD 10 TO LV_COL_POS. LS_FCAT-COL_POS = LV_COL_POS.
          APPEND LS_FCAT TO RT_FIELDCATALOG.
        ENDIF.
      ENDIF.

      CLEAR: LS_FCAT, LS_COMP, LV_REFFIELD, LV_REFSTRUCT, LS_DD04V, LS_DFIES, LRF_ELEM, LT_TAB[].

    ENDLOOP.

  ENDMETHOD.


  METHOD TEXT_POOL.

    DATA: lt_textpool TYPE TABLE OF textpool.

    READ TEXTPOOL i_cprog INTO lt_textpool LANGUAGE sy-langu.
    READ TABLE lt_textpool INTO DATA(ls_textpool) WITH KEY id = i_id key = i_key.
    e_entry = ls_textpool-entry.

  ENDMETHOD.


  METHOD XML_DOWNLOAD.

    DATA : xml TYPE dcxmllines.
    DATA : BEGIN OF ls_xml_tab,
             d LIKE LINE OF xml,
           END OF ls_xml_tab,
           lt_xml_tab LIKE TABLE OF ls_xml_tab.

    DATA : lv_path TYPE rlgrap-filename.

    DATA: l_dom      TYPE REF TO if_ixml_element,
          m_document TYPE REF TO if_ixml_document,
          g_ixml     TYPE REF TO if_ixml,
          w_string   TYPE xstring,
          w_size     TYPE i,
          w_result   TYPE i,
          w_line     TYPE string,
          it_xml     TYPE dcxmllines,
          s_xml      LIKE LINE OF it_xml,
          w_rc       LIKE sy-subrc.

    lv_path = zcl_util_59=>file_save_dialog( EXPORTING i_file_filter = 'All files (*.*)|*.*' ).

    CHECK lv_path IS NOT INITIAL.

    CLASS cl_ixml DEFINITION LOAD.
    g_ixml = cl_ixml=>create( ).
    CHECK NOT g_ixml IS INITIAL.
    m_document = g_ixml->create_document( ).
    CHECK NOT m_document IS INITIAL.

    CALL FUNCTION 'SDIXML_DATA_TO_DOM'
      EXPORTING
        name         = i_name
        dataobject   = i_tab[]
      IMPORTING
        data_as_dom  = l_dom
      CHANGING
        document     = m_document
      EXCEPTIONS
        illegal_name = 1
        OTHERS       = 2.

    CHECK sy-subrc = 0.
    CHECK l_dom IS NOT INITIAL.
    w_rc = m_document->append_child( new_child = l_dom ).
    CHECK w_rc IS INITIAL.

    CALL FUNCTION 'SDIXML_DOM_TO_XML'
      EXPORTING
        document      = m_document
        pretty_print  = 'X'
      IMPORTING
        xml_as_string = w_string
        size          = w_size
      TABLES
        xml_as_table  = xml
      EXCEPTIONS
        no_document   = 1
        OTHERS        = 2.

    CHECK sy-subrc = 0.

    LOOP AT xml INTO DATA(ls_xml).
      ls_xml_tab-d = ls_xml.
      INSERT ls_xml_tab INTO TABLE lt_xml_tab.
    ENDLOOP.

    CALL FUNCTION 'WS_DOWNLOAD'
      EXPORTING
*       bin_filesize = w_size
        filename = lv_path
        filetype = 'BIN'
      TABLES
        data_tab = lt_xml_tab
      EXCEPTIONS
        OTHERS   = 10.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
