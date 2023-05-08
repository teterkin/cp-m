Program DMA;

Const
  Times = 30;
  Deviation = 20;

Type
  ScreenArray = array[1..24, 1..80] of Char;

Var
  scr: ScreenArray absolute $f800;
  buf: ScreenArray;
  i,x,y: Integer;

Procedure CheckPress;
begin
  if KeyPressed then
  begin
    ClrScr;
    write(chr(31));
    GotoXY(5,3);
    Write('We''re human - and maybe that''s the word the best explain us.');
    GotoXY(4,4);
    Writeln(' Ä Captain Kirk, Star Trek.');
    Halt;
  end;
end;

Procedure MakeSpace;
begin
  FillChar(buf,24*80,' ');
  for i := 1 to 100 do
  begin
    x := 1 + Round(79 * Random);
    y := 1 + Round(23 * Random);
    buf[y, x] := '.';
  end;
  Move(buf, scr, 24*80);
end;

Begin
  MakeSpace;
  Write(chr(30));
  GotoXY(10,6); Write(' Space: the final frontier ');
  GotoXY(10,7); Write(' These are the voyages of the starship Enterprise ');
  GotoXY(10,8); Write(' Its continuing mission: to explore strange new worlds ');
  GotoXY(10,9); Write(' To seek out new life and new civilizations ');
  GotoXY(10,10); Write(' To boldly go where no one has gone before! ');
  i := 0;
  While True do
  begin
    CheckPress;
    x := 1 + Round(79 * Random);
    y := 1 + Round(23 * Random);
    if (y < 6) or (y > 10) or ((x < 10) or (x > 64)) then
    begin
      if i mod Deviation = 0 then
      begin
        scr[y, x] := '.';
      end
      else
      begin
        scr[y, x] := ' ';
      end;
    end;
{    write(y);}
    i := i + 1;
    if i = (MaxInt - 1) then
      i := 0
  end;
End.
