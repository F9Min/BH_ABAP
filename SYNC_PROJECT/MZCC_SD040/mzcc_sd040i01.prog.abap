*&---------------------------------------------------------------------*
*& Include          MZCC_SD040I01
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
    WHEN 'FIND' OR ' '.
      PERFORM check_validate.
      PERFORM select_data.
      PERFORM modify_status.

    WHEN 'CREATE'.
      CALL TRANSACTION 'ZCCMM090'.
  ENDCASE.

ENDMODULE.
