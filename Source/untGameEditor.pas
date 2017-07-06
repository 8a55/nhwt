unit untGameEditor;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

 {$TYPEINFO ON}
interface
uses untGame;
type
 TGameEditor=class(TGameAbstract)// editor game class
  procedure MainLoop;override;
  constructor Create;override;
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
  untConsole,untWorld,untGameMenu,SysUtils,
  //Graphics,
  untTScreen,
  CastleKeysMouse
  ;
var comment:string; py,px,pz:integer;

 constructor TGameEditor.Create;
 begin;
 //


 end;

 procedure TGameEditor.MainLoop;
 var cx,cy,cz,tx,ty:integer;
 begin;
  _screen.clear;
 if (lastkey=k_escape) then
  begin;newGame:=TGameMenu.Create;Game.Destroy;game:=newgame;newgame:=nil;
  game.mainloop;
  //untconsole.frmCon.Repaint;
  end;
  //untConsole.frmCon.caption:=' Editor support is broken!';

  // caption:=Chr(Key)+' '+IntToStr(key);
 if lastKey=k_f7 then begin;_writeln('loading...');location.LoadActors('.\Save\Location');_writeln('loaded');end;
 if lastKey=k_f6 then begin;location.SaveActors('.\SaveD\Location');end;
 if lastKey=k_f9 then begin;location.EmptyActors;end;
// if lastKey=k_f2 then begin;if curgr<maxgroundtypes then inc(curgr);comment:='ground: '+wcViewR[curgr]+' '+wcView[curgr];end;
 //if lastKey=k_f1 then begin;if curgr>0 then dec(curgr);comment:='ground: '+wcViewR[curgr]+' '+wcView[curgr];end;
 if lastKey=k_up then dec(py) else
 if lastKey=k_down then inc(py) else
 if lastKey=k_left then dec(px) else
 if lastKey=k_right then inc(px);

 if lastKey=K_PageDown then inc(pz);
 if lastKey=K_PageUp then dec(pz);
 if pz>maxLocationZSize then pz:=maxLocationZSize;
 if pz<0 then pz:=0;

{ if lastKey=vk_space then begin;comment:='grounded';location.ground[px,py,pz].GroundType:=curgr;inc(px);end;
 if lastKey=ord('X') then begin;comment:='grounded';
  for tx:=px to maxLocationXSize-1 do begin;
  if location.ground[tx,py,pz].GroundType<>location.ground[tx+1,py,pz].GroundType then break;
  location.ground[tx,py,pz].GroundType:=curgr;end;
 end;
 if lastKey=ord('Z') then begin;comment:='grounded';
 location.ground[px,py,pz].GroundType:=curgr;
 location.ground[px+1,py,pz].GroundType:=curgr;
 location.ground[px-1,py,pz].GroundType:=curgr;
 location.ground[px,py+1,pz].GroundType:=curgr;
 location.ground[px,py-1,pz].GroundType:=curgr;
 location.ground[px+1,py+1,pz].GroundType:=curgr;
 location.ground[px-1,py-1,pz].GroundType:=curgr;
 location.ground[px+1,py+1,pz].GroundType:=curgr;
 location.ground[px-1,py-1,pz].GroundType:=curgr;
 end;
 if lastKey=vk_f4 then begin;end; }


 for cz:=0 to maxLocationZSize do
  for cx:=0 to maxxscreen do
   for cy:=0 to maxyscreen do
   begin;
  // if Location.ground[cx,cy,cz].GroundType<>wcNothing then
  // _screen.writeXY(wcViewR[Location.ground[cx,cy,cz].GroundType],cx,cy,lyGround);
   end;

   _screen.clear;
    location.Render;

   _screen.writeXY(comment+' cursor position: '+inttostr(px)+' '+inttostr(py)+' ly: '+inttostr(pz),0,maxyscreen-1,maxlayers);
 //  _screen.writeXYex('`',px,py,MaxLayers,ColorChangeBrightness(clGreen,round(random(90)/90)+0.01));
end;

end.
