@EndUserText.label: 'Transport Request'
@AccessControl.authorizationCheck: #PRIVILEGED_ONLY
@AccessControl.privilegedAssociations: [ '_UserName' ]
define view entity ZI_TransportRequest
  as select from e070

  association [0..*] to ZI_TransportRequest_Text     as _Text      on $projection.Trkorr = _Text.Trkorr
  association [0..*] to ZI_TransportRequestAttribute as _Attribute on $projection.Trkorr = _Attribute.Trkorr
  association [0..*] to ZI_TransportObject           as _Object    on $projection.Trkorr = _Object.Trkorr
  association [1]    to I_UserDescription            as _UserName  on $projection.As4user = _UserName.UserID

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

      -- Associations
      _Text,
      _Attribute,
      _Object,
      _UserName
}
