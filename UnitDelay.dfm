object Form2: TForm2
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Form2'
  ClientHeight = 281
  ClientWidth = 40
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmExplicit
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 8
    Width = 17
    Height = 13
    Caption = '60s'
  end
  object TrackBar1: TTrackBar
    Left = 8
    Top = 22
    Width = 28
    Height = 251
    Max = 605
    Min = 5
    Orientation = trVertical
    Frequency = 60
    Position = 60
    TabOrder = 0
    OnChange = TrackBar1Change
  end
end
