program Project1;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {FrmMain},
  uDbFirebird in 'uDbFirebird.pas',
  uContext in 'uContext.pas',
  uLogin in 'uLogin.pas' {frmLogin},
  uUser in 'uUser.pas',
  uUsers in 'uUsers.pas' {frmUsers};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
