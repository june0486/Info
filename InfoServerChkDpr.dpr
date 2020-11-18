program InfoServerChkDpr;

uses
  Vcl.Forms,
  InfoChkServerpas in 'InfoChkServerpas.pas' {Form1},
  Ping2 in 'Ping2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
