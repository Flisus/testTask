object MDIChild: TMDIChild
  Left = 197
  Top = 117
  Caption = 'MDI Child'
  ClientHeight = 645
  ClientWidth = 804
  Color = clBtnFace
  Constraints.MaxHeight = 683
  Constraints.MaxWidth = 816
  Constraints.MinWidth = 300
  ParentFont = True
  FormStyle = fsMDIChild
  Position = poDefault
  Visible = True
  OnClose = FormClose
  TextHeight = 20
  object pnl1: TPanel
    Left = 0
    Top = 604
    Width = 804
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 392
    ExplicitWidth = 622
    object lbPos: TLabel
      Left = 517
      Top = 6
      Width = 35
      Height = 20
      Align = alCustom
      Anchors = [akTop, akRight]
      Caption = 'lbPos'
    end
    object trb1: TTrackBar
      Left = 558
      Top = 4
      Width = 246
      Height = 47
      Align = alCustom
      Anchors = [akRight, akBottom]
      DoubleBuffered = True
      LineSize = 10
      Max = 1000
      Min = 20
      ParentDoubleBuffered = False
      ParentShowHint = False
      Frequency = 10
      Position = 20
      ShowHint = True
      ShowSelRange = False
      TabOrder = 0
      StyleName = 'Windows'
      OnChange = trb1Change
    end
  end
  object scr1: TScrollBox
    Left = 0
    Top = 0
    Width = 804
    Height = 604
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
    OnMouseWheel = scr1MouseWheel
    ExplicitWidth = 622
    ExplicitHeight = 392
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 786
      Height = 600
      OnPaint = PaintBox1Paint
    end
  end
end
