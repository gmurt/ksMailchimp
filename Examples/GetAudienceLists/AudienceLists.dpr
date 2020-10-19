program AudienceLists;

uses
  Vcl.Forms,
  untMain in 'untMain.pas' {Form10},
  ksMailChimp in '..\..\ksMailChimp.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm10, Form10);
  Application.Run;
end.
