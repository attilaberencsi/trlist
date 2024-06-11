"! <p class="shorttext synchronized" lang="en">Custom IDA Grid Model</p>
CLASS zcl_salv_gui_grid_model_ida DEFINITION
  PUBLIC
  INHERITING FROM cl_salv_gui_grid_model_ida
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS get_data_4_frontend REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_salv_gui_grid_model_ida IMPLEMENTATION.
  METHOD get_data_4_frontend.
    super->get_data_4_frontend(
      EXPORTING
        from_table_line               = from_table_line
        to_table_line                 = to_table_line
        from_x_y_cell                 = from_x_y_cell
        to_x_y_cell                   = to_x_y_cell
        calculate_search_hits         = calculate_search_hits
        support_multi_selection       = support_multi_selection
      IMPORTING
        et_result_info_truncated_area = et_result_info_truncated_area
        et_lvc_data                   = et_lvc_data
        et_lvc_coll                   = et_lvc_coll
        ev_lines_in_list              = ev_lines_in_list
        ev_lines_selected             = ev_lines_selected
    ).
  ENDMETHOD.

ENDCLASS.
