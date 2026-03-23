FUNCTION ZEDU_QUT_TO_S4H.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_HEAD) TYPE  ZDEDUS0040_088
*"     VALUE(IT_ITEM) TYPE  ZDEDUT0020_088
*"  EXPORTING
*"     VALUE(IV_FLAG) TYPE  ZIFFLG_088
*"     VALUE(IV_MSG) TYPE  STRING
*"----------------------------------------------------------------------
  " QUTNO 점검용 Variable Declation
  DATA : BEGIN OF GS_HEAD,
           QUTNO TYPE ZMMT0530_088-QUTNO,
         END OF GS_HEAD,
         GT_HEAD LIKE TABLE OF GS_HEAD.

  " QUOT Header 저장용 Variable Declation
  DATA : BEGIN OF GS_QUT_H,
           QUTNO  TYPE ZMMT0530_088-QUTNO,
           DLVDT  TYPE ZMMT0530_088-DLVDT,
           ERDAT  TYPE ZMMT0530_088-ERDAT,
           CHDAT  TYPE ZMMT0530_088-CHDAT,
           ZIFFLG TYPE ZMMT0530_088-ZIFFLG,
           ZIFDAT TYPE ZMMT0530_088-ZIFDAT,
           ZIFTIM TYPE ZMMT0530_088-ZIFTIM,
         END OF GS_QUT_H,
         GT_QUT_H LIKE TABLE OF GS_QUT_H.

  " QUOT Itme 저장용 Variable Declation
  DATA : BEGIN OF GS_QUT_I,
           QUTNO TYPE ZMMT0540_088-QUTNO,
           QUTSQ TYPE ZMMT0540_088-QUTSQ,
           QUDAT TYPE ZMMT0540_088-QUDAT,
           RFQNO TYPE ZMMT0540_088-RFQNO,
           RFQSQ TYPE ZMMT0540_088-RFQSQ,
           RFQDT TYPE ZMMT0540_088-RFQDT,
           MATNR TYPE ZMMT0540_088-MATNR,
           MENGE TYPE ZMMT0540_088-MENGE,
           NETPR TYPE ZMMT0540_088-NETPR,
           NETWR TYPE ZMMT0540_088-NETWR,
           MEINS TYPE ZMMT0540_088-MEINS,
           WAERS TYPE ZMMT0540_088-WAERS,
         END OF GS_QUT_I,
         GT_QUT_I LIKE TABLE OF GS_QUT_I.

  DATA : GV_INITIAL_FOUND.

  SELECT SINGLE QUTNO
    INTO GS_HEAD
    FROM ZMMT0530_088
    WHERE QUTNO = IS_HEAD-QUTNO.

  IF SY-SUBRC EQ 0.
    MESSAGE '이미 존재하는 Quotation 입니다.' TYPE 'E'.
  ENDIF.

*"----------------------------------------------------------------------
*"  헤더 정보 유효성 검사
*"----------------------------------------------------------------------
  DO.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE IS_HEAD TO FIELD-SYMBOL(<FS_HEAD>).

    IF SY-SUBRC NE 0.
      EXIT.  " 더 이상 필드가 없는 경우
    ENDIF.

    IF <FS_HEAD> IS INITIAL.
      GV_INITIAL_FOUND = ABAP_ON.
      EXIT.  " 필수 파라미터가 누락된 경우
    ENDIF.

  ENDDO.

  IF GV_INITIAL_FOUND EQ ABAP_ON.
    MESSAGE '필수 파라미터가 누락되었습니다.' TYPE 'E'.
    CLEAR : GV_INITIAL_FOUND.
    RETURN.
  ENDIF.

*"----------------------------------------------------------------------
*"  헤더 정보 이관
*"----------------------------------------------------------------------
  GS_QUT_H-QUTNO = IS_HEAD-QUTNO.
  GS_QUT_H-DLVDT = IS_HEAD-LFDAT.
  GS_QUT_H-ERDAT = IS_HEAD-QUDAT.

  GS_QUT_H-CHDAT = SY-DATUM.
  GS_QUT_H-ZIFTIM = SY-UZEIT.

  LOOP AT IT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
*"----------------------------------------------------------------------
*"  아이템 정보 유효성 검사
*"----------------------------------------------------------------------
    DO.
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <FS_ITEM> TO FIELD-SYMBOL(<FS_ITEM_VALID>).

      IF SY-SUBRC NE 0.
        EXIT.  " 더 이상 필드가 없는 경우

      ENDIF.

      IF <FS_ITEM_VALID> IS INITIAL.
        GV_INITIAL_FOUND = ABAP_ON.
        EXIT.  " 필수 파라미터가 누락된 경우

      ENDIF.

    ENDDO.

    IF GV_INITIAL_FOUND EQ ABAP_ON.
      MESSAGE '필수 파라미터가 누락되었습니다.' TYPE 'E'.
      CLEAR : GV_INITIAL_FOUND.
      RETURN.

    ELSE.

*"----------------------------------------------------------------------
*"  아이템 정보 이관
*"----------------------------------------------------------------------
      CLEAR : GS_QUT_I.

      MOVE-CORRESPONDING <FS_ITEM> TO GS_QUT_I.
      GS_QUT_I-QUTNO = IS_HEAD-QUTNO.
      GS_QUT_I-RFQDT = IS_HEAD-LFDAT.

      APPEND GS_QUT_I TO GT_QUT_I.

    ENDIF.

  ENDLOOP.

ENDFUNCTION.
