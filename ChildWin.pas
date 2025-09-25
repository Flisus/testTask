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
  private
    xPos,yPos:Integer;
    procedure reCalcPB();
  public
    {@arg
      0 - owner
      1 - data}
    constructor createWithImage(AOwner: TComponent;data:string);
  end;
var fBitmap,fScaledBitmap:TBitmap;
    fJpg : TJPEGImage;
    scaleRate,scaleW,scaleH: Double;
implementation

{$R *.dfm}
constructor TMDIChild.createWithImage(AOwner: TComponent;data:string);
begin
  inherited Create(AOwner);
  fBitmap := TBitmap.Create;
  xPos := 0;
  yPos := 0;
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
      scaleH := fBitmap.Height/PaintBox1.Height;
      scaleW := fBitmap.Width/PaintBox1.Width;
      scaleRate := IfThen(scaleW*scaleH>1,scaleW*scaleH,1);
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

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDIChild.PaintBox1Paint(Sender: TObject);
var scW,scH:Integer;
    scRect:TRect;
begin
  if Assigned(fBitmap) and ((fBitmap.Width<>0) and (fBitmap.Height<>0)) then
    begin
      scH := Round(scaleRate*fBitmap.Height);
      scW := Round(scaleRate*fBitmap.Width);
      scRect := Rect(0,0,PaintBox1.Width,PaintBox1.Height);
      PaintBox1.Canvas.StretchDraw(scRect,fBitmap);
    end
  else
    begin
      PaintBox1.Canvas.Brush.Color := clWebWhite;
      PaintBox1.Canvas.FillRect(PaintBox1.Canvas.ClipRect);
    end;
end;

procedure TMDIChild.scr1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var imX,imY,scrX,scrY:Integer;
    tmpScale:Double;
    ntf:TNotifyEvent;
begin
  ntf := trb1Change;
  trb1.OnChange := nil;
  tmpScale := scaleRate;
  scrX := scr1.HorzScrollBar.Position;
  scrY := scr1.VertScrollBar.Position;
  handled := true;
  scaleRate := scaleRate + IfThen(WheelDelta>0,0.1,-0.1);
  scaleRate := Max(0.2,Min(scaleRate,10));
  trb1.Position := Round(scaleRate*100);
  lbPos.Caption := IntToStr(trb1.Position)+'%';
  imX := Round((MousePos.X+xPos)/tmpScale);
  imY := Round((MousePos.Y+yPos)/tmpScale);
  xPos := Round(imX * scaleRate)-MousePos.X;
  yPos := Round(imY * scaleRate)-MousePos.Y;
  reCalcPB;
  scr1.HorzScrollBar.Position := Max(0,xPos);
  scr1.VertScrollBar.Position := Max(0,yPos);
  xPos := Max(0,Min(xPos,Round(fBitmap.Width*scaleRate)-PaintBox1.Width));
  yPos := Max(0,Min(yPos,Round(fBitmap.Height*scaleRate)-PaintBox1.Height));
  trb1.OnChange := ntf;
  PaintBox1.Invalidate;
end;

procedure TMDIChild.trb1Change(Sender: TObject);
begin
  trb1.Position := trb1.Position div 10 * 10;
  scaleRate := trb1.Position /100;
  lbPos.Caption := IntToStr(trb1.Position)+'%';
  xPos := Round(paintBox1.Width*scaleRate) div 2;
  yPos := Round(paintBox1.Height*scaleRate) div 2;
  PaintBox1.Invalidate;
end;

end.
