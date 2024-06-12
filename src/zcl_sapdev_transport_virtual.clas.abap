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
    CONSTANTS co_ida_calc_struc  TYPE typename  VALUE 'ZDS_BC_TRSTATUS_IDA'.
    "! <p class="shorttext synchronized">Field Name of Transport Request Number</p>
    CONSTANTS co_fieldname_trnum TYPE fieldname VALUE 'TRKORR' ##NO_TEXT.

    "! <p class="shorttext synchronized">Dev System ID<</p>
    DATA sysid_dev TYPE trtarsys READ-ONLY.
    "! <p class="shorttext synchronized">Quality System ID</p>
    DATA sysid_qua TYPE trtarsys READ-ONLY.
    "! <p class="shorttext synchronized">Pre-Production System ID</p>
    DATA sysid_pre TYPE trtarsys READ-ONLY.
    "! <p class="shorttext synchronized">Production System ID</p>
    DATA sysid_prd TYPE trtarsys READ-ONLY.

    "! <p class="shorttext synchronized">Instance Setup</p>
    "!
    "! @parameter i_sysid_dev | <p class="shorttext synchronized">Dev System ID</p>
    "! @parameter i_sysid_qua | <p class="shorttext synchronized">Quality System ID</p>
    "! @parameter i_sysid_pre | <p class="shorttext synchronized">Pre-Production System ID</p>
    "! @parameter i_sysid_prd | <p class="shorttext synchronized">Production System ID</p>
    METHODS constructor
      IMPORTING i_sysid_dev TYPE trtarsys OPTIONAL
                i_sysid_qua TYPE trtarsys OPTIONAL
                i_sysid_pre TYPE trtarsys OPTIONAL
                i_sysid_prd TYPE trtarsys OPTIONAL.

  PROTECTED SECTION.

  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Highest Return Code of Export/Import</p>
    DATA highest_retcode TYPE strw_int4.

    "! <p class="shorttext synchronized">Read Transport EXP/IMP Status</p>
    "!
    "! @parameter i_transport_request | <p class="shorttext synchronized"></p>
    "! @parameter result              | <p class="shorttext synchronized"></p>
    METHODS _read_target_status
      IMPORTING i_transport_request TYPE trkorr
      RETURNING VALUE(result)       TYPE zds_bc_trstatus.

    "! <p class="shorttext synchronized" lang="en">Calculate the highest return code</p>
    "!
    "! @parameter i_retcode | <p class="shorttext synchronized" lang="en"></p>
    METHODS max_the_return_code
      IMPORTING i_retcode TYPE strw_int4.

ENDCLASS.



CLASS zcl_sapdev_transport_virtual IMPLEMENTATION.

  METHOD constructor.
    sysid_dev = i_sysid_dev.
    sysid_qua = i_sysid_qua.
    sysid_pre = i_sysid_pre.
    sysid_prd = i_sysid_prd.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA:
      virtual_properties  TYPE STANDARD TABLE OF zds_bc_trstatus.

    LOOP AT it_original_data ASSIGNING FIELD-SYMBOL(<request>).
      ASSIGN COMPONENT co_fieldname_trnum OF STRUCTURE <request> TO FIELD-SYMBOL(<request_num>).

      IF sy-subrc = 0.
        APPEND _read_target_status( <request_num> ) TO virtual_properties.
        UNASSIGN <request_num>.
      ELSE.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF sy-subrc = 0.
      ct_calculated_data[] = virtual_properties[].
    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    "DB fields needed to determine value of calculated fields
    APPEND co_fieldname_trnum TO et_requested_orig_elements.
  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~calculate_line.
    DATA transport_cds TYPE ZI_TransportRequestQueryALV.

    " Structure CDS record
    transport_cds = is_data_base_line.

    DATA(status) = _read_target_status( transport_cds-Trkorr ).

    " Workaround IDA Limitation of zeros
    DATA(status_ida) = CORRESPONDING zds_bc_trstatus_ida( status EXCEPT import_date_q import_time_q import_date_q1 import_time_q1 import_date_p import_time_p ).

    IF status-import_date_q IS NOT INITIAL.
      status_ida-import_date_q = |{ status-import_date_q DATE = USER }|.
    ENDIF.
    IF status-import_time_q IS NOT INITIAL.
      status_ida-import_time_q = |{ status-import_time_q TIME = USER }|.
    ENDIF.

    IF status-import_date_q1 IS NOT INITIAL.
      status_ida-import_date_q1 = |{ status-import_date_q1 DATE = USER }|.
    ENDIF.
    IF status-import_time_q1 IS NOT INITIAL.
      status_ida-import_time_q1 = |{ status-import_time_q1 TIME = USER }|.
    ENDIF.

    IF status-import_date_p IS NOT INITIAL.
      status_ida-import_date_p = |{ status-import_date_p DATE = USER }|.
    ENDIF.
    IF status-import_time_p IS NOT INITIAL.
      status_ida-import_time_p = |{ status-import_time_p TIME = USER }|.
    ENDIF.

    "Status Column holds the ALV status codes 0,1,2,3, which are represented as icons
    "Yes Bro..., just look at :) CL_ALV_A_LVC=>int_2_ext_exception
    IF status-highest_retcode IS INITIAL.
      IF transport_cds-ExportDate IS INITIAL."It was not yet released
        "status_ida-impex_status = '0'."No Status
      ELSE.
        status_ida-impex_status = '3'. " OK
      ENDIF.
    ELSEIF 0 < status-highest_retcode AND status-highest_retcode < 8.
      status_ida-impex_status = '2'. "Warning
    ELSEIF status-highest_retcode >= 8.
      status_ida-impex_status = '1'."Error
    ENDIF.

    es_calculated_fields = status_ida.
  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~end_page.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~get_calc_field_structure.
    ro_calc_field_structure ?= cl_abap_typedescr=>describe_by_name( p_name = co_ida_calc_struc ).
  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~get_requested_fields.
    "DB fields needed to determine value of calculated fields
    INSERT co_fieldname_trnum INTO TABLE rts_db_field_name.
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
          max_the_return_code( system-rc ).

        WHEN me->sysid_qua.
          READ TABLE system-steps INTO DATA(import_step) WITH KEY stepid = 'I'. " Import
          IF sy-subrc = 0.
            result-retcode_q = system-rc.
            max_the_return_code( system-rc ).
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
            max_the_return_code( system-rc ).
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
            max_the_return_code( system-rc ).
            READ TABLE import_step-actions INTO import_date_time INDEX 1.
            IF sy-subrc = 0.
              result-import_date_p = import_date_time-date.
              result-import_time_p = import_date_time-time.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD max_the_return_code.
    IF i_retcode > highest_retcode.
      highest_retcode = i_retcode.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
