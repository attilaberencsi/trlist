FUNCTION conversion_exit_ztim0_output.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT)
*"  EXPORTING
*"     VALUE(OUTPUT)
*"----------------------------------------------------------------------
  IF input IS INITIAL.
    output = ''.
  ELSE.
    DATA(typed_time) = CONV tims( input ).
    output = |{ typed_time TIME = USER }|.
  ENDIF.

ENDFUNCTION.
