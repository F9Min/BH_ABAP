*&---------------------------------------------------------------------*
*& Include          ZSDR0160F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_init_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATA .

  S_ERDAT[] =  VALUE #( SIGN = 'I' OPTION = 'BT' ( LOW = |{ SY-DATUM(6) }01|
                                                 HIGH = SY-DATUM ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  DATA : LV_DLVTXT TYPE C LENGTH 100.
  REFRESH GT_DATA.
  CLEAR : GS_DATA.


*1. 주문정보
  SELECT T1~ERDAT, T1~AUDAT, T1~BSTNK, T1~VTWEG, T1~VKBUR, T1~VKGRP, T1~KUNNR,
         T1~WAERK, T1~AUART, T1~VBTYP,
         T2~VBELN, T2~POSNR, T2~SPART, T2~MATNR, T2~ARKTX, T2~WERKS, T2~LGORT,
         T2~VSTEL, T2~NETWR, T2~MWSBP, T2~KWMENG,
*         t2~zzaddrs, t2~zzpstlz,    "USER-EXIT
*         t2~zzpname, t2~zztelno, t2~zzmobno, t2~zzdlmsg, t2~zzextso,         "USER-EXIT
*         t2~zzsbnso, t2~zzexmat, t2~zzexqty, t2~zzexamt, t2~zzwaers,         "USER-EXIT
         T2~LFSTA, T2~MVGR1, T2~MVGR2, T2~MVGR3, T2~MVGR4, T2~MVGR5, T2~VRKME,
         T3~KUNNR AS RGNR, T4~LIFNR AS SENR, T5~PODKZ, T5~KDGRP, T5~BSTKD,
         T6~NAME_ORG1 AS KUNNM,
         RG~NAME_ORG1 AS RGNM, SE~NAME_ORG1 AS SENM,
         T7~BEZEI AS AUARTT, T8~BEZEI AS MVGR1T, T9~BEZEI AS MVGR2T,
         T10~BEZEI AS MVGR3T, T11~BEZEI AS MVGR4T, T12~BEZEI AS MVGR5T,
         T13~VBELV, T13~POSNV, T14~SPRAS
    FROM VBAK AS T1 INNER JOIN VBAP AS T2
      ON T1~VBELN = T2~VBELN
   INNER JOIN VBPA AS T3
      ON T2~VBELN = T3~VBELN
     AND T3~POSNR = '000000'
     AND T3~PARVW = 'RG'
    LEFT JOIN VBPA AS T4
      ON T2~VBELN = T4~VBELN
     AND T4~POSNR = '000000'
     AND T4~PARVW = 'VE'
   INNER JOIN VBKD AS T5
      ON T1~VBELN = T5~VBELN
     AND T5~POSNR = '000000'
    JOIN BUT000 AS T6
      ON T1~KUNNR = T6~PARTNER
    JOIN KNA1 AS T14
      ON T1~KUNNR = T14~KUNNR
    LEFT JOIN BUT000 AS RG
      ON T3~KUNNR = RG~PARTNER
    LEFT JOIN BUT000 AS SE
      ON T4~LIFNR = SE~PARTNER
   INNER JOIN TVAKT AS T7
      ON T1~AUART = T7~AUART
     AND T7~SPRAS = @SY-LANGU
    LEFT JOIN TVM1T AS T8
      ON T2~MVGR1 = T8~MVGR1
     AND T8~SPRAS = @SY-LANGU
    LEFT JOIN TVM2T AS T9
      ON T2~MVGR2 = T9~MVGR2
     AND T9~SPRAS = @SY-LANGU
    LEFT JOIN TVM3T AS T10
      ON T2~MVGR3 = T10~MVGR3
     AND T10~SPRAS = @SY-LANGU
    LEFT JOIN TVM4T AS T11
      ON T2~MVGR4 = T11~MVGR4
     AND T11~SPRAS = @SY-LANGU
    LEFT JOIN TVM5T AS T12
      ON T2~MVGR5 = T12~MVGR5
     AND T12~SPRAS = @SY-LANGU
    LEFT JOIN VBFA AS T13
      ON T2~VBELN = T13~VBELN
     AND T2~POSNR = T13~POSNN
     AND T13~VBTYP_V = 'C'
   WHERE T1~VKORG IN @S_VKORG
     AND T1~ERDAT IN @S_ERDAT
     AND T1~VTWEG IN @S_VTWEG
     AND T1~AUART IN @S_AUART
     AND T1~VKBUR IN @S_VKBUR
     AND T1~VKGRP IN @S_VKGRP
     AND T1~KUNNR IN @S_KUNNR
     AND T1~VBELN IN @S_VBELN
     AND T2~WERKS IN @S_WERKS
     AND T2~SPART IN @S_SPART
     AND T2~MATNR IN @S_MATNR
     AND T2~VSTEL IN @S_VSTEL
     AND T4~LIFNR IN @S_LIFNR
     AND T5~KDGRP IN @S_KDGRP
     AND T2~ABGRU = @SPACE
     AND T5~BSTKD IN @S_BSTKD
    INTO TABLE @DATA(LT_ORDER).


*2. 1을 기준으로 미결주문
  SELECT T1~ERDAT, T1~AUDAT, T1~BSTNK, T1~VTWEG, T1~VKBUR, T1~VKGRP, T1~KUNNR,
         T1~RGNR, T1~KDGRP, T1~VBELN, T1~POSNR, T1~SPART, T1~MATNR, T1~ARKTX,
         T1~WERKS, T1~LGORT, T1~SENR, T1~VSTEL, "t1~zzaddrs, t1~zzpstlz,
         "t1~zzpname, t1~zztelno, t1~zzmobno, t1~zzdlmsg, t1~zzextso, t1~zzsbnso,
         "t1~zzexmat,
         T1~WAERK, T1~RGNM, T1~SENM, T1~NETWR, T1~MWSBP, T1~KUNNM,
         T1~PODKZ, T1~AUART, T1~AUARTT, T1~MVGR1, T1~MVGR1T, T1~MVGR2, T1~MVGR2T,
         T1~MVGR3, T1~MVGR3T, T1~MVGR4, T1~MVGR4T, T1~MVGR5, T1~MVGR5T, T1~KWMENG,
         "t1~zzexqty, t1~zzwaers, t1~zzexamt,
         T1~VRKME, T1~BSTKD, T1~VBELV, T1~POSNV,
         T1~SPRAS, T1~VBTYP,
         T2~ORDQTY_BU, T2~MEINS,
         T1~NETWR + T1~MWSBP AS TOTAMT
    FROM @LT_ORDER AS T1 INNER JOIN VBEP AS T2
      ON T1~VBELN = T2~VBELN
     AND T1~POSNR = T2~POSNR
     AND T2~ETENR = '0001'
   WHERE T1~LFSTA NE 'C'"납품 미완료
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.


*3. 1을 기준으로 납품 진행된 주문
  SELECT T1~ERDAT, T1~AUDAT, T1~BSTNK, T1~VTWEG, T1~VKBUR, T1~VKGRP, T1~KUNNR,
         T1~RGNR, T1~KDGRP, T1~VBELN, T1~POSNR, T1~SPART, T1~MATNR, T1~ARKTX,
         T1~WERKS, T1~LGORT, T1~VSTEL, T1~SENR, "t1~zzaddrs, t1~zzpstlz,
         T1~WAERK, "t1~zzpname, t1~zztelno,  t1~zzmobno, t1~zzdlmsg, t1~zzextso,
         "t1~zzsbnso, t1~zzexmat,
         T1~RGNM, T1~SENM, T1~NETWR, T1~MWSBP, T1~KUNNM,
         T1~PODKZ, T1~AUART, T1~AUARTT, T1~MVGR1, T1~MVGR1T, T1~MVGR2, T1~MVGR2T,
         T1~MVGR3, T1~MVGR3T, T1~MVGR4, T1~MVGR4T, T1~MVGR5, T1~MVGR5T,
         " t1~zzexqty, t1~zzwaers, t1~zzexamt,
         T1~KWMENG, T1~VRKME, T1~BSTKD,
         T1~VBELV, T1~POSNV, T1~SPRAS, T1~VBTYP,
         T2~LFIMG, T2~LFIMG AS ORDQTY_BU, T2~VRKME AS MEINS,
         T2~VBELN AS LI_VBELN, T2~POSNR AS LI_POSNR,
         CASE WHEN T3~WBSTK = 'C' THEN T3~WADAT_IST END AS WADAT_IST,
         CASE WHEN T3~PDSTK = 'C' THEN T3~PODAT END AS PODAT,
         T1~NETWR + T1~MWSBP AS TOTAMT,
         T4~CHARG, T4~VFDAT, T4~HSDAT
    FROM @LT_ORDER AS T1 INNER JOIN LIPS AS T2
      ON T1~VBELN = T2~VGBEL
     AND T1~POSNR = T2~VGPOS
   INNER JOIN LIKP AS T3
      ON T2~VBELN = T3~VBELN
    LEFT OUTER JOIN MCHA AS T4
      ON T2~MATNR = T4~MATNR
     AND T2~WERKS = T4~WERKS
     AND T2~CHARG = T4~CHARG
   WHERE T1~LFSTA IN ( 'B', 'C' ) "납품문서 일부or전체 생성
     AND T2~LFIMG > 0
  APPENDING CORRESPONDING FIELDS OF TABLE @GT_DATA.

  IF GT_DATA IS INITIAL.
    MESSAGE S102(YBHSDS1) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SORT GT_DATA BY ERDAT VBELN POSNR.

  SELECT VTWEG, VTEXT
    FROM TVTWT
   WHERE SPRAS = @SY-LANGU
   ORDER BY VTWEG
    INTO TABLE @DATA(LT_TVTWT).

  SELECT VKBUR, BEZEI
    FROM TVKBT
   WHERE SPRAS = @SY-LANGU
   ORDER BY VKBUR
    INTO TABLE @DATA(LT_TVKBT).

  SELECT VKGRP, BEZEI
    FROM TVGRT
   WHERE SPRAS = @SY-LANGU
   ORDER BY VKGRP
    INTO TABLE @DATA(LT_TVGRT).

  SELECT KDGRP, KTEXT
    FROM T151T
   WHERE SPRAS = @SY-LANGU
   ORDER BY KDGRP
    INTO TABLE @DATA(LT_T151T).

  SORT GT_DATA BY VBELN POSNR.
  LOOP AT GT_DATA INTO GS_DATA.
    AT NEW VBELN.
      DATA(LV_NEW) = ABAP_TRUE.
    ENDAT.
    IF GS_DATA-KWMENG IS NOT INITIAL.
      GS_DATA-NETWR = GS_DATA-NETWR / GS_DATA-KWMENG * GS_DATA-ORDQTY_BU.
      GS_DATA-MWSBP = GS_DATA-MWSBP / GS_DATA-KWMENG * GS_DATA-ORDQTY_BU.
      GS_DATA-TOTAMT = GS_DATA-TOTAMT / GS_DATA-KWMENG * GS_DATA-ORDQTY_BU.
    ENDIF.

*    주문수량 ORDQTY_BU / 총금액  TOTAMT / 공급가  NETWR / 부가세  MWSBP
*    외부주문수량 ZZEXQTY / 외부주문금액 ZZEXAMT

    IF GS_DATA-VBTYP EQ 'H' OR GS_DATA-VBTYP EQ 'K'.
      MULTIPLY GS_DATA-ORDQTY_BU BY -1.
      MULTIPLY GS_DATA-TOTAMT BY -1.
      MULTIPLY GS_DATA-NETWR BY -1.
      MULTIPLY GS_DATA-MWSBP BY -1.
*      MULTIPLY gs_data-zzexqty BY -1.
*      MULTIPLY gs_data-zzexamt BY -1.
    ENDIF.

    IF GS_DATA-VTWEG IS NOT INITIAL.
      GS_DATA-VTWEGT = LT_TVTWT[ VTWEG = GS_DATA-VTWEG ]-VTEXT.
    ENDIF.
    IF GS_DATA-VKBUR IS NOT INITIAL.
      GS_DATA-VKBURT = LT_TVKBT[ VKBUR = GS_DATA-VKBUR ]-BEZEI.
    ENDIF.
    IF GS_DATA-VKGRP IS NOT INITIAL.
      GS_DATA-VKGRPT = LT_TVGRT[ VKGRP = GS_DATA-VKGRP ]-BEZEI.
    ENDIF.
    IF GS_DATA-KDGRP IS NOT INITIAL.
      GS_DATA-KDGRPT = LT_T151T[ KDGRP = GS_DATA-KDGRP ]-KTEXT.
    ENDIF.
    IF LV_NEW IS NOT INITIAL.
      CLEAR LV_NEW.
      PERFORM GET_TEXT USING GS_DATA-SPRAS GS_DATA-VBELN
                  CHANGING LV_DLVTXT.
    ENDIF.

    GS_DATA-DLV_TXT = LV_DLVTXT.

    MODIFY GT_DATA FROM GS_DATA.
    CLEAR GS_DATA.
  ENDLOOP.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_instance
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&      --> GO_DOCKING
*&---------------------------------------------------------------------*
FORM CREATE_INSTANCE  USING    PO_GRID    TYPE REF TO CL_GUI_ALV_GRID
                               PO_DOCKING TYPE REF TO CL_GUI_DOCKING_CONTAINER.

  CREATE OBJECT PO_DOCKING
    EXPORTING
      REPID     = SY-REPID
      DYNNR     = SY-DYNNR
      SIDE      = PO_DOCKING->DOCK_AT_TOP
      EXTENSION = 2000.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT = PO_DOCKING.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_exclude
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FUNC
*&---------------------------------------------------------------------*
FORM SET_GRID_EXCLUDE  USING    PT_FUNC TYPE UI_FUNCTIONS.

  DATA LS_FUNC TYPE UI_FUNC.

  REFRESH PT_FUNC.
*  APPEND cl_gui_alv_grid=>mc_fc_excl_all TO pt_func.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_CHECK TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_CUT TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW TO PT_FUNC.
*  APPEND cl_gui_alv_grid=>mc_fc_subtot TO pt_func.
*  APPEND cl_gui_alv_grid=>mc_fc_sum TO pt_func.
  APPEND CL_GUI_ALV_GRID=>MC_FC_DETAIL TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_REFRESH TO PT_FUNC.
*  APPEND cl_gui_alv_grid=>mc_mb_filter TO pt_func.
  APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_MB_EXPORT TO PT_FUNC.
*  APPEND cl_gui_alv_grid=>mc_fc_current_variant TO pt_func.
*  APPEND cl_gui_alv_grid=>mc_fc_pc_file TO pt_func.
  APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_GRAPH TO PT_FUNC.
  APPEND CL_GUI_ALV_GRID=>MC_FC_INFO TO PT_FUNC.
*  APPEND cl_gui_alv_grid=>mc_mb_variant  TO pt_func.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM SET_GRID_FIELDCAT .


  PERFORM MAKE_FIELDCAT USING :
   'S' 'GT_FCAT' 'FIELDNAME'  'ERDAT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F01,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ERDAT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'AUDAT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F02,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'AUDAT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

*   'S' 'GT_FCAT' 'FIELDNAME'  'BSTNK',
*   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-f03,
*   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
*   ' ' 'GT_FCAT' 'REF_FIELD'  'BSTNK',
*   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'BSTKD',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F03,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBKD',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BSTKD',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VTWEG',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F04,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VTWEG',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VTWEGT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F05,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVTWT',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VTEXT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VKBUR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F06,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VKBUR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VKBURT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F07,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVKBT',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VKGRP',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F08,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VKGRP',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VKGRPT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F09,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVGRT',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'KUNNR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F10,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'KUNNR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'KUNNM',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F11,
   ' ' 'GT_FCAT' 'REF_TABLE'  'BUT000',
   ' ' 'GT_FCAT' 'REF_FIELD'  'NAME_ORG1',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'RGNR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F12,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'KUNNR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'RGNM',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F13,
   ' ' 'GT_FCAT' 'REF_TABLE'  'BUT000',
   ' ' 'GT_FCAT' 'REF_FIELD'  'NAME_ORG1',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'KDGRP',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F14,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBKD',
   ' ' 'GT_FCAT' 'REF_FIELD'  'KDGRP',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'KDGRPT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F15,
   ' ' 'GT_FCAT' 'REF_TABLE'  'T151T',
   ' ' 'GT_FCAT' 'REF_FIELD'  'KTEXT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VBELV',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F65,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBFA',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VBELV',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'POSNV',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F66,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBFA',
   ' ' 'GT_FCAT' 'REF_FIELD'  'POSNV',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'AUART',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F47,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'AUART',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'AUARTT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F48,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVAKT',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VBELN',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F16,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAK',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VBELN',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'POSNR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F17,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'POSNR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'SPART',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F18,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'SPART',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MATNR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F19,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MATNR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ARKTX',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F20,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ARKTX',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ORDQTY_BU',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F21,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBEP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ORDQTY_BU',
   ' ' 'GT_FCAT' 'QFIELDNAME' 'MEINS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

*   gs_fcat-qfieldname

   'S' 'GT_FCAT' 'FIELDNAME'  'WERKS',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F22,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'WERKS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'LGORT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F23,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'LGORT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VSTEL',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F24,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VSTEL',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'LI_VBELN',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F25,
   ' ' 'GT_FCAT' 'REF_TABLE'  'LIKP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VBELN',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'LI_POSNR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F26,
   ' ' 'GT_FCAT' 'REF_TABLE'  'LIPS',
   ' ' 'GT_FCAT' 'REF_FIELD'  'POSNR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'LFIMG',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F27,
   ' ' 'GT_FCAT' 'REF_TABLE'  'LIPS',
   ' ' 'GT_FCAT' 'REF_FIELD'  'LFIMG',
   ' ' 'GT_FCAT' 'QFIELDNAME' 'MEINS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'CHARG',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F59,
   ' ' 'GT_FCAT' 'REF_TABLE'  'LIPS',
   ' ' 'GT_FCAT' 'REF_FIELD'  'CHARG',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VFDAT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F60,
   ' ' 'GT_FCAT' 'REF_TABLE'  'MCHA',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VFDAT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'HSDAT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F61,
   ' ' 'GT_FCAT' 'REF_TABLE'  'MCHA',
   ' ' 'GT_FCAT' 'REF_FIELD'  'HSDAT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'WADAT_IST',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F28,
   ' ' 'GT_FCAT' 'REF_TABLE'  'LIKP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'WADAT_IST',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'PODAT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F30,
   ' ' 'GT_FCAT' 'REF_TABLE'  'LIKP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'PODAT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MEINS',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F31,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MEINS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

*   'S' 'GT_FCAT' 'FIELDNAME'  'KWMENG',
*   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-f32,
*   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
*   ' ' 'GT_FCAT' 'REF_FIELD'  'KWMENG',
*   ' ' 'GT_FCAT' 'QFIELDNAME' 'MEINS',
*   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'TOTAMT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F32,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'NETWR',
   ' ' 'GT_FCAT' 'CFIELDNAME' 'WAERK',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'WAERK',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F33,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'WAERK',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'NETWR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F34,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'NETWR',
   ' ' 'GT_FCAT' 'CFIELDNAME' 'WAERK',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MWSBP',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F35,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MWSBP',
   ' ' 'GT_FCAT' 'CFIELDNAME' 'WAERK',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',


*gs_fcat-
   'S' 'GT_FCAT' 'FIELDNAME'  'SENR',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F36,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBPA',
   ' ' 'GT_FCAT' 'REF_FIELD'  'LIFNR',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'SENM',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F37,
   ' ' 'GT_FCAT' 'REF_TABLE'  'BUT000',
   ' ' 'GT_FCAT' 'REF_FIELD'  'NAME_ORG1',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR1',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F49,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MVGR1',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR1T',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F50,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVM1T',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR2',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F51,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MVGR2',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR2T',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F52,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVM2T',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR3',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F53,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MVGR3',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR3T',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F54,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVM3T',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR4',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F55,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MVGR4',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR4T',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F56,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVM4T',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR5',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F57,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'MVGR2',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'MVGR5T',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F58,
   ' ' 'GT_FCAT' 'REF_TABLE'  'TVM5T',
   ' ' 'GT_FCAT' 'REF_FIELD'  'BEZEI',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZADDRS',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F38,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZADDRS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZPSTLZ',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F39,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZPSTLZ',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZPNAME',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F40,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZPNAME',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZTELNO',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F41,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZTELNO',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZMOBNO',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F42,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZMOBNO',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZDLMSG',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F43,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZDLMSG',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZEXTSO',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F44,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZEXTSO',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZSBNSO',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F45,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZSBNSO',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZEXMAT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F46,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZEXMAT',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZEXQTY',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F62,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZEXQTY',
   ' ' 'GT_FCAT' 'QFIELDNAME' 'VRKME',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'ZZEXAMT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F63,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZEXAMT',
   ' ' 'GT_FCAT' 'CFIELDNAME' 'ZZWAERS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',


   'S' 'GT_FCAT' 'FIELDNAME'  'ZZWAERS',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F64,
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'ZZWAERS',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'VRKME',
   ' ' 'GT_FCAT' 'COLTEXT'    '주문단위',
   ' ' 'GT_FCAT' 'REF_TABLE'  'VBAP',
   ' ' 'GT_FCAT' 'REF_FIELD'  'VRKME',
   ' ' 'GT_FCAT' 'TECH'       'X',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10',

   'S' 'GT_FCAT' 'FIELDNAME'  'DLV_TXT',
   ' ' 'GT_FCAT' 'COLTEXT'    TEXT-F67,
   ' ' 'GT_FCAT' 'INTTYPE'    'C',
   ' ' 'GT_FCAT' 'INTLEN'     '100',
   'E' 'GT_FCAT' 'OUTPUTLEN'  '10'.

*  gs_fcat-intlen

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_FIELDCAT
*&---------------------------------------------------------------------*

FORM MAKE_FIELDCAT USING VALUE(PV_GUBUN)
                         VALUE(PV_ITAB)
                         VALUE(PV_FNAME)
                         VALUE(PV_VALUE).

  DATA: LV_FIELD(50).
  FIELD-SYMBOLS: <FLD>   TYPE ANY,
                 <STR>   TYPE LVC_S_FCAT,
                 <TABLE> TYPE LVC_T_FCAT.

  ASSIGN (PV_ITAB) TO <STR>.

  IF PV_GUBUN EQ 'S'.
    CLEAR LV_FIELD.
    CONCATENATE PV_ITAB '[]' INTO LV_FIELD.
    ASSIGN (LV_FIELD) TO <TABLE>.

    CLEAR <STR>.
    <STR>-COL_POS = LINES( <TABLE> ) + 1.
  ENDIF.

  CONCATENATE '<STR>' '-' PV_FNAME INTO LV_FIELD.
  ASSIGN (LV_FIELD) TO <FLD> .
  <FLD> = PV_VALUE.

  IF PV_GUBUN EQ 'E'.
    CLEAR LV_FIELD.
    CONCATENATE PV_ITAB '[]' INTO LV_FIELD.
    ASSIGN (LV_FIELD) TO <TABLE>.
    APPEND <STR> TO <TABLE>.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_event_receiver
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> go_grid
*&---------------------------------------------------------------------*
FORM CREATE_EVENT_RECEIVER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CREATE OBJECT GO_EVENT_RECEIVER.
  SET HANDLER : GO_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR PO_GRID,
                GO_EVENT_RECEIVER->HANDLE_TOOLBAR FOR PO_GRID,
                GO_EVENT_RECEIVER->HANDLE_USER_COMMAND FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&--> gt_list
*&      --> gt_fcat
*&      --> gt_sort
*&      --> gt_filt
*&      --> gt_func
*&      --> go_grid
*&      --> gs_variant
*&      --> gs_layout
*&---------------------------------------------------------------------*
FORM DISPLAY_GRID  TABLES   PT_OUTTAB
                            PT_FCAT    TYPE LVC_T_FCAT
                            PT_SORT    TYPE LVC_T_SORT
*                            pt_filt    TYPE lvc_t_filt*                            PT_F4      TYPE LVC_T_F4
                            PT_FUNC    TYPE UI_FUNCTIONS
                    USING   PO_GRID    TYPE REF TO CL_GUI_ALV_GRID
                            PS_VARIANT TYPE DISVARIANT
                            PS_LAYOUT  TYPE LVC_S_LAYO.

  CLEAR PS_VARIANT.

  PS_VARIANT-REPORT   = SY-REPID.
  PS_VARIANT-VARIANT = P_VARI.
*  ps_variant-username = sy-uname.*  ps_variant-variant  = ''.

  PS_LAYOUT-SEL_MODE   = 'D'.
  PS_LAYOUT-ZEBRA      = ABAP_TRUE.
  PS_LAYOUT-CWIDTH_OPT = ABAP_TRUE.




  CALL METHOD PO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = PS_VARIANT
      I_SAVE                        = 'A'
      I_BYPASSING_BUFFER            = ABAP_TRUE
*     I_DEFAULT                     =
      IS_LAYOUT                     = PS_LAYOUT
      IT_TOOLBAR_EXCLUDING          = PT_FUNC[]
    CHANGING
      IT_OUTTAB                     = PT_OUTTAB[]
      IT_FIELDCATALOG               = PT_FCAT[]
      IT_SORT                       = PT_SORT[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form handel_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDEL_DOUBLE_CLICK  USING   PS_ROW     TYPE LVC_S_ROW
                                   PS_COLUMN TYPE LVC_S_COL
                                   PS_ROW_NO TYPE  LVC_S_ROID.

  CLEAR GS_DATA.
  CHECK PS_ROW-ROWTYPE IS  INITIAL.

  GS_DATA = GT_DATA[ PS_ROW-INDEX ].

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'VBELN'.
      CHECK GS_DATA-VBELN IS NOT INITIAL.
      SET PARAMETER ID 'AUN' FIELD GS_DATA-VBELN.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    WHEN 'LI_VBELN'.
      CHECK GS_DATA-LI_VBELN IS NOT INITIAL.
      SET PARAMETER ID 'VL' FIELD GS_DATA-LI_VBELN.
      CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_REPID
*&      <-- P_VARI
*&---------------------------------------------------------------------*
FORM F4_VARIANT  USING    PV_REPID
                 CHANGING PV_VARIANT.

*  DATA: ls_variant TYPE disvariant,
  DATA: LS_VARIANT TYPE DISVARIANT,
        L_EXIT     TYPE CHAR1.


  LS_VARIANT-REPORT = PV_REPID."sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT         = LS_VARIANT
      I_SAVE             = 'A'
      I_DISPLAY_VIA_GRID = 'X'
*     it_default_fieldcat =
    IMPORTING
      E_EXIT             = L_EXIT
      ES_VARIANT         = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND          = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF L_EXIT EQ SPACE.
      PV_VARIANT = LS_VARIANT-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA_SPRAS
*&      --> GS_DATA_VBELN
*&      <-- GS_DATA_DLV_TXT
*&---------------------------------------------------------------------*
FORM GET_TEXT  USING    VALUE(PV_SPRAS)
                        VALUE(PV_VBELN)
               CHANGING PV_TEXT.


  DATA LV_LANGUAGE         TYPE THEAD-TDSPRAS.
  DATA LV_NAME             TYPE THEAD-TDNAME.
  DATA LT_LINES            TYPE STANDARD TABLE OF TLINE.

  CLEAR PV_TEXT.

  LV_LANGUAGE = PV_SPRAS.
  LV_NAME = PV_VBELN.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID                      = 'Z001'
      LANGUAGE                = LV_LANGUAGE
      NAME                    = LV_NAME
      OBJECT                  = 'VBBK'
    TABLES
      LINES                   = LT_LINES
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CHECK LT_LINES IS NOT INITIAL.

  LOOP AT LT_LINES INTO DATA(LS_LINES).
    PV_TEXT = PV_TEXT && LS_LINES-TDLINE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING    PO_OBJECT	TYPE REF TO	CL_ALV_EVENT_TOOLBAR_SET
                              PV_INTERACTIVE TYPE  CHAR01.

  DATA LS_TOOLBAR TYPE STB_BUTTON.

*  CLEAR ls_toolbar.
**  ls_toolbar-icon = icon_refresh.
*  ls_toolbar-butn_type = 3.
*  APPEND ls_toolbar TO po_object->mt_toolbar.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION = 'REFRESH'.
  LS_TOOLBAR-ICON = ICON_REFRESH.
  LS_TOOLBAR-QUICKINFO = TEXT-BT1.
  APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING    PV_UCOMM TYPE SY-UCOMM.
  CASE PV_UCOMM.
    WHEN 'REFRESH'.
      PERFORM GET_DATA.
      PERFORM REFRESH_GRID TABLES GT_FCAT
                            USING GS_LAYOUT GS_VARIANT
                                  GO_GRID '' '' '' ''.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GS_LAYOUT
*&      --> GS_VARIANT
*&      --> GO_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  TABLES   PT_FIELDCAT TYPE STANDARD TABLE "GT_FIELDCAT1
                   USING PS_LAYOUT TYPE LVC_S_LAYO        "GS_LAYOUT1
                         PS_VARIANT TYPE DISVARIANT
                         PO_GRID TYPE REF TO CL_GUI_ALV_GRID       "GRID1
                         P_LAYOUT     "X
                         P_FIELDCAT   "X
                         P_TOOL       "X
                         P_SOFT.      "X

  DATA: LS_STABLE   TYPE LVC_S_STBL,
        LT_FIELDCAT TYPE LVC_T_FCAT,
        LS_VARIANT  LIKE DISVARIANT.
  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

*  FIELD-SYMBOLS:  TYPE REF TO cl_gui_alv_grid.
*  ASSIGN (p_grid) TO .
*
*  CHECK  IS BOUND.

*  CONCATENATE p_grid(1) p_grid+4(1) INTO gs_variant-handle.
  LS_VARIANT = PS_VARIANT.
  LT_FIELDCAT[] = PT_FIELDCAT[].
  CALL FUNCTION 'LVC_VARIANT_SELECT'
    EXPORTING
      I_DIALOG            = SPACE
      I_USER_SPECIFIC     = 'X'
      IT_DEFAULT_FIELDCAT = LT_FIELDCAT[]
    IMPORTING
      ET_FIELDCAT         = LT_FIELDCAT[]
    CHANGING
      CS_VARIANT          = LS_VARIANT
    EXCEPTIONS
      WRONG_INPUT         = 1
      FC_NOT_COMPLETE     = 2
      NOT_FOUND           = 3
      PROGRAM_ERROR       = 4
      DATA_MISSING        = 5
      OTHERS              = 6.
  IF LS_VARIANT IS NOT INITIAL.
    PS_VARIANT = LS_VARIANT.
    PT_FIELDCAT[] = LT_FIELDCAT[].
  ENDIF.

  IF P_LAYOUT = 'X'.
    CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = PS_LAYOUT.
  ENDIF.

  IF P_FIELDCAT = 'X'.
    CALL METHOD PO_GRID->SET_FRONTEND_FIELDCATALOG
      EXPORTING
        IT_FIELDCATALOG = PT_FIELDCAT[].
  ENDIF.

  IF P_TOOL = 'X'.
    CALL METHOD PO_GRID->SET_TOOLBAR_INTERACTIVE.
  ENDIF.

  CALL METHOD PO_GRID->SET_VARIANT
    EXPORTING
      IS_VARIANT = PS_VARIANT
      I_SAVE     = 'A'.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE
      I_SOFT_REFRESH = P_SOFT.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_AMDP
*&---------------------------------------------------------------------*
FORM GET_DATA_AMDP .

  DATA(LV_WHERE_CLAUSE) = CL_SHDB_SELTAB=>COMBINE_SELTABS(
    IT_NAMED_SELTABS = VALUE #(
      ( NAME = 'VKORG' DREF = REF #( S_VKORG[] ) )
      ( NAME = 'ERDAT' DREF = REF #( S_ERDAT[] ) )
      ( NAME = 'VTWEG' DREF = REF #( S_VTWEG[] ) )
      ( NAME = 'AUART' DREF = REF #( S_AUART[] ) )
      ( NAME = 'VKBUR' DREF = REF #( S_VKBUR[] ) )
      ( NAME = 'VKGRP' DREF = REF #( S_VKGRP[] ) )
      ( NAME = 'KDGRP' DREF = REF #( S_KDGRP[] ) )
      ( NAME = 'KUNNR' DREF = REF #( S_KUNNR[] ) )
      ( NAME = 'WERKS' DREF = REF #( S_WERKS[] ) )
      ( NAME = 'SPART' DREF = REF #( S_SPART[] ) )
      ( NAME = 'MATNR' DREF = REF #( S_MATNR[] ) )
      ( NAME = 'VSTEL' DREF = REF #( S_VSTEL[] ) )
      ( NAME = 'LIFNR' DREF = REF #( S_LIFNR[] ) )
      ( NAME = 'VBELN' DREF = REF #( S_VBELN[] ) )
      ( NAME = 'BSTKD' DREF = REF #( S_BSTKD[] ) )
    ) IV_CLIENT_FIELD = 'MANDT'
  ).

  ZCL_AMDP_ORDER_STATUS=>GET_SALES_ORDER(
    EXPORTING
      IV_CLIENT  = SY-MANDT
      IV_FILTERS = LV_WHERE_CLAUSE
    IMPORTING
      ET_RESULTS = GT_DATA
  ).

ENDFORM.
