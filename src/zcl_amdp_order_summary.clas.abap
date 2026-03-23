CLASS ZCL_AMDP_ORDER_SUMMARY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES IF_AMDP_MARKER_HDB.

    TYPES : BEGIN OF TS_SUMMARY,
              COUNTRY     TYPE SCUSTOM-COUNTRY,
              CUST_ID     TYPE SCUSTOM-ID,
              CUST_NAME   TYPE SCUSTOM-NAME,
              TOTAL_PRICE TYPE SBOOK-LOCCURAM,
              WAERS       TYPE SBOOK-LOCCURKEY,
            END OF TS_SUMMARY,
            TY_SUMMARY TYPE TABLE OF TS_SUMMARY.

    CLASS-METHODS GET_ORDER_SUMMARY
      IMPORTING
        VALUE(IV_COUNTRY) TYPE S_COUNTRY
        VALUE(IV_YEAR)    TYPE NUMC4
      EXPORTING
        VALUE(RT_SUMMARY) TYPE TY_SUMMARY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AMDP_ORDER_SUMMARY IMPLEMENTATION.


  METHOD GET_ORDER_SUMMARY BY DATABASE PROCEDURE
                           FOR HDB
                           LANGUAGE SQLSCRIPT
                           USING SCUSTOM SBOOK.

    rt_summary =
        select c.country,
               c.id as cust_id,
               c.name as cust_name,
               sum( b.loccuram ) as total_price,
               b.loccurkey as waers
          from scustom as c
          join sbook as b
            on c.id = b.customid
         where c.mandt = session_context('CLIENT')
           and ( :iv_country is null or c.country = :iv_country )
           and ( :iv_year is null or year( b.order_date ) = :iv_year )
      group by c.country, c.id, c.name, b.loccurkey;


  ENDMETHOD.
ENDCLASS.
