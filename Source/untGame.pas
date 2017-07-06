//- untGame ----------------------------------------------------------------
// Обьект игры.
// maniac

unit untGame;

{$mode objfpc}{$H+}

{$CODEPAGE UTF8}

 {$TYPEINFO ON}
interface
uses untGUI,untActorBase;

var
 gui_charflash_defaultvalue:integer=30;

type
 TGameClass=class of TGameAbstract;

 TGameAbstract=class
 public
  procedure MainLoop;virtual;abstract;
  constructor Create;virtual;abstract;
  destructor Destroy;override;
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
   procedure MainLoop;override;
   procedure DrawGUI;
   procedure ReactKeys;
   procedure SwitchAvatar;
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
 CastleKeysMouse,CastleColors,strutils,FileUtil,untScreenSFX,untAI,untMaps,LazUTF8;

//type
//t2=record a,b:string;end;
var comment:string;test1:boolean;
cAction:TAction;//BUG BUG
//actSpeak:TAction_Speak;
loopnum:integer;
//t1:array of t2;
 rltrsh1,rltrsh2,rltrsh3,rltrsh4,rltrsh5,rltrsh6,rltrsh:real;

destructor TGameAbstract.Destroy;begin;end;

procedure TGameAbstract.SwitchTo(anewgameclass:TGameClass);begin;
  newGame:=anewgameclass.Create;
  Game.destroy;game:=newgame;
  newgame:=nil;self:=nil;
  Log_write('+ switching game class.');exit;
end;


destructor TGame.Destroy;
begin;
 player:=nil;
 location.EmptyActors;
 Menu_game.free;
 Menu_Chat.free;
 Menu_Help.free;
end;

constructor TGame.Create;
 begin;
  Menu_game:=TGUI_menu.create;
  Menu_Chat:=TGUI_menu.create;
  Menu_Help:=TGUI_menu.create;
{  untConsole.frmCon.caption:='location[-] actors[-]';
  location.LoadLocation('.\Save\Location');
  untConsole.frmCon.caption:='location[+] actors[-]';}

//  _writeln('─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┟┞┝├┛┚┙┘┗┖┕└┓┒┑┑┐┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┯┿┾┼┻┺┹┸┷┶┵┴┳┲┱┰╀╁╂╃╅╆╇╈╉╊╋╌╍╎╏╞╞╝╛╚╙╘╗╖╕╔╓╒║═╟╠╢╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╿╾╽╼╻╺╸╷╶╵╴╳╲╱╰╿▀▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▏▞▟▞▝▜▛▚▙▘▗▖▕▔▓▒░▐■■□▢▣▤▥▦▧▨▩▪▫▬▭▮▯▿▾▽▼▻►▹▸▷▶▴△▲▱▰◀◁◂◃◄◅◆◇◈◉○◌◍◎●◟◞◝◜◛◚◘◗◖◕◔◓◒◑◐◠◡◢◤◥◦◨◩◪◫◬◮◯◿◾◽◼◻◹◸◷◶◵◴◳◱◰◰');

//  untConsole.frmCon.caption:='location[+] actors[+]';
//  untConsole.frmCon.caption:='NW deep gamma';
  loopnum:=0;//debug feature
 end;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
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

procedure TGame.MainLoop_help;
begin;
 if (lastkey=k_F1)or(lastkey=k_escape) then begin;help_open:=not(help_open);lastkey:=k_None;end;
 //Menu_help.Clear;
 //Menu_help.AddItemEX('- unselect target -',-2);
 Menu_help.MainLoop('Справка');
end;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
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
     '('+(player as TCharacter).AI_controller.PerceptedCritters[currtargetnum].id+') at '
     +inttostr(dist)+' m',
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
//-----------------------------------------------------------------------------
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
				        begin;Menu_game.AddItemEX((citem as TItem).GetComment+' ('+citem.id+') in '+(citem as TItem).CurrentSlot,citem.id);end
			       else
			          begin;Menu_game.AddItemEX((citem as TItem).GetComment+' ('+citem.id+')',citem.id);end;
		    end
	       else begin;//Menu_game.AddItemEX('<'+(citem as TItem).GetComment+'>',citem.id);
	        end;
	   end
	   else  begin;Menu_game.AddItemEX(citem.name+' ('+citem.id+')',citem.id);end;
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
	   Menu_game.comment:=Menu_game.comment+' [ENTER] - Использовать или одеть [D] - Бросить';
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
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
 procedure TGame.MainLoop_debugconsole;
 var
  currconstring,cx,tmp1,tmp2:integer;
  //aaa:TStringList;
  commandexecuted:boolean;
  tmptile:ttiler;
  rltrsh,maxheigth:real;
  tileindebug,tileindebug2:string;
 begin
  _screen.writeXYex('debugconsole',maxXscreen-14,0,maxLayers,WhiteRGB);
{  if (lastkey=vk_escape) then begin;
   newGame:=TGameMenu.Create;
   Game.Destroy;game:=newgame;
   newgame:=nil;self:=nil;
   Log_write('+ exiting to main menu.');exit;  end;}
  if (lastkey=K_F10)or(lastkey=K_escape) then begin;debugconsole_open:=false;lastkey:=k_None;exit;end;
  if (lastkey=K_BackSpace ) then begin;
    debugconsole_currcommand:=leftstr(debugconsole_currcommand,Length(debugconsole_currcommand)-1);
    lastkey:=k_None;exit;
  end;
  //------ debug commands --------------
  CommandExecuted:=false;
 { debug_los:=true;
  Location.Geom_checkLOS(player.xpos,player.ypos,player.zpos,cmouse_x,cmouse_y,1,rltrsh,rltrsh,rltrsh,maxheigth,false);
  debug_los:=false;}
  if (lastkey=k_Enter) then
  begin
   //if (debugconsole_currcommand='QQQ')or(debugconsole_currcommand='FU') then frmCon.close;
   if (debugconsole_currcommand='HELP') then begin;_writeln('no help for you');CommandExecuted:=true;end;
   if (debugconsole_currcommand='GP') then begin;
     _writeln('GetPhysics : '+
     inttostr(location.GetPhysics(cmouse_x,cmouse_y,0,tmp1,tmp2)));
     ;CommandExecuted:=true;
   end;
   if (debugconsole_currcommand='CMH') then begin;_writeln('CheckMaxHeight : '+FloatToStr(maxheigth)); CommandExecuted:=true;end;
   if commandexecuted then
    debugconsole_currcommand:=''
   else _writeln('i dnt understand your typing');
   lastkey:=k_None;
  end;
  //------ /debug commands --------------
  if lastkey<>k_None then
   debugconsole_currcommand:=debugconsole_currcommand+char(lastkey);
//  frmCon.Caption:=debugconsole_currcommand+' '+inttostr(cmouse_x)+' '+inttostr(cmouse_y);
  _screen.writeXY(' | ',cmouse_x-1,cmouse_y-1,lyGUI);
  _screen.writeXY('- -',cmouse_x-1,cmouse_y,lyGUI);
  _screen.writeXY(' | ',cmouse_x-1,cmouse_y+1,lyGUI);
{  for currconstring:=maxConsoleLines downto 0 do begin
    _screen.writeXY(_screen.consolelines[currconstring],0,maxYscreen-currconstring-10,lyGui);
  end;}
  tmptile:=Location.getgroundEX(cmouse_x,cmouse_y,0);
  if assigned(Location.Critters[tmptile.index])
   then tileindebug:=Location.Critters[tmptile.index].id
   else tileindebug:='-=UNKNOWN=-';
  tileindebug2:='x:'+inttostr(cmouse_x)+' y:'+inttostr(cmouse_y)+' '+Location.getground(cmouse_x,cmouse_y,0)+
  ' physics: '+inttostr(location.GetPhysics(cmouse_x,cmouse_y,0,tmp1,tmp2));
  tileindebug2:='debug id: '+tileindebug+' index['+IntToStr(tmptile.index)+']'+tileindebug2+'CheckMaxHeight : '
    +FloatToStr(location.getgroundEX((cmouse_x),(cmouse_x),0).height);
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
//-----------------------------------------------------------------------------
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
        _screen.writeXY('[Цель: '+targ.name+' at '+inttostr(dist)+' m]'+
        str_tmp1,15,maxyscreen-1,lyGUI)
       end
      else _screen.writeXY('[Цель не выбрана]'+str_tmp1,18,maxyscreen-1,lyGUI);
      s_targ.free;

      with player as TCreature do
        begin;
         _screen.writeXYRA('['+stnNames[stance]+']',maxxscreen-8,maxyscreen,lyGUI);
         _screen.writeXY('[   ]',maxxscreen-7,maxyscreen-2,lyGUI);
         _screen.writeXY('[   ]',maxxscreen-7,maxyscreen-1,lyGUI);
         _screen.writeXY('[   ]',maxxscreen-7,maxyscreen-0,lyGUI);
         _screen.drawSprite('.',(maxxscreen-5+1.3*cos((90-glance)/57)),(maxyscreen-1-1.3*sin((90-glance)/57)),lyGUI,GreenRGB);
         _screen.writeXY('ОЗ: '+inttostr(Sklmtrx_GetParamRes(prmCurrHP))+'/'+
         inttostr(Sklmtrx_GetParamRes(prmBaseHP))+' ',0,maxyscreen,lyGUI);
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
          _screen.writeXY('['+(hand as TItem).GetComment+'] '+
	      '['+str_tmp1+']',13,maxyscreen,lyGUI)//(hand as TItem).GetCurrAction.GetComment
        end

       else _screen.writeXY('[Нет] ',13,maxyscreen,lyGUI);
       _screen.writeXY('Время: '+location.BreakScalarTime(location.time)+' ',0,maxyscreen-1,lyGUI);

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
              if (gui_charflash>0) and ((tmpCritter as TCreature).curraction=nil)and (tmpCritter.id<>idPLayer) then begin
//                 _screen.writeXYex(strOF('▒', UTF8Length(str_tmp1)),0,maxyscreen-2-i,lyGuiBack,greenrgb);
                 str_tmp1:=str_tmp1+' <<Жду приказа!>>';
                end;

               //else
               _screen.writeXYex(str_tmp1,0,maxyscreen-2-i,lyGUI,greenrgb);
           end;
        end;
         _screen.writeXY('N  КомГрп',0,maxyscreen-3-lastgroup,lyGUI);
       //КЛ1725  КЛ715  КЛ832  КЛ1892  КЛ1182

  for cx:=0 to 15 do
   if maxconsolelines-cx>0 then begin;
     _screen.writeXY(_screen.consolelines[maxconsolelines-cx],0,15-cx-2,lyGui);
     _screen.writeXYex(strOF('█',length(_screen.consolelines[maxconsolelines-cx])),0,15-cx-2,lyGuiBack,BlackRGB);
   end;

   s3.free;
   sear.free;
  end;

 function cmousecheckselected:integer;
 var i:integer;
 begin;result:=0;
  for i:=maxLayers downto 0 do begin;
    if _screen.content.[cmouse_x,cmouse_y,i]<>'' then begin;result:=i;exit;end;
  end;
 end;

 procedure TGame.SwitchAvatar;
 var i,j:integer;dist,moveto_x,moveto_y:real;chklosend:point;
  tmpplayer:tcritter;
  tmpstr:string;
  sear:TSearcher;
  cAction:TAction;
 label fck,chklosend_stop;
 begin;
  sear:=TSearcher.create; sear.ResetSearch;
  if assigned(Player) then
   if (player as TLiveCreature).Sklmtrx_GetParamRes(prmCurrHP) >=0 then
   begin;

      if (cmouse_x<24)and(cmouse_y=maxyscreen-2-i)and(mouse_button=mouseLeft)then j:=i;
        // tmpplayer:=Location.Find_CritterbyID('player'+inttostr(i));
      tmpplayer:=sear.Find_CritterByPosEx(cmouse_x,cmouse_y,0,1);

      //Выбрать группу мышью
      if assigned(tmpplayer)then begin;
        {  _writeln(' cmx'+inttostr(cmouse_x)+' cmy'+inttostr(cmouse_y)+
               ' plyx'+floattostr(tmpplayer.xpos)+' plyx'+floattostr(tmpplayer.ypos));}
           for i:=1 to 9 do
            if  (tmpplayer.id=('player'+inttostr(i))) then
             if(round(tmpplayer.xpos)=cmouse_x)and(round(tmpplayer.ypos)=cmouse_y)then
              if(mouse_button=mouseLeft)
                then begin;j:=i;mouse_button:=mouseNone;
                   gui_charflash:=gui_charflash_defaultvalue;
                  goto fck;end
                else begin;
                 tmpstr:='Выбрать группу '+tmpplayer.name+' ';
   //              _screen.drawSprite('[ ]',cmouse_x-1,cmouse_y,lyDEBUG,greenrgb);
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
                   tmpstr:='Выбрать цель: '+tmpplayer.name+' дист '+floattostr(dist)+'м.';
  //                 _screen.drawSprite('+',cmouse_x,cmouse_y,lyDEBUG,redrgb);
                  end;
         end;
      fck:
  //    _screen.writeXY(tmpstr,trunc(maxxscreen/2)-7,maxyscreen-4,lyGUIback);
      tmpplayer:=Location.Find_CritterbyID( idPlayer);

      { for i:=0 to round(Location.Geom_calcdist(tmpplayer.xpos,tmpplayer.ypos,0,cmouse_x,cmouse_y,0)) do
       begin;
        chklosend:=SolveLine(tmpplayer.xpos,tmpplayer.ypos,cmouse_x,cmouse_y,i);
        if location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,chklosend.x,chklosend.y,0) then goto chklosend_stop;
       end;
      chklosend:=SolveLine(tmpplayer.xpos,tmpplayer.ypos,cmouse_x,cmouse_y,i-1);
      chklosend_stop:ScrSFXDrawline(tmpplayer.xpos,tmpplayer.ypos,chklosend.x,chklosend.y,grayrgb);
      }

     debug_los:=true;
      Location.Geom_checkLOS(tmpplayer.xpos,tmpplayer.ypos,0,cmouse_x,cmouse_y,0,moveto_x,moveto_y,rltrsh5,rltrsh5,true);

      if (cmouse_x<>moveto_x)or(cmouse_y<>moveto_y) then begin;
          moveto_x:=cmouse_x;
          moveto_y:=cmouse_y;
      end;

      if tmpstr='' then begin;
        tmpstr:='Идти к';
 //       _screen.drawSprite('- -',moveto_x-1,moveto_y,0,grayrgb);
       end;
//        _screen.drawSprite(tmpstr,cmouse_x+1,cmouse_y-1,lyGUI,grayrgb);
        _screen.writeXYex(tmpstr,cmouse_x+1,cmouse_y-1,lyGUI,grayrgb);
       _screen.writeXYex(strOF('█',UTF8Length(tmpstr)),cmouse_x+1,cmouse_y-1,lyGuiBack,BlackRGB);
//      _screen.writeXY(tmpstr,trunc(maxxscreen/2)-10,maxyscreen-9,lyGUI);
//      _screen.writeXYex(strOF('█',length(tmpstr)),trunc(maxxscreen/2)-10,maxyscreen-9,lyGuiBack,BlackRGB);

      if (mouse_button=mouseLeft) then
       if (cmousecheckselected<lyGUIback) then begin;{ TODO -cBUG : must be checked after drawing the gui }
         cAction:=(player as TCharacter).DoAction(TAction_WalkToCoord);
         if assigned(caction) then begin
          (cAction as TAction_WalkToCoord).walkto_x:=moveto_x;
          (cAction as TAction_WalkToCoord).walkto_y:=moveto_y;
          (cAction as TAction_WalkToCoord).walkfrom_x:=player.xpos;
          (cAction as TAction_WalkToCoord).walkfrom_y:=player.ypos;
         end;
         gui_charflash:=gui_charflash_defaultvalue;
       end;
      debug_los:=false;
  end;

  if ((j=1) or (lastkey=K_1))and assigned(Location.Find_CritterbyID('player1'))  then idPlayer:='player1';
  if ((j=2) or (lastkey=K_2))and assigned(Location.Find_CritterbyID('player2'))  then idPlayer:='player2';
  if ((j=3) or (lastkey=K_3))and assigned(Location.Find_CritterbyID('player3'))  then idPlayer:='player3';
  if ((j=4) or (lastkey=K_4))and assigned(Location.Find_CritterbyID('player4'))  then idPlayer:='player4';
  if ((j=5) or (lastkey=K_5))and assigned(Location.Find_CritterbyID('player5'))  then idPlayer:='player5';
  if ((j=6) or (lastkey=K_6))and assigned(Location.Find_CritterbyID('player6'))  then idPlayer:='player6';
  if ((j=7) or (lastkey=K_7))and assigned(Location.Find_CritterbyID('player7'))  then idPlayer:='player7';
  if ((j=8) or (lastkey=K_8))and assigned(Location.Find_CritterbyID('player8'))  then idPlayer:='player8';
  if ((j=9) or (lastkey=K_9))and assigned(Location.Find_CritterbyID('player9'))  then idPlayer:='player9';
  //if ((j=0) or (lastkey=K_0))and assigned(Location.Find_CritterbyID('player0'))  then idPlayer:='player0';
  sear.Destroy;
 end;

function TGame.GetHandItem(aCitter:tcritter):tcritter;
var hnd:tcritter; sear2:TSearcher; begin result:=nil;
	 sear2:=TSearcher.create; sear2.ResetSearch;
	 hnd:=sear2.Find_ItemByslot(aCitter.id,sltPonyTelekineticField);
	 if not(assigned(hnd)) then
	  begin; sear2.ResetSearch;hnd:=sear2.Find_ItemByslot(aCitter.id,sltPonyTelekineticFields);end;
	 if assigned(hnd) then result:=hnd as TItem;
	 sear2.free;
end;

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
  if chat_open then begin;MainLoop_Chat;exit;end;
  if targetselect_open then begin;MainLoop_targetselect;exit;end;
  if help_open then begin;MainLoop_help;exit;end;
  if debugconsole_open then begin;MainLoop_debugconsole;exit;end;
  if modalwindow_open then begin;MainLoop_modalwindow;exit;end;

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
     Menu_help.AddItemEX('[СТРЕЛКИ] смотреть в разные стороны и ходить',-2);
	 if (lastKey=k_Up) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkForward);gui_charflash:=gui_charflash_defaultvalue;end;
	 if (lastKey=k_Down) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkBackward);gui_charflash:=gui_charflash_defaultvalue;end;
	 if (lastKey=k_Left) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_RotateLeft);gui_charflash:=gui_charflash_defaultvalue;end;
	 if (lastKey=K_Right) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_RotateRight);gui_charflash:=gui_charflash_defaultvalue;end;

     Menu_help.AddItemEX('[<]/[>] ходить боком',-2);
     if (lastKey=K_Period) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkStrafeRight);gui_charflash:=gui_charflash_defaultvalue;end;
     if (lastKey=K_Comma) then
	   begin;cAction:=(player as TCharacter).DoAction(TAction_WalkStrafeLeft);gui_charflash:=gui_charflash_defaultvalue;end;

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
         act_Speak.text:=agrNames[tmpAggrLevelActual];
         (player.DoInfluence(TInfluence_Sound_Talk_Speech) as TInfluence_Sound_Talk_Speech).text:=agrNames[tmpAggrLevelActual];
         ((player as TCharacter).AI_controller as TAI_ControllerUser).AggressionLevel:=tmpAggrLevelActual;
         gui_charflash:=gui_charflash_defaultvalue;
         mouse_button:=mouseNone;
       end;

       if gui_AggrMenuOpen then
        for i:=agrMin to agrMax do
         if maxyscreen-1-cmouse_y=i then //i=tmpAggrLevelActual then
          _screen.writeXYRA('['+agrNames[i]+']',maxxscreen-8,maxyscreen-1-i,lyGUI)
          else _screen.writeXYRA(' '+agrNames[i]+' ',maxxscreen-8,maxyscreen-1-i,lyGUI)
        else
         begin;
          tmpAggrLevelActual:=((player as TCharacter).AI_controller as TAI_ControllerUser).AggressionLevel;
         _screen.writeXYRA('['+agrNames[tmpAggrLevelActual]+']',maxxscreen-8,maxyscreen-1,lyGUI);
         end;
    end;

  Menu_help.AddItemEX('[ПРОБЕЛ] Остановить время/Приказ ЖДАТЬ',-2);
  Menu_help.AddItemEX('          время запускаеться автоматически',-2);
  Menu_help.AddItemEX('          если все КомГрп имеют приказы',-2);

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

  SwitchAvatar;

 end;

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

 procedure TGame.MainLoop;
 var cx,cy,ca,i,j:integer;tmp1,tmpplayer:TCritter;infl:TInfluence_sound;nearenemy:TLiveCreature;
  sear,Sear1,sear2,sear_item:TSearcher;
  //cAction:TAction;
  item1:TItem;
 begin;inc(cntGameFramesRendered);

  if MapToLoad<>'' then begin;
    Location.EmptyActors;Location.clearground;Location.Load('.'+PathDelim+MapToLoad+PathDelim);
    MapToLoad:='';
    inventory_open:=false;targetselect_open:=false;chat_open:=false;help_open:=false;
    modalwindow_open:=false;debugconsole_open:=false;
    exit;
  end;
  if (lastKey=k_f5) then begin;
    Location.EmptyActors;Location.clearground;Location.Load('.'+PathDelim+'Save00'+PathDelim);
    exit;
  end;

  if cntGameFramesRendered<3 then begin;ScrSFXDigitalNoise;exit;end;

 //  debug_los:=true;
   _screen.clear;
   Sear:=TSearcher.create;

 //  ReactKeys;
  player:=sear.Find_CritterById(idPlayer);sear.ResetSearch;
  paused:=false;

  if not(modalwindow_open) and not(inventory_open) and not(targetselect_open)
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
                  if TCharacter(tmpplayer).tags.GetTag(tagMyFaction)<>TCharacter(tmp1).tags.GetTag(tagMyFaction) then begin;
                      paused:=true;
                      paused_lastnewperceptedtime:=Location.Time;
                      TCharacter(tmpplayer).DoAction(nil);
                      _writeln(tmpplayer.name+' наблюдаю движение!');
                   end;
                 end;
            end;
       end;

   end
   else paused:=true;

  if paused and(lastKey=K_Space) then gui_charflash:=gui_charflash_defaultvalue;

  if not assigned(self) then exit;

  if not paused then location.Tick;

  if not assigned(self) then exit;

  player:=sear.Find_CritterById(idPlayer);sear.ResetSearch;

  {  if (player=nil) then
  begin;
	newGame:=TGameMenu.Create;
	Game.Destroy;game:=newgame;
	newgame:=nil;self:=nil;
	Log_write('PANIC - player = nil');exit;
  end;}

{    if assigned(player) then
     with Player as TCharacter do
      begin;
       if assigned(currAction) then
        // if currAction.ClassType<>TAction_Idle then
           begin;
            // if currAction.priority>apRecoil;
            //_write('MainLoop player action: '+currAction.ClassName);
           // debug_physics:=true;
            location.Tick;
           end
           else begin;
            paused:=true;
           end;
       {  else begin;
            paused:=true;
         end;}
 }
       //  self.priority:=apRecoil; apRecoil

      if not(inventory_open) and not(targetselect_open) and not(chat_open) and not(help_open) then
      //  if not(assigned(curraction)) then
       begin;
        if not(modalwindow_open) and not(debugconsole_open) then DrawGUI;
        // testlos;
        //testpath2;
       end;
    // end;

   ReactKeys;if not assigned(self) then exit;

   if not(modalwindow_open) and not(inventory_open) and not(targetselect_open)
        and not(chat_open) and not(help_open) //and not(debugconsole_open)
        then
    begin;

      location.Render;

      if paused then
       begin;
        if ScrSFXeffectBlink then begin;
           _screen.writeXYex('█████████',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback,BlackRGB);
           _screen.writeXYex('█████████',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback,BlackRGB);
           _screen.writeXYex('█████████',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback,BlackRGB);
           _screen.writeXY(' ПАУЗА ',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI);
           _screen.writeXY(' Нажмите ',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUI);
           _screen.writeXY(' ПРОБЕЛ ',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUI);
         end
         else begin;
  {        _screen.writeXY('▒▒▒▒▒▒▒▒▒',trunc(maxxscreen/2)-4,maxyscreen-7,lyGUIback);//▅█     ▒▒▒▒▒▒▒▒▒
          _screen.writeXY('▒       ▒',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback);
          _screen.writeXY('▒       ▒',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback);
          _screen.writeXY('▒       ▒',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback);
          _screen.writeXY('▒▒▒▒▒▒▒▒▒',trunc(maxxscreen/2)-4,maxyscreen-3,lyGUIback);
   }
          _screen.writeXY(' -------',trunc(maxxscreen/2)-4,maxyscreen-7,lyGUIback);//▅█     ▒▒▒▒▒▒▒▒▒
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback);
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUIback);
          _screen.writeXY('|       |',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUIback);
          _screen.writeXY(' ------- ',trunc(maxxscreen/2)-4,maxyscreen-3,lyGUIback);
          _screen.writeXYex('███████',trunc(maxxscreen/2)-3,maxyscreen-6,lyGUIback,BlackRGB);
          _screen.writeXYex('███████',trunc(maxxscreen/2)-3,maxyscreen-5,lyGUIback,BlackRGB);
          _screen.writeXYex('███████',trunc(maxxscreen/2)-3,maxyscreen-4,lyGUIback,BlackRGB);
          _screen.writeXY(' ПАУЗА ',trunc(maxxscreen/2)-4,maxyscreen-6,lyGUI);
          _screen.writeXY(' Нажмите ',trunc(maxxscreen/2)-4,maxyscreen-5,lyGUI);
          _screen.writeXY(' ПРОБЕЛ ',trunc(maxxscreen/2)-4,maxyscreen-4,lyGUI);
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
         _screen.writeXYex(strOF('█',length(location.BreakScalarTime(location.time,':'))),trunc(maxxscreen/2)-4,maxyscreen-6,lyGUIback,blackrgb);
        end;
       //автобездельничание
     end;
   sear.free;
   Maps_Mainloop;
   if (lastkey=k_escape) then begin; SwitchTo(TGameMenu); end;
 end;

end.
