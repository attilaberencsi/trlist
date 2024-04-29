*&---------------------------------------------------------------------*
*& Include zbc_tr_check_cl01
*&---------------------------------------------------------------------*
CLASS lcl_view DEFINITION.
  PUBLIC SECTION.
    "! Display List of Transport Requests as ALV
    CLASS-METHODS display_tr_list.
  PRIVATE SECTION.
    "! Prepare ALV List Configuration
    CLASS-METHODS _prepare_alv.
    "! Prepare ALV Field Catalog
    CLASS-METHODS _prepare_field_catalog.
    "! Setup D-Q-P Status column colors
    CLASS-METHODS _prepare_column_colors.
    "! Setup D-Q-P Status column colors
    CLASS-METHODS _prepare_callback_functions.
    "! Show ALV Listcc
    CLASS-METHODS _display_alv.
ENDCLASS.

CLASS lcl_view IMPLEMENTATION.
  METHOD display_tr_list.
    _prepare_alv( ).
    _display_alv( ).
  ENDMETHOD.

  METHOD _prepare_alv.
    _prepare_callback_functions( ).
    _prepare_field_catalog( ).
    _prepare_column_colors( ).
  ENDMETHOD.

  METHOD _prepare_field_catalog.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name   = sy-cprog
        i_structure_name = 'ZDS_TRCHECKUI'
      CHANGING
        ct_fieldcat      = gt_fieldcat.

    LOOP AT gt_fieldcat ASSIGNING <gs_fcat>.
      CASE <gs_fcat>-fieldname.
        WHEN 'TRKORR'.
          <gs_fcat>-fix_column = abap_true.
        WHEN 'TRFUNCTION' OR 'TRSTATUS'.
          <gs_fcat>-outputlen = 3.
        WHEN 'NOTE'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = TEXT-c01.
        WHEN 'STRKORR' OR 'KORRDEV'.
          <gs_fcat>-no_out = 'X'.
        WHEN 'AS4USER' OR 'AS4DATE' OR 'AS4TIME'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = TEXT-c02.
        WHEN 'EXPORT_DATE' OR 'EXPORT_TIME'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_dev }-{ TEXT-c03 }|.
          <gs_fcat>-no_zero = abap_true.
        WHEN 'IMPORT_DATE_Q' OR 'IMPORT_TIME_Q'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_qua }-{ TEXT-c04 }|.
          <gs_fcat>-no_zero = abap_true.
        WHEN 'IMPORT_DATE_P' OR 'IMPORT_TIME_P'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_prd }-{ TEXT-c04 }|.
          <gs_fcat>-no_zero = abap_true.
        WHEN 'RETCODE_D'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_dev }-{ TEXT-crc }|.
          <gs_fcat>-outputlen = 7.
        WHEN 'RETCODE_Q'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_qua }-{ TEXT-crc }|.
          <gs_fcat>-outputlen = 7.

        WHEN 'RETCODE_P'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_prd }-{ TEXT-crc }|.
          <gs_fcat>-outputlen = 7.

        WHEN 'IMPORT_DATE_Q1' OR 'IMPORT_TIME_Q1'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = TEXT-c04.
          <gs_fcat>-no_zero = abap_true.

          IF gc_sysid_prpr IS INITIAL.
            <gs_fcat>-no_out = 'X'.
          ENDIF.

        WHEN 'RETCODE_Q1'.
          <gs_fcat>-reptext_ddic =
          <gs_fcat>-seltext_s =
          <gs_fcat>-seltext_m =
          <gs_fcat>-seltext_l = |{ gc_sysid_prpr }-{ TEXT-crc }|.
          <gs_fcat>-outputlen = 7.

          IF gc_sysid_prpr IS INITIAL.
            <gs_fcat>-no_out = 'X'.
          ENDIF.

      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD _prepare_column_colors.

    "Column(Cell) Colors
    DATA(gt_colors) = VALUE lvc_t_scol(
      ( fname   = 'RETCODE_D'
        color-col = 5
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'EXPORT_DATE'
        color-col = 5
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'EXPORT_TIME'
        color-col = 5
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'RETCODE_Q'
        color-col = 3
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'IMPORT_DATE_Q'
        color-col = 3
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'IMPORT_TIME_Q'
        color-col = 3
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'RETCODE_Q1'
        color-col = 7
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'IMPORT_DATE_Q1'
        color-col = 7
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'IMPORT_TIME_Q1'
        color-col = 7
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'RETCODE_P'
        color-col = 6
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'IMPORT_DATE_P'
        color-col = 6
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
      ( fname   = 'IMPORT_TIME_P'
        color-col = 6
        color-int = 0
        color-inv = 0
        nokeycol  = abap_true )
    ).

    LOOP AT gt_request ASSIGNING <gs_request>.
      <gs_request>-cell_colors = gt_colors.
    ENDLOOP.
  ENDMETHOD.

  METHOD _prepare_callback_functions.
    gs_event_exit-ucomm = '&IC1'.        "(Double-click)
    gs_event_exit-after = abap_true.
    APPEND gs_event_exit TO gt_event_exit.
  ENDMETHOD.

  METHOD _display_alv.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program      = sy-repid
        i_callback_user_command = 'DCLICK'
        i_structure_name        = 'ZDS_TRCHECKUI'
        it_fieldcat             = gt_fieldcat
        it_event_exit           = gt_event_exit
        is_layout               = VALUE slis_layout_alv(  no_input = abap_true
                                                          colwidth_optimize = abap_true
                                                          coltab_fieldname = 'CELL_COLORS' )
      TABLES
        t_outtab                = gt_request.

  ENDMETHOD.


ENDCLASS.
