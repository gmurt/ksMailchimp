object Form10: TForm10
  Left = 0
  Top = 0
  Caption = 'Form10'
  ClientHeight = 404
  ClientWidth = 332
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
    Left = 0
    Top = 0
    Width = 332
    Height = 41
    Align = alTop
    Caption = 'Get Mailchimp Audiences'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 0
    Top = 41
    Width = 332
    Height = 167
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
    ExplicitLeft = -8
    ExplicitTop = 47
    ExplicitHeight = 255
  end
  object Panel1: TPanel
    Left = 0
    Top = 208
    Width = 332
    Height = 196
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitLeft = 88
    ExplicitTop = 214
    object Label1: TLabel
      Left = 16
      Top = 37
      Width = 28
      Height = 13
      Caption = 'E-mail'
    end
    object Edit1: TEdit
      Left = 16
      Top = 56
      Width = 289
      Height = 21
      TabOrder = 0
    end
    object Button2: TButton
      Left = 16
      Top = 91
      Width = 289
      Height = 38
      Caption = 'Add E-mail Address To Audience'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
