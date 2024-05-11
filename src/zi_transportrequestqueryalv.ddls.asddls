@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Query'
define view entity ZI_TransportRequestQueryALV
  as select from ZI_TransportRequestQueryBase
{
  key Trkorr,
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
