//- untLog ----------------------------------------------------------------
// Поддержка ведения лога
// maniac


unit untLog;

{$mode objfpc}{$H+}

{$TYPEINFO ON}

{$DEFINE LOG_SLOW}

interface
var text1:text;
//введен по просьбам трудящихся... то есть маньяка.

procedure Log_write(astr:string);

implementation
procedure Log_write(astr:string);
begin;
 {$IFDEF LOG_SLOW}
  assign(text1,'_log.txt');append(text1);
  writeln(text1,astr);close(text1);
 {$ENDIF}
 {$IFNDEF LOG_SLOW}
   writeln(text1,astr);
 {$ENDIF}
end;
begin;
 {$IFDEF LOG_SLOW}
  assign(text1,'_log.txt');rewrite(text1);close(text1);
 {$ENDIF}
 {$IFNDEF LOG_SLOW}
  assign(text1,'_log.txt');rewrite(text1);
 {$ENDIF}
end.
