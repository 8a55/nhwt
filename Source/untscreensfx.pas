//- untScreenSFX ----------------------------------------------------------------
// Экранные эффекты
// 8а55

unit untScreenSFX;

{$mode objfpc}{$H+}

interface

uses
 Classes, SysUtils,CastleColors,untUtils;

procedure ScrSFXDigitalNoise;//шум символами псевдографики
procedure ScrSFXPointNoise;//наложение символа ░ на весь экран
procedure ScrSFXDrawline(ax,ay,ex,ey:real;acolor:TCastleColorRGB);//отрисовка линии

var
  ScrSFXeffectBlink,ScrSFXeffectBlink2:boolean;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation
uses untTScreen,untConsole,untWorld;

 procedure ScrSFXDigitalNoise;
 var cx,cy:integer;tmprnd:real;
 begin;
  for cx:=0 to maxxscreen do
   for cy:=0 to maxyscreen do
    begin;
      tmprnd:=random();
      if (tmprnd>0)and(tmprnd<0.25) then _screen.writeXYex('▒',cx,cy,lyMouse,grayrgb);//▒▒█▨▧▩▪░▒▓
      if (tmprnd>0.25)and(tmprnd<0.5) then _screen.writeXYex('▓',cx,cy,lyMouse,grayrgb);//▒▒
      if (tmprnd>0.5)and(tmprnd<0.75) then _screen.writeXYex('░',cx,cy,lyMouse,grayrgb);//▒▒
      if (tmprnd>0.75)and(tmprnd<0.99) then _screen.writeXYex('█',cx,cy,lyMouse,grayrgb);//▒▒
     end;
 end;
 //-----------------------------------------------------------------------------
 procedure ScrSFXPointNoise;
 var cx,cy:integer;tmprnd:real;
 begin;
  for cx:=0 to maxxscreen do
   for cy:=0 to maxyscreen do
    begin;
     _screen.writeXYex('░',cx,cy,lyMouse,grayrgb);//▒▒█▨▧▩▪░▒▓
    end;
 end;
 //-----------------------------------------------------------------------------
 procedure ScrSFXDrawline(ax,ay,ex,ey:real;acolor:TCastleColorRGB);
 var  tmpcolor2:TCastleColorRGB = ( 0.2 , 0.2 , 0.2);
  tmpcolor3:TCastleColorRGB = ( 0.8, 0.8 , 0.8);
  tmpcolor:TCastleColorRGB = ( 0.9, 0 , 0);
  i,j,k:integer;
  dist,angl:real;
  currpoint:tPoint;
 begin;
 //_screen.drawSprite(FloatToStr(glance),(xpos-2),(ypos-2),lyGUI2,tmpcolor);
 //_screen.drawSprite('.',(xpos+2*cos((90-glance)/57)),(ypos-2*sin((90-glance)/57)),lyGUI,tmpcolor);
 // angl:=arctan((ay-ey)/(ax-ex));
  for i:=0 to round(Location.Geom_calcdist(ax,ay,0,ex,ey,0)) do begin;
   for j:=0 to 3 do tmpcolor[j]:=(20-i)/20-0.1;
   dist:=1;//0.05;//Random();//4;
   currpoint:=SolveLine(ax,ay,ex,ey,i);
 //   for k:=0 to 3 do
   // if (Game as TGame).paused then begin;
 //     _screen.drawSprite('.',(xpos+dist*i*cos((90-glance-angl-k)/57)),(ypos-dist*i*sin((90-glance-angl-k)/57)),lyGUI2,tmpcolor);
 //     _screen.drawSprite('.',(xpos+dist*i*cos((90-glance+angl-k)/57)),(ypos-dist*i*sin((90-glance+angl-k)/57)),lyGUI2,tmpcolor);
   // end;
  //  _screen.drawSprite('.',(ax+dist*i*cos((90-angl)/57)),(ay-dist*i*sin((90-angl)/57)),lyGUI,redrgb);
    _screen.drawSprite('-',currpoint.x,currpoint.y,lyGUI,acolor);
  end;
 end;

 //-----------------------------------------------------------------------------
 {//laserlike effect
 for i:=1 to 60 do begin;
   for j:=0 to 3 do tmpcolor[j]:=(20-i)/20-0.1;
   dist:=0.3+random()/20;//Random();//4;
   angl:=60;
    for k:=0 to 3 do
    if (Game as TGame).paused then begin;
 //     _screen.drawSprite('.',(xpos+dist*i*cos((90-glance-angl-k)/57)),(ypos-dist*i*sin((90-glance-angl-k)/57)),lyGUI2,tmpcolor);
 //     _screen.drawSprite('.',(xpos+dist*i*cos((90-glance+angl-k)/57)),(ypos-dist*i*sin((90-glance+angl-k)/57)),lyGUI2,tmpcolor);
    end;
   _screen.drawSprite('.',(xpos+dist*i*cos((90-glance)/57)),(ypos-dist*i*sin((90-glance)/57)),lyGUI2,redrgb);
 }

end.

