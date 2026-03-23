CLASS ZCL_AMDP_ORDER_STATUS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES IF_AMDP_MARKER_HDB.

    TYPES : BEGIN OF TS_DATA,
              VBELN     TYPE VBAK-VBELN,
              POSNR     TYPE VBAP-POSNR,
              ERDAT     TYPE VBAK-ERDAT,
              AUDAT     TYPE VBAK-AUDAT,
              BSTNK     TYPE VBAK-BSTNK,
              BSTKD     TYPE VBKD-BSTKD,
              VTWEG     TYPE VBAK-VTWEG,
              VTWEGT    TYPE TVTWT-VTEXT,
              VKBUR     TYPE VBAK-VKBUR,
              VKBURT    TYPE TVKBT-BEZEI,
              VKGRP     TYPE VBAK-VKGRP,
              VKGRPT    TYPE TVGRT-BEZEI,
              KUNNR     TYPE VBAK-KUNNR,
              KUNNM     TYPE BUT000-NAME_ORG1,
              SPRAS     TYPE KNA1-SPRAS,
              RGNR      TYPE VBPA-KUNNR,
              RGNM      TYPE BUT000-NAME_ORG1,
              KDGRP     TYPE VBKD-KDGRP,
              KDGRPT    TYPE T151T-KTEXT,
              VBELV     TYPE VBFA-VBELV,
              POSNV     TYPE VBFA-POSNV,
              PODKZ     TYPE VBKD-PODKZ,
              AUART     TYPE VBAK-AUART,
              AUARTT    TYPE TVAKT-BEZEI,
              VBTYP     TYPE VBAK-VBTYP,

              SPART     TYPE VBAP-SPART,
              MATNR     TYPE VBAP-MATNR,
              ARKTX     TYPE VBAP-ARKTX,
              MVGR1     TYPE VBAP-MVGR1,
              MVGR1T    TYPE TVM1T-BEZEI,
              MVGR2     TYPE VBAP-MVGR2,
              MVGR2T    TYPE TVM2T-BEZEI,
              MVGR3     TYPE VBAP-MVGR3,
              MVGR3T    TYPE TVM3T-BEZEI,
              MVGR4     TYPE VBAP-MVGR4,
              MVGR4T    TYPE TVM4T-BEZEI,
              MVGR5     TYPE VBAP-MVGR5,
              MVGR5T    TYPE TVM5T-BEZEI,
              ORDQTY_BU TYPE VBEP-ORDQTY_BU, "주문수량
              WERKS     TYPE VBAP-WERKS,
              LGORT     TYPE VBAP-LGORT,
              VSTEL     TYPE VBAP-VSTEL,
              LI_VBELN  TYPE LIKP-VBELN,
              LI_POSNR  TYPE LIPS-POSNR,
              LFIMG     TYPE LIPS-LFIMG,
              CHARG     TYPE LIPS-CHARG,
              VFDAT     TYPE MCHA-VFDAT,
              HSDAT     TYPE MCHA-HSDAT,
              WADAT_IST TYPE LIKP-WADAT_IST,
              PODAT     TYPE LIKP-PODAT,
              MEINS     TYPE MEINS,
              KWMENG    TYPE VBAP-KWMENG,
              WAERK     TYPE VBAP-WAERK,
              NETWR     TYPE VBAP-NETWR,
              MWSBP     TYPE VBAP-MWSBP,
              TOTAMT    TYPE VBAP-NETWR,
              SENR      TYPE VBPA-KUNNR,
              SENM      TYPE BUT000-NAME_ORG1,
              VRKME     TYPE VBAP-VRKME,
              DLV_TXT   TYPE C LENGTH 100,
            END OF TS_DATA,

            TT_DATA TYPE STANDARD TABLE OF TS_DATA.

    CLASS-METHODS GET_SALES_ORDER
      IMPORTING
        VALUE(IV_CLIENT)  TYPE SY-MANDT
        VALUE(IV_FILTERS) TYPE STRING
      EXPORTING
        VALUE(ET_RESULTS) TYPE TT_DATA.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AMDP_ORDER_STATUS IMPLEMENTATION.

  METHOD GET_SALES_ORDER BY DATABASE PROCEDURE
                         FOR HDB
                         LANGUAGE SQLSCRIPT
                         USING VBAK VBAP VBPA VBKD BUT000 KNA1 TVAKT TVM1T TVM2T TVM3T TVM4T TVM5T VBFA VBEP LIPS LIKP MCHA TVTWT TVKBT TVGRT T151T.


    lt_base =
      SELECT t1.mandt, t1.vbeln, t2.posnr, t1.erdat, t1.audat, t1.bstnk, t1.vtweg, t1.vkbur, t1.vkgrp, t1.kunnr,
             t1.waerk, t1.auart, t1.vbtyp, t2.lfsta, t1.vkorg,
             t2.spart, t2.matnr, t2.arktx, t2.werks, t2.lgort, t2.vstel, t2.netwr, t2.mwsbp, t2.kwmeng, t2.vrkme,
             t2.mvgr1, t2.mvgr2, t2.mvgr3, t2.mvgr4, t2.mvgr5,
             t3.kunnr AS rgnr,
             t4.lifnr,
             t4.lifnr AS senr,
             t5.podkz, t5.kdgrp, t5.bstkd,
             t6.name_org1 AS kunnm, rg.name_org1 AS rgnm, se.name_org1 AS senm,
             t7.bezei AS auartt, t8.bezei AS mvgr1t, t9.bezei AS mvgr2t,
             t10.bezei AS mvgr3t, t11.bezei AS mvgr4t, t12.bezei AS mvgr5t,
             t13.vbelv, t13.posnv, t14.spras
        FROM vbak AS t1
       INNER JOIN vbap AS t2 ON t1.mandt = t2.mandt AND t1.vbeln = t2.vbeln
       INNER JOIN vbpa AS t3 ON t2.mandt = t3.mandt AND t2.vbeln = t3.vbeln AND t3.posnr = '000000' AND t3.parvw = 'RG'
        LEFT OUTER JOIN vbpa AS t4 ON t2.mandt = t4.mandt AND t2.vbeln = t4.vbeln AND t4.posnr = '000000' AND t4.parvw = 'VE'
       INNER JOIN vbkd AS t5 ON t1.mandt = t5.mandt AND t1.vbeln = t5.vbeln AND t5.posnr = '000000'
        LEFT OUTER JOIN but000 AS t6 ON t1.mandt = t6.client AND t1.kunnr = t6.partner
       INNER JOIN kna1 AS t14 ON t1.mandt = t14.mandt AND t1.kunnr = t14.kunnr
        LEFT OUTER JOIN but000 AS rg ON t3.mandt = rg.client AND t3.kunnr = rg.partner
        LEFT OUTER JOIN but000 AS se ON t4.mandt = se.client AND t4.lifnr = se.partner
       INNER JOIN tvakt AS t7 ON t1.mandt = t7.mandt AND t1.auart = t7.auart AND t7.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvm1t AS t8 ON t2.mandt = t8.mandt AND t2.mvgr1 = t8.mvgr1 AND t8.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvm2t AS t9 ON t2.mandt = t9.mandt AND t2.mvgr2 = t9.mvgr2 AND t9.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvm3t AS t10 ON t2.mandt = t10.mandt AND t2.mvgr3 = t10.mvgr3 AND t10.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvm4t AS t11 ON t2.mandt = t11.mandt AND t2.mvgr4 = t11.mvgr4 AND t11.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvm5t AS t12 ON t2.mandt = t12.mandt AND t2.mvgr5 = t12.mvgr5 AND t12.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN vbfa AS t13 ON t2.mandt = t13.mandt AND t2.vbeln = t13.vbeln AND t2.posnr = t13.posnn AND t13.vbtyp_v = 'C'
       WHERE t1.mandt = :iv_client
         AND t2.abgru = '';

    lt_filtered = APPLY_FILTER( :lt_base, :iv_filters );

    lt_open =
      SELECT t1.*, t2.ordqty_bu, t2.meins,
             (t1.netwr + t1.mwsbp) AS totamt_base,
             '' AS li_vbeln, '000000' AS li_posnr, 0.0 AS lfimg,
             '' AS charg, '00000000' AS vfdat, '00000000' AS hsdat,
             '00000000' AS wadat_ist, '00000000' AS podat
        FROM :lt_filtered AS t1
       INNER JOIN vbep AS t2 ON t1.mandt = t2.mandt AND t1.vbeln = t2.vbeln AND t1.posnr = t2.posnr AND t2.etenr = '0001'
       WHERE t1.lfsta != 'C';

       lt_dlv =
      SELECT t1.*, t2.lfimg AS ordqty_bu, t2.vrkme AS meins,
             (t1.netwr + t1.mwsbp) AS totamt_base,
             t2.vbeln AS li_vbeln, t2.posnr AS li_posnr, t2.lfimg,
             t4.charg, t4.vfdat, t4.hsdat,
             CASE WHEN t3.wbstk = 'C' THEN t3.wadat_ist ELSE '00000000' END AS wadat_ist,
             CASE WHEN t3.pdstk = 'C' THEN t3.podat ELSE '00000000' END AS podat
        FROM :lt_filtered AS t1
       INNER JOIN lips AS t2 ON t1.mandt = t2.mandt AND t1.vbeln = t2.vgbel AND t1.posnr = t2.vgpos
       INNER JOIN likp AS t3 ON t2.mandt = t3.mandt AND t2.vbeln = t3.vbeln
        LEFT OUTER JOIN mcha AS t4 ON t2.mandt = t4.mandt AND t2.matnr = t4.matnr AND t2.werks = t4.werks AND t2.charg = t4.charg
       WHERE t1.lfsta IN ('B', 'C')
         AND t2.lfimg > 0;

    lt_union =
      SELECT * FROM :lt_open
      UNION ALL
      SELECT * FROM :lt_dlv;

    et_results =
      SELECT u.vbeln, u.posnr, u.erdat, u.audat, u.bstnk, u.bstkd, u.vtweg,
             txt1.vtext AS vtwegt,
             u.vkbur,
             txt2.bezei AS vkburt,
             u.vkgrp,
             txt3.bezei AS vkgrpt,
             u.kunnr, u.kunnm, u.spras, u.rgnr, u.rgnm, u.kdgrp,
             txt4.ktext AS kdgrpt,
             u.vbelv, u.posnv, u.podkz, u.auart, u.auartt, u.vbtyp,
             u.spart, u.matnr, u.arktx, u.mvgr1, u.mvgr1t, u.mvgr2, u.mvgr2t,
             u.mvgr3, u.mvgr3t, u.mvgr4, u.mvgr4t, u.mvgr5, u.mvgr5t,

             -- 반품(H, K) 여부에 따른 마이너스(-) 처리 적용
             ( CASE WHEN u.vbtyp IN ('H', 'K') THEN -1 ELSE 1 END * u.ordqty_bu ) AS ordqty_bu,

             u.werks, u.lgort, u.vstel, u.li_vbeln, u.li_posnr,
             ( CASE WHEN u.vbtyp IN ('H', 'K') THEN -1 ELSE 1 END * u.lfimg ) AS lfimg,
             u.charg, u.vfdat, u.hsdat, u.wadat_ist, u.podat, u.meins, u.kwmeng, u.waerk,

             -- [핵심] 수량 비율에 따른 금액 계산 (Zero Division 방지 로직 포함)
             ( CASE WHEN u.vbtyp IN ('H', 'K') THEN -1 ELSE 1 END * CASE WHEN u.kwmeng <> 0 THEN (u.netwr * u.ordqty_bu / u.kwmeng) ELSE u.netwr END ) AS netwr,

             ( CASE WHEN u.vbtyp IN ('H', 'K') THEN -1 ELSE 1 END * CASE WHEN u.kwmeng <> 0 THEN (u.mwsbp * u.ordqty_bu / u.kwmeng) ELSE u.mwsbp END ) AS mwsbp,

             ( CASE WHEN u.vbtyp IN ('H', 'K') THEN -1 ELSE 1 END * CASE WHEN u.kwmeng <> 0 THEN (u.totamt_base * u.ordqty_bu / u.kwmeng) ELSE u.totamt_base END ) AS totamt,

             u.senr, u.senm, u.vrkme,
             '' AS dlv_txt -- 이 컬럼은 ABAP 단으로 넘어가서 LOOP 돌면서 채워집니다.

        FROM :lt_union AS u
        LEFT OUTER JOIN tvtwt AS txt1 ON u.mandt = txt1.mandt AND u.vtweg = txt1.vtweg AND txt1.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvkbt AS txt2 ON u.mandt = txt2.mandt AND u.vkbur = txt2.vkbur AND txt2.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN tvgrt AS txt3 ON u.mandt = txt3.mandt AND u.vkgrp = txt3.vkgrp AND txt3.spras = SESSION_CONTEXT('LOCALE_SAP')
        LEFT OUTER JOIN t151t AS txt4 ON u.mandt = txt4.mandt AND u.kdgrp = txt4.kdgrp AND txt4.spras = SESSION_CONTEXT('LOCALE_SAP');

  ENDMETHOD.

ENDCLASS.
