@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view entity ZI_TransportRequestQueryBase
  as select from ZI_TransportRequest
  association [0..1] to ZI_TransportObjectWithNote as _HasNote on $projection.Trkorr = _HasNote.Trkorr
  //association [1]    to ZI_TransportType           as _Type    on $projection.Trfunction = _Type.Low
{
  key Trkorr,
      _Text[ 1: Langu = $session.system_language ].As4text,
      //@ObjectModel.text.element: [ 'TrfunctionText' ]
      Trfunction,
      //_Type.Text                                                                                                   as TrfunctionText,
      Trstatus,
      Tarsystem,
      cast( _Attribute[ 1: Attribute = 'SAP_CTS_PROJECT' ].Reference as trkorr_p )                                 as CTSProject,
      As4user,
      As4date,
      As4time,

      cast( substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 1, 8 ) as zde_sapdev_tr_expdate ) as ExportDate,
      cast( substring(_Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference, 9, 6 ) as zde_sapdev_tr_exptime ) as ExportTime,

      _HasNote.IHaveNote,

      /* Associations */
      _Attribute,
      _Text
}

where
  Strkorr = '' // No tasks, just requests 
