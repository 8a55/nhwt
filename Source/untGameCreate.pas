unit untGameCreate;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$TYPEINFO ON}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ interface----- -------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
interface
uses untGame,untGUI;

type

TGameCreate=class(TGameAbstract)// default game class aka MAIN MENU
public
state:integer;
tagskills,tagtraits,charpoints:integer;
Menu_Create:TGUI_menu;
procedure MainLoop_prim;
procedure MainLoop_traits;
procedure MainLoop_skills;
procedure MainLoop_secondary;
procedure MainLoop;override;
procedure AdjState;
constructor Create;override;
destructor Destroy;override;
end;



implementation
uses
{$IFnDEF FPC}
  windows,
{$ELSE}
  //LCLIntf, LCLType, LMessages,
{$ENDIF}
  untConsole,untGameEditor,untWorld,sysutils,untActorBase,untUtils,untTCharacter,untTScreen
  ,CastleKeysMouse;
var Player:TCreature;
currcomment:string;
const
cc_name='Имя персонажа.';
cc_STR='Грубая физическая сила. Влияет на способности наносить вред ближнему.';
cc_PE='Способность к воприятию внешнего мира:слух,зрение,осязание.';
cc_EN='Степень выносливости персонажа.';
cc_CH='Обаяние персонажа. Влияет на отношения с людьми и цены.';
cc_INT='Знание, мудрость и способность думать быстро. Важна всем.';
cc_AG='Координация движений и способность быстро двигаться.';
cc_LK='Кармическая способность отводить неприятности и призывать Шару.';

cc_nextstep='Следущий шаг в создании персонажа';
cc_prevstep='Предедущий шаг в создании персонажа';

cc_defname='Unnamed One';

cc_skillwarn='Are your a SuperDog? normal humans only have three skills';


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//------------------------------ TGAME.CREATE ---------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

destructor TGameCreate.Destroy;
begin;
 //Create.free;
 //Player.free;
end;

constructor TGameCreate.Create;
begin;
Menu_Create:=TGUI_menu.Create;
//Menu_create.xpos_comment:=1;
//Menu_create.ypos_comment:=1;
Menu_create.ypos_content:=Menu_create.ypos_content-1;
Menu_create.ypos_comment:=maxyscreen-1;;
Player:=TCreature.create;
Player.name:=cc_defname;
Player.id:=idPLayer;
player.Sklmtrx_WriteParam(prmSTR,modBase,5);
player.Sklmtrx_WriteParam(prmPE,modBase,5);
player.Sklmtrx_WriteParam(prmEN,modBase,5);
player.Sklmtrx_WriteParam(prmCH,modBase,5);
player.Sklmtrx_WriteParam(prmINT,modBase,5);
player.Sklmtrx_WriteParam(prmAG,modBase,5);
player.Sklmtrx_WriteParam(prmLK,modBase,5);
charpoints:=5;
tagskills:=3;
tagtraits:=2;
end;

procedure TGameCreate.MainLoop;
begin;
//case state of
//0:
 MainLoop_prim;
{1: MainLoop_skills;
2: MainLoop_traits;
3: MainLoop_secondary;
end;}
end;

procedure AdjInt(var inte:integer;max,min:integer);
begin;
if (lastkey=k_left)and(inte>min)then dec(inte);
if (lastkey=k_right)and(inte<max)then inc(inte);
end;

procedure TGameCreate.AdjState;
begin;
if (lastkey=k_left)and(state>0)then dec(state);
if (lastkey=k_right)and(state<3)then inc(state);//bug bug bug
player.sklmtrx_DumpMtrx;
player.Save('player. ');//debug feat.
end;

procedure TGameCreate.MainLoop_secondary;
begin;
end;

procedure TGameCreate.MainLoop_traits;
var j:integer;s:string;
begin;
end;

procedure TGameCreate.MainLoop_skills;
var j:integer;

procedure calc_skills;
begin;
end;

begin;//maxSkills skillsName player.Sklmtrx_ Sklmtrx_
player.Sklmtrx_Recalculate;
Menu_Create.Clear;
calc_skills;
for j:=0 to maxSkills
do

if player.Sklmtrx_GetParam(prmFirstTagSkill+j,modResult)<>0 then
Menu_Create.AddItem(' '+strDOP(strskillsName[j],15)+' '+inttostr(player.Sklmtrx_GetParamRes(prmFirstTagSkill+j)*2)+' [T]')
else
Menu_Create.AddItem(' '+strDOP(strskillsName[j],15)+' '+inttostr(player.Sklmtrx_GetParamRes(prmFirstSkill+j))+' [ ]');
Menu_Create.AddItem('======================');
Menu_Create.AddItem('<- Prev | Next->');
_screen.clear;
// tagskills
// MainLoopEX('Create players character:Select and tag skills',currcomment);
Menu_Create.MainLoop('Create players character:Select and tag skills');
if (Menu_Create.executed>=0) then
 if (Menu_Create.executed<=maxSkills) then
 begin;
  if player.Sklmtrx_GetParamRes(prmFirstTagSkill+Menu_Create.executed)<>0 then
  begin;
   inc(tagskills);
   player.Sklmtrx_WriteParam(1,prmFirstTagSkill+Menu_Create.executed,modResult);
  end
 else
begin;
if tagskills>0 then
begin;dec(tagskills);
 player.Sklmtrx_WriteParam(1,prmFirstTagSkill+Menu_Create.executed,modResult);
end
else Menu_Create.comment:=cc_skillwarn;
end;
end;

if Menu_Create.selected=maxskills+2 then AdjState;
end;

//-----------------------------------------------------------------------------
//------------------------------ TGameCreate.MainLoop_prim --------------------
procedure TGameCreate.MainLoop_prim;
var iCSkill,iCTrait:integer;

function AdjPrim(inp:integer;max,min:integer):integer;
begin;result:=inp;
if (lastkey=k_left) then
 if (result>min)
then begin;dec(result);inc(charpoints);end;
if (lastkey=k_right)and(result<max)and(charpoints>0)
then begin;inc(result);dec(charpoints);end;
end;

procedure ehh(a_name:string;a_param:integer);
var b,p:string;
begin;b:=' ';p:=' ';
if a_param > 1 then b:='<';
if a_param < 10 then p:='>';
Menu_Create.AddItem(b+a_name+p+' '+inttostr(a_param)+' ');
end;
begin;
case Menu_Create.selected of
0: currcomment:=cc_name;
1: currcomment:=cc_str;
2: currcomment:=cc_PE;
3: currcomment:=cc_EN;
4: currcomment:=cc_Ch;
5: currcomment:=cc_INT;
6: currcomment:=cc_AG;
7: currcomment:=cc_LK;
9: currcomment:=cc_nextstep ;
end;
    //Создание меню.
    Menu_Create.Clear;
    //Настройка имени.
    Menu_Create.AddItem(' Choose name: '+player.name+' ');
    //Primary
    ehh(' Strength ',player.Sklmtrx_getparam(prmSTR,modResult));
    ehh(' Perception ',player.Sklmtrx_getparam(prmPE,modResult));
    ehh(' Endurance ',player.Sklmtrx_getparam(prmEN,modResult));
    ehh(' Charisma ',player.Sklmtrx_getparam(prmCH,modResult));
    ehh(' Intelligent ',player.Sklmtrx_getparam(prmINT,modResult));
    ehh(' Agility ',player.Sklmtrx_getparam(prmAG,modResult));
    ehh(' Luck ',player.Sklmtrx_getparam(prmLK,modResult));
    Menu_Create.AddItem('= Skill selecting =');
    //Skills
    for iCSkill:=0 to prmLastSkill-prmFirstSkill do
     if player.Sklmtrx_GetParam(prmFirstTagSkill+iCSkill,modResult)<>0 then
      Menu_Create.AddItem(strSkillsName[iCSkill]+' '+inttostr(player.Sklmtrx_getparam(prmFirstSkill+iCSkill,modResult))+'% (T) ')
      else
      Menu_Create.AddItem(strSkillsName[iCSkill]+' '+inttostr(player.Sklmtrx_getparam(prmFirstSkill+iCSkill,modResult))+'% ( ) ');
    //Perks
    Menu_Create.AddItem('= Perks selecting =');
    for iCTrait:=0 to prmLastTrait-prmFirstTrait do
     if player.Sklmtrx_GetParam(prmFirstTrait+iCTrait,modResult)<>0 then
      Menu_Create.AddItem(strTraitsName[iCTrait]+' '+' (T) ')
      else
      Menu_Create.AddItem(strTraitsName[iCTrait]+' '+' ( ) ');
    _screen.clear;
    Menu_Create.MainLoopEX('= Player creation process =',currcomment);
    _screen.writeXY('= Secondary statistics =',0,5,lyGui);
    _screen.writeXY(' Max carry weight: '+inttostr(player.Sklmtrx_GetParam(prmMaxCWeight,modResult))+' ',0,6,lyGui);
    _screen.writeXY(' HP: '+inttostr(player.Sklmtrx_GetParam(prmBaseHP,modResult))+' ',0,7,lyGui);
    _screen.writeXY(' AC: '+inttostr(player.Sklmtrx_GetParam(prmAC,modResult))+' ',0,8,lyGui);
    _screen.writeXY(' AP: '+inttostr(player.Sklmtrx_GetParam(prmAP,modResult))+' ',0,9,lyGui);
    _screen.writeXY(' MeleeDamage: '+inttostr(player.Sklmtrx_GetParam(prmMeleeDamage,modResult))+' ',0,10,lyGui);
    _screen.writeXY(' Poison resist: '+inttostr(player.Sklmtrx_GetParam(prmPoisResist,modResult))+' ',0,11,lyGui);
    _screen.writeXY(' Rad resist: '+inttostr(player.Sklmtrx_GetParam(prmRadResist,modResult))+' ',0,12,lyGui);
    _screen.writeXY(' Sequence: '+inttostr(player.Sklmtrx_GetParam(prmSequence,modResult))+' ',0,13,lyGui);
    _screen.writeXY(' Healing rate: '+inttostr(player.Sklmtrx_GetParam(prmHealRate,modResult))+' ',0,14,lyGui);
    _screen.writeXY(' Critical chance: '+inttostr(player.Sklmtrx_GetParam(prmCritChance,modResult))+' ',0,15,lyGui);
    _screen.writeXY('= Outstanding points =',0,17,lyGui);
    if charpoints>0 then _screen.writeXY(' Character points: '+inttostr(charpoints)+' ',0,18,lyGui);
    if tagskills>0 then _screen.writeXY(' Skill tags remain: '+inttostr(tagskills)+' ',0,19,lyGui);
    if tagtraits>0 then _screen.writeXY(' Traits tags remain: '+inttostr(tagtraits)+' ',0,20,lyGui);
    //SPECIAL
    if Menu_Create.selected=1 then player.Sklmtrx_writeparam(prmSTR,modBase,AdjPrim(player.Sklmtrx_getparam(prmSTR,modBase),10,1));
    if Menu_Create.selected=2 then player.Sklmtrx_writeparam(prmPE,modBase,AdjPrim(player.Sklmtrx_getparam(prmPE,modBase),10,1));
    if Menu_Create.selected=3 then player.Sklmtrx_writeparam(prmEN,modBase,AdjPrim(player.Sklmtrx_getparam(prmEN,modBase),10,1));
    if Menu_Create.selected=4 then player.Sklmtrx_writeparam(prmCH,modBase,AdjPrim(player.Sklmtrx_getparam(prmCH,modBase),10,1));
    if Menu_Create.selected=5 then player.Sklmtrx_writeparam(prmINT,modBase,AdjPrim(player.Sklmtrx_getparam(prmINT,modBase),10,1));
    if Menu_Create.selected=6 then player.Sklmtrx_writeparam(prmAG,modBase,AdjPrim(player.Sklmtrx_getparam(prmAG,modBase),10,1));
    if Menu_Create.selected=7 then player.Sklmtrx_writeparam(prmLK,modBase,AdjPrim(player.Sklmtrx_getparam(prmLK,modBase),10,1));
    // выбор имени
    if Menu_Create.selected=0 then
    begin;
    {if ((((lastkey>ord('a')-1) AND (lastkey<ord('z')))or
    ((lastkey>ord('A')-1) AND (lastkey<ord('Z')))or
    ((lastkey>ord('а')-1) AND (lastkey<ord('я')))or
    ((lastkey>ord('А')-1) AND (lastkey<ord('Я'))))
    or (lastkey=8))
    and(player.name=cc_defname)
    then player.name:='';
    if (lastkey=8) then player.name:=copy(player.name,0,length(player.name)-1) else
    if ((lastkey>ord('a')-1) AND (lastkey<ord('z')))or
    ((lastkey>ord('A')-1) AND (lastkey<ord('Z')))or
    ((lastkey>ord('а')-1) AND (lastkey<ord('я')))or
    ((lastkey>ord('А')-1) AND (lastkey<ord('Я')))
    then   }
    // if kkey<>char(0) then player.name:=player.name+kkey;
    end;
    // Выбор скиллов.
    if (Menu_Create.selected>=9)and(Menu_Create.selected<29)then //9 - first item for skill tagging
    begin;
     if lastkey=k_enter then
      if player.Sklmtrx_GetParam(prmFirstTagSkill+Menu_Create.selected-9,modBase)<>0 then
       begin;player.Sklmtrx_WriteParam(prmFirstTagSkill+Menu_Create.selected-9,modBase,0);inc(tagskills);end
       else
       if tagskills>0 then
       begin;player.Sklmtrx_WriteParam(prmFirstTagSkill+Menu_Create.selected-9,modBase,1);dec(tagskills);end;
    end;
    if (Menu_Create.selected>=29)and(Menu_Create.selected<46) then
    begin;
     if lastkey=k_enter then
      if player.Sklmtrx_GetParam(prmFirstTrait+Menu_Create.selected-29,modBase)<>0 then
       begin;player.Sklmtrx_WriteParam(prmFirstTrait+Menu_Create.selected-29,modBase,0);inc(tagtraits);end
       else
       if tagtraits>0 then
       begin;player.Sklmtrx_WriteParam(prmFirstTrait+Menu_Create.selected-29,modBase,1);dec(tagtraits);end;
    end;
    //player.Sklmtrx_CurrHP:=player.Sklmtrx_GetParamRes(prmBaseHP);
    //player.Sklmtrx_BaseHP:=player.Sklmtrx_GetParamRes(prmBaseHP);
    player.Sklmtrx_WriteParam(prmCurrHP,modPrim,player.Sklmtrx_GetParamRes(prmBaseHP));
    player.size:=sizeLarge;
    if lastkey=k_D then player.sklmtrx_DumpMtrx;
    if lastkey=k_F6 then player.Save('player');
    if lastkey=k_F5 then player.Load('player');
end;

end.
