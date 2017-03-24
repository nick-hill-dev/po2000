program Podantious;

{*** Version 2.00 by Nicholas Hill, connivex@callnetuk.com ***}
{*** (c) 1999 & 2000 Connivex ***}

{*** I once decided to NOT finish this game. However, the millenium  ***}
{*** is fast approaching and I wanted to do the best program I could ***}
{*** do. So, you're looking at my best programming skill for the     ***}
{*** 20th century - indeed my entire life!                           ***}

uses crt, graph, DOS, poengine;

const
  Prg_Title = 'Podantious game version 2.10 build 1B [1.10] (99)-(00)';
  Biggest_Nutter = 'Karl Williams';
  Worst_Joke_Maker = 'Gareth Ayres';
  Most_Drunk_1999 = 'Gareth Ayres';

var
  Ch: Char;
  A,B,D: Integer;
  {* If keys are set up or not}
  KeysSetup: Array[1..32] of Boolean;
  {* Setup for levels}
  LevNumObjects: Integer;
  PlLives,PlMaxActiveMissiles: Array[1..32] of Integer;
  {* Variables for end of level}
  MaxHits,MinHits,BestPlayer,WorstPlayer: Integer;
  Winner: Integer;
  {* Window temp variables}
  OLDX,OLDY,OLDW,OLDH: Integer;
  OLDTITLE: String;


procedure CalcDelay;
var H1,M1,S1,MS1,H2,M2,S2,MS2,NUM: Word;
begin
  TextColor(7); ClrScr;
  WriteLn('Connivex 1999 & 2000.'); WriteLn;
  Writeln('Nicholas Hill''s delay calculation routine v1.01.');
  Writeln('Calculating delays...');
  GetTime(h1,m1,s1,ms1); NUM:=0;
  repeat
    DELAY(200); NUM:=NUM+1;
    GetTime(h2,m2,s2,ms2);
    GotoXY(1,5); Write(NUM); GotoXY(7,5); Writeln(H2:2,':',M2:2,':',S2:2);
  until (((S2-S1)*100)+(MS2-MS1))>=300;
  writeln('Took ',NUM,' loops of 200 for 3s.');
  SDelay:=(NUM*200) div 3;
  Delay(SDelay);
end;


procedure ShowWindow(X,Y,W,H: Integer; TITLE: String; DECOL: Boolean);
begin
  {* Decolour old window title}
  if DECOL=true then begin
    SetFillStyle(1,8); Bar(OLDX+3,OLDY+3,OLDX+OLDW-3,OLDY+13);
    SetColor(7); OutTextXY(OLDX+5,OLDY+5,OLDTITLE);
  end;
  {* Zoom in first}
  SetFillStyle(1,7);
  if W>=H then begin
    for A:=1 to (H div 2) do begin
      Bar(X,Y+(H div 2)-A,X+W,Y+(H div 2)+A);
      Delay(10);
    end;
  end else if W<H then begin
    for A:=1 to (W div 2) do begin
      Bar(X+(W div 2)-A,Y,X+(W div 2)+A,Y+H);
      Delay(10);
    end;
  end;
  Sound(900); Delay(20); Sound(950); Delay(35); NoSound;
  SetTextStyle(DefaultFont,HorizDir,1);
  SetColor(15);
  for A:=0 to 2 do begin {* Top and left bevels}
    MoveTo(X+A,Y); LineTo(X+A,Y+H-A);
    MoveTo(X,Y+A); LineTo(X+W-A,Y+A);
  end;
  SetColor(8);
  for A:=0 to 2 do begin {* Bottom and right bevels}
    MoveTo(X+A,Y+H-A); LineTo(X+W,Y+H-A);
    MoveTo(X+W-A,Y+A); LineTo(X+W-A,Y+H);
  end;
  SetFillStyle(1,7);
  {* Main box}
  Bar(X+2,Y+2,X+W-2,Y+H-2);
  {* Show main form, and title bar with text}
  SetFillStyle(1,1); Bar(X+3,Y+3,X+W-3,Y+13);
  SetColor(15); OutTextXY(X+5,Y+5,TITLE);
  {* Setup params for decolouring window next time}
  OLDX:=X; OLDY:=Y; OLDW:=W; OLDH:=H;
  OLDTITLE:=TITLE;
end;


procedure StartLevel;
var E: Integer;
begin
  {* Clear screen}
  ClearDevice;
  {* Draw players... etc}
  for E:=1 to NumPlayers do begin
    if StillInGame[E]=true then begin
      Sound(E*10); Delay(SDelay div 10); DrawPlayer(E);
      NoSound; Delay(SDelay div 80);
    end;
  end;
  for E:=1 to 3 do begin
    Sound(E*300); Delay(SDelay div 4);
    NoSound; Delay(SDelay div 4);
  end;
  for E:=1 to 2 do begin
    Sound(120); Delay(SDelay div 10);
    NoSound; Delay(SDelay div 18);
  end;
end;


procedure EndLevel;
var
  B,E: Integer;
  S1,S2,S3: String;
begin
  MaxHits:=0;
  for B:=1 to NumPlayers do if Alive[B]=true then Winner:=B;
  for B:=1 to 3 do begin
    for E:=10 downto 1 do begin
      Sound(E*12+100); Delay(SDelay div 50);
      Sound(E*10+110); Delay(SDelay div 50);
    end;
  end; NoSound;
  Delay(SDelay);
  {* Fade out}
  for E:=0 to 63 do begin
    SetColor(8); MoveTo(E*10+11,0); LineTo(E*10+11,480);
    SetColor(7); MoveTo(E*10+12,0); LineTo(E*10+12,480);
    SetColor(15); MoveTo(E*10+13,0); LineTo(E*10+13,480);
    SetFillStyle(1,0); Bar(E*10,0,E*10+10,480); Delay(SDelay div 100);
  end;
  {* Show window}
  ShowWindow(50,10,340,420,'Scores for end of level',FALSE);
  SetFillStyle(1,0); Bar(60,30,380,420);
  for B:=1 to NumPlayers do begin
    if StillInGame[B]=true then begin
      SetColor(PCOL[B]);
      Str(B:2,S1); Str(NumHits[B]:3,S2); Str(NumKills[B]:2,S3);
      OutTextXY(70,B*12+23,'Player '+S1+' had '+S2+' hits, '+S3+' kills.');
    end;
  end;
  {* Find maximum and minimum kills}
  MaxHits:=0;
  for B:=1 to NumPlayers do begin
    if StillInGame[B]=true then begin
      if NumHits[B]>MaxHits then begin
        MaxHits:=NumHits[B];
        BestPlayer:=B;
      end;
    end;
  end;
  MinHits:=MaxHits;
  for B:=1 to NumPlayers do begin
    if StillInGame[B]=true then begin
      if NumHits[B]<=MinHits then begin
        MinHits:=NumHits[B];
        WorstPlayer:=B;
      end;
    end;
  end;
  SetColor(9); Rectangle(65,BestPlayer*12+21,350,BestPlayer*12+31);
  SetColor(4); Rectangle(65,WorstPlayer*12+21,350,WorstPlayer*12+31);
  SetColor(2); SetFillStyle(1,2); Bar(355,Winner*12+21,375,Winner*12+31);
  SetColor(15); OutTextXY(1,460,'Level over - Press ''C'' to continue...');
  REPEAT UNTIL UpCase(readkey)='C';
  SetColor(0); SetFillStyle(1,0); Bar(1,460,640,480);
end;


procedure GameInit;
var grDriver, grMode, ErrCode: Integer;
begin
  Cheating:=false;
  Randomize;
  OLDX:=0; OLDY:=0; OLDW:=0; OLDH:=0; OLDTITLE:='';
  {* Initialise graphics}
  grDriver:=Detect; InitGraph(grDriver,grMode,'');
  ErrCode:=GraphResult; if ErrCode<>grOk then Halt(1);
  SetTextStyle(DefaultFont, HorizDir, 1);
  for A:=1 to 32 do KeysSetup[A]:=false;
end;


procedure SetupPlayer(PLN: Integer);
var S1: String;
begin
  if StillInGame[PLN]=true then begin
    {* Main player variables, x,y...etc, and get keys for each player}
    X[PLN]:=Random(620)+20; Y[PLN]:=Random(460)+20; DIR[PLN]:=Random(4)+1;
    {* Player colour and other variables}
    if PLN<16 then PCOL[PLN]:=PLN;
    if (PLN>15) and (PLN<31) then PCOL[PLN]:=PLN-15;
    if PLN>30 then PCOL[PLN]:=PLN-30;
    NumActiveMissiles[PLN]:=0; Alive[PLN]:=true;
    NumLives[PLN]:=PlLives[PLN];
    MaxActiveMissiles[PLN]:=PlMaxActiveMissiles[PLN];
    if (PLN<=NumHumanPlayers) and (KeysSetup[PLN]=false) then begin
      Str(PLN,S1);
      ShowWindow(290,65+(PLN*9),310,88,'Define keys for player '+S1,TRUE);
      SetColor(0); Str(PLN,S1);
      OutTextXY(300,85+(PLN*9),'Player '+S1+' - Press key for UP:');
      KUp[PLN]:=ReadKey;
      OutTextXY(300,97+(PLN*9),'Player '+S1+' - Press key for DOWN:');
      KDown[PLN]:=ReadKey;
      OutTextXY(300,109+(PLN*9),'Player '+S1+' - Press key for LEFT:');
      KLeft[PLN]:=ReadKey;
      OutTextXY(300,121+(PLN*9),'Player '+S1+' - Press key for RIGHT:');
      KRight[PLN]:=ReadKey;
      OutTextXY(300,133+(PLN*9),'Player '+S1+' - Press key for FIRE:');
      KFire[PLN]:=ReadKey;
      KeysSetup[PLN]:=true;
    end;
    {* Set initial AI victims :}
    if (PLN>NumHumanPlayers) and (Random(10)>4) then
      VICTIM[PLN]:=Random(NumPlayers+1);
  end else Alive[PLN]:=false;
end;


procedure InitLevel(NumHuman,NumAI,AISkill: Integer);
var E: Integer;
begin
  for E:=1 to 32 do begin
    NumHits[E]:=0; Alive[E]:=false; NumKills[E]:=0;
    FastSpeed[E]:=false;
  end;
  {* Number of each thing}
  NumHumanPlayers:=NumHuman;
  NumAIPlayers:=NumAI;
  NumPlayers:=NumAIPlayers+NumHumanPlayers;
  NumPlayersAlive:=0;
  for E:=1 to NumPlayers do begin
    if StillInGame[E]=true then NumPlayersAlive:=NumPlayersAlive+1;
  end;
  NumObjects:=0; MaxObjects:=LevNumObjects;
  LevAISkill:=AISkill;
end;


procedure GetPlayerTypes(HumanYN,AIYN: Integer);
var S1: String;
begin
  ShowWindow(50,350,350,70,'Setup player types',TRUE);
  SetColor(0);
  if HumanYN=1 then repeat
    OutTextXY(60,375,'Enter number of human players (0-32): ');
    ReadLn(NumHumanPlayers);
  until (NumHumanPlayers>-1) and (NumHumanPlayers<33);
  if AIYN=1 then repeat
    Str(32-NumHumanPlayers,S1);
    OutTextXY(60,395,'Enter number of AI players (0-'+S1+'): ');
    Readln(NumAIPlayers);
  until (NumAIPlayers>-1) and (NumAIPlayers<(33-NumHumanPlayers));
end;

procedure SetupCustomLevel;
var E: Integer;
begin
  GetPlayerTypes(1,1); {* Player setup}
  InitLevel(NumHumanPlayers,NumAIPlayers,LevAISkill);
  ShowWindow(90,10,310,100,'Custom level parameters',TRUE);
  SetColor(0);
  {* User input setup}
  OutTextXY(100,30,'Enter AI skill level (1-5):'); Readln(LevAISkill);
  OutTextXY(100,50,'Enter maximum objects (0-20):');
  repeat
    ReadLn(LevNumObjects);
  until (LevNumObjects>-1) and (LevNumObjects<21);
  OutTextXY(100,70,'Enter starting lives (1-5):');
  repeat
    ReadLn(PlLives[1]);
  until (PlLives[1]>0) and (PlLives[1]<6);
  for E:=1 to NumPlayers do PlLives[E]:=PlLives[1];
  OutTextXY(100,90,'Enter maximum missiles (0-20):');
  repeat
    ReadLn(PlMaxActiveMissiles[1]);
  until (PlMaxActiveMissiles[1]>-1) and (PlMaxActiveMissiles[1]<21);
  for E:=1 to NumPlayers do PlMaxActiveMissiles[E]:=PlMaxActiveMissiles[1];
end;


procedure SetupCampaignLevel(L: Integer);
var E: Integer;
begin
  if L=1 then begin
    LevNumObjects:=15; InitLevel(1,1,1);
    PlLives[1]:=5; PlMaxActiveMissiles[1]:=10;
    PlLives[2]:=2; PlMaxActiveMissiles[2]:=1;
  end;
  if L=2 then begin
    LevNumObjects:=8; InitLevel(1,7,1);
    PlLives[1]:=5; PlMaxActiveMissiles[1]:=3;
    for E:=2 to 8 do PlLives[E]:=1;
    for E:=2 to 8 do PlMaxActiveMissiles[E]:=1;
  end;
  if L=3 then begin
    LevNumObjects:=5; InitLevel(1,3,2);
    PlLives[1]:=4; PlMaxActiveMissiles[1]:=2;
    for E:=2 to 4 do PlLives[E]:=2;
    for E:=2 to 4 do PlMaxActiveMissiles[E]:=2;
  end;
  if L=4 then begin
    LevNumObjects:=5; InitLevel(1,2,2);
    PlLives[1]:=5; PlMaxActiveMissiles[1]:=2;
    for E:=2 to 3 do PlLives[E]:=5;
    for E:=2 to 3 do PlMaxActiveMissiles[E]:=2;
  end;
  if L=5 then begin
    LevNumObjects:=3; InitLevel(1,2,2);
    PlLives[1]:=4; PlMaxActiveMissiles[1]:=1;
    for E:=2 to 3 do PlLives[E]:=5;
    for E:=2 to 3 do PlMaxActiveMissiles[E]:=2;
  end;
  if L=6 then begin
    LevNumObjects:=3; InitLevel(1,14,3);
    PlLives[1]:=4; PlMaxActiveMissiles[1]:=3;
    for E:=2 to 15 do PlLives[E]:=1;
    for E:=2 to 15 do PlMaxActiveMissiles[E]:=2;
  end;
  if L=7 then begin
    LevNumObjects:=2; InitLevel(1,1,5);
    PlLives[1]:=3; PlMaxActiveMissiles[1]:=1;
    PlLives[2]:=5; PlMaxActiveMissiles[2]:=2;
  end;
  if L=8 then begin
    LevNumObjects:=2; InitLevel(1,14,3);
    PlLives[1]:=5; PlMaxActiveMissiles[1]:=4;
    for E:=2 to 15 do PlLives[E]:=3;
    for E:=2 to 15 do PlMaxActiveMissiles[E]:=3;
  end;
  if L=9 then begin
    LevNumObjects:=1; InitLevel(1,9,3);
    PlLives[1]:=2; PlMaxActiveMissiles[1]:=1;
    for E:=2 to 10 do PlLives[E]:=2;
    for E:=2 to 10 do PlMaxActiveMissiles[E]:=2;
  end;
  if L=10 then begin
    LevNumObjects:=2; InitLevel(1,14,3);
    PlLives[1]:=5; PlMaxActiveMissiles[1]:=1;
    for E:=2 to 5 do PlLives[E]:=5;
    for E:=2 to 5 do PlMaxActiveMissiles[E]:=5;
    for E:=6 to 9 do PlLives[E]:=3;
    for E:=6 to 9 do PlMaxActiveMissiles[E]:=3;
    for E:=10 to 14 do PlLives[E]:=1;
    for E:=10 to 14 do PlMaxActiveMissiles[E]:=1;
  end;
  if L=11 then begin
    LevNumObjects:=1; InitLevel(1,3,4);
    PlLives[1]:=2; PlMaxActiveMissiles[1]:=1;
    PlLives[2]:=3; PlMaxActiveMissiles[2]:=1;
    PlLives[3]:=4; PlMaxActiveMissiles[3]:=1;
    PlLives[4]:=5; PlMaxActiveMissiles[4]:=5;
  end;
  if L=12 then begin
    LevNumObjects:=0; InitLevel(1,2,4);
    PlLives[1]:=2; PlMaxActiveMissiles[1]:=2;
    for E:=2 to 3 do PlLives[E]:=4;
    for E:=2 to 3 do PlMaxActiveMissiles[E]:=5;
  end;
  if L=13 then begin
    LevNumObjects:=1; InitLevel(1,14,4);
    PlLives[1]:=5; PlMaxActiveMissiles[1]:=2;
    for E:=2 to 15 do PlLives[E]:=4;
    for E:=2 to 15 do PlMaxActiveMissiles[E]:=3;
  end;
  if L=14 then begin
    LevNumObjects:=20; InitLevel(1,9,4);
    PlLives[1]:=2; PlMaxActiveMissiles[1]:=1;
    for E:=2 to 9 do PlLives[E]:=3;
    for E:=2 to 9 do PlMaxActiveMissiles[E]:=2;
    PlLives[10]:=5; PlMaxActiveMissiles[10]:=1;
  end;
  if L=15 then begin
    LevNumObjects:=0; InitLevel(1,2,5);
    PlLives[1]:=2; PlMaxActiveMissiles[1]:=0;
    PlLives[2]:=2; PlMaxActiveMissiles[1]:=1;
    PlLives[3]:=5; PlMaxActiveMissiles[1]:=5;
  end;
  if L=16 then begin
    LevNumObjects:=2; InitLevel(1,14,5);
    PlLives[1]:=2; PlMaxActiveMissiles[1]:=1;
    for E:=2 to 15 do PlLives[E]:=5;
    for E:=2 to 15 do PlMaxActiveMissiles[E]:=5;
  end;
  for E:=1 to NumPlayers do SetupPlayer(E);
  {* Specify X and Y positions for some levels}
  if L=1 then begin
    X[1]:=100; Y[1]:=50; Dir[1]:=2;
    X[2]:=100; Y[2]:=400; Dir[2]:=2;
  end;
  if L=4 then begin
    for E:=1 to NumPlayers do Y[E]:=300;
  end;
  if L=8 then begin
    for E:=1 to 15 do begin
      X[E]:=E*30; if (E mod 2)=1 then Y[E]:=200 else Y[E]:=180;
    end;
  end;
  if L=10 then begin
    for E:=1 to 15 do begin
      Y[E]:=E*22; if (E mod 2)=1 then X[E]:=20 else X[E]:=525;
      if (E mod 2)=1 then DIR[E]:=4 else DIR[E]:=3;
    end;
  end;
  if L=12 then begin
    X[1]:=20; Y[1]:=460; DIR[1]:=1;
    X[2]:=300; Y[2]:=100; DIR[2]:=2;
    X[3]:=60; Y[3]:=460; DIR[3]:=1;
  end;
  if L=16 then begin
    X[1]:=30; Y[1]:=30; DIR[1]:=4;
    X[2]:=515; Y[2]:=30; DIR[2]:=3;
    X[3]:=30; Y[3]:=450; DIR[3]:=4;
    X[4]:=515; Y[4]:=450; DIR[4]:=3;
    X[5]:=50; Y[5]:=50; DIR[5]:=4;
    X[6]:=495; Y[6]:=50; DIR[6]:=3;
    X[7]:=50; Y[7]:=430; DIR[7]:=4;
    X[8]:=495; Y[8]:=430; DIR[8]:=3;
    X[9]:=70; Y[9]:=70; DIR[9]:=4;
    X[10]:=475; Y[10]:=70; DIR[10]:=3;
    X[11]:=70; Y[11]:=410; DIR[11]:=4;
    X[12]:=475; Y[12]:=410; DIR[12]:=3;
    X[13]:=90; Y[13]:=90; DIR[13]:=4;
    X[14]:=455; Y[14]:=90; DIR[14]:=3;
    X[15]:=90; Y[15]:=390; DIR[15]:=4;
  end;
end;


procedure ShowMessage(Msg: String; DECOL: Boolean);
begin
  ShowWindow(130,100,380,50,'Message',DECOL);
  SetColor(0); OutTextXY(140,120,Msg);
  OutTextXY(140,132,'Press the ''C'' key to continue...');
  REPEAT UNTIL Readkey='C';
end;


procedure PlayGame(GameType: Char);
var
  E, Level, Lives: Integer;
  SOTF_MaxLevel: Integer;
  S1: String;
begin
  TextColor(15); SetColor(15);
  DuelMode:=false;
  {* Initialise level: NumHuman,NumAI,AISKILL}
  {* Setup player: PLN};

  {# CAMPAIGN #}
  if GameType='A' then begin
    Level:=0; Lives:=3;
    repeat
      Level:=Level+1;
      SetupCampaignLevel(Level);
      Str(Level,S1);
      ShowMessage('You are on level '+S1+'.',TRUE);
      StartLevel;    {* The startup sequence for the level}
      PlayLevel;     {* Main playing part of the game}
      EndLevel;      {* End the level}
      if Alive[1]=false then begin
        Lives:=Lives-1;
        if Lives=0 then ShowMessage('You lost all lives! Game over!',TRUE);
        if Lives>0 then begin
          STR(Lives,S1);
          ShowMessage('Life lost. Replay level with '+S1+' lives.',TRUE);
          Alive[1]:=true;
          Level:=Level-1;
        end;
      end;
      if (Level=16) then begin
        ShowMessage('Congratulations!',FALSE);
        ShowMessage('You have completed the campaign.',TRUE);
        ShowMessage('Be sure to email connivex@callnetuk.com!',TRUE);
      end;
    until (Level=16) or (Alive[1]=false);
  end;

  {# DUEL #}
  if GameType='B' then begin
    DuelMode:=true;
    LevNumObjects:=6;
    InitLevel(1,1,3);
    for E:=1 to 2 do PlLives[E]:=5;
    for E:=1 to 2 do PlMaxActiveMissiles[E]:=0;
    for E:=1 to NumPlayers do SetupPlayer(E);
    {* Setup colours! (This should be fun...!) }
    PCOL[1]:=9; PCOL[2]:=12;
    ShowMessage('Keep going until you die!',TRUE);
    StartLevel;    {* The startup sequence for the level}
    PlayLevel;     {* Main playing part of the game}
    EndLevel;      {* End the level}
    Str(NumHits[1],S1);
    ShowMessage('Duel over! You got '+S1+' hits.',TRUE);
  end;

  {# SURVIVAL OF THE FITTEST #}
  if GameType='C' then begin
    GetPlayerTypes(1,1); {* Player setup}
    Level:=0; SOTF_MaxLevel:=NumHumanPlayers+NumAIPlayers-1;
    repeat
      Level:=Level+1;
      LevNumObjects:=NumPlayers-Level;
      InitLevel(NumHumanPlayers,NumAIPlayers,5);
      for E:=1 to 32 do PlLives[E]:=5;
      for E:=1 to 32 do PlMaxActiveMissiles[E]:=3;
      for E:=1 to NumPlayers do SetupPlayer(E);
      Str(Level,S1);
      ShowMessage('You are on level '+S1+'.',TRUE);
      StartLevel;    {* The startup sequence for the level}
      PlayLevel;     {* Main playing part of the game}
      EndLevel;      {* End the level}
      StillInGame[WorstPlayer]:=false;
    until Level=SOTF_MaxLevel;
    Str(BestPlayer,S1);
    ShowMessage('Survival game is over - winner was #'+S1,TRUE);
  end;

  {# NO POWERUP SINGLE GAME #}
  if GameType='D' then begin
    GetPlayerTypes(1,1); {* Player setup}
    LevNumObjects:=0;
    InitLevel(NumHumanPlayers,NumAIPlayers,3);
    for E:=1 to 32 do PlLives[E]:=5;
    for E:=1 to 32 do PlMaxActiveMissiles[E]:=3;
    for E:=1 to NumPlayers do SetupPlayer(E);
    ShowMessage('You are about to play option "D".',TRUE);
    StartLevel;    {* The startup sequence for the level}
    PlayLevel;     {* Main playing part of the game}
    EndLevel;      {* End the level}
    Str(Winner,S1);
    ShowMessage('This level is finished. Winner was player '+S1+'.',TRUE);
  end;

  {# BEST OF THREE GAMES #}
  if GameType='E' then begin
    GetPlayerTypes(1,1); {* Player setup}
    LevNumObjects:=(NumHumanPlayers+NumAIPlayers) div 4;
    InitLevel(NumHumanPlayers,NumAIPlayers,3);
    for Level:=1 to 3 do begin
      for E:=1 to NumPlayers do Alive[E]:=true;
      NumPlayersAlive:=NumPlayers;
      for E:=1 to 32 do PlLives[E]:=5;
      for E:=1 to 32 do PlMaxActiveMissiles[E]:=3;
      for E:=1 to NumPlayers do SetupPlayer(E);
      Str(Level,S1);
      ShowMessage('Level '+S1+' / 3.',TRUE);
      StartLevel;    {* The startup sequence for the level}
      PlayLevel;     {* Main playing part of the game}
      EndLevel;      {* End the level}
      Str(Winner,S1);
      ShowMessage('Level is finished. Last survivor was #'+S1+'.',TRUE);
    end;
    Str(BestPlayer,S1);
    ShowMessage('Best of 3 completed. Winner is player '+S1+'.',TRUE);
  end;

  {# CUSTOM GAME #}
  if GameType='F' then begin
    SetupCustomLevel;
    InitLevel(NumHumanPlayers,NumAIPlayers,LevAISkill);
    for E:=1 to NumPlayers do SetupPlayer(E);
    ShowMessage('Starting custom level...',TRUE);
    StartLevel;    {* The startup sequence for the level}
    PlayLevel;     {* Main playing part of the game}
    EndLevel;      {* End the level}
    Str(Winner,S1);
    ShowMessage('This level is finished. Winner was player '+S1+'.',TRUE);
  end;

end;

procedure ShowMenu;
var E: Integer;
begin
  {* Starry background}
  SetColor(0);
  for A:=0 to 640 do begin
    MoveTo(A,0); LineTo(A,480);
    for B:=1 to Random(14) do begin
      D:=Random(3);
      if D=1 then E:=7;
      if D=2 then E:=8;
      if D=3 then E:=15;
      PutPixel(A,Random(480),E);
    end;
    Delay(10);
  end;
  {* Display the menu}
  ShowWindow(100,50,440,270,'Podantious 2000 by Connivex',FALSE);
  SetColor(15); MoveTo(111,70); LineTo(111,311);
  LineTo(530,181); LineTo(111,71);
  SetColor(8); MoveTo(110,70); LineTo(110,310);
  LineTo(530,180); LineTo(110,70);
  SetColor(8); OutTextXY(1,1,Prg_Title);
  SetColor(1);
  OutTextXY(105,80,'A] Campaign');
  OutTextXY(105,110,'B] Duel');
  OutTextXY(105,150,'C] Survival of the fittest');
  OutTextXY(105,190,'D] Single game - no powerups');
  OutTextXY(105,230,'E] Best of three games');
  OutTextXY(105,270,'F] Custom game');
  OutTextXY(105,300,'X] Exit game');
  SetColor(0);
  OutTextXY(135,90,'Go through 16 predesigned levels.');
  OutTextXY(135,120,'See how far you get against the triangles as');
  OutTextXY(135,130,'their number increases when one dies.');
  OutTextXY(135,160,'Up to 31 levels, where the worst player is thrown');
  OutTextXY(135,170,'out after each level.');
  OutTextXY(135,200,'A single game for up to 32 players, and only one');
  OutTextXY(135,210,'winner, leading to 31 losers.');
  OutTextXY(135,240,'Total the kills after each level and the winner');
  OutTextXY(135,250,'is the one with the most kills after 3 levels.');
  OutTextXY(135,280,'Customise your game to one that suits you.');
  Ch:='1';
  While (Ch<>'A') and (CH<>'B') and (Ch<>'C') and (CH<>'D')
  and (CH<>'E') and (Ch<>'F') and (Ch<>'X')
  and (CH<>'~') do Ch:=UpCase(ReadKey);
  {* Cheat mode!}
  if CH='~' then begin
    Cheating:=not Cheating;
    if Cheating=true then begin
      sound(1000); delay(900); sound(2000); delay(400);
      sound(3000); delay(200); nosound;
    end else begin
      sound(3000); delay(900); sound(2000); delay(400);
      sound(1000); delay(200); nosound;
    end;
  end;
end;


begin
  {*** The main program ***}
  CalcDelay;    {* Calculate delays}
  GameInit;     {* Init game}
  repeat
    {* Make all players still in game}
    for A:=1 to 32 do StillInGame[A]:=true;
    repeat
      ShowMenu;     {* Show the menu, and get settings}
    until Ch<>'~';
    if Ch='A' then PlayGame(Ch); {* Play the game with menu choice}
    if Ch='B' then PlayGame(Ch);
    if Ch='C' then PlayGame(Ch);
    if Ch='D' then PlayGame(Ch);
    if Ch='E' then PlayGame(Ch);
    if Ch='F' then PlayGame(Ch);
  until Ch='X';
  restorecrtmode;
  writeln(Prg_Title);
  writeln('(c) 1999 by Nicholas Hill of Connivex.');
end.