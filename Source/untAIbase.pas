unit untAIbase;//не используеться

interface
uses untActorBase;
type

 TPerceptedCritter = class
  TimeWhen:longword; //Âðåìÿ îáíàðóæåíèÿ êðèòòåðà.
  xpos,ypos,zpos:integer;
  id:string;
 end;

 TAI_controller = class
  PerceptedCritters:array of TPerceptedCritter;
  procedure AddPercepted(infl:TInfluence);virtual;
  function  FindAlikePercepted(infl:TInfluence):integer;virtual;
  procedure RemovePercepted(infl:TInfluence);virtual;
 end;

implementation
uses untActorBase;

 procedure TAI_controller.RemovePercepted(infl:TInfluence);
  var i:integer;
  begin;
   for i:=0 to length(PerceptedCritters) do
    if assigned(PerceptedCritters[i]) then
     if PerceptedCritters[i].id=infl.parent then
      begin;PerceptedCritters[i].free;PerceptedCritters[i]:=nil;end;
  end;

  function TAI_controller.FindAlikePercepted(infl:TInfluence):integer;
  var i:integer;
  begin;
   result:=-1;
   for i:=0 to length(PerceptedCritters)-1 do
    if assigned(PerceptedCritters[i]) then
     if PerceptedCritters[i].id=infl.parent then result:=i;
  end;

  procedure TAI_controller.AddPercepted(infl:TInfluence);
  var i:integer;
  begin;
   for i:=0 to length(PerceptedCritters) do
    if not(assigned(PerceptedCritters[i])) then
     begin;
     PerceptedCritters[i]:=TPerceptedCritter.Create;
     PerceptedCritters[i].TimeWhen:=Location.time;
     PerceptedCritters[i].id:=infl.parent;
     PerceptedCritters[i].xpos:=infl.xpos;
     PerceptedCritters[i].ypos:=infl.ypos;
     PerceptedCritters[i].zpos:=infl.zpos;
     exit;
     end;
  end;

end.
