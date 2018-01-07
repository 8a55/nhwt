//- untTLandscape ----------------------------------------------------------------
// Элементы ланшафта
// 8а55

unit untTLandscape;

{$mode objfpc}{$H+}

{$TYPEINFO ON}

interface
uses untActorBase,untActorBaseConst,untTItem,untTAction,untUtils,untLog;

 const
 PRandomMax=1000;

 type
 TLandscape=class(TCritter)
 public
 end;

 TLandscape_Custom=class(TLandscape)
 public
  w,h:integer;
  d:real;
  Tile:string;
  TileComment:string;
  IsOpaque:boolean;
  function GetPhysics(a_x,a_y,a_z:real):integer;override;
  procedure GetPhysicsBoundingBox(var res_x,res_y,res_z,res_w,res_h,res_d:real);override;
  procedure SerializeData;override;
  constructor Create;override;
 end;

 TLandscape_Plain=class(TLandscape_Custom)//Равнина просто равнина
 public
  procedure Render;override;
 end;

 ttreepos=record
  x,y:real;
 end;

 TLandscape_Forest=class(TLandscape_Custom)//Лес - коробка
 // заполненная случайно расположеными деревьями
 public
  TreeNum, //количество деревьев
  delta //некий показатель "уникальности" леса
  :integer;
  procedure SerializeData;override;
  function GetTree(atreenum:integer):ttreepos;
  function GetPhysics(a_x,a_y,a_z:real):integer;override;
  procedure Render;override;
  constructor Create;override;
 end;

 var
  PRandom:array[0..1000] of real;//массив псевдослучайных чисел, хранящийся в rfile

implementation
uses SysUtils,untSerialize,untWorld,CastleColors;

 var
  rfile:file of real;

 constructor TLandscape_Custom.Create;
 begin;
  inherited;
  Tile:='';
  TileComment:='';
  IsOpaque:=false;
 end;

 procedure TLandscape_Custom.SerializeData;
 begin;
  inherited SerializeData;
  SerializeFieldI('w',w);
  SerializeFieldI('h',h);
  SerializeFieldFL('d',d);
  SerializeFieldS('Tile',Tile);
  SerializeFieldS('TileComment',TileComment);
  IsOpaque:=SerializeFieldB('IsOpaque',IsOpaque);
 end;

 procedure TLandscape_Custom.GetPhysicsBoundingBox(var res_x,res_y,res_z,res_w,res_h,res_d:real);
 var dl:real;
 begin;
  dl:=0.5;
  res_x:=xpos-dl;
  res_y:=ypos-dl;
  res_z:=zpos;
  res_w:=w+dl;
  res_h:=h+dl;
  res_d:=d;
 end;

 function TLandscape_Custom.GetPhysics(a_x,a_y,a_z:real):integer;
 var physical:integer;
  dl:real;
 begin; {(a_x>=xpos-0.5)and(a_x<=xpos+w-1)and
   (a_y>=ypos)and(a_y<=ypos+h-1)and
   (a_z>=zpos)and(a_z<=zpos+1)  }
{     (a_x>=xpos-1)and(a_x<=xpos+w+1)and
   (a_y>=ypos-0.7)and(a_y<=ypos+h+1)and
   (a_z>=zpos)and(a_z<=zpos+d)}
  dl:=0.5;
  physical:=stSolid; if IsOpaque then physical:=stOpaque;
  if
   (a_x>=xpos-dl)and(a_x<=xpos+w+dl)and
   (a_y>=ypos-dl)and(a_y<=ypos+h+dl)and
   (a_z>=zpos)and(a_z<=zpos+d)
  then
   result:=physical
  else
   result:=stEtheral;
 end;

 procedure TLandscape_Plain.Render;
 var x,y,physical:integer;
 begin;
  physical:=stSolid; if IsOpaque then physical:=stOpaque;
  for x:=0 to w-1 do
   for y:=0 to h-1 do
    location.RenderSymbol(xpos+x,ypos+y,zpos,Tile
    ,d,index,GreenRGB,MaxCritters,physical);
 end;

 constructor TLandscape_Forest.Create;
 begin;
  inherited;
 end;

 procedure TLandscape_Forest.SerializeData;
 begin;
  inherited SerializeData;
  SerializeFieldI('delta',delta);
  SerializeFieldI('TreeNum',TreeNum);
 end;

 function TLandscape_Forest.GetPhysics(a_x,a_y,a_z:real):integer;
 var ctree:integer;
 ctreepos:ttreepos;
 begin;
  result:=stEtheral;
  if a_z<>zpos then exit;
  for ctree:=1 to TreeNum do
  begin;
   ctreepos:=GetTree(ctree);
   if Location.Geom_calcdist(a_x,a_y,a_z,ctreepos.x,ctreepos.y,zpos)<=1 then
 //  if (ctreepos.x=a_x)and(ctreepos.y=a_y)then
    begin;
     result:=stSolid;
     exit;
   end;
  end;
 end;

 function TLandscape_Forest.GetTree(atreenum:integer):ttreepos;
 begin;
  result.x:=trunc(xpos+PRandom[atreenum+delta]*w);
  result.y:=trunc(ypos+PRandom[PRandomMax-atreenum-delta]*h);
 end;

 procedure TLandscape_Forest.Render;
 var ctreepos:ttreepos;ctree:integer;
 begin;
  for ctree:=1 to TreeNum do
  begin;
   ctreepos:=GetTree(ctree);
//   if Location.GetPhysics(ctreepos.x,ctreepos.y,zpos)=stetheral then
   location.RenderSymbol(ctreepos.x,ctreepos.y,zpos,'T',d,index,GreenRGB)
//   else location.RenderSymbol(ctreepos.x,ctreepos.y,zpos,'T',clRed);
  end;
 end;

// инициализация. создание, или загрузка файла псевдо-случаных чисел.
var i:integer;
begin
 assign(rfile,'.'+PathDelim+'rfile');
 if not(FileExists('.'+PathDelim+'rfile')) then
  begin;
   log_write('!untTLandscape - rfile not exists,generating');
   rewrite(rfile);
   for i:=0 to PRandomMax do
    begin;PRandom[i]:=random;write(rfile,PRandom[i]);end;
  end
 else
  begin;
   log_write('+untTLandscape - rfile loaded');
   reset(rfile);
   for i:=0 to PRandomMax do read(rfile,PRandom[i]);
  end;
 closefile(rfile);
 // обычная инициализация модуля - обьявление сериализуемых классов
 AddSerialClass(TLandscape_Forest);
 AddSerialClass(TLandscape_Plain);
end.
