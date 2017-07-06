unit untShell;
 {$TYPEINFO ON}
interface
var
 canexit:boolean;
 procedure beginexecute;
implementation
uses untConsole,untWorld,untGameMenu,untGameEditor;
 procedure beginexecute;
 begin;
  _screen.writeln('welcome to poseidon oil');
  location:=TLocation.create;
  Game:=TGameMenu.Create;//
 end;
end.
