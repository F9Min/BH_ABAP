*&---------------------------------------------------------------------*
*& Include          Z2603R0050_088_TOP
*&---------------------------------------------------------------------*
TABLES : ZBCT0010, ZBCT0020.
**********************************************************************
* Variables
**********************************************************************
DATA : GV_FLAG,
       GV_LINES      TYPE I,
       GV_PW         TYPE C LENGTH 10,
       GV_ENTERED_PW TYPE C LENGTH 10,
       GV_PASS.
**********************************************************************
* ITAB
**********************************************************************
DATA : GS_STAT TYPE ZBCT0010,
       GT_STAT TYPE TABLE OF ZBCT0010.

DATA : BEGIN OF GS_LIST,
         TBTCO_JOBNAME    TYPE BTCJOB,        "작업내역
         TBTCO_STEPCOUNT  TYPE BTCSTEPCNT,    "단계번호
         TBTCO_SDLUNAME   TYPE BTCSDLNM,      "작업생성자
         TBTCO_STATUS     TYPE BTCPSTATUS,    "상태
         STATTXT          TYPE C LENGTH 25,   "상태 내역
         REMARK           TYPE ICON_D,        "ICON 원인 및 조치사항
         DETAIL           TYPE C LENGTH 1333, "최근 조치사항
         TBTCO_SDLDATE    TYPE BTCSDLDATE,    "작업일정 계획일자
         TBTCO_SDLTIME    TYPE BTCSDLTIME,    "작업일정 계획시간
         TBTCO_LASTCHDATE TYPE BTCJCHDATE,    "최종변경 일자
         TBTCO_LASTCHTIME TYPE BTCJCHTIME,    "최종변경 시간
         TBTCO_RELDATE    TYPE BTCRELDT,      "릴리즈 일자
         TBTCO_RELTIME    TYPE BTCXTIME,      "릴리즈 시간
         TBTCO_SDLSTRTDT  TYPE BTCSDATE,      "예정된시작 일자
         TBTCO_SDLSTRTTM  TYPE BTCSTIME,      "예정된시작 시간
         TBTCO_STRTDATE   TYPE BTCXDATE,      "실행시작 일자
         TBTCO_STRTTIME   TYPE BTCXTIME,      "실행시작 시간
         DELAYTIME        TYPE C LENGTH 10,   "지연시간
         TBTCO_ENDDATE    TYPE BTCXDATE,      "실행종료 일자
         TBTCO_ENDTIME    TYPE BTCXTIME,      "실행종료 시간
         PLAYTIME         TYPE C LENGTH 10,   "실행시간
         PROGNAME         TYPE BTCPROG,       "프로그램
         VARIANT          TYPE BTCVARIANT,    "변형
         PRDLEN           TYPE C LENGTH 10,   "작업주기
         TBTCO_JOBCOUNT   TYPE BTCJOBCNT,     "작업번호
         ERDAT            TYPE ERDAT,         "저장일자
         ERTIM            TYPE ERZET,         "저장시간
         TIMESTAMP        TYPE TIMESTAMPL,    "타임스탬프
       END OF GS_LIST,
       GT_LIST LIKE TABLE OF GS_LIST.

DATA : BEGIN OF GS_JOB.
         INCLUDE STRUCTURE ZBCT0020.
DATA :   CELLTAB TYPE LVC_T_STYL,
       END OF GS_JOB,
       GT_JOB LIKE TABLE OF GS_JOB.
**********************************************************************
* ALV
**********************************************************************
DATA : OK_CODE TYPE SY-UCOMM.

DATA : GV_SAVE,
       GS_VARIANT TYPE DISVARIANT,
       GS_LAYO    TYPE LVC_S_LAYO,
       GS_LAYO2   TYPE LVC_S_LAYO,
       GT_FCAT    TYPE LVC_T_FCAT,
       GT_FCAT2   TYPE LVC_T_FCAT.

DATA : GO_DOCKING   TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID  TYPE REF TO CL_GUI_ALV_GRID,
       GO_CUSTOM    TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_GRID2 TYPE REF TO CL_GUI_ALV_GRID.
