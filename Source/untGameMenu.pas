//- untGameMenu ----------------------------------------------------------------
// Главное меню. работает через untConsole
// maniac

unit untGameMenu;

{$mode objfpc}{$H+}

{$TYPEINFO ON}
interface
uses untGame,untGUI
 ,fileinfo,winpeimagereader,elfreader,machoreader
;

type
 TGameMenu=class(TGameAbstract) // Класс игры "главное меню"
  // default game class aka MAIN MENU
  public
   splashimg:array[0..19] of string;
   splashimganim:array[0..5] of string;
   splashimgfull:string;
   cntGameFramesRendered,MenuAnimationCounter:LongWord;
   main:TGUI_menu;
   procedure MainLoop;override;
   constructor Create;override;
   destructor Destroy;override;
 end;

var
 FileVerInfo: TFileVersionInfo;
 mmenucommentshow:boolean;
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
  untConsole,untGameEditor,untGameCreate,untWorld,sysutils
  ,CastleKeysMouse,unttscreen,CastleColors,LazUTF8
  ,CastleApplicationProperties,CastleWindow,Translations
  ,untUtils;
 //,graphics;
resourcestring
   rsAppName = 'РВЛ(т) версия:';
   rsNewGame = '1. НОВАЯ ИГРА    ';
   rsLoadGame = '2. ЗАГРУЗИТЬ ИГРУ';
   rsExittoOS = '0. ВЫЙТИ В ОС';
   rsLocationLoaded = 'Location loaded';

//-----------------------------------------------------------------------------
destructor TGameMenu.Destroy;
begin;
 inherited;
 main.free;
end;
//-----------------------------------------------------------------------------
constructor TGameMenu.Create;// Создаем главное меню
var i:integer;
begin;
  inherited;
  splashimg[0]:='       _____________________________________________________';
  splashimg[1]:='      /                                                    /';
  splashimg[2]:='     / ▒▒|   ▒▒| ▒▒|   ▒▒| ▒▒|       ▒▒|                  /  ';
  splashimg[3]:='    /  ▒▒▒   ▒▒| ▒▒|   ▒▒| ▒▒|       ▒▒|                  /  ';
  splashimg[4]:='    /  ▒▒▒▒  ▒▒| ▒▒|   ▒▒| ▒▒|  ▒|   ▒▒|                 / ';
  splashimg[5]:='   /   ▒▒|▒▒ ▒▒| ▒▒▒▒▒▒▒▒| ▒▒| ▒▒▒▒  ▒▒|  ▒| ▒|   ▒|     / ';
  splashimg[6]:='   /   ▒▒| ▒▒▒▒| ▒▒|   ▒▒| ▒▒|▒▒  ▒▒ ▒▒| ▒| ▒▒▒▒|  ▒|   / ';
  splashimg[7]:='  /    ▒▒|  ▒▒▒| ▒▒|   ▒▒| ▒▒▒▒    ▒▒▒▒| ▒|  ▒|    ▒|  /';
  splashimg[8]:='  /    ▒▒|   ▒▒| ▒▒|   ▒▒| ▒▒▒      ▒▒▒| ▒|  ▒| ▒| ▒|  /';
  splashimg[9]:=' /     ▒▒|   ▒▒| ▒▒|   ▒▒| ▒▒|       ▒▒|  ▒|  ▒▒| ▒|  /';
 splashimg[10]:='/                                                    /';
 splashimg[11]:='-/------------------------------------------------\--';
 splashimg[12]:=' | A POST-APOCALYPTIC ROLE PLAYING GAME (tactical)|';
 splashimg[13]:=' \------------------------------------------------/';


  splashimg[0]:='       _____________________________________________________';
  splashimg[1]:='      /                                                    /';
  splashimg[2]:='     /   ▒▒▒▒▒▒|   ▒▒▒▒▒▒|       ▒|                       / ';
  splashimg[3]:='    /    ▒▒|   ▒▒| ▒▒|   ▒▒|    ▒▒▒▒|                    / ';
  splashimg[4]:='    /    ▒▒|   ▒▒| ▒▒|   ▒▒|   ▒▒| ▒▒|                   / ';
  splashimg[5]:='   /     ▒▒▒▒▒▒|   ▒▒▒▒▒▒▒|   ▒▒|   ▒▒|   ▒|       ▒|   / ';
  splashimg[6]:='   /     ▒▒|       ▒▒|   ▒▒|  ▒▒|   ▒▒|  ▒| ▒▒▒▒▒|  ▒|  / ';
  splashimg[7]:='  /      ▒▒|       ▒▒|   ▒▒|  ▒▒|   ▒▒|  ▒|   ▒|    ▒| /';
  splashimg[8]:='  /      ▒▒|       ▒▒|   ▒▒|  ▒▒|   ▒▒|  ▒|   ▒|    ▒| /';
  splashimg[9]:=' /       ▒▒|   ▒|  ▒▒▒▒▒▒|  ▒|▒▒|   ▒▒|▒| ▒|  ▒| ▒|▒| /';
 splashimg[10]:='/                                                    /';
 splashimg[11]:='/---------------------------------------------------\';
 splashimg[12]:='|           ПОСТ-АПОКАЛИПТИЧЕСКАЯ ТАКТИЧЕСКАЯ        |';
 splashimg[13]:='|               КОМПЬЮТЕРНАЯ РОЛЕВАЯ ИГРА            |';
 splashimg[14]:='\---------------------------------------------------/';
 splashimg[15]:='            ▒▒▒|  ▒▒|  ▒▒▒|  ▒▒▒|  ▒▒▒|  ▒▒|  ';
 splashimg[16]:='           ▒| ▒| ▒| ▒|▒  ▒| ▒| ▒| ▒| ▒| ▒|    ';
 splashimg[17]:='           ▒| ▒| ▒|▒  ▒  ▒| ▒| ▒| ▒| ▒| ▒|   ';
 splashimg[18]:='           ▒| ▒| ▒|   ▒  ▒| ▒| ▒| ▒| ▒| ▒|    ';
 splashimg[19]:='           ▒| ▒| ▒|   ▒▒▒|  ▒| ▒| ▒▒▒|  ▒|';


 splashimganim[0]:='ПОСТ-АПОКАЛИПТИЧЕСКАЯ';
 splashimganim[1]:='ТАКТИЧЕСКАЯ';
 splashimganim[2]:='РОЛЕВАЯ';
 splashimganim[3]:='ИГРА';
 splashimganim[4]:='';
end;
//-----------------------------------------------------------------------------
procedure TGameMenu.MainLoop;// Цикл отображения главного меню
var i,cx:integer;
 strtmp,version:string;
begin;
  inherited;
  if (cntGameFramesRendered/2)=round(cntGameFramesRendered/2) then
   inc(MenuAnimationCounter);
  if MenuAnimationCounter=4 then MenuAnimationCounter:=0;
  splashimgfull:=splashimg[0];
  for i:=1 to high(splashimg) do
   splashimgfull:=splashimgfull+LineEnding+splashimg[i];
//  splashimgfull:=splashimgfull+LineEnding+splashimganim[MenuAnimationCounter];
//  splashimgfull:=splashimgfull+LineEnding+splashimganim[13];

    //_screen.writeBlockEx(splashimgfull,trunc(maxxscreen/2-UTF8Length(splashimg[0])/2)
    // ,5,maxxscreen,maxyscreen,lyGUI,GreenRGB,cntGameFramesRendered*3,'▒' );

  _screen.clear;inc(cntGameFramesRendered);
  //if cntGameFramesRendered<3 then begin;ScrSFXDigitalNoise;exit;end;
  //if cntGameFramesRendered<5 then begin;ScrSFXPointNoise;exit;end;

  if not assigned(main) then begin;
    main:=TGUI_menu.create;
   // _writeln(comment);
   if not mmenucommentshow then begin;
    _writeln('Вы зачем-то запустили очередную <s>техническую</s> демонстрацию РВЛ(т). '+LineEnding,false);
    _writeln('Она скорее всего не отображает ни одно качество конечной версии. '+LineEnding,false);
    _writeln('Сейчас в игре:',false);
    _writeln(' - примитивный los',false);
    _writeln(' - <s>ИскИн</s>примитивные боты',false);
    _writeln(' - графоний всех видов отсутствует',false);
    _writeln(' - управление шайкой частично реализовано',false);
    //_writeln('Присутствуют в рудиментарной форме:',false);редактор персонажа, ходилка по лесу,, стрелялка в крестьянина(и роботов).
    _writeln(' - диалоговая система'+LineEnding,false);
    _writeln(' - зайчатки симуляции боя, основанной на "умной"-паузе'+LineEnding,false);
 {   +'№,?─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┟┞┝├┛┚┙┘┗┖┕└┓┒┑┑┐┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┯┿┾┼┻┺┹┸┷┶┵┴┳┲┱┰╀╁╂╃╅╆╇╈╉╊╋╌╍╎╏'+
    '╞╞╝╛╚╙╘╗╖╕╔╓╒║═╟╠╢╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╿╾╽╼╻╺╸╷╶╵╴╳╲╱╰╿▀▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▏▞▟▞▝▜▛▚▙▘▗▖▕▔▓▒░▐■■□▢▣▤▥▦▧▨▩▪▫▬▭'+
    '▮▯▿▾▽▼▻►▹▸▷▶▴△▲▱▰◀◁◂◃◄◅◆◇◈◉○◌◍◎●◟◞◝◜◛◚◘◗◖◕◔◓◒◑◐◠◡◢◤◥◦◨◩◪◫◬◮◯◿◾◽◼◻◹◸◷◶◵◴◳◱◰◰☢⚙⚛✇↖·⋅'}
    ;
     mmenucommentshow:=true;
   end;

   main.Clear;
   {
    3. НАСТРОЙКИ
    4. АВТОРЫ
    9. СМЕНИТЬ ЯЗЫК / CHANGE LANGUAGE
    0. ВЫЙТИ В ОС}
   main.AddItemEx(rsNewGame, 1);
//    main.AddItem('');
   main.AddItemEx(rsLoadGame, 2
     ); // main.AddItem(' Редактор(слман) ');
//    main.AddItem('3. РЕДАКТОР ПЕРСОНАЖА(нефункционален)');
  {main.AddItem(' Новая игра      ');
   main.AddItem(' Быстрая загрузка ');// main.AddItem(' Редактор(слман) ');
   main.AddItem(' РедПерс(слман)  ');}
   main.AddItemEx(rsExittoOS, 9);
   main.comment:='';
 //  main.comment:='Выберите пункт меню используя клавиатуру или манипулятор "Мышь" : [ ]';
//  end;
  end;

  main.ypos_comment:=maxyscreen-30;
  main.xpos_content:=trunc(maxxscreen/2-10);
  main.xpos_title:=trunc(maxxscreen/2-10);
  main.ypos_title:=0;
  main.ypos_content:=27;

  if assigned(FileVerInfo) then version:=FileVerInfo.VersionStrings.Values['FileVersion'];  //
  main.MainLoop(rsAppName+version);
  if cntGameFramesRendered*3>UTF8Length(splashimgfull) then
  _screen.writeBlockEx(splashimgfull,trunc(maxxscreen/2-UTF8Length(splashimg[0])/2)
   ,5,maxxscreen,maxyscreen,lyGUI,GreenRGB) else
  _screen.writeBlockEx(splashimgfull,trunc(maxxscreen/2-UTF8Length(splashimg[0])/2)
   ,5,maxxscreen,maxyscreen,lyGUI,GreenRGB,LimitToRange(0,cntGameFramesRendered*3,UTF8Length(splashimgfull)),'▒' );
  _screen.writeBlockEx(
   'Выберите пункт меню используя клавиатуру или манипулятор "Мышь"'
   ,trunc(maxxscreen/2-UTF8Length(splashimg[0])/2),40,maxxscreen,maxyscreen,lyGUI
   ,GreenRGB,cntGameFramesRendered*3,'▒' );
  if (lastkey=k_1) or (lastkey=k_N)or ((main.special[main.executed]=1) and (main.executed<>-1))  then // Создаем новою игру      (main.executed=0)
  begin;
    strtmp:=Game.strStartMap;
    SwitchTo(TGame);
    (Game as TGame).MapToLoad:='.'+PathDelim+'Data'+PathDelim+strtmp;
    exit;
  end;
  if (lastkey=k_2) or (lastkey=k_F5) or ((main.special[main.executed]=2)and (main.executed<>-1)) then // Читаем записку (main.executed=1)
  begin;
    SwitchTo(TGame);
    (Game as TGame).MapToLoad:='.'+PathDelim+'Save00';
    _writeln(rsLocationLoaded);
    exit;
  end;
  if (lastkey=k_C)
   //or (main.executed=2)
   then // Редактор персонажа
  begin;// 
    newGame:=TGameCreate.Create;
    Game.Destroy;
    game:=newgame;
    newgame:=nil;
    exit;
  end;
  if (lastkey=k_E)  then // Редактор локаций, сломан примерно с 2002 года. Чинить наверно смысла нет
  begin;
     newGame:=TGameEditor.Create;
     Game.Destroy;
     game:=newgame;
     newgame:=nil;
     exit;
  end;
  if (lastkey=K_O) then
  begin;
    if TranslateResourceStrings('i18n1/NHWT.po') then _writeln('language switch');
  end;
  if (lastkey=k_0) or ((main.special[main.executed]=9)and (main.executed<>-1)) then // Выход из игры
  begin;
   config.Save('./Config');
   { TODO -cBUG :  }//Destroy;
   Application.Terminate;
  end;

  for cx:=0 to 15 do
   if maxconsolelines-cx>0 then begin;
     _screen.writeXYexWithBCK(_screen.consolelines[maxconsolelines-cx],0,maxyscreen-cx-2,lyGui,rgbGUI_Elements);
   end;
end;
end.
