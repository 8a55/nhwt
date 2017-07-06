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
   splashimg:array[0..13] of string;
   splashimgfull:string;
   cntGameFramesRendered:LongWord;
   main:TGUI_menu;
   procedure MainLoop;override;
   constructor Create;override;
   destructor Destroy;override;
 end;

var
 FileVerInfo: TFileVersionInfo;
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
  ,CastleKeysMouse,untScreenSFX,unttscreen,CastleColors,LazUTF8
  ,CastleApplicationProperties,CastleWindow
  ;
 //,graphics;
resourcestring
   AppName = 'РВЛ(т) версия:';

//-----------------------------------------------------------------------------
destructor TGameMenu.Destroy;
begin;
 main.free;
end;
//-----------------------------------------------------------------------------
constructor TGameMenu.Create;// Создаем главное меню
begin;
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
end;
//-----------------------------------------------------------------------------
procedure TGameMenu.MainLoop;// Цикл отображения главного меню
var i:integer;
 version:string;
begin;
  splashimgfull:=splashimg[0];
  for i:=1 to high(splashimg) do
   splashimgfull:=splashimgfull+LineEnding+splashimg[i];

  _screen.clear;inc(cntGameFramesRendered);
  //if cntGameFramesRendered<3 then begin;ScrSFXDigitalNoise;exit;end;
  //if cntGameFramesRendered<5 then begin;ScrSFXPointNoise;exit;end;

  if not assigned(main) then begin;
    main:=TGUI_menu.create;
    main.Clear;
    {
     3. НАСТРОЙКИ
     4. АВТОРЫ
     9. СМЕНИТЬ ЯЗЫК / CHANGE LANGUAGE
     0. ВЫЙТИ В ОС}
    main.AddItemEx('1. НОВАЯ ИГРА    ',1);
//    main.AddItem('');
    main.AddItemEx('2. ЗАГРУЗИТЬ ИГРУ',2);// main.AddItem(' Редактор(слман) ');
//    main.AddItem('3. РЕДАКТОР ПЕРСОНАЖА(нефункционален)');
   {main.AddItem(' Новая игра      ');
    main.AddItem(' Быстрая загрузка ');// main.AddItem(' Редактор(слман) ');
    main.AddItem(' РедПерс(слман)  ');}
    main.AddItemEx('0. ВЫЙТИ В ОС',9); { TODO -cBUG : Сломано, надо понять как castleengine вызвать закрытие окна }
    main.comment:=
    'Вы зачем-то запустили техническую демонстрацию NHWT. '+LineEnding+
    'Она скорее всего не отображает ни одно качество конечной версии. '+LineEnding+
    'Сейчас в игре отсутствуют: <s>los</s>присобачен, ai, графоний всех видов, '+
    '<s>управление шайкой</s> частично реализовано.'+LineEnding+
    'Присутствуют в рудиментарной форме:'+
    ' редактор персонажа, ходилка по лесу, говорилка, стрелялка в крестьянина(и роботов).'+LineEnding
//    +'№,?─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┟┞┝├┛┚┙┘┗┖┕└┓┒┑┑┐┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┯┿┾┼┻┺┹┸┷┶┵┴┳┲┱┰╀╁╂╃╅╆╇╈╉╊╋╌╍╎╏'+
//    '╞╞╝╛╚╙╘╗╖╕╔╓╒║═╟╠╢╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╿╾╽╼╻╺╸╷╶╵╴╳╲╱╰╿▀▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▏▞▟▞▝▜▛▚▙▘▗▖▕▔▓▒░▐■■□▢▣▤▥▦▧▨▩▪▫▬▭'+
//    '▮▯▿▾▽▼▻►▹▸▷▶▴△▲▱▰◀◁◂◃◄◅◆◇◈◉○◌◍◎●◟◞◝◜◛◚◘◗◖◕◔◓◒◑◐◠◡◢◤◥◦◨◩◪◫◬◮◯◿◾◽◼◻◹◸◷◶◵◴◳◱◰◰☢⚙⚛✇↖'
    ;
  end;
  main.ypos_comment:=maxyscreen-30;
  main.xpos_content:=trunc(maxxscreen/2-10);
  main.xpos_title:=trunc(maxxscreen/2-10);
  main.ypos_title:=0;
  main.ypos_content:=25;

  if assigned(FileVerInfo) then version:=FileVerInfo.VersionStrings.Values['FileVersion'];
  main.MainLoop(AppName+version);
  _screen.writeBlockEx(splashimgfull,trunc(maxxscreen/2-UTF8Length(splashimg[0])/2),5,maxxscreen,maxyscreen,lyGUI,GreenRGB,cntGameFramesRendered*3,'▒' );
  _screen.writeBlockEx(
   'Выберите пункт меню используя клавиатуру или манипулятор "Мышь" : [ ]'
   ,trunc(maxxscreen/2-UTF8Length(splashimg[0])/2),40,maxxscreen,maxyscreen,lyGUI,GreenRGB,cntGameFramesRendered*3,'▒' );

  if (lastkey=k_1) or (lastkey=k_N)or ((main.special[main.executed]=1) and (main.executed<>-1))  then // Создаем новою игру      (main.executed=0)
  begin;
    newGame:=TGame.Create;
    Game.Destroy;
    game:=newgame;
    newgame:=nil;
    (Game as TGame).MapToLoad:='Data'+PathDelim+'Map00';
    //  _screen.writeln('welcome to poseidon oil');
    _writeln('OIA.▒▒.▒▒▒▒▒▒▒▒.system.UPDATE-2077-195b.Brought.To.You.BY.-=ЦaЕsЯгСrEш=-');
    _writeln('Welcome to Tartarus Coal, Inc.');//_writeln('Welcome to Tartarus Coal, Inc.');
    _writeln('нажмите [F1] для подсказки');
    exit;
  end;
  if (lastkey=k_2) or (lastkey=k_F5) or ((main.special[main.executed]=2)and (main.executed<>-1)) then // Читаем записку (main.executed=1)
  begin;
    newGame:=TGame.Create;
    Game.Destroy;
    game:=newgame;
    newgame:=nil;
  //    if (lastKey=k_f5) then begin;
    //Location.EmptyActors;Location.clearground;
    Location.Load('.'+PathDelim+'Save00'+PathDelim);
    _writeln('Location loaded');
  //  exit;
  //end;
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
  if (lastkey=k_0) or ((main.special[main.executed]=9)and (main.executed<>-1)) then // Выход из игры
  begin;
   Application.Terminate;
  end;
end;
end.
