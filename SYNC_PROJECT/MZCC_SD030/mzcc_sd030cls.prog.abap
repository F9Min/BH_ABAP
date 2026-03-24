*&---------------------------------------------------------------------*
*& Include          MZCC_SD030CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS :

      " 데이터 변경 시 발생항 DATA CHANGED HANDLER METHOD DEFINITION
      ON_DATA_CHANGED FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED,

      " 데이터 변경 시 발생항 DATA CHANGED HANDLER METHOD DEFINITION
      ON_DATA_CHANGED_FINISHED FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
        IMPORTING E_MODIFIED SENDER.

ENDCLASS.
CLASS LCL_APPLICATION DEFINITION.
  " Tree의 작동을 위한 Class 선언

  PUBLIC SECTION.
    METHODS :
      " TREE의 NODE를 더블클릭할 경우 발생할 EVENT HANDELR METHOD DEFINITION
      HANDLE_NODE_DOUBLE_CLICK FOR EVENT NODE_DOUBLE_CLICK OF CL_GUI_COLUMN_TREE
        IMPORTING NODE_KEY.

ENDCLASS.

CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD ON_DATA_CHANGED.

    PERFORM ALV_HANDLER_DATA_CHANGED USING ER_DATA_CHANGED.

  ENDMETHOD.

  METHOD ON_DATA_CHANGED_FINISHED.

    CHECK E_MODIFIED EQ ABAP_ON.

    SENDER->REFRESH_TABLE_DISPLAY(
      EXPORTING
        IS_STABLE      = VALUE #( ROW = 'X' COL = 'X' )                 " With Stable Rows/Columns
      EXCEPTIONS
        FINISHED = 1                " Display was Ended (by Export)
        OTHERS   = 2

    ).

    IF SY-SUBRC <> 0.
      CASE SY-SUBRC.
        WHEN 1.
          MESSAGE I084(ZCC_MSG) DISPLAY LIKE 'E'. " Display was Ended (by Export)
        WHEN 2.
          MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
      ENDCASE.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS LCL_APPLICATION IMPLEMENTATION.

  METHOD HANDLE_NODE_DOUBLE_CLICK.

    DESCRIBE TABLE GT_DISPLAY LINES DATA(LV_ITEM_COUNT).
    IF ZCC_VBAK-AUART EQ 'QT' AND LV_ITEM_COUNT >= 1.
      " 맞춤형 계약은 1개 이하의 아이템에 대해서만 채결됩니다.
      MESSAGE S119(ZCC_MSG) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    " 노드 더블클릭 시 작동할 Method 생성
    READ TABLE ITEM_TABLE WITH KEY NODE_KEY = NODE_KEY INTO DATA(LS_ITEM).

    IF LS_ITEM-TEXT CS 'FERT'.
      " 완제품에 해당하는 노드를 클릭했을 때만 ALV에 아이템을 삽입하도록 처리함.
      " 제품 테이블에서 노드의 ITEM TEXT에 해당하는 제품번호를 조건으로 하여 검색
      SELECT SINGLE
        FROM ZCC_MVKE
        FIELDS *
        WHERE MATNR EQ @LS_ITEM-TEXT
        INTO @DATA(LS_MVKE).

      IF ZCC_VBAK-AUART EQ 'NO' AND LS_MVKE-CUSTOM EQ 'X'.
        " 주문유형은 일반계약인데 선택한 제품이 맞춤 제품인 경우
        " 주문유형과 동일한 제품을 선택해주세요.
        MESSAGE S118(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF ZCC_VBAK-AUART EQ 'QT' AND LS_MVKE-CUSTOM EQ SPACE.
        " 주문유형은 맞춤계약인데 선택한 제품이 일반 제품인 경우
        " 주문유형과 동일한 제품을 선택해주세요.
        MESSAGE S118(ZCC_MSG) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      " ALV를 출력하기 위한 Subroutine
      PERFORM FILL_ALV USING LS_MVKE.

      CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
    ELSE.
      " 완제품 노드를 더블클릭 해주세요.
      MESSAGE S111(ZCC_MSG) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.


  ENDMETHOD.

ENDCLASS.
