//- untTInfluence ----------------------------------------------------------------
// Базовые классы воздействий.
// maniac

unit untTInfluence;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
 uses untActorBase,untActorBaseConst;

 type
  TInfluence_Track=class(TInfluence)
   procedure Tick;override;
   constructor Create;override;
  end;

  TInfluence_Sound=class(TInfluence)// типа звук
   public
   radius:integer;
   extrainfo:string;
//   lifetime:integer;
   procedure Tick;override;
  end;

  TInfluence_Etheral=class(TInfluence)// типа непонятно какая информация
  end;

  TInfluence_PhysicalDamage=class(TInfluence)
  end;

  TInfluence_projectile_bullet=class(TInfluence_PhysicalDamage)//типа информация о том как кто-то попал.
  public
   Miss:boolean;
   damage:integer;
   procedure Tick;override;
   procedure SerializeData;override;
  end;

  TInfluence_Visual=class(TInfluence)// типа визуальная информация
   public
   extrainfo:string;
   procedure Tick;override;
   procedure Render;override;   
  end;

implementation
uses untWorld,untConsole,untSerialize,sysutils,untAI;

procedure TInfluence_Visual.Render;
begin;
end;

procedure TInfluence_Visual.Tick;
 var i:integer;host:TCritter;
  localDEBUG_LOS,tmpBool:boolean;
  targetheight,maxheight,currheight,trs1,trs2,trs3:real;
 begin;
  //localDEBUG_LOS:=debug_los;
  // if Self.parent<>idPlayer then DEBUG_LOS:=false;
   host:=location.Find_CritterbyID(Self.parent);
   if assigned(host) then begin;self.xpos:=host.xpos;self.ypos:=host.ypos;self.zpos:=host.zpos;end;
   for i:=0 to maxcritters do
    if assigned(location.Critters[i]) then
     if not(location.Critters[i].inheritsfrom(TInfluence)) then//Воздействиям не сообщаем.
      if location.Critters[i].inheritsfrom(TCreature) then
      begin;//Просто сообщение для всех обьектов
        //if
        //debug_los:=false;
        //if location.Critters[i].id=idPlayer then debug_los:=true;

       // tmpBool:=location.Geom_checkLOS(xpos,ypos,zpos,location.Critters[i].xpos,location.Critters[i].ypos,location.Critters[i].zpos
        //  ,trs1,trs2,trs3,maxheight,false);
         tmpBool:=false;
        // debug_TLosEvaluator_dumplosarray:=true;
         tmpBool:=((location.Critters[i] as Tcreature).AI_controller as TAI_ControllerUser).LosEvaluator.getVisible(xpos,ypos);
        // debug_TLosEvaluator_dumplosarray:=false;
         maxheight:=((location.Critters[i] as Tcreature).AI_controller as TAI_ControllerUser).LosEvaluator.maxheight(xpos,ypos);
//        if location.Critters[i].id=idPlayer then
        { begin;
          _writeln('TInfluence_Visual.Tick('+id+') parent: '+Self.parent
           +' x '+floattostr(xpos)+' y '+floattostr(ypos)+' z '+floattostr(zpos)
           +'->'+location.Critters[i].id
           +' x '+floattostr(location.Critters[i].xpos)+' y '+floattostr(location.Critters[i].ypos)+' z '+floattostr(location.Critters[i].zpos)
           +' '+BoolToStr(tmpbool,true));
         end;}
         // and
 //        if (Location.Geom_calcdist(xpos,ypos,zpos,location.Critters[i].xpos,location.Critters[i].ypos,location.Critters[i].zpos)<5)
 //         then
   //     if (zpos>=maxheight)and(location.Critters[i].zpos>=maxheight) then
       targetheight:=stnHeight[((location.Critters[i] as Tcreature)).stance];
       currheight:=0;
       if assigned(host) then currheight:=stnHeight[(host as TCreature).stance];
       if tmpBool and (currheight>=maxheight)and (targetheight>=maxheight) then begin;
          location.Critters[i].OnInfluence_Visual(self);

{           if assigned(t) then
            (t as TCreature).AI_controller.AddPercepted(location.time
             ,location.Critters[i].xpos,location.Critters[i].ypos,location.Critters[i].zpos
             ,location.Critters[i].id,location.Critters[i].id,snsVisual);}
         // _write('view '+location.Critters[i].id+' for '+Self.parent);
          end
      end;
  //debug_los:=localDEBUG_LOS;
  samokill;
 end;

 procedure TInfluence_projectile_bullet.SerializeData;
 begin
  Miss:=SerializeFieldB('Miss',Miss);
  SerializeFieldI('damage',damage)
 end;


 procedure TInfluence_projectile_bullet.Tick;
 var aTarget:TCritter;Sear:TSearcher;
 begin;
  Sear:=TSearcher.Create;
  aTarget:=Sear.Find_CritterbyID(target);
  if assigned(aTarget) and not Miss then aTarget.OnInfluence_projectile_bullet(self);//    хухры
  self.SamoKill;
  Sear.free;
 end;

 constructor TInfluence_Track.Create;
 begin;
  inherited Create;
  //
 end;

  procedure TInfluence_Track.Tick;
  var i,j:integer;t:TCritter;
  sear:TSearcher;
  begin;_writeln('!!!tracking');sear:=TSearcher.Create;
{   for i:=xpos-1 to xpos+1 do
     for j:=ypos-1 to ypos+1 do
      begin;
      t:=sear.Find_CritterByPos(i,j,0);
      if (t<>nil)then
      if (not(t.inheritsfrom(TInfluence)))then
      begin;
      //t.OnInfluence_Track;
       _writeln(t.name);
      end;
     end;    }
   samokill;
   _writeln('!!!tracking end');
   sear.free;
  end;

  procedure TInfluence_Sound.Tick;
  var i,j,k:integer;t:TCritter;
  sear:TSearcher;
  begin;
   for i:=0 to maxcritters do
    if assigned(location.Critters[i]) then
     if not(location.Critters[i].inheritsfrom(TInfluence)) then
      if location.Geom_calcdest(location.Critters[i].xpos,location.Critters[i].ypos,location.Critters[i].zpos
      ,xpos,ypos,zpos)<self.radius then location.Critters[i].OnInfluence_Sound(self);
   samokill;
  end;

begin;
 AddSerialClass(TInfluence_Track);
 AddSerialClass(TInfluence_Sound);
 AddSerialClass(TInfluence_Etheral);
 AddSerialClass(TInfluence_projectile_bullet);
 AddSerialClass(TInfluence_Visual);
end.
