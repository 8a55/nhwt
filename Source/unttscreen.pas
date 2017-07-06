//- untTScreen ----------------------------------------------------------------
// Логика эмулятора терминала

unit untTScreen;

{$mode objfpc}{$H+}

{$CODEPAGE UTF8}

{$TYPEINFO ON}

interface

uses

{$IFnDEF FPC}
  Windows,
{$ELSE}
  //LCLIntf, LCLType, LMessages,
{$ENDIF}
 // Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,  ExtCtrls, //DXDraws, DXClass,
//Menus, StdCtrls, Types;
 CastleColors,
 LazUTF8
 ;

const
    maxConsoleLines=999;
var
    maxXscreen:integer=80;
    maxYscreen:integer=50;
    maxLayers:integer=8;
    //слои буфера эмуляции терминала
    lyGround:integer=1;//земля
    lyGUIback:integer=3;//подслойка интерфейса, больше чем z размер локаций
    lyGUI:integer=4;//интерфейс
    lyGUI2:integer=5;//интерфейс
    lyMouse:integer=6;//курсор мыши итд
    lyDEBUG:integer=7;//отладочный вывод

type

    T_screen_color  = array of array of array of TCastleColorRGB;// буфер эмулятора терминала
    T_screen_content  = array of array of array of String;

    TSprite = record
     aStr:string;px,py,pl:real;aColor:TCastleColorRGB;
    end;

    T_screen=class
    public
         color:T_screen_color;
         content:T_screen_content;
         Sprites:array of TSprite;
         consolelines:array[0..maxConsoleLines] of string;
         cur_x,cur_y:integer;
         procedure SetSize(aNewmaxXscreen,aNewmaxYscreen,aNewmazLayers:integer);
         constructor Create;
         procedure Clear;//очистка буферов
         procedure pos(x,y:integer);//уст. позиции курсора
         procedure write(astr:String);//вывод в буфер
         procedure writeLN(astr:String);
         procedure writeXY(astr:String;px,py,pl:integer);
         procedure writeXYex(astr:String;px,py,pl:integer;aColor:TCastleColorRGB);
         procedure writeXYRA(astr:String;px,py,pl:integer);
//         procedure writeBlockEx(astr:String;px,py,pw,ph,pl:integer;aColor:TCastleColorRGB);
         procedure writeBlockEx(astr:String;px,py,pw,ph,pl:integer;aColor:TCastleColorRGB;LastPrintedSymbolNum:integer=-1;cursor:string='');
         procedure drawSprite(aStr:string;px,py,pl:real;aColor:TCastleColorRGB);//вывод спрайта в буфер
         procedure clearSprites;//очистка буфера спрайтов
    end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation

procedure T_screen.drawSprite(aStr:string;px,py,pl:real;aColor:TCastleColorRGB);
 begin;
  SetLength(Sprites,Length(Sprites)+1);
  Sprites[High(Sprites)].aStr:=aStr;
  Sprites[High(Sprites)].px:=px;
  Sprites[High(Sprites)].py:=py;
  Sprites[High(Sprites)].pl:=pl;
  Sprites[High(Sprites)].aColor:=aColor;
 end;

procedure T_screen.clearSprites;
 begin;
  SetLength(Sprites,0);
 end;

procedure T_screen.SetSize(aNewmaxXscreen,aNewmaxYscreen,aNewmazLayers:integer);
 begin;
	 SetLength(color, aNewmaxXscreen+1, aNewmaxYscreen+1,aNewmazLayers+1);
	 SetLength(content, aNewmaxXscreen+1, aNewmaxYscreen+1,aNewmazLayers+1);
	 maxXscreen:=aNewmaxXscreen;
	 maxYscreen:=aNewmaxYscreen;
	 maxLayers:=aNewmazLayers;
 end;


constructor T_screen.Create;
 begin
  SetSize(maxXscreen, maxYscreen,maxLayers);
 end;

procedure T_screen.pos(x,y:integer);
 begin;
     if x<0 then x:=0;
     if x>maxxscreen then x:=maxxscreen;
     if y<0 then y:=0;
     if y>maxxscreen then y:=maxyscreen;
     cur_x:=x;cur_y:=y;
 end;

procedure T_screen.write(astr:String);
var x,y,i:integer;a:string;
 begin;
      writeXY(astr,cur_x,cur_y,maxLayers);
      Pos(cur_x+UTF8Length(astr),cur_y);
 end;

procedure T_screen.writeLN(astr:String);
 var x,y,i:integer;a:string;
 begin;
      writeXY(astr,cur_x,cur_y,maxLayers);
      Pos(0,cur_y+1);
 end;

procedure T_screen.clear;
 var cx,cy,cl:integer;
 begin;
  for cx:=0 to maxxscreen do for cy:=0 to maxyscreen do for cl:=0 to maxlayers do
   begin;
    color[cx,cy,cl]:=GreenRGB;
    content[cx,cy,cl]:='';
   end;
  pos(0,0);
end;

procedure T_screen.writeBlockEx(astr:String;px,py,pw,ph,pl:integer;aColor:TCastleColorRGB;LastPrintedSymbolNum:integer=-1;cursor:string='');
var x,y,i:integer;//:string;
label nextline,nextchar;
begin;
{ i:=1;
 for y:=py to py+ph do
  for x:=px to px+pw do
  if (i<UTF8Length(astr)+1)and(x<maxxscreen)and(y<maxyscreen)and(x>0)and(y>0) then
  begin;
   if UTF8Copy(astr,i,1)=LineEnding then
   content[x,y,pl]:=UTF8Copy(astr,i,1);//astr[1]+astr[2];
   color[x,y,pl]:=aColor;
   inc(i);
  end;}

 i:=1;
 for y:=py to py+ph do
//  for x:=px to px+pw do
  begin;
   x:=px;
   nextchar:
	 if (i<UTF8Length(astr)+1)and(x<maxxscreen)and(y<maxyscreen)and(x>0)and(y>0) then
  	 begin;
	    content[x,y,pl]:=UTF8Copy(astr,i,1);//astr[1]+astr[2];
	    color[x,y,pl]:=aColor;
  	  inc(i);
      if (i>LastPrintedSymbolNum)and(LastPrintedSymbolNum<>-1) then begin;
       if cursor<>'' then begin;
         content[x+1,y,pl]:=cursor;
         color[x,y,pl]:=aColor;
        end;
       exit;
      end;
     end;
   {$ifdef Windows}
     if (UTF8Copy(astr,i,1)=LineEnding[1])and(UTF8Copy(astr,i+1,1)=LineEnding[2]) then begin;i:=i+2;goto nextline;end;
   {$endif}
   {$ifdef Linux}
     if (UTF8Copy(astr,i,1)=#10) then begin;i:=i+2;goto nextline;end;
   {$endif}
   inc(x);
   if x<px+pw then goto nextchar;
   nextline:
  end;

end;

procedure T_screen.writeXYex(astr:String;px,py,pl:integer;aColor:TCastleColorRGB);
var x,y,i:integer;a:String;
 begin;
  for i:=1 to UTF8Length(astr) do
  if (px+i-1>=0)and(px+i-1<=maxxscreen)and(py>=0)and(py<=maxyscreen)
   and(pl>=0)and(pl<=maxLayers)then
  begin;
   a:=UTF8Copy(astr,i,1);//astr[i]+astr[i+1];
   content[px+i-1,py,pl]:=a;
   color[px+i-1,py,pl]:=aColor;
  // if aDebug<>'' then  color[px+i-1,py,pl]:=aColor;
  end;
 end;

procedure T_screen.writeXY(astr:String;px,py,pl:integer);
var x,y,i:integer;a:String;{ TODO : multyline string support via sLineBreak detecting }
 begin;
  for i:=1 to UTF8Length(astr) do
   if (px+i-1>=0)and(px+i-1<=maxxscreen)and(py>=0)and(py<=maxyscreen)
    //then content[px+i-1,py,pl]:=astr[i];
    then
      begin;
       a:=UTF8Copy(astr,i,1);//astr[i]+astr[i+1];
       content[px+i-1,py,pl]:=a;
      end;
//  Log_write(astr);
 end;

procedure T_screen.writeXYRA(astr:String;px,py,pl:integer); //BUGBUG line part disapearing near screen border,tltf
var x,y,i:integer;a:String;{ TODO : multyline string support via sLineBreak detecting }
 begin;
  for i:=0 to UTF8Length(astr) do
   if (px+i>=0)and(px-i<=maxxscreen)and(py>=0)and(py<=maxyscreen)
    //then content[px+i-1,py,pl]:=astr[i];
    then
      begin;
       a:=UTF8Copy(astr,UTF8Length(astr)-i,1);//astr[i]+astr[i+1];
       content[px-i,py,pl]:=a;
      end;
//  Log_write(astr);
 end;

end.

