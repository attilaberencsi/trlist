@AbapCatalog.sqlViewName: 'ZITRREQT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Request Description'
@ObjectModel.dataCategory: #TEXT
define view ZI_TransportRequest_Text
  as select from e07t
{
      @ObjectModel.text.element: [ 'As4text' ]
  key trkorr  as Trkorr,
      @Semantics.language: true
  key langu   as Langu,
      @Semantics.text: true
      as4text as As4text
}
