CLASS ZCL_AMDP_SAELS_INCENTIVE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES IF_AMDP_MARKER_HDB.

    TYPES: BEGIN OF TY_COMPLEX_RESULT,
             VBELN_REP   TYPE ERNAM,      " VBAK-ERNAM (CHAR 12)
             TOTAL_SALES TYPE WERTV12,    " 합산된 금액 (P 8 DEC 2 / CURR 13,2)
             PERF_RANK   TYPE F,          " PERCENT_RANK()는 DOUBLE(실수)을 반환하므로 F 사용
             GRADE       TYPE C LENGTH 1, " 'A', 'B', 'C' 등급
           END OF TY_COMPLEX_RESULT.

    TYPES TT_COMPLEX_RESULT TYPE STANDARD TABLE OF TY_COMPLEX_RESULT WITH EMPTY KEY.

    METHODS CALCULATE_MONTHLY_INCENTIVE
      IMPORTING VALUE(IV_YEAR)   TYPE CHAR4  " YYYY
      EXPORTING VALUE(ET_RESULT) TYPE TT_COMPLEX_RESULT.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS ZCL_AMDP_SAELS_INCENTIVE IMPLEMENTATION.

  METHOD CALCULATE_MONTHLY_INCENTIVE
      BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
USING VBAK VBAP.

    -- 1. 환율 변환 및 제품 가중치가 적용된 기초 실적 생성
    lt_base_sales =
    SELECT
    a.ernam AS vbeln_rep,
    CONVERT_CURRENCY(
        amount          => b.netwr,
        source_unit     => a.waerk,
        target_unit     => 'KRW',
        reference_date  => a.erdat,
        client          => SESSION_CONTEXT( 'CLIENT' ),
        schema          => CURRENT_SCHEMA
    ) AS netwr_krw,
    b.matnr
    FROM vbak AS a INNER JOIN vbap AS b ON a.vbeln = b.vbeln
    WHERE a.mandt = SESSION_CONTEXT( 'CLIENT' )
      AND ( :IV_YEAR = '' OR a.erdat LIKE :IV_YEAR || '%' );

    -- 2. 상위 % 기반 등급 산출 (HANA Window Function)
    et_result =
        SELECT
            vbeln_rep,
            SUM(netwr_krw) AS total_sales,
            PERCENT_RANK() OVER (ORDER BY SUM(netwr_krw) DESC) AS perf_rank,
            CASE
                WHEN PERCENT_RANK() OVER (ORDER BY SUM(netwr_krw) DESC) <= 0.1 THEN 'A' -- 상위 10%
                WHEN PERCENT_RANK() OVER (ORDER BY SUM(netwr_krw) DESC) <= 0.3 THEN 'B' -- 상위 30%
                ELSE 'C'
            END AS grade
            FROM :lt_base_sales
            GROUP BY vbeln_rep;

  ENDMETHOD.

ENDCLASS.
