@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request'
define view entity ZI_TransportRequest
  as select from e070

  association [0..*] to ZI_TransportRequest_Text     as _Text      on $projection.Trkorr = _Text.Trkorr
  association [0..*] to ZI_TransportRequestAttribute as _Attribute on $projection.Trkorr = _Attribute.Trkorr

{
      @ObjectModel.text.association: '_Text'
  key trkorr     as Trkorr,
      trfunction as Trfunction,
      trstatus   as Trstatus,
      tarsystem  as Tarsystem,
      korrdev    as Korrdev,
      as4user    as As4user,
      as4date    as As4date,
      as4time    as As4time,
      strkorr    as Strkorr,

      --Associations
      _Text,
      _Attribute
}
