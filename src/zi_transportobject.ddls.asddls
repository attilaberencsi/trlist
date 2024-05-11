@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Objects in Transport Request/Task'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_TransportObject
  as select from e071
{
  key trkorr   as Trkorr,
  key as4pos   as As4pos,
      pgmid    as Pgmid,
      object   as Object,
      obj_name as ObjName,
      objfunc  as Objfunc,
      lockflag as Lockflag,
      gennum   as Gennum,
      lang     as Lang,
      activity as Activity
}
