//- untTCharacter ----------------------------------------------------------------
// Базовый класс для персонажа
// maniac

unit untTCharacter;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses untTAction,untActorBase,CastleColors;

type

TCharacter=class(TLiveCreature)
public
 constructor Create;override;
 procedure SerializeData;override;
 procedure Render;override;
/// function GetPhysics(a_x,a_y,a_z:real):integer;override;
 procedure Tick;override;
end;

TCharacterUser=class(TCharacter)
public
 procedure Render;override;
// constructor Create;override;
end;

TCharacterMonsterTest=class(TCharacter)
public
 procedure Tick;override;
// constructor Create;override;
 procedure SerializeData;override;
 function DoAction(ActionClass:TActionClass):TAction;override;
end;

TAI_ControllerMonster = class(TAI_controller)
public
 target:string;
 procedure SerializeData;override;
 procedure AI_Tick;override;
 constructor Create;override;
end;

implementation
uses SysUtils,untConsole,
  //Graphics,
  untLog,untTItem,untWorld,untSerialize,untSpeak,untTScreen,math,untUtils,
  untGame,castle_base,CastleControls,CastleRectangles;

procedure TAI_ControllerMonster.SerializeData;
begin;
 inherited SerializeData;
 SerializeFieldS('target',target);
end;

constructor TAI_ControllerMonster.Create;
begin;
 inherited;
end;


procedure TCharacterMonsterTest.Tick;
begin;
 inherited;
end;

function TCharacterMonsterTest.DoAction(ActionClass:TActionClass):TAction;
begin;
 result:=inherited DoAction(ActionClass);
end;

procedure TAI_ControllerMonster.AI_Tick;
 var i:integer;
 ihand:TItem;
 enemy,hand:TCritter;
 sear:TSearcher;
 cAction:TAction;
 currAction:TActionClass;
 host:TCreature;
 begin;
  inherited;
  for i:=0 to length(location.critters)-1 do
   if assigned(location.critters[i]) then
    if location.critters[i].inheritsfrom(TCreature) then
     if (location.critters[i] as TCreature).AI_controller=self then
      host:=TCreature(location.critters[i]);
  for i:=0 to length(self.PerceptedCritters)-1 do
   if assigned(PerceptedCritters[i]) then
    if PerceptedCritters[i].id=target then
  begin;
	   log_write(host.id+' '+self.ClassName+' Attacking');
	   sear:=TSearcher.create;
	   enemy:=sear.Find_CritterbyID(target);sear.ResetSearch;
	   if not(assigned(enemy)) then begin;log_write(host.id+' '+self.ClassName+' cannot find enemy');sear.free;exit;end;
	   hand:=sear.Find_ItemBySlot(host.id,'hand');
	   if not(assigned(hand)) then begin;log_write(host.id+' '+self.ClassName+' hand empty');sear.free;exit;end;
	   if not(hand.InheritsFrom(TWeapon)) then begin;log_write(host.id+' '+self.ClassName+' not weapons in hand');sear.free;exit;end;
	   currAction:=(hand as TItem).GetCurrAction;
	   cAction:=(host as TCharacter).DoAction(currAction);
	   if assigned(cAction) then cAction.agent:=hand.id;
	   sear.free;
  end;
 end;

 procedure TCharacter.Tick;
 begin;
  inherited Tick;
  if assigned(currAction) then
   currAction.Tick
  { else
    begin;
     DoAction(TAction_Idle);
     currAction.Tick;
    end; }
 end;

 {function TCharacter.GetPhysics(a_x,a_y,a_z:real):integer;
 begin;
  if (a_x=xpos)and(a_y=ypos)and(a_z=zpos) then
   result:=stSolid;
 end; }

 procedure TCharacter.Render;
 begin;
  //location.RenderSymbol(xpos,ypos,zpos,'.',index,GreenRGB,MaxCritters);
  if not hidden then _screen.drawSprite('*',xpos,ypos,lyGround,GreenRGB);
  if id=idPlayer then _screen.drawSprite('O',xpos,ypos,lyGround-1,grayrgb)
 end;

constructor TCharacter.Create;
 var i,j:integer;
 begin;
  inherited Create;
  for i:=0 to MaxParams do for j:=0 to MaxModifs do skillmatrix[i,j]:=0;
 end;

 procedure TCharacter.SerializeData;
 begin;
  inherited SerializeData;
 end;

procedure TCharacterMonsterTest.SerializeData;
 begin;
  inherited SerializeData;
 end;

procedure TCharacterUser.Render;
var  tmpcolor2:TCastleColorRGB = ( 0.2 , 0.2 , 0.2);
 tmpcolor3:TCastleColorRGB = ( 0.8, 0.8 , 0.8);
 tmpcolor:TCastleColorRGB = ( 0.9, 0 , 0);
 i,j,k:integer;
 dist,angl:real;
begin;
 inherited;
 if tags.GetTag(tagMyFaction)<>tagCNT_Player then exit;
// case glance of
//_screen.drawSprite(FloatToStr(glance),(xpos-2),(ypos-2),lyGUI2,tmpcolor);
//_screen.drawSprite('.',(xpos+2*cos((90-glance)/57)),(ypos-2*sin((90-glance)/57)),lyGUI,tmpcolor);

//if id=idPlayer then
 for i:=20 to 30 do begin;
  for j:=0 to 3 do tmpcolor[j]:=(20-i)/20-0.1;
  dist:=0.05;//Random();//4;
  angl:=60;
   for k:=0 to 3 do
   if (Game as TGame).paused then begin;
//     _screen.drawSprite('.',(xpos+dist*i*cos((90-glance-angl-k)/57)),(ypos-dist*i*sin((90-glance-angl-k)/57)),lyGUI2,tmpcolor);
//     _screen.drawSprite('.',(xpos+dist*i*cos((90-glance+angl-k)/57)),(ypos-dist*i*sin((90-glance+angl-k)/57)),lyGUI2,tmpcolor);
   end;
   _screen.drawSprite('.',(xpos+dist*i*cos((90-glance)/57)),(ypos-dist*i*sin((90-glance)/57)),lyGUI2,grayrgb);
 end;
// Theme.Draw(Rectangle(round(xpos*CharH),Window.Height-round(ypos*CharW), CharH, CharW), tiActiveFrame);
end;



begin;
//AddSerialClass('TCharacter',TCharacter);
AddSerialClass(TCharacterUser);
AddSerialClass(TAI_ControllerMonster);
AddSerialClass(TCharacterMonsterTest);
end.
