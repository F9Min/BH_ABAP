PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE init_alv_0100.
  MODULE clear_ok_code.
  CALL SUBSCREEN sub1 INCLUDING sy-repid '1100'.

PROCESS AFTER INPUT.
  MODULE exit_0100 AT EXIT-COMMAND.
  "검색조건 subscreen 불러오기
  CALL SUBSCREEN sub1.
  MODULE user_command_0100.
