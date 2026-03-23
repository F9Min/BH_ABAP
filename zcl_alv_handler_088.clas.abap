class ZCL_ALV_HANDLER_088 definition
  public
  final
  create public .

public section.

  data GV_ALV_NAME type STRING .
  data O_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data O_CONTAINER_O type ref to CL_GUI_CONTAINER .
  data O_DOCKING_CONTAINER type ref to CL_GUI_DOCKING_CONTAINER .
  data O_ALV type ref to ZCL_GUI_ALV_GRID .
  data T_FCAT type LVC_T_FCAT .
  data S_LAYO type LVC_S_LAYO .
  data T_EXTOOLBAR type UI_FUNCTIONS .
  data T_F4 type LVC_T_F4 .

  methods ALV_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM .
  methods ALV_DATA_CHANGED_FINISHED
    for event DATA_CHANGED_FINISHED of CL_GUI_ALV_GRID
    importing
      !E_MODIFIED
      !ET_GOOD_CELLS .
  methods ALV_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
  methods ALV_HOTSPOT_CLICK
    for event HOTSPOT_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW_ID
      !E_COLUMN_ID
      !ES_ROW_NO .
  methods ALV_HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE .
  methods ALV_ON_F4
    for event ONF4 of CL_GUI_ALV_GRID
    importing
      !E_FIELDNAME
      !E_FIELDVALUE
      !ES_ROW_NO
      !ER_EVENT_DATA
      !ET_BAD_CELLS
      !E_DISPLAY .
  methods ALV_TOP_OF_PAGE
    for event TOP_OF_PAGE of CL_GUI_ALV_GRID
    importing
      !E_DYNDOC_ID
      !TABLE_INDEX .
  methods ALV_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !SENDER
      !E_UCOMM .
  methods M_10_CREATE_OBJECT .
  methods M_30_ADD_F4_FLD
    importing
      !I_FIELDNAME type FIELDNAME .
  methods M_30_EX_TOOLBAR
    importing
      !IV_REFRESH type CHAR01 optional
      !IV_CUT type CHAR01 optional
      !IV_APPEND type CHAR01 optional
      !IV_INSERT type CHAR01 optional
      !IV_DELETE type CHAR01 optional
      !IV_FILTER type CHAR01 optional
      !IV_SORT_ASC type CHAR01 optional
      !IV_SORT_DSC type CHAR01 optional
      !IV_SUM type CHAR01 optional
      !IV_SUBTOT type CHAR01 optional
      !IV_PRINT type CHAR01 optional
      !IV_EXPORT type CHAR01 optional
      !IV_VARIANT type CHAR01 optional
      !IV_PASTE type CHAR01 optional
      !IV_PASTE_NEW type CHAR01 optional
      !IV_COPY_ROW type CHAR01 optional
      !IV_VIEW type CHAR01 optional
      !IV_CHECK type CHAR01 optional
      !IV_DETAIL type CHAR01 optional
      !IV_COPY type CHAR01 optional
      !IV_INFO type CHAR01 optional
      !IV_UNDO type CHAR01 optional
      !IV_FIND type CHAR01 optional
      !IV_FIND_MORE type CHAR01 optional .
  methods M_30_SET_HANDLER
    importing
      !DOUBLE_CLICK type CHAR01 optional
      !DATA_CHANGED type CHAR01 optional
      !TOP_OF_PAGE type CHAR01 optional
      !HOTSPOT_CLICK type CHAR01 optional
      !DATA_CHANGED_FINISHED type CHAR01 optional
      !F4 type CHAR01 optional
      !TOOLBAR type CHAR01 optional
      !USER_COMMAND type CHAR01 optional .
  methods M_30_SET_LAYOUT
    importing
      !I_FIELD type STRING optional
      !I_VALUE type CLIKE optional .
  methods M_80_DISPLAY_ALV
    changing
      !T_DATA type STANDARD TABLE .
  methods M_90_REFRESH_ALV .
  methods CONSTUCTOR
    importing
      value(ALV_NAME) type STRING optional .
  methods SET_DROP_DOWN_TABLE
    importing
      !IT_DROP_DOWN type LVC_T_DROP .
  methods CHECK_CHANGED_DATA
    exporting
      !E_VALID type CHAR01 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ALV_HANDLER_088 IMPLEMENTATION.


  METHOD ALV_DATA_CHANGED.

    TRY .

        PERFORM handle_data_changed IN PROGRAM (sy-cprog)
            USING gv_alv_name
                  er_data_changed
*                  e_onf4
*                  e_onf4_before
*                  e_onf4_after
                  e_ucomm .
        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  METHOD ALV_DATA_CHANGED_FINISHED.

    TRY .

        PERFORM handle_DATA_CHANGED_FINISHED IN PROGRAM (sy-cprog)
            USING   gv_alv_name    e_modified    et_good_cells  .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  METHOD ALV_DOUBLE_CLICK.

    TRY .

        PERFORM handle_double_click IN PROGRAM (sy-cprog)
            USING    gv_alv_name    e_row    e_column    es_row_no  .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  method ALV_HANDLE_TOOLBAR.

    TRY .

        PERFORM handle_toolbar IN PROGRAM (sy-cprog)
            USING   gv_alv_name    e_object   e_interactive  .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .


  endmethod.


  METHOD ALV_HOTSPOT_CLICK.

    TRY .

        PERFORM handle_hotspot_click IN PROGRAM (sy-cprog)
            USING   gv_alv_name    e_row_id    e_column_id    es_row_no  .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  METHOD ALV_ON_F4.

    TRY .

        PERFORM handle_f4 IN PROGRAM (sy-cprog)
            USING gv_alv_name
                  e_fieldname
                  e_fieldvalue
                  es_row_no
                  er_event_data
                  et_bad_cells
                  e_display .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  METHOD ALV_TOP_OF_PAGE.

    TRY .

        PERFORM handle_top_of_page IN PROGRAM (sy-cprog)
            USING   gv_alv_name    e_dyndoc_id    table_index .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  method ALV_USER_COMMAND.

    TRY .

        PERFORM handle_user_command IN PROGRAM (sy-cprog)
            USING gv_alv_name
                  e_ucomm .

        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  endmethod.


  METHOD CHECK_CHANGED_DATA.

    CALL METHOD o_alv->check_changed_data
      IMPORTING
        e_valid = e_valid.  " Entries are Consistent

  ENDMETHOD.


  method CONSTUCTOR.

    me->gv_alv_name = alv_name .

  endmethod.


  METHOD M_10_CREATE_OBJECT.

    IF o_container IS NOT INITIAL .

      CREATE OBJECT me->o_alv
        EXPORTING
          i_parent = me->o_container.

    ELSEIF o_container_o IS NOT INITIAL .

      CREATE OBJECT me->o_alv
        EXPORTING
          i_parent = me->o_container_o .

    ELSEIF o_docking_container IS NOT INITIAL .

      CREATE OBJECT me->o_alv
        EXPORTING
          i_parent = me->o_docking_container.

    ENDIF .

  ENDMETHOD.


  METHOD M_30_ADD_F4_FLD .

    DATA ls LIKE LINE OF me->t_f4 .

    ls-fieldname = i_fieldname .
    ls-register = 'X' .
    APPEND ls TO me->t_f4 .

  ENDMETHOD.


  METHOD M_30_EX_TOOLBAR.

    REFRESH t_extoolbar .

    IF iv_detail = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_detail TO t_extoolbar .
    ENDIF .
    IF iv_check = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_check TO t_extoolbar .
    ENDIF .
    IF iv_copy = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO t_extoolbar .
    ENDIF .
    IF iv_view = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_view TO t_extoolbar .
    ENDIF .
    IF iv_info = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_info TO t_extoolbar .
    ENDIF .

    IF iv_undo = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_undo TO t_extoolbar .
    ENDIF .
    IF iv_find = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_find TO t_extoolbar .
    ENDIF .
    IF iv_find_more = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_find_more TO t_extoolbar .
    ENDIF .

    IF iv_refresh = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_refresh TO t_extoolbar .
    ENDIF .
    IF iv_cut = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO t_extoolbar .
    ENDIF .
    IF iv_append = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO t_extoolbar .
    ENDIF .
    IF iv_insert = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO t_extoolbar .
    ENDIF .
    IF iv_delete = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO t_extoolbar .
    ENDIF .
    IF iv_sort_asc = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_sort_asc TO t_extoolbar .
    ENDIF .
    IF iv_sort_dsc = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_sort_dsc TO t_extoolbar .
    ENDIF .
    IF iv_sum = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_sum TO t_extoolbar .
    ENDIF .
    IF iv_filter = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_filter TO t_extoolbar .
    ENDIF .
    IF iv_subtot = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_subtot TO t_extoolbar .
    ENDIF .
    IF iv_print = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_print_back TO t_extoolbar .
    ENDIF .
    IF iv_export = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_export TO t_extoolbar .
    ENDIF .
    IF iv_variant = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_variant TO t_extoolbar .
    ENDIF .
    IF iv_paste = 'X' .
      APPEND cl_gui_alv_grid=>mc_mb_paste TO t_extoolbar .
    ENDIF .
    IF iv_paste_new = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row  TO t_extoolbar .
    ENDIF .
    IF iv_paste_new = 'X' .
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row  TO t_extoolbar .
    ENDIF .

  ENDMETHOD.


  METHOD M_30_SET_HANDLER.

    SET HANDLER ME->ALV_DOUBLE_CLICK FOR O_ALV.
    SET HANDLER ME->ALV_USER_COMMAND FOR O_ALV.
    SET HANDLER ME->ALV_HOTSPOT_CLICK FOR O_ALV.
    SET HANDLER ME->ALV_ON_F4 FOR O_ALV.
    SET HANDLER ME->ALV_DATA_CHANGED FOR O_ALV.
    SET HANDLER ME->ALV_DATA_CHANGED_FINISHED FOR O_ALV.
    SET HANDLER ME->ALV_TOP_OF_PAGE FOR O_ALV.
    SET HANDLER ME->ALV_HANDLE_TOOLBAR FOR O_ALV.


*    IF double_click = 'X' .
*      SET HANDLER me->alv_double_click FOR o_alv.
*    ENDIF .
*
*    IF f4 = 'X' .
*
*      SET HANDLER me->alv_on_f4 FOR o_alv.
*
*    ENDIF .
*
*    IF data_changed = 'X' .
*
*      SET HANDLER me->alv_data_changed FOR o_alv.
*
*      CALL METHOD o_alv->register_edit_event
*        EXPORTING
*          i_event_id = o_alv->mc_evt_modified.
*
*    ENDIF .
*
*    IF top_of_page = 'X' .
*      SET HANDLER me->alv_top_of_page FOR o_alv.
*    ENDIF .
*
*    IF hotspot_click = 'X' .
*      SET HANDLER me->alv_hotspot_click FOR o_alv.
*    ENDIF .
*
*    IF data_changed_finished = 'X' .
*      SET HANDLER me->alv_data_changed_finished FOR o_alv.
*    ENDIF .
*
*    IF toolbar = 'X' .
*      SET HANDLER me->alv_handle_toolbar FOR o_alv.
*    ENDIF .
*
*    IF user_command = 'X' .
*      SET HANDLER me->alv_user_command FOR o_alv.
*    ENDIF .

  ENDMETHOD.


  METHOD M_30_SET_LAYOUT .

    DATA lv_fld TYPE string .
    FIELD-SYMBOLS <f> TYPE any .

    lv_fld = |ME->S_LAYO-{ i_field }| .

    UNASSIGN <f> .
    ASSIGN (lv_fld) TO <f> .
    IF <f> IS ASSIGNED .
      <f> = i_value .
    ENDIF .

  ENDMETHOD.


  METHOD M_80_DISPLAY_ALV.

    CALL METHOD o_alv->register_f4_for_fields
      EXPORTING
        it_f4 = me->t_f4.                 " F4 FIELDS

    CALL METHOD o_alv->set_table_for_first_display
      EXPORTING
        is_layout            = s_layo
        it_toolbar_excluding = t_extoolbar
      CHANGING
        it_outtab            = t_data
        it_fieldcatalog      = t_fcat.

  ENDMETHOD.


  METHOD M_90_REFRESH_ALV.

*    o_alv->refresh_table_display( ) .

    DATA: ls_stable TYPE lvc_s_stbl.

    ls_stable-row = abap_true. " 행 위치 유지
    ls_stable-col = abap_true. " 열 위치 유지

    CALL METHOD o_alv->refresh_table_display
      EXPORTING
        is_stable = ls_stable
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.

  ENDMETHOD.


  method SET_DROP_DOWN_TABLE.

    CALL METHOD o_alv->set_drop_down_table
      EXPORTING
        it_drop_down = it_drop_down.  " Dropdown Table

  endmethod.
ENDCLASS.
