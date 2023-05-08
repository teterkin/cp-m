Program ScreenSaver;

type
  txt = string[255];
  Dot = record
    X: Integer;
    Y: Integer;
    Body: Array[1..12] of Char;
  end;

const
  WUN  = 'Wake up, Neo...';
  MHU  = 'The Matrix has you...';
  FTWR = 'Follow the white rabbit.';
  KKN  = 'Knock, knock, Neo.';
  LongDelay = 100;
  ShortDelay = 90;
  MatrixDelay = 10000;
  MatrixDelay2 = 7000;
  MatrixDelay3 = 4000;
  Delay3 = 1000;
  MX = 8; MY = 4;
  DoDelay = True; NoDelays = False;
  NumberOfLines = 20;
  Times = 96;

var
  i,k,n,DRY: Integer;
  Lines: array[1..NumberOfLines] of Dot;

Procedure CheckPress;
begin
  if KeyPressed then
  begin
    ClrScr;
    write(chr(31));
    Halt;
  end;
end;

Procedure MyDelay(MyDel: Integer);
begin
  for i := 1 to MyDel do
  begin
    Delay(1);
    CheckPress;
  end;
end;

Procedure TypeIt(X,Y: Integer; S: txt; DoDelay: Boolean);
var
  i: Integer;
  FirstDelay: Integer;
  RandDelay: Integer;
begin
  FirstDelay := LongDelay;
  GotoXY(X,Y);
  for i := 1 to length(S) do
  begin
    CheckPress;
    write(S[i]);
    Case S[i] of
      ' ': RandDelay := 0;
      '.': RandDelay := 20;
      else RandDelay := Round(100 + Random * 100);
    end;
    if DoDelay = False then
    begin
      RandDelay := 0;
      FirstDelay := ShortDelay;
    end;
    MyDelay(FirstDelay + RandDelay);
  end;
end;

Begin
  While True do
  begin
    ClrScr;
    TypeIt(MX, MY, WUN, DoDelay);
    MyDelay(MatrixDelay);
    ClrScr;
    TypeIt(MX, MY, MHU, DoDelay);
    MyDelay(MatrixDelay2);
    ClrScr;
    TypeIt(MX, MY, FTWR, DoDelay);
    MyDelay(MatrixDelay2);
    ClrScr;
    TypeIt(MX, MY, KKN, NoDelays);
    { Initialize the Lines }
    for i := 1 to NumberOfLines do
    begin
      Lines[i].X := 1 + round(78 * Random);
      Lines[i].Y := -36 + round(36 * Random);
      for k := 1 to 11 do
        Lines[i].Body[k] := chr(33 + round(221 * Random));
      Lines[i].Body[12] := ' ';
      { Writeln(i,' = (',Lines[i].X,',',Lines[i].Y,')'); }
    end;
    MyDelay(MatrixDelay3);
    ClrScr;
    write(chr(30));
    for i := 1 to Times do
    begin
      for k:= 1 to NumberOfLines do
      begin
        CheckPress;
        { Writeln(k,' = (',Lines[k].X,',',Lines[k].Y,')'); }
        if Lines[k].Y >= 1 then
          Lines[k].Body[1] := chr(33 + round(221 * Random));
          for n:= 1 to 12 do
          begin
            CheckPress;
            DRY := Lines[k].Y + 1 - n;
            { Draw only ones that on screen }
            if (DRY >=1) and (DRY <= 24) then
            begin
              GotoXY(Lines[k].X, DRY);
              Write(Lines[k].Body[n]);
            end;
          end;
        Lines[k].Y := Lines[k].Y + 1;
        { 24 + 12 = 26 }
        if Lines[k].Y >= 36 then
        begin
          Lines[k].Y := -10 + round(10 * Random);
          Lines[k].X := 1 + round(78 * Random);
        end;
      end;
    end;
    for i := 1 to 15 do
    begin
      GotoXY(26, i + 4);
      Write('                              ');
    end;
    gotoXY(31,7); Write('             /     ');
    gotoXY(31,8); Write('ÚÄÄ¿ ÂÄÄ¿   / Ú¿ Ú¿');
    gotoXY(31,9); Write('³    ³  ³  /  ³ÀÄÙ³');
    gotoXY(31,10);Write('³    ÃÄÄÙ /   ³   ³');
    gotoXY(31,11);Write('³    ³   /    ³   ³');
    gotoXY(31,12);Write('ÀÄÄÙ Á  /     Á   Á');
    gotoXY(31,13);Write('       /           ');
    MyDelay(Delay3);
    write(chr(31));
    TypeIt(37, 15, 'INSIDE', DoDelay);
    MyDelay(Delay3);
    TypeIt(29, 17, 'Press Any Key to Exit...', DoDelay);
    MyDelay(MatrixDelay);
  end;
End.
