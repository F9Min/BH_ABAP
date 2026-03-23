*&---------------------------------------------------------------------*
*& Include          ZS4H088R02_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.
    METHODS:
      ON_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW E_COLUMN,

      ON_CLOSE FOR EVENT CLOSE OF CL_GUI_DIALOGBOX_CONTAINER
        IMPORTING SENDER.

  PRIVATE SECTION.
    DATA : MO_CONT_POPUP TYPE REF TO CL_GUI_DIALOGBOX_CONTAINER,
           MO_ALV_POPUP  TYPE REF TO CL_GUI_ALV_GRID.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD : ON_DOUBLE_CLICK.
    IF E_COLUMN-FIELDNAME NE 'TITLE'.
      MESSAGE TEXT-E14 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.

    ELSE.
      " 선택한 행에 대한 INDEX 정보 가져오기
      READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX E_ROW-INDEX.

      " ISBN과 SEQ를 기반으로 해당 개별 도서의 Data Select
      SELECT T05~ID,
             T04~NAME,
             T05~RDATE,
             T05~REDATE2,
             T02~TITLE,
             T02~AUTHOR,
             T02~PUBLISHER
        FROM ZS4H088T04 AS T04
        JOIN ZS4H088T05 AS T05
          ON T04~ID = T05~ID
        JOIN ZS4H088T02 AS T02
          ON T02~CODE = T05~CODE AND T02~ISBN = T05~ISBN
        WHERE T05~ISBN EQ @GS_DISPLAY-ISBN+0(13)
          AND T05~SEQ  EQ @GS_DISPLAY-ISBN+14(3)
        INTO CORRESPONDING FIELDS OF TABLE @GT_BOOK.

      IF GT_BOOK IS INITIAL.
        MESSAGE TEXT-E15 TYPE 'I' DISPLAY LIKE 'E'. " 표시할 데이터가 존재하지 않습니다.
        RETURN.
      ENDIF.

      SORT GT_BOOK BY RDATE DESCENDING.
      READ TABLE GT_BOOK INTO GS_BOOK INDEX 1.

      GV_DIALOG = 'X'.
      CALL SCREEN 0120 STARTING AT 5 1.

*      IF MO_CONT_POPUP IS INITIAL.
*        " 출력이 이루어지지 않은 경우
*        GV_DIALOG = 'X'.
*
*        CREATE OBJECT MO_CONT_POPUP
*          EXPORTING
*            WIDTH                       = 600              " Width of This Container
*            HEIGHT                      = 300              " Height of This Container
*            TOP                         = 50               " Top Position of Dialog Box
*            LEFT                        = 100              " Left Position of Dialog Box
*            CAPTION                     = '대여 이력'      " Dialog Box Caption
*          EXCEPTIONS
*            CNTL_ERROR                  = 1                " CNTL_ERROR
*            CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
*            CREATE_ERROR                = 3                " CREATE_ERROR
*            LIFETIME_ERROR              = 4                " LIFETIME_ERROR
*            LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
*            EVENT_ALREADY_REGISTERED    = 6                " Event Already Registered
*            ERROR_REGIST_EVENT          = 7                " Error While Registering Event
*            OTHERS                      = 8.
*
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*
*        CREATE OBJECT MO_ALV_POPUP
*          EXPORTING
*            I_PARENT          = MO_CONT_POPUP                 " Parent Container
*          EXCEPTIONS
*            ERROR_CNTL_CREATE = 1                " Error when creating the control
*            ERROR_CNTL_INIT   = 2                " Error While Initializing Control
*            ERROR_CNTL_LINK   = 3                " Error While Linking Control
*            ERROR_DP_CREATE   = 4                " Error While Creating DataProvider Control
*            OTHERS            = 5.
*
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*
*        " 팝업 ALV 출력을 위한 LAYOUT, Field Catalog 생성
*        PERFORM SET_LAYOUT        USING GV_DIALOG.
*        PERFORM SET_FIELD_CATALOG USING GV_DIALOG.
*
*        CALL METHOD MO_ALV_POPUP->SET_TABLE_FOR_FIRST_DISPLAY
*          EXPORTING
*            IS_VARIANT                    = GS_VARIANT2      " Layout
*            I_SAVE                        = GV_SAVE2         " Save Layout
*            IS_LAYOUT                     = GS_LAYO2         " Layout
*          CHANGING
*            IT_OUTTAB                     = GT_BOOK          " Output Table
*            IT_FIELDCATALOG               = GT_FCAT2         " Field Catalog
*          EXCEPTIONS
*            INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
*            PROGRAM_ERROR                 = 2                " Program Errors
*            TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
*            OTHERS                        = 4.
*
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*
*        " 팝업을 닫기 위한 HANDLER 생성
*        SET HANDLER ME->ON_CLOSE FOR MO_CONT_POPUP.
*
*      ELSE.
*        " 출력이 이미 이루어진 경우
*        CALL METHOD MO_ALV_POPUP->REFRESH_TABLE_DISPLAY
*          EXCEPTIONS
*            FINISHED = 1                " Display was Ended (by Export)
*            OTHERS   = 2.
*
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*
*      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD ON_CLOSE.
    IF MO_ALV_POPUP IS NOT INITIAL.
      CALL METHOD MO_ALV_POPUP->FREE. " ALV 객체 삭제
      FREE MO_ALV_POPUP.              " 객체 연결정보 삭제
    ENDIF.

    CALL METHOD SENDER->FREE. " 닫기 버튼이 눌렸던 팝업 컨테이너를 삭제
    FREE MO_CONT_POPUP.       " 닫기 버튼이 눌렸던 팝업 컨테이너 연결정보를 삭제

    GV_DIALOG = SPACE.
  ENDMETHOD.

ENDCLASS.
