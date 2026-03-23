class ZCL_ZGW_TEST02_088_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_TEST02_088_DPC
  create public .

public section.
protected section.

  methods CONNECTIONSET_GET_ENTITY
    redefinition .
  methods CONNECTIONSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_TEST02_088_DPC_EXT IMPLEMENTATION.


  METHOD CONNECTIONSET_GET_ENTITY.

* Entity와 동일한 Structure로 전달받을 수 있다.
* 이때 모든 필드에 값을 채우지 않고, 키 필드에만 값을 채운다.
* 예) /sap/opu/odata/SAP/ZGW100_C20_FLIGHT_SRV/ConnectionSet(Carrid='AA',Connid='0017')
* er_entity 에는 Carrid, Connid 에 'AA', '0017'이 기록된다.
    CALL METHOD IO_TECH_REQUEST_CONTEXT->GET_CONVERTED_KEYS
      IMPORTING
        ES_KEY_VALUES = ER_ENTITY.                 " Entity Key Values - converted

* ( )안의 키 값을 기준으로 데이터를 [ 한 줄만 ] 검색한다 !!!!!!!!!!!!
    SELECT SINGLE FROM SPFLI
      FIELDS *
      WHERE CARRID = @ER_ENTITY-CARRID
        AND CONNID = @ER_ENTITY-CONNID
      INTO CORRESPONDING FIELDS OF @ER_ENTITY.

* 검색이 실패했다면, 적절한 에러 메시지를 Message Container에 담아서 Exception을 발생시킨다.
    IF SY-SUBRC NE 0.
      MO_CONTEXT->GET_MESSAGE_CONTAINER( )->ADD_MESSAGE_TEXT_ONLY(
        IV_MSG_TYPE               = 'E'                                     " Message Type - defined by GCS_MESSAGE_TYPE
        IV_MSG_TEXT               = '해당하는 항공편이 존재하지 않습니다.'  " Message Text
      ).

      RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
        EXPORTING
          TEXTID            = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
          MESSAGE_CONTAINER = MO_CONTEXT->GET_MESSAGE_CONTAINER( ).
    ENDIF.

  ENDMETHOD.


  METHOD CONNECTIONSET_GET_ENTITYSET.

    SELECT FROM SPFLI
      FIELDS CARRID, CONNID, COUNTRYFR, CITYFROM, AIRPFROM,
                             COUNTRYTO, CITYTO,   AIRPTO
      INTO TABLE @DATA(LT_DATA).

    MOVE-CORRESPONDING LT_DATA TO ET_ENTITYSET.

  ENDMETHOD.
ENDCLASS.
