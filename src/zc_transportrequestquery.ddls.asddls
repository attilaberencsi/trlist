@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view entity ZC_TransportRequestQuery
  as select from ZI_TransportRequestQueryBase
{
  key Trkorr,
      As4text,
      Trfunction,
      Trstatus,
      Tarsystem,
      CTSProject,
      As4user,
      As4date,
      As4time,
      ExportDate,
      ExportTime,

      cast ( 'A4H' as trtarsys )                  as SystemIdDev,
      cast ( 'A4H' as trtarsys )                  as SystemIdQuality,
      cast ( 'A4H' as trtarsys )                  as SystemIdPreProd,
      cast ( 'A4H' as trtarsys )                  as SystemIdProd,

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as zde_sapdev_tr_rc_d )           as retcode_d,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as  zde_sapdev_tr_rc_d )          as retcode_q,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as  zde_sapdev_tr_impdate_q )     as import_date_q,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_imptime_q )    as import_time_q,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_rc_pre )       as retcode_q1,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_impdate_pre )  as import_date_q1,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_imptime_pre )  as import_time_q1,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_rc_prod )      as retcode_p,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_impdate_prod ) as import_date_p,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as   zde_sapdev_tr_imptime_prod ) as import_time_p,

      /* Associations */
      _Attribute,
      _Text
}
