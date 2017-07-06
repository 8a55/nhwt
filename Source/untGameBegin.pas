unit untGameEditor;

interface
uses untGame;
type
 TGameEditor=class(TGame)// editor game class
  procedure MainLoop;override;
 end;
implementation
uses untConsole,Windows,untWorld;
var comment:string;
 procedure TGameEditor.MainLoop;
 var cx,cy:integer;
 begin;
  _screen.clear;
  untConsole.frmCon.caption:=' Ground editor nw deep gamma';

  // caption:=Chr(Key)+' '+IntToStr(key);
 if lastKey=vk_f7 then begin;untConsole.frmCon.caption:='loading...';location.LoadLocation('.\Save\Location');untConsole.frmCon.caption:='loaded';end;
 if lastKey=vk_f6 then begin;untConsole.frmCon.caption:='saving...';location.SaveLocation('.\Save\Location');untConsole.frmCon.caption:='saved';end;
 if lastKey=vk_f2 then begin;inc(curgr);comment:='ground: '+wcViewR[curgr]+' '+wcView[curgr];end;
 if lastKey=vk_f1 then begin;dec(curgr);comment:='ground: '+wcViewR[curgr]+' '+wcView[curgr];end;
 if lastKey=38 then dec(py) else
 if lastKey=40 then inc(py) else
 if lastKey=37 then dec(px) else
 if lastKey=39 then inc(px);
//  _screen.content[px,py]:='*';
// _screen.content[px,py]:='*';
// caption:=inttostr(px)+' '+inttostr(py);
 if lastKey=vk_space then begin;comment:='grounded';location.ground[px,py].GroundType:=curgr;end;
 if lastKey=vk_f4 then begin;end;

 _screen.writeXY(comment,0,maxyscreen-1,maxlayers);
 for cx:=0 to maxxscreen do
  for cy:=0 to maxyscreen do
  begin;
   _screen.writeXY(wcViewR[Location.ground[cx,cy].GroundType],cx,cy,lyGround);
   _screen.writeXY('*',px,py,MaxLayers);
  end;
// Canvas.TextOut(2+Canvas.TextWidth('0')*px,2+Canvas.TextHeight('0')*py,'*');
   // Canvas.TextOut(mouse_x,mouse_y,'+');
 end;

end.
