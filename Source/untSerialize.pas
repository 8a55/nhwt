//- untSerialize ----------------------------------------------------------------
// Базовый класс для сериализуемых обьектов.
// maniac

unit untSerialize;

{$mode objfpc}{$H+}

{$TYPEINFO ON}

interface
uses Classes;
const
 smSave=1;
 smLoad=2;

type
 TSerialObject=class
  public
  SerialFileName:string;//Имя файла
  SerialMode:integer;//Режим - чтение,запись,синхронизация,и.т.д.
  SerialFile:text;//Имя файла
  SerialCache:array of string;//Кэш чтения
  procedure Save(fileName:string);virtual;//Запись обьекта
  function Load(fileName:string):boolean;virtual;//Чтение обьекта
  function SerializeFieldO(AFieldName:string;AObject:TSerialObject):TSerialObject;//Сериализация Обьекта - поля. Поле должен наследовать от TSerialObject
  procedure SerializeFieldLW(FieldName:string;var Args:LongWord);//Сериализация LongWord
  procedure SerializeFieldI(FieldName:string;var Args:integer);//Сериализация Integer
  procedure SerializeFieldFl(FieldName:string;var Args:real);//Сериализация Integer
  procedure SerializeFieldS(FieldName:string;var Args:string);//Сериализация String
  function SerializeFieldB(FieldName:string;Args:boolean):boolean;//Сериализация Boolean
  procedure SerializeData;virtual;//Переопределяемая функция собсно чтения - записи данных
  constructor Create;virtual;//Конструктор.
 end;

 TSerialObjectClass=class of TSerialObject;

 //список классов пригодных для сериализации
 function FindSerialClass(a_classname:string):TSerialObjectClass;//поиск класса по имени
 procedure AddSerialClass(a_class:TSerialObjectClass);overload;//регистрация класса
 procedure AddSerialClass(a_classname:string;a_class:TSerialObjectClass);overload;

 var
 SerialClasses:array of record
  classname:string;
  serialclass:TSerialObjectClass;
 end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ implementation -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

implementation
uses SysUtils,untLog,untConsole,untActorBase;

  constructor TSerialObject.Create;
  begin;
   //
  end;

  procedure TSerialObject.Save(fileName:string);
  begin
    SerialFileName:=fileName;SerialMode:=smSave;
    AssignFile(SerialFile,SerialFileName);
    Rewrite(SerialFile);
    writeln(serialfile,self.ClassName);
    SerializeData;
    Close(SerialFile);
  end;

  function TSerialObject.Load(fileName:string):boolean;
  var ClassNameTst:string;
   currChstr:integer;
  begin;
    result:=false;
    SerialFileName:=fileName;SerialMode:=smLoad;
    if fileexists(SerialFileName) then
    begin;
     AssignFile(SerialFile,SerialFileName);
     Reset(SerialFile);
     currChstr:=0;
     SetLength(SerialCache,10);
     repeat
      if currChstr=length(SerialCache)
       then SetLength(SerialCache,length(SerialCache)+5);
      readln(serialFile,SerialCache[currChstr]);
      inc(currChstr);
     until (eof(serialFile));
     SerializeData;
     result:=true;
     Close(SerialFile);
     SetLength(SerialCache,0);
    end;
  end;

  procedure TSerialObject.SerializeData;
  begin
   //прототип функции сериализации. пустой. в переопределенной ф-ии
   //должны быть вызовы SerializeField над полями обьекта.
  end;

  function TSerialObject.SerializeFieldO(AFieldName:string;AObject:TSerialObject):TSerialObject;
  var
   ResultClass:TSerialObjectClass;
   ResultClassName:string;
   t_filename:string;
   test:boolean;
   t_file:text;
  begin
  result:=nil;
  t_filename:=SerialFileName+'_'+AFieldName;
  if serialMode=smSave then if assigned(AObject) then begin;
   AObject.Save(t_filename);result:=AObject;
  end;
  if serialMode=smLoad then
   begin;
    if not(fileexists(t_filename)) then begin;
       log_write('-TSerialObject.SerializeFieldO - cant load from file '+t_filename+
        ' because file not exists');
       exit;
     end;
    AssignFile(t_file,t_filename);
     Reset(t_file);
     readln(t_file,ResultClassName);
    CloseFile(t_file);
    ResultClass:=FindSerialClass(ResultClassName);
    if ResultClass=nil then begin;
      log_write('-TSerialObject.SerializeFieldO - cant load from file '+t_filename+
       ' because class '+classname+' not found in SerialClasses');
      exit;
     end;
    Result:=ResultClass.Create;
    if not(Result.Load(t_filename)) then  begin;
      log_write('-TSerialObject.SerializeFieldO - cant load from file '+
      t_filename+' because '+classname+'.Load failed');
      Result.free;
      Result:=nil;
     end;
   end;
 end;

  procedure TSerialObject.SerializeFieldLW(FieldName:string;var Args:LongWord);
  var strTmp1:string;
   currChstr:integer;
  begin
    if serialMode=smSave then begin;writeln(SerialFile,FieldName);writeln(SerialFile,Args);end;
    if serialMode=smLoad then
    begin
	     for currChstr:=0 to length(SerialCache)-1 do
		      if SerialCache[currChstr]=FieldName
		       then begin;Args:=strtoint(SerialCache[currChstr+1]);exit;end;
    end;
  end;

  procedure TSerialObject.SerializeFieldFl(FieldName:string;var Args:real);
  var strTmp1:string;
  currChstr:integer;
  begin
    if serialMode=smSave then
    begin;
     writeln(SerialFile,FieldName);
     writeln(SerialFile,floattostr(Args));
    end;
    if serialMode=smLoad then
    begin
    for currChstr:=0 to length(SerialCache)-1 do
    if SerialCache[currChstr]=FieldName then
     begin;
      try
       Args:=strtofloat(SerialCache[currChstr+1]);
      except
       //else;
       on EConvertError do
        Log_write('-'+classname+'.SerializeFieldFl : cant convert '+
         SerialCache[currChstr+1]+' to float'+' file: '+SerialFileName+
         ' field: '+FieldName);
       end;
      end;
      exit;
     end;
    end;

  procedure TSerialObject.SerializeFieldI(FieldName:string;var Args:integer);
  var strTmp1:string;
  currChstr:integer;
  begin
    if serialMode=smSave then begin;writeln(SerialFile,FieldName);writeln(SerialFile,Args);end;
    if serialMode=smLoad then
    begin
    for currChstr:=0 to length(SerialCache)-1 do
     if SerialCache[currChstr]=FieldName
      then begin;Args:=strtoint(SerialCache[currChstr+1]);exit;end;
    end;
  end;

  procedure TSerialObject.SerializeFieldS(FieldName:string;var Args:string);
  var strTmp1:string;
  currChstr:integer;
  begin;
    if serialMode=smSave then begin;writeln(SerialFile,FieldName);writeln(SerialFile,Args);end;
    if serialMode=smLoad then
    begin
    for currChstr:=0 to length(SerialCache)-1 do
     if SerialCache[currChstr]=FieldName
      then begin;Args:=SerialCache[currChstr+1];exit;end;
     end;
  end;

  function TSerialObject.SerializeFieldB(FieldName:string;Args:boolean):boolean;
  var strTmp1,strTmp2:string;
  currChstr:integer;
  begin;
    if serialMode=smSave then begin;writeln(SerialFile,FieldName);writeln(SerialFile,Args);result:=Args;end;
    if serialMode=smLoad then
    begin
     result:=false;
     for currChstr:=0 to length(SerialCache)-1 do
     if SerialCache[currChstr]=FieldName then
     begin;
      strTmp2:=SerialCache[currChstr+1];
      if (strTmp2='TRUE') or (strtmp2='true') or (strtmp2='True')or (strtmp2='1')or(strtmp2='+')
      then result:=true
      else
       begin;
       if (strTmp2='FALSE') or (strtmp2='false') or (strtmp2='False') or (strtmp2='0') or (strtmp2='-') then result:=false
       else Log_write('-ERROR - TSerialObject.SerializeFieldB unknown field value '+FieldName+' value - '+strtmp2+' in '+SerialFileName);
       end;
      exit;
     end;
    end;
  end;

 function FindSerialClass(a_classname:string):TSerialObjectClass;
 var j:integer;
 begin
  result:=nil;
  for j:=0 to length(SerialClasses)-1 do
   if SerialClasses[j].classname=a_classname then
   begin;
    result:=SerialClasses[j].SerialClass;
    break;
   end;
 end;

 procedure AddSerialClass(a_class:TSerialObjectClass);
 begin;
  AddSerialClass(a_class.ClassName,a_class);
 end;

 procedure AddSerialClass(a_classname:string;a_class:TSerialObjectClass);
 begin;
  if findserialclass(a_classname)<>nil then
   begin;
    log_write('-AddSerialClass '+a_classname+' is already in SerialClasses');
    exit;
   end;
  SetLength(SerialClasses,length(SerialClasses)+1);
  SerialClasses[length(SerialClasses)-1].classname:=a_classname;
  SerialClasses[length(SerialClasses)-1].serialclass:=a_class;
 // log_write('+AddSerialClass added '+a_classname);
  if a_classname<>a_class.ClassName then log_write('-AddSerialClass - a_classname<>a_class.Classname alias?');
 end;

begin;
// SetLength(SerialClasses,0);
end.
