class ZCL_ZGW_0010_088_02_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_0010_088_02_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.
PRIVATE SECTION.

  DATA IV_TEMPLATEID TYPE STRING .
  DATA IV_XSTRING TYPE XSTRING .
  DATA IV_TOTAL_PRICE TYPE NETWR .
  DATA : BEGIN OF IS_DATA,
           EBELN   TYPE EKKO-EBELN,
           LIFNR   TYPE EKKO-LIFNR,
           NAME1   TYPE LFA1-NAME1,
           BEDAT   TYPE EKKO-BEDAT,
           ZTERM   TYPE EKKO-ZTERM,
           WAERS   TYPE EKKO-WAERS,
           EKORG   TYPE EKKO-EKORG,
           EKOTX   TYPE T024E-EKOTX,
           EKGRP   TYPE EKKO-EKGRP,
           EKNAM   TYPE T024-EKNAM,
           BUKRS   TYPE EKKO-BUKRS,
           BUTXT   TYPE T001-BUTXT,

           EBELP   TYPE EKPO-EBELP,
           MATNR   TYPE EKPO-MATNR,
           MAKTX   TYPE MAKT-MAKTX,
           LGORT   TYPE EKPO-LGORT,
           LGOBE   TYPE T001L-LGOBE,
           MENGE   TYPE EKPO-MENGE,
           MEINS   TYPE EKPO-MEINS,
           NETPR   TYPE EKPO-NETPR,
           NETPR_C TYPE CHAR30,
           NETWR   TYPE EKPO-NETWR,
           NETWR_C TYPE CHAR30,
         END OF IS_DATA .
  DATA IT_DATA LIKE TABLE OF IS_DATA .
ENDCLASS.



CLASS ZCL_ZGW_0010_088_02_DPC_EXT IMPLEMENTATION.


  METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.

    IF IV_ENTITY_SET_NAME EQ 'ZEDUDV0010_DDL_088'.  " 모든 ENTITY TYPE이 공통으로 사용하는 METHOD 이기 때문에 ENTITY SET NAME으로 구분

      DATA : BEGIN OF LS_DEEP_ENTITY.
               INCLUDE TYPE ZCL_ZGW_0010_088_02_MPC_EXT=>TS_ZEDUDV0010_DDL_088TYPE.
      DATA :   TO_ITEMS TYPE ZCL_ZGW_0010_088_02_MPC_EXT=>TT_ZEDUDV0020_DDL_088TYPE,
             END OF LS_DEEP_ENTITY.

      " LS_DEEP_ENTITY의 구조를 기반으로 동적 구조체인 ER_DEEP_ENTITY 선언
      " ER_DEEP_ENTITY 는 출력값이고, 이 객체에 데이터가 채워지지 않은 경우 UI5 APP에서 오류를 뱉음
      CREATE DATA ER_DEEP_ENTITY LIKE LS_DEEP_ENTITY.

      TRY.
          IO_DATA_PROVIDER->READ_ENTRY_DATA(  " 입력된 데이터 READ
           IMPORTING
             ES_DATA = LS_DEEP_ENTITY
          ).
        CATCH /IWBEP/CX_MGW_TECH_EXCEPTION.
          RETURN.
      ENDTRY.

      IF SY-SUBRC EQ 0.
*--------------------------------------------------------------------*
* CREATE
*--------------------------------------------------------------------*
        IF LS_DEEP_ENTITY-EBELN IS INITIAL.

          DATA : LS_EKKO   TYPE BAPIMEPOHEADER,
                 LS_EKKOX  TYPE BAPIMEPOHEADERX,
                 LT_EKPO   TYPE TABLE OF BAPIMEPOITEM,
                 LT_EKPOX  TYPE TABLE OF BAPIMEPOITEMX,
                 LT_RETURN TYPE TABLE OF BAPIRET2.

          SELECT MATNR,
                 MEINS
            FROM MARA
            INTO TABLE @DATA(LT_MEINS).

          LS_DEEP_ENTITY-WAERS = 'KRW'.

          " Header 세팅
          LS_EKKO-DOC_TYPE = 'NB'.  " 표준 PO 유형
          LS_EKKO-VENDOR = LS_DEEP_ENTITY-LIFNR.
          LS_EKKO-DOC_DATE = LS_DEEP_ENTITY-BEDAT.
          LS_EKKO-PURCH_ORG = LS_DEEP_ENTITY-EKORG.
          LS_EKKO-PUR_GROUP = LS_DEEP_ENTITY-EKGRP.
          LS_EKKO-COMP_CODE = LS_DEEP_ENTITY-BUKRS.
          LS_EKKO-CURRENCY = LS_DEEP_ENTITY-WAERS.

          LS_EKKOX-DOC_TYPE = 'X'.
          LS_EKKOX-VENDOR = 'X'.
          LS_EKKO-DOC_DATE = 'X'.
          LS_EKKOX-PURCH_ORG = 'X'.
          LS_EKKOX-PUR_GROUP = 'X'.
          LS_EKKOX-COMP_CODE = 'X'.
          LS_EKKOX-CURRENCY = 'X'.

          DATA LV_PO_NUMBER TYPE C LENGTH 10.

          DATA(LV_EBELP) = 10.

          " Item & ItemX 세팅
          LOOP AT LS_DEEP_ENTITY-TO_ITEMS ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
            <FS_ITEM>-EBELP = LV_EBELP.
            LV_EBELP += 10.

            <FS_ITEM>-WAERS = 'KRW'.

            READ TABLE LT_MEINS INTO DATA(LS_MEINS) WITH KEY MATNR = <FS_ITEM>-MATNR.
            IF SY-SUBRC EQ 0.
              <FS_ITEM>-MEINS = LS_MEINS-MEINS.
            ENDIF.

            <FS_ITEM>-NETWR = <FS_ITEM>-NETPR * <FS_ITEM>-MENGE.


            APPEND VALUE #(
              PO_ITEM  = <FS_ITEM>-EBELP
              MATERIAL = <FS_ITEM>-MATNR
              QUANTITY = <FS_ITEM>-MENGE
              NET_PRICE = <FS_ITEM>-NETPR
              PLANT    = <FS_ITEM>-WERKS
              STGE_LOC = <FS_ITEM>-LGORT
            ) TO LT_EKPO.

            APPEND VALUE #(
              PO_ITEM = <FS_ITEM>-EBELP
              PO_ITEMX = 'X'
              MATERIAL = 'X'
              QUANTITY = 'X'
              NET_PRICE = 'X'
              PLANT    = 'X'
              STGE_LOC = 'X'
            ) TO LT_EKPOX.

          ENDLOOP.

          " CREATE를 위한 BAPI 태우기
          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              POHEADER         = LS_EKKO
              POHEADERX        = LS_EKKOX
            IMPORTING
              EXPPURCHASEORDER = LV_PO_NUMBER
            TABLES
              RETURN           = LT_RETURN
              POITEM           = LT_EKPO
              POITEMX          = LT_EKPOX.

          " RETURN MESSAGE TYPE에 따른 예외 처리
          LOOP AT LT_RETURN INTO DATA(LS_RETURN).
            IF LS_RETURN-TYPE = 'E' OR LS_RETURN-TYPE = 'A'.
              RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
                EXPORTING
                  TEXTID  = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
                  MESSAGE = LS_RETURN-MESSAGE.
            ENDIF.
          ENDLOOP.

          IF LV_PO_NUMBER IS NOT INITIAL.  " 생성할 아이템이 1건 이상인 경우에만 이후 트랜잭션 진행

            FIELD-SYMBOLS : <LR_ER_ENTITY> LIKE LS_DEEP_ENTITY.

            ASSIGN ER_DEEP_ENTITY->* TO <LR_ER_ENTITY>.

            IF <LR_ER_ENTITY> IS ASSIGNED.
              MOVE-CORRESPONDING LS_DEEP_ENTITY TO <LR_ER_ENTITY>.
              <LR_ER_ENTITY>-EBELN = LV_PO_NUMBER.
            ENDIF.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.                 " Use of Command `COMMIT AND WAIT`

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          ENDIF.
*--------------------------------------------------------------------*
* UPDATE & DELETE
*--------------------------------------------------------------------*
        ELSE.



        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.

    DATA :
      "
      LV_EBELN       TYPE EKKO-EBELN,
      LV_TOTAL_PRICE TYPE CHAR30,
      LV_MAX_LEN     TYPE I VALUE 10,
      " TEMPLATE을 가져오기 위해 필요한 DATA DECLATION
      LT_MIME        TYPE TABLE OF W3MIME,
      LT_SOLIX       TYPE SOLIX_TAB,
      LS_OBJECT      TYPE WWWDATATAB,
      LV_XSTRING     TYPE XSTRING,
      LV_FILESIZE    TYPE I,
      LV_FILESIZEC   TYPE C LENGTH 10,
      LS_STREAM      TYPE TY_S_MEDIA_RESOURCE.

    LOOP AT IT_KEY_TAB ASSIGNING FIELD-SYMBOL(<FS_KEY>).

      CASE <FS_KEY>-NAME.
        WHEN 'EBELN'.
          LV_EBELN = <FS_KEY>-VALUE.
      ENDCASE.

    ENDLOOP.

    CLEAR : IT_DATA.


    SELECT SINGLE *
      FROM WWWDATA
      INTO CORRESPONDING FIELDS OF @LS_OBJECT
      WHERE OBJID = 'Z2511R010_088'.

    CALL FUNCTION 'WWWDATA_IMPORT'
      EXPORTING
        KEY               = LS_OBJECT
      TABLES
        MIME              = LT_MIME
      EXCEPTIONS
        WRONG_OBJECT_TYPE = 1
        IMPORT_ERROR      = 2
        OTHERS            = 3.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF LT_MIME IS INITIAL.
      RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
        EXPORTING
          MESSAGE = 'Template not found'.
    ENDIF.

    CALL FUNCTION 'WWWPARAMS_READ'
      EXPORTING
        RELID = LS_OBJECT-RELID
        OBJID = LS_OBJECT-OBJID
        NAME  = 'filesize'
      IMPORTING
        VALUE = LV_FILESIZEC.

    LV_FILESIZE = LV_FILESIZEC.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        INPUT_LENGTH = LV_FILESIZE     " 반드시 실제 크기
      IMPORTING
        BUFFER       = LV_XSTRING
      TABLES
        BINARY_TAB   = LT_MIME.

    ME->/IWBEP/IF_MGW_CONV_SRV_RUNTIME~SET_HEADER(
       VALUE #( NAME = 'Content-Disposition'
                VALUE = 'attachment; filename="PO_Template.xlsx"' ) ).

    ME->/IWBEP/IF_MGW_CONV_SRV_RUNTIME~SET_HEADER(
       VALUE #( NAME = 'SAP-HTTP-No-Compression'
                VALUE = '1' ) ).

    CLEAR LS_STREAM.
    LS_STREAM-VALUE     = LV_XSTRING.
    LS_STREAM-MIME_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.

    COPY_DATA_TO_REF(
       EXPORTING
         IS_DATA = LS_STREAM
       CHANGING
         CR_DATA = ER_STREAM ).

  ENDMETHOD.
ENDCLASS.
