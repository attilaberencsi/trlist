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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sapdev_transport_virtual IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
  METHOD if_salv_ida_calc_field_handler~calculate_line.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~end_page.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~get_calc_field_structure.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~get_requested_fields.

  ENDMETHOD.

  METHOD if_salv_ida_calc_field_handler~start_page.

  ENDMETHOD.

ENDCLASS.
