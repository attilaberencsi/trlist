@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@Search.searchable: true
define view entity ZI_TransportType
  as select from ZI_DomainFixedValueLow
{
      @UI.hidden: true
  key ZI_DomainFixedValueLow.DomainName,
      @EndUserText.label: 'Status' -- Custom label text
  key ZI_DomainFixedValueLow.Low,
      @Semantics.text: true            -- identifies the text field
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ZI_DomainFixedValueLow.Text
}

where
  ZI_DomainFixedValueLow.DomainName = 'TRFUNCTION'
