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

 array_of_string=array of string;

 TSerialObject=class
  public
  SerialTemplateFilename:string;
  SerialTemplateCache:array_of_string;
  SerialTemplateFile:text;
  SerialFileName:string;//Имя файла
  SerialMode:integer;//Режим - чтение,запись,синхронизация,и.т.д.
  SerialFile:text;//Имя файла
  SerialCache:array_of_string;//Кэш чтения
  procedure Save(fileName:string);virtual;//Запись обьекта
  function Load(fileName:string):boolean;virtual;//Чтение обьекта
  function GetFieldValue(aFieldName:string;aOnlyFromTemplate:boolean=false):string;
  procedure SetFieldValue(aFieldName,aValue:string);
  function LoadCache(aSerialFilename:string;var aSerialFile:text;var aSerialCache:array_of_string):boolean;
  function SerializeFieldO(AFieldName:string;AObject:TSerialObject):TSerialObject;//Сериализация Обьекта - поля. Поле должен наследовать от TSerialObject
  procedure SerializeFieldLW(FieldName:string;var Args:LongWord);//Сериализация LongWord
  procedure SerializeFieldQW(FieldName:string;var Args:QWord);//Сериализация LongWord
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
    if SerialTemplateFilename<>'' then begin;LoadCache(SerialTemplateFilename,SerialTemplateFile,SerialTemplateCache);
     SetFieldValue('#template',SerialTemplateFilename);
    end;
    SerializeData;
    Close(SerialFile);
    SetLength(SerialTemplateCache,0);
  end;

  function TSerialObject.LoadCache(aSerialFilename:string;var aSerialFile:text;var aSerialCache:array_of_string):boolean;
   var currStr:integer;
   begin;
    result:=false;
    if fileexists(SerialFileName) then
    begin;
     AssignFile(aSerialFile,aSerialFileName);
     Reset(aSerialFile);
     currStr:=0;
     SetLength(aSerialCache,10);
     repeat
      if currStr=length(aSerialCache)
       then SetLength(aSerialCache,length(aSerialCache)+5);
      readln(aSerialFile,aSerialCache[currStr]);
      inc(currStr);
     until (eof(aSerialFile));
     Close(aSerialFile);
     result:=true;
    end;
   end;

  function TSerialObject.Load(fileName:string):boolean;
  var
   ClassNameTst:string;
   currChstr:integer;
  begin;
    result:=false;
    SerialFileName:=fileName;SerialMode:=smLoad;
    if fileexists(SerialFileName) then
    begin;
     LoadCache(SerialFilename,SerialFile,SerialCache);
     SerialTemplateFilename:=GetFieldValue('#template');//'.'+PathDelim+'Save00'+PathDelim)
     if SerialTemplateFilename<>'' then
      if fileexists(SerialTemplateFileName)then
        LoadCache(SerialTemplateFilename,SerialTemplateFile,SerialTemplateCache)
       else
        log_write('-TSerialObject.Load - template dsnt exists '+SerialTemplateFilename);
     SerializeData;
     result:=true;
     SetLength(SerialCache,0);
     SetLength(SerialTemplateCache,0);
    end;
  end;

  procedure TSerialObject.SetFieldValue(aFieldName,aValue:string);
  var strTemplatedFieldValue:string;
  begin
   if SerialTemplateFilename<>'' then begin
    strTemplatedFieldValue:=GetFieldValue(aFieldName,true);
    if (strTemplatedFieldValue<>aValue)or(aValue='') then
     begin;writeln(SerialFile,aFieldName);writeln(SerialFile,aValue);end;
   end
   else begin;writeln(SerialFile,aFieldName);writeln(SerialFile,aValue);end;
  end;

  function TSerialObject.GetFieldValue(aFieldName:string;aOnlyFromTemplate:boolean=false):string;
  var
   NewFieldValue:string;
   function GetFieldValueActual(aFieldName:string;var aSerialCache:array_of_string):string;
     var currStr:integer;
     begin
      for currStr:=0 to trunc((length(aSerialCache)-1)) do
       if (aSerialCache[currStr]=aFieldName)and(odd(currstr)) then begin;
         if result<>'' then log_write('-TSerialObject.GetFieldValue - duplicate field record '+
               aFieldName+' in '+SerialFileName+' or its template(s)');
         result:=aSerialCache[currStr+1];
        end;
     end;
  begin;
   if not aOnlyFromTemplate then NewFieldValue:=GetFieldValueActual(aFieldName,SerialCache);
   if NewFieldValue='' then NewFieldValue:=GetFieldValueActual(aFieldName,SerialTemplateCache);
   if NewFieldValue<>'' then Result:=NewFieldValue;
  end;

  procedure TSerialObject.SerializeData;
  begin
   //прототип функции сериализации. пустой. в переопределенной ф-ии
   //должны быть вызовы SerializeField над полями обьекта.
  end;

  function TSerialObject.SerializeFieldO(AFieldName:string;AObject:TSerialObject):TSerialObject;
  var
   ResultClass:TSerialObjectClass;
   aNewResult:TSerialObject;
   ResultClassName:string;
   t_filename:string;
   test:boolean;
   t_file:text;
  begin
  result:=aObject;
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
       ' because class '+ResultClassName+' not found in SerialClasses');
      exit;
     end;
    aNewResult:=ResultClass.Create;
    if not(aNewResult.Load(t_filename)) then  begin;
      log_write('-TSerialObject.SerializeFieldO - cant load from file '+
      t_filename+' because '+classname+'.Load failed');
      aNewResult.free;
      aNewResult:=nil;
     end
     else begin;
      if assigned(aObject) then begin;aObject.destroy;end;
      result:=aNewResult;
     end;
   end;
 end;

  procedure TSerialObject.SerializeFieldLW(FieldName:string;var Args:LongWord);
  var strTmp1,NewFieldValue:string;
   NewFieldValueResult:LongWord;
   currChstr:integer;
  begin
    if serialMode=smSave then SetFieldValue(FieldName,IntToStr(Args));
    if serialMode=smLoad then
    begin
     NewFieldValue:=GetFieldValue(FieldName);
     if NewFieldValue<>'' then
      try NewFieldValueResult:=strtoint(NewFieldValue);
      except on EConvertError do Log_write('-'+classname+'.SerializeFieldLW : cant convert '+
       NewFieldValue+' to LWord file: '+SerialFileName+' field: '+FieldName);end;
     if NewFieldValue<>'' then Args:=NewFieldValueResult;
    end;
  end;

  procedure TSerialObject.SerializeFieldQW(FieldName:string;var Args:QWord);//Сериализация QWord
  var strTmp1,NewFieldValue:string;
   NewFieldValueResult:LongWord;
   currChstr:integer;
  begin
    if serialMode=smSave then SetFieldValue(FieldName,IntToStr(Args));
    if serialMode=smLoad then
    begin
     NewFieldValue:=GetFieldValue(FieldName);
     if NewFieldValue<>'' then
      try NewFieldValueResult:=strtoint(NewFieldValue);
      except on EConvertError do Log_write('-'+classname+'.SerializeFieldQW : cant convert '+
       NewFieldValue+' to QWord file: '+SerialFileName+' field: '+FieldName);end;
     if NewFieldValue<>'' then Args:=NewFieldValueResult;
    end;
  end;

  procedure TSerialObject.SerializeFieldFl(FieldName:string;var Args:real);
  var strTmp1,NewFieldValue:string;
   NewFieldValueResult:real;
  currChstr:integer;
  begin
    if serialMode=smSave then SetFieldValue(FieldName,FloatToStr(Args));
    if serialMode=smLoad then
     begin
      NewFieldValue:=GetFieldValue(FieldName);
      if NewFieldValue<>'' then
       try NewFieldValueResult:=strtofloat(NewFieldValue);
       except on EConvertError do Log_write('-'+classname+'.SerializeFieldFl : cant convert '+
        NewFieldValue+' to Float file: '+SerialFileName+' field: '+FieldName);end;
      if NewFieldValue<>'' then Args:=NewFieldValueResult;
     end;
    end;

  procedure TSerialObject.SerializeFieldI(FieldName:string;var Args:integer);
  var strTmp1,NewFieldValue:string;
   NewFieldValueResult:integer;
  currChstr:integer;
  begin
    if serialMode=smSave then SetFieldValue(FieldName,IntToStr(Args));
    if serialMode=smLoad then
     begin
      NewFieldValue:=GetFieldValue(FieldName);
      if NewFieldValue<>'' then
       try NewFieldValueResult:=strtoint(NewFieldValue);
       except on EConvertError do Log_write('-'+classname+'.SerializeFieldI : cant convert '+
        NewFieldValue+' to Integer file: '+SerialFileName+' field: '+FieldName);end;
      if NewFieldValue<>'' then Args:=NewFieldValueResult;
     end;
  end;

  procedure TSerialObject.SerializeFieldS(FieldName:string;var Args:string);
  var strTmp1,NewFieldValue:string;
   currChstr:integer;
  begin;
    if serialMode=smSave then SetFieldValue(FieldName,(Args));
    if serialMode=smLoad then
    begin
      NewFieldValue:=GetFieldValue(FieldName);
      if NewFieldValue<>'' then Args:=NewFieldValue;
    end;
  end;

  function TSerialObject.SerializeFieldB(FieldName:string;Args:boolean):boolean;
  var strTmp1,strTmp2,NewFieldValue:string;
   NewFieldValueResult:boolean;
   currChstr:integer;
  begin;
    if serialMode=smSave then begin;
     Result:=Args;
     if Args then SetFieldValue(FieldName,'True') else SetFieldValue(FieldName,'False');
    end;
    if serialMode=smLoad then
    begin;
      Result:=Args;
      NewFieldValue:=GetFieldValue(FieldName);
      if NewFieldValue<>'' then
       try NewFieldValueResult:=StrToBool(NewFieldValue);
       except on EConvertError do Log_write('-'+classname+'.SerializeFieldB : cant convert '+
        NewFieldValue+' to Boolean file: '+SerialFileName+' field: '+FieldName);end;
      if NewFieldValue<>'' then Result:=NewFieldValueResult;
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
