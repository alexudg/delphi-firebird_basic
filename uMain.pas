unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  uContext,
  uDbFirebird,
  uLogin,
  uUsers;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    pnlTop: TPanel;
    btnSession: TSpeedButton;

    bar: TStatusBar;
    menu: TMainMenu;
    Configuracon1: TMenuItem;
    menuUsers: TMenuItem;
    procedure btnSessionClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure menuUsersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    var
      tmrMain: TTimer;
  public
    { Public declarations }
    procedure tic(Sender: TObject);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.btnSessionClick(Sender: TObject);
var
  i: byte;
begin
  // hide menu, buttons & status-bar
  for i := 0 to menu.Items.Count - 1 do
    menu.Items[i].Visible := false;
  pnlTop.Hide;
  bar.Hide;

  frmLogin := TFrmLogin.Create(nil);
  if (frmLogin.ShowModal = mrOk) then
  begin
    // show menu, buttons & status-bar
    for i := 0 to menu.Items.Count - 1 do
      menu.Items[i].Visible := true;
    pnlTop.Show;
    bar.Show;

    // currentUser already exists
    with bar.Panels[0] do
    begin
      Text := 'Usuario: ' + TContext.currentUser.userName;
      Width := 100;//Canvas.TextWidth(Text) + 8;
    end;

    {$IFDEF DEBUG}
    menuUsers.Click;
    {$ENDIF}
  end
  else
    Application.Terminate();
  FreeAndNil(frmLogin);
end;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  ShowMessage(TContext.currentUser.id.ToString())
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  // show on second monitor if debug
  {$IFDEF DEBUG}
  if (Screen.MonitorCount > 1) then
  begin
    self.Position := TPosition.poDesigned;
    self.Left := Screen.Monitors[1].Left +  Screen.Monitors[1].Width div 2 - self.Width div 2;
    self.Top := Screen.Monitors[1].Height div 2 - self.Height div 2;
  end;
  {$ENDIF}
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  tmrMain := TTimer.Create(nil);
  tmrMain.OnTimer := tic;
  tmrMain.Interval := 1;
  //tmrMain.Enabled := true; // default value
end;

procedure TFrmMain.menuUsersClick(Sender: TObject);
begin
  frmUsers := TfrmUsers.Create(nil);
  frmUsers.ShowModal;
  FreeAndNil(frmUsers);
end;

procedure TFrmMain.tic(Sender: TObject);
begin
  tmrMain.Enabled := false;
  FreeAndNil(tmrMain);
  btnSession.Click();
end;

begin
  TContext.print('uMain loaded');
end.
