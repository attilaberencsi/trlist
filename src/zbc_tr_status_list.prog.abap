*&---------------------------------------------------------------------*
*& Report zbc_tr_status_list
*&---------------------------------------------------------------------*
*& Transport Status List
*&---------------------------------------------------------------------*
*& Purpose
*&  Support release management with monitoring Transport Request status
*&  in target systems.
*&
*& Features
*&  - List transports after certain release date
*&  - Shows release date and import Return Codes(RC) in target systems
*&  - Shows which request contains OSS Notes
*&  - Filter By Owner, CTS Project, Release Date/Status
*&  - Double-click on the line shows transport request
*& Setup
*&  - Provide Target System IDs in parameters p_sy_(dev/qua/prd)
*&    Why not to save them as default variant ? (:
*&  - In case You have Pre-Production system set p_sy_pre as well
*&
*&  Enjoy (;
*&---------------------------------------------------------------------*
REPORT zbc_tr_status_list.

TABLES: trdyse01cm, e070, ctsproject.

CONSTANTS:
  co_transport_list_cds_name TYPE dbtabl VALUE 'ZI_TransportRequestQueryALV'.

DATA:
  g_trfunc_sel_rtab TYPE RANGE OF trfunction,
  g_trfunc_sel_rstr LIKE LINE OF g_trfunc_sel_rtab.


SELECTION-SCREEN BEGIN OF BLOCK bf  WITH FRAME TITLE TEXT-bhf.
  SELECT-OPTIONS:
    s_user    FOR trdyse01cm-username,
    s_trfunc  FOR e070-trfunction DEFAULT 'K',
    s_proj    FOR ctsproject-trkorr.
  PARAMETERS:
    p_relesd AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK bf.

SELECTION-SCREEN BEGIN OF BLOCK bs WITH FRAME TITLE TEXT-bhs.
  PARAMETERS:
    p_sy_dev TYPE sysname DEFAULT 'A4H' OBLIGATORY,
    p_sy_qua TYPE sysname DEFAULT 'A4H' OBLIGATORY,
    p_sy_pre TYPE sysname DEFAULT 'A4H',   " PreProduction
    p_sy_prd TYPE sysname DEFAULT 'A4H' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bs.

INCLUDE zbc_tr_status_list_cl_alv.

INITIALIZATION.
  g_trfunc_sel_rstr-sign   = 'I'.
  g_trfunc_sel_rstr-option = 'EQ'.
  g_trfunc_sel_rstr-low    = 'W'.
  APPEND g_trfunc_sel_rstr TO s_trfunc.


START-OF-SELECTION.
  "Initialise List
  DATA(g_alv) = cl_salv_gui_table_ida=>create_for_cds_view(
                  iv_cds_view_name      = co_transport_list_cds_name
                  io_calc_field_handler = NEW zcl_sapdev_transport_virtual( i_sysid_dev = CONV #( p_sy_dev )
                                                                            i_sysid_qua = CONV #( p_sy_qua )
                                                                            i_sysid_pre = CONV #( p_sy_pre )
                                                                            i_sysid_prd = CONV #( p_sy_prd ) ) ).
  TRY.
      "Collect Select-Options
      DATA(g_selopt) = NEW cl_salv_range_tab_collector( ).
      g_selopt->add_ranges_for_name( EXPORTING iv_name = 'AS4USER' it_ranges = s_user[] ).
      g_selopt->add_ranges_for_name( EXPORTING iv_name = 'TRFUNCTION' it_ranges = s_trfunc[] ).
      g_selopt->add_ranges_for_name( EXPORTING iv_name = 'CTSPROJECT' it_ranges = s_proj[] ).
      g_selopt->get_collected_ranges( IMPORTING et_named_ranges = DATA(g_all_selopt) ).
      g_alv->set_select_options( EXPORTING it_ranges = g_all_selopt ).

      "ALV Configuration
      DATA(g_alv_handler) = NEW lcl_alv( i_alv = g_alv ).
      g_alv_handler->configure_alv( ).

    CATCH cx_salv_db_connection
          cx_salv_db_table_not_supported
          cx_salv_ida_contract_violation
          cx_salv_function_not_supported INTO DATA(ex_alv).
      RAISE ex_alv.
  ENDTRY.

  g_alv->fullscreen( )->display( ).
