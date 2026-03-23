class ZCL_ZGW_TEST01_088_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_TEST01_088_DPC
  create public .

public section.
protected section.

  methods BUSINESSPARTNERS_GET_ENTITY
    redefinition .
  methods BUSINESSPARTNERS_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_CREATE_ENTITY
    redefinition .
  methods PRODUCTSET_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_TEST01_088_DPC_EXT IMPLEMENTATION.


  METHOD BUSINESSPARTNERS_GET_ENTITY.

* GET_ENTITY 목적 : 관련된 Entity 하나를 조회해서 결과로 내보내는 것
* 결과로 내보내기 위해서는 ER_ENTITY 변수에 값을 기록해야 한다.
* 무슨 값을 기록하는가? 관련된 Entity 하나를 조회해서 기록한다.
* 관련된 Entity는 어떤건가? 비즈니스 파트너(거래처)에 관한 정보다.
* 어떻게 검색하면 되는가? 문제에서는 함수를 호출해서 비즈니스 파트너(거래처)를 조회할 수 있다고 했다.


    DATA LS_BP TYPE BAPI_EPM_BP_ID.     " 타입을 확인하니, 스트럭쳐 타입이다.
    DATA LS_HEADERDATA TYPE BAPI_EPM_BP_HEADER. " 마찬가지로 스트럭쳐 타입이다.
    DATA LT_RETURN      TYPE TABLE OF BAPIRET2.

* 내가 이 함수를 호출할 때 BP_ID를 빈값으로 보내도 내가 원하는 거래처 정보가 조회되는가? 아니다.
* 그럼 내가 원하는 거래처만 조회가 되도록 하려면 어떻게 해야 하는가? LS_BP에 적절한 BP_ID 값을 기록해서 전달해야 한다.
* 어떻게 하면 적절한 BP_ID 값을 찾아서 LS_BP에 기록할 수 있는가? url의 ( ) 안의 값을 활용해서 찾을 수 있다.
* URL의 ( ) 안의 값은 어떻게 가져오는가? IO_TECH_REQUEST_CONTEXT 의 메소드 GET_CONVERTED_KEYS를 통해서 가져올 수 있다.

    CALL METHOD IO_TECH_REQUEST_CONTEXT->GET_CONVERTED_KEYS
      IMPORTING
        ES_KEY_VALUES = ER_ENTITY. " Entity Key Values - converted

    LS_BP-BP_ID = ER_ENTITY-BUSINESSPARTNERID.

* ( ) 안의 거래처코드를 LS_BP에 담았으니 해당 데이터가 올바르게 검색되는지 LT_RETURN으로 결과를 받아오자.
    CALL FUNCTION 'BAPI_EPM_BP_GET_DETAIL'
      EXPORTING
        BP_ID      = LS_BP          " EPM: Business Partner ID to be used in BAPIs
      IMPORTING
        HEADERDATA = LS_HEADERDATA  " EPM: Business Partner header data ( BOR SEPM004 )
      TABLES
        RETURN     = LT_RETURN.     " Return Parameter

    IF LT_RETURN IS NOT INITIAL.
      " RAISE EXCEPTION
    ENDIF.

    ER_ENTITY-BUSINESSPARTNERID = LS_HEADERDATA-BP_ID.
    ER_ENTITY-BUSINESSPARTNERROLE = LS_HEADERDATA-BP_ROLE.

  ENDMETHOD.


  METHOD BUSINESSPARTNERS_GET_ENTITYSET.

    DATA: LT_BP     TYPE TABLE OF BAPI_EPM_BP_HEADER,
          LT_RETURN TYPE TABLE OF BAPIRET2.

    " Filter Query를 위해 BAPI 함수에서 거래처 조회할 때 검색 조건으로 사용할 변수를 선언.
    DATA : LT_SEL_COMPANYNAME TYPE TABLE OF BAPI_EPM_COMPANY_NAME_RANGE,
           LS_SEL_COMPANYNAME TYPE BAPI_EPM_COMPANY_NAME_RANGE.

    " LT_SEL_COMPANYNAME은 $filter로 전달될 CompanyName의 비교값을 가져와야 한다.
    " LT_FILTER는 2개의 필드로 이루어진 ITAB이다.
    DATA LT_FILTER TYPE /IWBEP/T_MGW_SELECT_OPTION.
*    LT_FILTERS = IO_TECH_REQUEST_CONTEXT->GET_FILTER( )->GET_FILTER_SELECT_OPTIONS( ).
    "사실 해당 Method의 Import Parameter인 IT_FILTER_SELECT_OPTIONS의 정보를 받아와도 위와 같은 기능을 한다.
    LT_FILTER = IT_FILTER_SELECT_OPTIONS. " 추천

    DATA LS_FILTER LIKE LINE OF LT_FILTER.
    LOOP AT LT_FILTER INTO LS_FILTER.
      CASE LS_FILTER-PROPERTY.
        WHEN 'CompanyName'.
          " LS_FILTER-SELECT_OPTIONS가 ITAB 형태이기 때문에 LT_SEL_COMPANYNAME에 옮기는 것이 교재에 나온 방식보다 더 나음.
          MOVE-CORRESPONDING LS_FILTER-SELECT_OPTIONS TO LT_SEL_COMPANYNAME.
      ENDCASE.
    ENDLOOP.

    CALL FUNCTION 'BAPI_EPM_BP_GET_LIST'
      TABLES
        SELPARAMCOMPANYNAME = LT_SEL_COMPANYNAME      " EPM : Range for Company name
        BPHEADERDATA        = LT_BP                   " EPM: Business Partner header data ( BOR SEPM004 )
        RETURN              = LT_RETURN.              " Return Parameter

    IF LT_RETURN IS NOT INITIAL .

      MO_CONTEXT->GET_MESSAGE_CONTAINER( )->ADD_MESSAGES_FROM_BAPI( LT_RETURN ).

      RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
        EXPORTING
          TEXTID            = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
          MESSAGE_CONTAINER = MO_CONTEXT->GET_MESSAGE_CONTAINER( ).

    ENDIF.

* 목적: ET_ENTITYSET에 검색된 결과를 기록해서 메소드의 결과로 내보내는 것
*       LT_BP 에 저장된 데이터를 ET_ENTITYSET에 옮겨야 한다.
*       그런데, Data Model에서 내가 직접 Entity Type을 만들었다.
*       하여 ET_ENTITYSET와 LT_BP는 구조가 다를 확률이 매우 높으므로 직접 값을 전달하여 et_entityset을 채우도록 한다.

    DATA: LS_BP     LIKE LINE OF LT_BP,
          LS_ENTITY LIKE LINE OF ET_ENTITYSET.

    LOOP AT LT_BP INTO LS_BP.

      CLEAR LS_ENTITY.

      LS_ENTITY-BUSINESSPARTNERID   = LS_BP-BP_ID.
      LS_ENTITY-BUSINESSPARTNERROLE = LS_BP-BP_ROLE.
      LS_ENTITY-EMAILADDRESS        = LS_BP-EMAIL_ADDRESS.
      LS_ENTITY-COMPANYNAME         = LS_BP-COMPANY_NAME.
      LS_ENTITY-CURRENCYCODE        = LS_BP-CURRENCY_CODE.
      LS_ENTITY-CITY                = LS_BP-CITY.
      LS_ENTITY-STREET              = LS_BP-STREET.
      LS_ENTITY-COUNTRY             = LS_BP-COUNTRY.

      APPEND LS_ENTITY TO ET_ENTITYSET.

    ENDLOOP.

  ENDMETHOD.


  METHOD PRODUCTSET_CREATE_ENTITY.



  ENDMETHOD.


  METHOD PRODUCTSET_GET_ENTITY.

    DATA:
      LT_KEYS       TYPE /IWBEP/T_MGW_TECH_PAIRS,
      LS_KEY        TYPE /IWBEP/S_MGW_TECH_PAIR,
      LS_PRODUCT_ID TYPE BAPI_EPM_PRODUCT_ID,
      LS_HEADERDATA TYPE BAPI_EPM_PRODUCT_HEADER,
      LT_RETURN     TYPE TABLE OF BAPIRET2.

*   /SAP/IPU/ODATA/SAP/ZGW100_C12_STUDENT_SRV/PRODUCTSET('HT-1007')
*   검색조건은 제품ID가 HT-1007 인 제품정보를 조회해서 결과로 내보내야 한다.
    CALL METHOD IO_TECH_REQUEST_CONTEXT->GET_CONVERTED_KEYS
      IMPORTING
        ES_KEY_VALUES = LS_HEADERDATA.

    LS_PRODUCT_ID-PRODUCT_ID = LS_HEADERDATA-PRODUCT_ID.

    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
      EXPORTING
        PRODUCT_ID = LS_PRODUCT_ID              " EPM: Product header data of BOR object SEPM002
      IMPORTING
        HEADERDATA = LS_HEADERDATA              " EPM: Product header data of BOR object SEPM002
      TABLES
        RETURN     = LT_RETURN.                 " Return Parameter

    IF LT_RETURN IS NOT INITIAL.
      " Raise exception
    ENDIF.

    MOVE-CORRESPONDING LS_HEADERDATA TO ER_ENTITY.

  ENDMETHOD.


  METHOD PRODUCTSET_GET_ENTITYSET.

    DATA: LT_HEADERDATA TYPE TABLE OF BAPI_EPM_PRODUCT_HEADER,
          LT_RETURN     TYPE TABLE OF BAPIRET2.

* 제품 목록을 조회하기 위해 호출한 함수
* 함수의 결과로 headerdata 는 제품목록을 전달해주고, return은 오류발생 시 메시지를 전달해준다.

* URL 1. : /ProductSet ( 모든 제품 )
* URL 2. : /BusinessPartnerSet('xxxxxx')/Products ( 'xxxxxx'의 업체가 취급하는 제품들만 )
    CASE IV_SOURCE_NAME.
      WHEN 'BusinessPartner'.

        DATA LS_KEY LIKE LINE OF IT_KEY_TAB. " 작업공간

        " URL에 있는 업체코드를 가져온다.
        READ TABLE IT_KEY_TAB INTO LS_KEY WITH KEY NAME = 'BusinessPartnerID'.
        IF SY-SUBRC EQ 0.
          DATA LS_BP      TYPE BAPI_EPM_BP_ID.
          DATA LS_BP_DATA TYPE BAPI_EPM_BP_HEADER.

          " 업체코드를 검색조건으로 사용하기 위해 LS_BP에 값을 전달
          LS_BP-BP_ID = LS_KEY-VALUE.

          " 업체 상세정보를 조회하는 함수를 호출하여 LS_BP에 들어있는 업체코드 기준의 세부정보를 LS_BP_DATA로 받는다.
          CALL FUNCTION 'BAPI_EPM_BP_GET_DETAIL'
            EXPORTING
              BP_ID      = LS_BP        " EPM: Business Partner ID to be used in BAPIs
            IMPORTING
              HEADERDATA = LS_BP_DATA   " EPM: Business Partner header data ( BOR SEPM004 )
            TABLES
              RETURN     = LT_RETURN.   " Return Parameter

          " BAPI 함수의 결과가 오류인 경우 LT_RETURN에 오류메시지가 담긴다.
          " 하여 LT_RETURN이 비어있지 않으면 Exception을 발생시켜서 사용자에게 오류내용을 전달한다.
          IF LT_RETURN IS NOT INITIAL.
            MO_CONTEXT->GET_MESSAGE_CONTAINER( )->ADD_MESSAGES_FROM_BAPI( LT_RETURN ).
            RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
              EXPORTING
                TEXTID            = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
                MESSAGE_CONTAINER = MO_CONTEXT->GET_MESSAGE_CONTAINER( ).
          ENDIF.

          IF LS_BP_DATA-BP_ROLE EQ '01'. " 01:고객, 02:벤더
            MO_CONTEXT->GET_MESSAGE_CONTAINER( )->ADD_MESSAGE_TEXT_ONLY(
              EXPORTING
                IV_MSG_TYPE = 'E'
                IV_MSG_TEXT = '해당 업체는 고객이므로, 판매하는 제품이 없습니다.'
            ).

            RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
              EXPORTING
                TEXTID            = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
                MESSAGE_CONTAINER = MO_CONTEXT->GET_MESSAGE_CONTAINER( ).
          ENDIF.

          DATA LT_SEL_SUPPLIER_NAME TYPE TABLE OF BAPI_EPM_SUPPLIER_NAME_RANGE.
          DATA LS_SEL_SUPPLIER_NAME TYPE BAPI_EPM_SUPPLIER_NAME_RANGE.

          " 조회한 업체 상세정보 중 회사명을 제품 조회할 때 검색조건으로 사용한다.
          LS_SEL_SUPPLIER_NAME-SIGN = 'I'.
          LS_SEL_SUPPLIER_NAME-OPTION = 'EQ'.
          LS_SEL_SUPPLIER_NAME-LOW = LS_BP_DATA-COMPANY_NAME.
          APPEND LS_SEL_SUPPLIER_NAME TO LT_SEL_SUPPLIER_NAME.

        ENDIF.
    ENDCASE.

    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
      TABLES
        HEADERDATA            = LT_HEADERDATA         " EPM: Product header data of BOR object SEPM002
        SELPARAMSUPPLIERNAMES = LT_SEL_SUPPLIER_NAME  " EPM: BAPI range table for company names
        RETURN                = LT_RETURN.            " Return Parameter

* return의 내용을 전달받은 lt_return이 비어있지 않다면, 오류가 발생했다고 볼 수 있다.
    IF LT_RETURN IS NOT INITIAL.
      " Instance Attribute인 mo_context를 통해 메시지 컨테이너를 가져온다.
      " 가져온 메시지 컨테이너에 bapi 함수의 결과를 전달하여 메시지를 추가한다.
      MO_CONTEXT->GET_MESSAGE_CONTAINER( )->ADD_MESSAGES_FROM_BAPI( LT_RETURN ).

      " Exception을 발생시키는 중, 만약 메시지 컨테이너를 쓰지 않으면, message or message_unlimited 를 통해
      " 오류에 대한 내용을 전달할 수도 있다. 하지만 메시지 컨테이너를 사용할 것을 권장한다.
      RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
        EXPORTING
          TEXTID            = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
          MESSAGE_CONTAINER = MO_CONTEXT->GET_MESSAGE_CONTAINER( ).
    ENDIF.

* 조회한 결과에서 동일한 명칭의 필드끼리만 값을 전달하도록 한다.
*    MOVE-CORRESPONDING lt_headerdata TO et_entityset.
    ET_ENTITYSET = CORRESPONDING #( LT_HEADERDATA ).

  ENDMETHOD.
ENDCLASS.
