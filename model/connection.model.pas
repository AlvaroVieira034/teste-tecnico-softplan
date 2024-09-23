unit connection.model;

interface

{$REGION 'Uses'}
uses FireDAC.Stan.Intf, FireDAC.Stan.Option,  FireDAC.Stan.Error, FireDAC.UI.Intf,
     FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
     FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, System.SysUtils,
     FireDAC.Phys.MSSQL, System.IniFiles, System.IOUtils;

{$ENDREGION}

type
  TConnection = class
    private
      FConexao: TFDConnection;
      procedure LerConfiguracaoINI;

    public
      constructor Create;
      destructor Destroy; override;
      function GetConexao: TFDConnection;
      function CriarQuery: TFDQuery;
      function CriarDataSource: TDataSource;

  end;

implementation

{ TConnection }

constructor TConnection.Create;
var FDPhysMSSQL: TFDPhysMSSQLDriverLink;
begin
  inherited Create;
  FDPhysMSSQL := TFDPhysMSSQLDriverLink.Create(nil);
  FConexao := TFDConnection.Create(nil);
  LerConfiguracaoINI();
end;


destructor TConnection.Destroy;
begin
  FreeAndNil(FConexao);
  inherited;

end;

procedure TConnection.LerConfiguracaoINI;
var Ini: TIniFile;
    IniFileName: string;
begin
  // Caminho do arquivo INI
  IniFileName := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'consultaCEP.ini');

  // Verifica se o arquivo INI existe
  if not FileExists(IniFileName) then
    raise Exception.Create('Arquivo consultaCEP.ini não encontrado!');

  // Carregar o arquivo INI
  Ini := TIniFile.Create(IniFileName);
  try
    FConexao.Params.DriverID := Ini.ReadString('Database', 'DriverID', 'MSSQL');
    FConexao.Params.Database := Ini.ReadString('Database', 'Database', 'BDTESTE');
    FConexao.Params.UserName := Ini.ReadString('Database', 'UserName', 'sa');
    FConexao.Params.Password := Ini.ReadString('Database', 'Password', 'info');
    FConexao.Params.Add('Server=' + Ini.ReadString('DatabaseConfig', 'ADDRESS', ''));
    FConexao.LoginPrompt := False;
  finally
    Ini.Free;
  end;

end;

function TConnection.GetConexao: TFDConnection;
begin
  Result := FConexao;
end;

function TConnection.CriarQuery: TFDQuery;
var Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  Query.Connection := FConexao;

  Result := Query;
end;

function TConnection.CriarDataSource: TDataSource;
var DataSource: TDataSource;
begin
  DataSource := TDataSource.Create(nil);

  Result := DataSource;
end;


end.
