//- untActorBaseConst ----------------------------------------------------------------
// Константы. 
// maniac

const

maxParams=74;
maxModifs=6;

modBase=0;// Базовые параметры (ДОЛЖНЫ ИЗМ ТОЛЬКО ПРИ ГЕНЕРАЦИИ)(кроме перков-тагов и скилл-тагов)
// aka SPECIAL,SkillTags,PerkTags;
modPrim=1;// Параметры зависимые от ОСНОВНЫХ
modPerk=2;// Параметры зависимые от ПЕРКОВ
modTrait=3;// Параметры зависимые от ТРЕЙТОВ и начальные бонуса от скилл-тагов (20%)
modUser=4;//   Пользовательские изменения ?????????
modDrugs=5; // Изменения наркотой и подобными воздействиями

modLastNumModif=5;//последний модификатор. После него только результ.

modResult=6; //MUST BE LAST IN Params table;

prmSTR=0; // догадайтесь, что это? 8)
prmPE=1;
prmEN=2;
prmCH=3;
prmINT=4;
prmAG=5;
prmLK=6;

prmFirstSkill=7; // номер первого скилла

prmSmallGuns=7;
prmBigGuns=8;
prmEnergyWeapons=9;
prmUnarmed=10;
prmMeleeWeapons=11;
prmThrowing=12;
prmFirstAid=13;
prmDoctor=14;
prmDriving=15;
prmSneak=16;
prmLockpick=17;
prmSteal=18;
prmTraps=19;
prmScience=20;
prmRepair=21;
prmSpeech=22;
prmBarter=23;
prmGambling=24;
prmOutdoorsman=25;

prmLastSkill=25; // номер последнего скилла

prmFirstTagSkill=26;

prmTagSmallGuns=26;
prmTagBigGuns=27;
prmTagEnergyWeapons=28;
prmTagUnarmed=29;
prmTagMeleeWeapons=30;
prmTagThrowing=31;
prmTagFirstAid=32;
prmTagDoctor=33;
prmTagDriving=34;
prmTagSneak=35;
prmTagLockpick=36;
prmTagSteal=37;
prmTagTraps=38;
prmTagScience=39;
prmTagRepair=40;
prmTagSpeech=41;
prmTagBarter=42;
prmTagGambling=43;
prmTagOutdoorsman=44;

prmLastTagSkill=44;

prmFirstTrait=45;

prmTrtFastMetabolism=45;
prmTrtBruiser=46;
prmTrtSmallFrame=47;
prmTrtOneHander=48;
prmTrtFinesse=49;
prmTrtKamikaze=50;
prmTrtHeavyHanded=51;
prmTrtFastShot=52;
prmTrtBloodyMess=53;
prmTrtJinxed=54;
prmTrtGoodNatured=55;
prmTrtChemReliant=56;
prmTrtChemResistant=57;
prmTrtNightPerson=58;
prmTrtSkilled=59;
prmTrtGifted=60;
prmTrtSexAppeal=61;

prmLastTrait=61;

prmBaseHP=62;
prmCurrHP=63;
prmAC=64;
prmAP=65;
prmMaxCWeight=66;
prmCurrCWeight=67;
prmPoisResist=68;
prmRadResist=69;
{prmDR:DRRecord;
  DT:DTRecord;}
prmHealRate=70;
prmCritChance=71;
prmMeleeDamage=72;
prmSequence=73;
prmSex=74;//пол персонажа

//завернуты из common strings
racMin=1;
racHuman=1;
strHuman='human';// 8\
racEpony=2;
strEpony='зем.пони';
racUnicorn=2;
strUnicorn='единорог';
racPegasus=3;
strPegasus='пегас';
racGhoul=4;
strGhoul='гул';
racMax=4;

sexMale=0;
sexFemale=1;
strMale='муж.';
strFemale='жен.';

maxInventoryItems=255;
maxSkills=18;
maxTraits=16;

//меньше 3 - обьекты ?
sizeSmaller=3;//крысы
sizeSmall=4;
sizeMedium=5;
sizeLarge=6;//size for human and human-like creatures;
sizeLargest=7;//super mutants, d-claw и прочее "бальшое и страшное".

//Стороны света.
cmpNord=0;
cmpNordEast=45;
cmpEast=90;
cmpSouthEast=135;
cmpSouth=180;
cmpSouthWest=225;
cmpWest=270;
cmpNordWest=315;

//Органы чувств
snsVisual=0;
snsSound=1;
snsEtheral=2;

//Физика
stOpaque=2;//прозрачный предмет, стекло например
stSolid=1;//твердый предмет
stEtheral=0;//нечто эфемерное

//Стойки
stnMax=2;
stnStandup=2;
stnKneeling=1;
stnLaydown=0;
stnMin=0;
stnNames: Array [0..2] of string=('Ползком','Пригнувшись','Стоя');
stnHeight: Array [0..2] of real=(0.1,0.5,0.9);

//Уровень агрессии
agrMax=2;
agrFireAtWill=2;
agrReturnFire=1;
agrCeaseFire=0;
agrMin=0;
agrNames: Array [0..2] of string=('Не стрелять','Огонь в ответ','Огонь по возможности');

//tags
tagEnemyOf='EnemyOf';
tagAttackedBy='AttackedBy';
tagCNT_Player='Player';
tagCNT_Faction='Faction';
tagMyFaction='MyFaction';
tagFactionSample1='FactionSample1';
tagFactionPlayer='FactionPlayer';


