class ltc_create definition
  for testing
  duration short
  risk level harmless
  final.

  public section.

    methods create for testing.
    methods create_for_non_existing_table for testing.

    methods create_cds for testing.
    methods create_cds_old_sw_version for testing.
    methods create_for_non_existing_cds for testing.

    methods capability_service for testing.

*    METHODS create_with_unknown_dbcon FOR TESTING.
*    METHODS create_without_dbcon FOR TESTING.


  private section.
    data mo_unbound_gui_container type ref to cl_gui_container value is initial.

*    METHODS teardown.

endclass.

class ltc_create implementation.

*  METHOD create_with_unknown_dbcon.
*    TRY.
*        cl_sadl_aunit_friend=>inject_dbcon( 'UNDEFINED_DBCON_XY' ).
*        cl_salv_gui_table_ida=>create( io_gui_container = mo_unbound_gui_container
*            J                           iv_table_name    = `SFLIGHT` ).
*        cl_abap_unit_assert=>fail( msg = `exception expected` ).
*      CATCH cx_salv_db_connection ##no_handler.
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD create_without_dbcon.
*    DATA lo_alv TYPE REF TO if_salv_gui_table_ida.
*    DATA lx_abqi TYPE REF TO cx_sadl_abqi.
*
*    TRY.
*        cl_sadl_aunit_friend=>inject_dbcon( '' ).
*        lo_alv = cl_salv_gui_table_ida=>create( io_gui_container = mo_unbound_gui_container
*                                                iv_table_name    = `SFLIGHT` ).
*
*        cl_abap_unit_assert=>assert_bound( lo_alv ).
*      CATCH cx_salv_db_connection INTO data(lx).
*        "it is OK if the DBMS is not supported, but other errors are not expected here:
*        lx_abqi ?= lx->previous->previous.
*        cl_aunit_assert=>assert_equals( act = lx_abqi->textid
*                                        exp = cx_sadl_abqi=>cx_unknown_dbcon ).
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD teardown.
*    cl_sadl_aunit_friend=>reset_all( ).
*  ENDMETHOD.


  method create.
    "Online InContainer bound => not testable in AUnit
    "Online InContainer not bound => Exception
    try.
        data(lo_alv) = zcl_salv_gui_table_ida=>create(
          io_gui_container = mo_unbound_gui_container
          iv_table_name    = `SFLIGHT` ).
        cl_abap_unit_assert=>assert_bound( lo_alv ).
        if cl_salv_table=>is_offline( ) ne abap_true.  "AUnit Test Run in Background: Exlipse or ATC check
          cl_abap_unit_assert=>fail( ).
        endif.
      catch cx_salv_ida_contract_violation.
    endtry.
    "Offline InContainer
    if cl_salv_table=>is_offline( ).
      lo_alv = zcl_salv_gui_table_ida=>create(
        io_gui_container = mo_unbound_gui_container
        iv_table_name    = `SFLIGHT` ).
      cl_abap_unit_assert=>assert_bound( lo_alv ).
    endif.
    "Online/Offline Fullscreen
    lo_alv = zcl_salv_gui_table_ida=>create(
      iv_table_name    = `SFLIGHT` ).
    cl_abap_unit_assert=>assert_bound( lo_alv ).
  endmethod.


  method create_for_non_existing_table.
    try.
        " io_gui_container = mo_unbound_gui_container
        data(lo_alv) = zcl_salv_gui_table_ida=>create( iv_table_name    = `BLABLABLABLA` ).
        cl_abap_unit_assert=>fail( ).
      catch cx_salv_db_table_not_supported. " expected
    endtry.
  endmethod.


  method create_cds.
    if if_sadl_api_version=>co_version < '740SP07'.
      cl_abap_unit_assert=>abort( quit = if_aunit_constants=>method  msg = 'BASIS 740SP07 needed for this test' ).
    endif.
    try.
        data(lo_alv) = zcl_salv_gui_table_ida=>create_for_cds_view(
"        io_gui_container = mo_unbound_gui_container
        iv_cds_view_name = `sadl_v_cds_sflight` ).
        cl_abap_unit_assert=>assert_bound( lo_alv ).
      catch cx_salv_ida_contract_violation.  "ForCURRKeY not part of structure...
    endtry.
  endmethod.


  method create_cds_old_sw_version.
    check cl_salv_table=>is_offline( ) ne abap_true.
    if if_sadl_api_version=>co_version >= '740SP07'.
      cl_abap_unit_assert=>abort( quit = if_aunit_constants=>method  msg = 'older BASIS SP needed for this test' ).
    endif.
    try.
        data(lo_alv) = zcl_salv_gui_table_ida=>create_for_cds_view(
  "          io_gui_container = mo_unbound_gui_container
            iv_cds_view_name = `sadl_v_cds_sflight` ).
        cl_abap_unit_assert=>fail( ).
      catch cx_salv_function_not_supported.
    endtry.
  endmethod.


  method create_for_non_existing_cds.
    if if_sadl_api_version=>co_version < '740SP07'.
      cl_abap_unit_assert=>abort( quit = if_aunit_constants=>method  msg = 'BASIS 740SP07 needed for this test' ).
    endif.
    try.
        data(lo_alv) = zcl_salv_gui_table_ida=>create_for_cds_view( `BLABLABLABLA` ).
        cl_abap_unit_assert=>fail( ).
      catch cx_salv_db_table_not_supported. " expected
    endtry.
  endmethod.


  method capability_service.
    data(lo_srv) = zcl_salv_gui_table_ida=>db_capabilities( ).
    cl_abap_unit_assert=>assert_equals( act = lo_srv exp = cl_salv_ida_capability_service=>get( ) ).
  endmethod.

endclass.
