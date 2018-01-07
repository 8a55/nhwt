//- untActorBase ----------------------------------------------------------------
// Базовые классы актеров. Некоторые константы. 
// maniac

unit untActorBase;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untSerialize,untConsole,Classes,untActorBaseConst;

const
 MaxUniqObjectsSeed=1000;{ TODO -cTODO : Завести глобальный список всех обьектов, там проверять уникальность ид }

type

 TCritter=class;
 TInfluence=class;
 TAction=class;
 TCreature=class;

 TInfluenceClass = class of TInfluence;

 TTagsList=class(Tstringlist)
  public
   function GetTag(aTagname:string):string;
   function DelTag(aTagname:string):string;
   function SetTag(aTagname,aValue:string):string;
 end;

 TNamedObject=class(TSerialObject)
 public
  name,id,parent:String;
  procedure SetUniqueNameID;virtual;
  constructor Create;override;
  procedure SerializeData;override;
 end;

 TCritter=class(TNamedObject)// basic class for all world objects
 public
  tags:TTagsList;
  tagsFilename:string;
  index:integer;
  description:string;
  size:integer;
  // position info
  xpos,ypos,zpos:real;
  immhalt,hidden:boolean;
  LastTickTime:longword;//время последнего тика.
  // time info
  procedure Tick;virtual;//abstract;
  procedure SerializeData;override;
  procedure Render;virtual;
  function GetVisible:boolean;virtual;
  function GetPhysics(a_x,a_y,a_z:real):integer;virtual;
  procedure GetPhysicsBoundingBox(var res_x,res_y,res_z,res_w,res_h,res_d:real);virtual;

  procedure SamoKill;//destroy self and deleting from critters table;

  procedure OnInfluence;virtual;

  procedure OnInfluence_Track;virtual;
  procedure OnInfluence_Sound(infl:TInfluence);virtual;
  procedure OnInfluence_Visual(infl:TInfluence);virtual;
  procedure OnInfluence_projectile_bullet(infl:TInfluence);virtual;
  function DoInfluence(InfluenceClass:TInfluenceClass):TInfluence;virtual;
  constructor Create;override;
  destructor Destroy;override;
  procedure Action_MoveDelta(dx,dy,dz:real);virtual;  
 end;

 TAction=class(TNamedObject)//не обьект мира, след. от ТКриттер не наследует
 public
  timelength,priority:integer;
  agent,host:string;//host - хозяин, агент - предмет выполняющий действие.
  class function GetComment:string;virtual;
  procedure SerializeData;override;
  procedure Tick;virtual;//abstract;
  constructor Create;override;
  procedure Recoil;virtual;
  procedure Recoil2;virtual;
  function GetFriendlyName:string;virtual;
 end;

 TActionClass = class of TAction;

 TPerceptedCritter = class
  TimeWhen:longword; //Время обнаружения криттера.
  xpos,ypos,zpos:real;
  id:string;
  sense:integer;
 end;

 TAI_controller = class (TSerialObject)
 public
  lastchangetime:DWord;
  lastnewperceptedtime:DWord;
  hostid:String;
  PerceptedCritters:array of TPerceptedCritter;
  procedure AddPercepted(infl:TInfluence);virtual;overload;
  procedure AddPercepted(aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer);virtual;overload;
  function  FindAlikePercepted(infl:TInfluence):integer;virtual;
  function  IsPercepted(aID:string):boolean;virtual;
  procedure RemovePercepted(infl:TInfluence);virtual;
  constructor Create;override;
  procedure SerializeData;override;
  procedure AI_Tick;virtual;
  procedure OnInfluence(infl:TInfluence);virtual;
 end;



 TInfluence=class(TCritter)
   public
   //parent,
   target:string;//index in critters table
   countdown:integer;
   procedure SerializeData;override;
   constructor Create;override;
   procedure Render;override;
  end;

  TCreature=class(TCritter)
  protected
   skillmatrix:array of array of integer;//0..maxParams,0..maxModifs
   fbRecall:boolean;//< Сюда Скиллматрикс
  public
  currAction:TAction;
  AI_controller:TAI_controller;
  target:string;//текущая цель, используеться в подсчете пенальти внимания
  glance:real;//теперь по 45 градусов
  stance:integer;
//  BodyPosition:integer;//Дописать соот константы. присядка, лежа, стоя, к стене, и.т.д.

  procedure Sklmtrx_WriteParam(Param,Modif,Value:integer);virtual;
  function Sklmtrx_GetParam(Param,Modif:integer):integer;virtual;
  function Sklmtrx_GetParamRes(Param:integer):integer;virtual;
//  function Sklmtrx_SumParms(aParam,aLastModif:integer):integer;virtual;
  procedure Sklmtrx_DumpMtrx;virtual;
  procedure Sklmtrx_Recalculate;virtual;
  procedure Sklmtrx_AddMod(aParam,aModif,aValue:integer);

  procedure Tick;override;
  procedure SerializeData;override;

  procedure Inven_DropItem(aItem:TCritter);virtual;//параметр- указатель на предмет инвентаря
  procedure Inven_LiftItem(aItem:TCritter);virtual;
  procedure Inven_PutItemToSlot(aItem:TCritter);virtual;
  procedure Inven_RemoveItemFromSlot(aItem:TCritter);virtual;

  procedure OnInfluence_Track;override;
  procedure OnInfluence_Visual(infl:TInfluence);override;
  procedure OnInfluence_Sound(infl:TInfluence);override;
  procedure OnInfluence_projectile_bullet(infl:TInfluence);override;

  procedure Action_MoveDelta(dx,dy,dz:real);override;

  procedure Action_Idle;virtual;

  function DoAction(ActionClass:TActionClass):TAction;virtual;

  function GetPhysics(a_x,a_y,a_z:real):integer;override;
  procedure GetPhysicsBoundingBox(var res_x,res_y,res_z,res_w,res_h,res_d:real);override;

  constructor Create;override;
  destructor Destroy;override;
 end;

 TLiveCreature=class(TCreature)
 public
  procedure OnInfluence_projectile_bullet(infl:TInfluence);override;
  procedure Tick;override;
 end;

 //-----------------------------------------------------------------------------
 //-----------------------------------------------------------------------------
 //------------------------------ implementation -------------------------------
 //-----------------------------------------------------------------------------
 //-----------------------------------------------------------------------------
implementation
uses untWorld,untTItem,untTInfluence,untTAction,SysUtils,untLog,untUtils,StrUtils;

 function TTagsList.GetTag(aTagname:string):string;
  var tmpindx:integer;
  begin;tmpindx:=IndexOf(aTagname);result:='';
   if tmpindx<>-1 then
    result:=strings[tmpindx+1];
  end;
 function TTagsList.DelTag(aTagname:string):string;
  var tmpindx:integer;
  begin;tmpindx:=IndexOf(aTagname);
   if tmpindx<>-1 then
    begin;
     Delete(tmpindx+1);
     Delete(tmpindx);
    end;
  end;
 function TTagsList.SetTag(aTagname,aValue:string):string;
  var tmpindx:integer;
  begin;tmpindx:=IndexOf(aTagname);
   if tmpindx<>-1 then strings[tmpindx+1]:=aValue
    else
     begin;
      Append(aTagName);Append(aValue);
     end;
   end;

 function TCreature.GetPhysics(a_x,a_y,a_z:real):integer;
 var radius:real;
 begin;
  radius:=0.5;
  if
    (a_x>=xpos-radius)and(a_x<=xpos+radius)and
    (a_y>=ypos-radius)and(a_y<=ypos+radius)and
    (a_z>=zpos-radius)and(a_z<=zpos+radius)
   then
    result:=stSolid
   else
    result:=stEtheral;
  if hidden then result:=stEtheral;
 end;

 procedure TCreature.GetPhysicsBoundingBox(var res_x,res_y,res_z,res_w,res_h,res_d:real);
 var radius,res:real;
 begin;
  radius:=0.5;
  res:=0.9;
  //res_x:=xpos;res_y:=ypos;res_z:=zpos;res_w:=1;res_h:=1;res_d:=1;
  res_x:=xpos-radius;res_y:=ypos-radius;res_z:=zpos-radius;res_w:=res;res_h:=res;res_d:=res;
 end;

 function TCritter.GetPhysics;
 begin;
  result:=stEtheral;
 end;

 procedure TCritter.GetPhysicsBoundingBox(var res_x,res_y,res_z,res_w,res_h,res_d:real);
 begin;
  res_x:=xpos;res_y:=ypos;res_z:=zpos;res_w:=0;res_h:=0;res_d:=0;
 end;

 procedure TInfluence.Render;
 begin;
 end;

 procedure TAI_Controller.SerializeData;
 var PerceptedCrittersCount:integer;
   aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer;
  i:integer;
 begin;
 inherited;
  SerializeFieldS('hostid',hostid);
  SerializeFieldLW('lastchangetime',lastchangetime);
  SerializeFieldLW('lastnewperceptedtime',lastnewperceptedtime);
  //SerializeFieldS('tagsFilename',tagsFilename);      and(tags.Count<>0)
  if (serialMode=smSave) then
   begin;
    PerceptedCrittersCount:=0;//length(PerceptedCritters)-1;
    for i:=0 to length(PerceptedCritters)-1 do
     if assigned(PerceptedCritters[i]) then
      begin;
       SerializeFieldLW('PerceptedCritters_'+inttostr(i)+'_TimeWhen',PerceptedCritters[i].TimeWhen);
       SerializeFieldS('PerceptedCritters_'+inttostr(i)+'_id',PerceptedCritters[i].id);
       SerializeFieldFL('PerceptedCritters_'+inttostr(i)+'_xpos',PerceptedCritters[i].xpos);
       SerializeFieldFL('PerceptedCritters_'+inttostr(i)+'_ypos',PerceptedCritters[i].ypos);
       SerializeFieldFL('PerceptedCritters_'+inttostr(i)+'_zpos',PerceptedCritters[i].zpos);
       SerializeFieldI('PerceptedCritters_'+inttostr(i)+'_sense',PerceptedCritters[i].sense);
       PerceptedCrittersCount:=i;
      end;
     SerializeFieldI('PerceptedCrittersCount',PerceptedCrittersCount);
   end;

    {   TPerceptedCritter = class
  TimeWhen:longword; //Время обнаружения криттера.
  xpos,ypos,zpos:real;
  id:string;
  sense:integer;
 end;   }

  if serialMode=smLoad then
   begin;PerceptedCrittersCount:=0;
    SerializeFieldI('PerceptedCrittersCount',PerceptedCrittersCount);
    SetLength(PerceptedCritters,PerceptedCrittersCount+1);PerceptedCrittersCount:=0;

    for i:=0 to length(PerceptedCritters)-1 do
     //if assigned(PerceptedCritters[i]) then
      begin;
       aTimeWhen:=0;aid:='';axpos:=0;aypos:=0;azpos:=0;asense:=0;

       SerializeFieldS('PerceptedCritters_'+inttostr(i)+'_id',aid);
       if aid<>'' then begin;
        SerializeFieldLW('PerceptedCritters_'+inttostr(i)+'_TimeWhen',aTimeWhen);
        SerializeFieldFL('PerceptedCritters_'+inttostr(i)+'_xpos',axpos);
        SerializeFieldFL('PerceptedCritters_'+inttostr(i)+'_ypos',aypos);
        SerializeFieldFL('PerceptedCritters_'+inttostr(i)+'_zpos',azpos);
        SerializeFieldI('PerceptedCritters_'+inttostr(i)+'_sense',asense);
        AddPercepted(aTimeWhen,axpos,aypos,azpos,'',aid,asense);
       end;
       //AddPercepted(aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer);
      end;

   end;

  if (serialMode<>smLoad)and(serialMode<>smSave) then Begin;
    _writeln('!TCritter.SerializeData -unknown serialization operation');
    Abort;
   end;

 end;

 procedure TAI_Controller.AI_Tick;
 var i:integer;
 begin;
   for i:=0 to length(PerceptedCritters)-1 do //Чистка
   if assigned(PerceptedCritters[i]) then
    begin;
    if PerceptedCritters[i].TimeWhen<location.Time then
     begin;
      log_write(hostid+'.AI_Tick : cleaned - '+PerceptedCritters[i].id);
      PerceptedCritters[i].free;
      PerceptedCritters[i]:=nil;
     end;
    end;
 end;

 destructor TCreature.Destroy;
 begin;
  AI_controller.free;
  AI_controller:=nil;
 end;

 procedure TCreature.OnInfluence_Sound(infl:TInfluence);
 var sear1:TSearcher; j:integer;
 begin;
  if (infl.parent=self.id) then exit;
//  if assigned(AI_controller) then AI_controller.AddPercepted(infl);
 end;

 procedure TCreature.OnInfluence_Visual(infl:TInfluence);
 var sear1:TSearcher; j:integer;
 begin;
  if (infl.parent=self.id) then exit;
  debug_TLosEvaluator_dumplosarray:=true;
  if assigned(AI_controller) then AI_controller.AddPercepted(infl);
   debug_TLosEvaluator_dumplosarray:=false;
 end;

 constructor TAI_controller.Create;
 begin;
  SetLength(PerceptedCritters,1);//BUG BUG
 end;

 procedure TAI_controller.RemovePercepted(infl:TInfluence);
  var i:integer;
  begin;
   for i:=0 to length(PerceptedCritters)-1 do
    if assigned(PerceptedCritters[i]) then
     if PerceptedCritters[i].id=infl.parent then
      begin;
       log_write('TAI_controller.RemovePercepted '+PerceptedCritters[i].id+' removed');
       PerceptedCritters[i].free;PerceptedCritters[i]:=nil;
       lastchangetime:=Location.Time;
      end;
  end;

  function TAI_controller.FindAlikePercepted(infl:TInfluence):integer;
  var i:integer;
  begin;
   result:=-1;
   for i:=0 to length(PerceptedCritters)-1 do
    if assigned(PerceptedCritters[i]) then
     if PerceptedCritters[i].id=infl.parent then result:=i;
  end;

  function TAI_controller.IsPercepted(aID:string):boolean;
  var i:integer;
  begin;
   result:=false;
   for i:=0 to length(PerceptedCritters)-1 do
    if assigned(PerceptedCritters[i]) then
     if PerceptedCritters[i].id=aID then result:=true;
  end;

  procedure TAI_controller.OnInfluence(infl:TInfluence);begin;end;

  procedure TAI_controller.AddPercepted(infl:TInfluence);
  var sense:integer;
  begin;
   if infl.inheritsfrom(TInfluence_Visual) then
    sense:=snsVisual;
   if infl.inheritsfrom(TInfluence_Sound) then
    sense:=snsSound;
   if infl.inheritsfrom(TInfluence_Etheral) then
    sense:=snsEtheral;

   AddPercepted(
    Location.time,
    infl.xpos,infl.ypos,infl.zpos,infl.id,infl.parent,
    sense);
    {     //PerceptedCritters[i]:=TPerceptedCritter.Create;
      PerceptedCritters[i].TimeWhen:=aTimeWhen;//Location.time;
      PerceptedCritters[i].id:=ainfl_parent;
      PerceptedCritters[i].xpos:=axpos;
      PerceptedCritters[i].ypos:=aypos;
      PerceptedCritters[i].zpos:=azpos;
      //Органы чувств
      {snsVisual=0;
      snsSound=1;
      snsEtheral=2;}
   {   if infl.inheritsfrom(TInfluence_Visual) then
       begin;PerceptedCritters[i].sense:=snsVisual;log_write(tmpmsg+' via view');end;
      if infl.inheritsfrom(TInfluence_Sound) then
       begin;PerceptedCritters[i].sense:=snsSound;log_write(tmpmsg+' via sound');end;
      if infl.inheritsfrom(TInfluence_Etheral) then
       begin;PerceptedCritters[i].sense:=snsEtheral;log_write(tmpmsg+' via etheral');end;        }
  end;

  procedure TAI_controller.AddPercepted(aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer);
  var i:integer;tmpmsg:string;
  label a;

   procedure add;
   begin;
      //PerceptedCritters[i]:=TPerceptedCritter.Create;
      PerceptedCritters[i].TimeWhen:=aTimeWhen;//Location.time;
      lastchangetime:=aTimeWhen;
      PerceptedCritters[i].id:=ainfl_parent;
      PerceptedCritters[i].xpos:=axpos;
      PerceptedCritters[i].ypos:=aypos;
      PerceptedCritters[i].zpos:=azpos;
      if asense=snsVisual then begin;PerceptedCritters[i].sense:=snsVisual;log_write(tmpmsg+' via view');end;
      if asense=snsSound then begin;PerceptedCritters[i].sense:=snsSound;log_write(tmpmsg+' via sound');end;
      if asense=snsEtheral then begin;PerceptedCritters[i].sense:=snsEtheral;log_write(tmpmsg+' via etheral');end;
   end;

  begin;
   if ainfl_parent=self.hostid then exit;

   a:
    for i:=0 to length(PerceptedCritters)-1 do
     if assigned(PerceptedCritters[i]) then
      if PerceptedCritters[i].id=ainfl_parent then begin;
       tmpmsg:=hostid+' AI: refresh percepted '+ainfl_parent;
       add;
       exit;
      end;

    for i:=0 to length(PerceptedCritters)-1 do
     if not(assigned(PerceptedCritters[i])) then begin;
       PerceptedCritters[i]:=TPerceptedCritter.Create;
       tmpmsg:=hostid+' AI: add percepted '+ainfl_parent;
       lastnewperceptedtime:=aTimeWhen;

       add;
       exit;
      end;

    SetLength(PerceptedCritters,length(PerceptedCritters)+5);
    goto a;
  end;

procedure TCreature.Sklmtrx_AddMod(aParam,aModif,aValue:integer);
begin;
  fbRecall:=true;
  skillmatrix[aParam,aModif]:=skillmatrix[aParam,aModif]+aValue;
end;

procedure TCreature.Sklmtrx_Recalculate;
var iParam,iModif,itmpprmTrtGifted,tmpSkillsNum:integer;
procedure AddMod(aParam,aModif,aValue:integer);
begin;
  skillmatrix[aParam,aModif]:=skillmatrix[aParam,aModif]+aValue;
end;
procedure r;//Пересчет
var iParam,iModif:integer;
begin;
  for iParam:=0 to maxParams do
  begin;
   skillmatrix[iParam,maxModifs]:=0;
   for iModif:=maxModifs-1 downto 0 do skillmatrix[iParam,maxModifs]:=skillmatrix[iParam,maxModifs]+skillmatrix[iParam,iModif];
  end;
  fbRecall:=false;
end;

function Sklmtrx_GetParam(Param,Modif:integer):integer;
 begin;
  result:=skillmatrix[Param,Modif];
 end;

function Sklmtrx_GetParamRes(Param:integer):integer;
 begin;
  result:=Sklmtrx_GetParam(Param,modResult);
 end;

begin;// Собсно расчет
 //зануление действия трейтов-модификаторов
for iParam:=0 to maxParams do
 skillmatrix[iParam,modTrait]:=0;
// prmTrtGifted
if skillmatrix[prmTrtGifted,modBase]<>0 then
 begin;
  for itmpprmTrtGifted:=prmSTR to prmLK do AddMod(itmpprmTrtGifted,modTrait,1);
  for itmpprmTrtGifted:=prmFirstSkill to prmLastSkill
   do AddMod(itmpprmTrtGifted,modTrait,-10);
 end;
//-----------------------------------------------------------------------------
//Fast Metabolism
if skillmatrix[prmTrtFastMetabolism,modBase]<>0 then
 begin;
  AddMod(prmHealRate,modTrait,2);
  AddMod(prmPoisResist,modTrait,0);//BUG BUG Надо занулять все до этого парма.
  AddMod(prmRadResist,modTrait,0);//BUG BUG
 end;
// Finesse
if skillmatrix[prmTrtFinesse,modBase]<>0 then
 begin;
  AddMod(prmCritChance,modTrait,10);
 end;
// Good Natured
if skillmatrix[prmTrtGoodNatured,modBase]<>0 then
 begin;
  AddMod(prmFirstAid,modTrait,20);
  AddMod(prmDoctor,modTrait,20);
  AddMod(prmBarter,modTrait,20);
  AddMod(prmSmallGuns,modTrait,-10);
  AddMod(prmBigGuns,modTrait,-10);
  AddMod(prmEnergyWeapons,modTrait,-10);
  AddMod(prmUnarmed,modTrait,-10);
  AddMod(prmMeleeWeapons,modTrait,-10);
 end;

// Вторичная статистика
skillmatrix[prmBaseHP,modPrim]:=20+skillmatrix[prmSTR,modBase]+skillmatrix[prmEN,modBase];
skillmatrix[prmAP,modPrim]:=skillmatrix[prmAG,modBase];
 if skillmatrix[prmAP,modPrim]<=5 then skillmatrix[prmAP,modPrim]:=5;
//skillmatrix[prmMaxCWeight,modPrim]:=25*skillmatrix[prmSTR,modBase];//obsolete because Small Frame implemen
skillmatrix[prmPoisResist,modPrim]:=3*skillmatrix[prmEN,modBase];
skillmatrix[prmRadResist,modPrim]:=2*skillmatrix[prmEN,modBase];
skillmatrix[prmHealRate,modPrim]:=round(0.5*skillmatrix[prmEN,modBase]);//BUG BUG
skillmatrix[prmMeleeDamage,modPrim]:=skillmatrix[prmSTR,modBase];//BUG BUG

//BUGBUG - наложение эффектов трейтов
// Max Curr Weight
//  Small Frame
 if skillmatrix[prmTrtSmallFrame,modBase]<>0
  then
   begin;
   skillmatrix[prmMaxCWeight,modPrim]:=15*Sklmtrx_GetParamRes(prmStr);
   AddMod(prmAG,modTrait,1);
   end
  else
   begin;
   skillmatrix[prmMaxCWeight,modPrim]:=25*Sklmtrx_GetParamRes(prmStr);
   end;
// AC
 skillmatrix[prmAC,modPrim]:=skillmatrix[prmAG,modBase];
// Seq
 skillmatrix[prmSequence,modPrim]:=skillmatrix[prmPE,modBase]+skillmatrix[prmLK,modBase];
// Crit Chance
 skillmatrix[prmCritChance,modPrim]:=skillmatrix[prmLK,modBase];

//  Kamikaze
 if skillmatrix[prmTrtKamikaze,modBase]<>0
  then
   begin;
    skillmatrix[prmAC,modPrim]:=0;
    AddMod(prmSequence,modTrait,5);
   end;
// Heavy Handed
if skillmatrix[prmTrtHeavyHanded,modBase]<>0 then
 begin;
  AddMod(prmMeleeDamage,modTrait,4);// +4 unarmed damage
  AddMod(prmCritChance,modTrait,-30);// -30% crit chanse
 end;
// Bruiser
if skillmatrix[prmTrtBruiser,modBase]<>0 then
 begin;
  AddMod(prmSTR,modTrait,2);
  AddMod(prmAP,modTrait,-2);
 end;
// Small Frame
if skillmatrix[prmTrtSmallFrame,modBase]<>0 then
 begin;
  AddMod(prmAG,modTrait,1);
 end;

// Скиллы
skillmatrix[prmSmallGuns,modBase]:=35;
 skillmatrix[prmSmallGuns,modPrim]:=Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmBigGuns,modBase]:=10;
 skillmatrix[prmBigGuns,modPrim]:=Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmEnergyWeapons,modBase]:=10;
 skillmatrix[prmEnergyWeapons,modPrim]:=Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmUnarmed,modBase]:=40;
 skillmatrix[prmUnarmed,modPrim]:=trunc((Sklmtrx_GetParamRes(prmAG)+Sklmtrx_GetParamRes(prmSTR))/2);
skillmatrix[prmMeleeWeapons,modBase]:=25;
 skillmatrix[prmMeleeWeapons,modPrim]:=Sklmtrx_GetParamRes(prmSTR)+Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmThrowing,modBase]:=40;
 skillmatrix[prmThrowing,modPrim]:=Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmFirstAid,modBase]:=30;
  skillmatrix[prmFirstAid,modPrim]:=trunc((Sklmtrx_GetParamRes(prmPE)+Sklmtrx_GetParamRes(prmINT))/2);
skillmatrix[prmDoctor,modBase]:=15;
  skillmatrix[prmDoctor,modPrim]:=trunc((Sklmtrx_GetParamRes(prmPE)+Sklmtrx_GetParamRes(prmINT))/2);
skillmatrix[prmDriving,modPrim]:=2*trunc(Sklmtrx_GetParamRes(prmPE)+Sklmtrx_GetParamRes(prmAG));
skillmatrix[prmSneak,modBase]:=25;
 skillmatrix[prmSneak,modPrim]:=Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmLockpick,modBase]:=20;
  skillmatrix[prmLockpick,modPrim]:=trunc((Sklmtrx_GetParamRes(prmPE)+Sklmtrx_GetParamRes(prmAG))/2);
skillmatrix[prmSteal,modBase]:=20;
 skillmatrix[prmSteal,modPrim]:=Sklmtrx_GetParamRes(prmAG);
skillmatrix[prmTraps,modBase]:=10;
 skillmatrix[prmTraps,modPrim]:=Sklmtrx_GetParamRes(prmAG)+Sklmtrx_GetParamRes(prmPE);
skillmatrix[prmScience,modPrim]:=4*Sklmtrx_GetParamRes(prmINT);
skillmatrix[prmRepair,modPrim]:=3*Sklmtrx_GetParamRes(prmINT);
skillmatrix[prmSpeech,modBase]:=25;
 skillmatrix[prmSpeech,modPrim]:=2*Sklmtrx_GetParamRes(prmCH);
skillmatrix[prmBarter,modBase]:=20;
 skillmatrix[prmBarter,modPrim]:=2*Sklmtrx_GetParamRes(prmCH);
skillmatrix[prmGambling,modBase]:=20;
 skillmatrix[prmGambling,modPrim]:=5*Sklmtrx_GetParamRes(prmLK);
skillmatrix[prmOutdoorsman,modPrim]:=2*(Sklmtrx_GetParamRes(prmEN)+Sklmtrx_GetParamRes(prmINT));

//Начальные бонуса (+20%) прописываются в Трейтах
  tmpSkillsNum:=prmLastSkill-prmFirstSkill;
  for itmpprmTrtGifted:=0 to tmpSkillsNum do
   if skillmatrix[itmpprmTrtGifted+prmFirstTagSkill,modBase]<>0 then
   AddMod(itmpprmTrtGifted+prmFirstSkill,modTrait,20)
   else
   AddMod(itmpprmTrtGifted+prmFirstSkill,modTrait,0);
   //типа подсчет итогов.
   r;//пересчет
//Защита от отрицательных параметров
  if skillmatrix[prmCritChance,modresult]<0 then skillmatrix[prmCritChance,modresult]:=0;// -30% crit chanse
 end;

{function TCreature.sklmtrx_SumParms;
var iModif:integer;
begin;
result:=0;
 for iModif:=0 to aLastModif do
 result:=result+skillmatrix[aParam,iModif];
end;}

procedure TCreature.sklmtrx_DumpMtrx;
 var dump:textfile;
  i,j:integer;
  strTmp1:string;
  t:smallint;
 function getname (i:integer):string;
 begin;
  result:=inttostr(i);
  if i<prmFirstSkill then result:=result+strPrimaryNames[i];
  if (i>=prmFirstSkill) and (i<=prmLastSkill) then result:=result+strSkillsName[i-prmFirstSkill];
  if (i>prmLastSkill) and (i<prmFirstTrait) then result:=result+'tag'+strSkillsName[i-prmLastSkill-1];
  if (i>=prmFirstTrait) and (i<=prmLastTrait) then result:=result+strTraitsName[i-prmFirstTrait];
  if (i>=prmLastTrait) then result:=result+strMiscName[i-prmLastTrait-1];
 end;

 begin;
  assignfile(dump,'TCharacterDump.csv');
  rewrite(dump);
  //writeln(dump,id);
  strTmp1:=strdop(id,20)+#9+'base'+#9+'prim'+#9+'perk'+#9+'trait'+#9+'user'+#9+'drugs'+#9+'result';
  writeln(dump,strTmp1);
  for i:=0 to 8 do begin;
   writeln(dump,'test'+ExtractDelimited(i,strTmp1,[#9]));
  end;

  for i:=0 to MaxParams do
   begin;
    write(dump,strdop(getname(i),20)+#9);
    for j:=0 to MaxModifs do write(dump,inttostr(skillmatrix[i,j])+#9);
    writeln(dump);
   end;
  closefile(dump);
 end;

 procedure TCreature.Sklmtrx_WriteParam(Param,Modif,Value:integer);
 begin;
  skillmatrix[Param,Modif]:=value;
  fbRecall:=true;
//  _write(astr:string);
 end;

 function TCreature.Sklmtrx_GetParam(Param,Modif:integer):integer;
 begin;
  if fbRecall then self.Sklmtrx_Recalculate;
  result:=skillmatrix[Param,Modif];
 end;

 function TCreature.Sklmtrx_GetParamRes(Param:integer):integer;
 begin;
  result:=Sklmtrx_GetParam(Param,modResult);
 end;

 constructor TCreature.Create;
 begin;
 inherited Create;
//  self.AI_controller:=TAI_controller.Create;
  SetLength(skillmatrix,maxParams+1,maxModifs+1);
 end;

 procedure TCreature.Tick;
 var vis:TInfluence_Visual;
 snd:TInfluence_Sound;
 begin;
  inherited Tick;
  if Self.GetVisible then
  begin;
   vis:=TInfluence_Visual(DoInfluence(TInfluence_Visual));
   vis.extrainfo:=id;
  end;
{
  snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
  snd.extrainfo:=id;
  snd.radius:=255;
}
  log_write(Log_NameId(self)+' ticked');
 end;

 class function TAction.GetComment:string;
 begin;
 result:='action:'+classname;
 end;

 procedure TAction.Recoil2;
 var
  sear_host:TSearcher;
  chost:TCritter;
 begin;
  dec(timelength);
  if timelength=0 then
  begin;
	 priority:=apRecoil;
	 sear_host:=TSearcher.create;chost:=sear_host.Find_CritterbyID(host);sear_host.free;
	 if assigned(chost) then (chost as TCreature).currAction:=nil//надо написать макрос освобождения слота действий.
	  else log_write('-TAction.Recoil - chost-nil');
	 self.free;
  end;
 end;

 procedure TAction.Recoil;
 var
  sear_host:TSearcher;
  chost:TCritter;
 begin;
  priority:=apRecoil;
  sear_host:=TSearcher.create;chost:=sear_host.Find_CritterbyID(host);sear_host.free;
  if assigned(chost) then (chost as TCreature).currAction:=nil//надо написать макрос освобождения слота действий.
   else log_write('-TAction.Recoil - chost-nil');
  self.free;
 end;

 function TCritter.DoInfluence(InfluenceClass:TInfluenceClass):TInfluence;
 begin;
  result:=InfluenceClass.Create;
  result:=TInfluence(location.Alloc_Critter(TCritter(result)));
  result.parent:=self.id;
  result.xpos:=xpos;//??
  result.ypos:=ypos;
  result.zpos:=zpos;
 end;

 procedure TCreature.Action_MoveDelta(dx,dy,dz:real);
 var
  InvSear:TSearcher;nx,ny,nz:real;Item:TCritter;gphys,blockcriter:integer;idblock:string;
 begin;
  nx:=xpos+dx;ny:=ypos+dy;nz:=zpos+dz;
  gphys:=location.GetPhysics(nx,ny,nz,blockcriter,Self.index);
  if (gphys=stSolid)or(gphys=stOpaque) then begin;
   if self.id=idPlayer then begin;
//   if self.id=blockcriter then
   location.GetPhysics(nx,ny,nz,blockcriter,Self.index);//BUGBUG
     if assigned(Location.Critters[blockcriter])then idblock:=Location.Critters[blockcriter].id;
     log_write('DEBUG player.Action_MoveDelta blocked by:'+idblock+' '+inttostr(blockcriter));
    end;
   exit;
  end;
  begin
    if debug_physics then
     log_write('DEBUG player.Action_MoveDelta :'+idblock+' '+inttostr(blockcriter));
    self.xpos:=(xpos+dx);
    self.ypos:=(ypos+dy);
    self.zpos:=(zpos+dz);
  end;
  inherited Action_MoveDelta(dx,dy,dz);
  if (xpos=nx)and(ypos=ny)and(zpos=nz) then
   begin;
    InvSear:=TSearcher.Create;
    Item:=InvSear.Find_ItemInventoredBy(Id);
    if not(assigned(Item)) then begin;InvSear.Destroy;exit;end;
    repeat
     Item.xpos:=xpos;Item.ypos:=ypos;Item.zpos:=zpos;
     Item:=InvSear.Find_ItemInventoredBy(Id);     
    until not(assigned(Item));
    InvSear.Destroy;
   end;
 end;

 function TCreature.DoAction(ActionClass:TActionClass):TAction;
 begin;
  if ActionClass=nil then begin;
    if assigned(currAction) then currAction.destroy;
    currAction:=nil;result:=nil;exit;
   end;
  result:=ActionClass.Create;
  result.host:=id;
  result.agent:='';
  if assigned(currAction) then
   begin;
    if currAction.priority>result.priority
     then begin;result.free;result:=nil;exit;end
     else
      begin;
       currAction.destroy;currAction:=result;
      end;
   end
   else currAction:=result;// в принципе баг.
 end;

 procedure TAction.Tick;
 begin
  log_write(host+' '+self.ClassName+' .tick');
 end;

 function TAction.GetFriendlyName:string;
 begin;
  result:=className;
 end;

 procedure TAction.SerializeData;
 begin;
  inherited SerializeData;
  SerializeFieldS('name',name);
  SerializeFieldI('timelength',timelength);
  SerializeFieldS('host',host);
 end;

 constructor TAction.Create;
 begin;
  inherited Create;
  timelength:=1;//Защита от дурака.
 end;

 procedure TLiveCreature.OnInfluence_projectile_bullet(infl:TInfluence);
 var damage:integer;
 begin;
  damage:=(infl as TInfluence_projectile_bullet).damage;
//  _write(name+' ранен '+infl.parent+' на '+inttostr(damage)+' очков жизни');
  self.Sklmtrx_AddMod(prmCurrHP,modUser,-1*damage);
  DoAction(nil);
 end;

 constructor TInfluence.Create;
 begin;
  inherited;
 end;

 procedure TLiveCreature.Tick;
 var dead:TDeadBody;tmpInven,HP:integer;
 begin;
  inherited Tick;
   HP:=Sklmtrx_GetParamRes(prmCurrHP);
   if (HP<=0)//and (pos(id,'player')=0)
     then
   begin;                               
  // self.Sklmtrx_DumpMtrx;
   dead:=Tdeadbody.create;
   if dead=location.Alloc_Critter(dead) then
   begin;
    dead.id:='dead_'+self.id;
    dead.name:='Тело '+name;
    dead.xpos:=self.xpos;
    dead.ypos:=self.ypos;
//    dead.quantity:=1;
    _writeln('кажется '+self.name+' скончался');
    for tmpInven:=0 to maxCritters do
     if assigned(Location.Critters[tmpInven]) then
      if (Location.Critters[tmpInven].parent=id)and(Location.Critters[tmpInven].InheritsFrom(TItem)) then
       if ((Location.Critters[tmpInven] as TItem).inventored)and(not((Location.Critters[tmpInven] as TItem).undroppable)) then begin;
        (Location.Critters[tmpInven] as TItem).DropItem;
       end;
    self.SamoKill;
    immhalt:=true;
   end;
   end;
 end;

 procedure TInfluence.SerializeData;
 begin;
  inherited;
 // SerializeFieldS('parent',parent);
  SerializeFieldS('target',target);
  SerializeFieldI('countdown',countdown);
 end;

 constructor TCritter.Create;
 begin;
  inherited Create;
  immhalt:=false;
//  _write('TCritter.Create '+name);
  tags:=TTagsList.create;
 end;

 constructor TNamedObject.Create;
 begin;
  inherited Create;
  SetUniqueNameID;
 end;

 procedure TNamedObject.SetUniqueNameID;
 var rand:string;
 begin;
  rand:=inttostr(random(MaxUniqObjectsSeed));
  name:=classname+'_'+rand;
  id:=classname+'_'+rand;//BUGBUG check for unique
 end;

 procedure TNamedObject.SerializeData;
 begin;
  inherited;
  SerializeFieldS('name',name);//name:String;
  SerializeFieldS('id',id);
  SerializeFieldS('parent',parent);
 end;

 destructor TCritter.Destroy;
 begin;
  inherited;
  tags.destroy;
 end;

 procedure TCreature.Inven_RemoveItemFromSlot(aItem:TCritter);
 var act:TAction_CreatureUnEquip;
 begin;
  act:=(DoAction(TAction_CreatureUnEquip) as TAction_CreatureUnEquip);
  act.item:=(aItem as TItem);
  act.timelength:=1;
 end;

 procedure TCreature.Inven_PutItemToSlot(aItem:TCritter);
 var act:TAction_CreatureEquip;
  begin;
   act:=(DoAction(TAction_CreatureEquip) as TAction_CreatureEquip);
   act.ItemId:=(aItem as TItem).id;
   act.timelength:=1;
  end;

 procedure TCreature.Inven_DropItem;
 var act:TAction_CreatureDrop;
 begin;
  act:=(DoAction(TAction_CreatureDrop) as TAction_CreatureDrop);
  act.item:=(aItem as TItem);
  act.timelength:=1;
 end;

 procedure TCreature.Inven_LiftItem;
 var act:TAction_CreatureLiftItem;
 begin;
  act:=(DoAction(TAction_CreatureLiftItem) as TAction_CreatureLiftItem);
  act.item:=(aItem as TItem);
  act.timelength:=1;
 end;

 procedure TCreature.Action_Idle;
 begin;
 // do nothing 8)))
 end;

 procedure TCritter.Action_MoveDelta(dx,dy,dz:real);
 var i:TCritter;sear:TSearcher;
 begin;
 //BUG BUG
{  sear:=TSearcher.create;
  i:=(sear.Find_CritterBiggerThan(trunc(xpos+dx),trunc(ypos+dy),Size));
    if (xpos+dx>=0)
    and (xpos+dx<=maxLocationXSize)
    and (ypos+dy>=0)
    and (ypos+dy<=maxLocationXSize) then
    if (i=nil) and (wcViewMoveRating[location.ground[trunc(xpos+dx),trunc(ypos+dy),trunc(zpos)].GroundType]>0)//BUG BUG
   then}

//  sear.free;
 end;

 function TCritter.GetVisible:boolean;
 begin;
  result:=not hidden;
 end;
 procedure TCritter.Render;
 begin;
  _writeln('WARNING - TCRITTER.Render called!');
 end;
 procedure TCritter.OnInfluence_Track;
 begin;
  _writeln('WARNING - TCRITTER.OnInfluence_Track called!');
 end;
 procedure TCritter.OnInfluence;
 begin;
  _writeln('WARNING - TCRITTER.OnInfluence called!');
 end;

 procedure TCritter.Tick;
 begin;
//
 end;

 procedure TCritter.SamoKill;
 begin;
  immhalt:=true;
 end;

 procedure TCritter.OnInfluence_Visual(infl:TInfluence);
 begin;
  log_write(infl.parent+' -> '+name);
 end;

 procedure TCritter.OnInfluence_Sound(infl:TInfluence);
 begin;
  if infl.parent<>self.id then log_write(name+' '+id+' hear '+infl.name
  +' '+infl.description);//я думаю, напоминать криттеру, что он слышит свои шаги несколько бессмысленно
 end;

 procedure TCritter.OnInfluence_projectile_bullet;
  begin;
   _writeln(self.name+'.OnInfluence_projectile_bullet - tracked by '+infl.name);
  end;

 procedure TCreature.OnInfluence_projectile_bullet;
 begin;
  inherited;
  if assigned(AI_controller) then AI_controller.OnInfluence(infl);
 end;

 procedure TCreature.OnInfluence_Track;
  begin;
   _writeln(self.name+'.OnInfluence_Track - tracked');
  end;

 procedure TCritter.SerializeData;
 begin;
  inherited;
  SerializeFieldFl('xpos',self.xpos);
  SerializeFieldFl('ypos',self.ypos);
  SerializeFieldFl('zpos',self.zpos);
  SerializeFieldI('size',size);
  hidden:=SerializeFieldB('hidden',hidden);
  //SerializeFieldS('tagsFilename',tagsFilename);
  if (serialMode=smSave)and(tags.Count<>0) then
   begin;
    tags.SaveToFile(SerialFileName+'_tags');
   end;
  if serialMode=smLoad then
   begin;
    try
     tags.LoadFromFile(SerialFileName+'_tags');
    except;
    end;
   end;
  if (serialMode<>smLoad)and(serialMode<>smSave) then Begin;
    _writeln('!TCritter.SerializeData -unknown serialization operation');
    Abort;
   end;

 end;

 procedure TCreature.SerializeData;
 var iParam,iModif:integer;
 begin;
  inherited SerializeData;
  SerializeFieldLW('LastTickTime',LastTickTime);
  SerializeFieldFl('glance',glance);
  SerializeFieldI('stance',stance);
  SerializeFieldS('target',target);
  for iParam:=0 to maxParams do
   for iModif:=0 to maxModifs do
   begin;
    SerializeFieldI('SkillMatrix_'+inttostr(iParam)+'_'+inttostr(iModif),skillmatrix[iParam,iModif]);
   end;
  AI_controller:=pointer(SerializeFieldO('AI_controller',AI_controller));
  if not assigned(AI_controller) then _writeln('!TCreature.SerializeData -ai_controller not assigned!');
  currAction:=pointer(SerializeFieldO('currAction',currAction));
 end;

begin;

end.
