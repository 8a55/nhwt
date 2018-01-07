//- untGame ----------------------------------------------------------------
// Обьект игры.
// maniac

unit untGame;

{$mode objfpc}{$H+}

{$CODEPAGE UTF8}

 {$TYPEINFO ON}
interface
uses untGUI,untActorBase,untActorBaseConst,untSerialize,Classes;

var
 gui_charflash_defaultvalue:integer=30;

type
 TGameClass=class of TGameAbstract;

 TGameConfigHelper=class(TSerialObject)
 public
  procedure SerializeData;override;
 end;

 TGameAbstract=class
 public
  initialized:boolean;
  strGameID:string;
  strStartMap:string;
  intEngineBuild:integer;
  config:TGameConfigHelper;
  constructor Create;virtual;
  destructor Destroy;virtual;
  procedure MainLoop;virtual;
  procedure SwitchTo(anewgameclass:TGameClass);virtual;
 end;

 TGame=class(TGameAbstract)
  private
   player:TCritter;
  public
   MapToLoad:string;
   cntGameFramesRendered:LongWord;
   paused:boolean;
   paused_lastnewperceptedtime:dword;
   gui_charflash:integer;
   gui_nxtAggrLvl:integer;
   gui_AggrMenuOpen:boolean;
   Menu_Game:TGUI_menu;
   Menu_Chat:TGUI_menu;
   Menu_Help:TGUI_menu;
   modalwindow_open,inventory_open,targetselect_open,chat_open,help_open,debugconsole_open:boolean;
   modalwindow_text:string;
   debugconsole_currcommand:string;
   debugconsole_help:Tstringlist;
   procedure MainLoop;override;
   procedure DrawGroupsList;
   procedure DrawGUI;
   procedure ReactKeys;
   procedure ReactMouse;
   function  GetHandItem(aCitter:tcritter):tcritter;
   procedure MainLoop_inventory;
   procedure MainLoop_modalwindow;
   procedure MainLoop_targetselect;
   procedure MainLoop_chat;
   procedure MainLoop_help;
   procedure MainLoop_debugconsole;
   constructor Create;override;
   destructor Destroy;override;
 end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

implementation
uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  //LCLIntf, LCLType, LMessages,
{$ENDIF}
 // controls,
 untConsole,untWorld,sysutils,untGameMenu//,Classes,graphics
 ,untUtils,untMonster_GiAnt,untLog,untTCharacter,untTAction,
 untTInfluence,untSpeak,math,untTScreen,untTItem,
 CastleWindow,CastleKeysMouse,CastleColors,strutils,FileUtil,untScreenSFX,
 untAI,untMaps,LazUTF8,CastleControls,fileinfo,untTLandscape;

//type
//t2=record a,b:string;end;
var comment:string;test1:boolean;
cAction:TAction;//BUG BUG
//actSpeak:TAction_Speak;
loopnum:integer;
//t1:array of t2;
 rltrsh1,rltrsh2,rltrsh3,rltrsh4,rltrsh5,rltrsh6,rltrsh:real;
 //-----------------------------------------------------------------------------
procedure TGameConfigHelper.SerializeData;
var size:real;
begin;
 inherited;
 SerializeFieldS('GameID',Game.strGameID);
 If SerialMode=smSave then
  SerializeFieldI('EngineBuild',Game.intEngineBuild);
 debug_console:=SerializeFieldB('debug_console',debug_console);
 SerializeFieldFL('UIFont.Size',FontSize);
 SerializeFieldS('StartMap',Game.strStartMap);
end;
//-----------------------------------------------------------------------------
procedure TGameAbstract.SwitchTo(anewgameclass:TGameClass);begin;
  Game.destroy;
  newGame:=anewgameclass.Create;
  game:=newgame;
  newgame:=nil;self:=nil;
  Log_write('+ switching game class.');exit;
end;
//-----------------------------------------------------------------------------
destructor TGameAbstract.Destroy;
begin;
 config.Save('./Config');
 config.destroy;
end;
//-----------------------------------------------------------------------------
constructor TGameAbstract.Create;
 begin;
  config:=TGameConfigHelper.create;
 end;
//-----------------------------------------------------------------------------
procedure TGameAbstract.MainLoop;
 var vers:TProgramVersion;
  cfg:text;
 begin;
 inherited;
 if not initialized then begin;
  intEngineBuild:=-1;
  if assigned(FileVerInfo) then begin;
    fileinfo.GetProgramVersion(vers);
    intEngineBuild:=(vers.Build);
   end;
  //FileVerInfo.VersionStrings.Values['Build']);//FileVersion
  if not FileExists('./Config') then begin;
    assign(cfg,'./Config');
    rewrite(cfg);
    writeln(cfg,'#template');
    writeln(cfg,'./Data/ConfigDefault');
    CloseFile(cfg);
   end;
  config.Load('./Config');
  initialized:=true;
 end;
end;
//-----------------------------------------------------------------------------
destructor TGame.Destroy;
begin;
 player:=nil;
 location.EmptyActors;
 location.destroy;
 Menu_game.free;
 Menu_Chat.free;
 Menu_Help.free;
 debugconsole_help.destroy;
 inherited;
end;
//-----------------------------------------------------------------------------
constructor TGame.Create;
 begin;
  inherited;
  location:=TLocation.create;
  Menu_game:=TGUI_menu.create;
  Menu_Chat:=TGUI_menu.create;
  Menu_Help:=TGUI_menu.create;
  debugconsole_help:=Tstringlist.create;
{  untConsole.frmCon.caption:='location[-] actors[-]';
  location.LoadLocation('.\Save\Location');
  untConsole.frmCon.caption:='location[+] actors[-]';}
//  untConsole.frmCon.caption:='location[+] actors[+]';
//  untConsole.frmCon.caption:='NW deep gamma';
  loopnum:=0;//debug feature
 end;
//-----------------------------------------------------------------------------
procedure TGame.MainLoop_chat;
var iplayer:TCharacter;sound:TAction;
begin;
 if (lastkey=k_C) or (lastkey=k_escape) then begin;chat_open:=not(chat_open);lastkey:=k_None;end;
// Menu_Chat.Clear;
 {Menu_Chat.ypos_comment:=3;
 Menu_Chat.xpos_comment:=4;
 Menu_Chat.ypos_content:=trunc(maxYscreen/2)+2;
 Menu_Chat.xpos_content:=4;
 Menu_Chat.width_comment:=maxXscreen-1;
 Menu_Chat.heigth_comment:=trunc(maxYscreen/2);    }
 Menu_Chat.MainLoop('');
 if  Menu_Chat.executed<>-1 then
  begin;
   iplayer:=(location.Find_CritterbyID(idPlayer)) as TCharacter;
   sound:=iplayer.DoAction(TAction_Speak);
   (sound as TAction_Speak).text:=Menu_Chat.menu[Menu_Chat.executed];
   (sound as TAction_Speak).target:=iplayer.target;
  end;
end;
//-----------------------------------------------------------------------------
procedure TGame.MainLoop_help;
begin;
 if (lastkey=k_F1)or(lastkey=k_escape) then begin;help_open:=not(help_open);lastkey:=k_None;end;
 Menu_help.MainLoop('Справка');
end;
//-----------------------------------------------------------------------------
 procedure TGame.MainLoop_targetselect;
 var
  currtargetnum,dist,i,j:integer;comment:string;
  currtarget:TCritter;
  s4:TSearcher;

 label a;
 begin;
 s4:=TSearcher.create;

 if (lastkey=k_T)or (lastkey=k_escape) then begin;targetselect_open:=not(targetselect_open);lastkey:=k_None;end;
 if not_assigned((player as TCharacter).AI_controller) then
  begin;log_write('! TGame.MainLoop_targetselect - '+player.id+' has unassigned AI_controller');targetselect_open:=false;exit;end;
 Menu_game.Clear;
 Menu_game.AddItemEX('- отменить выбор -',-2);

 if length((player as TCharacter).AI_controller.PerceptedCritters)>0 then
 for currtargetnum:=0 to length((player as TCharacter).AI_controller.PerceptedCritters)-1 do
  if assigned((player as TCharacter).AI_controller.PerceptedCritters[currtargetnum]) then begin;
   with (player as TCharacter).AI_controller.PerceptedCritters[currtargetnum] do begin
    dist:=trunc(location.Geom_calcdist(player.xpos,player.ypos,player.zpos,xpos,ypos,zpos));
   end;

   s4.ResetSearch;
   currtarget:=s4.Find_CritterbyID((player as TCharacter).AI_controller.PerceptedCritters[currtargetnum].id);
   if assigned(currtarget) then Menu_game.AddItemEX( currtarget.name+
     '('+(player as TCharacter).AI_controller.PerceptedCritters[currtargetnum].id+') расстояние '
     +inttostr(dist)+' м',
     //ctarget.name+' at '+inttostr(dist)+' m'
     (player as TCharacter).AI_controller.PerceptedCritters[currtargetnum].id
     );
  end;

 {repeat
 ctarget:=s3.Find_CritterVisibleBy(player);
 if (assigned(ctarget)) and (ctarget.inheritsfrom(TLiveCreature)) then
 begin;
  dist:=trunc(location.Geom_calcdist(player.xpos,player.ypos,player.zpos,ctarget.xpos,ctarget.ypos,ctarget.zpos));
  Menu_game.AddItemEX(ctarget.name+' at '+inttostr(dist)+' m',ctarget.id);
 end;
 until not(assigned(ctarget));}
 a:Menu_game.MainLoop('Выберите цель');

 if  (Menu_game.executed<>-1)
 //or(mouse_button=mbLeft)
 then
  begin; s4.ResetSearch;
   currtarget:=s4.Find_CritterbyID(Menu_game.special2[Menu_game.executed]);
   if assigned(currtarget) then
    begin;
     (player as TCreature).target:=Menu_game.special2[Menu_game.executed];
     targetselect_open:=false;
    end;
  if  Menu_game.executed=0 then
    begin;
     (player as TCreature).target:='';
     targetselect_open:=false;
    end;
  end;
 s4.free;
 end;

//-----------------------------------------------------------------------------
 procedure TGame.MainLoop_inventory;
 var i,j,k:integer;comment:string;
 uitem,citem,iplayer:TCritter;
 currItem:TItem;
 s2,s3,s4:TSearcher;
 //nonemptyinven:boolean;
 //currItemIndex:integer;
 label a;
 begin;
  if (lastkey=k_I) or (lastkey=k_escape) then begin;inventory_open:=not(inventory_open);lastkey:=k_None;end;
  Menu_game.Clear;
  s2:=TSearcher.create;
  s3:=TSearcher.create;
  iplayer:=s2.Find_critterbyid(idPlayer);
  citem:=s3.Find_ItemInventoredBy(idPlayer);

  if not(assigned(citem)) then begin;goto a;end;
  repeat
   if (citem.InheritsFrom(TItem)) then begin;
    if (not(citem.InheritsFrom(TBodyPart))) then
     begin;
      if (citem as TItem).InSlot then
       begin;Menu_game.AddItemEX((citem as TItem).GetComment+' ('+citem.id+') в '
        +(citem as TItem).CurrentSlot,citem.id);end
      else
       begin;Menu_game.AddItemEX((citem as TItem).GetComment+' ('+citem.id+')',citem.id);end;
     end
     else begin;//Menu_game.AddItemEX('<'+(citem as TItem).GetComment+'>',citem.id);
     end;
   end ;
   //else  begin;Menu_game.AddItemEX(citem.name+' ('+citem.id+')',citem.id);end;
   citem:=s3.Find_CritterByParent(idPlayer);
  until not(assigned(citem));

  a:
   if Menu_game.selected<>-1 then
   begin;
     currItem:=(location.Find_CritterbyID(Menu_game.special2[ Menu_game.selected]) as tItem);
     if assigned(currItem) then  begin;
       Menu_game.comment:=currItem.name+' ';
       for k:=0 to currItem.GetSlotCount do
	Menu_game.comment:=Menu_game.comment+' '+currItem.GetSlot(k);
     end;
   end;
   Menu_game.comment:=Menu_game.comment+' [ENTER] - Использовать или одеть [D] - Бросить ';
   Menu_game.MainLoop('Инвентарь '+iplayer.name);

  if  Menu_game.executed<>-1 then //"применить" текущий предмет
   begin;
    s4:=TSearcher.create;
    uitem:=s4.Find_CritterbyID( Menu_game.special2[ Menu_game.executed]);
    if assigned(uitem) //and ((uitem as TItem).slot<>'')
    then
     begin;
      if (uitem as TItem).InSlot then
       (iplayer as TCreature).Inven_RemoveItemFromSlot(uitem)
       else
       (iplayer as TCreature).Inven_PutItemToSlot(uitem);
     end;
    s4.free;
   end;
  if (lastkey=k_D) then
  begin;
  if Menu_game.selected<>-1 then
  begin;
    s4:=TSearcher.create;
    uitem:=s4.Find_CritterbyID(Menu_game.special2[Menu_game.selected]);
    if assigned(uitem) then
     if uitem.inheritsfrom(TItem) and ((uitem as titem).inventored) then
      begin;
       (iplayer as TCreature).Inven_DropItem(uitem);
      end;
    s4.free;
   end;
   end;
  s2.free;
  s3.free;
 end;
//-----------------------------------------------------------------------------
procedure TGame.MainLoop_debugconsole;
 var
  currconstring,cx,tmp1,tmp2,tmp3:integer;
  //aaa:TStringList;
  commandexecuted:boolean;
  tmptile:ttiler;
  rltrsh,maxheigth:real;
  tileindebug,tileindebug2:string;
 begin
  _screen.writeXYex('консоль',maxXscreen-14,0,maxLayers,WhiteRGB);
  if (lastkey=K_F10)or(lastkey=K_escape) then begin;debugconsole_open:=false;lastkey:=k_None;exit;end;
  if (lastkey=K_BackSpace ) then begin;
    debugconsole_currcommand:=leftstr(debugconsole_currcommand,Length(debugconsole_currcommand)-1);
    lastkey:=k_None;exit;
  end;
  //------ debug commands --------------
  CommandExecuted:=false;
  {debug_los:=true;
  Location.Geom_checkLOS(player.xpos,player.ypos,player.zpos,cmouse_x,cmouse_y,1,rltrsh,rltrsh,rltrsh,maxheigth,false);
  debug_los:=false;}
  if (lastkey=k_Enter) then
  begin
   debugconsole_help.Clear;
   //if (debugconsole_currcommand='QQQ')or(debugconsole_currcommand='FU') then frmCon.close;
   debugconsole_help.Add('TDC - debug_console');
   if (debugconsole_currcommand='TDC') then begin;_writeln('TDC debug_console toggled');
    debug_console:=not debug_console;CommandExecuted:=true;end;
   debugconsole_help.Add('TSA - toggle debug_show_all 8)');
   if (debugconsole_currcommand='TSA') then begin;_writeln('TSA debug_show_all toggled');
    debug_show_all:=not debug_show_all;CommandExecuted:=true;end;
   debugconsole_help.Add('GP - GetPhysics on cursor');
   if (debugconsole_currcommand='GP') then begin;
    _writeln('GetPhysics : '+
    inttostr(location.GetPhysics(cmouse_x,cmouse_y,0,tmp1,tmp2)));
    CommandExecuted:=true;
   end;
   debugconsole_help.Add('CMH - CheckMaxHeight on cursor');
   if (debugconsole_currcommand='CMH') then begin;_writeln('CheckMaxHeight : '+FloatToStr(maxheigth)); CommandExecuted:=true;end;
   debugconsole_help.Add('HELP - your are reading it');
   if (debugconsole_currcommand='HELP') then begin;
    for tmp3:=0 to debugconsole_help.Count-1 do
      _writeln(debugconsole_help.strings[tmp3]);
    CommandExecuted:=true;end;
   if commandexecuted then begin;
//     _writeln(debugconsole_currcommand);
     debugconsole_currcommand:='';
    end
   else _writeln('i dnt understand your typing');
   lastkey:=k_None;
  end;
  if lastkey<>k_None then
   debugconsole_currcommand:=debugconsole_currcommand+char(lastkey);
  //------ /debug commands --------------
  _screen.writeXY(' | ',cmouse_x-1,cmouse_y-1,lyGUI);
  _screen.writeXY('- -',cmouse_x-1,cmouse_y,lyGUI);
  _screen.writeXY(' | ',cmouse_x-1,cmouse_y+1,lyGUI);
  {for currconstring:=maxConsoleLines downto 0 do begin
   _screen.writeXY(_screen.consolelines[currconstring],0,maxYscreen-currconstring-10,lyGui);
  end;}
  tmptile:=Location.getgroundEX(cmouse_x,cmouse_y,1);
  if assigned(Location.Critters[tmptile.index])
   then tileindebug:=Location.Critters[tmptile.index].id
   else tileindebug:='-=UNKNOWN=-';
  tileindebug2:=' debug id: '+tileindebug+' index['+IntToStr(tmptile.index)+']'+' x:'+inttostr(cmouse_x)
   +' y:'+inttostr(cmouse_y)+' '+Location.getground(cmouse_x,cmouse_y,1)
   +' physics: '+inttostr(location.GetPhysics(cmouse_x,cmouse_y,0,tmp1,tmp2))+' CheckMaxHeight : '
   +FloatToStr(tmptile.height);
  if IsAssignedAndInherited(Location.Critters[tmptile.index],TLandscape_Custom) then
    tileindebug2:=tileindebug2+' tile comment:'+(Location.Critters[tmptile.index] as TLandscape_Custom).TileComment;
  _screen.writeXY(tileindebug2,0,maxYscreen-14,lyGui);
  _screen.writeXYex(strOF('█',length(tileindebug2)),0,maxYscreen-14,lyGuiBack,BlackRGB);
  for cx:=0 to 10 do
     if maxconsolelines-cx>0 then begin;
       _screen.writeXY(_screen.consolelines[maxconsolelines-cx],0,maxYscreen-cx-2,lyGui);
       _screen.writeXYex(strOF('█',length(_screen.consolelines[maxconsolelines-cx])),0,maxYscreen-cx-2,lyGuiBack,BlackRGB);
     end;
  _screen.writeXY('~$ '+debugconsole_currcommand+'█',0,maxYscreen-1,lyGui);
  lastkey:=k_None;
 end;
//-----------------------------------------------------------------------------
 procedure TGame.DrawGroupsList;
 var i:integer;lastgroup:integer;
  str_tmp1:string;
  tmpCritter:TCritter;
 begin;
  for i:=1 to 9 do
   begin;
    str_tmp1:='';
    tmpCritter:=Location.Find_CritterbyID('player'+inttostr(i));
    if assigned(tmpCritter) then
     begin;
        lastgroup:=i;
        if tmpCritter.id=idPlayer
         then str_tmp1:=inttostr(i)+' ['+tmpCritter.name+' '
         else str_tmp1:=inttostr(i)+'  '+tmpCritter.name+' ';
          begin;
           if assigned((tmpCritter as TCharacter).currAction)
           then
            begin;
             str_tmp1:=str_tmp1+(tmpCritter as TCharacter).currAction.GetFriendlyName+' ';
            end
           else str_tmp1:=str_tmp1+'Нет действий';
          end;
       if tmpCritter.id=idPlayer then str_tmp1:=str_tmp1+']';
       if tmpCritter.id<>idplayer then
         _screen.drawSprite(inttostr(i),(tmpCritter.xpos),(tmpCritter.ypos),lyGUI2,grayRGB);
       // (mouse_button=mouseLeft)
       {if tmpCritter.id=idPlayer then
        begin;
         _screen.writeXYex(StrOF('█',Length(str_tmp1)) ,0,maxyscreen-2-i,lyGUIback,greenRGB);
         _screen.writeXYex(str_tmp1,0,maxyscreen-2-i,lyGUI,blackRGB);
        end
        else }
        if (gui_charflash>0) and ((tmpCritter as TCreature).curraction=nil)and (tmpCritter.id<>idPLayer) then
          begin
           //_screen.writeXYex(strOF('▒', UTF8Length(str_tmp1)),0,maxyscreen-2-i,lyGuiBack,greenrgb);
           str_tmp1:=str_tmp1+' <<Жду приказа!>>';
           _screen.drawSprite('?',(tmpCritter.xpos)+1,(tmpCritter.ypos)-1,lyGUI,rgbGUI_Hint);
          end;

         //else
         _screen.writeXYexWithBCK(str_tmp1,0,maxyscreen-2-i,lyGUI,rgbGUI_Elements);
     end;
   end;
    _screen.writeXYexWithBCK('N  КомГрп',0,maxyscreen-3-lastgroup,lyGUI,rgbGUI_Elements);
  //КЛ1725  КЛ715  КЛ832  КЛ1892  КЛ1182

 { TODO -cTODO : переделать на TGUI_Menu }
  if (cmouse_x<24) and (cmouse_y<=maxyscreen-3)and (cmouse_y>=maxyscreen-3-9) then begin;
    mouse_cursor_enabled:=false;
    str_tmp1:='Выбрать группу ';
//    mousehint:='ЛКМ - Выбрать группу';
    _screen.drawSprite('○',cmouse_x,cmouse_y,lyDEBUG,rgbGUI_Hint);
    if (mouse_button=mouseLeft) then begin;
     //_writeln((('player'+inttostr(maxyscreen-2-cmouse_y))));
      if assigned(Location.Find_CritterbyID('player'+inttostr(maxyscreen-2-cmouse_y))) then begin;
         idPlayer:=('player'+inttostr(maxyscreen-2-cmouse_y));
         mouse_button:=mouseNone;
      end;
    end;
  end;

  _screen.writeXYex(str_tmp1,cmouse_x+1,cmouse_y-1,lyGUI,rgbGUI_Hint);

  if ((lastkey>=k_1)and(lastkey<=k_9))then begin;
   if assigned(Location.Find_CritterbyID('player'+inttostr(ord(lastkey)-ord(k_0))))
    then idPlayer:='player'+inttostr(ord(lastkey)-ord(k_0));
  end;

 if inventory_open or targetselect_open then mouse_button:=mouseNone;

 end;
//-----------------------------------------------------------------------------
 procedure TGame.DrawGUI;
  var dist,tohit,cx,cy,i,tmpActEnum,lastgroup:integer;targ,hand,tmpCritter:TCritter;
  sear,s3,s_targ:TSearcher;tmpHandAction:TActionClass;
  str_tmp1:string;tmprnd:real;

  begin;
      if not(assigned(player)) then exit;
      sear:=TSearcher.create;
      s3:=TSearcher.create;

      s_targ:=TSearcher.create;targ:=nil;
      targ:=s_targ.Find_CritterbyID((player as TCreature).target);
      if assigned((player as TCharacter).currAction)
       then
        begin;
         str_tmp1:=(player as TCharacter).currAction.GetFriendlyName;
         if str_tmp1='' then
          str_tmp1:=(player as TCharacter).currAction.classname;
         str_tmp1:='['+str_tmp1+']'
        end
       else str_tmp1:='[Нет действий]';
      if assigned(targ) then
       begin;
        dist:=trunc(location.Geom_calcdist(targ.xpos,targ.ypos,targ.zpos,player.xpos,player.ypos,player.zpos));
        _screen.writeXYexWithBCK('[Цель: '+targ.name+' расстояние '+inttostr(dist)+' м]'+
        str_tmp1,15,maxyscreen-1,lyGUI,rgbGUI_Elements);
       end
      else _screen.writeXYexWithBCK('[Цель не выбрана]'+str_tmp1,18,maxyscreen-1,lyGUI,rgbGUI_Elements);
      s_targ.free;

      with player as TCreature do
        begin;
         _screen.writeXYRAWithBCK('['+stnNames[stance]+']',maxxscreen-8,maxyscreen,lyGUI,rgbGUI_Elements);
         _screen.writeXYexWithBCK('[   ]',maxxscreen-7,maxyscreen-2,lyGUI,rgbGUI_Elements);
         _screen.writeXYexWithBCK('[   ]',maxxscreen-7,maxyscreen-1,lyGUI,rgbGUI_Elements);
         _screen.writeXYexWithBCK('[   ]',maxxscreen-7,maxyscreen-0,lyGUI,rgbGUI_Elements);
         _screen.drawSprite('.',(maxxscreen-5+1.3*cos((90-glance)/57)),(maxyscreen-1-1.3*sin((90-glance)/57)),lyGUI,GreenRGB);
         _screen.writeXYexWithBCK('ОЗ: '+inttostr(Sklmtrx_GetParamRes(prmCurrHP))+'/'+
          inttostr(Sklmtrx_GetParamRes(prmBaseHP))+' ',0,maxyscreen,lyGUI,rgbGUI_Elements);
        end;
       hand:=gethanditem(player);
       if assigned(hand)
       then
        begin;str_tmp1:='';
        {  for tmpActEnum:=0 to 20 do//BUGBUG ima lazy
           begin;tmpHandAction:=nil;  }
            tmpHandAction:=(hand as TItem).GetCurrAction;
            {if assigned(tmpHandAction) then
             begin;
             { if tmpActEnum=(hand as TItem).CurrActionNum then
                str_tmp1:=str_tmp1+'['+(hand as TItem).GetActionByNum(tmpActEnum).GetComment+']'
               else  }  }
                str_tmp1:=//str_tmp1+' '+
                 tmpHandAction.GetComment;//+' ';
             {end;
            end;}
          _screen.writeXYexWithBCK('['+(hand as TItem).GetComment+'] '+
	      '['+str_tmp1+']',13,maxyscreen,lyGUI,rgbGUI_Elements)//(hand as TItem).GetCurrAction.GetComment
        end

       else _screen.writeXYexWithBCK('[Предмет не выбран] ',13,maxyscreen,lyGUI,rgbGUI_Elements);
       _screen.writeXYexWithBCK('Время: '+location.BreakScalarTime(location.time)+' ',
        0,maxyscreen-1,lyGUI,rgbGUI_Elements);

     {  for i:=1 to 9 do
        begin;
          str_tmp1:='';
          tmpCritter:=Location.Find_CritterbyID('player'+inttostr(i));
          if assigned(tmpCritter) then
           begin;
              lastgroup:=i;
              if tmpCritter.id=idPlayer
               then str_tmp1:=inttostr(i)+' ['+tmpCritter.name+' '
               else str_tmp1:=inttostr(i)+'  '+tmpCritter.name+' ';
                begin;
                 if assigned((tmpCritter as TCharacter).currAction)
                 then
                  begin;
                   str_tmp1:=str_tmp1+(tmpCritter as TCharacter).currAction.GetFriendlyName+' ';
                  end
                 else str_tmp1:=str_tmp1+'Нет действий';
                end;
             if tmpCritter.id=idPlayer then str_tmp1:=str_tmp1+']';
             if tmpCritter.id<>idplayer then
               _screen.drawSprite(inttostr(i),(tmpCritter.xpos),(tmpCritter.ypos),lyGUI2,grayRGB);
             // (mouse_button=mouseLeft)
             {if tmpCritter.id=idPlayer then
              begin;
               _screen.writeXYex(StrOF('█',Length(str_tmp1)) ,0,maxyscreen-2-i,lyGUIback,greenRGB);
               _screen.writeXYex(str_tmp1,0,maxyscreen-2-i,lyGUI,blackRGB);
              end
              else }
              if (gui_charflash>0) and ((tmpCritter as TCreature).curraction=nil)and (tmpCritter.id<>idPLayer) then
                begin
                 //_screen.writeXYex(strOF('▒', UTF8Length(str_tmp1)),0,maxyscreen-2-i,lyGuiBack,greenrgb);
                 str_tmp1:=str_tmp1+' <<Жду приказа!>>';
                 _screen.drawSprite('?',(tmpCritter.xpos)+1,(tmpCritter.ypos)-1,lyGUI,rgbGUI_Hint);
                end;

               //else
               _screen.writeXYexWithBCK(str_tmp1,0,maxyscreen-2-i,lyGUI,rgbGUI_Elements);
           end;
        end;
         _screen.writeXYexWithBCK('N  КомГрп',0,maxyscreen-3-lastgroup,lyGUI,rgbGUI_Elements);
       //КЛ1725  КЛ715  КЛ832  КЛ1892  КЛ1182    }

  for cx:=0 to 15 do
   if maxconsolelines-cx>0 then begin;
     _screen.writeXYexWithBCK(_screen.consolelines[maxconsolelines-cx],0,15-cx-2,lyGui,rgbGUI_Elements);
   end;

   s3.free;
   sear.free;
  end;
 //-----------------------------------------------------------------------------
 function cmousecheckselected:integer;
 var i:integer;
 begin;result:=0;
  for i:=maxLayers downto 0 do begin;
    if _screen.content.[cmouse_x,cmouse_y,i]<>'' then begin;result:=i;exit;end;
  end;
 end;
//-----------------------------------------------------------------------------
 procedure TGame.ReactMouse;
 var i,j,tmpx,tmpy:integer;dist,moveto_x,moveto_y:real;chklosend:tPoint;
  tmpplayer:tcritter;
  tmpstr,mousehint,mousehint2:string;
  sear:TSearcher;
  cAction:TAction;
  vis:boolean;
  playerLosEvaluator:TLosEvaluator;
  tmptile:ttiler;
 label fck,chklosend_stop;
 begin;
  sear:=TSearcher.create; sear.ResetSearch;

 _screen.paintBlock(0,0,maxXscreen+1,maxYscreen+1,1,rgbRender_UnvisibleTile);

 if (modalwindow_open)// or (inventory_open) or (targetselect_open)
  or(chat_open) or (help_open) or (debugconsole_open)
 then exit;

 { TODO -cTODO : переделать на TGUI_Menu }
{ if (cmouse_x<24) and (cmouse_y<=maxyscreen-3)and (cmouse_y>=maxyscreen-3-9) then begin;
   mouse_cursor_enabled:=false;
   tmpstr:='Выбрать группу ';
   mousehint:='ЛКМ - Выбрать группу';
   _screen.drawSprite('○',cmouse_x,cmouse_y,lyDEBUG,rgbGUI_Hint);
   if (mouse_button=mouseLeft) then begin;
    //_writeln((('player'+inttostr(maxyscreen-2-cmouse_y))));
     if assigned(Location.Find_CritterbyID('player'+inttostr(maxyscreen-2-cmouse_y))) then begin;
        idPlayer:=('player'+inttostr(maxyscreen-2-cmouse_y));
        mouse_button:=mouseNone;
     end;
   end;
 end;

 if ((lastkey>=k_1)and(lastkey<=k_9))then begin;
  if assigned(Location.Find_CritterbyID('player'+inttostr(ord(lastkey)-ord(k_0))))
   then idPlayer:='player'+inttostr(ord(lastkey)-ord(k_0));
 end;  }

 for i:=1 to 9 do
  if assigned(Location.Find_CritterbyID('player'+inttostr(i))) then
  begin
//   tmpx:=0;tmpy:=0;
   playerLosEvaluator:=((Location.Find_CritterbyID('player'+inttostr(i))
     as TCharacter).AI_controller as TAI_ControllerUser).LosEvaluator;
  // while tmpx<maxLocationXSize do
   for tmpx:=0 to maxXscreen do
    begin;
//      tmpy:=0;
//      while tmpy<maxLocationYSize do
      for tmpy:=0 to maxYscreen do
       begin;
        vis:=playerLosEvaluator.getVisible(tmpx,tmpy);
        if vis
         then begin;
          if idPlayer=('player'+inttostr(i)) then
           begin;
            _screen.writeXYex('░',tmpx,tmpy,0,rgbRender_VisibleFloor);
            _screen.paintBlock(tmpx,tmpy,1,1,1,rgbRender_VisibleTile);// color[tmpx,tmpy,1]:=rgbRender_VisibleTile;
           end
          else
           begin;
            if _screen.content[tmpx,tmpy,0]='' then
             _screen.writeXYex('▒',tmpx,tmpy,0,rgbRender_LessVisibleFloor);//▓▒░▐
            _screen.paintBlock(tmpx,tmpy,1,1,1,rgbRender_LessVisibleTile);// _screen.color[tmpx,tmpy,1]:=rgbRender_LessVisibleTile;
           end;
         end;
    //    tmpy:=tmpy+1;
       end;
   //  tmpx:=tmpx+1;
    end;
  end;

 if (inventory_open) or (targetselect_open)
  then
    exit;

 if assigned(Player) then
  if (player as TLiveCreature).Sklmtrx_GetParamRes(prmCurrHP) >=0 then
  begin;
   tmpplayer:=sear.Find_CritterByPosEx(cmouse_x,cmouse_y,lyGround,0.5);
   //Выбрать группу мышью
   if assigned(tmpplayer)then begin;
    for i:=1 to 9 do
     if  (tmpplayer.id=('player'+inttostr(i)))and(idPlayer<>'player'+inttostr(i)) then
      //if(round(tmpplayer.xpos)=cmouse_x)and(round(tmpplayer.ypos)=cmouse_y)then
       if(mouse_button=mouseLeft)
         then begin;j:=i;mouse_button:=mouseNone;
            gui_charflash:=gui_charflash_defaultvalue;
            idPlayer:='player'+inttostr(i);
           goto fck;end
         else begin;
          mouse_cursor_enabled:=false;
          tmpstr:='Выбрать группу '+tmpplayer.name+' ';
          _screen.drawSprite('○',cmouse_x,cmouse_y,lyDEBUG,rgbGUI_Hint);
          mousehint:='ЛКМ - Выбрать группу';
          goto fck;
         end
    end;

   //select target by mouse
   if length((player as TCharacter).AI_controller.PerceptedCritters)>0 then
    for i:=0 to length((player as TCharacter).AI_controller.PerceptedCritters)-1 do
     if assigned((player as TCharacter).AI_controller.PerceptedCritters[i]) then// begin;
      with (player as TCharacter).AI_controller.PerceptedCritters[i] do begin
       dist:=trunc(location.Geom_calcdist(player.xpos,player.ypos,player.zpos,xpos,ypos,zpos));
       sear.ResetSearch;
       //currtarget:=sear.Find_CritterbyID((player as TCharacter).AI_controller.PerceptedCritters[currtargetnum].id);
       tmpplayer:=sear.Find_CritterbyID(id);
       if assigned(tmpplayer) then
 {        if (tmpplayer.xpos-1<=cmouse_x)and(tmpplayer.xpos+1>=cmouse_x)and
            (tmpplayer.ypos-1<=cmouse_y)and(tmpplayer.ypos+1>=cmouse_y)then}
         if (tmpplayer.xpos=cmouse_x)and(tmpplayer.ypos=cmouse_y)then
           if(mouse_button=mouseLeft)//then
            //if(pos(tmpplayer.id,'player')=0)
             then begin;(player as TCreature).target:=tmpplayer.id;mouse_button:=mouseNone;
              gui_charflash:=gui_charflash_defaultvalue;end
             else begin;
              mouse_cursor_enabled:=false;
              tmpstr:='Выбрать цель: '+tmpplayer.name+' дист '+floattostr(dist)+'м.';
              _screen.drawSprite('✇',cmouse_x,cmouse_y,lyDEBUG,redrgb);
              mousehint:='ЛКМ - Выбрать цель';
             end;
      end;
   fck:
//    _screen.writeXY(tmpstr,trunc(maxxscreen/2)-7,maxyscreen-4,lyGUIback);
   tmpplayer:=Location.Find_CritterbyID( idPlayer);

   debug_los:=false;
   Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,tmpplayer.zpos,cmouse_x,cmouse_y,1,moveto_x,moveto_y,rltrsh5,rltrsh5,true);

   debug_los:=false;

   if (cmouse_x<>moveto_x)or(cmouse_y<>moveto_y) then begin;
       moveto_x:=cmouse_x;moveto_y:=cmouse_y;
   end;
   Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,cmouse_x,cmouse_y,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);
   if tmpstr='' then begin;
    tmpstr:='┌Идти к';

    tmptile:=Location.getgroundEX(cmouse_x,cmouse_y,1);
    if IsAssignedAndInherited(Location.Critters[tmptile.index],TLandscape_Custom) then
     tmpstr:=tmpstr+' '+(Location.Critters[tmptile.index] as TLandscape_Custom).TileComment;

    mousehint:='ЛевКМ - идти, Shift+ЛевКМ - бежать, СреднКМ или Alt+ЛКМ - смотреть, CTRL+ЛевКМ - идти, сохраняя направление взгляда';
     //+FloatToStr(SolveAngle(tmpplayer.xpos,tmpplayer.ypos,cmouse_x,cmouse_y));
    if (cmouse_x=moveto_x)or(cmouse_y=moveto_y) then mouse_cursor_enabled:=false;
    _screen.writeXYex('▾',round(moveto_x),round(moveto_y),lyGUI,rgbGUI_Hint);
    if (cmouse_x<>moveto_x)or(cmouse_y<>moveto_y) then
     _screen.writeXYex(tmpstr,round(moveto_x),round(moveto_y)-1,lyGUI,rgbGUI_Hint);
//       _screen.writeXYex(strOF('█',UTF8Length(tmpstr)),round(moveto_x)+1,round(moveto_y)-1,lyGuiBack,BlackRGB);
   end
   else begin;
    _screen.writeXYex(tmpstr,cmouse_x+1,cmouse_y-1,lyGUI,rgbGUI_Hint);
   end;
   if (mouse_button=mouseLeft)or(mouse_button=mouseMiddle)
//      and not((keyShiftPressed) or (keyCtrlPressed))
    then
    //if (cmousecheckselected<lyGUIback)or(cmousecheckselected<lyGUI) then
    begin;{ TODO -cBUG : must be checked after drawing the gui }
      cAction:=(player as TCharacter).DoAction(TAction_WalkToCoord);
      if assigned(caction) then begin
       if keyCtrlPressed then (cAction as TAction_WalkToCoord).preserveglance:=true;
       if keyShiftPressed then (cAction as TAction_WalkToCoord).run:=true;
       if (mouse_button=mouseMiddle) or keyAltPressed then (cAction as TAction_WalkToCoord).rotateonly:=true;
       (cAction as TAction_WalkToCoord).walkto_x:=moveto_x;
       (cAction as TAction_WalkToCoord).walkto_y:=moveto_y;
       (cAction as TAction_WalkToCoord).walkfrom_x:=player.xpos;
       (cAction as TAction_WalkToCoord).walkfrom_y:=player.ypos;
      end;
      gui_charflash:=gui_charflash_defaultvalue;
    end;
   debug_los:=false;
  end;

  sear.Destroy;
  _screen.writeXYRAWithBCK(mousehint,maxXscreen-1,0,lyGUI,rgbGUI_Hint);

 end;
//-----------------------------------------------------------------------------
function TGame.GetHandItem(aCitter:tcritter):tcritter;
var hnd:tcritter; sear2:TSearcher; begin result:=nil;
	 sear2:=TSearcher.create; sear2.ResetSearch;
	 hnd:=sear2.Find_ItemByslot(aCitter.id,sltPonyTelekineticField);
	 if not(assigned(hnd)) then
	  begin; sear2.ResetSearch;hnd:=sear2.Find_ItemByslot(aCitter.id,sltPonyTelekineticFields);end;
	 if assigned(hnd) then result:=hnd as TItem;
	 sear2.free;
end;
//-----------------------------------------------------------------------------
procedure TGame.ReactKeys;
var sear2,s3,st,s_targ,sear_item:TSearcher;
targ,hand,near_item:TCritter;ihand:TItem;
dist,wtf,tmpAggrLevel,tmpAggrLevelActual,i:integer;
tohit,mindist,g:integer;str_tmp1:string;
act_speak:TAction_Speak;
outHour,outMinute,outSecond,outMilliSecond:word;
label z,y;
 begin;
  if inventory_open then begin;MainLoop_inventory;exit;end;
  if chat_open then begin;MainLoop_Chat;mouse_button:=mouseNone;exit;end;
  if targetselect_open then begin;MainLoop_targetselect;exit;end;
  if help_open then begin;MainLoop_help;mouse_button:=mouseNone;exit;end;
  if debugconsole_open then begin;MainLoop_debugconsole;mouse_button:=mouseNone;exit;end;
  if modalwindow_open then begin;MainLoop_modalwindow;mouse_button:=mouseNone;exit;end;

  if (lastkey=k_f10)then begin;debugconsole_open:=true;lastkey:=k_None;exit;end;
  if (lastkey=k_T) then begin;targetselect_open:=true;lastkey:=k_None;exit;end;
  if (lastkey=k_I) then begin;inventory_open:=not(inventory_open);lastkey:=k_None;exit;end;
  if (lastKey=k_f1) then begin;help_open:=not(help_open);lastkey:=k_None;exit;end;

  Menu_help.Clear;
  Menu_help.AddItemEX('[T] выбрать цель',-2);
  Menu_help.AddItemEX('[I] инвентарь',-2);
  Menu_help.AddItemEX('[ESC] выйти в главное меню',-2);
  Menu_help.hideselector:=true;

{  if (lastkey=k_escape) then begin;
	{newGame:=.Create;
	Game.destroy;game:=newgame;
	newgame:=nil;self:=nil;
	Log_write('+ exiting to main menu.');exit;}
    SwitchTo(TGameMenu);
    exit;
  end;
  }

  Menu_help.AddItemEX('[F6] быстрая запись ',-2);
  if (lastKey=k_f6) then
  begin;
//   untConsole.frmCon.caption:='location[-] actors[-]';

   RenameFile('.'+PathDelim+'Save00','.'+PathDelim+'_TRASH'+PathDelim+'Save00_Backup_'
   +inttostr(DateDay)+'.'+inttostr(DateMonth)+'.'+inttostr(DateYear)+','
   +inttostr(TimeHour)+'.'+inttostr(TimeMinute)+'.'+inttostr(TimeSecond)
   );
   CreateDir('.'+PathDelim+'Save00');
  // DeleteDirectory('.'+PathDelim+'Save00',true);
   Location.Save('.'+PathDelim+'Save00'+PathDelim);
   _writeln('Location saved')
{   untConsole.frmCon.caption:='location[+] actors[-]';
   location.SaveLocation('');
   untConsole.frmCon.caption:='location[+] actors[+]';}
  end;
  Menu_help.AddItemEX('[F5] быстрое загрузка ',-2);//cm. MainLoop

  if assigned(Player) then
   if (player as TLiveCreature).Sklmtrx_GetParamRes(prmCurrHP) >=0 then
  begin;
   with Player as TCreature do
	begin;
     {Menu_help.AddItemEX('[СТРЕЛКИ] смотреть в разные стороны и ходить',-2);
	 if (lastKey=k_Up) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkForward);gui_charflash:=gui_charflash_defaultvalue;end;
	 if (lastKey=k_Down) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkBackward);gui_charflash:=gui_charflash_defaultvalue;end;
	 if (lastKey=k_Left) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_RotateLeft);gui_charflash:=gui_charflash_defaultvalue;end;
	 if (lastKey=K_Right) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_RotateRight);gui_charflash:=gui_charflash_defaultvalue;end;

     Menu_help.AddItemEX('[<],[>] ходить боком',-2);
     if (lastKey=K_Period) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkStrafeRight);gui_charflash:=gui_charflash_defaultvalue;end;
     if (lastKey=K_Comma) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkStrafeLeft);gui_charflash:=gui_charflash_defaultvalue;end;
      }
       {
     Menu_help.AddItemEX('[Q] Бегом',-2); }
     Menu_help.AddItemEX('[A] Подняться',-2);
     Menu_help.AddItemEX('[Z] Пригнуться/Ползком',-2);
     if (lastKey=k_A) then
	      begin;cAction:=(player as TCharacter).DoAction(TAction_StandUp);gui_charflash:=gui_charflash_defaultvalue;end;
     if (lastKey=k_Z) then
	      begin;cAction:=(player as TCharacter).DoAction(TAction_StandDown);gui_charflash:=gui_charflash_defaultvalue;end;

	 Menu_help.AddItemEX('[N] выбрать следующее действие предмета',-2);
	 if (lastKey=k_N) then
	  begin;
	    sear2:=TSearcher.create;
	    sear2.ResetSearch;
	    hand:=sear2.Find_ItemBySlot(idPlayer,sltPonyTelekineticField);
	    if assigned(hand) then with hand as TItem do SwitchAction;
	    sear2.free;
        gui_charflash:=gui_charflash_defaultvalue;
	  end;

	{ Menu_help.AddItemEX('[H] выкинуть предмет инвентаря',-2);
	 if (lastKey=k_H) then
	  begin;
	    sear2:=TSearcher.create;
	    sear2.ResetSearch;
	    hand:=sear2.Find_ItemBySlot(idPlayer,slt);
	    if assigned(hand)
	     then (player as TCreature).Inven_RemoveItemFromSlot(hand)
	     else _writeln(player.name+' - hands empty');
	    sear2.free;
	  end;}

	 Menu_help.AddItemEX('[D] совершить выбранное действие',-2);
	 if (lastKey=k_d)
	// and ((player as TCharacter).target<>'')
	 then
	   begin;
	      sear2:=TSearcher.create;
	      sear2.ResetSearch;
	      hand:=gethanditem(player);
	      if assigned(hand) then
	      begin;
	       ihand:=(hand as TItem);
	       cAction:=(player as TCharacter).DoAction(ihand.GetCurrAction);
	       if _ASSERT(cAction) then _writeln('???')
	       else
	       begin;
	        cAction.agent:=hand.id;
          {  if cAction.InheritsFrom(TAction_Attack) then
             (Location.Find_CritterbyID((player as TCreature).target)).tags.SetTag(tagAttackedByPlayer,'true'); }
            gui_charflash:=gui_charflash_defaultvalue;
	       end;
	      end;
	      sear2.free;
	   end;
//	end;

      Menu_help.AddItemEX('[S] ждать',-2);
      if (lastkey=k_S) then
      begin;
	    cAction:=(player as TCharacter).DoAction(TAction_Idle);
      end;

      Menu_help.AddItemEX('[C] говорить с выбранной целью',-2);
      if (lastkey=k_C) then
      begin;
	       if((player as TCharacter).target<>'') then begin;
		    act_Speak:=((player as TCharacter).DoAction(TAction_Speak))as TAction_Speak;
		    act_Speak.target:=(player as TCharacter).target;
		    act_Speak.text:='';
	       end
       else
		    _writeln('! Следует сначала выбрать цель для разговора');
       gui_charflash:=gui_charflash_defaultvalue;
      end;

      Menu_help.AddItemEX('[G] поднять предмет',-2);
      if (lastkey=k_G) then
      begin;
       sear_item:=TSearcher.create;
       z:near_item:=sear_item.Find_CritterByPosEx(player.xpos,player.ypos,player.zpos,1);
       if not(assigned(near_item)) then goto y;
       if not(near_item.InheritsFrom(TItem)) then goto z;
       if ((near_item as TItem).inventored=true) then goto z;
       (player as TCreature).Inven_LiftItem(near_item);
       y: sear_item.free;
       gui_charflash:=gui_charflash_defaultvalue;
      end;

  end;

  Menu_help.AddItemEX('[1]-[0] Переключение групп персонажей',-2);

  Menu_help.AddItemEX('[Q] Огонь по возможности',-2);
  Menu_help.AddItemEX('[W] Огонь в ответ',-2);
  Menu_help.AddItemEX('[E] Не стрелять',-2);
 if assigned((player as TCharacter).AI_controller) then
  if (player as TLiveCreature).Sklmtrx_GetParamRes(prmCurrHP) >=0 then
   if ((player as TCharacter).AI_controller.InheritsFrom(TAI_ControllerUser)) then
    begin;
      tmpAggrLevel:=((player as TCharacter).AI_controller as TAI_ControllerUser).AggressionLevel;
      tmpAggrLevelActual:=tmpAggrLevel;
      if (lastKey=k_Q) then tmpAggrLevelActual:=agrFireAtWill;
      if (lastKey=k_W) then tmpAggrLevelActual:=agrReturnFire;
      if (lastKey=k_E) then tmpAggrLevelActual:=agrCeaseFire;
      if (cmouse_x<maxxscreen-8)and(cmouse_x>maxXscreen-8-length(agrNames[agrFireAtWill]))and
         (cmouse_y=maxyscreen-1)then gui_AggrMenuOpen:=true
       else
         if (cmouse_y<maxyscreen-agrMax-1) then gui_AggrMenuOpen:=false;
      if (mouse_button=mouseLeft)and(gui_AggrMenuOpen) then tmpAggrLevelActual:=maxyscreen-1-cmouse_y;
      if tmpAggrLevel<>tmpAggrLevelActual then begin
         act_Speak:=((player as TCharacter).DoAction(TAction_Speak))as TAction_Speak;
         if assigned(act_Speak) then begin;
           act_Speak.text:=agrNames[tmpAggrLevelActual];
           (player.DoInfluence(TInfluence_Sound_Talk_Speech) as TInfluence_Sound_Talk_Speech).text:=agrNames[tmpAggrLevelActual];
           ((player as TCharacter).AI_controller as TAI_ControllerUser).AggressionLevel:=tmpAggrLevelActual;
           gui_charflash:=gui_charflash_defaultvalue;
           mouse_button:=mouseNone;
         end;
       end;

      if gui_AggrMenuOpen then
       for i:=agrMin to agrMax do
        if maxyscreen-1-cmouse_y=i then //i=tmpAggrLevelActual then
         _screen.writeXYRAWithBCK('['+agrNames[i]+']',maxxscreen-8,maxyscreen-1-i,lyGUI,rgbGUI_Elements)
         else _screen.writeXYRAWithBCK(' '+agrNames[i]+' ',maxxscreen-8,maxyscreen-1-i,lyGUI,rgbGUI_Elements)
      else
       begin;
        tmpAggrLevelActual:=((player as TCharacter).AI_controller as TAI_ControllerUser).AggressionLevel;
        _screen.writeXYRAWithBCK('['+agrNames[tmpAggrLevelActual]+']',maxxscreen-8,maxyscreen-1,lyGUI,rgbGUI_Elements);
       end;
    end;

  Menu_help.AddItemEX('[ПРОБЕЛ] Остановить время/Приказ ЖДАТЬ',-2);
  Menu_help.AddItemEX('          время запускаеться автоматически',-2);
  Menu_help.AddItemEX('          если все группы имеют приказы',-2);
  Menu_help.AddItemEX('[ЛЕВ.КН.МЫШИ] Выбрать цель/КомГрп/Идти в точку',-2);
  Menu_help.AddItemEX('[КОЛЕСО МЫШИ]  Изменить масштаб отображения',-2);
  Menu_help.AddItemEX('[F11] вкл/выкл полноэкранный режим',-2);
  Menu_help.AddItemEX('[ALT]+[F4] выйти из игры',-2);
  Menu_help.AddItemEX('--------------------------------',-2);
  Menu_help.AddItemEX('Нажмите ESC для закрытия справки',-2);

{  tmptile:=Location.getgroundEX(cmouse_x,cmouse_y,0);
  if assigned(Location.Critters[tmptile.index])
   then tileindebug:=Location.Critters[tmptile.index].id
   else tileindebug:='-=UNKNOWN=-';
  tileindebug2:='x:'+inttostr(cmouse_x)+' y:'+inttostr(cmouse_y)+' '+Location.getground(cmouse_x,cmouse_y,0);
  _screen.writeXY('debug id: '+tileindebug+' index['+IntToStr(tmptile.index)+']'
     +tileindebug2
     ,0,maxYscreen-14,lyGui);}

  {if (lastkey=K_L) then begin;player.tags.Append('sample_tag1');player.tags.Append('sample_tag1_content');end;
  if (lastkey=K_K) then begin;
   player.tags.Delete(player.tags.IndexOf('sample_tag1'));
   player.tags.Delete(player.tags.IndexOf('sample_tag1_content')); }
  if (lastkey=K_K) then begin;
     modalwindow_text:='Вы зачем-то запустили техническую демонстрацию NHWT. '+LineEnding+
 'Она скорее всего не отображает ни одно качество конечной версии. '+LineEnding+
 'Сейчас в игре отсутствуют: <s>los</s>присобачен, ai, графоний всех видов, <s>управление шайкой</s> частично реализовано. Присутствуют в рудиментарной форме: редактор персонажа, ходилка по лесу'+
 ', говорилка, стрелялка в крестьянина.';
     modalwindow_text:=modalwindow_text+modalwindow_text;modalwindow_text:=modalwindow_text+modalwindow_text;
     modalwindow_text:=modalwindow_text+modalwindow_text;
     modalwindow_open:=true;
     end;
  end;
  //ReactMouse;
 end;
//-----------------------------------------------------------------------------
 procedure TGame.MainLoop_modalwindow;
 var i,j:integer;
  width_comment,heigth_comment,xpos_comment,ypos_comment,xpos_title,ypos_title,xpos_content,ypos_content,
  maxheight,firstshownitem:integer;
 begin;
  if (lastKey=k_space) or (mouse_button=mouseLeft) then
   begin;modalwindow_open:=false;lastKey:=K_None;mouse_button:=mouseNone;end;
  _screen.writeBlockEx(modalwindow_text,10,10,maxXscreen-20,trunc(maxxscreen/2),lyGUI,GreenRGB);
  _screen.writeBlockEx('НАЖМИТЕ ПРОБЕЛ ИЛИ ЛЕВ.КН.МЫШИ ДЛЯ ПРОДОЛЖЕНИЯ',10,trunc(maxyscreen/2)+2,maxXscreen-20,trunc(maxyscreen/2)+2,lyGUI,GreenRGB);
 end;
//-----------------------------------------------------------------------------
 procedure TGame.MainLoop;
 var cx,cy,ca,i,j:integer;tmp1,tmpplayer:TCritter;infl:TInfluence_sound;nearenemy:TLiveCreature;
  sear,Sear1,sear2,sear_item:TSearcher;
  item1:TItem;
  mousehint2:string;
 begin;
  inherited;
  inc(cntGameFramesRendered);
  if MapToLoad<>'' then begin;
    Location.EmptyActors;Location.clearground;{ TODO -cTODO : писать в записку и проверять\предупреждать игрока о версии игры }
    if not Location.Load('.'+PathDelim+MapToLoad+PathDelim) then begin;
      SwitchTo(TGameMenu);
    end;
    MapToLoad:='';
    inventory_open:=false;targetselect_open:=false;chat_open:=false;help_open:=false;
    modalwindow_open:=false;debugconsole_open:=false;
    exit;
  end;
  if (lastKey=k_f5) then begin;
    MapToLoad:='.'+PathDelim+'Save00';
    exit;
  end;

  if cntGameFramesRendered<10 then begin;ScrSFXDigitalNoise;exit;end;

 //  debug_los:=true;
   _screen.clear;
   Sear:=TSearcher.create;

 //  ReactKeys;
  player:=sear.Find_CritterById(idPlayer);sear.ResetSearch;
  paused:=false;

  if not(modalwindow_open)
   ///  and not(inventory_open)
   //  and not(targetselect_open)
     and not(chat_open) and not(help_open) //and not(debugconsole_open)
     then
   begin;

      dec(gui_charflash);if gui_charflash<0 then gui_charflash:=0;
      if (lastKey=K_Space)//or ((player as TCharacter).AI_controller.lastchangetime=Location.Time)
       then
        if IsAssignedAndInherited(player,TCharacter) then
         if TCharacter(player).currAction=nil
          then TCharacter(player).DoAction(TAction_Idle)
          else
          // if not (player as TCharacter).currAction.InheritsFrom(TAction_Idle) then
              TCharacter(player).DoAction(nil);

      for i:=1 to 9 do begin;
        tmpplayer:=Location.Find_CritterbyID(('player'+inttostr(i)));
        if IsAssignedAndInherited(tmpplayer,TCharacter) then
         if (not assigned(TCharacter(tmpplayer).currAction))then
          paused:=true;
      end;

     // if paused_lastnewperceptedtime-1=Location.Time then dec(paused_lastnewperceptedtime);
      if not paused then
       for i:=1 to 9 do begin;
        tmpplayer:=Location.Find_CritterbyID(('player'+inttostr(i)));
         if IsAssignedAndInherited(tmpplayer,TCharacter) then
          if (TCharacter(tmpplayer).AI_controller.lastnewperceptedtime=Location.Time)
           and (paused_lastnewperceptedtime<>Location.Time)
           then
            begin;
              for j:=0 to length(TCharacter(tmpplayer).AI_controller.PerceptedCritters)-1 do
               if assigned(TCharacter(tmpplayer).AI_controller.PerceptedCritters[j]) then
                if TCharacter(tmpplayer).AI_controller.PerceptedCritters[j].TimeWhen=(TCharacter(tmpplayer).AI_controller.lastnewperceptedtime) then begin;
                  tmp1:=Location.Find_CritterbyID(TCharacter(tmpplayer).AI_controller.PerceptedCritters[j].id);
                  if assigned(tmp1) then
                   if TCharacter(tmpplayer).tags.GetTag(tagMyFaction)<>TCharacter(tmp1).tags.GetTag(tagMyFaction) then begin;
                       paused:=true;
                       paused_lastnewperceptedtime:=Location.Time;
                       TCharacter(tmpplayer).DoAction(nil);
                       _writeln(tmpplayer.name+' - вижу движение!');
                    end;
                 end;
            end;
       end;

   end
  else paused:=true;

  if paused and(lastKey=K_Space) then gui_charflash:=gui_charflash_defaultvalue;

  if not assigned(self) then exit;

  if (not paused)and (not debugconsole_open) then location.Tick;

  if not assigned(self) then exit;

  player:=sear.Find_CritterById(idPlayer);sear.ResetSearch;

   if not(inventory_open) and not(targetselect_open) and not(chat_open) and not(help_open) then
 //  if not(assigned(curraction)) then
  begin;
   if not(modalwindow_open) and not(debugconsole_open) then DrawGUI;
   // testlos;
   //testpath2;
  end;
//end;

   ReactKeys;if not assigned(self) then exit;

   if (modalwindow_open) or (inventory_open) or (targetselect_open)
    or (chat_open) or (help_open) //and not(debugconsole_open)
   then
     _screen.paintBlock(0,0,maxXscreen,maxYscreen,lyGUIback,BlackRGB,'░'); // ▓▒░

   location.Render;

 {  if not(modalwindow_open) and not(inventory_open) and not(targetselect_open)
        and not(chat_open) and not(help_open) //and not(debugconsole_open)
        then
    begin; }

   ReactMouse;if not assigned(self) then exit;

   if not modalwindow_open then
    if paused then mousehint2:='ПРОБЕЛ - приказ ЖДАТЬ/ДЕЙСТВОВАТЬ САМОСТОЯТЕЛЬНО'
     else mousehint2:='ПРОБЕЛ - ПАУЗА';
   _screen.writeXYRAWithBCK(mousehint2,maxXscreen-1,1,lyGUI,rgbGUI_Hint);

    // end;
   if (not modalwindow_open)// or (inventory_open) or (targetselect_open)
    and (not chat_open) and (not help_open) and (not debugconsole_open)
   then
    DrawGroupsList;

   if paused then
       begin;
        if ScrSFXeffectBlink then begin;
           _screen.writeXYex(' ▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback,BlackRGB);
           _screen.writeXYex(' ▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback,BlackRGB);
           _screen.writeXYex(' ▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback,BlackRGB);
           _screen.writeXY('  ',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI);
           _screen.writeXY('  ПАУЗА ',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUI);     //Нажмите
           _screen.writeXY('  ',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUI);     //ПРОБЕЛ
         end
         else begin;
          {_screen.writeXY('▒       ▒',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback);
          _screen.writeXY('▒       ▒',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback);
          _screen.writeXY('▒       ▒',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback);}
{          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback);
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback);
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback);}
        _screen.writeXYex('▓▓▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-7,lyGUIback,BlackRGB);//▅█     ▒▒▒▒▒▒▒▒▒
        _screen.writeXYex('▓▓▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback,BlackRGB);   //▓   █
        _screen.writeXYex('▓▓▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback,BlackRGB);
        _screen.writeXYex('▓▓▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback,BlackRGB);
        _screen.writeXYex('▓▓▓▓▓▓▓▓▓',trunc(maxxscreen/2)-4,maxyscreen-3,lyGUIback,BlackRGB);
          _screen.writeXY(' ------- ',trunc(maxxscreen/2)-4,maxyscreen-7,lyGUI);//▅█     ▒▒▒▒▒▒▒▒▒
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI);
          _screen.writeXY('| ПАУЗА |',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUI);
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUI);
          _screen.writeXY(' ------- ',trunc(maxxscreen/2)-4,maxyscreen-3,lyGUI);
         end;
       end
       else
        if ScrSFXeffectBlink2 then begin
           _screen.writeXY('▒'+location.BreakScalarTime(location.time,' ')+'▒',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI);
           _screen.writeXYex(strOF('█',length('▒'+location.BreakScalarTime(location.time,' ')+'▒')),trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback,blackrgb);
           //_screen.writeXY('['+location.BreakScalarTime(location.time)+']',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI)
           //_screen.writeXY(' !!! ',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI)
          end
        else begin;
  //       _screen.writeXY('▒▒▒▒▒▒▒',trunc(maxxscreen/2)-4,maxyscreen-7,lyGUIback);//▅█
    //     _screen.writeXY('▒▒▒▒▒▒▒▒▒▒',trunc(maxxscreen/2)-6,maxyscreen-6,lyGUIback);
  //       _screen.writeXY('▒▒▒▒▒▒▒',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback);
         _screen.writeXY(location.BreakScalarTime(location.time,':'),trunc(maxxscreen/2)-3,maxyscreen-6,lyGUI);
         _screen.writeXYex(strOF('▓',length(location.BreakScalarTime(location.time,':'))),trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback,blackrgb);
        end;
       //автобездельничание


   sear.free;
   Maps_Mainloop;
   if (lastkey=k_escape) then
    begin; SwitchTo(TGameMenu); end;
 end;

end.
