*&---------------------------------------------------------------------*
*& Include          ZRFC0010_088_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  CASE OK_CODE.
    WHEN 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM SAVE_RFQ.
      PERFORM REFRESH_ALV.
    WHEN 'SEND'.
      PERFORM SEND_RFQ.
      PERFORM REFRESH_ALV.
    WHEN 'ADD'.
      PERFORM ADD_LINES.
      PERFORM REFRESH_ALV.
    WHEN 'DELT'.
      PERFORM DELT_LINES.
      PERFORM REFRESH_ALV.
  ENDCASE.

ENDMODULE.
