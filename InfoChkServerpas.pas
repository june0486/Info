unit InfoChkServerpas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet ;

type
  TForm1 = class(TForm)
    Pan_Top: TPanel;
    Pan_Content: TPanel;
    StringGrid1: TStringGrid;
    Pan_Footer: TPanel;
    Btn_Start: TButton;
    Btn_Stop: TButton;
    Btn_Exit: TButton;
    Edt_Interval: TEdit;
    Label1: TLabel;
    Mem_Log: TMemo;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    Timer1: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure Btn_StartClick(Sender: TObject);
    procedure Btn_ExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Btn_StopClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Function ChkMachines(): Boolean;
    procedure SendPush(Msg, Gbn: string);
    procedure DBUpdate(Machine,sIP,Gbn:string);

  end;

var
  Form1: TForm1;

implementation

uses Ping2;

{$R *.dfm}

procedure TForm1.Btn_ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Btn_StartClick(Sender: TObject);
var
  i, j: integer;
begin
  for i := 1 to StringGrid1.RowCount - 1 do
    for j := 0 to 7 do
      StringGrid1.Cells[j, i] := '';

  StringGrid1.RowCount := 2;

  try
    if NOT FDConnection1.Connected then
      FDConnection1.Connected := true;
    with FDQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM infochk_machine ORDER BY gubun,ip_addr');
      OPEN;
      i := 0;
      while not EOF do
      begin
        inc(i);
        StringGrid1.Cells[0, i] := intToStr(i);
        StringGrid1.Cells[1, i] := Fields[0].AsString;
        StringGrid1.Cells[2, i] := Fields[1].AsString;
        StringGrid1.Cells[3, i] := Fields[2].AsString;
        StringGrid1.Cells[4, i] := Fields[3].AsString;
        StringGrid1.Cells[5, i] := Fields[4].AsString;
        StringGrid1.Cells[6, i] := Fields[5].AsString;
        StringGrid1.Cells[7, i] := Fields[6].AsString;
        StringGrid1.RowCount := i + 1;
        Next;
      end;
    end;
  except
    on Exception do
    begin
      Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + '] :'
        + ' DB Connection Failed!!!');
      SendPush('DB Connection Failed! Server Stop', 'ERR');
      Btn_StopClick(Sender);
    end;
  end;

  Btn_Stop.Enabled := true;
  Btn_Start.Enabled := False;

  Timer1.Interval := StrToInt(Edt_Interval.Text) * 10000;
  Timer1.Enabled := true;

  Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) +
    '] : Server Start');
  FDConnection1.Connected := False;
end;

procedure TForm1.Btn_StopClick(Sender: TObject);
begin
  Btn_Start.Enabled := true;
  Btn_Stop.Enabled := False;
  Timer1.Enabled := False;
  Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) +
    '] : Server Stop');
end;

function TForm1.ChkMachines: Boolean;
var
  i :integer;
begin
  Try
    Result := True;
  for i := 1 to StringGrid1.RowCount - 1 do
  begin

    if PingHost(Trim(StringGrid1.Cells[2,i])) then
    begin
      //성공시
      StringGrid1.Cells[ 4, i] := 'Y';

      if Trim(StringGrid1.Cells[ 5, i]) = 'N' then  //이전 체크값이 실패였으면 성공PUSH를 보낸다.
      begin
        SendPush('['+StringGrid1.Cells[1,i]+'] : 복구됨',StringGrid1.Cells[3,i]);
        Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + '] : '+StringGrid1.Cells[1,i]
        + ' : Machine 복구됨!!!');
        StringGrid1.Cells[ 5, i] := 'Y';
        DBUpdate(StringGrid1.Cells[1, i],StringGrid1.Cells[2, i],'Y');
      end;
    end
    else
    begin
      //실패시
      StringGrid1.Cells[ 4, i] := 'N';
      if Trim(StringGrid1.Cells[ 5, i]) = 'Y' then  //이전 체크값이 성공이었으면 실패PUSH를 보낸다.
      begin
        SendPush('['+StringGrid1.Cells[1,i]+'] : 실패',StringGrid1.Cells[3,i]);
        Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + '] : '+StringGrid1.Cells[1,i]
        + ' : Machine 연결실패!!!');
        StringGrid1.Cells[ 5, i] := 'N';
        DBUpdate(StringGrid1.Cells[1, i],StringGrid1.Cells[2, i],'N');
      end;

    end;

    StringGrid1.Cells[6,i] := FormatDateTime('hh:mm:ss',now);
  end;
  Except
    On Exception do Result:=False;
  End;

end;

procedure TForm1.DBUpdate(Machine,sIP, Gbn: string);
begin
  Try
    if not FDConnection1.Connected then FDConnection1.Connected := true;
    FDConnection1.StartTransaction;
    with FDQuery1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add(' UPDATE infochk_machine SET chknow = '''+Gbn+''' , chkold = '''+ Gbn +''' ' );
      SQL.Add(' , chktime = ''' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + ''' ');
      SQL.Add(' WHERE machine = '''+ Machine + ''' AND ip_addr = '''+ sIP + ''' ' );
      ExecSQL;
    end;
  Except
    on Exception do
    begin
      Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + '] :'
        + ' DB Update Failed!!!');
      FDConnection1.Rollback;
      Exit;
    end;
  End;
  FDConnection1.Commit;
  FDConnection1.Connected := False;
  Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + '] : ' +Machine+' : DB UPDATE ('+GBN+')');
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Btn_Stop.Enabled := False;
  StringGrid1.Cells[0, 0] := '순번';
  StringGrid1.Cells[1, 0] := '기기명';
  StringGrid1.Cells[2, 0] := '아이피';
  StringGrid1.Cells[3, 0] := '구분';
  StringGrid1.Cells[4, 0] := '최근';
  StringGrid1.Cells[5, 0] := '이전';
  StringGrid1.Cells[6, 0] := '시간';
  StringGrid1.Cells[7, 0] := '비고';
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TForm1.SendPush(Msg, Gbn: string);
var
  i: integer;
  sSQL : string;
begin
  Exit;

  // GBN: ERR 전체, GBN유저별
  if not FDConnection1.Connected then FDConnection1.Connected := true;
  // ERR로 들어왔을 시 전체 푸시를 날린다.
  sSQL := 'SELECT * FROM infochk_user ';
  // GBN에 해당하는 유저 테이블 만 읽어서 해당 유저에게만 푸시를 날린다.
  if GBN <> 'ERR' then sSQL := sSQL+' WHERE gbn = ''' + Gbn + ''' ';

  with FDQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add(sSQL);
    OPEN;
    while NOT EOF do
    begin
      //Push
      NEXT;
    end;
  end;


end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Try
    ChkMachines;
    //Mem_Log.Lines.Add('Work');
  Except
    on Exception do
    begin
      Mem_Log.Lines.Add('[' + FormatDateTime('YYYY-MM-DD hh:mm:ss', now) + '] : '
        + 'Machines Check Failed!!!');
    end;
  End;
end;

end.
