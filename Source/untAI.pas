//- untAI ----------------------------------------------------------------
// ИИ
// 8а55
unit untAI;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untActorBaseConst,untSerialize,untUtils;
 type

 TLosArrayElement=record
   Visible:boolean;
   MaxHeight:real;
  end;

 TLosEvaluator=class(TNamedObject)
 private
  LosArray:array of array of TLosArrayElement;
 public
  parent:string;
  pov_x,pov_y,pov_z,d,glance,fov:real;
  constructor Create;override;
  procedure SerializeData;override;
  procedure SetPointofView(aX,aY,aZ:real);virtual;
  procedure SetFov(aGlance,aFov:real);virtual;
  function getVisible(aX,aY:real):boolean;
  function maxheight(aX,aY:real):real;
  procedure Calculate;virtual;
 end;

 TAI_Order = class(TSerialObject)
 public
  Aop:integer;
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
  LosEvaluator:TLosEvaluator;{ TODO -cTODO : необоходимо переместить в предок аи контролеров }
  order_moveto_x,order_moveto_y:real;
  AggressionLevel:integer;
  oldhp:integer;
  constructor Create;override;
  destructor Destroy;override;
  procedure SerializeData;override;
  procedure AI_Tick;override;
  procedure AddPercepted(aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer);virtual;overload;
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
uses untTScreen,untConsole,untTAction,untTItem,untMonster_GiAnt,
  untWorld,untGame,untTCharacter,sysutils,LazUTF8,math;

constructor TLosEvaluator.Create;
var ix,iy:integer;
begin;
 inherited;
 SetLength(LosArray,maxLocationXSize+1,maxLocationYSize+1);
 for ix:=0 to maxLocationXSize do
   for iy:=0 to maxLocationYSize do begin;
     LosArray[ix,iy].visible:=false;
     LosArray[ix,iy].MaxHeight:=1;
    end;
 fov:=45;
 glance:=cmpNord;
end;

procedure TLosEvaluator.SetPointofView(aX,aY,aZ:real);
begin;
 pov_x:=ax;pov_y:=ay;pov_z:=az;
end;

procedure TLosEvaluator.SetFov(aGlance,aFov:real);
begin;
 fov:=aFov;
 glance:=aGlance;
end;

function TLosEvaluator.maxheight(aX,aY:real):real;
begin;
 result:=LosArray[round(aX),round(aY)].maxHeight;
end;

function TLosEvaluator.getVisible(aX,aY:real):boolean;
var ix,iy:integer;
 dbg:text;
 tmpstr,tmpstr2:string;
 host:tcreature;
begin;
 //-а-а-а-а-а-а-а добавить наследника, автоматически привязанного к хосту по данным а-а-а--а-а-а
 {if parent<>'' then begin;
    host:=(Location.Find_CritterbyID(parent) as TCreature);
    if IsAssignedAndInherited(host,Tcreature) then
     begin;
      if not(
        (host.xpos=pov_x)and(host.ypos=pov_y)and(host.zpos=pov_z)
        and(glance=host.glance)
       ) then begin
          SetPointofView(host.xpos,host.ypos,host.zpos);
          SetFov(host.glance,fov);
          Calculate;
         end;
     end;
   end; }
 inc(debugcounter_TLosEvaluator_getVisible);
 result:=LosArray[round(aX),round(aY)].visible;
 if debug_TLosEvaluator_dumplosarray then begin;
  assign(dbg,'.'+DirectorySeparator+'Tmp'+DirectorySeparator+'debugcounter_TLosEvaluator_getVisible_'
  +floattostr(pov_x)+'_'+floattostr(pov_y)+'_'+inttostr(debugcounter_TLosEvaluator_getVisible)
  );
  rewrite(dbg);
  writeln(dbg,inttostr(debugcounter_TLosEvaluator_getVisible));
  writeln(dbg,'TInfluence_Visual.Tick('+id+') '+Self.parent
            +' pov_x '+floattostr(pov_x)+' pov_y '+floattostr(pov_y)+' pov_z '+floattostr(pov_z)
//            +'->'+location.Critters[i].id
            +' ax '+floattostr(ax)+' ay '+floattostr(ay)//+' z '+floattostr(location.Critters[i].zpos)
            +' fov '+floattostr(fov)+' glance '+floattostr(glance)
            );
  for iy:=0 to maxLocationYSize do
    begin;
     tmpstr:='';
     for ix:=0 to maxLocationXSize do
      begin;
       tmpstr2:='?';
       if LosArray[ix,iy].visible then
        tmpstr2:=' '
       else
        tmpstr2:='#';
       if (ix=round(pov_x))and(iy=round(pov_y)) then tmpstr2:='@';
       if (ix=round(aX))and(iy=round(aY)) then tmpstr2:='*';
       tmpstr:=tmpstr+tmpstr2;
      end;
     writeln(dbg,tmpstr);
    end;
  writeln(dbg,'');
  close(dbg);
 end;
end;

procedure TLosEvaluator.Calculate;
 procedure DrLOSLIne(x1,y1,d,x2,y2:real);
//  Function SolveLine(X1,Y1,X2,Y2,N: real): Point;
 var xdelta,ydelta,xstep,ystep,dist,dir,currstep,resx,resy,currpoint_x,currpoint_y:double;
 cx,cy,tmp1,tmp2:integer;
 i:integer;
 angle,glance2,fov2,currheight:real;
 begin;
     fov2:=30;
     angle:=(SolveAngle(x1,y1,x2,y2));
   {  if DegNormalize(glance+fov)<DegNormalize(glance-fov) then begin;
       fov2:=-fov2;
      end; }

     //if ((angle>DegNormalize(glance+0.00001-fov2))and(angle<DegNormalize(glance+0.00001+fov2)))
     //then
      begin
               xdelta:=abs(x1-x2);
               ydelta:=abs(y1-y2);
               //dist:=Location.Geom_calcdist(x1,y1,0,x2,y2,0);
               dist:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
               xstep:=xdelta/dist;if x2<x1 then xstep:=-xstep;
               ystep:=ydelta/dist;if y2<y1 then ystep:=-ystep;
               resx:=x1;
               resy:=y1;
               currheight:=0;
               for i:=0 to round(dist) do begin;
              //   result.x:=result.x+xstep*n; result.y:=result.y+ystep*n;
                currpoint_x:=resx+xstep*i;
                currpoint_y:=resy+ystep*i;
                cx:=round(currpoint_x);
                cy:=round(currpoint_y);
                if (cx<0)or(cx>maxLocationXSize)or(cy<0)or(cy>maxLocationYSize) then exit;
                if //not LosArray[round(currpoint_x),round(currpoint_y)].visible
                 location.getTile(cx,cy,1)=0
                 then begin;
                  LosArray[cx,cy].visible:=true;
                  LosArray[cx,cy].MaxHeight:=currheight;
                 // _screen.writeXYex('.',cx,cy,0,rgbGUI_Elements);
                 end
                 else //exit;
                  begin;
                   currheight:=Location.getgroundEX(cx,cy,1).height;
                   LosArray[cx,cy].visible:=true;
                   if currheight> d then
                    exit;
                  end;
                {  begin;
                   if //location.GetPhysics(cx,cy,1,tmp1,tmp2)=stOpaque
                    location.getgroundEX(cx,cy,1).physical=stOpaque
                   then begin;
                      LosArray[cx,cy].visible:=true;
                     end
                   else begin;
                     LosArray[cx,cy].visible:=true;
                     exit;
                    end
                  end   }
               end;
      end
    { else
      begin;
      _writeln('glance- '+FloatToStr(DegNormalize(glance+0.00001-45)));
      _writeln('glance+ '+FloatToStr(DegNormalize(glance+0.00001+45)));
      _writeln(FloatToStr(angle));
      end;}

 end;

 var tmpx,tmpy,tmpz,maxheight,fcangle:real;
  ix,iy,i:integer;
  fcpoint:tpoint;
 begin

  debug_los:=false;
  for ix:=0 to maxLocationXSize do
   for iy:=0 to maxLocationYSize do begin;
     LosArray[ix,iy].visible:=false;
     LosArray[ix,iy].MaxHeight:=1;
    end;

  fcangle:=0;
  while fcangle<fov do
   begin;
    fcpoint:=SolveAngledLine(pov_x,pov_y,glance-fcangle,1000);
    DrLOSLIne(pov_x,pov_y,d,fcpoint.x,fcpoint.y);
    fcpoint:=SolveAngledLine(pov_x,pov_y,glance+fcangle,1000);
    DrLOSLIne(pov_x,pov_y,d,fcpoint.x,fcpoint.y);
    fcangle:=fcangle+0.25
   end;

  //post-processing https://sites.google.com/site/jicenospam/visibilitydetermination
  for ix:=0 to maxLocationXSize do
   for iy:=0 to maxLocationYSize do
    begin;    //EnsureRange();
//     if LosArray[ix,iy].visible:=false;
    end;

{  tmpx:=0;tmpy:=0;
  while tmpx<maxLocationXSize do
   begin;
    DrLOSLIne(pov_x,pov_y,tmpx,0);
    DrLOSLIne(pov_x,pov_y,tmpx,maxLocationYSize);
    tmpx:=tmpx+1;
   end;
  while tmpY<maxLocationYSize do
   begin;
    DrLOSLIne(pov_x,pov_y,0,tmpy);
    DrLOSLIne(pov_x,pov_y,maxLocationXSize,tmpy);
    tmpy:=tmpy+1;
   end;}



//  Location.Geom_checkLOS(bx,by,bz,ex,ey,ez,tmpx,tmpy,tmpz,maxheight,true);
//   dist:=Geom_calcdist(bx,by,0,ex,ey,0);maxheight:=0;
     //currpoint:=SolveLine(bx,by,ex,ey,i);

{     debug_los:=false;
     Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,cmouse_x,cmouse_y,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);
     tmpx:=0;tmpy:=0;
     debug_los:=false;
     _screen.paintBlock(0,0,maxXscreen,maxYscreen,0,rgbRender_UnvisibleTile);
      while tmpx<maxXscreen do
       begin;
        Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,
          tmpx,0,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);
    //    _screen.paintBlock(round(moveto_x),round(moveto_y),1,1,0,GreenRGB);
        Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,
          tmpx,maxYscreen,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);
//        _screen.paintBlock(round(moveto_x),round(moveto_y),1,1,0,GreenRGB);
        tmpx:=tmpx+1;
       end;
      while tmpy<maxyscreen do
       begin;
        Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,
          0,tmpy,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);
//        _screen.paintBlock(round(moveto_x),round(moveto_y),1,1,0,GreenRGB);
        Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,
          maxXscreen,tmpy,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);
//        _screen.paintBlock(round(moveto_x),round(moveto_y),1,1,0,GreenRGB);
        tmpy:=tmpy+1;
       end;  }
 end;

procedure TLosEvaluator.SerializeData;
var ix,iy:integer;
 tmpstr:string;
begin;
 inherited;
 if serialMode=smSave then begin;
   for iy:=0 to maxLocationYSize do
     begin;
      tmpstr:='';
      for ix:=0 to maxLocationXSize do
       begin;
   //     LosArray[ix,iy].visible:=SerializeFieldB('visible_'+inttostr(ix)+'_'+inttostr(iy),LosArray[ix,iy].visible);
        if LosArray[ix,iy].visible then
         tmpstr:=tmpstr+' '
        else
         tmpstr:=tmpstr+'#';
       end;
      SerializeFieldS('visible_'+inttostr(iy),tmpstr);
     end;
  end;
 if serialMode=smLoad then
   for iy:=0 to maxLocationYSize do
     begin;
      SerializeFieldS('visible_'+inttostr(iy),tmpstr);
      for ix:=1 to maxLocationXSize do
       begin;
        if Copy(tmpstr,ix,1)='#'
         then LosArray[ix-1,iy].visible:=false
         else LosArray[ix-1,iy].visible:=true;
       end;
     end;
 if (serialMode<>smLoad)and(serialMode<>smSave) then Begin;
   _writeln('!TCritter.SerializeData -unknown serialization operation');
   Abort;
  end;
end;

//-----------------------------------------------------------------------------
procedure TAI_ControllerUser.AddPercepted(aTimeWhen:longword;axpos,aypos,azpos:real;aid,ainfl_parent:string;asense:integer);
begin;
 inherited;
end;
//-----------------------------------------------------------------------------
constructor TAI_ControllerUser.Create;
 begin;
  inherited;
  LosEvaluator:=TLosEvaluator.create;
 end;
//-----------------------------------------------------------------------------
destructor TAI_ControllerUser.Destroy;
 begin;
  inherited;
  LosEvaluator.Destroy;
 end;
//-----------------------------------------------------------------------------
procedure TAI_ControllerUser.SerializeData;
var player:tcritter;
 begin;
  inherited;
  SerializeFieldI('AggressionLevel',AggressionLevel);
  SerializeFieldI('oldhp',oldhp);
  player:=Location.Find_CritterbyID(hostid);
  LosEvaluator:=pointer(SerializeFieldO('LosEvaluator',LosEvaluator));
  LosEvaluator.parent:=hostid;
  if oldhp=0 then
   if assigned(player) then oldhp:=
    (player as TCreature).Sklmtrx_GetParamRes(prmCurrHP);
 end;
//-----------------------------------------------------------------------------
procedure TAI_ControllerUser.AI_Tick;
 var i:integer;
  ptarget,host,hand,player:tcritter;sear2:TSearcher;
  ihand:titem;
  cAction:Taction;
  fck:boolean;
  myfaction,ptarget_tag_enemyof:string;

 procedure Fire;
 begin;

  cAction:=(player as TCharacter).DoAction(ihand.GetCurrAction);
 end;

 begin;fck:=false;
  inherited;
//  _writeln(hostid+'controller aitick');
   player:=Location.Find_CritterbyID(hostid);
   if not assigned(player)  then exit;//BUGBUG
   LosEvaluator.SetPointofView(player.xpos,player.ypos,player.zpos);
   LosEvaluator.parent:=hostid;//BUGBUG
   LosEvaluator.d:=stnHeight[(player as TCreature).stance];
   LosEvaluator.SetFov((player as TCreature).glance,45);
   if IsAssignedAndInherited((player as TCreature).currAction,TAction_WalkToCoord) then
    if ((player as TCreature).currAction as TAction_WalkToCoord).run then
     LosEvaluator.SetFov((player as TCreature).glance,15);
   LosEvaluator.Calculate;
   myfaction:=player.tags.GetTag(tagMyFaction);
   //if idPLayer<>hostid then
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
	                   //cAction:=(player as TCharacter).DoAction(ihand.GetCurrAction);
                           Fire;
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
//-----------------------------------------------------------------------------
procedure TAI_ControllerOrdered.AI_Tick;
 var currOrd,currAop:integer;
 begin;
  for currAop:=Aop_Max downto Aop_min do
   for currOrd:=0 to high(orders) do
    if assigned(orders[currOrd]) then
     if orders[currOrd].aop=currAop then
      begin;
     //  orders[currOrd].AI_Tick;
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
 AddSerialClass(TLosEvaluator);
end.
