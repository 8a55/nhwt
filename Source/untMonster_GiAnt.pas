//- untMonster_GiAnt ----------------------------------------------------------------
// Винегрет. Все сразу.
// maniac

unit untMonster_GiAnt;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untTItem,untTAction;
{
monster: GiAnts = Tarakan
HP: 15
SQ: 6
AP: 6
XP: 50
AC: 2 DR DT
Normal: 0 0
Laser: 0 0
Fire: 0 0
Plasma: 0 0
Explosion: 0 0
Attacks: Mandibles (60%, 3 AP, D:1d6,
Poison Type A)
}
type

 TMonster_GiAnt=class(TLiveCreature)
 public
  XP:integer;
  EnemyId:string;
  procedure SerializeData;override;
  procedure Tick;override;
  procedure Render;override;
 end;

 TMapMarker_type1=class(TCritter)
 public
  procedure Render;override;
 end;

 TAmmo_10mmPistol=class(TItem)//Магазин с патронами к ПМ
 public
  ammo:integer;
  procedure SerializeData;override;
 end;

 TWeapon_Pistol=class(TWeapon_Firearm)
  function GetSlot(SlotNum:integer):string;override; 
 end;

 TWeapon_10mmPistol=class(TWeapon_Pistol)
 public
//  ammo:integer;
  clip:string;
  test1:real;
//  magazine:TAmmo_10mmPistol;
//  procedure UseOn(target:TCritter);override;
//  function GetCurrentSlotCompat(AItem:TItem):integer;virtual;//ibility
  procedure DropItem;override;
  procedure SerializeData;override;
  procedure SwitchAction;override;
  function GetComment:string;override;
  constructor Create;override;
  function GetCurrAction:TActionClass;override;
  function GetActionByNum(aActNum:integer):TActionClass;override;
  destructor Destroy;override;
 end;

 TWeapon_LaserTagPistol=class(TWeapon_10mmPistol)
 public
  constructor Create;override;
 end;

 TWeapon_knife=class(TWeapon)
 public
//  procedure Use;override;
 end;

 TAction_FireArm_Reload=class(TAction)
 private
//  chost:TCritter;
//  sear_host:TSearcher;
 public
  procedure Tick;override;
//  procedure Doing;virtual;
  class function GetComment:string;override;
  function GetFriendlyName:string;override;
 end;

 TWeapon_GenRifle=class(TWeapon_10mmPistol)
 public
  function GetSlot(SlotNum:integer):string;override;
end;

 TItem_GenCloth=class(TItem_Inventored)
 public
  function GetSlot(SlotNum:integer):string;override;
 end;

 TItem_GenHeadCloth=class(TItem_Inventored)
 public
  function GetSlot(SlotNum:integer):string;override;
 end;

 TAI_ControllerChater_peasant2 = class(TAI_controller)
 public
  test:string;
  procedure SerializeData;override;
  procedure AddPercepted(infl:TInfluence);override;
  procedure AI_Tick;override;
 end;

 TAI_ControllerChater_peasant1 = class(TAI_controller)
 public
  playerhello:integer;
  procedure SerializeData;override;
  procedure AddPercepted(infl:TInfluence);override;
 end;

implementation
uses untConsole,untWorld,sysutils,untUtils,untTCharacter,untLog,untSerialize,untSpeak,untTInfluence,untTScreen,CastleColors,untGame;

constructor TWeapon_LaserTagPistol.Create;
begin;
 inherited;

end;


procedure TMapMarker_type1.Render;
begin;
 if not hidden then
  _screen.drawSprite('?',xpos,ypos,zpos,GreenRGB);
end;

procedure TAI_ControllerChater_peasant1.SerializeData;
  begin;
   inherited SerializeData;
   SerializeFieldI('playerhello',playerhello);
  end;

procedure TAI_ControllerChater_peasant1.AddPercepted(infl:TInfluence);
begin;
inherited AddPercepted(infl);
if (infl.InheritsFrom(TInfluence_Visual))and (infl.parent=idPlayer)
  and(playerhello=0)then
 begin;
  playerhello:=1;
  (location.Find_CritterbyID(hostid).DoInfluence(TInfluence_Sound_Talk_Speech)
  as TInfluence_Sound_Talk_Speech).text:='Блин, ну и хмырь.<сплевывает>';
 end;
end;

procedure TAI_ControllerChater_peasant2.SerializeData;
  begin;
   inherited SerializeData;
   SerializeFieldS('test',test);
  end;

procedure TAI_ControllerChater_peasant2.AddPercepted(infl:TInfluence);
begin;
inherited AddPercepted(infl);
if (infl.InheritsFrom(TInfluence_Sound_Talk_Answer))and (infl.parent=idPlayer)
 and (infl.target=hostid) then
 begin;
  if (infl as TInfluence_Sound_Talk_Answer).text='сказать: Смерть зебрам!' then test:='1';
  if (infl as TInfluence_Sound_Talk_Answer).text='<конец разговора>' then test:='2';
  if (infl as TInfluence_Sound_Talk_Answer).text='' then test:='0';
  if (infl as TInfluence_Sound_Talk_Answer).text='сказать: Привет' then
     begin;(Game as TGame).MapToLoad:='Map00';
     end;
 end;
end;

procedure TAI_ControllerChater_peasant2.AI_Tick;
var //a:TInfluence_Sound_Talk_Speech;
 host:TCharacter;
 begin;
  inherited;
  host:=pointer(location.Find_CritterbyID(self.hostid));
  if test='2' then
       host.DoInfluence(TInfluence_Sound_Talk_End);
  if test='1' then
  begin;
       (host.DoInfluence(TInfluence_Sound_Talk_Speech)
            as TInfluence_Sound_Talk_Speech).text:='Рим падет!';
       (host.DoInfluence(TInfluence_Sound_Talk_PossiblePhrase)
            as TInfluence_Sound_Talk_PossiblePhrase).text:='<конец разговора>';
  end;
  if test='0' then
  begin;
      (host.DoInfluence(TInfluence_Sound_Talk_Begin)
            as TInfluence_Sound_Talk_Begin).text:='Крестьянин';
      (host.DoInfluence(TInfluence_Sound_Talk_Speech)
            as TInfluence_Sound_Talk_Speech).text:=
            'Вы смотрите на усталого крестьянина. '+
            'Он говорит: Да здравствует Родина!';
      (host.DoInfluence(TInfluence_Sound_Talk_PossiblePhrase)
           as TInfluence_Sound_Talk_PossiblePhrase).text:='сказать: Привет';
      (host.DoInfluence(TInfluence_Sound_Talk_PossiblePhrase)
           as TInfluence_Sound_Talk_PossiblePhrase).text:='сказать: Смерть зебрам!';
  end;
  //(host.DoInfluence(TInfluence_Sound_Talk_Speech)as TInfluence_Sound_Talk_Speech).text:='111';
 end;

 function TItem_GenHeadCloth.GetSlot(SlotNum:integer):string;
 begin;
  result:=sltPonyHead;
 end;

 function TItem_GenCloth.GetSlot(SlotNum:integer):string;
 begin;
  result:=sltPonyBody;
 end;

 function TWeapon_GenRifle.GetSlot(SlotNum:integer):string;
 begin;
  result:=sltPonyTelekineticFields;
 end;

 class function TAction_FireArm_Reload.GetComment:string;
 begin;
  result:='Перезарядить';
 end;

 function TAction_FireArm_Reload.GetFriendlyName:string;
 begin;inherited GetFriendlyName;
  result:='Перезаряжаю';
 end;


 procedure TAction_FireArm_Reload.Tick;
 var
  weapon:TWeapon_10mmPistol;
  ammo_2reload:TAmmo_10mmPistol;
  Sear:TSearcher;
  a1:integer;
 label noammo;
 begin;
  { dec(timelength);
  if timelength=0 then
  begin;//BUGBUG search the inventory for best mag
   Sear:=TSearcher.Create;
   weapon:=(Sear.Find_CritterbyID(agent) as TWeapon_10mmPistol);sear.ResetSearch;
   if assigned(weapon) then    begin;
     ammo_2reload:=(Sear.Find_ItemByParentAndClass(host,TAmmo_10mmPistol.ClassName) as TAmmo_10mmPistol);//sear.ResetSearch;
     if ammo_2reload=nil then begin
      _write(host+': невозможно перезарядить - закончились заряды к '+weapon.name);goto noammo; end;
     if assigned(weapon.magazine) then begin;
       Location.Alloc_Critter(weapon.magazine);weapon.magazine.parent:=weapon.parent;
     end;
     weapon.magazine:=ammo_2reload;
     Location.RemoveCritter(ammo_2reload);ammo_2reload.parent:=weapon.id;
    end;
   noammo:
   sear.free;
  end;
  if timelength=0 then Recoil;      }
 end;

 procedure TWeapon_10mmPistol.DropItem;
 begin
  //BUGBUG drop clip
  inherited DropItem;
  clip:='';
 end;

 procedure TWeapon_10mmPistol.SwitchAction;
 begin;
 inc(CurrActionNum);if CurrActionNum=1 then CurrActionNum:=0;
 end;

 function TWeapon_Pistol.GetSlot(SlotNum:integer):string;
 begin;
  result:=sltPonyTelekineticField;
 end;

 function TWeapon_10mmPistol.GetComment:string;
 var   Sear:TSearcher;ammo:TAmmo_10mmPistol;
 begin;
  Sear:=TSearcher.Create;
 // ammo:=(Sear.Find_CritterbyID(clip) as TAmmo_10mmPistol);
  result:=name;
//  if assigned(magazine) then begin     result:=result+' '+inttostr(magazine.ammo)+' патронов';   end;
 //  if magazine.parent=self.parent then

//else result:=result+' пустой';

  sear.free;
 end;

function TWeapon_10mmPistol.GetCurrAction:TActionClass;
begin;inherited;
 GetActionByNum(CurrActionNum);
end;

function TWeapon_10mmPistol.GetActionByNum(aActNum:integer):TActionClass;
begin;inherited;
 if CurrActionNum=0 then result:=TAction_FireArm_SingleShot;
 //if CurrActionNum=1 then result:=TAction_FireArm_Reload;
end;

constructor TWeapon_10mmPistol.Create;
begin;
 inherited Create;
// currAction:=TAction_FireArm_SingleShot;

end;

destructor TWeapon_10mmPistol.Destroy;
begin
// if assigned(magazine)then magazine.Destroy;
end;

{
procedure TWeapon_10mmPistol.UseOn(target:TCritter);
begin;
end;
}

{procedure TWeapon_knife.Use;
 begin;
var dist,tohit,damage,dice:integer;
 parenta:TCritter;
 s2:TSearcher;
 msgn:integer;
 begin;
 s2:=TSearcher.create;
 parenta:=s2.Find_critterbyid(parent);
 dist:=location.Geom_calcdist(parenta.xpos,parenta.ypos,target.xpos,target.ypos);
 tohit:=(parenta as TCharacter).GetParamRes(prmMeleeWeapons);
 damage:=trunc(random(6));
 dice:=trunc(random(100));
 if dist>1 then begin;_write('Далековато.');exit;end;
 if dice<tohit then
  begin;
   (target as TLiveCreature).CurrHP:=(target as TLiveCreature).CurrHP-damage;
   _write(parenta.name+' пырнул '+target.name+' сняв '+inttostr(damage)+' хелсов ');
  end
 else
 begin;
 msgn:=trunc(random(2));
 case msgn of
 0:_write(parenta.name+' махнул ножиком над головой '+target.name);
 1:_write(parenta.name+' героически промахнулся, пытаясь пырнуть '+target.name);
 end;
 end;
 end;
}

 procedure TAmmo_10mmPistol.SerializeData;
 begin;
  inherited SerializeData;
  SerializeFieldI('ammo',ammo);
 end;

 procedure TWeapon_10mmPistol.SerializeData;
 var magazine2:TAmmo_10mmPistol;
 begin;
  inherited SerializeData;
  SerializeFieldFl('test1',test1);
  SerializeFieldS('clip',clip);
  //magazine:=SerializeFieldO('magazine',magazine)as TAmmo_10mmPistol;
//  туточки мы и покончили.
 end;

  procedure TMonster_GiAnt.Render;
   begin;
    _screen.writeXY('m',trunc(xpos),trunc(ypos),lyGround)
   end;

  procedure TMonster_GiAnt.SerializeData;
   begin;
    inherited SerializeData;
    SerializeFieldI('XP',XP);
    SerializeFieldS('EnemyId',EnemyId);
   end;

 procedure TMonster_GiAnt.Tick;//
 begin;
   inherited Tick;
  end;

begin;
AddSerialClass(TItem_GenHeadCloth);
AddSerialClass(TItem_GenCloth);
AddSerialClass(TAI_ControllerChater_peasant2);
AddSerialClass(TAI_ControllerChater_peasant1);
AddSerialClass(TWeapon_10mmPistol);
AddSerialClass(TWeapon_LaserTagPistol);
AddSerialClass(TWeapon_GenRifle);
AddSerialClass(TWeapon_knife);
AddSerialClass(TAmmo_10mmPistol);
AddSerialClass(TMapMarker_type1);
end.





