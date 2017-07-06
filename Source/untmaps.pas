unit untMaps;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untSerialize;
// type

procedure Maps_Mainloop;
procedure Maps_SerializeData;

var
 Map00_over,Map00_briefingreaded,
 Game_Over:boolean;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation
uses untGame,untWorld,untConsole,sysutils,untGameMenu,untLog;
{$I untActorBaseConst.pas}

procedure Maps_Mainloop_EveryMap;
var player:tcritter;
 hp:integer;
begin;
 player:=Location.Find_CritterbyID('player1');
 if assigned(player) then
  HP:=(player as TCreature).Sklmtrx_GetParamRes(prmCurrHP) else hp:=0;
 if (HP<=0)
  //(not assigned(Location.Find_CritterbyID('player1')))
  and ((game as tgame).modalwindow_open=false) and (not Game_Over) then begin;
  (game as tgame).modalwindow_text:=
      'Вы умерли.'+LineEnding;
  (game as tgame).modalwindow_open:=true;
  Game_Over:=true;
 end;
 if Game_Over and ((game as tgame).modalwindow_open=false) then begin;
  game.SwitchTo(TGameMenu);
  Log_write('+ exiting to main menu, because player non exists');
 end;
end;

procedure Maps_Mainloop_Map00;
var i:integer;fck:boolean;
begin;
 if ((game as tgame).cntGameFramesRendered=5)and(not Map00_briefingreaded) then begin;
    (game as tgame).modalwindow_text:=
     'Здраствуйте, 2197. Мы в курсе ситуации складывающейся с вашим заданием.'+
     ' Решение руководства Отдела Вмешательства, отправить вас внепланово'+
     ', буду откровенен, чреповато для нас всех. Но отчаяные времена, требуют'+
     ' отчаяных действий, совершаемых горячими головами.'+
     'Мы зарезервировали вам виртуальный тренажер для освежения навыков.'+
     ' Там загружена традиционная для курсов ближнего боя карта.'+
     LineEnding;
    (game as tgame).modalwindow_open:=true;
    Map00_briefingreaded:=true;
   end;

 if (game as tgame).cntGameFramesRendered>50 then
  begin;
  fck:=true;
  for i:=3 to 8 do
   if assigned(Location.Find_CritterbyID('xplayer'+inttostr(i))) then
     fck:=false;

  if fck and not Map00_over then
    begin;
    (game as tgame).modalwindow_text:=
     'Вы успешно прошли задачу на тренажере'+
     LineEnding;
    (game as tgame).modalwindow_open:=true;
    Map00_over:=true;
    end;
  end;
end;

procedure Maps_SerializeData_Map00;
begin;
 Map00_over:=Location.SerializeFieldB('Map00_over',Map00_over);
 Map00_briefingreaded:=Location.SerializeFieldB('Map00_briefingreaded',Map00_briefingreaded);
end;

procedure Maps_Mainloop;
begin;
 if Location.MapName='Map00' then Maps_Mainloop_Map00;
 Maps_Mainloop_EveryMap;
end;

procedure Maps_SerializeData;
begin;
 if Location.MapName='Map00' then Maps_SerializeData_Map00;
 Game_over:=Location.SerializeFieldB('Game_over',Game_over);
end;

end.
