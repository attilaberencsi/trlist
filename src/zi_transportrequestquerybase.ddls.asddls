@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view entity ZI_TransportRequestQueryBase
  as select from ZI_TransportRequest
{
  key Trkorr,
      _Text[ 1: Langu = $session.system_language ].As4text,
      Trfunction,
      Trstatus,
      Tarsystem,
      cast( _Attribute[ 1: Attribute = 'SAP_CTS_PROJECT' ].Reference as trkorr_p )                                 as CTSProject,
      As4user,
      As4date,
      As4time,

      cast( substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 1, 8 ) as zde_sapdev_tr_expdate ) as ExportDate,

      cast( substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 9, 6 ) as zde_sapdev_tr_exptime ) as ExportTime,

      /* Associations */
      _Attribute,
      _Text
}

where
  Strkorr = '' // No tasks, just requests 
