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
*&  - Filter By User and CTS Project
*&  - Double-click on the line shows transport request
*& Setup
*&  - Set your system IDs in parameters p_sy_(dev/qua/prd)
*&  - In case You have Pre-Production system set gc_sysid_pre as well
*&
*&  Enjoy (;
*&---------------------------------------------------------------------*
REPORT zbc_tr_status_list.

CONSTANTS:
  co_transport_list_cds_name TYPE dbtabl VALUE 'ZI_TRANSPORTREQUESTQUERY'.

PARAMETERS:
  p_sy_dev TYPE trtarsys DEFAULT 'A4H' OBLIGATORY,
  p_sy_qua TYPE trtarsys DEFAULT 'A4H' OBLIGATORY,
  p_sy_pre TYPE trtarsys DEFAULT 'A4H',   " PreProduction
  p_sy_prd TYPE trtarsys DEFAULT 'A4H' OBLIGATORY.

START-OF-SELECTION.
  DATA(alv) = cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = co_transport_list_cds_name ).

  TRY.
      alv->set_view_parameters( it_parameters = VALUE #( ( name = 'P_SYS_DEV'   value = p_sy_dev )
                                                         ( name = 'P_SYS_QUA'   value = p_sy_qua )
                                                         ( name = 'P_SYS_PRE'   value = p_sy_qua )
                                                         ( name = 'P_SYS_PROD'  value = p_sy_qua ) ) ).
    CATCH cx_salv_db_connection
          cx_salv_db_table_not_supported
          cx_salv_ida_contract_violation
          cx_salv_function_not_supported INTO DATA(ex_alv).
      RAISE ex_alv.
  ENDTRY.

  alv->fullscreen( )->display( ).
