//- untConsole ----------------------------------------------------------------
// Консоль работающая через <s>Дельфикс-ДДрав</s> CastleEngine
// Fake VT on top of CastleEngine
// maniac

unit untConsole;

{$mode objfpc}{$H+}

{$TYPEINFO ON}
interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
 // LCLIntf, LCLType, LMessages,
{$ENDIF}
  {Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, //DXDraws, DXClass,
Menus, StdCtrls, Types,}

untTScreen,
CastleWindow, CastleGLUtils, CastleParameters,
CastleFonts, CastleStringUtils, CastleColors,
CastleControls, CastleKeysMouse, CastleControlsImages,
CastleLog, CastleApplicationProperties,
CastleSceneManager,X3DTriangles, CastleUnicode;

procedure _writeln(astr:String;aWriteToLog:boolean=true);//write to console routine
//procedure _write(astr:String);//write to console routine

type
 TMouseButtonz = (mouseLeft, mouseRight, mouseMiddle, mouseExtra1, mouseExtra2, mouseNone);

var
 // frmCon: TfrmCon;
  //prev_key,
  //px,py,
  mouse_x,mouse_y, // perpixel position of mouse cursor on screen
  mouse_wheeldelta, // mouse wheel scroll from last frame
  cmouse_x,cmouse_y:integer; // mouse cursor position in Fake VT symbols
  cmouse_xr,cmouse_yr:real; // mouse cursor position in Fake VT symbols
  mouse_button: TMouseButtonz; // mouse buttons state
  mouse_cursor_enabled:boolean;
  lastkey:TKey; // last pessed key
  keyShiftPressed,keyCtrlPressed,keyAltPressed:boolean;
  FontSize:real;
//  kkey:char;
  cntFrameRendered:LongWord; // rendered frames counter
 // lastShift:TShiftState;
  CharW,CharH:Integer;  // Fake VT chars width/height

  _screen:T_screen; // Fake VT singlton
  Window: TCastleWindowCustom;  // CastleEngine window object
  TimeHour, TimeMinute, TimeSecond, TimeMilliSecond,
   DateYear, DateMonth, DateDay: word;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

implementation

uses untWorld,untGame,untGameMenu,untLog,untUtils,CastleRectangles,
 castletexturefont_dejavusansmono_20,sysutils

 //CastleTextureFont_PxPlusIBMVGA8_20
// CastleTextureFont_PxPlusAmstradPC15122y_20
 ,untScreenSFX;

{$IFnDEF FPC}
//  {$R *.dfm}
{$ELSE}
//  {$R *.lfm}
{$ENDIF}
//-----------------------------------------------------------------------------
 procedure beginexecute; // Starter
 begin;
  _screen:=T_screen.create;
  //location:=TLocation.create;
 // Game:=TGameMenu.Create;//
 end;
 //-----------------------------------------------------------------------------
procedure _writeln(astr:String;aWriteToLog:boolean=true); // Write string to console and log
var i:integer;
begin;
 for i:=0 to maxconsolelines-1 do
  _screen.consolelines[i]:=_screen.consolelines[i+1];
 _screen.consolelines[maxconsolelines]:=astr;
 if aWriteToLog then Log_write('conmsg: '+astr);
end;
//-----------------------------------------------------------------------------
procedure Render(Container: TUIContainer); // Render frame
  var
    currX,currY,currL,maxX,maxY: Integer;
    currSprite :Integer;
    tmpFontsize: single;
    font:tcastlefont;
    tmpstr2:string;tmpchar:widechar;
  begin
    RenderContext.Clear([cbColor], Black);
    mouse_x:=trunc(Window.MousePosition[0]);mouse_y:=trunc(Window.MousePosition[1]);
    //Theme.Draw(Rectangle(X1, 0, 500, Window.Height), tiActiveFrame);   *Window.Width('W')

    CharW:=UIFont.TextWidth('A')+1;
    CharH:=UIFont.TextHeightBase('A')+1;
    maxX:=trunc(Window.Width/CharW);
    maxY:=trunc(Window.Height/CharH);
    _screen.SetSize(maxX-1,maxY-1,maxLayers);
    cmouse_x:=round((mouse_x-CharW)/CharW);
    cmouse_y:=round((Window.Height-mouse_y-CharH)/CharH);
    cmouse_xr:=((mouse_x-CharW)/CharW);
    cmouse_yr:=((Window.Height-mouse_y-CharH)/CharH);
    font:=uifont;
    mouse_cursor_enabled:=true;

    if assigned (Game) then Game.Mainloop
    else begin;
     Game:=TGameMenu.Create;
     Game.Mainloop;
    end;

    if IsAssignedAndInherited(Game,TGame) then begin;
      if not (Game as TGame).debugconsole_open then begin;
        //  _screen.writeXYex(' ☢⚙⚛✇',cmouse_x-1,cmouse_y-1,lyMouse,WhiteRGB);
         if   mouse_cursor_enabled then _screen.writeXYex('↖',cmouse_x,cmouse_y,lyMouse,WhiteRGB);
        //  _screen.writeXYex(' ',cmouse_x-1,cmouse_y+1,lyMouse,WhiteRGB);
        //  _screen.writeXYex(' ',cmouse_x-1,cmouse_y+2,lyMouse,WhiteRGB);
      end;
     end else
      _screen.writeXYex('↖',cmouse_x,cmouse_y,lyMouse,WhiteRGB);

    for CurrL:=0 to maxlayers do
     begin;tmpFontsize:=UIFont.Size;
     {  if (CurrL=lyGUI) then
	    begin;
         if tmpFontsize<8 then
          UIFont.Size:=8
          else UIFont.Size:=trunc(tmpFontsize);
        end;
       if (CurrL=lyGUI2) then
	    begin;
         if tmpFontsize/2<8 then
          UIFont.Size:=8
          else UIFont.Size:=trunc(tmpFontsize/2);
        end;     }
       for currX:=0 to maxXscreen do
        for currY:=0 to maxYscreen do
           if (_screen.content[CurrX,CurrY,CurrL]<>'')then
             begin;
              Font.Print(
               (currX+1)*CharW,
               Window.Height-CharH*(currY+1),
               HexToColor(ColorRGBToHex(_screen.color[CurrX,CurrY,CurrL])),
               _screen.content[CurrX,CurrY,CurrL]);
              if debug_console then
               DrawRectangleOutline(Rectangle(round((currX+1)*CharW),
                Window.Height-round((currY+1)*CharH),CharW, CharH),white,1);
             // Theme.Draw(, tiActiveFrame);
             {  Like with DrawPrimitive2D:
               Blending is automatically used if Color alpha < 1.
               ForceBlending forces the usage of blending. When it is @false,
               we use blending only if Color[3] (alpha) < 1.  }
               {const LineWidth: Single = 1;
               const BlendingSourceFactor: TBlendingSourceFactor = bsSrcAlpha;
               const BlendingDestinationFactor: TBlendingDestinationFactor = bdOneMinusSrcAlpha;
               const ForceBlending: boolean = false);}
             end;

    for currSprite:=0 to High(_screen.Sprites) do
     if _screen.Sprites[currSprite].pl=CurrL then
      begin;
       Font.Print(
        trunc((_screen.Sprites[currSprite].px+1)*CharW),
        Window.Height-trunc(CharH*(_screen.Sprites[currSprite].py+1)),
        HexToColor(ColorRGBToHex(_screen.Sprites[currSprite].aColor))
        ,_screen.Sprites[currSprite].aStr);
       if debug_console then
        DrawRectangleOutline(Rectangle(trunc((_screen.Sprites[currSprite].px+1)*CharW),
         Window.Height-trunc(CharH*(_screen.Sprites[currSprite].py+1)), CharH, CharW),white,1);
     //  FloatRectangle(Window.Rect).Collides(
      end;
     UIFont.Size:=tmpFontsize;
    end;
     //canvas
    //Theme.Draw(Rectangle(50, 0, 100, Window.Height), tiActiveFrame);
    lastkey:=k_none;
    mouse_button:=mouseNone;

    _screen.clearSprites;
    inc(cntFrameRendered);
    DecodeTime(Time,TimeHour,TimeMinute,TimeSecond,TimeMilliSecond);
    DecodeDate(Date,DateYear, DateMonth, DateDay);
    if TimeSecond/2=trunc(TimeSecond/2) then ScrSFXeffectBlink:=true else ScrSFXeffectBlink:=false;
    if TimeMilliSecond>500 then ScrSFXeffectBlink2:=true else ScrSFXeffectBlink2:=false;
//    if trunc(cntFrameRendered/40)*40=cntFrameRendered then ScrSFXeffectBlink:=not(ScrSFXeffectBlink);
//    if trunc(cntFrameRendered/20)*20=cntFrameRendered then ScrSFXeffectBlink2:=not(ScrSFXeffectBlink2);
  end;
//-----------------------------------------------------------------------------
procedure WindowPress(Container: TUIContainer; const Event: TInputPressRelease); // Input events reaction
begin
  if Event.IsMouseButton(mbLeft) then mouse_button:=mouseLeft;
  if Event.IsMouseButton(mbRight) then mouse_button:=mouseRight;
  if Event.IsMouseButton(mbMiddle) then mouse_button:=mouseMiddle;
  if Event.EventType = itKey then lastkey:=event.key;
  if Event.EventType = itMouseWheel then begin
   if Event.MouseWheelVertical then begin;
    if Event.MouseWheelScroll>0
     then FontSize:=FontSize+1
     else FontSize:=FontSize-1;
    if FontSize>18 then FontSize:=18;
    if FontSize<6 then FontSize:=6;
   end;
  end;
end;
//-----------------------------------------------------------------------------
procedure WindowUpdate(Container: TUIContainer);
begin
 if Window.Pressed[K_Shift] then keyShiftPressed:=true else keyShiftPressed:=false;
 if Window.Pressed[K_Ctrl] then keyCtrlPressed:=true else keyCtrlPressed:=false;
 if Window.Pressed[K_Alt] then keyAltPressed:=true else keyAltPressed:=false;
// Window.Cursor:=mcForceNone;
 UIFont.Size:=FontSize;
end;

procedure WindowClose(Container: TUIContainer);
begin
 Game.config.Save('./Config');
end;

var
  Characters: TUnicodeCharList;
begin;
  mouse_button:=mouseNone;
  Characters := TUnicodeCharList.Create;
  Characters.Add(SimpleAsciiCharacters);
  Characters.Add('йфяцычувскамепинртгоьшлбщдюзжхэъ');
  Characters.Add('ЙФЯЦЫЧУВСКАМЕПИНРТГОЬШЛБЩДЮЗЖХЭЪ');
  Characters.Add('№,?─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┟┞┝├┛┚┙┘┗┖┕└┓┒┑┑┐┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┯┿┾┼┻┺┹┸┷┶┵┴┳┲┱┰╀╁╂╃╅╆╇╈╉╊╋╌╍╎╏╞╞╝╛╚╙╘╗╖╕╔╓╒║═╟╠╢╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╿╾╽╼╻╺╸╷╶╵╴╳╲╱╰╿▀▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▏▞▟▞▝▜▛▚▙▘▗▖▕▔▓▒░▐■■□▢▣▤▥▦▧▨▩▪▫▬▭▮▯▿▾▽▼▻►▹▸▷▶▴△▲▱▰◀◁◂◃◄◅◆◇◈◉○◌◍◎●◟◞◝◜◛◚◘◗◖◕◔◓◒◑◐◠◡◢◤◥◦◨◩◪◫◬◮◯◿◾◽◼◻◹◸◷◶◵◴◳◱◰◰☢⚙⚛✇↖·');
  //Characters.Add('ф');
  // ApplicationProperties.OnWarning.Add(@ApplicationProperties.WriteWarningOnConsole);
  //UIFont := TTextureFont.Create('DejaVuSansMono.ttf', 14, false, Characters);
  UIFont := TTextureFont.Create(texturefont_dejavusansmono_20);
//  UIFont := TTextureFont.Create(texturefont_sharetechmono_20);
//  UIFont := TTextureFont.Create(TextureFont_PxPlusIBMVGA8_20);
//  UIFont := TTextureFont.Create(texturefont_pxplusamstradpc15122y_20);

  UIFont.Size:=12;
  //FreeAndNil(Characters);
  Window := TCastleWindowCustom.Create(Application);
  //Window.OnResize := @Resize;
  Window.DepthBits := 0;
  Window.SetDemoOptions(K_F11, #0, true);
  Window.Caption := 'NHWT';
  Window.OnRender := @Render;
  Window.OnPress := @WindowPress;
  Window.OnUpdate := @WindowUpdate;
  window.OnClose:= @WindowClose;

 // GetTickCount64;
  Log_write('GetAppConfigDir: '+ GetAppConfigDir(false));

  beginexecute;


end.
