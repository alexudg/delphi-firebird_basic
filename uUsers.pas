unit uUsers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids,
  System.Generics.Collections,
  System.UITypes,
  uContext,
  uUser, Vcl.Buttons, Vcl.StdCtrls;

type
  TfrmUsers = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    grid: TStringGrid;
    pnlList: TPanel;
    bar: TStatusBar;
    pnlFields: TPanel;
    btnInsert: TSpeedButton;
    btnUpdate: TSpeedButton;
    btnDelete: TSpeedButton;
    txtUserName: TLabeledEdit;
    boxPass: TGroupBox;
    txtPass: TLabeledEdit;
    txtConfirm: TLabeledEdit;
    txtAge: TLabeledEdit;
    checkIsPass: TCheckBox;
    btnSave: TSpeedButton;
    btnCancel: TSpeedButton;
    barFields: TStatusBar;
    error: TBalloonHint;
    procedure FormCreate(Sender: TObject);
    procedure checkIsPassClick(Sender: TObject);
    procedure btnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure btnDeleteClick(Sender: TObject);
  private
    { Private declarations }
    _users: TList<TUser>;
    _id: integer;
    procedure _usersLoad(idSelect: integer = -1);
    procedure _loadUser(i: integer);
  public
    { Public declarations }
  end;

var
  frmUsers: TfrmUsers;

implementation

{$R *.dfm}

procedure TfrmUsers.btnClick(Sender: TObject);
var
  idBtn: byte;
  user: TUser;
begin
  idBtn := (Sender as TSpeedButton).Tag;

  // save: validate
  if (idBtn = 1) then
  begin
    Trim(txtUserName.Text);
    if (txtUserName.Text = '') then
    begin
      error.Description := 'Nombre vacío';
      error.ShowHint(txtUserName);
      Exit;
    end;

    // verify if username exists
    if (TUser.isExists(txtUserName.Text, _id)) then
    begin
      error.Description := 'Nombre de usuario ya existe';
      error.ShowHint(txtUserName);
      Exit;
    end;

    if (txtAge.Text = '') then
    begin
      error.Description := 'Edad vacía';
      error.ShowHint(txtAge);
      Exit;
    end;

    // isPass
    if (checkIsPass.Checked) then
    begin
      if (txtPass.Text = '') then
      begin
        error.Description := 'Contraseña vacía';
        error.ShowHint(txtPass);
        Exit;
      end;
      if (txtConfirm.Text = '') then
      begin
        error.Description := 'Confirmación vacía';
        error.ShowHint(txtConfirm);
        Exit;
      end;
      if (txtPass.Text <> txtConfirm.Text) then
      begin
        txtPass.Clear;
        txtConfirm.Clear;
        error.Description := 'Contraseñas diferentes';
        error.ShowHint(txtPass);
        Exit;
      end;
    end;
  end;

  // cancel|save
  if (idBtn <= 1) then
  begin
    // cancel
    if (idBtn = 0) then
      _loadUser(grid.Row - 1)
    // save
    else
    begin
      user := TUser.Create(
        _id,
        txtUserName.Text,
        txtPass.Text,
        StrToInt(txtAge.Text)
      );
      // insert
      if (user.id = -1) then
        user.id := TUser.insert(user)
      // update
      else
        TUser.update(user);
      _usersLoad(user.id);
    end;
    checkIsPass.Hide;
    boxPass.Hide;
    txtPass.Clear;
    txtConfirm.Clear;
    barFields.Panels[0].Text := 'Observando usuario seleccionado';
  end;

  // enable|disable controls
  pnlList.Visible := idBtn <= 1;
  grid.Enabled := idBtn <= 1;
  pnlFields.Visible := idBtn >= 2;
  txtUserName.Enabled := idBtn >= 2;
  txtAge.Enabled := idBtn >= 2;

  // update|insert
  if (idBtn >= 2) then
  begin
    // update
    if (idBtn = 2) then
    begin
      _id := _Users[grid.Row - 1].id;
      checkIsPass.Checked := false;
      checkIsPass.Show;
      barFields.Panels[0].Text := 'Editando usuario seleccionado';
    end
    // insert
    else
    begin
      _id := -1;
      txtUserName.Clear;
      txtAge.Clear;
      checkIsPass.Checked := true;
      boxPass.Show;
      barFields.Panels[0].Text := 'Agregando nuevo usuario';
    end;
  end;
end;

procedure TfrmUsers.btnDeleteClick(Sender: TObject);
var
  id: integer;
begin
  id := _users[grid.Row - 1].id;
  if (id = 0) then
  begin
    TContext.showError('No esta permitido eliminar al super-admin');
    Exit;
  end;
  if (MessageDlg('¿Estás segur@ de eliminar al usuario seleccionado?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    TUser.delete(id);
    _usersLoad(-1);
  end;
end;

procedure TfrmUsers.checkIsPassClick(Sender: TObject);
begin
  boxPass.Visible := checkIsPass.Checked;
end;

procedure TfrmUsers.FormCreate(Sender: TObject);
begin
  error.Title := 'ERROR';

  with grid do
  begin
    Cells[0,0] := 'Usuario';
    Cells[1,0] := 'Edad';
  end;

  _usersLoad();
end;

procedure TfrmUsers.FormShow(Sender: TObject);
begin
  btnCancel.Click;
end;

procedure TfrmUsers.gridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  i: integer;
begin
  i := ARow - 1;
  _loadUser(i);
end;

procedure TfrmUsers._loadUser(i: integer);
begin
  txtUserName.Text := _users[i].userName;
  txtAge.Text := _users[i].age.ToString();
end;

procedure TfrmUsers._usersLoad(idSelect: integer = -1);
var
  i: integer;
begin
  _users := TUser.getAll();

  // show|hide buttons
  btnUpdate.Visible := _users.Count > 0;
  btnDelete.Visible := _users.Count > 0;

  with grid do
  begin
    if (_users.Count > 0) then
    begin
      RowCount := _users.Count + 1;
      for i := 0 to _users.Count - 1 do
      begin
        Cells[0, i + 1] := _users[i].userName;
        Cells[1, i + 1] := _users[i].age.ToString();

        // select
        if (_users[i].id = idSelect) then
          Row := i + 1;
      end;
    end
    else
    begin
      RowCount := 2;
      Rows[1].Clear;
    end;
  end;

  with bar.Panels[0] do
  begin
    Text := _users.Count.ToString() + ' usuario';
    if (_users.Count <> 1) then
      Text := Text + 's';
  end;

  _loadUser(grid.Row - 1);
end;

end.
