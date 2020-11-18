object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #44221#50689#51221#48372#54016'IP'#52404#53356#49436#48260'App'
  ClientHeight = 820
  ClientWidth = 902
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Pan_Top: TPanel
    Left = 0
    Top = 0
    Width = 902
    Height = 65
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 29
      Width = 63
      Height = 13
      Caption = #51312#54924#44036#44201'('#48516')'
    end
    object Btn_Start: TButton
      Left = 624
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Start'
      TabOrder = 0
      OnClick = Btn_StartClick
    end
    object Btn_Stop: TButton
      Left = 720
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Stop'
      TabOrder = 1
      OnClick = Btn_StopClick
    end
    object Btn_Exit: TButton
      Left = 816
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Exit'
      TabOrder = 2
      OnClick = Btn_ExitClick
    end
    object Edt_Interval: TEdit
      Left = 128
      Top = 26
      Width = 57
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      MaxLength = 2
      NumbersOnly = True
      TabOrder = 3
      Text = '1'
    end
  end
  object Pan_Content: TPanel
    Left = 0
    Top = 65
    Width = 902
    Height = 555
    Align = alClient
    TabOrder = 1
    object StringGrid1: TStringGrid
      Left = 1
      Top = 1
      Width = 900
      Height = 553
      Align = alClient
      ColCount = 8
      DefaultColWidth = 80
      TabOrder = 0
    end
  end
  object Pan_Footer: TPanel
    Left = 0
    Top = 620
    Width = 902
    Height = 200
    Align = alBottom
    TabOrder = 2
    object Mem_Log: TMemo
      Left = 1
      Top = 1
      Width = 900
      Height = 198
      Align = alClient
      Lines.Strings = (
        '')
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=MySQL'
      'User_Name=appslogin'
      'Password=appslogindelphi'
      'Server=34.64.75.224'
      'Database=juneapps'
      'CharacterSet=utf8mb4')
    LoginPrompt = False
    Left = 232
    Top = 8
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 320
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 424
    Top = 8
  end
end
