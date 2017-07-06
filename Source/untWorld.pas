//- untWorld ----------------------------------------------------------------
// Класс локации TLocation
// maniac

unit untWorld;

{$mode objfpc}{$H+}

{$TYPEINFO ON}
interface

uses untGame,untActorBase,
 //Graphics,
 untSerialize,untTScreen,CastleColors,fgl;

 const
 // maxLocationXSize=255;
  //maxLocationYSize=255;
  maxLocationXSize=512;//min 128 mb 8)
  maxLocationYSize=512;
  
  maxLocationZSize=1;//енто число должно меньше untConsole.maxLayers
  maxCritters=1000;
  maxGroundTypes=8;

  tmCENTISECOND=1;
  tmSECOND= 1;//100 * tmCENTISECOND);
  tmMINUTE= (60 * tmSECOND);
  tmHOUR= (60 * tmMINUTE);
  tmDAY= (24 * tmHOUR);
  tmYEAR= (365 * tmDAY);

  // ground types
  wcSnow=1;
  wcNothing=0;

  // commmon ids - temporary

  idUnknown='???';//ид для неопознанных криттеров. должны отрисовываться как '?'

 var
  idPlayer:string='player1';

  wcView:array[0..maxGroundTypes] of String = (
'просто черная пустота',
'грязный снег',
'облупленная стена',
'асфальт',
'лужа грязи',
'железо-бетонная плита',
'грязный цемент',
'раздолбаное окно',
'дерево')
;
  wcViewS:array[0..maxGroundTypes] of String = (
  'пустота',
  'снег',
  'стена',
  'асфальт',
  'лужа',
  'плита',
  'цемент',
  'окно',
  'дерево');
  wcViewR:array[0..maxGroundTypes] of widechar =
  //    (' ','.','\','=','~','-',';','П','Д');//Экранный символ.
    (' ','.','\','#','~','-',';','P','T');//Экранный символ.

  wcViewMoveRating:array[0..maxGroundTypes] of integer=
  (0,100,0,100,100,100,100,100,0);//0%-100% модификатор скорости передвижения
  wcViewThroughVisible:array[0..maxGroundTypes] of real=
  (0,0,1,0,0,0,0,0.5,0.5);
  //Пропускает ли тайл свет. 0 - дырка 1 - стена
  wcViewCoverStatus:array[0..maxGroundTypes] of real=
  (0,0,0,0,0,0,0,0,0);
  // Значение прикрытия. 
  // дробные значение модифицируют значение прикрытия для
  // GetCoverStatus.
  //wcViewColors:array[0..maxGroundTypes] of TColor=($00005900,clGreen,$00005900,clGreen,clGreen,$00005900,$00005900,clGreen,clGreen);
  //Экранный цвет.
 type
  TCritterClass=class of TCritter;

  TTileR=record
  //public
   Tile:integer;
   height:real;
   CellSize:integer;//размер занятой в ячейке области, см. размеры криттеров
   QDimension:byte;
   Extra1:integer;
   index:integer;
   debug:integer;
   physical:integer;//проходимость для различных форм материи/энергии
  end;

  //TTileList = specialize TFPGObjectList<TTile>;

  TLocation=class(TSerialObject)
   private
    window_x,window_y,window_h,window_w:integer;
    ground_ox,ground_oy,ground_oz,
    ground_maxx,ground_maxy,ground_maxz:integer;
    lastrendertime:integer;
    //положение окна камеры(верхний левый угол).
    //существуют только во время TLocation.Render

    {QDimensions:array of byte;
    Extra1s:array of integer;
    indexs:array of integer;
    debugs:array of integer; }
   public
    //TilesList:TTileList;
    tiles_dict:array of string;//shortstring;
    tiles:array[0..maxLocationXSize,0..maxLocationYSize,0..maxLocationZSize] of TTileR;
    //tiles:array of array of array of TTile;
    //ground:array of array of array of string;
    //ground:array[0..maxLocationXSize,0..maxLocationYSize,0..maxLocationZSize] of string;

    //extra1:array[0..maxLocationXSize,0..maxLocationYSize,0..maxLocationZSize] of integer;
    Critters:array[0..maxCritters] of TCritter;
    Time:LongWord;
    MapName:string;
    counter_TSearcher_Create:integer;
    counter_TSearcher_Find_CritterbyID:integer;
    constructor Create;override;
    destructor Destroy; override;

    procedure Tick;


    function LoadActors(params:String):String;
    function SaveActors(params:String):String;
    procedure Save(fileName:string);override;//Запись обьекта
    function Load(fileName:string):boolean;override;//Чтение обьекта
    procedure SerializeData;override;

    procedure EmptyActors;

    function Alloc_Critter(aCrit:TCritter):TCritter;// must find empty critter and alloc to him aCrit
    function RemoveCritter(ACrit:TCritter):boolean;//remove critter from table
    function DeAlloc_Critter(ACrit:TCritter):boolean;//dealloc critter from table
    function CreateCritter(aCritterClass:TCritterClass):TCritter;
    //глобальные безконтекстные поисковики
    function Find_CritterbyID(a_id:string):TCritter;

    function BreakScalarTime(a_time:int64):string;overload;
    function BreakScalarTime(a_time:int64;aseparator:string):string;overload;
    function BreakScalarTimeYDHMS(a_time:int64):string;

    function Geom_calcdest(x1,y1,z1,x2,y2,z2:real):real;//oouuupppss 8)
    function Geom_calcdist(x1,y1,z1,x2,y2,z2:integer):integer;overload;
    function Geom_calcdist(x1,y1,z1,x2,y2,z2:real):real;overload;//oouuupppss 8)

    //function Geom_checkLOS(mon_x,mon_y,ply_x,ply_y:integer):boolean;
    function Geom_checkLOS(mon_x,mon_y,mon_z,ply_x,ply_y,ply_z:real;var break_x,break_y,break_z,maxheight:real;checkPhysical:boolean):boolean;
    function Geom_checkLOS2(mon_x,mon_y,mon_z,ply_x,ply_y,ply_z:real;var break_x,break_y,break_z,maxheight:real;checkPhysical:boolean):boolean;
    //Function Geom_CheckLos2(X1,Y1,X2,Y2:Integer):boolean;
    function Geom_GetCoverStatus(xpos,ypos,zpos:integer):real;

    function GetPhysics(a_x,a_y,a_z:real;var result_critter:integer;var ignore_critter:integer):integer;virtual;

    procedure clearground;
    function getground(x,y,z:integer):string;
    function getgroundEX(x,y,z:integer):TTileR;
//    procedure setground(x,y,z:integer;newground:string;aheight:real;index,indebug:integer);
    procedure setground(x,y,z:integer;newground:string;aheight:real;index,indebug,physical:integer);
    procedure Render;
//    procedure RenderSymbol(xpos,ypos,zpos:real;symbol:string;aheight:real;index:integer;color:TCastleColorRGB;indebug:integer=MaxCritters);
    procedure RenderSymbol(xpos,ypos,zpos:real;symbol:string;
       aheight:real;index:integer;color:TCastleColorRGB;indebug:integer=MaxCritters;
       physical:integer=stSolid);
    //function GetGround(xpos,ypos,zpos:integer):TLocationCell;

   private
    privsearch:integer;
    find_tmp:integer;
  end;

  TSearcher=class
  public
   currcritter:integer;
   constructor Create;
   procedure ResetSearch;
   function Find_CritterThat(a_crit:TCritter):TCritter;virtual;
   function Find_CritterbyID(a_id:string):TCritter;virtual;
   function Find_CritterByParent(a_id:string):TCritter;virtual;
   function Find_CritterByPos(a_xpos,a_ypos,a_zpos:real):TCritter;virtual;
   function Find_CritterByPosEx(a_xpos,a_ypos,a_zpos,possibledelta:real):TCritter;virtual;
   function Find_CritterBiggerThan(a_xpos,a_ypos,a_size:integer):TCritter;virtual;
   function Find_CritterVisibleBy(a_crit:TCritter):TCritter;virtual;
   function Find_ItemInventoredBy(a_id:string):TCritter;virtual;
   function Find_ItemBySlot(a_id,a_hop:string):TCritter;virtual;
   function Find_ItemByParentAndClass(a_parent,AClass:string):TCritter;virtual;
  end;



var
 Location:TLocation;
 Game:TGameAbstract;
 newgame:TGameAbstract;//warning - used by game switching routines

 debug_los:boolean;
 debug_physics:boolean;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

implementation
uses SysUtils,untConsole,untLog,untMonster_GiAnt,untGameCreate,untTCharacter,
untTItem,untUtils,math,LazUtils,lazfileutils,untMaps;

const
 srCritterThat=1;
 srEmptyCritter=2;

 constructor TSearcher.Create;
 begin;
// log_write('TSearcher.Create');
  inc(location.counter_TSearcher_Create);
 end;

 procedure TSearcher.ResetSearch;
 begin;
  currcritter:=0;
 end;

 function TSearcher.Find_CritterbyID(a_id:string):TCritter;
 var i:integer;
 begin;
	  inc(location.counter_TSearcher_Find_CritterbyID);
	  result:=nil;
	  for i:=currcritter to maxCritters do
	   if (assigned(location.critters[i])) then
	    if (location.critters[i].id=a_ID) then
	     begin;
	      result:=location.critters[i];
	      currcritter:=i;
	      inc(currcritter);
	      exit;
	     end;
	  currcritter:=i;
 end;

 function TSearcher.Find_CritterVisibleBy(a_crit:TCritter):TCritter;
 var i:integer;
  trs1,trs2,trs3,maxheight:real;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.Geom_checkLOS(a_crit.xpos,a_crit.ypos,a_crit.zpos,location.critters[i].xpos,location.critters[i].ypos,location.critters[i].zpos,trs1,trs2,trs3,maxheight,false))
    then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_CritterThat(a_crit:TCritter):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i]=a_crit) then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_CritterByParent(a_id:string):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i].parent=a_id) then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_CritterByPos(a_xpos,a_ypos,a_zpos:real):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i].xpos=a_xpos)and(location.critters[i].ypos=a_ypos)
    and(location.critters[i].zpos=a_zpos)and not(location.critters[i].hidden)
    then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_CritterByPosEx(a_xpos,a_ypos,a_zpos,possibledelta:real):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if
    (location.critters[i].xpos<=a_xpos+possibledelta)and(location.critters[i].xpos>=a_xpos-possibledelta)and
    (location.critters[i].ypos<=a_ypos+possibledelta)and(location.critters[i].ypos>=a_ypos-possibledelta)and
    (location.critters[i].zpos<=a_zpos+possibledelta)and(location.critters[i].zpos>=a_zpos-possibledelta)and
     not(location.critters[i].hidden)
   then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_CritterBiggerThan(a_xpos,a_ypos,a_size:integer):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i].xpos=a_xpos)and(location.critters[i].ypos=a_ypos)
   and(location.critters[i].size>=a_size) then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_ItemInventoredBy(a_id:string):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i].inheritsfrom(TItem)) then
    if ((location.critters[i] as TItem).parent=a_id) and
    ((location.critters[i] as TItem).inventored=true) then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_ItemByslot(a_id,a_hop:string):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i].inheritsfrom(TItem)) then
    if ((location.critters[i] as TItem).parent=a_id) and
    ((location.critters[i] as TItem).inventored=true) and
    ((location.critters[i] as TItem).CurrentSlot=a_hop) and
    ((location.critters[i] as TItem).InSlot=true)
     then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 function TSearcher.Find_ItemByParentAndClass(a_parent,AClass:string):TCritter;
 var i:integer;
 begin;
 result:=nil;
 for i:=currcritter to maxCritters do
  if (assigned(location.critters[i])) then
   if (location.critters[i].inheritsfrom(TItem)) then
    if ((location.critters[i] as TItem).parent=a_parent) and
    (location.critters[i].ClassName=aclass)
     then
    begin;
     result:=location.critters[i];
     currcritter:=i;
     inc(currcritter);
     exit;
    end;
 currcritter:=i;
 end;

 //-----------------------------------------------------------------------------
//------------------------------ END OF TSEARCHER -----------------------------
//-----------------------------------------------------------------------------

 function TLocation.GetPhysics(a_x,a_y,a_z:real;var result_critter:integer;var ignore_critter:integer):integer;
 var
  currcritter,currresult,currresult_critter:integer;
  res_x,res_y,res_z,res_w,res_h,res_d:real;
  label nxt;
 begin;
  result:=stEtheral;result_critter:=-1;
  for currcritter:=0 to maxCritters do
   begin;
      if assigned(critters[currcritter]) and (currcritter<>ignore_critter) then
      begin;
       critters[currcritter].GetPhysicsBoundingBox(res_x,res_y,res_z,res_w,res_h,res_d);
       if
        (a_x>=res_x)and(a_x<=res_x+res_w)and
        (a_y>=res_y)and(a_y<=res_y+res_h)and
        (a_z>=res_z)and(a_z<=res_z+res_d)
        then begin;
         if debug_physics then
            _writeln('Location.GetPhysics '+floattostr(a_x)+','+floattostr(a_y)+','+floattostr(a_z)
            +' inside of '+critters[currcritter].id
            +' '+floattostr(res_x)+'->'+floattostr(res_w)
            +','+floattostr(res_y)+'->'+floattostr(res_h)
            +','+floattostr(res_z)+'->'+floattostr(res_d)+',');
         currresult:=critters[currcritter].GetPhysics(a_x,a_y,a_z);
         currresult_critter:=currcritter;
         //if currresult=stSolid then begin
          result:=currresult;result_critter:=currcritter;
          goto nxt;{ TODO : BUGBUG it return first value, but must check all, also for hole-Q tiles      }
         //end;
        end;
      end;
      nxt:
   end;
 end;

 function TLocation.Find_CritterbyID(a_id:string):TCritter;
 var i:integer;
 begin;
  result:=nil;
  for i:=0 to maxCritters do
  if (assigned(critters[i])) then
   if (location.critters[i].id=a_ID) then
    begin;
     result:=critters[i];
     exit;
    end;
 end;



 function TLocation.CreateCritter(aCritterClass:TCritterClass):TCritter;
 begin;
 result:=aCritterClass.Create;
 if assigned(result) then
  begin;
   if result=Alloc_Critter(result)
   then exit
   else log_write('oouuppss - untWorld TLocation.CreateCritter - critter not allocated');
  end
  else log_write('oouuppss - untWorld TLocation.CreateCritter - critter not created');
 end;


function TLocation.RemoveCritter(ACrit:TCritter):boolean;//remove critter from table
 var i:integer;sear:TSearcher;
 begin;
  result:=false;sear:=TSearcher.create;
  if assigned(sear.Find_CritterThat(acrit)) then
  begin;
   for i:=0 to maxcritters do
    if critters[i]=aCrit then begin;critters[i].index:=maxCritters+1;critters[i]:=nil;end;
   //aCrit.free;
   result:=true;
  end;
 sear.free;
 end;
 //-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
 function TLocation.DeAlloc_Critter(ACrit:TCritter):boolean;//dealloc critter from table and destroy
 var i:integer;sear:TSearcher;
 begin;
  result:=false;sear:=TSearcher.create;
  if assigned(sear.Find_CritterThat(acrit)) then
  begin;
   for i:=0 to maxcritters do
    if critters[i]=aCrit then critters[i]:=nil;
   aCrit.free;
   result:=true;
  end;
 sear.free;
 end;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
 function TLocation.Geom_GetCoverStatus(xpos,ypos,zpos:integer):real;
  begin;
   result:=1;
{   if (xpos>=0)and(xpos<=maxLocationXSize) then
   if (ypos>=0)and(ypos<=maxLocationYSize) then
   if (zpos>=0)and(zpos<=maxLocationZSize) then
    result:=wcViewCoverStatus[ground[xpos,ypos,zpos].groundtype];
}    
  end;

 procedure TLocation.RenderSymbol(xpos,ypos,zpos:real;symbol:string;
    aheight:real;index:integer;color:TCastleColorRGB;indebug:integer=MaxCritters;
    physical:integer=stSolid);
 var x,y,z:integer;
 begin;
  // _screen.writeXYex(symbol,trunc(xpos-window_x),trunc(ypos-window_y),trunc(zpos),color);
  {x:=trunc(xpos)-ground_ox;
  y:=trunc(ypos)-ground_oy;
  z:=trunc(zpos)-ground_oz;}
//  ground[x,y,z] := '*';

  if (xpos=trunc(xpos))and(ypos=trunc(ypos))and(zpos=trunc(zpos)) then begin;
    x:=trunc(xpos);
    y:=trunc(ypos);
    z:=trunc(zpos);
    setground(x,y,z,symbol,aheight,index,MaxCritters,physical);
    end;
 end;

 procedure TLocation.clearground;
  var igx,igy,igz,iperc:integer;
  begin;
     for igx:=0 to maxLocationXSize do
      for igy:=0 to maxLocationYSize do
       for igz:=0 to maxLocationZSize do begin;
         tiles[igx,igy,igz].tile := 0;
         tiles[igx,igy,igz].height:=0;
         tiles[igx,igy,igz].QDimension:= 0;
         tiles[igx,igy,igz].Extra1:= 0;
         tiles[igx,igy,igz].index:= MaxCritters;
         tiles[igx,igy,igz].debug:= MaxCritters;
         tiles[igx,igy,igz].CellSize:=0;
         tiles[igx,igy,igz].physical:=stEtheral;
       end;

  {  SetLength(Tiles,0);
    SetLength(Tiles,(maxLocationXSize+1),(maxLocationYSize+1),(maxLocationZSize+1));
    SetLength(Tiless,0);
    SetLength(Tiless,maxLocationXSize*maxLocationYSize*maxLocationZSize);
    SetLength(QDimensions,0);
    SetLength(QDimensions,maxLocationXSize*maxLocationYSize*maxLocationZSize);
   SetLength(Extra1s,0);
    SetLength(Extra1s,maxLocationXSize*maxLocationYSize*maxLocationZSize);
    SetLength(indexs,0);
    SetLength(indexs,maxLocationXSize*maxLocationYSize*maxLocationZSize);
   SetLength(debugs,0);
   SetLength(debugs,maxLocationXSize*maxLocationYSize*maxLocationZSize); }
  end;



  function TLocation.getground(x,y,z:integer):string;

  begin
 {    if (x>=0)and(x<=maxLocationXSize) and
      (y>=0)and(y<=maxLocationYSize) and
      (z>=0)and(z<=maxLocationZSize) then begin;
       result:=tiles[x,y,z].tile
   //    Result:=Tiless[x*y*z];
      end
     else result:='';}
    result:=tiles_dict[getgroundEX(x,y,z).Tile];
  end;

  function TLocation.getgroundEX(x,y,z:integer):TTileR;
  begin
  if (x>=0)and(x<=maxLocationXSize) and
      (y>=0)and(y<=maxLocationYSize) and
      (z>=0)and(z<=maxLocationZSize) then begin;
        result:=tiles[x,y,z];
    //    Result.Tile:=Tiless[x*y*z];
       { Result.QDimension:=QDimensions[x*y*z];
        Result.Extra1:=Extra1s[x*y*z];
        Result.index:=indexs[x*y*z];
        result.debug:=debugs[x*y*z];}
       end
     else begin;
        //result.debug:=MaxCritters;Result.Extra1:=0;Result.index:=MaxCritters;Result.QDimension:=0;Result.Tile:='';
        Result.Tile:=0;
        Result.Height:=0;
        Result.QDimension:=0;
        Result.Extra1:=0;
        Result.index:=MaxCritters;
        result.debug:=MaxCritters;
        result.physical:=stSolid;
       end;
  end;

 procedure TLocation.setground(x,y,z:integer;newground:string;aheight:real;index,indebug,physical:integer);
  begin
   if (x>=0)and(x<=maxLocationXSize) and
      (y>=0)and(y<=maxLocationYSize) and
      (z>=0)and(z<=maxLocationZSize) then begin;
        tiles[x,y,z].tile:=index;
        //color[x,y,z]:=clGreen;
        tiles[x,y,z].height:=aheight;
        tiles[x,y,z].index:=index;
        tiles[x,y,z].debug:=indebug;
        tiles[x,y,z].physical:=physical;
         // Tiless[x*y*z]:=newground;
      {   QDimensions[x*y*z]:=0;
         Extra1s[x*y*z]:=0;
         indexs[x*y*z]:=index;
         debugs[x*y*z]:=indebug; }
        tiles_dict[index]:=newground;
       end;

  end;

 procedure TLocation.Render;
 var n,i,ca,cx,cy,cz:integer;
 sear:TSearcher;
 sear_res:TCritter;
 player:TCharacter;
 currpoint:point;
 currCritter:integer;
 rminx,rminy,rminz,rmaxx,rmaxy,rmaxz:real;
 iminx,iminy,iminz,
 imaxx,imaxy,imaxz,iperc:integer;
 //ground_maxx,ground_maxy,ground_maxz,
 tmp1:string;

// window_x,window_y,window_h,window_w:integer;//положение окна камеры(верхний левый угол).
// в заголовке

 begin;
 ground_maxx:=1;ground_maxy:=1;ground_maxz:=1;
 ground_ox:=MaxInt;ground_oy:=MaxInt;ground_oz:=MaxInt;
 player:=Find_CritterbyID(idPlayer) as TCharacter;
 if not_assigned(player) then begin;log_write('-TLocation.Render - player not found');exit;end;
 window_x:=trunc(player.xpos-maxxscreen/2);
 window_y:=trunc(player.ypos-maxyscreen/2);
 window_h:=maxyscreen;
 window_w:=maxxscreen;

 {for currCritter:=0 to maxCritters-1 do
  if assigned(critters[currCritter]) then
    if not(critters[currCritter].hidden) then begin;
     //critters[currCritter].Render;
     critters[currCritter].GetPhysicsBoundingBox(rminx,rminy,rminz,rmaxx,rmaxy,rmaxz);
     iminx:=trunc(min(rminx,rmaxx));imaxx:=trunc(max(rminx,rmaxx));
     iminy:=trunc(min(rminy,rmaxy));imaxy:=trunc(max(rminy,rmaxy));
     iminz:=trunc(min(rminz,rmaxz));imaxz:=trunc(max(rminz,rmaxz));
     ground_ox:=min(iminx,ground_ox);
     ground_oy:=min(iminy,ground_oy);
     ground_oz:=min(iminz,ground_oz);
     //   ground_oy,ground_oz
     ground_maxx:=max(imaxx,ground_maxx);
     ground_maxy:=max(imaxy,ground_maxy);
     ground_maxz:=max(imaxz,ground_maxz);
     end;      }
     //   else  untlog.Log_write('TLocation.Render - '+critters[currCritter].id+' is inventored');

  //SetLength(ground,ground_maxx+2,ground_maxy+2,ground_maxz+2);
 // SetLength(ground,1000,1000,maxLocationZSize);

  clearground;
     {for x:=0 to maxLocationXSize do
    for y:=0 to maxLocationYSize do
      for z:=0 to maxLocationZSize do
        setground(x,y,z,'',MaxCritters,MaxCritters);   }

  //window_x:=-1;window_y:=-1;window_h:=-1;window_w:=-1;
  //_screen.writeXYex('*',trunc(maxxscreen/2),trunc(maxyscreen/2),lyGround,clred);



  for currCritter:=0 to maxCritters-1 do
   if assigned(critters[currCritter]) then
    if not critters[currCritter].InheritsFrom(TCreature) then
     begin;
      critters[currCritter].Render;;end;

  if assigned(player) then
   begin;
    for iperc:=0 to length(player.AI_controller.PerceptedCritters)-1 do
    if (assigned(player.AI_controller.PerceptedCritters[iperc])) then begin;
     sear_res:=Find_CritterbyID(player.AI_controller.PerceptedCritters[iperc].id);
     if assigned(sear_res) then sear_res.Render;end;

    player.Render;
   end;


  {for cx:=window_x to window_x+maxxscreen do
  for cy:=window_y to window_y+maxyscreen do
  begin;
   for cz:=maxLocationZSize downto 0 do
   // for cl:=0 to maxlayers do
     // Canvas.TextOut(2+Canvas.TextWidth('0')*(cx),2+Canvas.TextHeight('0')*(cy),_screen.content[cx,cy,cl]);
      if (cx+window_x>0)and (cx+window_x<ground_x)and(cy+window_y>0)and (cy+window_y<ground_y) then
      _screen.content[cx,cy,cz]:= ground[cx+window_x,cy+window_y,cz];
    end;}

  for cx:=0 to maxxscreen do
  for cy:=0 to maxyscreen do
  begin;
   for cz:=maxLocationZSize downto 0 do
   // for cl:=0 to maxlayers do
  //   untConsole.frmCon.Canvas.TextOut(2+untConsole.frmCon.Canvas.TextWidth('0')*(cx),
    // 2+untConsole.frmCon.Canvas.TextHeight('0')*(cy),_screen.content[cx,cy,cz]);
   // try;
    //  tmp1:=ground[cx+window_x,cy+window_y,cz];
//    finally
   // except

   // end;
     if getground(cx,cy,cz)<>'' then _screen.content[cx,cy,cz]:=getground(cx,cy,cz)[1];
  end;

 // for cx:=0 to 25 do   _screen.content[cx,cx,0]:='z';
//   window_x:=trunc(player.xpos-maxxscreen/2);
// window_y:=trunc(player.ypos-maxyscreen/2);
//    _writeln('cx:'+inttostr(cx)+' cy:'+inttostr(cy)+' cx+window_x:'+inttostr(cx+window_x)+' cy+window_y:'+inttostr(cy+window_y));
 end;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
 function TLocation.Alloc_Critter(aCrit:TCritter):TCritter;// must find empty critter and alloc to him aCrit
 var i:integer;
 begin;
  for i:=1 to maxCritters do
   if not(assigned(critters[i])) then
    begin;
     critters[i]:=aCrit;
     result:=aCrit;
     aCrit.index:=i;
     exit;
    end;
  if i>=maxcritters then result:=nil;
  untlog.Log_write('TLocation.Alloc_EmptyCritter - cant alloc critter because table is full');
 end;
 //-----------------------------------------------------------------------------
 //-----------------------------------------------------------------------------


  function TLocation.Geom_checkLOS2(mon_x,mon_y,mon_z,ply_x,ply_y,ply_z:real;var break_x,break_y,break_z,maxheight:real;checkPhysical:boolean):boolean;
  var t, x, y, z, ax, ay, az, sx, sy, sz, dx, dy, dz:real;
   debug_string:string;

 { function testlos(bx,by,bz,ex,ey,ez:real):boolean;{ TODO : z ignored for now }
    var i,tmp1,tmp2:integer;dist:real;
    currpoint:point;
    currground:string;
    currphysics:integer;
    begin;
     result:=false;debug_string:='';dist:=Geom_calcdist(bx,by,0,ex,ey,0);
     if dist<=1 then begin;result:=false;exit;end;
     for i:=2 to trunc(dist) do
      begin;
        currpoint:=SolveLine(bx,by,ex,ey,i);
        if (currpoint.x=ex)and(currpoint.y=ey)then result:=true;
        currground:=getground(round(currpoint.x),round(currpoint.y),trunc(bz));
        if getgroundEX(round(currpoint.x),round(currpoint.y),trunc(bz)).height>maxheight then begin;
          maxheight:=getgroundEX(round(currpoint.x),round(currpoint.y),trunc(bz)).height;
         end;

        currphysics:=GetPhysics(currpoint.x,currpoint.y,trunc(bz),tmp1,tmp2);
        if(currphysics<>stEtheral)and checkPhysical and((bx<>currpoint.x)and(by<>currpoint.y))
           //(currground<>'')//and(i<>0)
         //getground(currpoint.x,currpoint.y,bz)<>'*')
          then begin;result:=true;break_x:=currpoint.x;break_y:=currpoint.y;break_z:=0;exit;end;
        if((currphysics=stSolid))and(not checkPhysical) and((bx<>currpoint.x)and(by<>currpoint.y))
          then begin;result:=true;break_x:=currpoint.x;break_y:=currpoint.y;break_z:=0;exit;end;

        if not result then
         begin;
          if debug_los then begin;
            debug_string:=debug_string+' '+FloatToStr(currpoint.x)+','+FloatToStr(currpoint.y);
            if debug_los then
             _screen.drawSprite('.',currpoint.x,currpoint.y,lyGUI,GrayRGB);
           end;
         end;
       end;
    end;
  begin;
    maxheight:=0;
    result:=not testlos((mon_x),(mon_y),(mon_z),(ply_x),(ply_y),(ply_z));  }
    begin;
  end;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// function TLocation.Geom_checkLOS(mon_x,mon_y,mon_z,ply_x,ply_y,ply_z:real):boolean;
 function TLocation.Geom_checkLOS(mon_x,mon_y,mon_z,ply_x,ply_y,ply_z:real;var break_x,break_y,break_z,maxheight:real;checkPhysical:boolean):boolean;
 var t, x, y, z, ax, ay, az, sx, sy, sz, dx, dy, dz:real;
  debug_string:string;

 function testlos(bx,by,bz,ex,ey,ez:real):boolean;{ TODO : z ignored for now }
   var i,tmp1,tmp2:integer;currheight,dist:real;
   currpoint:point;
   currground:string;

   //stop:boolean;
   begin;
    result:=false;debug_string:='';dist:=Geom_calcdist(bx,by,0,ex,ey,0);
//    wtf
    maxheight:=0;
    if dist<=1 then begin;result:=true;exit;end;
    for i:=1 to trunc(dist) do
     begin;
       currpoint:=SolveLine(bx,by,ex,ey,i);
       if (currpoint.x=ex)and(currpoint.y=ey)then result:=true;
       currground:=getground(trunc(currpoint.x),trunc(currpoint.y),trunc(bz));
//       debug_string:=debug_string+' '+inttostr(round(currpoint.x))+' '+inttostr(round(currpoint.y));
       currheight:=getgroundEX(trunc(currpoint.x),trunc(currpoint.y),trunc(bz)).height;
       if currheight>=maxheight then begin;
         maxheight:=currheight;
//         debug_string:=debug_string+'maxh ch'+floattostr(maxheight);
         if debug_los then
           _screen.drawSprite(floattostr(maxheight),currpoint.x,currpoint.y,lyGUI2,yellowrgb);
        end;
       if
  //       (getgroundEX(round(currpoint.x),round(currpoint.y),trunc(bz)).physical=stSolid)
        (currground<>'')
     //   (GetPhysics((currpoint.x),(currpoint.y),trunc(bz),tmp1,tmp2)=stSolid)
       //and(i<>0)
       and((bx<>currpoint.x)and(by<>currpoint.y))
       //getground(currpoint.x,currpoint.y,bz)<>'*')
       then
        begin
         result:=true;
         if debug_los then _screen.drawSprite('+',currpoint.x,currpoint.y,lyGUI2,redrgb);
         break_x:=currpoint.x;break_y:=currpoint.y;break_z:=0;

         //_screen.writeXYex('!',currpoint.x,currpoint.y,lydebug,GrayRGB);
         //maxLocationZSize
         //setground(currpoint.x,currpoint.y,maxLocationZSize,'!',MaxCritters,MaxCritters);
         //Location.getground(currpoint.x,currpoint.y,bz)
        end;

       if (not checkPhysical)and(GetPhysics((currpoint.x),(currpoint.y),0,tmp1,tmp2)=stOpaque) then result:=false;

       if not result then
        begin;
         if debug_los then begin;
           debug_string:=debug_string+' '+FloatToStr(currpoint.x)+','+FloatToStr(currpoint.y);
           if debug_los then
            _screen.drawSprite('.',currpoint.x,currpoint.y,lyGUI,GrayRGB);
            //setground(currpoint.x,currpoint.y,maxLocationZSize,'#',MaxCritters,MaxCritters);
            //    maxLocationZSize     if debug_los then _screen.writeXYex('░',currpoint.x,currpoint.y,lydebug,RGBToColor(40,40,40));
            //_write('TInfluence_Visual.Tick: '+Self.parent+'->'+location.Critters[i].id);
          end;
            //  Location.setground( currpoint.x,currpoint.y,   maxLocationZSize-1,'░',maxCritters,-1);
        end;

       if result then
        exit;
     end;
//     if result then _screen.drawSprite('.',currpoint.x,currpoint.y,lyGUI,YellowRGB);
    //if debug_los then _write('testlos: '+debug_string);
   end;

 function testlos2(bx,by,bz,ex,ey,ez:real):boolean;{ TODO : z ignored for now }
   var i,tmp1,tmp2:integer;currheight,dist:real;
   currpoint,currpointZD:point;
   currground:string;deltaz:real;
   begin;
    result:=true;debug_string:='';dist:=Geom_calcdist(bx,by,0,ex,ey,0);maxheight:=0;
    debug_string:='mon:'+floattostr((mon_x))+','+floattostr((mon_y))+','+floattostr((mon_z));
    debug_string:=debug_string+' pol: '+floattostr((ply_x))+','+floattostr((ply_y))+','+floattostr((ply_z));
    deltaz:=(ply_z-mon_z)/dist;
    if dist<=1 then begin;result:=true;exit;end;
    for i:=1 to round(dist) do
     begin;
       currpoint:=SolveLine(bx,by,ex,ey,i);
      // currpointZD:=SolveLine(mon_z,1,ply_z,dist,i);
       currpointZD.x:=mon_z+deltaz*i;
       if (currpoint.x=ex)and(currpoint.y=ey)then result:=false;
//        exit;
       currground:=getground(trunc(currpoint.x),trunc(currpoint.y),0);
       debug_string:=debug_string+' '+floattostr((currpoint.x))+','+floattostr((currpoint.y))+','+floattostr((currpointZD.x));
       currheight:=getgroundEX(trunc(currpoint.x),trunc(currpoint.y),0).height;
       if //(currheight>currpointZD.x)
         //or
         (currground<>'')
          then begin;
         result:=false;
         debug_string:=debug_string+' currh:'+floattostr(currheight);
//         exit;
        end;
//       if debug_los then _screen.drawSprite(floattostr(maxheight),currpoint.x,currpoint.y,lyGUI2,yellowrgb);
       if debug_los then _screen.drawSprite('.',currpoint.x,currpoint.y,lyGUI,GrayRGB);
       {if //(currground<>'') //and((bx<>currpoint.x)and(by<>currpoint.y))
        (GetPhysics((currpoint.x),(currpoint.y),0,tmp1,tmp2)=stSolid)
         then
          begin
           if debug_los then
             _screen.drawSprite('+',currpoint.x,currpoint.y,lyGUI2,redrgb);
           result:=false;
       ///    if debug_los then _screen.drawSprite('+',currpoint.x,currpoint.y,lyGUI2,redrgb);
           break_x:=currpoint.x;break_y:=currpoint.y;break_z:=0;
           debug_string:=debug_string+' break:'+inttostr(round(currpoint.x))+','+inttostr(round(currpoint.y));
           exit;
          end;}

     //  if (not checkPhysical)and(GetPhysics((currpoint.x),(currpoint.y),0,tmp1,tmp2)=stOpaque) then result:=true;

       if not result then
         begin;
          if debug_los then begin;
 //           debug_string:=debug_string+' '+FloatToStr(currpoint.x)+','+FloatToStr(currpoint.y);
          end;
         end;
       if not result then begin;
         break_x:=currpoint.x;break_y:=currpoint.y;break_z:=0;
         exit;
        end;
     end;
   end;

 var fckdelta:real;
 begin;

//   result:=testlos(round(mon_x),round(mon_y),round(mon_z),round(ply_x),round(ply_y),round(ply_z));

   result:=testlos2((mon_x),(mon_y),(mon_z),(ply_x),(ply_y),(ply_z));
   fckdelta:=0.02;
  { result:=false;
   if
     testlos2((mon_x-fckdelta),(mon_y-fckdelta),(mon_z),(ply_x),(ply_y),(ply_z)) and
     testlos2((mon_x+fckdelta),(mon_y-fckdelta),(mon_z),(ply_x),(ply_y),(ply_z)) and
     testlos2((mon_x-fckdelta),(mon_y+fckdelta),(mon_z),(ply_x),(ply_y),(ply_z)) and
     testlos2((mon_x+fckdelta),(mon_y+fckdelta),(mon_z),(ply_x),(ply_y),(ply_z))

   testlos2((mon_x-fckdelta),(mon_y-fckdelta),(mon_z),(ply_x-fckdelta),(ply_y-fckdelta),(ply_z)) and
     testlos2((mon_x+fckdelta),(mon_y-fckdelta),(mon_z),(ply_x+fckdelta),(ply_y-fckdelta),(ply_z)) and
     testlos2((mon_x-fckdelta),(mon_y+fckdelta),(mon_z),(ply_x-fckdelta),(ply_y+fckdelta),(ply_z)) and
     testlos2((mon_x+fckdelta),(mon_y+fckdelta),(mon_z),(ply_x+fckdelta),(ply_y+fckdelta),(ply_z))
    then result:=true;}

 //  if not result then _write('check_los: '+debug_string);
 end;



  {function IsSightBlocked(x,y
 //,z - temporary
 :integer):integer;
  begin;
   if (x>0)and(x<maxLocationXSize)and(y>0)and(y<maxLocationYSize)
 //  and(z>0)and(z<maxLocationZSize)
    then result:=trunc(wcViewThroughVisible[ground[trunc(x),trunc(y),trunc(mon_z)].GroundType])
    else result:=-1;
  end;

 function SubCheckXY:boolean;
 begin;
  result:=true;
  dx:=ply_x-mon_x;
  dy:=ply_y-mon_y;
  ax:=(abs(dx)*2);
  ay:=(abs(dy)*2);
    if dx<0 then sx:=-1 else sx:=1;
    if dy<0 then sy:=-1 else sy:=1;
    x:= mon_x;
    y:= mon_y;
    if(ax > ay) then
    begin;t := ay - round(ax/2);
    repeat
          if(t >= 0) then begin;y :=y+ sy;t :=t- ax;end;
          x :=x+ sx;
          t :=t+ ay;
          if (x = ply_x) and (y = ply_y) then begin;result:=TRUE;exit;end;
      until(IsSightBlocked(round(x),round(y))<>0);result:=FALSE;
    end
    else
    begin;
       t := ax - round(ay/2);
       repeat
          if(t >= 0) then begin;x :=x+ sx;t :=t- ay;end;
          y :=y+ sy;
          t :=t+ ax;
          if(x = ply_x)and(y = ply_y) then begin;result:=TRUE;exit;end;
      until(IsSightBlocked(round(x),round(y))<>0);result:=false;
    end;
 end;

}




 function TLocation.Geom_calcdest(x1,y1,z1,x2,y2,z2:real):real;begin;result:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));end;
 function TLocation.Geom_calcdist(x1,y1,z1,x2,y2,z2:real):real;begin;result:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));end;

 function TLocation.Geom_calcdist(x1,y1,z1,x2,y2,z2:integer):integer;begin;result:=round(sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2)));end;

 function TLocation.BreakScalarTimeYDHMS(a_time:int64):string;
  begin;
    result:=
   ' yr '+inttostr(trunc(a_time/tmYEAR))+' day '+inttostr(trunc(a_time/tmDAY) mod 365)+
   ' hour '+inttostr(trunc(a_time/tmHOUR) mod 24)+' min '+inttostr(trunc(a_time/tmMINUTE) mod 60)
   +'sec '+inttostr(a_time mod tmMINUTE);
  end;

  function TLocation.BreakScalarTime(a_time:int64):string;
   begin;
   result:=inttostr(trunc(a_time/tmHOUR) mod 24)+':'+inttostr(trunc(a_time/tmMINUTE) mod 60)
   +':'+inttostr(a_time mod tmMINUTE);
  end;

  function TLocation.BreakScalarTime(a_time:int64;aseparator:string):string;
   begin;
   result:=IntToStr_99(trunc(a_time/tmHOUR) mod 24)+aseparator+IntToStr_99(trunc(a_time/tmMINUTE) mod 60)
   +aseparator+IntToStr_99(a_time mod tmMINUTE);
  end;

 procedure TLocation.Tick;
 var i,x,y,z:integer;u:boolean;
 creature:TCreature;
 label a;
 begin;
  counter_TSearcher_Create:=0;
  counter_TSearcher_Find_CritterbyID:=0;

  {for x:=0 to maxLocationXSize do
    for y:=0 to maxLocationYSize do
      for z:=0 to maxLocationZSize do
        setground(x,y,z,'',MaxCritters,MaxCritters);   }

   //---------------------------------------------------------
  Inc(Time);log_write('----------------- time '+BreakScalarTime(Time)+'------------------------');
  a:
  u:=false;//некрасиво, но цинично.
  for i:=0 to maxCritters do begin;
  if assigned(Critters[i]) then
  begin;
   if critters[i].immhalt then DeAlloc_Critter(critters[i]);
   if assigned(Critters[i]) then
     if not(Critters[i].InheritsFrom(TInfluence)) then
	     if critters[i].lastticktime<time then
	     begin;
	      Critters[i].tick;u:=true;
	      if assigned(Critters[i]) then
	       //inc(Critters[i].LastTickTime);//хмм ?
	       Critters[i].LastTickTime:=time;
	     end;
  end;
  end;
  if u then
  goto a;
  //Inf tick
  log_write('--- Inf Tick ---');
  for i:=0 to maxCritters do
    if assigned(Critters[i]) then
     begin;
        if Critters[i].InheritsFrom(TInfluence) then
         begin;Critters[i].Tick;log_write('+TInfluence.tick: '+Critters[i].id);end;
     end;

  //AI Tick
  log_write('--- AI Tick ---');
  for i:=0 to maxCritters do
    if assigned(Critters[i]) then
     begin;
	      if Critters[i].InheritsFrom(TCreature) then
	      begin;
	      creature:=(Critters[i] as TCreature);
	       if assigned(creature.AI_controller) then
	        begin;
	         creature.AI_controller.AI_Tick;
	         log_write('+'+creature.name+' '+creature.id);
	        end;
	      end;
     end;

  log_write('-- Tickly Times --');
  log_write('counter_TSearcher_Create : '+inttostr(counter_TSearcher_Create));
  counter_TSearcher_Create:=0;

  log_write('counter_TSearcher_Find_CritterbyID : '+inttostr(counter_TSearcher_Find_CritterbyID));
  counter_TSearcher_Find_CritterbyID:=0;
 end;

 constructor TLocation.Create;
 var tmptile:TTileR;
 begin;
//  time:=42*tmyear+tmday*364+tmHour*23+tmminute*59;
   //SetLength(Tiles,(maxLocationXSize+1),(maxLocationYSize+1),(maxLocationZSize+1));
   inherited;
   {TilesList:=TTileList.create;
   tmptile:=TTile.create;tmptile.Tile:='?';tmptile.index:=-1;
   TilesList.Add(tmptile); }
   //SetLength(Tiless,maxLocationXSize*maxLocationYSize*maxLocationZSize);
   SetLength(tiles_dict,maxCritters);
{   SetLength(QDimensions,maxLocationXSize*maxLocationYSize*maxLocationZSize);
   SetLength(Extra1s,maxLocationXSize*maxLocationYSize*maxLocationZSize);
   SetLength(indexs,maxLocationXSize*maxLocationYSize*maxLocationZSize);
   SetLength(debugs,maxLocationXSize*maxLocationYSize*maxLocationZSize);}
 end;

 destructor TLocation.Destroy;
 var i:integer;
 begin;
  // FreeAndNil(TilesList);
  for i:=0 to maxCritters do
   if assigned(Critters[i]) then
    Critters[i].Destroy;
 end;

 function TLocation.SaveActors(params:AnsiString):AnsiString;
 var i:integer;test:boolean;testfile:text;//classname:string;
 label  nextcrit;
  begin;
  for i:=0 to maxCritters do
   if assigned(Critters[i]) then
    Critters[i].Save(params+Critters[i].id);
 end;

 procedure TLocation.EmptyActors;
  var i:integer;
  begin;
   for i:=0 to maxCritters do
    if assigned(Critters[i]) then
     begin;Critters[i].Destroy;Critters[i]:=nil;end;
  end;

 function TLocation.LoadActors(params:String):String;

	    function TryLoad(a_filename:string):TSerialObject;
		     var
		       ResultClass:TSerialObjectClass;t,j:integer;
		       t_file:text;
		       t_classname:string;
		       test:boolean;
		     label bugout;
	    begin;
	      result:=nil;
	      {$i-}
	      assign(t_file,a_filename);reset(t_file);
	      readln(t_file,t_classname);
	      {$i+}
	      if IOResult<>0 then begin;
	         log_write('-TLocation.LoadActors - cant load critter from file '+a_filename+' because '
	         +inttostr(IOResult)+' I/O error');
	         goto bugout;
	        end;
	      ResultClass:=FindSerialClass(t_classname);
	      if ResultClass=nil then begin;log_write('-TLocation.LoadActors - cant load critter from file '
                    +a_filename+' because class '+t_classname+' not found in SerialClasses');exit;end;

	      if not(ResultClass.InheritsFrom(TCritter)) then begin;
	        log_write('?TLocation.LoadActors '+a_filename+' not inherited from TCritter,freeed.');
	        result:=nil;exit;
	        closefile(t_file);
        end;
	      result:=ResultClass.Create;test:=result.Load(a_filename);
	      if not(test) then
         begin;
	        log_write('-TLocation.LoadActors ['+a_filename+'] load failed');
	        result.free;
	        result:=nil;
	       end
	      else log_write('+TLocation.LoadActors ['+a_filename+'] loaded');
	      closefile(t_file);
	      bugout:
	    end;

   var
     SearchRec: TSearchRec;
     i:integer;test,template_use:boolean;testfile:text;filename:string;
     p,p1:TSerialObject;
   begin;
     log_write(' ----------- TLocation.LoadActors begin ---------------');
     FindFirstUTF8(params+'*', faAnyFile, SearchRec);// ;
     while (FindNextUTF8(SearchRec)=0) do
      begin;
       if SearchRec.Size<>0 then
        if SearchRec.Name<>'Location' then
	        begin;
	         p:=tryLoad(params+SearchRec.Name);
             if p<>nil then
              if assigned(Find_CritterbyID((p as TCritter).id)) then
                begin;
                 Log_write('TLocation.LoadActors: cant load object from '+(p as TCritter).SerialFileName
                  +' because its id '+(p as TCritter).id+' is non uniq!');
                 (p as TCritter).Destroy;
                end
             {  else
                 if ((p as TCritter).parent<>'') then begin;
                   Log_write('TLocation.LoadActors: cant load object from '+(p as TCritter).SerialFileName
                    +' because its parent '+(p as TCritter).id+' not empty!');
                   (p as TCritter).Destroy;
                  end  }
                  else p:=Alloc_Critter(p as TCritter);//BUG BUG - утечка памяти при ошибке чтения.
	        end;
      end;
     FindCloseUTF8(SearchRec);
     log_write(' ----------- TLocation.LoadActors end ---------------');
    end;


 procedure TLocation.Save(fileName:string);
 begin
  Inherited Save(fileName+'Location');
  SaveActors(fileName);
 end;

 function TLocation.Load(fileName:string):boolean;
 begin;
  result:=Inherited Load(fileName+'Location');
  LoadActors(fileName);
  _writeln('Игра загружена');
 end;

 procedure TLocation.SerializeData;
  var p:pointer;
  begin;
   inherited SerializeData;
   SerializeFieldLW('Time',Time);
   SerializeFieldS('MapName',MapName);
   Maps_SerializeData;
  end;

begin;
 AddSerialClass(TLocation);
end.
