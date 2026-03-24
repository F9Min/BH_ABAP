*&---------------------------------------------------------------------*
*& Include          MZCC_SD030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'S0110'.
  SET TITLEBAR 'T0110'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLOSE_INPUT OUTPUT
*&---------------------------------------------------------------------*
MODULE CLOSE_INPUT OUTPUT.

  IF GV_CLOSE = 'X'.
    " 상단의 기본정보가 입력된 경우
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'FG1'.
        " 상단의 기본정보 Input Field는 모두 잠금처리 된다.
        SCREEN-INPUT = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSE.
    " 상단의 기본정보가 입력되지 않은 경우.
    IF GV_KUNNR_SEA = 'X'.
      " 검색 기준이 고객ID인 경우
      LOOP AT SCREEN.
        IF SCREEN-NAME = 'ZCC_KNA1-KUNNR'.
          " 고객ID Input Field는 입력 허용
          SCREEN-INPUT = 1.
        ELSEIF SCREEN-NAME = 'ZCC_KNA1-NAME1'.
          " 고객명 Input Field는 입력 잠금
          SCREEN-INPUT = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSEIF GV_NAME1_SEA = 'X'.
      " 검색 기준이 고객명인 경우
      LOOP AT SCREEN.
        IF SCREEN-NAME = 'ZCC_KNA1-KUNNR'.
          " 고객ID Input Field는 입력 잠금
          SCREEN-INPUT = 0.
        ELSEIF SCREEN-NAME = 'ZCC_KNA1-NAME1'.
          " 고객명 Input Field는 입력 허용
          SCREEN-INPUT = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module FILL_DYNNR OUTPUT
*&---------------------------------------------------------------------*
MODULE FILL_DYNNR OUTPUT.

  " Tabstrip에서 현재 활성화 되어 있는 탭에 해당하는 화면을 보여주기 위해 조건문을 사용
  CASE MY_TAB_STRIP-ACTIVETAB.
    WHEN 'FC1'.
      DYNNR = '0110'.
    WHEN 'FC2'.
      DYNNR = '0120'.
    WHEN 'FC3'.
      DYNNR = '0130'.
    WHEN OTHERS.  " 모두 해당되지 않으면 초기값 설정
      DYNNR = '0110'. "화면에 110번 Subscreen이 보이도록 함.
      MY_TAB_STRIP-ACTIVETAB = 'FC1'.  "첫 번째 탭을 활성화 탭으로 취급
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLOSE_INPUT_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE CLOSE_INPUT_0110 OUTPUT.

  IF GV_CLOSE = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'FG2'.
        SCREEN-INPUT = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_TREE OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_TREE OUTPUT.
  IF G_TREE IS INITIAL.

    " 첫 번째 컬럼의 제목 결정
    HIERARCHY_HEADER-HEADING = '제품 리스트'.
    " HEADER 계층의 컬럼 너비
    HIERARCHY_HEADER-WIDTH = 40.

    CREATE OBJECT G_TREE
      EXPORTING
        PARENT                = GO_CONTAINER1                                    " Parent Container
        NODE_SELECTION_MODE   = CL_GUI_COLUMN_TREE=>NODE_SEL_MODE_MULTIPLE      " Nodes: Single or Multiple Selection
        ITEM_SELECTION        = ' '                                             " Can Individual Items be Selected?
        HIERARCHY_COLUMN_NAME = 'HEADTEXT'                                      " Name of the Column in Hierarchy Area
        HIERARCHY_HEADER      = HIERARCHY_HEADER.                               " Hierarchy Header

    PERFORM ADD_TREE_COLUMN.
    PERFORM BUILD_NODE_AND_ITEM_TABLE USING NODE_TABLE
                                            ITEM_TABLE.

    " 노드와 아이템을 트리에 추가
    CALL METHOD G_TREE->ADD_NODES_AND_ITEMS
      EXPORTING
        NODE_TABLE                = NODE_TABLE                 " Node table
        ITEM_TABLE                = ITEM_TABLE                 " Item table
        ITEM_TABLE_STRUCTURE_NAME = 'MTREEITM'.                " Name of Item Structure in ABAP Dictionary

    CALL METHOD G_TREE->EXPAND_NODE
      EXPORTING
        NODE_KEY = 'ROOT'.                 " Node key

    CREATE OBJECT GO_APPLICATION.

    " 자식노드가 없는 노드를 확장한 경우
    EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_EXPAND_NO_CHILDREN.
    EVENT-APPL_EVENT = 'X'.
    APPEND EVENT TO EVENTS.

    EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_NODE_DOUBLE_CLICK.
    EVENT-APPL_EVENT = 'X'.
    APPEND EVENT TO EVENTS.

    " 사용할 이벤트의 목록을 입력.
    CALL METHOD G_TREE->SET_REGISTERED_EVENTS
      EXPORTING
        EVENTS = EVENTS.                 " Event Table

    SET HANDLER GO_APPLICATION->HANDLE_NODE_DOUBLE_CLICK FOR G_TREE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0120 OUTPUT.

  IF GO_CUSTOM IS INITIAL.

    PERFORM CREATE_OBJECT_0120.

    PERFORM SET_ALV_LAYOUT_0120.

    PERFORM SET_FCAT.

    PERFORM SET_ALV_EVENT_0120.

    PERFORM DISPLAY_ALV_0120.

  ELSE.

    CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY
      EXCEPTIONS
        FINISHED = 1                " Display was Ended (by Export)
        OTHERS   = 2.

    IF SY-SUBRC <> 0.
      CASE SY-SUBRC.
        WHEN 1.
          MESSAGE I084(ZCC_MSG) DISPLAY LIKE 'E'. " Display was Ended (by Export)
        WHEN 2.
          MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
      ENDCASE.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_DATA OUTPUT
*&---------------------------------------------------------------------*
MODULE SET_DATA OUTPUT.

  IF ZCC_VBAK-VBELN IS INITIAL.
    " 당사 정보는 별도의 조건 없이 하나의 회사코드로 관리되기 때문에 바로 SELECT
    SELECT SINGLE *
      FROM ZCC_T001
      INTO CORRESPONDING FIELDS OF ZCC_T001.

    " GT_DISPLAY 에 기록되어있는 최종 아이템 정보를 통해 헤더의 총 순금액, 부가세 금액, 배송비, 할인금액을 결정
    PERFORM SET_PRICE.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0130 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0130 OUTPUT.

  IF GO_CUSTOM2 IS INITIAL.

    PERFORM CREATE_OBJECT_0130.

    PERFORM SET_FCAT2.

*    PERFORM SET_ALV_EVENT_0120.

    PERFORM DISPLAY_ALV_0130.

  ELSE.

    CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY
      EXCEPTIONS
        FINISHED = 1                " Display was Ended (by Export)
        OTHERS   = 2.

    IF SY-SUBRC <> 0.
      CASE SY-SUBRC.
        WHEN 1.
          MESSAGE I084(ZCC_MSG) DISPLAY LIKE 'E'. " Display was Ended (by Export)
        WHEN 2.
          MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
      ENDCASE.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0140 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0140 OUTPUT.
  SET PF-STATUS 'S0140'.
  SET TITLEBAR 'T0140'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0140 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0140 OUTPUT.

  IF GO_CUSTOM3 IS INITIAL.

    PERFORM CREATE_OBJECT_0140.

    PERFORM SET_ALV_LAYOUT_0140.

    PERFORM SET_FCAT_140.

    PERFORM DISPLAY_ALV_0140.

  ELSE.

    CALL METHOD GO_ALV_GRID3->REFRESH_TABLE_DISPLAY
      EXCEPTIONS
        FINISHED = 1                " Display was Ended (by Export)
        OTHERS   = 2.

    IF SY-SUBRC <> 0.
      CASE SY-SUBRC.
        WHEN 1.
          MESSAGE I084(ZCC_MSG) DISPLAY LIKE 'E'. " Display was Ended (by Export)
        WHEN 2.
          MESSAGE I075(ZCC_MSG) DISPLAY LIKE 'E'. " others_error
      ENDCASE.
    ENDIF.

  ENDIF.

ENDMODULE.
