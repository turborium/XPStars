unit uMain;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  TStar = record
    X, Y: Integer;
    Z: Double;
  end;

  { TFormMain }

  TFormMain = class(TForm)
    PaintBoxDisp: TPaintBox;
    TimerAnimate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxDispPaint(Sender: TObject);
    procedure TimerAnimateTimer(Sender: TObject);
  private const
    StarsCount = 500;
    StarsSpeed = 0.05;
    StarsMaxDepth = 8.0;
    StarsRotateSpeed = 0.007;
  private
    Stars: array of TStar;
    Bright: Integer;
    Angle: Double;
    procedure SetRandomCoord(var Star: TStar);
  public

  end;

var
  FormMain: TFormMain;

implementation

uses
  Math;

{$R *.lfm}

{ TFormMain }

procedure DrawStar(const Canvas: TCanvas; X, Y, Size: Integer);
var
  HalfSize: Integer;
begin
  if Size < 1 then
    Size := 1;
  if Size > 6 then
    Size := 6;

  HalfSize := Size div 2;
  Canvas.FillRect(X - HalfSize, Y - HalfSize, X - HalfSize + Size, Y - HalfSize + Size);
end;

procedure TFormMain.PaintBoxDispPaint(Sender: TObject);
var
  Canvas: TCanvas;
  I: Integer;
  X, Y: Double;
begin
  Canvas := TPaintBox(Sender).Canvas;

  // clear screen
  Canvas.Brush.Color := clBlack;
  Canvas.FillRect(0, 0, PaintBoxDisp.ClientWidth, PaintBoxDisp.ClientHeight);

  // draw stars
  Canvas.Brush.Color := RGBToColor(Bright, Bright, Bright);
  for I := 0 to High(Stars) do
  begin
    // rotate
    // X' = X * Cos(Angle) - Y * Sin(Angle)
    // Y' = X * Sin(Angle) + Y * Cos(Angle)
    X := Stars[I].X * Cos(Angle) - Stars[I].Y * Sin(Angle);
    Y := Stars[I].X * Sin(Angle) + Stars[I].Y * Cos(Angle);
    // SX := SW + X / Z
    // SY := SH + Y / Z
    DrawStar(
      Canvas,
      PaintBoxDisp.ClientWidth div 2 + Trunc(X / Stars[I].Z),
      PaintBoxDisp.ClientHeight div 2 + Trunc(Y / Stars[I].Z),
      Trunc((StarsMaxDepth * 1.2) / Stars[I].Z)
    );
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Bright := 0;

  SetLength(Stars, StarsCount);
  // generate
  for I := 0 to High(Stars) do
  begin
    SetRandomCoord(Stars[I]);
    repeat
      Stars[I].Z := Random * StarsMaxDepth;
    until not (Stars[I].Z = 0);
  end;
end;

procedure TFormMain.TimerAnimateTimer(Sender: TObject);
var
  I: Integer;
begin
  Bright := Bright + 4;
  if Bright > 255 then
    Bright := 255;

  // move
  for I := 0 to High(Stars) do
  begin
    // decrease Z coord
    Stars[I].Z := Stars[I].Z - StarsSpeed;
    // if Z <= 0 then Z := StarsMaxDepth
    if Stars[I].Z <= 0 then
    begin
      SetRandomCoord(Stars[I]);
      Stars[I].Z := StarsMaxDepth;
    end;
  end;

  Angle := Angle + StarsRotateSpeed;

  PaintBoxDisp.Invalidate;
end;

procedure TFormMain.SetRandomCoord(var Star: TStar);
var
  Size: Integer;
begin
  Size := Max(PaintBoxDisp.ClientWidth, PaintBoxDisp.ClientHeight);
  Star.X := RandomRange(-Size, Size);
  Star.Y := RandomRange(-Size, Size);
end;

end.

