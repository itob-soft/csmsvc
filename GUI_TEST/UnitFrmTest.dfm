object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 430
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 112
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 24
    Top = 104
    Width = 163
    Height = 25
    Caption = 'Decompress'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Memo1: TMemo
    Left = 24
    Top = 168
    Width = 441
    Height = 209
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 3
  end
end
