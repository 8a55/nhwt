//- untGUI ----------------------------------------------------------------
// ГИП.
// maniac

unit untGUI;

{$mode objfpc}{$H+}

{$TYPEINFO ON}

interface
uses untConsole,CastleKeysMouse;

type TGUI_Menu=class
public
  selected,executed:integer;
  pressedkey:TKey;
  special:array of integer;
  special2:array of String;
  menu:array of String;
  title,comment:String;
  width_comment,heigth_comment,xpos_comment,ypos_comment,xpos_title,ypos_title,xpos_content,ypos_content,
  maxheight,firstshownitem:integer;
  hideselector,
  posinited:boolean;
  clearscreen:boolean;
 procedure AddItemEX(a_menuitem:String;a_special:integer);overload;
 procedure AddItemEX(a_menuitem:String;a_special:String);overload;
 procedure AddItem(a_menuitem:String);
 procedure Clear;
 procedure MainLoop(a_menuname:String);
 procedure MainLoopEX(a_menuname,a_comment:String);
 procedure additem_;
 constructor Create;virtual;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation


uses
{$IFnDEF FPC}
  windows,
{$ELSE}
  //LCLIntf, LCLType, LMessages,
{$ENDIF}
  untGameEditor,untWorld,
  //sysutils,graphics,
  untUtils,untTScreen,CastleColors,LazUTF8;
{ procedure AddItemEX(a_menuitem:string;a_special:string;csl:boolean);
 var i:integer;
 begin;
  for i:=0 to high(menu) do
   if menu[i]='' then begin;menu[i]:=a_menuitem;special2[i]:=a_special;special3[i]:=csl;exit;end;
  if i:=high(menu) then begin;setlength(menu,high(menu)+1);menu[i]:=a_menuitem;end;
 end;}

{ прг.бар
|=====75%===---|

( ) радио
(о) радио
( ) радио

[ ] галочка
[х] галочка

|[таб 1]| таб2 | таб3 |
 [таб 1]  таб2 | таб3 |

[<]=====[#]====[>] полоса прокрутки

[ поле редактирования█ ]

 + дерево

 - дерево
  + ветвь1
  + ветвь2
   - ветвь3
     [лист]


}
 constructor TGUI_Menu.Create;
 begin;
  comment:='';
  title:='no title';
  clearscreen:=true;
 end;

 procedure TGUI_Menu.additem_;
 begin;
  setlength(menu,length(menu)+1);
  setlength(special,length(menu)+1);
  setlength(special2,length(menu)+1);
 end;

 procedure TGUI_Menu.AddItemEX(a_menuitem:String;a_special:String);
 var i:integer;
 begin;
  additem_;
  menu[high(menu)]:=a_menuitem;
  special2[high(menu)]:=a_special;
 end;

 procedure TGUI_Menu.AddItemEX(a_menuitem:String;a_special:integer);
 var i:integer;
 begin;
  additem_;
  menu[high(menu)]:=a_menuitem;
  special[high(menu)]:=a_special;
 end;

 procedure TGUI_Menu.AddItem(a_menuitem:String);
 begin;
  additem_;
  menu[high(menu)]:=a_menuitem;
 end;

 procedure TGUI_Menu.Clear;
 var i:integer;
 begin;
  setlength(menu,0);
  setlength(special,0);
  setlength(special2,0);
  selected:=-1;
  for i:=0 to high(menu) do begin;menu[i]:='';special[i]:=0;special2[i]:='';end;
  comment:='';
  xpos_title:=1;
  ypos_title:=1;
 end;

 procedure TGUI_Menu.MainLoopEX(a_menuname,a_comment:String);
 begin;
  comment:=a_comment;
  title:=a_menuname;
  MainLoop(a_menuname);
 end;

 procedure TGUI_Menu.MainLoop(a_menuname:String);
 var y,i,maxitemlength:integer;label a,b;
 begin;
      if not posinited then begin;
       width_comment:=maxxscreen-5;
       heigth_comment:=10;
       xpos_comment:=1;
       ypos_comment:=maxyscreen-5;
       xpos_title:=trunc(maxxscreen/3);//30;
       ypos_title:=3;
       xpos_content:=trunc(maxxscreen/3);//29;
       ypos_content:=5;
       firstshownitem:=0;
       maxheight:=trunc(maxyscreen-5);//18;
       posinited:=true;
      end;

      if a_menuname<>'' then title:=a_menuname;
      executed:=-1;
      if clearscreen then _screen.clear;
      if selected>high(menu) then selected:=high(menu);
      if (selected=-1)and(high(menu)<>0) then selected:=0;

      _screen.writexyEX(title,xpos_title,ypos_title,lyGUI,GreenRGB);
      //  _screen.writexyEX(comment,xpos_comment,ypos_comment,maxlayers,clYellow);
      _screen.writeBlockEx(comment,xpos_comment,ypos_comment,width_comment,heigth_comment,lyGUI,GreenRGB);
      if menu=nil then exit;//selected:=-1;

      a:if (lastkey=k_up)and(selected>0)then
          dec(selected)
         else
          if (lastkey=k_up)and(selected=0)then  selected:=high(menu);

      b:if (lastkey=k_down)and(selected<high(menu)) then
          inc(selected)
         else
          if (lastkey=k_down)and(selected=high(menu)) then selected:=0;

      if menu=nil then exit;
      if (lastkey=k_up) and (copy(menu[selected],0,1)='=') then goto a;
      if (lastkey=k_down) and (copy(menu[selected],0,1)='=') then goto b;

      if selected<firstshownitem then dec(firstshownitem);//BUG BUG
      if selected>firstshownitem+maxheight then inc(firstshownitem);

      maxitemlength:=0;
      for i:=firstshownitem to high(menu) do
      //   if (i<=high(menu)) and (i>=0) then
        if maxitemlength<length(menu[i]) then maxitemlength:=length(menu[i]);
      // selected:=1;

      for i:=firstshownitem to firstshownitem+maxheight do
       if (i<=high(menu)) and (i>=0) then
       if menu[i]<>'' then
       begin;
         if (cmouse_x>xpos_content) and (cmouse_x<xpos_content+UTF8Length(menu[i])+2)
            and (cmouse_y=ypos_content+i-firstshownitem)
           then selected:=i;
         if (selected=i) and (not(hideselector)) then
          begin;
            if menu[i]<>'' then
             _screen.writexy('['+menu[i]+']',xpos_content,ypos_content+i-firstshownitem,lyGUI);// else
            //_screen.writexy(']',xpos_content+maxitemlength,ypos_content+i-firstshownitem,lyGUI);// else
          end
         else _screen.writexy(' '+menu[i]+' ',xpos_content,ypos_content+i-firstshownitem,lyGUI);
         //_screen.writexy('Ж',0,0,maxLayers);
       end;
      if (lastkey=k_Enter) or (mouse_button=mouseLeft)
         then executed:=selected;
      pressedkey:=lastkey;
 end;



{  for i:=0 to high(menu) do
   if menu[i]<>'' then
   begin;
    if selected=i then
     begin;
      _screen.writexy('['+menu[i]+']',xpos_content,ypos_content+i,maxlayers)// else
     end
    else _screen.writexy(' '+menu[i]+' ',xpos_content,ypos_content+i,maxlayers);
   end;
  if (lastkey=vk_return) then executed:=selected;
  pressedkey:=lastkey;
 end;}
end.
