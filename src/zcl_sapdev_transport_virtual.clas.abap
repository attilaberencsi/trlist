CLASS zcl_sapdev_transport_virtual DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sapdev_transport_virtual IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    MESSAGE 'Hey' type 'X'.
    BREAK-POINT.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    MESSAGE 'Hey' type 'X'.
    BREAK-POINT.
  ENDMETHOD.
ENDCLASS.
