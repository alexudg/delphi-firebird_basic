unit uDbFirebird;

interface

uses
  Winapi.Windows,
  System.Generics.Collections,
  System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TDicStrVar = TDictionary<string, variant>;
  TDbFirebird = class
    private
      // static vars
      class var
        conFb: TFDConnection;
        qryFB: TFDQuery;
    public
      class function isDbConnected: boolean; static;
      class function executeScalar(sql: string; params: Array of variant): variant; static;
      class procedure executeNotQuery(sql: string; params: Array of variant); static;
      class function executeQuery(sql: string; params: Array of variant): TDictionary<string, variant>; static;
      class function executeQueryAll(sql: string; params: Array of variant): TList<TDicStrVar>; static;
  end;

implementation

{ TDbFirebird }

class procedure TDbFirebird.executeNotQuery(sql: string;
  params: array of variant);
var
  i: byte;
begin
  with TDbFirebird do
  begin
    qryFb.Params.Clear;
    qryFb.SQL.Text := sql;
    if (Length(params) > 0) then
    begin
      for i := 0 to Length(params) - 1 do
      begin
        qryFb.Params[i].Value := params[i];
      end;
    end;
    qryFb.ExecSQL();
    conFb.Close;
  end;
end;

class function TDbFirebird.executeQuery(sql: string;
  params: array of variant): TDictionary<string, variant>;
var
  i: byte;
begin
  Result := TDictionary<string, variant>.Create;
  with TDbFirebird do
  begin
    qryFb.Params.Clear;
    qryFb.SQL.Text := sql;
    if (Length(params) > 0) then
    begin
      for i := 0 to Length(params) - 1 do
      begin
        qryFb.Params[i].Value := params[i];
      end;
    end;
    qryFb.Open();
    if (qryFb.RecordCount > 0) then
    begin
      for i := 0 to qryFb.Fields.Count - 1 do
      begin
        // key, value
        Result.Add(qryFb.Fields[i].FieldName, qryFb.Fields[i].Value);
      end;
    end;
    qryFb.Close;
    conFb.Close;
  end;
end;

class function TDbFirebird.executeQueryAll(sql: string;
  params: array of variant): TList<TDicStrVar>;
var
  i: byte;
  dic: TDicStrVar;
begin
  Result := TList<TDicStrVar>.Create; // empty
  with TDbFirebird do
  begin
    qryFb.Params.Clear;
    qryFb.SQL.Text := sql;
    if (Length(params) > 0) then
    begin
      for i := 0 to Length(params) - 1 do
      begin
        qryFb.Params[i].Value := params[i];
      end;
    end;
    qryFb.Open();
    if (qryFb.RecordCount > 0) then
    begin
      while not qryFb.Eof do
      begin
        dic := TDicStrVar.Create();
        for i := 0 to qryFb.Fields.Count - 1 do
        begin
          // key, value
          dic.Add(qryFb.Fields[i].FieldName, qryFb.Fields[i].Value);
        end;
        Result.Add(dic);
        qryFb.Next;
      end;
    end;
    qryFb.Close;
    conFb.Close;
  end;
end;

class function TDbFirebird.executeScalar(sql: string; params: array of variant): variant;
var
  i: byte;
begin
  with TDbFirebird do
  begin
    qryFb.Params.Clear;
    qryFb.SQL.Text := sql;
    if (Length(params) > 0) then
    begin
      for i := 0 to Length(params) - 1 do
      begin
        qryFb.Params[i].Value := params[i];
      end;
    end;
    qryFb.Open();
    Result := qryFb.Fields[0].Value;
    qryFb.Close;
    conFb.Close;
  end;
end;

class function TDbFirebird.isDbConnected: boolean;
begin
  Result := TDbFirebird.conFb <> nil;
end;

begin
  Winapi.Windows.OutputDebugString(PWideChar('.....TDbFbLoaded'));
  TDbFirebird.conFb := TFDConnection.Create(nil);
  TDbFirebird.qryFB := TFDQuery.Create(nil);
  try
    with TDbFirebird.conFb do
    begin
      Params.DriverID := 'FB';
      Params.Database := '.\database.fdb';
      Params.UserName := 'sysdba';
      Params.Password := 'masterkey';
      //Open();
    end;

    with TDbFirebird.qryFB do
    begin
      Connection := TDbFirebird.conFb;
      Open('SELECT * FROM users');
      {
      while not Eof do
      begin
        Winapi.Windows.OutputDebugString(PWideChar(FieldByName('userName').AsString));
        Next;
      end;
      }
      Close();
    end;
    TDbFirebird.conFb.Close();
  except
    TDbFirebird.conFb := nil;
    TDbFirebird.qryFB := nil;
  end;
end.
