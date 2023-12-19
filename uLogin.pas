unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uDbFirebird,
  uUser,
  uContext;

type
  TfrmLogin = class(TForm)
    txtUserName: TLabeledEdit;
    txtPass: TLabeledEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  self.Close();
end;

procedure TfrmLogin.btnOkClick(Sender: TObject);
var
  id: integer;
begin
  // validate
  if (not TDbFirebird.isDbConnected()) then
  begin
    TContext.showError('Error al conectar con la base de datos');
    Exit;
  end;

  // exists?
  id := TUser.getId(txtUserName.Text, txtPass.Text);
  if (id = -1) then
  begin
    txtPass.Clear;
    txtPass.SetFocus();
    TContext.showError('Usuario o contraseña incorrect@');
    Exit;
  end;

  // get user object
  TContext.currentUser := TUser.get(id);

  self.ModalResult := mrOk;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  txtUserName.Text := 'admin';
  txtPass.Text := '0';
  {$ENDIF}
end;

end.
