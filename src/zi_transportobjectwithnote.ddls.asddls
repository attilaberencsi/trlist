@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Requets/Tasks with Note/Correction I.'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_TransportObjectWithNote
  as select distinct from ZI_TransportObject
{
  key Trkorr,
      cast ( 'X' as zde_sapdev_tr_has_note ) as IHaveNote
}

where
     Object = 'NOTE'
  or Object = 'CORR'
