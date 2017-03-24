unit POENGINE;

{*** The main game engine ***}
{*** Game play area dimensions: 0,0,639,479 ***}
{*** Version 2.00 from 1999 ***}
{*** Current: Version 2.10, updated 30th Dec 99 onwards ***}

interface

var
  {* Game modes}
    DuelMode,Cheating: boolean;
  {* A maximum of 32 players can have up to 20 missiles on screen at once}
    NumLives, PCOL: Array[1..32] of ShortInt;
    X, Y: Array[1..32] of Integer;
    DIR: Array[1..32] of ShortInt;
    NumHits: Array[1..32] of Integer;
    NumKills: Array[1..32] of Integer;
    Alive: Array[1..32] of Boolean;
    FastSpeed: Array[1..32] of Boolean;
    MissX, MissY: Array[1..32,1..20] of Integer;
    MissDIR: Array[1..32,1..20] of ShortInt;
    NumActiveMissiles, MaxActiveMissiles: Array[1..32] of shortint;
    StillInGame: Array[1..32] of Boolean;
  {* The keys each player uses}
    KUp, KDown, KLeft, KRight, KFire: array[1..32] of Char;
  {* Number of each type of player or object}
    NumPlayers, NumPlayersAlive: ShortInt;
    NumAIPlayers, NumHumanPlayers: ShortInt;
    NumObjects, MaxObjects: ShortInt;
  {* Object variables}
    ObjX, ObjY: Array[1..20] of Integer;
    ObjNum: Array[1..20] of ShortInt;
  {* AI variables}
    VICTIM: Array[1..32] of ShortInt;
    VICTIMTYPE: Array[1..32] of ShortInt;
    LevAISkill: ShortInt;
  {* For Control Loop variables}
    A, B, D, G: Integer;
  {* The key caught from the keyboard}
    C: Char;
  {* Second delay amount}
    SDelay: Integer;

{* Accessible procedures and functions}
  procedure DrawPlayer(NUM: ShortInt);
  procedure CreateMissile(PLN: Integer);
  procedure HideMissile(PLN,N: Integer);
  procedure DelMissile(PLN,N: Integer);
  procedure DuelAddPlayer(PLN: ShortInt; NX,NY: Integer);
  procedure LoseLife(Z, PLN: Integer);
  procedure DrawObject(NUM: Integer);
  procedure CreateObject;
  procedure DeleteObject(NUM: Integer);
  procedure CheckObjCollisions;
  procedure ChooseVictim(NUM: Integer);
  procedure ProcessAI(NUM: Integer);
  procedure CheckMissCollision(PLN,MISSNUM,CX,CY: Integer);
  procedure ProcessMissiles;
  procedure PlayLevel;

implementation
uses crt, graph;


procedure DrawPlayer(NUM: ShortInt);
var I1: Integer;
begin
  I1:=20-(5*(NumLives[num]-1));
  SetColor(PCOL[NUM]);
  {* Draw the player onto the board}
  case DIR[num] of
  1: begin
       for B:=I1 to 20 do begin
         MoveTo(X[num]-(B div 2),(Y[num]-10)+B);
         LineTo(X[num]+(B div 2),(Y[num]-10)+B);
       end;
       MoveTo(X[num]-10,Y[num]+10); LineTo(X[num]+10,Y[num]+10);
       LineTo(X[num],Y[num]-10); LineTo(X[num]-10,Y[num]+10);
     end;
  2: begin
       for B:=I1 to 20 do begin
         MoveTo(X[num]-(B div 2),(Y[num]+10)-B);
         LineTo(X[num]+(B div 2),(Y[num]+10)-B);
       end;
       MoveTo(X[num]-10,Y[num]-10); LineTo(X[num]+10,Y[num]-10);
       LineTo(X[num],Y[num]+10); LineTo(X[num]-10,Y[num]-10);
     end;
  3: begin
       for B:=I1 to 20 do begin
         MoveTo((X[num]-10)+B,Y[num]-(B div 2));
         LineTo((X[num]-10)+B,Y[num]+(B div 2));
       end;
       MoveTo(X[num]+10,Y[num]-10); LineTo(X[num]+10,Y[num]+10);
       LineTo(X[num]-10,Y[num]); LineTo(X[num]+10,Y[num]-10);
     end;
  4: begin
       for B:=I1 to 20 do begin
         MoveTo((X[num]+10)-B,Y[num]-(B div 2));
         LineTo((X[num]+10)-B,Y[num]+(B div 2));
       end;
       MoveTo(X[num]-10,Y[num]-10); LineTo(X[num]+10,Y[num]);
       LineTo(X[num]-10,Y[num]+10); LineTo(X[num]-10,Y[num]-10);
     end;
  end;
end;


procedure CreateMissile(PLN: Integer);
begin
  {* Create a new missile!}
  if NumActiveMissiles[PLN]<MaxActiveMissiles[PLN] then begin
    Inc(NumActiveMissiles[PLN]);
    MissX[PLN,NumActiveMissiles[PLN]]:=X[PLN];
    MissY[PLN,NumActiveMissiles[PLN]]:=Y[PLN];
    MissDIR[PLN,NumActiveMissiles[PLN]]:=DIR[PLN];
  end;
end;


procedure HideMissile(PLN,N: Integer);
begin
  {* Clear missile from display}
  MoveTo(MissX[PLN,N],MissY[PLN,N]); SetColor(0);
  case MissDIR[PLN,N] of
    1: LineTo(MissX[PLN,N],MissY[PLN,N]-50);
    2: LineTo(MissX[PLN,N],MissY[PLN,N]+50);
    3: LineTo(MissX[PLN,N]-50,MissY[PLN,N]);
    4: LineTo(MissX[PLN,N]+50,MissY[PLN,N]);
  end;
end;


procedure DelMissile(PLN,N: Integer);
begin
  {* Clear missile from display}
  HideMissile(PLN,N);
  if NumActiveMissiles[PLN]>0 then begin
    {* Actually delete missile by replacing with latest one}
    MissX[PLN,N]:=MissX[PLN,NumActiveMissiles[PLN]];
    MissY[PLN,N]:=MissY[PLN,NumActiveMissiles[PLN]];
    MissDIR[PLN,N]:=MissDIR[PLN,NumActiveMissiles[PLN]];
    Dec(NumActiveMissiles[PLN]);
  end;
end;


procedure DuelAddPlayer(PLN: ShortInt; NX,NY: Integer);
begin
  Sound(1000); Delay(200); Sound(5000); Delay(200); NoSound; Delay(300);
  {* New player: Main player variables, x,y...etc}
  X[PLN]:=NX; Y[PLN]:=NY; DIR[PLN]:=Random(4)+1;
  NumHits[PLN]:=0; NumKills[PLN]:=0; FastSpeed[PLN]:=false;
  {* Player colour and other variables}
  PCOL[PLN]:=4; NumActiveMissiles[PLN]:=0; Alive[PLN]:=true;
  NumLives[PLN]:=5; MaxActiveMissiles[PLN]:=3;
  {* Draw it}
  DrawPlayer(PLN);
end;


procedure LoseLife(Z, PLN: Integer);
var
 LX,LY,NUM,B,E: Integer;
 X_L20,X_R20,Y_T20,Y_B20: Integer; {X_L20=20 pixels left of dead player}
begin
  Dec(NumLives[Z]);
  {* Check cheating mode - invunerability}
  if Cheating=true then if NumLives[1]<1 then NumLives[1]:=1;
  {* Setup variables and flash player}
  LX:=X[Z]; LY:=Y[Z];
  X_L20:=X[Z]-20; X_R20:=X[Z]+20; Y_T20:=Y[Z]-20; Y_B20:=Y[Z]+20;
  SetFillStyle(1,PCOL[PLN]); Bar(LX-10,LY-10,LX+10,LY+10);
  {* Give credit where credit is due... :}
  Inc(NumHits[PLN]);
  {* And if player is truely dead... THEN KILL 'IM! - And give kill credit}
  if NumLives[Z]<1 then begin
    NumKills[PLN]:=NumKills[PLN]+1;
    {* Delete all of the now dead player's active missiles}
    for B:=1 to NumActiveMissiles[Z] do DelMissile(Z,B);
    Alive[Z]:=false;
    Dec(NumPlayersAlive);
    Sound(900); Delay(500); Sound(1900); Delay(200); NoSound;
    {* Hide player from view}
    SetFillStyle(1,0); Bar(LX-10,LY-10,LX+10,LY+10);
    {* Duel mode only - make 2 new players}
    if DuelMode=true then begin
      if (NumPlayers<32) and (NumLives[1]>0) then begin
        {* Replace old, now dead player, 20 pixels left and top}
        DuelAddPlayer(Z,X_L20,Y_T20);
        {* Add new duel player 20 pixels right and bottom}
        Inc(NumAIPlayers);
        NumPlayers:=NumHumanPlayers+NumAIPlayers;
        DuelAddPlayer(NumPlayers,X_R20,Y_B20);
        {* There are 2 more players born!}
        Inc(NumPlayersAlive,2);
      end;
      if (NumPlayers=32) or (NumLives[1]=0) then begin
        {* These are the last players, so set new colours}
        for E:=2 to NumPlayers do PCOL[E]:=11;
      end;
    end;
  end;
end;


procedure DrawObject(NUM: Integer);
var
  E,ONum,OX,OY: Integer;
begin
  OX:=ObjX[NUM]; OY:=ObjY[NUM]; ONum:=ObjNum[NUM];
  {* Draw object according to type}
  {* Extra life}
  if ONum=1 then begin
    SetColor(7); SetFillStyle(1,1); PieSlice(OX,OY,0,135,10);
    SetColor(15); SetFillStyle(1,9); PieSlice(OX,OY,136,360,10);
  end;
  {* Extra missile}
  if ONum=2 then begin
    for E:=-1 to 1 do begin
      case E of
        -1: SetColor(15); 0: SetColor(13); 1: SetColor(4);
      end;
      MoveTo(OX+E,OY-10); LineTo(OX+E,OY+10);
      MoveTo(OX-10,OY+E); LineTo(OX+10,OY+E);
    end;
  end;
  {* Circle of violence}
  if ONum=3 then begin
    SetColor(3); Circle(OX,OY,10);
    SetColor(4); MoveTo(OX-10,OY-10); LineTo(OX+10,OY+10);
    MoveTo(OX+10,OY-10); LineTo(OX-10,OY+10);
  end;
  {* Complete life restoration}
  if ONum=4 then begin
    SetColor(0); SetFillStyle(1,15); PieSlice(OX,OY,0,135,10);
    SetColor(15); SetFillStyle(1,7); PieSlice(OX,OY,136,360,10);
  end;
  {* Faster speed}
  if ONum=5 then begin
    SetFillStyle(1,2); Bar(OX-8,OY-8,OX+8,OY-4);
    Bar(OX-2,OY-8,OX+2,OY+8);
  end;
end;


procedure CreateObject;
var ONum,OX,OY: Integer;
begin
  if (NumObjects<MaxObjects) and (NumObjects<20) then begin
    Inc(NumObjects); ONum:=random(20)+1;
    OX:=Random(630)+5; OY:=Random(470)+5;
    case ONum of
      1..10: ObjNum[NumObjects]:=1;
     11..14: ObjNum[NumObjects]:=2;
     15..17: ObjNum[NumObjects]:=3;
     18..19: ObjNum[NumObjects]:=4;
         20: ObjNum[NumObjects]:=5;
    end;
    ObjX[NumObjects]:=OX; ObjY[NumObjects]:=OY;
    DrawObject(NumObjects);
  end;
end;


procedure DeleteObject(NUM: Integer);
begin
  {* Hide it}
  SetFillStyle(1,0);
  Bar(ObjX[NUM]-10,ObjY[NUM]-10,ObjX[NUM]+10,ObjY[NUM]+10);
  {* Actually delete it}
  if NumObjects>0 then begin
    ObjX[NUM]:=ObjX[NumObjects];
    ObjY[NUM]:=ObjY[NumObjects];
    ObjNum[NUM]:=ObjNum[NumObjects];
    Dec(NumObjects);
  end;
end;


procedure CheckObjCollisions;
var B,E,PX,PY,OX,OY,ONum,PLN: Integer;
begin
  for PLN:=1 to 32 do if Alive[PLN] then begin
    PX:=X[PLN]; PY:=Y[PLN];
    for B:=1 to NumObjects do begin
      OX:=ObjX[B]; OY:=ObjY[B]; ONum:=ObjNum[B];
      if (PX>OX-21) and (PX<OX+21) and (PY>OY-21)
      and (PY<OY+21) then begin
        {* Add object to player}
        {* 1=New life, 2= + Missile, 3=Kill all, 4=Full lives, 5=Turbo}
        sound(500); Delay(100); Sound(300); Delay(200); NoSound;
        if ONum=1 then if NumLives[PLN]<5 then Inc(NumLives[PLN]);
        if ONum=2 then Inc(MaxActiveMissiles[PLN]);
        if ONum=3 then begin
          {* Flash players and kill}
          for E:=1 to NumPlayers do begin
            if Alive[E]=true then begin
              SetFillStyle(1,PCOL[PLN]);
              Bar(X[E]-10,Y[E]-10,X[E]+10,Y[E]+10);
              Sound(E*50); Delay(SDelay div 50);
            end;
          end; NoSound; Delay(SDelay div 3);
          for E:=NumPlayers downto 1 do begin
            if Alive[E]=true then begin
              SetFillStyle(1,0); Bar(X[E]-10,Y[E]-10,X[E]+10,Y[E]+10);
              Sound(E*50); Delay(SDelay div 50);
            end;
          end; NoSound;
          for E:=1 to NumPlayers do begin
            if (Alive[E]=true) and (E<>PLN) then LoseLife(E,PLN);
          end;
        end;
        if ONum=4 then NumLives[PLN]:=5;
        if ONum=5 then FastSpeed[PLN]:=not FastSpeed[PLN];
        {* Delete the object}
        DeleteObject(B);
      end;
    end;
  end;
end;


procedure ChooseVictim(NUM: Integer);
var E: Integer;
begin
  {* Choose victim or object to chase after}
  if Random(5)>LevAISkill then begin
    {* Object chosen}
    VICTIMTYPE[NUM]:=2;
    if NumObjects>0 then VICTIM[NUM]:=Random(NumObjects)+1
    else VICTIMTYPE[NUM]:=1;
  end else VICTIMTYPE[NUM]:=1;
  if VICTIMTYPE[NUM]=1 then begin
    {* Triangle chosen}
    VICTIM[NUM]:=Random(NumPlayers)+1;
    while Alive[VICTIM[NUM]]=false do VICTIM[NUM]:=Random(NumPlayers)+1;
    if (LevAISkill>3) and (Random(4)>(6-LevAISkill)) then begin
      {* Force picking human - 10 attempts}
      if NumHumanPlayers>0 then begin
        VICTIM[NUM]:=Random(NumHumanPlayers)+1;
        for E:=1 to 10 do begin
          if Alive[VICTIM[NUM]]=false then
            VICTIM[NUM]:=Random(NumHumanPlayers)+1;
        end;
      end;
    end;
  end;
end;


procedure ProcessAI(NUM: Integer);
begin
  {* Process AI player movements}
  {* Create a new missile!}
  if NumActiveMissiles[NUM]<MaxActiveMissiles[NUM] then
  case LevAISkill of
    1..3: If (Random(130)=1) then CreateMissile(NUM);
       3: If (Random(80)=1) then CreateMissile(NUM);
    4..5: If (Random(50)=1) then CreateMissile(NUM);
  end;
  {* Move around, or choose some podantic (!) victim}
  if NumPlayersAlive>3 then begin
    if (RANDOM(900)=1) then ChooseVictim(NUM);
    if (RANDOM(900)=1) then VICTIM[NUM]:=0;
  end else if NumPlayersAlive<4 then begin
    if (RANDOM(150)=1) then ChooseVictim(NUM);
    if (RANDOM(400)=1) then VICTIM[NUM]:=0;
  end;
  if (RANDOM(100)=1) and (VICTIM[NUM]=0) then DIR[NUM]:=RANDOM(4)+1;
  {* Check existance of victims}
  if (VICTIM[NUM]<>0) then begin
    if (VICTIMTYPE[NUM]=1) and (Alive[Victim[NUM]]=false)
      then Victim[NUM]:=0;
    if (VICTIMTYPE[NUM]=2) and (NumObjects<Victim[NUM]) then Victim[NUM]:=0;
  end;
  {* If no victim chosen, randomly move about}
  if (VICTIM[NUM]=0) and (Random(100)=1) then DIR[NUM]:=Random(4)+1;
  if (VICTIM[NUM]>0) and (VICTIMTYPE[NUM]=1) then begin
    {* Move toward the triangle victim...}
    if X[VICTIM[NUM]]<X[NUM] then DIR[NUM]:=3;
    if X[VICTIM[NUM]]>X[NUM] then DIR[NUM]:=4;
    if Y[VICTIM[NUM]]<Y[NUM] then DIR[NUM]:=1;
    if Y[VICTIM[NUM]]>Y[NUM] then DIR[NUM]:=2;
    {* If 'in' victim, then move away}
    if (X[NUM]>X[VICTIM[NUM]]-4) and (X[NUM]<X[VICTIM[NUM]]+4)
    and (Y[NUM]>Y[VICTIM[NUM]]-4) and (Y[NUM]<Y[VICTIM[NUM]]+4)
    THEN VICTIM[NUM]:=0;
  end;
  if (VICTIM[NUM]>0) and (VICTIMTYPE[NUM]=2) then begin
    {* Move toward the object...}
    if ObjY[VICTIM[NUM]]<Y[NUM] then DIR[NUM]:=1;
    if ObjY[VICTIM[NUM]]>Y[NUM] then DIR[NUM]:=2;
    if ObjX[VICTIM[NUM]]<X[NUM] then DIR[NUM]:=3;
    if ObjX[VICTIM[NUM]]>X[NUM] then DIR[NUM]:=4;
    {* If 'in' object, then move away}
    if (X[NUM]>=ObjX[VICTIM[NUM]]-3) and (X[NUM]<=ObjX[VICTIM[NUM]]+3)
    and (Y[NUM]>=ObjY[VICTIM[NUM]]-3) and (Y[NUM]<=ObjY[VICTIM[NUM]]+3)
    THEN VICTIM[NUM]:=0;
  end;
end;


procedure CheckMissCollision(PLN,MISSNUM,CX,CY: Integer);
var Z: Integer;
begin
  {* Check to see if missile hits player}
  for Z:=1 to NumPlayers do if ALIVE[Z]=true then begin
    if (CX>X[Z]-11) and (CX<X[Z]+11) and (CY>Y[Z]-11) and (CY<Y[Z]+11)
    then begin
      Sound(100); Delay(50); Sound(300); Delay(90);
      Sound(1300); Delay(30); NoSound;
      DelMissile(PLN,MISSNUM);
      LoseLife(Z,PLN); {* Z: Who killed, PLN: Who kills}
    end;
  end;
  {* Check to see if Missile goes off edge of play area}
  if (CX<1) or (CX>638) or (CY<1) or (CY>478) then begin
    DelMissile(PLN,MISSNUM);
  end;
end;


procedure ProcessMissiles;
var
  MX,MY,MDIR,B,PLN: Integer;
begin
  for PLN:=1 to 32 do if Alive[PLN] then begin
    {* Make temporary variables for faster processing}
    for B:=1 to NumActiveMissiles[PLN] do begin
      HideMissile(PLN,B);
      {* Depending on direction, draw missile in new pos}
      MX:=MissX[PLN,B]; MY:=MissY[PLN,B]; MDIR:=MissDIR[PLN,B];
      case MDIR of
      1: begin
           MissY[PLN,B]:=MissY[PLN,B]-5;
           SetColor(15); MoveTo(MX,MY-55); LineTo(MX,MY-5);
         end;
      2: begin
           MissY[PLN,B]:=MissY[PLN,B]+5;
           SetColor(15); MoveTo(MX,MY+55); LineTo(MX,MY+5);
         end;
      3: begin
           MissX[PLN,B]:=MissX[PLN,B]-5;
           SetColor(15); MoveTo(MX-55,MY); LineTo(MX-5,MY);
         end;
      4: begin
           MissX[PLN,B]:=MissX[PLN,B]+5;
           SetColor(15); MoveTo(MX+55,MY); LineTo(MX+5,MY);
         end;
      end;
      {* Find points to check for collision, and check it}
      MX:=MissX[PLN,B]; MY:=MissY[PLN,B]; MDIR:=MissDIR[PLN,B];
      if MDIR=1 then MY:=MY-51;
      if MDIR=2 then MY:=MY+51;
      if MDIR=3 then MX:=MX-51;
      if MDIR=4 then MX:=MX+51;
      CheckMissCollision(PLN,B,MX,MY);
    end;
  end;
end;


procedure PlayLevel;
begin
  repeat
    C:='^'; if Keypressed=true then C:=UpCase(ReadKey);
    for G:=1 to NumHumanPlayers do begin                {* Process humans}
      if Alive[G]=true then begin
        if C=KUp[G] then DIR[G]:=1;
        if C=KDown[G] then DIR[G]:=2;
        if C=KLeft[G] then DIR[G]:=3;
        if C=KRight[G] then DIR[G]:=4;
        if C=KFire[G] then CreateMissile(G);
      end;
    end;
    for G:=NumHumanPlayers+1 to NumPlayers do begin     {* Process AI}
      if Alive[G]=true then ProcessAI(G);
    end;
    for G:=1 to NumPlayers do if Alive[G] then begin    {* Process all}
      SetFillStyle(0,0); Bar(X[G]-10,Y[G]-10,X[G]+10,Y[G]+10);
      {* Move it!}
      if DIR[G]=1 then if FastSpeed[G]
        then Y[G]:=Y[G]-2 else Y[G]:=Y[G]-1;
      if DIR[G]=2 then if FastSpeed[G]
        then Y[G]:=Y[G]+2 else Y[G]:=Y[G]+1;
      if DIR[G]=3 then if FastSpeed[G]
        then X[G]:=X[G]-2 else X[G]:=X[G]-1;
      if DIR[G]=4 then if FastSpeed[G]
        then X[G]:=X[G]+2 else X[G]:=X[G]+1;
      {* Check for screen boundaries}
      if X[G]<5 then X[G]:=635;
      if Y[G]<5 then Y[G]:=475;
      if X[G]>635 then X[G]:=5;
      if Y[G]>475 then Y[G]:=5;
      DrawPlayer(G);
    end;
    ProcessMissiles;
    CheckObjCollisions;
    if Random(500-(NumPlayersAlive*20))=1 then CreateObject;
    Delay(SDelay div 300);
  until NumPlayersAlive<2;
end;

end.