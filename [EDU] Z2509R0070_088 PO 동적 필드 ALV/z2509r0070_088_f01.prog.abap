*&---------------------------------------------------------------------*
*& Include          Z2509R0070_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
FORM CALL_SCREEN .

  CALL SCREEN 0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT K~EBELN,
         P~EBELP,
         P~MATNR
    FROM EKKO AS K
    JOIN EKPO AS P
      ON K~EBELN EQ P~EBELN
    WHERE K~EBELN IN @SO_EBELN
    ORDER BY K~EBELN, P~EBELP
    INTO TABLE @GT_DATA.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).

    <FS_DATA>-MATNR = |{ <FS_DATA>-MATNR ALPHA = OUT }|.
    MODIFY GT_DATA FROM <FS_DATA>.

  ENDLOOP.

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

*--------------------------------------------------------------------*
* GRID 초기화 : 동적 ITAB 사용을 위한 초기화 및 RECREATE
*  ㄴ ALV GRID는 객체 생성 시점에 단 한번 UI 요소들(컬럼 컨트롤, 셀 렌더링, 이벤트 핸들러 등)의 초기화 진행.
*    ㄴ 컬럼 컨트롤   : 각 컬럼의 ID, 이름, 정렬 방식, 길이, visible 여부 등을 포함
*    ㄴ 셀 렌더링     : 각 셀의 데이터를 어떻게 보여줄지 결정
*    ㄴ 이벤트 핸들러 : 사용자가 셀을 클릭, 편집, 정렬 등 UI 인터렉션 시 발생
*    ㄴ 이때는 껍데기만 만들고 나중에 ITAB를 전달 받음.
*  ㄴ ITAB는 SET_TABLE_FOR_FIRST_DISPLAY 호출 시에 전달되며 컬럼 컨트롤 구성, 셀 렌더러 구성, 이벤트 핸들러 연결 등이 진행됨.
*  ㄴ ITAB 구조가 바뀌는 경우 새로운 ITAB와 예전 데이터가 남아있는 ITAB와 매칭되지 않음.
*--------------------------------------------------------------------*
  IF GO_ALV_GRID IS NOT INITIAL.
    GO_ALV_GRID->FREE( ).
  ENDIF.

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT          = GO_DOCKING       " Parent Container
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
  GS_LAYO-SEL_MODE = 'B'.
  GS_LAYO-ZEBRA = 'X'.

  GV_SAVE = 'A'.
  GS_VARIANT-REPORT = SY-CPROG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT .
*--------------------------------------------------------------------*
* 고정 필드 카탈로그 생성
*--------------------------------------------------------------------*
  CLEAR : GT_FCAT.
  DATA : LS_FCAT LIKE LINE OF GT_FCAT.

  CLEAR : LS_FCAT.
  LS_FCAT-FIELDNAME = 'EBELN'.
  LS_FCAT-COLTEXT = '구매오더번호'.
  LS_FCAT-KEY = 'X'.
  APPEND LS_FCAT TO GT_FCAT.

*--------------------------------------------------------------------*
* 동적 필드 카탈로그 생성을 위한 최대 아이템 개수 구하기
*--------------------------------------------------------------------*
*  SORT GT_DATA BY EBELP DESCENDING.
*  READ TABLE GT_DATA INTO GS_DATA INDEX 1.
*  DATA(LV_MAX) = GS_DATA-EBELP / 10.
*  SORT GT_DATA BY EBELN EBELP.

*--------------------------------------------------------------------*
* REDUCE : ITAB를 순회하며 누적 결과를 만들어내는 표현식
*  ㄴ I : 최종 결과의 데이터 타입 ( 다른 타입으로도 지정 가능 )
*  ㄴ INIT : 초기값
*  ㄴ FOR <FS_DATA> IN GT_DATA : ITAB 순회, 반드시 필드심볼로 사용할 것
*  ㄴ NEXT : 누적값 계산식 정의 -> 여기서는 조건식에 따른 값 할당만 했지만 누적 합계, 레코드 수 세기 등 가능.
*--------------------------------------------------------------------*
  DATA(LV_MAX) = REDUCE I(
    INIT MAX = 0
    FOR <FS_DATA> IN GT_DATA
    NEXT MAX = COND #( WHEN <FS_DATA>-EBELP > MAX THEN <FS_DATA>-EBELP ELSE MAX )
  ) / 10.

  DO LV_MAX TIMES.
    CLEAR : LS_FCAT.
    LS_FCAT-FIELDNAME = |EBELP_{ SY-INDEX }|.
    LS_FCAT-COLTEXT = |아이템 번호 { SY-INDEX }|.
    APPEND LS_FCAT TO GT_FCAT.

    CLEAR : LS_FCAT.
    LS_FCAT-FIELDNAME = |MATNR_{ SY-INDEX }|.
    LS_FCAT-COLTEXT = |재품번호 { SY-TABIX }|.
    APPEND LS_FCAT TO GT_FCAT.
  ENDDO.

*--------------------------------------------------------------------*
* 동적 필드 카탈로그 생성
*--------------------------------------------------------------------*
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG           = GT_FCAT          " 필드 카탈로그를 기준으로
    IMPORTING
      EP_TABLE                  = GT_LIST_R        " 동적 ITAB 생성, 참조 형태로 RETURN
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*--------------------------------------------------------------------*
* FIELD-SYMBOL에 타입을 지정해주는 로직
*--------------------------------------------------------------------*
  UNASSIGN <GT_LIST>.
  " GT_LIST_R->* 는 참조변수가 가리키는 진짜 데이터에 접근하는 '역참조'와 관련된 문법
  " 일반적인 ASSIGN 문법 : ASSIGN [VAR] TO <FS>.
  " 아래 ASSIGN 문법     : ASSIGN [참조변수->*] TO <FS>
  " 일반적인 구조는 동일하나 ASSIGN 대상이 무엇인지에 따라 표현 방식이 조금 달라진 것.
  ASSIGN GT_LIST_R->* TO <GT_LIST>.

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
      IT_OUTTAB                     = <GT_LIST>        " Output Table
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

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DYNAMIC_TABLE
*&---------------------------------------------------------------------*
FORM CREATE_DYNAMIC_TABLE .

  FIELD-SYMBOLS : <FS_LIST>  TYPE DATA,
                  " TYPE DATA : 어떤 타입이든 할당 가능한 동적 타입 변수 -> 완전히 타입이 없으므로 런타임 타입에 따라 값 할당
                  " 실질적인 의미는 어떤 타입이든 될 수 있는 빈껍데기
                  <LV_VALUE> TYPE DATA.

  DATA : LV_DATA  TYPE REF TO DATA,
         LV_FNAME TYPE FIELDNAME,
         LV_POSNR TYPE NUMC2.

  " <GT_LIST>를 기반으로 동적 데이터 객체를 하나 생성 + LV_DATA에 해당 주소를 저장
  CREATE DATA LV_DATA LIKE LINE OF <GT_LIST>.
  " LV_DATA 에 저장된 주소를 기반으로 <FS_LIST>에 할당
  ASSIGN LV_DATA->* TO <FS_LIST>.

  LOOP AT GT_DATA INTO GS_DATA
    GROUP BY ( EBELN = GS_DATA-EBELN ) ASSIGNING FIELD-SYMBOL(<FS_GROUP>).
*--------------------------------------------------------------------*
* 정적 필드
*--------------------------------------------------------------------*
    ASSIGN COMPONENT 'EBELN' OF STRUCTURE <FS_LIST> TO <LV_VALUE>.
    <LV_VALUE> = <FS_GROUP>-EBELN.

    DATA(LV_COUNT) = 1.

*--------------------------------------------------------------------*
* 동적 필드
*--------------------------------------------------------------------*
    LOOP AT GROUP <FS_GROUP> ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
      DATA(LV_FIELDNAME) = |EBELP_{ LV_COUNT }|.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <FS_LIST> TO <LV_VALUE>.
      <LV_VALUE> = <FS_ITEM>-EBELP.

      LV_FIELDNAME = |MATNR_{ LV_COUNT }|.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <FS_LIST> TO <LV_VALUE>.
      <LV_VALUE> = <FS_ITEM>-MATNR.

      LV_COUNT += 1.

    ENDLOOP.

    APPEND <FS_LIST> TO <GT_LIST>.
    CLEAR : <FS_LIST>.

  ENDLOOP.

ENDFORM.
