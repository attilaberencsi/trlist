@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view entity ZI_TRANSPORTREQUESTQUERY
  with parameters
    p_sys_dev  : trtarsys,
    p_sys_qua  : trtarsys,
    p_sys_pre  : trtarsys,
    p_sys_prod : trtarsys
  as select from ZI_TransportRequest
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
      _Text[ 1: Langu = $session.system_language ].As4text,
      _Attribute[ 1: Attribute = 'EXPORT_TIMESTAMP' ].Reference as ExportTimeStamp,
      _Attribute[ 1: Attribute = 'SAP_CTS_PROJECT' ].Reference  as CTSProject,

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SAPDEV_TRANSPORT_VIRTUAL'
      cast( ''  as abap.char(255))                              as StatusText,

      /* Associations */
      _Attribute,
      _Text
}

where
  Strkorr = ''
