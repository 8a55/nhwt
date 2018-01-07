//- untUtils ----------------------------------------------------------------
// Улетиты
// maniac

unit untUtils;

{$mode objfpc}{$H+}

{$TYPEINFO ON}

{$modeswitch typehelpers}
{$modeswitch advancedrecords}
//{$inline on}

interface
uses untConsole,untWorld,untGameMenu,untGameEditor,untGame,untSerialize,untGUI,
 untLog,untActorBase,sysutils;
  {
    function _SafeCheckCI(a_id:string;aclass:TClass):boolean;
    function _As_TItem(a_id:string):TItem;
  }

 function IsAssignedAndInherited(aobject:TObject;aclass:TClass):boolean;

 type
 tpoint=record
  x,y:real;
 end;

 function _ASSERT(a:TObject):boolean;
 function strDOP(astr:string;aint:integer):string;
 function strOF(astr:string;aint:integer):string;
 function Log_NameId(aCrit:TCritter):string;
 function not_assigned(P:pointer):boolean;
 function SolveLine(X1,Y1,X2,Y2,N: real): tPoint;
 function SolveAngledLine(ax,ay,aangle,arange:real):tPoint;
 function SolveAngle(ax,ay,ex,ey:real):real;
 function IntToStr_99(int:integer):string;
 function IntToStr_9(int:integer):string;
 function IsInRange(amin,acheck,amax:integer):boolean; overload;
 function IsInRange(amin,acheck,amax:real):boolean;overload;
 function LimitToRange(amin,acheck,amax:integer):integer;

{ TaIntegerHelper = Type Helper for Integer
 public
  function isInrange(aMin,aMax:integer):boolean;
 end;  }

implementation

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  //LCLIntf, LCLType, LMessages,
{$ENDIF}
  untTLandscape,untTScreen,math//,Classes,
  //graphics
  ;

type
 err=class
 procedure err;
 end;
 var
 er:err;

function SolveAngle(ax,ay,ex,ey:real):real;
begin;
 result:=radtodeg(arctan2(ey-ay,ex-ax));
 if result<0 then result:=result+360;
 result:=result+90;
 if result>360 then result:=result-360;
end;

function SolveAngledLine(ax,ay,aangle,arange:real):tPoint;
begin;
///('.',(maxxscreen-5+1.3*cos((90-glance)/57)),(maxyscreen-1-1.3*sin((90-glance)/57)),lyGUI,GreenRGB);
 result.x:=ax+arange*cos((90-aangle)/57.296);
 result.y:=ay-arange*sin((90-aangle)/57.296);
end;

{function TaIntegerHelper.isInrange(aMin,aMax:integer):boolean;
begin;
// Result := (Self >= aMin) and (Self <= aMax);
end;       }

function LimitToRange(amin,acheck,amax:integer):integer;
begin;
 result:=acheck;
 if acheck<amin then result:=amin;
 if acheck>amax then result:=amax

end;

function IsInRange(amin,acheck,amax:integer):boolean;
begin;
 if (amin<=acheck)and(acheck<=amax) then result:=true
  else result:=false;
end;

function IsInRange(amin,acheck,amax:real):boolean;
begin;
 if (amin<=acheck)and(acheck<=amax) then result:=true
  else result:=false;
end;



function IntToStr_99(int:integer):string;begin;if int<=9 then result:='0'+IntToStr(int)else result:=IntToStr(int);end;
function IntToStr_9(int:integer):string;begin;if int<=9 then result:='0'+IntToStr(int)else result:=IntToStr(int);end;

Function SolveLine(X1,Y1,X2,Y2,N: real): tPoint;
var xdelta,ydelta,xstep,ystep,dist,dir,currstep:double;
begin;
 xdelta:=abs(x1-x2);
 ydelta:=abs(y1-y2);
 //dist:=Location.Geom_calcdist(x1,y1,0,x2,y2,0);
 dist:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
 xstep:=xdelta/dist;if x2<x1 then xstep:=-xstep;
 ystep:=ydelta/dist;if y2<y1 then ystep:=-ystep;
 result.x:=x1;
 result.y:=y1;
 currstep:=0;
 result.x:=result.x+xstep*n;
 result.y:=result.y+ystep*n;
end;

function not_assigned(P:pointer):boolean;
begin;
 result:=not(assigned(P));
end;

function IsAssignedAndInherited(aobject:TObject;aclass:TClass):boolean;
begin;result:=false;
 if assigned(aobject) then
  if aobject.InheritsFrom(aclass) then result:=true;
end;

function Log_NameId(aCrit:TCritter):string;
begin;
 if assigned(aCrit) then
  result:=aCrit.name+'('+aCrit.Id+')';
end;

procedure err.err;
begin;
///
end;

function strDOP(astr:string;aint:integer):string;
var i:integer;
begin;result:=astr;
 for i:=0 to aint-length(astr) do result:=result+' ';
end;

function strOF(astr:string;aint:integer):string;
var i:integer;
begin;result:='';
 for i:=0 to aint  do result:=result+astr;
end;

function _ASSERT(a:TObject):boolean;
begin;
 result:=false;
 if not(assigned(a)) then
  begin;
   Log_write('assertion failed');result:=true;
   er.err;
  end;
end;

end.
