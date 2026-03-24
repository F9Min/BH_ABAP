*&---------------------------------------------------------------------*
*& Module Pool      SAPMZCC_SD010
*&---------------------------------------------------------------------*
*& 판매실적 및 판매계획 관리
*& 작성자 : 조성민
*& 1. 2025-05-12 : 중간평가 이전 최종
*& 2. 2025-05-20 : PAI 개념 도입에 따른 ALV TOOLBAR 동적 적용 및 기능 추가 / 추가 기능 구현
*& 3. 2025-05-21 : KPI & PAI 계산 및 수치출력, 그래프 출력 로직 추가.
*& 4. 2025-06-06 : STYLE 적용을 통한 키필드 편집 잠금 기능 추가.
*&---------------------------------------------------------------------*

INCLUDE MZCC_SD010TOP.  " Global Data
INCLUDE MZCC_SD010SCR.
INCLUDE MZCC_SD010CLS.

INCLUDE MZCC_SD010O01.  " PBO-Modules
INCLUDE MZCC_SD010I01.  " PAI-Modules
INCLUDE MZCC_SD010F01.  " FORM-Routines

LOAD-OF-PROGRAM.
  " 초기값 세팅
  PERFORM SET_INITIAL.

AT SELECTION-SCREEN OUTPUT.
  " SELECTION SCREEN의 숨김처리
  PERFORM MODIFY_SELECTION_SCREEN.
