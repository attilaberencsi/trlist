@AbapCatalog.sqlViewName: 'ZITRREQA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Attributes'
define view ZI_TransportRequestAttribute
  as select from e070a
{
  key trkorr    as Trkorr,
  key pos       as Pos,
      attribute as Attribute,
      reference as Reference
}
