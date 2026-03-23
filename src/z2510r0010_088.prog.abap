************************************************************************
* Program ID   : Z2510R0010_088
* Title        : [EDU] ADMP Test Program
* Create Date  : 2025-10-15
* Developer    : 조성민
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. # |Date           |Developer | Description(Reason)
************************************************************************
* 1.0.   |2025-10-15     |조성민    | inital Coding
************************************************************************
REPORT Z2510R0010_088.

PARAMETERS : P_COUNT TYPE SCUSTOM-COUNTRY,
             P_YEAR  TYPE NUMC4.

CALL METHOD ZCL_AMDP_ORDER_SUMMARY=>GET_ORDER_SUMMARY
  EXPORTING
    IV_COUNTRY = P_COUNT  " 국가 코드
    IV_YEAR    = P_YEAR     " 카운트 매개변수
  IMPORTING
    RT_SUMMARY = DATA(LT_SUMMARY).

CL_DEMO_OUTPUT=>DISPLAY( LT_SUMMARY ).
