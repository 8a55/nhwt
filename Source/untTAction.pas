//- untTAction ----------------------------------------------------------------
// Базовые классы действий
// maniac

unit untTAction;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untSerialize,untConsole,untWorld,untActorBase,untActorBaseConst,untUtils;

 type

 TAction_GetFriendlyNameHelper=class(TAction)
 public
  function GetFriendlyName:string;override;
 end;

 TAction_Idle=class(TAction_GetFriendlyNameHelper)// Нифига не делание.
  procedure Tick;override;
 end;

 TAction_Walk=class(TAction_GetFriendlyNameHelper)
 private
//  chost:TCritter;
//  sear_host:TSearcher;
  checkcoords:boolean;
 public
  procedure Tick;override;
  procedure Doing(chost:TCritter);virtual;
  constructor Create;override;
 end;

 TAction_Attack=class(TAction_GetFriendlyNameHelper)
 end;

 TAction_FireArm_SingleShot=class(TAction_Attack)
 private
  chost:TCritter;
  sear_host:TSearcher;
 public
  procedure Tick;override;
  function GetFriendlyName:string;override;
  class function GetComment:string;override;
  constructor  Create;override;
//  procedure Doing;virtual;
 end;

 TAction_WalkForward=class(TAction_Walk)
  public
   procedure Doing(chost:TCritter);override;
   constructor Create;override;
 end;
// TAction_WalkForwardStand=class(TAction_WalkForward);
 //TAction_WalkForwardCrouch=class(TAction_WalkForward);  
 TAction_WalkBackward=class(TAction_Walk) public procedure Doing(chost:TCritter);override;end;
 TAction_WalkStrafeRight=class(TAction_Walk) public procedure Doing(chost:TCritter);override;end;
 TAction_WalkStrafeLeft=class(TAction_Walk) public procedure Doing(chost:TCritter);override;end;

 TAction_Rotate=class(TAction_Walk) public constructor Create;override;end;
 TAction_RotateRight=class(TAction_Rotate) public procedure Doing(chost:TCritter);override;end;
 TAction_RotateLeft=class(TAction_Rotate) public procedure Doing(chost:TCritter);override;end;

 TAction_StanceChange=class(TAction_Walk) public
  constructor Create;override;end;
 TAction_StandUp=class(TAction_StanceChange) public procedure Doing(chost:TCritter);override;end;
 TAction_StandDown=class(TAction_StanceChange) public procedure Doing(chost:TCritter);override;end;

 TAction_WalkToCoord=class(TAction_Walk)
 public
  walkdeltas:array of tPoint;
  walkto_x,walkto_y:real;
  currdist:integer;
  walkfrom_x,walkfrom_y:real;
  preserveglance:boolean;
  rotateonly:boolean;
  run:boolean;
  procedure SerializeData;override;
  procedure Doing(achost:TCritter);override;
 end;

 TAction_SleepForHealing=class(TAction_GetFriendlyNameHelper)
 public
  procedure Tick;override;
 end;

 TAction_Speak=class(TAction_GetFriendlyNameHelper)
 public
  target,text:string;
  procedure Tick;override;
 end;

 const //actions priority
 apMinimal=0;//минимально возможный приоритет
 apIdle=0;//ожидание
 apRecoil=10;//всякие воздействия типа отдачи от стрельбы из оружия и.т.д.
 apWounding=11;//внешние воздествия типа успешной расхитовки.

implementation
 uses sysutils,untLog,untTCharacter,untTItem,untMonster_GiAnt,untTInfluence,untSpeak,untTScreen,CastleColors,math;

 procedure TAction_Speak.Tick;
 var
  chost:TCritter;
  sound:TInfluence_Sound_Talk_Answer;
 begin;inherited Tick;
  dec(timelength);
  if timelength=0 then
  begin;
   chost:=location.Find_CritterbyID(idPlayer);
   sound:=pointer(chost.DoInfluence(TInfluence_Sound_Talk_Answer));
   sound.target:=target;
   sound.text:=text;
   sound.description:=text;
   sound.radius:=15;
  end;
  if timelength=-1 then Recoil;
 end;

 function TAction_FireArm_SingleShot.GetFriendlyName:string;
 begin;inherited GetFriendlyName;
  result:='Стреляю';
 end;

 class function TAction_FireArm_SingleShot.GetComment:string;
 begin;inherited GetComment;
  result:='Стрелять';
 end;

 constructor  TAction_FireArm_SingleShot.Create;
 begin;
  inherited Create;
  timelength:=2+round(random()*5);
 end;

 procedure TAction_FireArm_SingleShot.Tick;
 var
  nearenemy:TCritter;
  weapon:TWeapon_10mmPistol;
//  clip:TAmmo_10mmPistol;
  infl:TInfluence_projectile_bullet;
  trs1,trs2,trs3,maxheight,dist:real;
  tmpbullet:tPoint;
  chance:real;
  tohitroll,stancepenalty:real;
  comment:string;
  i:integer;
  label doexit;
 begin;
  inherited Tick;
  dec(timelength);
  sear_host:=TSearcher.create;
  if timelength=0 then
   begin;

   chost:=sear_host.Find_CritterbyID(host);sear_host.ResetSearch;
   if not(assigned(chost)) then begin;self.free;Log_write('Action_FireArm_SingleShot.Tick - host not found');
        sear_host.free;exit;end;
   if chost.InheritsFrom(TCreature) then
   begin;
    nearenemy:=(sear_host.Find_CritterById((chost as TCreature).target) as TLiveCreature);sear_host.ResetSearch;
    weapon:=(sear_host.Find_CritterByID(agent) as TWeapon_10mmPistol);
    if not(assigned(nearenemy))
     then _writeln(chost.name+': нет цели');
    { else
      if not(Location.Geom_checkLOS(chost.xpos,chost.ypos,chost.zpos,
        nearenemy.xpos,nearenemy.ypos,nearenemy.zpos,trs1,trs2,trs3,maxheight,false)) then
       begin;
        _writeln(chost.name+': не вижу цель!');goto doexit;
       end; }
    if (assigned(weapon))and(assigned(nearenemy)) then
    begin;
  //   if (weapon.magazine<>nil) then
      begin;//sear_host.ResetSearch;clip:=(sear_host.Find_CritterByID(weapon.clip) as TAmmo_10mmPistol);
       //  if (weapon.magazine.ammo>0)then
         begin;
              infl:=TInfluence_projectile_bullet.Create;
              if infl=location.Alloc_Critter(infl) then
              begin;
               infl.xpos:=chost.xpos;infl.ypos:=chost.ypos;infl.parent:=chost.id;
               infl.countdown:=1;infl.target:=(chost as TCharacter).target;
               infl.damage:=trunc(random(12));//6+trunc(random(6));               //if chost.InheritsFrom(TWeapon_LaserTagPistol) then infl.damage:=1;
               if chost.tags.GetTag(tagEnemyOf)=tagCNT_Player then infl.damage:=trunc(infl.damage*0.5);//0.5);
            /////   dec(weapon.magazine.ammo);

               dist:=Location.Geom_calcdist(chost.xpos,chost.ypos,chost.zpos,nearenemy.xpos,nearenemy.ypos,nearenemy.zpos);

               if nearenemy.InheritsFrom(TCharacter) then
                begin;
                  if (nearenemy as TCharacter).stance=stnLaydown then
                   stancepenalty:=stnHeight[(nearenemy as TCharacter).stance]*2;
                  if (nearenemy as TCharacter).stance=stnKneeling then
                   stancepenalty:=stnHeight[(nearenemy as TCharacter).stance];
                  if (nearenemy as TCharacter).stance=stnStandup then
                   stancepenalty:=stnHeight[(nearenemy as TCharacter).stance];
                end;

          {     if chost.tags.GetTag(tagEnemyOf)=tagCNT_Player then
               chance:=(5-dist)/5*stancepenalty
                else}
               chance:=(40-dist)/20*stancepenalty+1;

               tohitroll:=random();
               comment:=(':(дист:'+Format('%f',[dist])+' шанс:'+Format('%f',[chance])+
                   '/ бросок'+Format('%f',[tohitroll])+'* штраф.стойки: '+Format('%f',[stancepenalty]));
               if tohitroll<chance then begin;
                infl.Miss:=false;
                _writeln(nearenemy.name+' ранен '+nearenemy.parent+' на '+inttostr(infl.damage)+' очков жизни: '+comment);
               end
               else begin;infl.Miss:=true;
                _writeln(chost.name+': промах!'+comment);
               end;


               for i:=1 to round(Location.Geom_calcdist(chost.xpos,chost.ypos,chost.zpos,
                nearenemy.xpos,nearenemy.ypos,nearenemy.zpos))*5 do begin;
                  dist:=0.1;//Random();//4;
                  tmpbullet:=SolveLine(chost.xpos,chost.ypos,nearenemy.xpos,nearenemy.ypos,i/5);
                  _screen.drawSprite('.',tmpbullet.x,tmpbullet.y,lyGUI,grayrgb);
                end;
              end;
          end
        //  else _writeln(weapon.name+' только громко щелкнул. Стоит перезарядить?');
      end
    //  else _writeln(weapon.name+' только громко щелкнул. Стоит перезарядить?');
    end;
   end;
   doexit: sear_host.free;
   end;
  if timelength=-1 then Recoil;
 end;

 procedure TAction_Idle.Tick;
 begin;
  inherited Tick;
  dec(timelength);
 // if timelength=-1 then Recoil;
 end;

 procedure TAction_Walk.Doing;
 begin;
 //
 end;

 constructor  TAction_Rotate.Create;
 begin;
  inherited Create;
  timelength:=1;
 end;

 procedure TAction_RotateRight.Doing;
 begin;
  with chost as Tcreature do begin;
   glance:=glance+5;
   if glance=360 then glance:=0;
  end;
 end;

 procedure TAction_RotateLeft.Doing;
 begin;
  with chost as Tcreature do begin;
   if glance=0 then glance:=360;
   glance:=glance-5;
  end;
 end;

 procedure TAction_WalkBackward.Doing;
 var snd:TInfluence_Sound;step:real=0.1;
 begin;
   with chost as Tcreature do begin;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;
    if glance=cmpNord then Action_MoveDelta(0,step,0);
    if glance=cmpNordEast then Action_MoveDelta(-step,step,0);
    if glance=cmpNordWest then Action_MoveDelta(step,step,0);
    if glance=cmpSouth then Action_MoveDelta(0,-step,0);
    if glance=cmpSouthEast then Action_MoveDelta(-step,-step,0);
    if glance=cmpSouthWest then Action_MoveDelta(step,-step,0);
    if glance=cmpEast then Action_MoveDelta(-step,0,0);
    if glance=cmpWest then Action_MoveDelta(step,0,0);
   end;
 end;

 constructor TAction_WalkForward.Create;
 begin;
  inherited;
 // timelength:=10;
 end;

 procedure TAction_WalkForward.Doing;
 var snd:TInfluence_Sound;step:real=0.1;
 begin;
   inherited;
   with chost as Tcreature do begin;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;
    if glance=cmpNord then Action_MoveDelta(0,-step,0);
    if glance=cmpNordEast then Action_MoveDelta(step,-step,0);
    if glance=cmpNordWest then Action_MoveDelta(-step,-step,0);
    if glance=cmpSouth then Action_MoveDelta(0,step,0);
    if glance=cmpSouthEast then Action_MoveDelta(step,step,0);
    if glance=cmpSouthWest then Action_MoveDelta(-step,step,0);
    if glance=cmpEast then Action_MoveDelta(step,0,0);
    if glance=cmpWest then Action_MoveDelta(-step,0,0);
   end;
 end;


 procedure TAction_WalkStrafeRight.Doing;
 var snd:TInfluence_Sound;step:real=0.1;
 begin;
   inherited;
   with chost as Tcreature do begin;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;
    if glance=cmpNord then Action_MoveDelta(step,0,0);
    if glance=cmpNordEast then Action_MoveDelta(step,step,0);
    if glance=cmpNordWest then Action_MoveDelta(step,-step,0);
    if glance=cmpSouth then Action_MoveDelta(-step,0,0);
    if glance=cmpSouthEast then Action_MoveDelta(-step,step,0);
    if glance=cmpSouthWest then Action_MoveDelta(-step,-step,0);
    if glance=cmpEast then Action_MoveDelta(0,step,0);
    if glance=cmpWest then Action_MoveDelta(0,-step,0);
   end;
 end;

 procedure TAction_WalkStrafeLeft.Doing;
 var snd:TInfluence_Sound;step:real=0.1;
 begin;
   inherited;
   with chost as Tcreature do begin;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;
    if glance=cmpSouth then Action_MoveDelta(step,0,0);
    if glance=cmpSouthWest then Action_MoveDelta(step,step,0);
    if glance=cmpSouthEast then Action_MoveDelta(step,-step,0);
    if glance=cmpNord then Action_MoveDelta(-step,0,0);
    if glance=cmpNordWest then Action_MoveDelta(-step,step,0);
    if glance=cmpNordEast then Action_MoveDelta(-step,-step,0);
    if glance=cmpWest then Action_MoveDelta(0,step,0);
    if glance=cmpEast then Action_MoveDelta(0,-step,0);
   end;
 end;

 procedure TAction_StandUp.Doing;
 var snd:TInfluence_Sound;step:real=0.1;
 begin;
   inherited;
   with chost as Tcreature do begin;
    checkcoords:=false;
    if timelength=0 then exit;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;
    inc(stance);if stance>stnMax then stance:=stnMax;
    //zpos:=stnHeight[stance];
  //  timelength:=10;//BUGBUG
   end;
 end;

 procedure TAction_StandDown.Doing;
 var snd:TInfluence_Sound;step:real=0.1;
 begin;
   inherited;
   with chost as Tcreature do begin;
    checkcoords:=false;
    if timelength=0 then exit;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;
    dec(stance);if stance<stnMin then stance:=stnMin;
    //zpos:=stnHeight[stance];
//    timelength:=10;//BUGBUG
   end;
 end;

 procedure TAction_SleepForHealing.Tick;
 var
  chost:TCritter;
  sear_host:TSearcher;
 begin;
  inherited Tick;
  dec(timelength);
{   sear_host:=TSearcher.create;
   chost:=sear_host.Find_CritterbyID(host);
   if (chost as TCharacter).CurrHP>=(chost as TCharacter).BaseHP then
   begin;
    (chost as TCharacter).currAction:=nil;
    self.free;
   end else inc((chost as TCharacter).CurrHP);
   sear_host.free;}
 end;

 constructor TAction_StanceChange.Create;
 begin;
  inherited Create;
  timelength:=2;
 end;

 constructor TAction_Walk.Create;
 begin;
  inherited Create;
  timelength:=10;
 end;

 function TAction_GetFriendlyNameHelper.GetFriendlyName:string;
 begin;
  inherited GetFriendlyName;
  if ClassNameIs(TAction_WalkForward.ClassName) then result:='Идти вперед';
  if ClassNameIs(TAction_WalkBackward.ClassName) then result:='Идти назад';

  if ClassNameIs(TAction_RotateRight.ClassName) then result:='Поворот вправо';
  if ClassNameIs(TAction_RotateLeft.ClassName) then result:='Поворот влево';

  if ClassNameIs(TAction_WalkStrafeLeft.ClassName) then result:='Шаг влево';
  if ClassNameIs(TAction_WalkStrafeRight.ClassName) then result:='Шаг вправо';

  if ClassNameIs(TAction_Idle.ClassName) then result:='Ожидание';

  if ClassNameIs(TAction_FireArm_SingleShot.ClassName) then result:='Стреляю!';

  if ClassNameIs(TAction_SleepForHealing.ClassName) then result:='Сплю';

  if ClassNameIs(TAction_WalkToCoord.ClassName) then result:='Иду';

  if ClassNameIs(TAction_Speak.ClassName) then result:='Говорю';

  if ClassNameIs(TAction_StandDown.ClassName) then result:='На землю';

  if ClassNameIs(TAction_StandUp.ClassName) then result:='Поднимаюсь';

  if ClassNameIs(TAction_CreatureDrop.ClassName) then result:='Бросаю';

  if ClassNameIs(TAction_CreatureEquip.ClassName) then result:='Манипулирую снаряжением';

  if ClassNameIs(TAction_CreatureUnEquip.ClassName) then result:='Снимаю снаряжение';

  if ClassNameIs(TAction_CreatureLiftItem.ClassName) then result:='Поднимаю предмет';
 end;

 procedure TAction_Walk.Tick;
 var
  chost:TCritter;
  sear_host:TSearcher;
  chkx,chky,chkz:real;
 begin;
  inherited Tick;
  dec(timelength);
  if timelength>=0 then
   begin;
   sear_host:=TSearcher.create;
   chost:=sear_host.Find_CritterbyID(host);
   if not(assigned(chost)) then begin;self.free;exit;Log_write('OOPPSS');end;
   if chost.InheritsFrom(TCreature) then
    begin;
     chkx:=chost.xpos;chky:=chost.ypos;chkz:=chost.zpos;
     Doing(chost);
     if (chkx=chost.xpos)and(chky=chost.ypos)and(chkz=chost.zpos)and(checkcoords)then timelength:=0;
    end;
   sear_host.free;
//   self.priority:=apRecoil;
   end;
  if timelength=0 then //return time
   begin;
   sear_host:=TSearcher.create;
   chost:=sear_host.Find_CritterbyID(host);
   sear_host.free;
   (chost as TCharacter).currAction:=nil;//надо написать макрос освобождения слота действий.
   self.free;
   end;
 end;

 procedure TAction_WalkToCoord.Doing(achost:TCritter);
 var snd:TInfluence_Sound;step:real=0.1;
  newcoord:tPoint;
  dist,oldx,oldy,angle,aneg,apos:real;
  i,newtilephys,blockcriter:integer;
  divider:real;
  begin;
   inherited;
   with achost as Tcreature do begin;
    snd:=TInfluence_Sound(DoInfluence(TInfluence_Sound));
    snd.countdown:=1;
    snd.extrainfo:='step';
    snd.radius:=15;

    angle:=SolveAngle(achost.xpos,achost.ypos,walkto_x,walkto_y);
    if (glance<>angle)and(not preserveglance) then //BUGBUG
     begin;
      glance:=glance+(angle-glance)/2;
{      aneg:=360-angle-glance;
      apos:=angle-glance;
      if abs(aneg)<abs(apos) then glance:=glance-5 else glance:=glance+5;}
      if abs(glance-angle)<10 then
       begin;
        glance:=angle;
        if rotateonly then begin;timelength:=0;exit;end;
       end;
     end;

    dist:=Location.Geom_calcdist(walkfrom_x,walkfrom_y,0,walkto_x,walkto_y,0);

    if run then
     divider:=3
    else
     divider:=10;

    if Length(walkdeltas)=0 then begin;
     SetLength(walkdeltas,round(dist*divider)+1);
     walkdeltas[0].x:=xpos;
     walkdeltas[0].y:=ypos;
     for i:=1 to round(dist*divider) do begin
      newcoord:=SolveLine(walkfrom_x,walkfrom_y,walkto_x,walkto_y,i/divider);
      walkdeltas[i].x:=newcoord.x;
      walkdeltas[i].y:=newcoord.y;
     end;
     //newcoord:=SolveLine(walkfrom_x,walkfrom_y,walkto_x,walkto_y,currdist);
     currdist:=1;
    end;

    oldx:=achost.xpos;oldy:=achost.ypos;
    if (walkdeltas[currdist].x<>0)and(walkdeltas[currdist].y<>0)and(currdist/divider<=dist) then
     begin;
       newtilephys:=location.GetPhysics(walkdeltas[currdist].x,walkdeltas[currdist].y,1,blockcriter,achost.index);
       if (newtilephys<>stSolid)and(newtilephys<>stOpaque)and
         IsInRange(achost.xpos-1,walkdeltas[currdist].x,achost.xpos+1)and
         IsInRange(achost.ypos-1,walkdeltas[currdist].y,achost.ypos+1)
        then begin;
          achost.xpos:=walkdeltas[currdist].x;
          achost.ypos:=walkdeltas[currdist].y;
        end;
     end;
    if( (oldx=achost.xpos)and(oldy=achost.xpos))
     or( (achost.xpos=walkto_x) and (achost.xpos=walkto_y) )
     then begin;
     timelength:=0;
     _writeln(achost.name+': move interupted');
    end
    else begin;
     timelength:=1;inc(currdist);
    end;
    if currdist/divider>=dist then begin;
     timelength:=0;
     SetLength(walkdeltas,0);
    end;
   end;
 end;

 procedure TAction_WalkToCoord.SerializeData;
 begin;
  inherited;
  SerializeFieldFl('walkto_x',walkto_x);
  SerializeFieldFl('walkto_y',walkto_y);
  SerializeFieldI('currdist',currdist);
  preserveglance:=SerializeFieldB('preserveglance',preserveglance);
  rotateonly:=SerializeFieldB('rotateonly',rotateonly);
  run:=SerializeFieldB('run',run);
 end;


begin;
AddSerialClass(TAction_SleepForHealing);
AddSerialClass(TAction_Walk);
AddSerialClass(TAction_Idle);
AddSerialClass(TAction_FireArm_SingleShot);
AddSerialClass(TAction_WalkForward);
AddSerialClass(TAction_RotateRight);
AddSerialClass(TAction_RotateLeft);
AddSerialClass(TAction_WalkBackward);
AddSerialClass(TAction_WalkStrafeLeft);
AddSerialClass(TAction_WalkStrafeRight);
AddSerialClass(TAction_WalkToCoord);
AddSerialClass(TAction_Speak);
AddSerialClass(TAction_StandDown);
AddSerialClass(TAction_StandUp);


end.


