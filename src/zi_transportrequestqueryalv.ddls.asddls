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
      ExportDate,
      ExportTime,

      /* Associations */
      _Attribute,
      _Text
}
