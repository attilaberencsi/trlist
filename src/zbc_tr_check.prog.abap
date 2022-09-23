*&---------------------------------------------------------------------*
*& Report zbc_tr_check
*&---------------------------------------------------------------------*
*& Transport List
*&---------------------------------------------------------------------*
*& Purpose
*&  Support release management monitoring Transport Request status
*&  in target systems.
*&
*& Features
*&  - List transports after certain release date
*&  - Shows release date and import Return Codes(RC) in target systems
*&  - Shows which request contains OSS Notes
*&  - Double-click on the line shows transport request
*& Setup
*&  - Set your system IDs in constants in gc_sysid_dev/qua/prd
*&  - In case You have Pre-Production system set gc_sysid_prpr as well
*&
*&  Enjoy (;
*&---------------------------------------------------------------------*
REPORT zbc_tr_check.
" For older systems type-pools needs explicitly mentioned.
"TYPE-POOLS: ctslg, slis, sctsc, abap.

CONSTANTS:
  gc_sysid_dev  TYPE trtarsys VALUE 'DS4',
  gc_sysid_qua  TYPE trtarsys VALUE 'QS4',
  gc_sysid_prpr TYPE trtarsys VALUE '',   "PreProduction
  gc_sysid_prd  TYPE trtarsys VALUE 'PS4'.

DATA:
  gt_request          TYPE STANDARD TABLE OF zds_trcheckui,
  gs_request_info     TYPE trwbo_request,
  gs_trattrib         TYPE e070a,
  gs_cofile           TYPE ctslg_cofile,
  gv_project          TYPE trkorr,
  gs_system           TYPE ctslg_system,
  gs_import_step      TYPE ctslg_step,
  gs_import_date_time TYPE ctslg_action,
  gt_event_exit       TYPE slis_t_event_exit,
  gs_event_exit       TYPE slis_event_exit,
  gs_truser           TYPE trdyse01cm,
  gt_fieldcat         TYPE slis_t_fieldcat_alv,
  gs_e070             TYPE e070,
  gv_trkorr           TYPE trkorr,
  gt_trfunc_sel       TYPE RANGE OF trfunction,
  gs_trfunc_sel       LIKE LINE OF gt_trfunc_sel,
  gt_note_request     TYPE SORTED TABLE OF trkorr WITH UNIQUE KEY table_line.

FIELD-SYMBOLS:
  <gs_request> TYPE zds_trcheckui,
  <gs_fcat>    TYPE slis_fieldcat_alv.

PARAMETERS:
  p_expdat  TYPE as4date OBLIGATORY.

SELECT-OPTIONS:
  s_user    FOR gs_truser-username,
  s_trfunc  FOR gs_e070-trfunction DEFAULT 'K'.

PARAMETERS:
  p_releas AS CHECKBOX DEFAULT abap_true.


INCLUDE zbc_tr_check_cl01.

INITIALIZATION.
  gs_trfunc_sel-sign = 'I'.
  gs_trfunc_sel-option = 'EQ'.
  gs_trfunc_sel-low = 'W'.
  APPEND gs_trfunc_sel TO s_trfunc.

START-OF-SELECTION.

  CONCATENATE sy-sysid '%' INTO gv_trkorr.
  CONDENSE gv_trkorr NO-GAPS.

  SELECT * FROM e070 INTO CORRESPONDING FIELDS OF TABLE gt_request
    WHERE trkorr LIKE gv_trkorr
      AND trfunction IN s_trfunc
      AND as4user IN s_user.

  LOOP AT gt_request ASSIGNING <gs_request>.
    CLEAR gs_request_info.

    CALL FUNCTION 'TR_READ_REQUEST'
      EXPORTING
        iv_read_e07t       = 'X'
        iv_read_e070c      = 'X'
        iv_read_e070m      = 'X'
        iv_read_attributes = 'X'
        iv_trkorr          = <gs_request>-trkorr
      CHANGING
        cs_request         = gs_request_info
      EXCEPTIONS
        error_occured      = 1
        no_authorization   = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.
    ENDIF.

    IF  <gs_request>-trfunction NA sctsc_types_projects.
      CALL FUNCTION 'TR_READ_ATTRIBUTES'
        EXPORTING
          iv_request    = <gs_request>-trkorr
        IMPORTING
          et_attributes = gs_request_info-attributes
        EXCEPTIONS
          OTHERS        = 1.
    ENDIF.


    READ TABLE gs_request_info-attributes INTO gs_trattrib
      WITH KEY attribute = 'EXPORT_TIMESTAMP'.

    <gs_request>-as4text = gs_request_info-h-as4text.

    IF sy-subrc EQ 0.
      <gs_request>-export_date = gs_trattrib-reference(8).
      <gs_request>-export_time = gs_trattrib-reference+8(8).
    ENDIF.

    IF <gs_request>-export_date LT p_expdat
      AND <gs_request>-export_date IS NOT INITIAL.
      DELETE gt_request.
      CONTINUE.
    ENDIF.

    CLEAR gs_cofile.
    CALL FUNCTION 'TR_READ_GLOBAL_INFO_OF_REQUEST'
      EXPORTING
        iv_trkorr  = <gs_request>-trkorr
      IMPORTING
        es_cofile  = gs_cofile
        ev_project = gv_project.

    LOOP AT gs_cofile-systems INTO gs_system.
      CASE gs_system-systemid.

        WHEN gc_sysid_dev.
          <gs_request>-retcode_d = gs_system-rc.

        WHEN gc_sysid_qua.
          READ TABLE gs_system-steps INTO gs_import_step WITH KEY stepid = 'I'."Import
          IF sy-subrc EQ 0.
            <gs_request>-retcode_q = gs_system-rc.
            READ TABLE gs_import_step-actions INTO gs_import_date_time INDEX 1.
            IF sy-subrc EQ 0.
              <gs_request>-import_date_q = gs_import_date_time-date.
              <gs_request>-import_time_q = gs_import_date_time-time.
            ENDIF.
          ENDIF.

        WHEN gc_sysid_prpr.
          READ TABLE gs_system-steps INTO gs_import_step WITH KEY stepid = 'I'."Import
          IF sy-subrc EQ 0.
            <gs_request>-retcode_q1 = gs_system-rc.
            READ TABLE gs_import_step-actions INTO gs_import_date_time INDEX 1.
            IF sy-subrc EQ 0.
              <gs_request>-import_date_q1 = gs_import_date_time-date.
              <gs_request>-import_time_q1 = gs_import_date_time-time.
            ENDIF.
          ENDIF.

        WHEN gc_sysid_prd.
          READ TABLE gs_system-steps INTO gs_import_step WITH KEY stepid = 'I'."Import
          IF sy-subrc EQ 0.
            <gs_request>-retcode_p = gs_system-rc.
            READ TABLE gs_import_step-actions INTO gs_import_date_time INDEX 1.
            IF sy-subrc EQ 0.
              <gs_request>-import_date_p = gs_import_date_time-date.
              <gs_request>-import_time_p = gs_import_date_time-time.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

  ENDLOOP.

  IF p_releas IS NOT INITIAL.
    DELETE gt_request WHERE export_date IS INITIAL.
  ENDIF.

  "Does the request contain Notes or Correcton Instructions ?
  IF gt_request IS NOT INITIAL.
    SELECT DISTINCT trkorr FROM e071 INTO TABLE gt_note_request
      FOR ALL ENTRIES IN gt_request
        WHERE trkorr EQ gt_request-trkorr
          AND object IN ( 'NOTE', 'CORR' ).

    LOOP AT gt_request ASSIGNING <gs_request>.
      IF line_exists( gt_note_request[ table_line = <gs_request>-trkorr ] ).
        <gs_request>-note = abap_true.
      ENDIF.
    ENDLOOP.

  ENDIF.

  SORT gt_request BY export_date export_time.

* Display Data
  lcl_view=>display_tr_list( ).

*&---------------------------------------------------------------------*
*&      Form  click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_UCOMM     text
*      -->CS_SELFIELD  text
*----------------------------------------------------------------------*
FORM dclick USING iv_ucomm TYPE syucomm
                  cs_selfield TYPE slis_selfield.

  DATA:
    ls_request_ui  TYPE zds_trcheckui.

  READ TABLE gt_request INTO ls_request_ui INDEX cs_selfield-tabindex.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'TR_LOG_OVERVIEW_REQUEST_REMOTE'
      EXPORTING
        iv_trkorr = ls_request_ui-trkorr.
  ENDIF.

ENDFORM.                    " L01_LOAD_USER_COMMAND
