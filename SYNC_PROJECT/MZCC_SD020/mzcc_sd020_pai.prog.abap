*&---------------------------------------------------------------------*
*& Include          MZCC_SD020_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

      " 판매오더 검색
    WHEN 'ZDISPLAY'.
      PERFORM select_vbak_data.
      PERFORM modify_status.

    WHEN 'REFRESH'.
      PERFORM refresh_all.

      " 대금청구서 조회로 이동
    WHEN 'NEXT'.
      CALL TRANSACTION 'ZCCSD060'.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0101 INPUT.

  CASE ok_code.
    WHEN 'CANC'.
      MESSAGE '출고문서 생성을 취소했습니다.' TYPE 'I'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE ok_code.
    WHEN 'SAVE'.
      PERFORM create_material_document. "자재문서 생성.
      PERFORM save_data.                "출고문서 저장
      PERFORM create_document.          "전표생성

      PERFORM refresh_alv_0100.
      LEAVE TO SCREEN 0.   " 메인 화면으로 돌아가기.

  ENDCASE.

ENDMODULE.
