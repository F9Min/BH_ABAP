*&---------------------------------------------------------------------*
*& Report ztest_select_cds
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_SELECT_CDS.

START-OF-SELECTION.

  SELECT FROM ZEDUDV0010_DDL_088
    FIELDS
      \_ITEMS[ (1) ]-EBELN  AS EBELN,
      \_ITEMS[ (1) ]-EBELP AS EBELP
    INTO TABLE @DATA(RESULT).

  LOOP AT RESULT INTO DATA(LS_RESULT).
    WRITE :/ LS_RESULT-EBELN, LS_RESULT-EBELP.
  ENDLOOP.
