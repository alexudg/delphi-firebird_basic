unit uContext;

interface

uses
  Winapi.Windows,
  Vcl.Dialogs,
  System.UITypes,
  uUser;

type
  TContext = class
    public
      class var
        currentUser: TUser;
      class procedure print(txt: string); static;
      class procedure showError(txt: string); static;
      class function showConfirmation(target: string; isFemale: boolean = false): boolean; static;
  end;

implementation

{ TContext }

class procedure TContext.print(txt: string);
begin
  Winapi.Windows.OutputDebugString(PWideChar('..........' + txt + '          '));
end;

class function TContext.showConfirmation(target: string;
  isFemale: boolean): boolean;
var
  txt: string;
begin
  txt := '¿Estás segur@ de eliminar ';
  if (isFemale) then
    txt := txt + ' la '
  else
    txt := txt + ' el ';
  txt := txt + target;
  if (isFemale) then
    txt := txt + ' seleccionada?'
  else
    txt := txt + ' seleccionado?';
  Result := MessageDlg(txt, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

class procedure TContext.showError(txt: string);
begin
  MessageDlg('', mtError, [], 0);
end;

begin
  TContext.print('uContext loaded');
  TContext.currentUser := TUser.Create(-1, '', '', 0);
end.
