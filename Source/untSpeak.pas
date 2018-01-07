//- untActorBase ----------------------------------------------------------------
// Инфлюнсы для болталки. 
// maniac

unit untSpeak;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untActorBase,untActorBaseConst,untTInfluence;
//Разговоры.
//делаем чат
 type
 TInfluence_Sound_Talk=class(TInfluence_Sound)
 public
  text:string;
  procedure Tick;override;
 end;

 TInfluence_Sound_Talk_Begin=class(TInfluence_Sound_Talk)//инициирование разговора
   procedure Tick;override;
 end;

 TInfluence_Sound_Talk_Speech=class(TInfluence_Sound_Talk)//Текст сказанный от лица (host)
   procedure Tick;override;
 end;

 TInfluence_Sound_Talk_PossiblePhrase=class(TInfluence_Sound_Talk)//Возможный ответ.
   procedure Tick;override;
 end;

 TInfluence_Sound_Talk_Answer=class(TInfluence_Sound_Talk)//ответ.
   procedure Tick;override;
 end;

 TInfluence_Sound_Talk_End=class(TInfluence_Sound_Talk)//финал разговора. освободить ГИП
  procedure Tick;override;
 end;

 //-----------------------------------------------------------------------------
 //-----------------------------------------------------------------------------
 //------------------------------ implementation -------------------------------
 //-----------------------------------------------------------------------------
 //-----------------------------------------------------------------------------
implementation
uses untGame,untWorld,untConsole;

//-----------------------------------------------------------------------------
procedure TInfluence_Sound_Talk_End.Tick;
begin;
 inherited;
 (Game as TGame).chat_open:=false;
 (Game as TGame).Menu_Chat.Clear;
 samokill;
end;
//-----------------------------------------------------------------------------
procedure TInfluence_Sound_Talk_Begin.Tick;
begin;
 inherited;
 if parent<>target then begin;
  (Game as TGame).chat_open:=true;
  (Game as TGame).Menu_Chat.Clear;
  (Game as TGame).Menu_Chat.title:=text;
 end;
 samokill;
end;
//-----------------------------------------------------------------------------
procedure TInfluence_Sound_Talk.Tick;
begin;
 inherited;
 //_writeln(location.Find_CritterbyID(self.parent).name+' сказал: '+text);
 //samokill;
end;
//-----------------------------------------------------------------------------
procedure TInfluence_Sound_Talk_Speech.Tick;
begin;
 inherited;
 if (game as TGame).chat_open then begin;//чатилка открыта, пишем фразу
  (Game as TGame).Menu_Chat.Clear;
  (Game as TGame).Menu_Chat.comment:=text;
 end
 else //иначе пишем в консоль
  _writeln(location.Find_CritterbyID(self.parent).name+' сказал: '+text);
 samokill;
end;
//-----------------------------------------------------------------------------
procedure TInfluence_Sound_Talk_PossiblePhrase.Tick;
begin;
 inherited;
 (Game as TGame).Menu_Chat.AddItem(text);
 samokill;
end;
//-----------------------------------------------------------------------------
procedure TInfluence_Sound_Talk_Answer.Tick;
begin;
 inherited;
// samokill;
end;

end.
