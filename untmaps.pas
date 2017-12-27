//- untMaps ----------------------------------------------------------------
// Сценарии карт
// 8а55
unit untMaps;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untActorBaseConst,untSerialize;
// type

procedure Maps_Mainloop;
procedure Maps_SerializeData;

type
 TGameVars=class
  Maps_welcomereaded,
  MapDust_over,
  MapDust_briefingreaded,
  Map_TrainingMovement_1readed,
  Map_TrainingMovement_2readed,
  Map_TrainingMovement_3readed,
  Map_TrainingMovement_4readed,
  Map_TrainingMovement_5readed,
  Map_TrainingMovement_6readed,
  Map_TrainingMovement_7readed,
  Map_TrainingMovement_8readed,
  Map_TrainingMovement_9readed,
  MapTrainingMovement_over,
  MapTrainingCityHospital1_briefingreaded,
  MapTrainingCityHospital1_over,
  MapTrainingPause_briefingreaded,
  MapTrainingPause_over,
  PressF1tohelp_readed,
  Game_Over
  :boolean;
  MapTrainingSFXCounter,
  Map_TrainingMovement_penalty
  :integer;
 end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation
uses untGame,untWorld,untConsole,sysutils,untGameMenu,untLog,untUtils,untTAction,untScreenSFX;
var tmpstr,tmpstr2,tmpstr3,tmpstr4,tmpstr5:string;
//-----------------------------------------------------------------------------
{function Maps_CheckAndShowMWindow(aCheck:boolean;aText:string):boolean;   BUGBUG нечто эззотерическое
begin;
  if not aCheck then
   begin;
    (game as tgame).modalwindow_text:=aText;
    (game as tgame).modalwindow_open:=true;
    result:=true;
   end;
end;}
//-----------------------------------------------------------------------------
procedure Maps_Mainloop_EveryMap;// Сценарий для каждой карты
var player:tcritter;
 hp:integer;
begin;
 player:=Location.Find_CritterbyID('player1');
 if assigned(player) then
  HP:=(player as TCreature).Sklmtrx_GetParamRes(prmCurrHP) else hp:=0;
 if (HP<=0)
  //(not assigned(Location.Find_CritterbyID('player1')))
  and ((game as tgame).modalwindow_open=false) and (not location.GameVars.Game_Over) then begin;
  (game as tgame).modalwindow_text:=
      'Вы умерли.'+LineEnding;
  (game as tgame).modalwindow_open:=true;
  location.GameVars.Game_Over:=true;
 end;
 if location.GameVars.Game_Over and ((game as tgame).modalwindow_open=false) then begin;
  game.SwitchTo(TGameMenu);
  Log_write('+ exiting to main menu, because player non exists');
 end;
end;
//-----------------------------------------------------------------------------
procedure Maps_Mainloop_MapDust;//Сценарий карты Dust
var i:integer;fck:boolean;
begin;
 if// ((game as tgame).cntGameFramesRendered=5)and
  (not location.GameVars.MapDust_briefingreaded) then begin;
     tmpstr:=
     'Инструктор: Добро пожаловать, обратно, будущий корм червей!'+
     ' Сегодня вы "сражаетесь" с роботами, я пишу отчеты.'+
     ' Главный- 2197. Начинайте.'+
     LineEnding;
  {   tmpstr:=
     'Здраствуйте, 2197. Мы в курсе ситуации складывающейся с вашим заданием.'+
     ' Решение руководства Отдела Вмешательства, отправить вас внепланово'+
     ', буду откровенен, чреповато для нас всех. Но отчаяные времена, требуют'+
     ' отчаяных действий, совершаемых горячими головами.'+
     ' Мы зарезервировали вам виртуальный тренажер для освежения навыков.'+
     ' Там загружена традиционная для курсов ближнего боя карта.'+
     LineEnding;}
    _writeln('(Уничтожить всех врагов)');
    (game as tgame).modalwindow_text:=tmpstr;
    (game as tgame).modalwindow_open:=true;
    location.GameVars.MapDust_briefingreaded:=true;
   end;
 if (game as tgame).cntGameFramesRendered>50 then
  begin;
  fck:=true;
  for i:=3 to 8 do
   if assigned(Location.Find_CritterbyID('xplayer'+inttostr(i))) then
     fck:=false;

  if fck and not location.GameVars.MapDust_over then
    begin;
    (game as tgame).modalwindow_text:=
     'Вы успешно прошли задачу на тренажере'+
     LineEnding;
    (game as tgame).modalwindow_open:=true;
    location.GameVars.MapDust_over:=true;
    end;
  end;

  if (not (game as tgame).modalwindow_open)
  and (location.GameVars.MapDust_over) then
   begin;
    (Game as TGame).MapToLoad:='Data'+PathDelim+'MapTrainingCityHospital1';
   end;
end;
//-----------------------------------------------------------------------------
procedure Maps_Mainloop_MapTrainingMovement;//Сценарий карты MapTrainingMovement
var i:integer;fck:boolean;
 task3ok,task4ok:integer;
 tmpplayer:tcritter;
 tmpcerature:tcreature;
 curraction:TAction;
begin;
 if  location.GameVars.MapTrainingSFXCounter>0 then
  begin;ScrSFXDigitalNoise;dec(location.GameVars.MapTrainingSFXCounter);exit;end;

 if (not location.GameVars.Map_TrainingMovement_1readed)then
 begin;
  tmpstr:='Инструктор: Добро пожаловать на мой любимый курс ближнего боя, курсант!'+LineEnding;
  tmpstr2:='Посмотри в окно на западной стене!'+LineEnding;
  tmpstr3:='(Нажмите мышью перед w(окно), когда персонаж подойдет, нажмите средней кнопкой за окном, чтобы развернуться)';
  _writeln(tmpstr3);
  (game as tgame).modalwindow_text:=tmpstr+tmpstr2+tmpstr3;
  (game as tgame).modalwindow_open:=true;
  location.GameVars.Map_TrainingMovement_1readed:=true;
 end;

 tmpplayer:=Location.Find_CritterbyID('player1');
 if IsAssignedAndInherited(tmpplayer,TCreature) then
  begin;
   if (tmpplayer as TCreature).AI_controller.IsPercepted('xplayer4')and
    (not location.GameVars.Map_TrainingMovement_2readed)then
    begin;
     (game as tgame).modalwindow_text:=
      'Инструктор: Курсант! Ты смотришь на деактивированного боевого робота "Модель-34". Подобные ему машины, будут'+
      ' портить твою жизнь, весь курс! "М-34" способен эффективно заменять нас на поле боя, и предназначен для'+
      ' использования в пехоте. Мы будем использовать их в качестве оппонентов.'+
      ' Теперь посмотри в окно в восточной стене!'+
      LineEnding;
     _writeln('Инструктор: Теперь посмотри через окно в восточной стене!');
     (game as tgame).modalwindow_open:=true;
     location.GameVars.Map_TrainingMovement_2readed:=true;
    end;

   if (IsInRange(21.5,tmpplayer.ypos,22.5) and IsInRange(25.5,tmpplayer.xpos,26.5) and
   (not location.GameVars.Map_TrainingMovement_3readed)) then
    begin;
     if Assigned(Location.Find_CritterbyID('xplayer4')) then Location.Find_CritterbyID('xplayer4').SamoKill;
     location.GameVars.Map_TrainingMovement_3readed:=true;
      tmpstr:='Инструктор: Курсант! Как ты видишь, планировка помещения мешает определить наличие противника в северо-западном(↖) углу комнаты.';
      tmpstr2:=' Эту проблему мы решим так - ты заранее развернешся в направлении противника, а потом тактически выйдешь в проем двери.'+LineEnding;
      tmpstr3:='(Подойдите к проему в южной(▼) стене, не "засвечиваясь" перед потенциальным противником в';
      tmpstr4:=' СЗ(↖) углу комнаты. Повернитесь на север(Средняя КМ), и "стрейфом" (CTRL+ЛевКМ)';
      tmpstr5:=' зайдите в проем. Уничтожьте противника (Клавиша ПРОБЕЛ).)';
     (game as tgame).modalwindow_text:=tmpstr+tmpstr2+tmpstr3+tmpstr4+tmpstr5;
     (game as tgame).modalwindow_open:=true;
     _writeln(tmpstr3);_writeln(tmpstr4);_writeln(tmpstr5);
    end;

   task3ok:=0;
   curraction:=nil;
   if assigned((tmpplayer as TCreature).currAction) then
    begin;
     curraction:=(tmpplayer as TCreature).currAction;
     if IsAssignedAndInherited(currAction,TAction_WalkToCoord) then
      if (currAction as TAction_WalkToCoord).preserveglance then inc(task3ok);
     if IsAssignedAndInherited(currAction,TAction_Attack) then inc(task3ok);
    end;
   if IsInRange(23,tmpplayer.ypos,26) and IsInRange(30,tmpplayer.xpos,31) and
     (assigned(Location.Find_CritterbyID('xplayer5'))) and (task3ok=0) and assigned(curraction) then
    begin;
     location.GameVars.Map_TrainingMovement_3readed:=true;
     tmpstr:='Инструктор: Каким органом ты меня слушал, будущий корм для червей?!'+LineEnding;
     tmpstr2:='...мордой развернись в комнату, и боком выходи... как увидишь робота - стреляй!'+LineEnding;
     tmpstr3:='(Подойдите к проему в южной(▼) стене, не "засвечиваясь" перед потенциальным противником в';
     tmpstr4:=' СЗ(↖) углу комнаты. Повернитесь на север(Средняя КМ), и "стрейфом" (CTRL+ЛевКМ)';
     tmpstr5:=' зайдите в проем. Уничтожьте противника (Клавиша ПРОБЕЛ).)';
     (game as tgame).modalwindow_text:=tmpstr+tmpstr2+tmpstr3+tmpstr4+tmpstr5;
     (game as tgame).modalwindow_open:=true;
     _writeln(tmpstr3);_writeln(tmpstr4);_writeln(tmpstr5);
     (tmpplayer as TCreature).xpos:=28;
     (tmpplayer as TCreature).ypos:=25;
     location.GameVars.MapTrainingSFXCounter:=10;
     inc(location.GameVars.Map_TrainingMovement_penalty);
    end;

  if ((tmpplayer as TCreature).AI_controller.IsPercepted('xplayer5'))
   and (not location.GameVars.Map_TrainingMovement_4readed) then begin;
    Location.GameVars.Map_TrainingMovement_4readed:=true;
    _writeln('Инструктор: Теперь стреляй!');
    _writeln('(Прикажите персонажу действовать самостоятельно - клавиша ПРОБЕЛ)');
   end;

  if (not assigned(Location.Find_CritterbyID('xplayer5')))
   and (not location.GameVars.Map_TrainingMovement_5readed) then begin;
    location.GameVars.Map_TrainingMovement_5readed:=true;
    _writeln('Инструктор: Отлично! Вали всех, там разберуться!');
    _writeln('Инструктор: Иди в выходу из комнаты.');
   end;

  if IsInRange(33,tmpplayer.xpos,37) and IsInRange(25,tmpplayer.ypos,26)
   and (not location.GameVars.Map_TrainingMovement_6readed) then
    begin;
      location.GameVars.Map_TrainingMovement_6readed:=true;
      tmpstr:='Инструктор: Курсант! Следующие помещение перегорожено препятствием, что позволит тебе внезапно'+
      ' атаковать.'+LineEnding;
      tmpstr2:=' Спрячься за ним, и внезапно появись вблизи южной стены'+LineEnding;
      //''+
      tmpstr3:='(Повернитесь на запад(◀)(Средняя КМ), пригнитесь (кнопка Z) и';
      tmpstr4:=' "стрейфом" (CTRL+ЛевКМ) идите на середину коридора, поднимитесь(кнопка A) и уничтожьте противника.)';
     (game as tgame).modalwindow_text:=tmpstr+tmpstr2+tmpstr3+tmpstr4;
     (game as tgame).modalwindow_open:=true;
     _writeln(tmpstr3);
     _writeln(tmpstr4);
    end;

   task4ok:=0;
   if IsAssignedAndInherited((tmpplayer as TCreature).currAction,TAction_WalkToCoord) then
    if ((tmpplayer as TCreature).currAction as TAction_WalkToCoord).preserveglance then
     inc(task4ok);
   if IsAssignedAndInherited((tmpplayer as TCreature).currAction,TAction_WalkToCoord) then
    if ((tmpplayer as TCreature).currAction as TAction_WalkToCoord).rotateonly then
     inc(task4ok);
   if IsAssignedAndInherited((tmpplayer as TCreature).currAction,TAction_Attack) then
     inc(task4ok);
   if IsAssignedAndInherited((tmpplayer as TCreature).currAction,TAction_Walk) then
     inc(task4ok);
   if (tmpplayer as TCreature).currAction=nil then
     inc(task4ok);
   if IsInRange(33,tmpplayer.xpos,36) and IsInRange(27,tmpplayer.ypos,32) and
     (assigned(Location.Find_CritterbyID('xplayer3'))) and (task4ok=0)
   then
    begin;
     tmpstr:='Инструктор: Это что?! Ты хочешь моей смерти от смеха, курсант?'+LineEnding;
     tmpstr2:='...развернись к препятствию, пригнись и боком двигай до середины, там поднимайся и стреляй!...'+LineEnding;
     tmpstr3:='(Повернитесь на Запад(Средняя КМ), пригнитесь (кнопка Z), и'+
      '"стрейфом" (CTRL+ЛевКМ) идите';
     tmpstr4:=' на середину коридора, поднимитесь(кнопка A) и уничтожьте противника.)';
     (game as tgame).modalwindow_text:=tmpstr+tmpstr2+tmpstr3+LineEnding+tmpstr4;
     (game as tgame).modalwindow_open:=true;
     _writeln(tmpstr3);
     _writeln(tmpstr4);
     (tmpplayer as TCreature).xpos:=33;
     (tmpplayer as TCreature).ypos:=25;
     location.GameVars.MapTrainingSFXCounter:=10;
     inc(location.GameVars.Map_TrainingMovement_penalty);
    end;

  tmpcerature:=(tmpplayer as TCreature);

  {if IsInRange(33,tmpplayer.xpos,36) and IsInRange(27,tmpplayer.ypos,29) and
    (tmpcerature.stance>stnKneeling)
   then
    begin;
     tmpstr:='Инструктор: Курсант! Ты жить хочешь?!'+LineEnding;
     tmpstr2:='...враг ждет, тебя, прицелившись в угол коридора. Ты должен обмануть его!';
     tmpstr3:=' Проползи за преградой до середины коридора, и там внезапно поднимись...'+LineEnding;
     tmpstr4:='(Повернитесь на Запад(Средняя КМ), пригнитесь (кнопка Z), и'+
      '"стрейфом" (CTRL+ЛевКМ) идите';
     tmpstr5:=' на середину коридора, поднимитесь(кнопка A) и уничтожьте противника.)';
     (game as tgame).modalwindow_text:=tmpstr+tmpstr2+tmpstr3+tmpstr4+LineEnding+tmpstr5;
     (game as tgame).modalwindow_open:=true;
     _writeln(tmpstr4);
     _writeln(tmpstr5);
     (tmpplayer as TCreature).xpos:=33;
     (tmpplayer as TCreature).ypos:=25;
     location.GameVars.MapTrainingSFXCounter:=10;
     inc(location.GameVars.Map_TrainingMovement_penalty);
    end; }

  if (not assigned(Location.Find_CritterbyID('xplayer3')))
   and(not location.GameVars.MapTrainingMovement_over) then
    begin;
      (game as tgame).modalwindow_text:='Вы успешно прошли задачу на тренажере'+LineEnding;
      if location.GameVars.Map_TrainingMovement_penalty=0 then
       (game as tgame).modalwindow_text:=(game as tgame).modalwindow_text+LineEnding+'Результат занятия: Отлично';
      if location.GameVars.Map_TrainingMovement_penalty=1 then
       (game as tgame).modalwindow_text:=(game as tgame).modalwindow_text+LineEnding+'Результат занятия: Терпимо';
      if location.GameVars.Map_TrainingMovement_penalty>1 then
       (game as tgame).modalwindow_text:=(game as tgame).modalwindow_text+LineEnding+
       'Результат занятия: С такими результатами, ты будущий корм для червей, курсант.';

      (game as tgame).modalwindow_open:=true;
      location.GameVars.MapTrainingMovement_over:=true;
     end;
 end;

 if (not (game as tgame).modalwindow_open)
  and (location.GameVars.MapTrainingMovement_over) then
   begin;
    (Game as TGame).MapToLoad:='Data'+PathDelim+'MapTrainingPause';
   end;
end;
//-----------------------------------------------------------------------------
procedure Maps_Mainloop_MapTrainingCityHospital1;//Сценарий карты
var i:integer;fck:boolean;
begin;
 if// ((game as tgame).cntGameFramesRendered=5)and
  (not location.GameVars.MapTrainingCityHospital1_briefingreaded) then begin;
     tmpstr:=
     'Инструктор: Курсанты! Сейчас, вы наконец примените ваши навыки в учебном бою.'+
     ' Я с нетерпением жду возможность увидеть ваши озадаченные морды, хе-хе-хе.'+
     ' Ваша задача - зачистить здание, заполненое роботами. Главный - 2197.'+
     ' Разрешаю приступить.'+
     LineEnding;
    _writeln('(Уничтожить всех врагов)');
    (game as tgame).modalwindow_text:=tmpstr;
    (game as tgame).modalwindow_open:=true;
    location.GameVars.MapTrainingCityHospital1_briefingreaded:=true;

   end;
  if (game as tgame).cntGameFramesRendered>50 then
  begin;
  fck:=true;
  for i:=1 to 20 do
   if assigned(Location.Find_CritterbyID('xplayer'+inttostr(i))) then
    fck:=false;

  if fck and not location.GameVars.MapTrainingCityHospital1_over then
    begin;
    (game as tgame).modalwindow_text:=
     'Вы успешно прошли задачу на тренажере, и попутно все доступные в этой версии игры миссии.'+
     LineEnding;
    (game as tgame).modalwindow_open:=true;
    location.GameVars.MapTrainingCityHospital1_over:=true;
    location.GameVars.Game_Over:=true;
    end;
  end;
end;

procedure Maps_Mainloop_MapTrainingPause;//Сценарий карты
var i:integer;fck:boolean;
begin;
 if// ((game as tgame).cntGameFramesRendered=5)and
  (not location.GameVars.MapTrainingPause_briefingreaded) then begin;
     tmpstr:=
     'Инструктор: На сегодняшних занятиях мы будем разбирать методики управления'+
     ' личным составом в ближнем бою.'+LineEnding+
     ' (читает длинную лекцию, снабженную историческими примерами)'+LineEnding+
     ' Теперь будем отрабатывать усвоенные методики на практике.'+LineEnding
     ;
    _writeln('(Уничтожить всех врагов)');
    _writeln('Подсказка: Под вашим управлением два персонажа. Выбранный персонаж обозначен ◯, остальные цифрами.');
    _writeln(' Выбрать персонажа можно "мышью" или цифровыми клавишами. Игра автоматически устанавливает паузу, когда ');
    _writeln(' любой из них ждет вашего приказа. Вы увидите знак "?" над персонажем и <<Жду приказа>> в списке командиров групп.');
    _writeln(' Когда приказы розданы, пауза отключается.');
    _writeln(' Кнопка ПРОБЕЛ отменяет действующий приказ или разрешает персонажу действовать самостоятельно.');
    _writeln(' Персонажи будут самостоятельно аттаковать видимые цели.');
    _writeln('ВНИМАНИЕ: Роботы вооружены и враждебны. Чтобы успешно их уничтожать, вам необходимо атаковать');
    _writeln(' несколькими персонажами!');
    (game as tgame).modalwindow_text:=tmpstr;
    (game as tgame).modalwindow_open:=true;
    location.GameVars.MapTrainingPause_briefingreaded:=true;
   end;
  if (game as tgame).cntGameFramesRendered>50 then
  begin;
  fck:=true;
  for i:=1 to 20 do
   if assigned(Location.Find_CritterbyID('xplayer'+inttostr(i))) then
    fck:=false;

  if fck and not location.GameVars.MapTrainingPause_over then
    begin;
    (game as tgame).modalwindow_text:=
     'Вы успешно прошли задачу на тренажере'+
     LineEnding;
    (game as tgame).modalwindow_open:=true;
    location.GameVars.MapTrainingPause_over:=true;
    end;
  end;
  if (not (game as tgame).modalwindow_open)
  and (location.GameVars.MapTrainingPause_over) then
   begin;
    (Game as TGame).MapToLoad:='Data'+PathDelim+'MapDust';
   end;
end;

//-----------------------------------------------------------------------------
procedure Maps_Mainloop;//Обработка сценариев карт
begin;
 if not location.GameVars.Maps_welcomereaded then begin;
  _screen.consoleClear;
  _writeln('OIA.▒▒.▒▒▒▒▒▒▒▒.system.UPDATE-2077-195b.Brought.To.You.BY.-=ЦaЕsЯгСrEш=-');
  _writeln('Welcome to Tartarus Coal, Inc.');
  location.GameVars.Maps_welcomereaded:=true;
 end;
 if not location.GameVars.PressF1tohelp_readed then begin;
  _writeln('нажмите [F1] для подсказки');
  location.GameVars.PressF1tohelp_readed:=true;
 end;

 if Location.MapName='MapDust' then Maps_Mainloop_MapDust;
 if Location.MapName='MapTrainingMovement' then Maps_Mainloop_MapTrainingMovement;
 if Location.MapName='MapTrainingCityHospital1' then Maps_Mainloop_MapTrainingCityHospital1;
 if Location.MapName='MapTrainingPause' then Maps_Mainloop_MapTrainingPause;

 Maps_Mainloop_EveryMap;
end;
//-----------------------------------------------------------------------------
procedure Maps_SerializeData;//Сериализация данных карт
begin;
// if Location.MapName='MapDust' then Maps_SerializeData_MapDust;
// if Location.MapName='MapTrainingMovement' then Maps_SerializeData_MapTrainingMovement;
 location.GameVars.Game_over:=
  Location.SerializeFieldB('Game_over',location.GameVars.Game_over);

 location.GameVars.MapDust_over:=
  Location.SerializeFieldB('MapDust_over',location.GameVars.MapDust_over);
 location.GameVars.MapDust_briefingreaded:=
  Location.SerializeFieldB('MapDust_briefingreaded',location.GameVars.MapDust_briefingreaded);
 location.GameVars.Maps_welcomereaded:=
  Location.SerializeFieldB('Maps_welcomereaded',location.GameVars.Maps_welcomereaded);

 location.GameVars.Map_TrainingMovement_1readed:=
  Location.SerializeFieldB('Map_TrainingMovement_1readed',location.GameVars.Map_TrainingMovement_1readed);
 location.GameVars.Map_TrainingMovement_2readed:=
  Location.SerializeFieldB('Map_TrainingMovement_2readed',location.GameVars.Map_TrainingMovement_2readed);
 location.GameVars.Map_TrainingMovement_3readed:=
  Location.SerializeFieldB('Map_TrainingMovement_3readed',location.GameVars.Map_TrainingMovement_3readed);
 location.GameVars.Map_TrainingMovement_4readed:=
  Location.SerializeFieldB('Map_TrainingMovement_4readed',location.GameVars.Map_TrainingMovement_4readed);
 location.GameVars.Map_TrainingMovement_5readed:=
  Location.SerializeFieldB('Map_TrainingMovement_5readed',location.GameVars.Map_TrainingMovement_5readed);
 location.GameVars.Map_TrainingMovement_6readed:=
  Location.SerializeFieldB('Map_TrainingMovement_6readed',location.GameVars.Map_TrainingMovement_6readed);
 location.GameVars.Map_TrainingMovement_7readed:=
  Location.SerializeFieldB('Map_TrainingMovement_7readed',location.GameVars.Map_TrainingMovement_7readed);
 location.GameVars.Map_TrainingMovement_8readed:=
  Location.SerializeFieldB('Map_TrainingMovement_8readed',location.GameVars.Map_TrainingMovement_8readed);
 location.GameVars.Map_TrainingMovement_9readed:=
  Location.SerializeFieldB('Map_TrainingMovement_9readed',location.GameVars.Map_TrainingMovement_9readed);
 Location.SerializeFieldI ('Map_TrainingMovement_penalty',location.GameVars.Map_TrainingMovement_penalty);

 location.GameVars.MapTrainingCityHospital1_briefingreaded:=
  Location.SerializeFieldB('MapTrainingCityHospital1_briefingreaded',
  location.GameVars.MapTrainingCityHospital1_briefingreaded);
 location.GameVars.MapTrainingCityHospital1_over:=
  Location.SerializeFieldB('MapTrainingCityHospital1_over',
  location.GameVars.MapTrainingCityHospital1_over);

 location.GameVars.MapTrainingMovement_over:=
  Location.SerializeFieldB('MapTrainingMovement_over',location.GameVars.MapTrainingMovement_over);
end;

end.
