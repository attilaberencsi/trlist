"! <p class="shorttext synchronized" lang="en">Custom ALV with integrated data access (IDA): Factory</p>
"! Model class is replaced with zcl_salv_gui_grid_model_ida in method create_for_abqi
class zcl_salv_gui_table_ida definition
  public
  final
  create private .

  public section.
    interface if_salv_gui_table_ida load .

    interfaces if_salv_gui_table_ida .

    "! DDIC-View, DDIC_Tables
    class-methods create
      importing
        !iv_table_name              type dbtabl
        !io_gui_container           type ref to cl_gui_container optional
        !io_calc_field_handler      type ref to if_salv_ida_calc_field_handler optional
      returning
        value(ro_alv_gui_table_ida) type ref to if_salv_gui_table_ida
      raising
        cx_salv_db_connection
        cx_salv_db_table_not_supported
        cx_salv_ida_contract_violation .
    "! Core Data Services (CDS)
    class-methods create_for_cds_view
      importing
        !iv_cds_view_name           type dbtabl
        !io_gui_container           type ref to cl_gui_container optional
        !io_calc_field_handler      type ref to if_salv_ida_calc_field_handler optional
      returning
        value(ro_alv_gui_table_ida) type ref to if_salv_gui_table_ida
      raising
        cx_salv_db_connection
        cx_salv_db_table_not_supported
        cx_salv_ida_contract_violation
        cx_salv_function_not_supported .
    "! Check for supported features
    class-methods db_capabilities
      returning
        value(ro_capability_service) type ref to if_salv_ida_capability_service .
    class-methods get_api_version
      returning
        value(api_version) type string .
  private section.
    class-data mo_logger type ref to if_salv_logger.

    "! Create relevant components: IDA, Model, Layout, Fieldcatalog, Controler, ...
    class-methods create_for_abqi
      importing
        value(io_entity)            type ref to if_sadl_entity
        value(io_fetch)             type ref to if_sadl_query_fetch
        is_fullscreen_mode          type abap_bool default abap_false
        !io_gui_container           type ref to cl_gui_container optional
        !io_calc_field_handler      type ref to if_salv_ida_calc_field_handler optional
      returning
        value(ro_alv_gui_table_ida) type ref to if_salv_gui_table_ida
      raising
        cx_salv_db_connection
        cx_salv_db_table_not_supported
        cx_salv_ida_contract_violation .

    data mo_ida_api type ref to if_salv_gui_model_ida_api.
    data mo_controler_ida type ref to cl_salv_gui_grid_controler_ida.

ENDCLASS.



CLASS ZCL_SALV_GUI_TABLE_IDA IMPLEMENTATION.


  method create.
    mo_logger = cl_salv_logger=>create_logger( component            = 'IDA'
                                               class_shortened_name = 'GUI_TABLE' ).
    mo_logger->log_task_begin( task = 'CREATE' ).

    if cl_salv_ida_capability_service=>get( )->is_table_supported( iv_table_name ) <> abap_true.
      raise exception type cx_salv_db_table_not_supported
        exporting
          table_name = conv #( iv_table_name ).
    endif.

    cl_salv_ida_services=>create_entity_and_abqi(
        exporting iv_entity_id   = conv #( iv_table_name )
                  iv_entity_type = cl_sadl_entity_factory=>co_type-ddic_table_view
        importing eo_entity      = data(lo_entity)
                  eo_fetch       = data(lo_fetch) ).

    ro_alv_gui_table_ida = create_for_abqi(
        io_entity               = lo_entity
        io_fetch                = lo_fetch
        io_gui_container        = io_gui_container
        is_fullscreen_mode      = xsdbool( io_gui_container is not supplied )
        io_calc_field_handler   = io_calc_field_handler ).

    mo_logger->log_task_end( task = 'CREATE' ).
  endmethod.


  method create_for_abqi.
    mo_logger->log_task_begin( task = 'CREATE_FOR_ABQI' ).
    " IDAS: Structdescr +  ALV Query Engine + IDAS
    data(lo_ida_structdescr) = cl_salv_ida_structdescr=>create_for_sadl_entity(
        io_entity = io_entity
        io_calc_field_handler = io_calc_field_handler ).
    cl_salv_ida_text_search_prov=>get_search_attributes( exporting io_salv_ida_structdescr = lo_ida_structdescr
                                                         importing ets_search_attribute    = data(lt_search_attribute) ).
    data(lo_sti_text_search) = cl_salv_ida_text_search_prov=>create_4_sti( lt_search_attribute ).
    data(lo_sadl_entity) = lo_ida_structdescr->get_sadl_entity( ).
    data(lo_text_search) = cl_salv_ida_text_search_prov=>create_4_ida_api( lo_ida_structdescr ).
    data(lo_query_engine) = new cl_salv_ida_query_engine( io_sadl_entity          = lo_sadl_entity
                                                          io_sadl_fetch           = io_fetch
                                                          io_salv_ida_text_search = lo_text_search ).
    data(lo_idas) = cl_salv_ida_services=>create( io_structdescr_prov     = lo_ida_structdescr
                                                  io_sti_text_search_prov = lo_sti_text_search
                                                  io_query_engine         = lo_query_engine ).
    lo_idas->set_sort_by_relevance( abap_true ).

    " ALV objects
    data(lo_changelog)          = cl_salv_gui_grid_fwk_changelog=>create( cl_salv_gui_grid_controler_ida=>ts_registered_changes ).
    data(lo_user_action)        = new cl_salv_gui_user_action( lo_changelog ).
    data(lo_standard_functions) = new cl_salv_gui_std_functions_ida( ).
    data(lo_message_manager)    = new cl_salv_gui_message_manager( ).
    data(lo_field_catalog)      = new cl_salv_gui_field_catalog_ida( io_structdescr_provider = lo_ida_structdescr ).
    data(lo_layout) = new cl_salv_gui_layout_ida( io_standard_functions   = lo_standard_functions
                                                  io_text_search          = lo_sti_text_search
                                                  io_field_catalog        = lo_field_catalog
                                                  io_message_manager      = lo_message_manager
                                                  io_fwk_changelog         = lo_changelog ).
    data(lo_model_ida) = new zcl_salv_gui_grid_model_ida( io_idas                   = lo_idas
                                                         io_field_catalog          = lo_field_catalog
                                                         io_layout                 = lo_layout
                                                         io_user_action            = lo_user_action
                                                         io_message_manager        = lo_message_manager
                                                         io_fwk_changelog          = lo_changelog ).

    data(lo_alv_gui_table_ida) = new zcl_salv_gui_table_ida( ).
    lo_alv_gui_table_ida->mo_ida_api = lo_model_ida.

    " controller
    if cl_salv_gui_supplied_clnt_func=>is_offline_enhanced_check( ).
      lo_alv_gui_table_ida->mo_controler_ida = cl_salv_gui_grid_controler_ida=>create_for_background(
        exporting io_gui_grid_model  = lo_model_ida
                  io_layout_editor   = lo_layout
                  is_fullscreen_mode = is_fullscreen_mode
                  io_message_manager = lo_message_manager
                  io_user_action     = lo_user_action
                  io_fwk_changelog   = lo_changelog ).
      data(lv_text) = |Batch=X, Fullscreen={ is_fullscreen_mode }|      ##NO_TEXT .
    else.
      if is_fullscreen_mode eq abap_true.
        lo_alv_gui_table_ida->mo_controler_ida = cl_salv_gui_grid_controler_ida=>create_for_fullscreen(
          exporting io_user_action    = lo_user_action
                    io_gui_grid_model = lo_model_ida
                    io_layout_editor  = lo_layout
                    io_message_manager  = lo_message_manager
                    io_fwk_changelog    = lo_changelog
                    ).
      else.
        lo_alv_gui_table_ida->mo_controler_ida = cl_salv_gui_grid_controler_ida=>create(
          exporting io_gui_container  = io_gui_container
                    io_user_action    = lo_user_action
                    io_layout_editor  = lo_layout
                    io_gui_grid_model = lo_model_ida
                    io_message_manager  = lo_message_manager
                    io_fwk_changelog    = lo_changelog
                     ).
      endif.
      lv_text = |Online=X,{ lv_text }|.
    endif.
    ro_alv_gui_table_ida = lo_alv_gui_table_ida.

    mo_logger->log_task_end( task = 'CREATE_FOR_ABQI'
                             text = lv_text ).
  endmethod.


  method create_for_cds_view.
    mo_logger = cl_salv_logger=>create_logger( component            = 'IDA'
                                                  class_shortened_name = 'GUI_TABLE' ).
    mo_logger->log_task_begin( task = 'CREATE_FOR_CDS' text = conv #( iv_cds_view_name ) ).

    if if_sadl_api_version=>co_version < '740SP07'.
      raise exception type cx_salv_function_not_supported
        exporting
          textid = cx_salv_function_not_supported=>insufficient_sw_version.
    endif.

    cl_salv_ida_services=>create_entity_and_abqi(
        exporting iv_entity_id   = conv #( iv_cds_view_name )
                  iv_entity_type = 'CDS'
        importing eo_entity      = data(lo_entity)
                  eo_fetch       = data(lo_fetch) ).

    ro_alv_gui_table_ida = create_for_abqi(
          io_entity               = lo_entity
          io_fetch                = lo_fetch
          is_fullscreen_mode      = xsdbool( io_gui_container is not supplied )
          io_gui_container        = io_gui_container
          io_calc_field_handler   = io_calc_field_handler ).

    mo_logger->log_task_end( task = 'CREATE_FOR_CDS' ).
  endmethod.


  method db_capabilities.
    ro_capability_service = cl_salv_ida_capability_service=>get( ).
  endmethod.


  method get_api_version.
    api_version = '756.01'.
  endmethod.


  method if_salv_gui_table_ida~add_authorization_for_object.
    mo_ida_api->add_authorization_for_object(
        iv_authorization_object = iv_authorization_object
        it_activities           = it_activities
        it_field_mapping        = it_field_mapping ).
  endmethod.


  method if_salv_gui_table_ida~condition_factory.
    ro_condition_factory = mo_ida_api->condition_factory( ).
  endmethod.


  method if_salv_gui_table_ida~default_layout.
    ro_default_layout = mo_ida_api->default_layout( ).
  endmethod.


  method if_salv_gui_table_ida~display_options.
    ro_display_options = mo_ida_api->display_options( ).
  endmethod.


  method if_salv_gui_table_ida~field_catalog.
    ro_field_catalog = mo_ida_api->field_catalog( ).
  endmethod.


  method if_salv_gui_table_ida~free.
    "Release (Frontend) Resources of Views
    mo_controler_ida->free( ).
  endmethod.


  method if_salv_gui_table_ida~fullscreen.
    ro_fullscreen = mo_controler_ida->fullscreen( ).
  endmethod.


  method if_salv_gui_table_ida~layout_persistence.
    ro_layout_persistence = mo_ida_api->layout_persistence( ).
  endmethod.


  method if_salv_gui_table_ida~refresh.
    mo_logger->log_task_begin( task = 'REFRESH' ).
    mo_ida_api->refresh( ).
    mo_controler_ida->set_start_of_roundtrip( ).
    mo_logger->log_task_end( task = 'REFRESH' ).
  endmethod.


  method if_salv_gui_table_ida~selection.
    ro_selection = mo_ida_api->selection( ).
  endmethod.


  method if_salv_gui_table_ida~set_authorization_provider.
    mo_ida_api->set_authorization_provider( io_authorization_provider ).
  endmethod.


  method if_salv_gui_table_ida~set_maximum_number_of_rows.
    mo_ida_api->set_maximum_number_of_rows(
        iv_number_of_rows = iv_number_of_rows
        iv_unrestricted   = iv_unrestricted ).
  endmethod.


  method if_salv_gui_table_ida~set_select_options.
    mo_ida_api->set_select_options( it_ranges ).
    mo_ida_api->set_condition( io_condition ).
    mo_controler_ida->set_start_of_roundtrip( ).
  endmethod.


  method if_salv_gui_table_ida~set_view_parameters.
    mo_ida_api->set_view_parameters( it_parameters ).
  endmethod.


  method if_salv_gui_table_ida~standard_functions.
    ro_standard_functions = mo_ida_api->standard_functions( ).
  endmethod.


  method if_salv_gui_table_ida~text_search.
    ro_text_search = mo_ida_api->text_search( ).
  endmethod.


  method if_salv_gui_table_ida~toolbar.
    ro_toolbar = mo_ida_api->toolbar( ).
  endmethod.
ENDCLASS.
