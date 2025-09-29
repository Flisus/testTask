unit CHILDWIN;

interface

uses Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, JPEG,System.Variants,
  System.SysUtils,Vcl.Dialogs,System.Math;

type
  TMDIChild = class(TForm)
    PaintBox1: TPaintBox;
    trb1: TTrackBar;
    pnl1: TPanel;
    scr1: TScrollBox;
    lbPos: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBox1Paint(Sender: TObject);
    procedure trb1Change(Sender: TObject);
    procedure scr1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
  private
    procedure reCalcPB();
    procedure setCenter();
  public
    {@arg
      0 - owner
      1 - data}
    constructor createWithImage(AOwner: TComponent;data:string);
  end;
var fBitmap,fScaledBitmap:TBitmap;
    fJpg : TJPEGImage;
    scaleRate,scaleW,scaleH,minScale: Double;
implementation

{$R *.dfm}
constructor TMDIChild.createWithImage(AOwner: TComponent;data:string);
begin
  inherited Create(AOwner);
  fBitmap := TBitmap.Create;
    try
      if ExtractFileExt(data)='.jpg' then
         begin
           fJpg := TJPEGImage.Create;
           fJpg.LoadFromFile(data);
           fBitmap.Assign(fJpg);
           fJpg.Free;
         end
      else
        fBitmap.LoadFromFile(data);
      if (fBitmap.Width <= 800) and (fBitmap.Height <= 600) then
        begin
          ClientWidth := fBitmap.Width;
          ClientHeight := fBitmap.Height + pnl1.Height;
        end
      else
        begin
          ClientWidth := MIN(800,fBitmap.Width);
          ClientWidth := MIN(600,fBitmap.Height) + pnl1.Height;
        end;
      scaleH := fBitmap.Height/PaintBox1.Height;
      scaleW := fBitmap.Width/PaintBox1.Width;
      scaleRate := IfThen(scaleW*scaleH>1,scaleW*scaleH,1);
      minScale := scaleRate;
      trb1.Position := Round(scaleRate*100);
      reCalcPB;
      PaintBox1.Repaint;
    except on E: Exception do
      ShowMessage(e.Message)
    end;
end;

procedure TMDIChild.reCalcPB;
begin
  if fBitmap.Width>0 then
    PaintBox1.Width := round(fBitmap.Width*scaleRate)
  else
    PaintBox1.Width := 1;

  if fBitmap.Height>0 then
    PaintBox1.Height := round(fBitmap.Height*scaleRate)
  else
    PaintBox1.Height := 1;
end;

procedure TMDIChild.setCenter;
begin
  if (PaintBox1.Width <= scr1.ClientWidth) and
     (PaintBox1.Height <= scr1.ClientHeight) then
    begin
      scr1.HorzScrollBar.Position := 0;
      scr1.VertScrollBar.Position := 0;
      PaintBox1.Left := (scr1.ClientWidth - PaintBox1.Width) div 2;
      PaintBox1.Top := (scr1.ClientHeight - PaintBox1.Height) div 2;
    end
  else
    begin
      PaintBox1.Left := 0;
      PaintBox1.Top := 0;
    end;
end;

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDIChild.FormResize(Sender: TObject);
begin
  setCenter;
end;

procedure TMDIChild.PaintBox1Paint(Sender: TObject);
var
  scRect: TRect;
begin
  PaintBox1.Canvas.Brush.Color := clWebWhite;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);
  if Assigned(fBitmap) and (fBitmap.Width > 0) and (fBitmap.Height > 0) then
  begin
    scRect := Rect(0, 0, PaintBox1.Width, PaintBox1.Height);
    PaintBox1.Canvas.StretchDraw(scRect, fBitmap);
  end;
end;

procedure TMDIChild.scr1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  tmpScale: Double;
  imX,imY: Integer;
begin
  if not Assigned(fBitmap) or (fBitmap.Width = 0) then Exit;
  Handled := True;
  tmpScale := scaleRate;
  imX := Round((MousePos.X + scr1.HorzScrollBar.Position) / tmpScale);
  imY := Round((MousePos.Y + scr1.VertScrollBar.Position) / tmpScale);
  scaleRate := scaleRate + IfThen(WheelDelta>0,0.1,-0.1);
  scaleRate := Max(0.2,Min(scaleRate,10));
  trb1.Position := Round(scaleRate * 100);
  lbPos.Caption := IntToStr(trb1.Position) + '%';
  reCalcPB;
  scr1.HorzScrollBar.Position := Round(imX * scaleRate) - MousePos.X;
  scr1.VertScrollBar.Position := Round(imY * scaleRate) - MousePos.Y;
  if PaintBox1.Width<Round(fBitmap.Width*minScale) then
     setCenter;
  PaintBox1.Invalidate;
end;


procedure TMDIChild.trb1Change(Sender: TObject);
begin
  trb1.Position := trb1.Position div 10 * 10;
  scaleRate := trb1.Position / 100;
  lbPos.Caption := IntToStr(trb1.Position) + '%';
  reCalcPB;
  PaintBox1.Invalidate;
end;




end.
