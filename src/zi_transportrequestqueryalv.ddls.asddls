@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
@Search.searchable: true
define view entity ZI_TransportRequestQueryALV
  as select from ZI_TransportRequestQueryBase
{
  key Trkorr,
      @Search.defaultSearchElement: true
      As4text,
      Trstatus,
      Trfunction,
      IHaveNote,
      Tarsystem,
      CTSProject,
      As4user,
      As4date,
      As4time,
      cast ( ExportDate as zde_sapdev_tr_export_date ) as ExportDate,
      cast( ExportTime as zde_sapdev_tr_export_time )  as ExportTime,

      //      cast( concat(substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 1, 4),
      //      concat('-',
      //      concat(substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 5, 2),
      //      concat('-',substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 7, 2 ))))) as zde_sapdev_tr_expdate_t )  as ExpDateText,
      //
      //      cast(
      //      concat(substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 9, 2),
      //      concat(':',
      //      concat(substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 11, 2),
      //      concat(':',substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 13, 2 ))))) as zde_sapdev_tr_exptime_t ) as ExpTimeText,

      /* Associations */
      _Attribute,
      _Text
}
