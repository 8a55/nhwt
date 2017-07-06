unit untAI;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untSerialize;
 type

 TAI_Order = class(TSerialObject)
  procedure AI_TickActive;virtual;abstract;//Приказ активен
  procedure AI_TickInactive;virtual;abstract;//Приказ неактивен
 end;

 TAI_OrderSurvive = class(TAI_Order)
{инстинкт /желание/ самосохранения. При критическом состоянии здоровья персонаж должен убегать}
//  procedure AI_Tick;override;
 end;

 TAI_OrderAttack = class(TAI_Order){Аттака на цель.}
//  procedure AI_Tick;override;
 end;

 TAI_ControllerOrdered = class(TAI_controller)
 public
  orders:array of TAI_order;
//  procedure AddOrder;
  procedure AI_Tick;override;
 end;

  TAI_ControllerUser = class(TAI_controller)
  public
//  ha:string;
  order_moveto_x,order_moveto_y:real;
  AggressionLevel:integer;
  oldhp:integer;
  constructor Create;override;
  procedure SerializeData;override;
  procedure AI_Tick;override;
//  procedure AddPercepted(infl:TInfluence);virtual;overload;
//  procedure AddPercepted(aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer);virtual;overload;
 end;

const
{Приоритеты приказов}
 Aop_Max=50;
 Aop_Average=25;
 Aop_Min=0;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation
uses untTScreen,untUtils,untConsole,untTAction,untTItem,untMonster_GiAnt,
  untWorld,untGame,untTCharacter;

constructor TAI_ControllerUser.Create;
 begin;
  inherited;
 end;

procedure TAI_ControllerUser.SerializeData;
var player:tcritter;
 begin;
  inherited;
  SerializeFieldI('AggressionLevel',AggressionLevel);
  SerializeFieldI('oldhp',oldhp);
  player:=Location.Find_CritterbyID(hostid);
  if oldhp=0 then
   if assigned(player) then oldhp:=
    (player as TCreature).Sklmtrx_GetParamRes(prmCurrHP);
 end;

procedure TAI_ControllerUser.AI_Tick;
 var i:integer;
  ptarget,host,hand,player:tcritter;sear2:TSearcher;
  ihand:titem;
  cAction:Taction;
  fck:boolean;
  myfaction,ptarget_tag_enemyof:string;
 begin;fck:=false;
  inherited;
//  _writeln(hostid+'controller aitick');
   player:=Location.Find_CritterbyID(hostid);
   myfaction:=player.tags.GetTag(tagMyFaction);
   if idPLayer<>hostid then
     begin;
      for i:=0 to length(PerceptedCritters)-1 do
       if assigned(PerceptedCritters[i]) then begin;
          ptarget:=Location.Find_CritterbyID(PerceptedCritters[i].id);

          if assigned(ptarget) then begin
           ptarget_tag_enemyof:=ptarget.tags.GetTag(tagEnemyOf);
           if ((ptarget_tag_enemyof)=myfaction)and(AggressionLevel=agrFireAtWill)//and(PerceptedCritters[i].sense=snsVisual)
              or ((ptarget_tag_enemyof)=myfaction)and
                 ((ptarget as TCreature).target=player.id)and
                 (AggressionLevel=agrReturnFire)//and
                // (PerceptedCritters[i].sense=snsVisual)
            then
            begin;fck:=false;
                  if not assigned ((player as TCreature).currAction) then fck:=true
                   else if ((player as TCreature).currAction.ClassType=TAction_Idle) then fck:=true;

                  if fck then begin;
	                 sear2:=TSearcher.create;sear2.ResetSearch;
	                 hand:=(Game as Tgame).gethanditem(player);
	                 if assigned(hand) then begin;
	                   ihand:=(hand as TItem);
                       (player as TCharacter).target:=ptarget.id;
	                   cAction:=(player as TCharacter).DoAction(ihand.GetCurrAction);
        //               hand as TItem do SwitchAction; for TAction_Attack desc
	                   if _ASSERT(cAction) then _writeln('???')
	                   else
	                   begin;
	                    cAction.agent:=hand.id;
	                   end;
	                 end
                     else begin;
                       cAction:=(player as TCharacter).DoAction(nil);
                       if player.tags.GetTag(tagMyFaction)=tagCNT_Player then
                         _writeln(player.name+' безоружен, вижу противника!');
                     end;
	                 sear2.free;
                   end;
            end;
{           if (ptarget.tags.GetTag(tagEnemyOfPlayer)<>'')and(AggressionLevel=agrReturnFire) then begin;

             _writeln(player.name+' безоружен, вижу противника!');
           end;                                                   }
{          if (ptarget.tags.GetTag(tagEnemyOfPlayer)<>'')and(AggressionLevel=agrCeaseFire)
           then begin;
           (PerceptedCritters[i].
             _writeln(player.name+' наблюдаю противника!');
           end;   }


          end;
       end;

     if oldhp<>(player as TCreature).Sklmtrx_GetParamRes(prmCurrHP)then begin;
       oldhp:=(player as TCreature).Sklmtrx_GetParamRes(prmCurrHP);
       //cAction:=(player as TCharacter).DoAction(nil);
       if player.tags.GetTag(tagMyFaction)=tagCNT_Player then _writeln(player.name+' я ранен!');
     end;

     end;
 end;

procedure TAI_ControllerOrdered.AI_Tick;
 var currOrd,currAop:integer;
 begin;
  for currAop:=Aop_Max downto Aop_min do
   for currOrd:=0 to high(orders) do
    if assigned(orders[currOrd]) then
     begin;
//      orders[currOrd].AI_Tick;
     end;
 end;

{procedure TAI_OrderAttack.AI_Tick;
 begin;

 end;

procedure TAI_OrderSurvive.AI_Tick;
 begin;

 end;
}


{ procedure TMonster_GiAnt.Tick;
  label a;
  var t,targ:tcritter;
  crange:integer;
  sear:TSearcher;
 begin;
   inherited Tick;
   sear:=TSearcher.create;t:=nil;_ASSERT(sear);
   if immhalt then exit;
   targ:=nil;
    crange:=3;//BUGBUG must be very big, bigger than see range
        t:=sear.Find_CritterbyID(EnemyId);
        if assigned(t) then
        a:if (t.id=EnemyId)then
        begin;
         if location.Geom_calcdest(xpos,ypos,zpos,t.xpos,t.ypos,t.zpos)<=crange then
          begin;
           crange:=trunc(location.Geom_calcdest(xpos,ypos,zpos,t.xpos,t.ypos,t.zpos));
           targ:=t;
          end;
        end;
        t:=sear.Find_CritterbyID(EnemyId);
        if assigned(t) then goto a;

   /// move to nearby visible target
    if assigned(targ) then
     if location.Geom_calcdest(xpos,ypos,zpos,targ.xpos,targ.ypos,targ.zpos)>1 then
      begin;
//       if location.Geom_checkLOS(xpos,ypos,zpos,targ.xpos,targ.ypos,targ.zpos) then
       begin;
        if targ.ypos<ypos then self.Action_MoveDelta(0,-1,zpos);
        if targ.ypos>ypos then self.Action_MoveDelta(0,1,zpos);
        if targ.xpos<xpos then self.Action_MoveDelta(-1,0,zpos);
        if targ.xpos>xpos then self.Action_MoveDelta(1,0,zpos);
       end;
      end
      else
      begin;
   //     (targ as TLiveCreature).WriteParam(modUser,prmCurrHP,;
      end;
      sear.free;
  end;
 }
begin;
AddSerialClass(TAI_ControllerOrdered);
AddSerialClass(TAI_OrderSurvive);
AddSerialClass(TAI_OrderAttack);
AddSerialClass(TAI_ControllerUser);
end.
