FUNCTION ZFM_USER_MANAGE.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IV_NAME) TYPE  ZES4H088NAME OPTIONAL
*"     REFERENCE(IV_BDAY) TYPE  ZES4H088BDAY OPTIONAL
*"     REFERENCE(IV_MAIL) TYPE  ZES4H088MAIL OPTIONAL
*"     REFERENCE(IV_ID) TYPE  ZES4H088ID OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  C
*"  EXPORTING
*"     REFERENCE(EV_ID) TYPE  ZES4H088ID
*"     REFERENCE(EV_RESULT) TYPE  C
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"  EXCEPTIONS
*"      DUPLICATED_INFO
*"      NO_MODE
*"----------------------------------------------------------------------
  DATA : LS_USER   TYPE ZS4H088T04,
         LV_RETURN TYPE NRRETURN.

  CASE IV_MODE.
    WHEN 'I'. " 생성 모드인 경우
      " 사용자 이름 + 이메일 중복 체크
      " 사용자 이름, 생년월일, 전자메일 입력 체크
      " 문자열 타입인 경우 : 공백 여부 체크
      CASE SPACE.
        WHEN IV_NAME.
          " FM 이후 트랜잭션이 진행되도록 E TYPE이 아닌 'I' 또는 'X'를 사용
          MESSAGE TEXT-E01 TYPE 'I' DISPLAY LIKE 'E'.
          RETURN.
        WHEN IV_MAIL.
          MESSAGE TEXT-E03 TYPE 'I' DISPLAY LIKE 'E'.
          RETURN.
      ENDCASE.

      " 숫자형 타입인 경우 : 0 여부 체크
      CASE 0.
        WHEN IV_BDAY.
          MESSAGE TEXT-E02 TYPE 'I' DISPLAY LIKE 'E'.
          RETURN.
      ENDCASE.

      SELECT SINGLE ID,
                    NAME,
                    MAIL
        FROM ZS4H088T04
        INTO @DATA(LS_ID)
       WHERE NAME EQ @IV_NAME
         AND MAIL EQ @IV_MAIL.

      IF SY-SUBRC EQ 0.
        " 중복된 사용자 정보가 존재하는 경우
        PERFORM SET_EXPORT USING LS_ID-ID
                                 'F'
                                 '이미 등록된 사용자입니다.'
                        CHANGING EV_ID
                                 EV_RESULT
                                 EV_MESSAGE.
        RETURN.
      ELSE.
        " 사용자 전자메일 중복 체크
        SELECT SINGLE ID,
                      NAME,
                      MAIL
          FROM ZS4H088T04
          INTO @LS_ID
         WHERE MAIL EQ @IV_MAIL.

        IF SY-SUBRC EQ 0.
          " 중복된 전자메일이 존재하는 경우
          PERFORM SET_EXPORT USING LS_ID-ID
                                   'F'
                                   '중복된 전자메일이 입력되었습니다.'
                          CHANGING EV_ID
                                   EV_RESULT
                                   EV_MESSAGE.

*          MESSAGE EV_RESULT RAISING DUPLICATED_INFO.
*          RAISE DUPLICATED_INFO.
          RETURN.
        ELSE.
          FIND '@' IN IV_MAIL.

          IF SY-SUBRC NE 0.
            " 올바른 전자메일 형식을 입력해주세요.
            MESSAGE TEXT-E10 TYPE 'I' DISPLAY LIKE 'E'.
            RETURN.
          ELSE.
            IF IV_BDAY >= SY-DATUM.
              " 올바른 생년월일을 입력해주세요.
              MESSAGE TEXT-E11 TYPE 'I' DISPLAY LIKE 'E'.
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      " 데이터 생성
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR             = '01'             " Number range number
          OBJECT                  = 'ZNRS4H088I'    " Name of number range object
        IMPORTING
          NUMBER                  = LS_USER-ID       " free number
          RETURNCODE              = LV_RETURN        " Return code
        EXCEPTIONS
          INTERVAL_NOT_FOUND      = 1                " Interval not found
          NUMBER_RANGE_NOT_INTERN = 2                " Number range is not internal
          OBJECT_NOT_FOUND        = 3                " Object not defined in TNRO
          QUANTITY_IS_0           = 4                " Number of numbers requested must be > 0
          QUANTITY_IS_NOT_1       = 5                " Number of numbers requested must be 1
          INTERVAL_OVERFLOW       = 6                " Interval used up. Change not possible.
          BUFFER_OVERFLOW         = 7                " Buffer is full
          OTHERS                  = 8.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      LS_USER-NAME = IV_NAME.
      LS_USER-MAIL = IV_MAIL.
      LS_USER-BDAY = IV_BDAY.

      LS_USER-ERDAT = SY-DATUM.
      LS_USER-ERNAM = SY-UNAME.
      LS_USER-ERZET = SY-UZEIT.

      INSERT ZS4H088T04 FROM LS_USER.

      IF SY-SUBRC EQ 0.
        PERFORM SET_EXPORT USING LS_USER-ID
                                 'S'
                                 SPACE
                        CHANGING EV_ID
                                 EV_RESULT
                                 EV_MESSAGE.
        EV_MESSAGE = |사용자 '{ IV_NAME }'({ EV_ID }) 등록을 완료 하였습니다.|.
      ELSE.
        PERFORM SET_EXPORT USING LS_USER-ID
                                 'F'
                                 '사용자 정보 생성에 실패했습니다.'
                        CHANGING EV_ID
                                 EV_RESULT
                                 EV_MESSAGE.
        ROLLBACK WORK.
      ENDIF.

    WHEN 'M'. " 변경 모드인 경우
      IF IV_ID IS INITIAL.
        " 변경할 사용자의 ID를 입력해주세요.
        MESSAGE TEXT-E09 TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.

      SELECT SINGLE *
         FROM ZS4H088T04
         INTO CORRESPONDING FIELDS OF LS_USER
        WHERE ID EQ IV_ID.

      IF SY-SUBRC NE 0.
        PERFORM SET_EXPORT USING IV_ID
                                 'F'
                                 '존재하지 않는 회원 번호 입니다.'
                        CHANGING EV_ID
                                 EV_RESULT
                                 EV_MESSAGE.
        EXIT.
      ELSE.
        " 입력 값 중 공백이 없는 경우 변경을 위해 WA에 업데이트
        IF IV_ID IS NOT INITIAL.
          LS_USER-ID = IV_ID.
        ENDIF.

        IF IV_NAME IS NOT INITIAL.
          LS_USER-NAME = IV_NAME.
        ENDIF.

        IF IV_MAIL IS NOT INITIAL.
          FIND '@' IN IV_MAIL.

          IF SY-SUBRC NE 0.
            " 올바른 전자메일 형식을 입력해주세요.
            MESSAGE TEXT-E10 TYPE 'I' DISPLAY LIKE 'E'.
            RETURN.
          ENDIF.

          " 사용자 전자메일 중복 체크
          SELECT SINGLE ID,
                        NAME,
                        MAIL
            FROM ZS4H088T04
            INTO @LS_ID
           WHERE MAIL EQ @IV_MAIL.

          IF SY-SUBRC EQ 0.
            PERFORM SET_EXPORT USING IV_ID
                                     'F'
                                     '중복된 전자메일이 입력되었습니다.'
                            CHANGING EV_ID
                                     EV_RESULT
                                     EV_MESSAGE.
            RETURN.
          ENDIF.

          LS_USER-MAIL = IV_MAIL.
        ENDIF.

        IF IV_BDAY IS NOT INITIAL.
          IF IV_BDAY >= SY-DATUM.
            " 올바른 생년월일을 입력해주세요.
            MESSAGE TEXT-E11 TYPE 'I' DISPLAY LIKE 'E'.
            RETURN.
          ELSE.
            LS_USER-BDAY = IV_BDAY.
          ENDIF.
        ENDIF.

        LS_USER-AEDAT = SY-DATUM.
        LS_USER-AENAM = SY-UNAME.
        LS_USER-AEZET = SY-UZEIT.

        UPDATE ZS4H088T04 FROM LS_USER.

        IF SY-SUBRC EQ 0.
          PERFORM SET_EXPORT USING IV_ID
                                   'S'
                                   SPACE
                          CHANGING EV_ID
                                   EV_RESULT
                                   EV_MESSAGE.
          EV_MESSAGE = |사용자 { IV_NAME }의 정보 변경을 완료 하였습니다.|.
        ELSE.
          PERFORM SET_EXPORT USING IV_ID
                                   'S'
                                   '사용자 정보 변경에 실패했습니다.'
                          CHANGING EV_ID
                                   EV_RESULT
                                   EV_MESSAGE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
      PERFORM SET_EXPORT USING IV_ID
                               'F'
                               '모드를 확인해주세요.'
                      CHANGING EV_ID
                               EV_RESULT
                               EV_MESSAGE.

*      MESSAGE EV_RESULT RAISING NO_MODE.
      RETURN.
  ENDCASE.

ENDFUNCTION.

FORM SET_EXPORT USING PV_ID      TYPE ZES4H088ID
                      PV_RESULT  TYPE C
                      PV_MESSAGE TYPE STRING
             CHANGING EV_ID      TYPE ZES4H088ID
                      EV_RESULT  TYPE C
                      EV_MESSAGE TYPE STRING.

  EV_ID = PV_ID.
  EV_RESULT = PV_RESULT.
  EV_MESSAGE = PV_MESSAGE.

ENDFORM.
