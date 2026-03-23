*&---------------------------------------------------------------------*
*& Include          Z2602R0030_088_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.

  PARAMETERS : P_KOKRS TYPE TKA01-KOKRS OBLIGATORY,                 " 관리회계 영역
               P_GJAHR TYPE GJAHR OBLIGATORY DEFAULT SY-DATUM(4).   " 회계연도

  SELECT-OPTIONS : S_KOSTL FOR CSKS-KOSTL,                          " 코스트센터 범위
                   S_PERBL FOR COSP-PERBL DEFAULT '1' TO '12'.      " 조회할 월 선택

SELECTION-SCREEN END OF BLOCK B1.
