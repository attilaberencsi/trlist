*&---------------------------------------------------------------------*
*& Include zbc_tr_status_list_cl_alv
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& CDS ALV Handler Class
*&---------------------------------------------------------------------*
CLASS lcl_alv DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF co_action,
        show_log_in_gui TYPE ui_func VALUE 'SHOW_LOG_GUI',
        show_tr_in_gui  TYPE ui_func VALUE 'SHOW_TR_GUI',
        show_tr_in_adt  TYPE ui_func VALUE 'SHOW_TR_ADT',
      END OF co_action.

    DATA alv TYPE REF TO if_salv_gui_table_ida.

    METHODS constructor IMPORTING i_alv TYPE REF TO if_salv_gui_table_ida.

    METHODS configure_alv
      IMPORTING i_preprod TYPE abap_bool.

    METHODS handle_action FOR EVENT function_selected OF if_salv_gui_toolbar_ida
      IMPORTING ev_fcode.

    METHODS handle_show_tr_in_gui.
    METHODS handle_show_log.

    METHODS on_cell_click FOR EVENT cell_action OF if_salv_gui_field_display_opt
      IMPORTING ev_field_name
                eo_row_data
                sender.

    METHODS on_double_click FOR EVENT double_click OF if_salv_gui_table_display_opt
      IMPORTING ev_field_name
                eo_row_data
                sender.

  PRIVATE SECTION.
    " Dark stuff
    CONSTANTS co_cl_adt_gui_event_dispatcher TYPE string VALUE 'CL_ADT_GUI_EVENT_DISPATCHER' ##NO_TEXT.

    "! Opens in ADT Editor?
    "! @parameter wb_request | the wb request
    "! @parameter processed  | C1 Flag: abap_false; abap_true; E - internal error
    METHODS open_in_adt_editor
      CHANGING  wb_request       TYPE REF TO cl_wb_request
      RETURNING VALUE(processed) TYPE sychar01.

    "! Configure columns
    "!
    "! @parameter i_preprod | Preproduction system exists
    METHODS setup_field_catalog
      IMPORTING i_preprod TYPE abap_bool.

    METHODS setup_events
      RAISING cx_salv_call_after_1st_display
              cx_salv_ida_unknown_name.

    METHODS setup_toolbar
      RAISING cx_salv_ida_gui_fcode_reserved.

ENDCLASS.

CLASS lcl_alv IMPLEMENTATION.

  METHOD constructor.
    alv = i_alv.
  ENDMETHOD.

  METHOD handle_action.
    CASE ev_fcode.
      WHEN co_action-show_tr_in_gui.
        handle_show_tr_in_gui( ).
      WHEN co_action-show_log_in_gui.
        handle_show_log( ).
    ENDCASE.

  ENDMETHOD.

  METHOD configure_alv.
    alv->selection( )->set_selection_mode( iv_mode = if_salv_gui_selection_ida=>cs_selection_mode-single ).

    " CUSTOM FUNCTIONS / BUTTONS
    setup_toolbar( ).

    " EVENT HANDLER REGISTRATION
    setup_events( ).

    " COLUMNS
    setup_field_catalog( i_preprod = i_preprod ).
  ENDMETHOD.

  METHOD handle_show_log.
    DATA selected_row TYPE ZI_TransportRequestQueryALV.

    CHECK alv IS BOUND.

    TRY.
        alv->selection( )->get_selected_row( IMPORTING es_row = selected_row ).

      CATCH cx_salv_ida_row_key_invalid.
        RETURN.
      CATCH cx_salv_ida_contract_violation.
        MESSAGE 'Select a line ;-)' TYPE 'I'.
        RETURN.
      CATCH cx_salv_ida_sel_row_deleted.
        RETURN.
    ENDTRY.

    IF selected_row IS INITIAL.
      MESSAGE 'Select a line ;-)' TYPE 'I'.
      RETURN.
    ENDIF.
    CALL FUNCTION 'TR_LOG_OVERVIEW_REQUEST_REMOTE'
      EXPORTING
        iv_trkorr = selected_row-Trkorr.

    " alv->refresh( ).
  ENDMETHOD.

  METHOD handle_show_tr_in_gui.
    DATA selected_row TYPE ZI_TransportRequestQueryALV.

    CHECK alv IS BOUND.

    TRY.
        alv->selection( )->get_selected_row( IMPORTING es_row = selected_row ).

      CATCH cx_salv_ida_row_key_invalid.
        RETURN.
      CATCH cx_salv_ida_contract_violation.
        MESSAGE 'Select a line !' TYPE 'I'.
        RETURN.
      CATCH cx_salv_ida_sel_row_deleted.
        RETURN.
    ENDTRY.

    IF selected_row IS INITIAL.
      MESSAGE 'Select a line !' TYPE 'I'.
      RETURN.
    ENDIF.
    CALL FUNCTION 'TR_DISPLAY_REQUEST'
      EXPORTING
        i_trkorr = selected_row-Trkorr.

    " alv->refresh( ).
  ENDMETHOD.

  METHOD open_in_adt_editor.

    DATA:
      adt_available TYPE c LENGTH 1,
      object_type   TYPE seu_objtyp,
      object_name   TYPE seu_objkey,
      tabl_state    TYPE REF TO cl_wb_tabl_state.

    object_type = wb_request->object_type.
    object_name = wb_request->object_name.

    "don't navigate to ADT UI. TODO remove when table index editor is available
    IF object_type = swbm_c_type_ddic_db_table AND wb_request->object_state IS INSTANCE OF cl_wb_tabl_state.
      tabl_state ?= wb_request->object_state.
      IF tabl_state->view = cl_wb_tabl_state=>view_indx.
        RETURN.
      ENDIF.
    ENDIF.

    TRY.
        "change client navigation state
        CALL METHOD (co_cl_adt_gui_event_dispatcher)=>is_adt_tool_available
          EXPORTING
            operation          = wb_request->operation
            wb_object_type     = object_type
            wb_object_name     = object_name
          IMPORTING
            adt_tool_available = adt_available
          CHANGING
            wb_request         = wb_request.
        IF adt_available IS NOT INITIAL.
          TRY.
              CALL METHOD (co_cl_adt_gui_event_dispatcher)=>open_adt_editor
                EXPORTING
                  wb_request  = wb_request
                  object_type = object_type
                  object_name = object_name
                  operation   = wb_request->operation.

              processed = abap_true.
            CATCH cx_adt_gui_event_error.
              processed = 'E'.
          ENDTRY.
        ENDIF.
      CATCH cx_sy_dyn_call_error ##no_handler.
    ENDTRY.

  ENDMETHOD.

  METHOD setup_field_catalog.
    alv->field_catalog( )->get_available_fields( IMPORTING ets_field_names = DATA(field_list) ).

    " Configure field as status icon
    " More info at: CL_ALV_A_LVC=>int_2_ext_exception
    alv->field_catalog( )->display_options( )->set_exception_column_group( iv_field_name             = 'IMPEX_STATUS'
                                                                           iv_exception_column_group = '3' ).

    " No Pre-production system ID is provided => hide corresponding columns
    IF i_preprod = abap_false.
      DELETE field_list WHERE table_line = 'RETCODE_Q1'.
      DELETE field_list WHERE table_line = 'IMPORT_DATE_Q1'.
    ENDIF.

    alv->field_catalog( )->set_available_fields( its_field_names = field_list ).

    " Show Domain Text, not the fixed value
    alv->field_catalog( )->display_options( )->set_formatting(
        iv_field_name        = 'TRFUNCTION'
        iv_presentation_mode = if_salv_gui_types_ida=>cs_presentation_mode-description ).

    alv->field_catalog( )->display_options( )->set_formatting(
        iv_field_name        = 'TRSTATUS'
        iv_presentation_mode = if_salv_gui_types_ida=>cs_presentation_mode-description ).

    " Text adjustments
    alv->field_catalog( )->set_field_header_texts( iv_field_name  = 'AS4DATE'
                                                   iv_header_text = 'Changed on' ).

    alv->field_catalog( )->set_field_header_texts( iv_field_name  = 'AS4TIME'
                                                   iv_header_text = 'Changed at' ).

    " Enable text search for the Transport Description field
    IF cl_salv_gui_table_ida=>db_capabilities( )->is_text_search_supported( ).
      alv->standard_functions( )->set_text_search_active( abap_true ).
      alv->field_catalog( )->enable_text_search( iv_field_name = 'AS4TEXT' ).
    ENDIF.
  ENDMETHOD.

  METHOD on_double_click.

    TYPES: BEGIN OF ty_alv_all_fields.
             INCLUDE TYPE ZI_TransportRequestQueryALV.
             INCLUDE TYPE zds_bc_trstatus_ida.
    TYPES: END OF ty_alv_all_fields.

    DATA: alv_record TYPE ty_alv_all_fields.

    eo_row_data->get_row_data( EXPORTING iv_request_type = if_salv_gui_selection_ida=>cs_request_type-all_fields
                               IMPORTING es_row          = alv_record ).

    cl_salv_ida_show_data_row=>display( iv_text = |Technical Data|
                                        is_data = alv_record ).
  ENDMETHOD.

  METHOD on_cell_click.
    DATA tr_cds_record TYPE ZI_TransportRequestQueryALV.

    eo_row_data->get_row_data( EXPORTING iv_request_type = if_salv_gui_selection_ida=>cs_request_type-all_fields
                               IMPORTING es_row          = tr_cds_record ).

    CASE ev_field_name.
      WHEN 'AS4TEXT'.
        CALL FUNCTION 'TR_DISPLAY_REQUEST'
          EXPORTING
            i_trkorr = tr_cds_record-Trkorr.
    ENDCASE.

  ENDMETHOD.


  METHOD setup_events.

    SET HANDLER me->handle_action FOR alv->toolbar( ).

    "Register Double-Click event handler
    alv->display_options( )->enable_double_click( ).
    SET HANDLER me->on_double_click FOR alv->display_options( ).


    alv->field_catalog( )->display_options( )->display_as_link_to_action( iv_field_name = 'AS4TEXT' ).
    SET HANDLER me->on_cell_click FOR alv->field_catalog( )->display_options( ).

  ENDMETHOD.


  METHOD setup_toolbar.

*    alv->toolbar( )->add_separator( ).
*    "- Show Transport Request in GUI
*    alv->toolbar( )->add_button( iv_fcode     = co_action-show_tr_in_gui
*                                 iv_icon      = icon_display
*                                 iv_text      = TEXT-a02
*                                 iv_quickinfo = CONV iconquick( TEXT-a02 ) ).

    alv->toolbar( )->add_separator( ).

    "- Show Transport Log in GUI
    alv->toolbar( )->add_button( iv_fcode     = co_action-show_log_in_gui
                                 iv_icon      = icon_protocol
                                 iv_text      = TEXT-a01
                                 iv_quickinfo = CONV iconquick( TEXT-a01 ) ).

  ENDMETHOD.

ENDCLASS.
