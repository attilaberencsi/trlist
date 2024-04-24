@AbapCatalog.sqlViewName: 'ZITRREQQ'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view ZI_TransportRequestQuery
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

      /* Associations */
      _Attribute,
      _Text
}
