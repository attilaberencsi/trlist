@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view entity ZC_TransportRequestQuery

  as select from ZI_TRANSPORTREQUESTQUERY( p_sys_dev: 'A4H' , p_sys_qua: 'A4T' , p_sys_pre: 'A4Q' , p_sys_prod: 'A4P' )
{
  key Trkorr,
      Trfunction,
      Trstatus,
      Tarsystem,
      Korrdev,
      As4user,
      As4date,
      As4time,
      Strkorr,
      As4text,
      ExportTimeStamp,
      CTSProject,
      StatusText,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as abap.char(255)) as Status,


      /* Associations */
      _Attribute,
      _Text
}
