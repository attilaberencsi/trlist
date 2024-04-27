"! <p class="shorttext synchronized" lang="en">Calculated fields of TR Query</p>
"! <p><strong>Purpose</strong><br/>
"! Virtual / Calculated fields of Transport Request.<br/>
"! Implements interfaces for calculation in CDS and ALV context.
"! </p>
CLASS zcl_sapdev_transport_virtual DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.
    INTERFACES if_salv_ida_calc_field_handler.

    "! <p class="shorttext synchronized">Virtual elements structure name</p>
    CONSTANTS co_virtual_elements_struc TYPE typename VALUE 'ZDS_BC_TRSTATUS'.

    DATA:
      "! <p class="shorttext synchronized" lang="en">Dev System ID<</p>
      sysid_dev TYPE trtarsys,
      "! <p class="shorttext synchronized" lang="en">Quality System ID</p>
      sysid_qua TYPE trtarsys,
      "! <p class="shorttext synchronized" lang="en">Pre-Production System ID</p>
      sysid_pre TYPE trtarsys,
      "! <p class="shorttext synchronized" lang="en">Production System ID</p>
      sysid_prd TYPE trtarsys.

    "! <p class="shorttext synchronized">Instance Setup</p>
    "!
    "! @parameter i_sysid_dev | <p class="shorttext synchronized">Dev System ID</p>
    "! @parameter i_sysid_qua | <p class="shorttext synchronized">Quality System ID</p>
    "! @parameter i_sysid_pre | <p class="shorttext synchronized">Pre-Production System ID</p>
    "! @parameter i_sysid_prd | <p class="shorttext synchronized">Production System ID</p>
    METHODS constructor
      IMPORTING i_sysid_dev TYPE trtarsys
                i_sysid_qua TYPE trtarsys
                i_sysid_pre TYPE trtarsys OPTIONAL
                i_sysid_prd TYPE trtarsys.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS _read_target_status
      IMPORTING
        i_transport_request TYPE trkorr
      RETURNING
        VALUE(result)       TYPE zds_bc_trstatus.

ENDCLASS.



CLASS zcl_sapdev_transport_virtual IMPLEMENTATION.
  METHOD constructor.
    sysid_dev = i_sysid_dev.
    sysid_qua = i_sysid_qua.
    sysid_pre = i_sysid_pre.
    sysid_prd = i_sysid_prd.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~calculate_line.
    DATA transport_cds TYPE ZC_TransportRequestQuery.

    " Structure CDS record
    transport_cds = is_data_base_line.

    es_calculated_fields = _read_target_status( transport_cds-Trkorr ).
  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~end_page.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~get_calc_field_structure.
    ro_calc_field_structure ?= cl_abap_typedescr=>describe_by_name( p_name = co_virtual_elements_struc ).
  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~get_requested_fields.
    "DB fields needed to determine value of calculated fields
    INSERT CONV fieldname( 'TRKORR' ) INTO TABLE rts_db_field_name.
  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~start_page.

  ENDMETHOD.

  METHOD _read_target_status.
    DATA cofile TYPE ctslg_cofile.

    " Obtain the return codes from the target systems
    CALL FUNCTION 'TR_READ_GLOBAL_INFO_OF_REQUEST'
      EXPORTING
        iv_trkorr = i_transport_request
      IMPORTING
        es_cofile = cofile.

    " Fill calculated elements structure
    LOOP AT cofile-systems INTO DATA(system).

      CASE system-systemid.

        WHEN me->sysid_dev.
          result-retcode_d = system-rc.

        WHEN me->sysid_qua.
          READ TABLE system-steps INTO DATA(import_step) WITH KEY stepid = 'I'. " Import
          IF sy-subrc = 0.
            result-retcode_q = system-rc.
            READ TABLE import_step-actions INTO DATA(import_date_time) INDEX 1.
            IF sy-subrc = 0.
              result-import_date_q = import_date_time-date.
              result-import_time_q = import_date_time-time.
            ENDIF.
          ENDIF.

        WHEN me->sysid_pre.
          READ TABLE system-steps INTO import_step WITH KEY stepid = 'I'. " Import
          IF sy-subrc = 0.
            result-retcode_q1 = system-rc.
            READ TABLE import_step-actions INTO import_date_time INDEX 1.
            IF sy-subrc = 0.
              result-import_date_q1 = import_date_time-date.
              result-import_time_q1 = import_date_time-time.
            ENDIF.
          ENDIF.

        WHEN me->sysid_prd.
          READ TABLE system-steps INTO import_step WITH KEY stepid = 'I'. " Import
          IF sy-subrc = 0.
            result-retcode_p = system-rc.
            READ TABLE import_step-actions INTO import_date_time INDEX 1.
            IF sy-subrc = 0.
              result-import_date_p = import_date_time-date.
              result-import_time_p = import_date_time-time.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
