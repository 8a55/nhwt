program NHWT;

{$apptype GUI}

{$mode objfpc}{$H+}

{%File 'Source\untActorBaseConst.pas'}
{%ToDo 'NHWT.todo'}

uses
{$IFnDEF FPC}
{$ELSE}
  //Interfaces,
{$ENDIF}
 // Forms,
  {$ifdef unix}
   cwstring,
  {$endif}
  LazUTF8
  ,untConsole {frmCon}
  ,untWorld
  ,untGameMenu
  ,untGameEditor
  ,untGame
  ,untSerialize
  ,untGUI
  ,untActorBase
  ,untUtils
  ,untMonster_GiAnt
  ,untLog
  ,untGameCreate
  ,untTCharacter
  ,untTAction
  ,untTItem
  ,untTInfluence
  ,untAI
  ,untWounds
  ,untSpeak
  ,untTLandscape
  ,sysutils
  ,fileinfo
  ,winpeimagereader
  ,elfreader
  ,machoreader
  ;



{$R *.res}

begin

  FileVerInfo:=TFileVersionInfo.Create(nil);
  try
    FileVerInfo.FileName:=paramstr(0);
    FileVerInfo.ReadFileInfo;
{    writeln('Company: ',FileVerInfo.VersionStrings.Values['CompanyName']);
    writeln('File description: ',FileVerInfo.VersionStrings.Values['FileDescription']);
    writeln('File version: ',FileVerInfo.VersionStrings.Values['FileVersion']);
    writeln('Internal name: ',FileVerInfo.VersionStrings.Values['InternalName']);
    writeln('Legal copyright: ',FileVerInfo.VersionStrings.Values['LegalCopyright']);
    writeln('Original filename: ',FileVerInfo.VersionStrings.Values['OriginalFilename']);
    writeln('Product name: ',FileVerInfo.VersionStrings.Values['ProductName']);
    writeln('Product version: ',FileVerInfo.VersionStrings.Values['ProductVersion']);
}
  finally
//    FileVerInfo.Free;
  end;

  untConsole.Window.OpenAndRun;

end.
