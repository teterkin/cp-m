Program Piton;
{ Игра Питон }
{ Alexander Teterkin. Copyleft }

Const
  FILENAME = 'PITON.REC';
  StartX = 26;
  StartY = 10;
  MaxLen = 20;
  StartLen = 4;
  StartLvl = 20;
  MaxApples = 20;
  MaxGT = 500;
  LowGT = 250;
  NoGT = 125;
  SYT    = 'Сыт─────────────';
  VGOLOD = 'Очень голоден!──';
  GOLOD  = 'Голоден─────────';
  POMER  = 'Помер! А Жаль...';

Type
  ScreenArray = array[1..24, 1..80] of Char;
  HelpArea    = array[3..22, 1..76] of Char;
  txt = string[80];

Var
  c: char;
  sch: char;
  X,Y: array[1..100] of Integer;
  i,k,PitLen,Level,Apples,GT,TrueLvl,Lives,Score: Integer;
  Dir: char; { Direction: l=left, r=right, u=up, d=down, x=dead, s=stopped }
  scr: ScreenArray absolute $f800;
  HelpBuf: HelpArea;
  alive,GameOver: Boolean;
  rec_file                           : Text;
  Line,Name,NameTemp,ScoreStr,RecStr : String[255];
  OK                                 : Boolean;
  RecScore,position,Result           : Integer;
  Names                              : array[1..5] of String[255];
  Scores                             : array[1..5] of Integer;

Procedure AbsWrite(X,Y:Integer; T:txt);
var k,NX: Integer;
begin
  if (X>=1) and (X<=80) and (Y>=1) and (Y<=24) then
  begin
    for k := 1 to length(T) do
    begin
      NX := X + k - 1;
      if NX <= 80 then
        scr[Y,NX] := T[k];
    end;
  end;
end;

Procedure MakeApple;
var AX,AY: Integer;
begin
  AX := 2 + Round(76 * Random);
  AY := 2 + Round(20 * Random);
  AbsWrite(AX, AY, '@');
end;

Procedure Help;
var
  i,ty, RecLength, Dots: Integer;
  ScoreStrTemp: String[255];

begin
  {76x20}
  for ty := 3 to 22 do
  begin
    Move(scr[ty,3],HelpBuf[ty,1],76);
    FillChar(scr[ty,3],76,' ');
  end;
  GotoXY(16,6); Write('Привет!');
  GotoXY(5,8);  Write('Добро пожаловать в Игру ПИТОН!');
  GotoXY(5,10); Write('- Управляй курсором с помощью стрелок.');
  GotoXY(5,11); Write('- Клавиша ''F1'' - Показ этой справки.');
  GotoXY(5,12); Write('- Клавиша ''ESC'' или ''Q'' - Выход.');
  GotoXY(5,14); Write('Собирай яблоки @ и расти большой!!!');
  GotoXY(5,15); Write('Постарайся не кусать себя за хвост.');
  GotoXY(5,16); Write('Кусать стенки - тоже плохая идея ))');

  GotoXY(55,8); Write('Таблица рекордов:');
  GotoXY(55,9); Write('=================');
  for i := 1 to 5 do
  begin
    { 27 }
    RecStr := Names[i];
    Delete(RecStr,21,255);
    Str(Scores[i],ScoreStrTemp);
    Dots := 27 - Length(RecStr) - Length(ScoreStrTemp);
    For k := 1 to Dots do
      RecStr := RecStr + '.';
    RecStr := RecStr + ScoreStrTemp;
    GotoXY(50,9 + i);Write(RecStr);
  end;

  GotoXY(10,18); Write('Нажми на любую клавишу!');

  While True do
  begin
   if KeyPressed then
   begin
     c := #0;
     for ty := 3 to 22 do
       Move(HelpBuf[ty,1],scr[ty,3],76);
     exit;
   end;
   Delay(50);
  end;
end;

Procedure DrawFrame;
begin
  scr[1,1] := '┌';
  FillChar(scr[1,2],78,'─');
  scr[1,80] := '┐';
  for i := 2 to 23 do
  begin
    scr[i,1] := '│';
    scr[i,80] := '│';
  end;
  FillChar(scr[24,2],80,'─');
  scr[24,1] := '└';
  scr[24,80] := '┘';
  GotoXY(10,24); Write('ESC:Выход──F1:Справка');
end;

Procedure DrawPiton;
var
  i: Integer;
  head: char;
begin
  Case Dir of
    'l': head := '>';
    'r': head := '<';
    's': head := 'Z';
    'u': head := 'V';
    'd': head := 'Л';
    'x': head := 'X';
  end;
  scr[y[1],x[1]] := head;
  for i:=2 to PitLen-1 do
    scr[y[i],x[i]] := '▒';
  scr[y[PitLen],x[PitLen]] := ' ';
end;

Procedure CheckWall;
begin
  if (X[1] >= 80) or (X[1] <= 1) or (Y[1] <= 1) or  (Y[1] >= 24) then
  begin
    alive := False;
  end;
end;

Procedure MovePiton;
begin
  if Dir <> 's' then
  begin
    for i:= PitLen downto 2 do
    begin
      x[i] := x[i-1];
      y[i] := y[i-1];
    end;
    case Dir of
      'r': x[1] := x[1] + 1;
      'l': x[1] := x[1] - 1;
      'u': y[1] := y[1] - 1;
      'd': y[1] := y[1] + 1;
    end;
    CheckWall;
  end;
end;

Procedure UpdateStats;
var NLives,NScore,NPL,NLev,Nnada: String[5];
begin
  Str(Lives, NLives);
  AbsWrite(4,1,'Жизней:' + NLives);
  Str(Score,NScore);
  AbsWrite(15,1,'Очки:' + NScore);
  if alive then
    case GT of
      LowGT..MaxGT: AbsWrite(32,1,SYT);
      0..NoGT:      AbsWrite(32,1,VGOLOD);
      else          AbsWrite(32,1,GOLOD);
    end
  else
    AbsWrite(32,1,POMER);
  Str(PitLen, NPL);
  Str(TrueLvl*20,NNada);
  absWrite(53, 1, 'Длинна:' + NPL + '/' + NNada);
  Str(TrueLvl, NLev);
  absWrite(68,1, 'Уровень:' + NLev);
end;

Procedure NewStart;
begin
  PitLen := StartLen;
  Dir := 's';
  Apples := 0;
  GT := MaxGT;
  for i:=1 to PitLen do
  begin
    X[i] := StartX - i + 1;
    Y[i] := StartY;
  end;
  alive := True;
  ClrScr;
  Write(#14,#30);
  DrawFrame;
  for i:=1 to MaxApples do MakeApple;
end;

Procedure Init;
Begin
  TrueLvl := 1;
  GameOver := False;
  Level := StartLvl - ((TrueLvl - 1) * 5);
  Lives := 3;
  Score := 0;
  NewStart;
End;

Procedure CleanUp;
begin
  ClrScr;
  WriteLN(#15,#31);
  WriteLn('Возвращайся скорее!');
end;

Procedure CheckRec;
var
  ty,i: Integer;

begin
  if Score > Scores[5] then
  begin
    { WriteLn('Name=',Name);
    Delay(5000); }
    if Name = '' then
    begin
      {76x20}
      for ty := 3 to 22 do
      begin
        Move(scr[ty,3],HelpBuf[ty,1],76);
        FillChar(scr[ty,3],76,' ');
      end;
      GotoXY(16,6); Write('Ты поставил рекорд!');
      GotoXY(16,7); Write(Score, ' очков!');
      Write(#31);
      GotoXY(16,9); Write('Введи свое имя: ');
      ReadLn(Name);
      Write(#30);
      if Name = '' then
        Name := 'Вася';
      for ty := 3 to 22 do
        Move(HelpBuf[ty,1],scr[ty,3],76);
    end;
    Scores[5] := Score;
    Names[5] := Name;
    { WriteLn('Массив очков:');
    for i := 1 to 5 do
      WriteLn(Names[i],';;',Scores[i]);
    WriteLn('Сортирую массив...'); }
    for i := 4 downto 1 do
      if Scores[i] < Scores[i+1] then
      begin
        Name := Names[i];
        RecScore := Scores[i];
        Names[i] := Names[i+1];
        Scores[i] := Scores[i+1];
        Names[i+1] := Name;
        Scores[i+1] := RecScore;
      end;
    { WriteLn('Массив очков:');
    for i := 1 to 5 do
      WriteLn(Names[i],';;',Scores[i]);
    WriteLn('Сохраняю массив в файл...'); }
    Rewrite(rec_file);
    for i := 1 to 5 do
    begin
      Str(Scores[i], ScoreStr);
      WriteLn(rec_file, Names[i] + ';' + ScoreStr);
    end;
    Close(rec_file);
  end;
end;

Procedure Win;
var
  k: Integer;
  NS: String[15];

begin
  ClrScr;
  DrawFrame;
  AbsWrite(15,10,'#####  #####  #####  #####     ##    #     ###');
  AbsWrite(15,11,'#   #  #   #  #      #        # #   # #    ###');
  AbsWrite(15,12,'#   #  #   #  #####  #####   #  #  #   #    # ');
  AbsWrite(15,13,'#   #  #   #  #   #  #      #   #  #####      ');
  AbsWrite(15,14,'#   #  #####  #####  ## ##  #####  #   #    # ');
  AbsWrite(20,16,'Нажмите любую клавишу для продолжения!');
  Str(Score,NS);
  AbsWrite(28,18,'Набрано очков:' + NS);
  While True do
  begin
    if KeyPressed then
    begin
      c := #0;
      NewStart;
      TrueLvl := TrueLvl + 1;
      if TrueLvl > 5 then
      begin
        GameOver := True;
      exit;
      end;
      Level := StartLvl - ((TrueLvl - 1) * 5);
      if Level < 5 then Level := 5;
      exit;
    end;
    Delay(50);
  end;
end;

Procedure Lost;
var
  k: Integer;
  NS: String[15];
begin
  ClrScr;
  DrawFrame;
  AbsWrite(25,10,'#####  #####  #####       ');
  AbsWrite(25,11,'#   #  #   #  #           ');
  AbsWrite(25,12,'#   #  #   #  #           ');
  AbsWrite(25,13,'#   #  #   #  #           ');
  AbsWrite(25,14,'#####  #   #  #####  # # #');
  AbsWrite(18,16,'Нажмите любую клавишу для продолжения!');
  Str(Score,NS);
  AbsWrite(28,18,'Набрано очков:' + NS);
  Lives := Lives - 1;
  alive := True;
  if Lives = 0 then
  begin
    AbsWrite(25,20,'Жизни кончились! А жаль...');
    Delay(4000);
    CheckRec;
    Name := '';
    ClrScr;
    Init;
    Help;
    exit;
  end;
  While True do
  begin
    if KeyPressed then
    begin
      c := #0;
      NewStart;
      exit;
    end;
    Delay(50);
  end;
end;

Begin
  Name := '';
  Assign(rec_file, FILENAME);
  {$I-} Reset(rec_file); {$I+}
  OK := (IOresult = 0);
  if not OK then
  begin
    WriteLn('Файл ', FILENAME, ' не найден!');
    WriteLn('Создаю новый...');
    Rewrite(rec_file);
    for i := 1 to 5 do
      WriteLn(rec_file,'Пусто;0');
    Close(rec_file);
  end
  else
  begin
    WriteLn('Файл ', FILENAME, ' найден.');
    WriteLn('Загружаю данные таблицы рекордов...');
    k := 1;
    While not EOF(rec_file) do
    begin
      ReadLn(rec_file, Line);
      { WriteLn(Line); }
      position := pos(';',Line);
      NameTemp := Copy(Line, 1, position - 1);
      ScoreStr := Copy(Line, position + 1, Length(Line)-position);
      Val(ScoreStr,RecScore,Result);
      WriteLn('Name=',NameTemp,', RecScore=',ScoreStr);
      { WriteLn(RecScore); }
      Names[k] := NameTemp;
      Scores[k] := RecScore;
      k := k + 1;
    end;
    Close(rec_file);
  end;
  ClrScr;
  DrawFrame;
  Help;
  Init;
  Repeat
    MovePiton;
    if scr[Y[1],X[1]] = '▒' then
    begin
      AbsWrite(25,18,'Укусил себя за хвост!');
      Delay(2000);
      alive := false;
      Dir := 'r';
      c := #0;
    end;
    if not alive then
    begin
      Write(#15,#31);
      Lost;
    end;
    if scr[Y[1],X[1]] = '@' then
    begin
      Apples := Apples + 1;
      Score := Score + TrueLvl;
      GT := GT + NoGT;
      if GT > MaxGT then GT := MaxGT;
      PitLen := PitLen + 1;
      if PitLen > TrueLvl*20  then
      begin
        Win;
      end;
    end;
    DrawPiton;
    port[222] := Level;

    Repeat
      if BIOS(1) = 255 then
      begin
        c := Upcase(BIOS(2));
        port[222] := 0;
      end;
    Until port[222] = 0;

    GT := GT - 1;
    if GT <= 0 then
    begin
      Lost;
    end;

    if GT mod 15 = 0 then
    begin
      MakeApple;
    end;

    case c of
      ^S: begin { left }
            Dir := 'l';
          end;
      ^E: begin { up }
            Dir := 'u';
          end;
      ^X: begin { down }
            Dir := 'd';
          end;
      ^D: begin { right }
            Dir := 'r';
          end;
      #10: begin { F1 }
             help;
             Dir := 's';
           end;
    end;

    UpdateStats;

  Until (c = #27) or (c = 'Q') or (c = ^C) or (GameOver = True);
  CheckRec;
  CleanUp;
  if GameOver then
  begin
    WriteLn('Ты настоящий змеюка!');
  end;
End.
