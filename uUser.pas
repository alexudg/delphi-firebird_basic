unit uUser;

interface

uses
  System.Variants,
  System.Generics.Collections,
  uDbFirebird;

type
  TUser = class
    private

    public
      id: integer;
      userName: string;
      pass: string;
      age: byte;
      constructor Create(
        id: integer;
        userName: string;
        pass: string;
        age: byte
      );
      function ToString: string; override;

      // statics methods
      class function getId(userName: string; pass: string): integer; static;
      class function get(id: integer): TUser; static;
      class function getAll: TList<TUser>; static;
      class function isExists(userName: string; id: integer): boolean; static;
      class function insert(user: TUser): integer; static;
      class procedure update(user: TUser); static;
      class procedure updatePass(pass: string; id: integer); static;
      class procedure delete(id: integer); static;
  end;

implementation

{ TUser }

constructor TUser.Create(id: integer; userName, pass: string; age: byte);
begin
  self.id := id;
  self.userName := userName;
  self.pass := pass;
  self.age := age;
end;

class procedure TUser.delete(id: integer);
const
  SQL = 'DELETE FROM users WHERE id = :id';
begin
  TDbFirebird.executeNotQuery(SQL, [id]);
end;

class function TUser.get(id: integer): TUser;
var
  sql: string;
  row: TDictionary<string, variant>; // (System.Generics.Collections)
begin
  sql := 'SELECT id, userName, '''' AS pass, age FROM users ' +
         'WHERE id = :id';
  row := TDbFirebird.executeQuery(sql, [id]);

  // FIREBIRD ON UPPERCASE
  Result := TUser.Create(
    row['ID'],
    row['USERNAME'],
    row['PASS'],
    row['AGE']
  );
end;

class function TUser.getAll: TList<TUser>;
var
  sql: string;
  rows: TList<TDictionary<string, variant>>;
  row: TDictionary<string, variant>;
  user: TUser;
begin
  Result := TList<TUser>.Create; // empty
  sql := 'SELECT id, userName, '''' AS pass, age FROM users ' +
         'ORDER BY userName';
  rows := TDbFirebird.executeQueryAll(sql, []);
  for row in rows do
  begin
    user := TUser.Create(
      row['ID'],
      row['USERNAME'],
      row['PASS'],
      row['AGE']
    );
    Result.Add(user);
  end;
end;

class function TUser.getId(userName, pass: string): integer;
var
  sql: string;
  val: variant;
begin
  sql := 'SELECT id FROM users WHERE userName = :userName AND pass = :pass';
  val := TDbFirebird.executeScalar(sql, [userName, pass]);

  // (System.Variants)
  if (val = Null) then
    val := -1;

  Result := val;
end;

class function TUser.insert(user: TUser): integer;
var
  sql: string;
begin
  sql := 'INSERT INTO users (userName, pass, age) ' +
         'VALUES (:userName, :pass, :age) ' +
         'RETURNING id';
  Result := TDbFirebird.executeScalar(sql, [
    user.userName,
    user.pass,
    user.age
  ]);
end;

class function TUser.isExists(userName: string; id: integer): boolean;
var
  sql: string;
begin
  sql := 'SELECT EXISTS(SELECT 1 FROM users WHERE userName = :userName AND id <> :id) ' +
         'FROM RDB$DATABASE';
  Result := TDbFirebird.executeScalar(sql, [userName, id]);
end;

function TUser.ToString: string;
begin
  Result := 'Hello world';
end;

class procedure TUser.update(user: TUser);
var
  sql: string;
begin
  sql := 'UPDATE users SET ' +
           'userName = :userName,' +
           'age = :age ' +
         'WHERE id = :id';
  TDbFirebird.executeNotQuery(sql, [
    user.userName,
    user.age,
    user.id
  ]);
  if (user.pass > '') then
    updatePass(user.pass, user.id);
end;

class procedure TUser.updatePass(pass: string; id: integer);
var
  sql: string;
begin
  sql := 'UPDATE users SET ' +
           'pass = :pass ' +
         'WHERE id = :id';
  TDbFirebird.executeNotQuery(sql, [pass, id]);
end;

end.
