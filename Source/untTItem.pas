//- untTItem ----------------------------------------------------------------
// Базовый класс предметов и соот. действия.
// maniac

unit untTItem;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untConsole,untTAction,CastleColors;

 type

 TItem=class(TCritter)
  private
//   slot:string;
   _inventored:boolean;//наличие на игроке для предметов треб. удержания, и вкл. для остальных
   procedure _setinventored(inve:boolean);
  public
//   quantity:integer;//количество.
   CurrentSlot:string;//текущая "точка подвески".
   inven_invisible,undroppable:boolean;
   InSlot:boolean;
//   currAction:TActionClass;
   CurrActionNum:integer;
   property inventored:boolean read _inventored write _setinventored;
   procedure SwitchAction;virtual;
   procedure SerializeData;override;
//   function Actions_GetDefault:string;virtual;
//   function Actions_GetDefaultAP:string;virtual;
   function GetComment:string;virtual;
   function GetSlotCompat(AItem:TItem;SlotNum:integer):integer;virtual;//ibility
   //результат- согласие на установку в
   //этот слот обьекта аргумента. По умолчанию - согласие.
   function GetSlot(SlotNum:integer):string;virtual;
   function GetSlotCount:integer;virtual;
   //не переоп. функция возвращает значение slot.
   procedure DropItem;virtual;
   procedure Take;virtual;
   procedure Equip(SlotNum:integer);virtual;//
//   procedure UseOn(target:TCritter);virtual;
   procedure UnEquip;virtual;//
   procedure Render;override;
   procedure OnInfluence_Sound(infl:TInfluence);override;
   procedure Tick;override;
   function GetVisible:boolean;override;
   constructor Create;override;
   function GetCurrAction:TActionClass;virtual;
   function GetActionByNum(aActNum:integer):TActionClass;virtual;
  end;

  TDeadBody=class(TItem)
  end;

  TAction_CreatureInvAction=class(TAction)
  public
   ItemID:string;
  end;

  TAction_CreatureEquip=class(TAction_CreatureInvAction) public procedure Tick;override;end;
  TAction_CreatureUnEquip=class(TAction) public item:TItem; procedure Tick;override; end;
  TAction_CreatureDrop=class(TAction) public item:TItem; procedure Tick;override; end;
  TAction_CreatureLiftItem=class(TAction) public item:TItem; procedure Tick;override; end;

  TItem_Inventored=class(TItem)
   function GetSlot(SlotNum:integer):string;override;
   function GetSlotCount:integer;override;
  end;
  //Предмет допускающий установку в инвентарь, возвращает один слот
  // требуется переопределять GetSlot в наследниках

  TWeapon=class(TItem_Inventored) end;

  {Базовые классы оружия}
  TWeapon_Throwing=class(TWeapon) end;//Метательное
  TWeapon_Melee=class(TWeapon) end;//Рукопашное
  TWeapon_Heavy=class(TWeapon) end;//??? Тяжелое (станковое)
  TWeapon_Firearm=class(TWeapon) end;//Огнестрел

  TWeapon_Shotgun=class(TWeapon_Firearm) end;
  TWeapon_SMG=class(TWeapon_Firearm) end;
  TWeapon_Rifle=class(TWeapon_Firearm) end;

  {BodyParts}
  TBodyPart=class(TItem_Inventored)
//   procedure Equip;override;
//   function GetDefaultSlot:string;override;
//   function GetCurrentSlotCompat(AItem:TItem):integer;override;
  end;

  TPonyBodyPart=class(TBodyPart) end;
  
  TPonyBodyPart_Head=class(TPonyBodyPart)
   function GetSlotCompat(AItem:TItem;SlotNum:integer):integer;override;
  end;
  TPonyBodyPart_Body=class(TPonyBodyPart)
   function GetSlotCompat(AItem:TItem;SlotNum:integer):integer;override;
  end;

  TPonyBodyPart_BackLeftLeg=class(TPonyBodyPart) end;
  TPonyBodyPart_BackRightLeg=class(TPonyBodyPart) end;

  TPonyBodyPart_FrontLeg=class(TPonyBodyPart)
  end;
  TPonyBodyPart_FrontRightLeg=class(TPonyBodyPart_FrontLeg)
   function GetSlotCompat(AItem:TItem;SlotNum:integer):integer;override;
  end;
  TPonyBodyPart_FrontLeftLeg=class(TPonyBodyPart_FrontLeg) end;

  const
   sltAllow=0;//Результаты GetItemComp... allow - однозначно можно установить в слот
   sltRefuse=1;//однозначно нельзя.
   sltUnknown=2;//код возврата означающий "пофих" (пример - опрос каски на совместимость с пистолетом)

   //текстовые константы слотов.
   sltPonyTelekineticField='sltPonyTelekineticField';//Телекинетическое поле
   sltPonyTelekineticFields='sltPonyTelekineticFieldS';//удержание множественных предметов телекинезом
   sltPonyBody='sltPonyBody';//торс
   sltPonyHead='sltPonyHead';//голова

implementation
uses untWorld,untTInfluence,untLog,untUtils,untSerialize
  //,Graphics
  ;

 function TPonyBodyPart_Body.GetSlotCompat(AItem:TItem;SlotNum:integer):integer;
 begin;
  if (AItem.GetSlot(SlotNum)=sltPonyBody)then result:=sltAllow else result:=sltUnknown;
 end;

 function TPonyBodyPart_Head.GetSlotCompat(AItem:TItem;SlotNum:integer):integer;
 begin;
  if (AItem.GetSlot(SlotNum)=sltPonyHead)then result:=sltAllow else result:=sltUnknown;
 end;

 function TPonyBodyPart_FrontRightLeg.GetSlotCompat(AItem:TItem;SlotNum:integer):integer;//BUGBUG  механика для гуманоида
 var i:integer;
 Sear:TSearcher;
 begin;
     if (AItem.GetSlot(SlotNum)<>sltPonyTelekineticField)and(AItem.GetSlot(SlotNum)<>sltPonyTelekineticFields) then
      result:=sltUnknown;
     if AItem.GetSlot(SlotNum)=sltPonyTelekineticField  then
      begin;
           Sear:=TSearcher.Create;
           if assigned(Sear.Find_ItemByslot(self.parent,sltPonyTelekineticFields)) then begin;
                _writeln(self.parent+' не могу поднять '+aitem.name);
                result:=sltRefuse;end
           else
                result:=sltAllow;
           Sear.free;
      end;
     if Aitem.GetSlot(SlotNum)=sltPonyTelekineticFields then
      begin;
            Sear:=TSearcher.Create;
            if assigned(Sear.Find_ItemByslot(self.parent,sltPonyTelekineticField)) then begin;
                result:=sltRefuse;
                _writeln(self.parent+' не могу поднять слишком большой предмет '+aitem.name);
                Sear.free;
                exit; end
            else result:=sltAllow;
            sear.free;
            result:=sltAllow;
       end;
 end;

{ function TBodyPart.GetCurrentSlotCompat(AItem:TItem):integer;
 begin;
  result:=inherited GetCurrentSlotCompat(AItem);
  if Aitem.GetDefaultSlot=self.CurrentSlot then result:=sltAllow
  else result:=sltUnknown;
 end;

 function TBodyPart.GetDefaultSlot:string;
 begin;
  result:='';
 end;

 procedure TBodyPart.Equip;
 begin;
 _write('-'+self.parent+' пытается установить TBodyPart 8)');
 end;  }

 function TItem.GetSlot(SlotNum:integer):string;
 begin;
  result:='';;
//  self.slot;
 end;

 function TItem.GetSlotCount:integer;
 begin;
  result:=0;
 end;

 function TItem_Inventored.GetSlot(SlotNum:integer):string;
 begin;
  result:='';;
  Log_write('- PANIC in class '+classname+' GetSlot isnt overrided');
 end;

 function TItem_Inventored.GetSlotCount:integer;
 begin;
  result:=1;
 end;

 function TItem.GetSlotCompat(AItem:TItem;SlotNum:integer):integer;
 begin;
  result:=sltUnknown;
  if (inslot)and(CurrentSlot=AItem.GetSlot(SlotNum)) then
   result:=sltRefuse;
 end;
 
 procedure TItem.SwitchAction;
 begin;
 //do nothing
 end;

 procedure TAction_CreatureLiftItem.Tick;
 var sear:TSearcher;chost:TCritter;
 begin;
  dec(timelength);
  if timelength=0 then
  begin;
  sear:=TSearcher.Create;
  chost:=sear.Find_CritterbyID(host);
  if (assigned(item))and(assigned(chost)) then
   if item.InheritsFrom(TItem) then
   begin;
    item.parent:=host;
    item.xpos:=chost.xpos;
    item.ypos:=chost.ypos;
    (item as TItem).Take;
    _writeln(chost.name+' поднял '+item.name);
   end;
   sear.free;
  end;
  if timelength=-1 then Recoil;
 end;

 procedure TAction_CreatureDrop.Tick;
 var sear:TSearcher;chost:TCritter;
 begin;
  dec(timelength);
  if timelength=0 then
  begin;
  sear:=TSearcher.Create;
  chost:=sear.Find_CritterbyID(host);
  if (assigned(item))and(assigned(chost)) then
   if item.InheritsFrom(TItem) then
   begin;
    (item as TItem).DropItem;
    if not((item as TItem).inventored) then _writeln(chost.name+' выбросил '+item.name);
   end;
  sear.Free;
  end;
  if timelength=-1 then Recoil;
 end;

 procedure TAction_CreatureUnEquip.Tick;
 begin;
  dec(timelength);
  if timelength=0 then
  begin;
  if assigned(self.Item) then
   if item.InheritsFrom(TItem) then
    if item.parent=self.host then
     if (item as TItem).InSlot then
       (item as TItem).UnEquip
  end;
  if timelength=0 then Recoil;
 end;

 procedure TAction_CreatureEquip.Tick;
 var InvSear,sear:TSearcher;an:TCritter;
  item,tmpItem:TItem;res:integer;allowed:boolean;
  label a;
 begin;
  allowed:=false;
  res:=sltRefuse;
  dec(timelength);
  if timelength=0 then
  begin;
   InvSear:=TSearcher.Create;
   Item:=pointer(InvSear.Find_CritterById(ItemID));
   if not(assigned(Item)) then begin;log_write('-'+host+'.TAction_CreatureEquip - empty item(nil)');Recoil;exit;end;
   if not(Item.InheritsFrom(TItem)) then begin;log_write('-'+host+'.TAction_CreatureEquip - item not inherits from TItem');Recoil;exit;end;
   if not(Item.parent=self.host) then begin;log_write('-'+host+'.TAction_CreatureEquip - item.'+item.parent+'<>host.'+host);Recoil;exit;end;

   InvSear.ResetSearch;tmpItem:=pointer(InvSear.Find_ItemInventoredBy(host));
   if not(assigned(tmpItem)) then begin;goto a;end;
   repeat
    res:=tmpItem.GetSlotCompat(Item,1);
    if res=sltAllow then allowed:=true;
    if res=sltRefuse then
     begin;
//      _write(host+': не могу установить '+Log_NameId(item)+' т.к. '+Log_NameId(tmpItem)+' мешает');
      InvSear.Destroy;
      Recoil;
      exit;
     end;
   tmpItem:=pointer(InvSear.Find_ItemInventoredBy(host));
   until not(assigned(tmpItem));

a:   InvSear.Destroy;
  begin;
  if allowed then (Item as TItem).Equip(1)
//   else _write(host+': не могу установить '+Log_NameId(item)+' т.к. '+item.GetSlot(1)+' слот не обнаружен 8)');
  end;
  end;

  if timelength=0 then Recoil;
 end;

 constructor TItem.Create;begin;inherited Create;end;

 procedure TItem.Tick;
 begin;
  inherited Tick;
 end;

function TItem.GetComment;begin;result:=name;end;

 procedure TItem.DropItem;
 var sear:TSearcher;par:TCritter;
 begin;
 sear:=TSearcher.Create;
 par:=sear.Find_CritterbyID(parent);
 if assigned(par) then
 begin;
  if undroppable
   then
    begin;_writeln(self.parent+' не могу выбросить '+Log_NameId(self));end
   else
   begin;
    InSlot:=false;
    inventored:=false;
    xpos:=par.xpos;
    ypos:=par.ypos;
    parent:='';
   end;
 end
 else
 begin;
  _writeln('-'+Log_NameId(self)+'.DropItem: parent'+parent+' not found');
 end;
 sear.free;   
 end;

 procedure TItem._setinventored;
 begin;
  if inve then begin;_inventored:=true;self.hidden:=true;end
   else begin;_inventored:=false;self.hidden:=false;end;
 end;


 procedure TItem.Take;
 begin;
  InSlot:=false;
  inventored:=true;
 end;

 procedure TItem.Equip;
 begin;
  InSlot:=true;inventored:=true;
  CurrentSlot:=GetSlot(SlotNum);
  _writeln(name+' установлен');
 end;

 function TItem.GetVisible:boolean;
 begin;
  if inventored then result:=false else result:=true;
 end;

 procedure TItem.UnEquip;
 begin;
  InSlot:=false;inventored:=true;
  CurrentSlot:='';
  _writeln(name+' снят');
 end;

// procedure TItem.UseOn(target:TCritter);begin;end;

 procedure TItem.Render;
 begin;
  if not(inventored) then
   location.RenderSymbol(xpos,ypos,zpos,'i',stnLaydown,index,GrayRGB);
 end;

{
 function TItem.Actions_GetDefault:string;
 begin;
  //do nothing
 end;
}

 function TItem.GetCurrAction:TActionClass;begin;result:=nil;end;
 function TItem.GetActionByNum(aActNum:integer):TActionClass;begin;result:=nil;end;

 procedure TItem.OnInfluence_Sound;
 begin;
  //итемы, они ента не слышат ничаго. вот.
 end;

 procedure TItem.SerializeData;
  begin;
   inherited SerializeData;
   SerializeFieldS('CurrentSlot',CurrentSlot);
   InSlot:=SerializeFieldB('InSlot',InSlot);
   inventored:=SerializeFieldB('inventored',inventored);
   inven_invisible:=SerializeFieldB('inven_invisible',inven_invisible);
   undroppable:=SerializeFieldB('undroppable',undroppable);
  end;

begin;
  AddSerialClass(TPonyBodyPart_Head);
  AddSerialClass(TPonyBodyPart_Body);
  AddSerialClass(TPonyBodyPart_BackRightLeg);
  AddSerialClass(TPonyBodyPart_FrontRightLeg);
  AddSerialClass(TPonyBodyPart_BackLeftLeg);
  AddSerialClass(TPonyBodyPart_FrontLeftLeg);
  AddSerialClass(TDeadBody);
end.
