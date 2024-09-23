unit endereco.model;

interface

uses System.SysUtils, System.JSON, System.Variants, XMLDoc, XMLIntF, FireDAC.Comp.Client, FireDAC.Stan.Param,
     conexao.model, uselecionacep, Data.DB;

type
  TEndereco = class

  private
    QryTemp: TFDQuery;
    DsCep: TDataSource;
    FCodigo: Integer;
    FCep: string;
    FLogradouro: string;
    FComplemento: string;
    FBairro: string;
    FLocalidade: string;
    FUF: string;

  public
    constructor Create();
    destructor Destroy; override;
    procedure CarregarJSON(const JSONString: string);
    procedure CarregarXML(const AXMLString: string);
    function CEPExistente(QryTemp: TFDQuery; CEP: string): Boolean;
    function EnderecoExistente(var AQuery: TFDQuery; const ALogradouro, ALocalidade, AUF: string): Boolean;
    function GetXMLValueOrDefault(Node: IXMLNode; const TagName: string; const DefaultValue: string = ''): string;

    property Codigo: Integer read FCodigo write FCodigo;
    property Cep: string read FCep write FCep;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Localidade: string read FLocalidade write FLocalidade;
    property UF: string read FUF write FUF;

  end;

implementation

uses Vcl.Dialogs, System.UITypes;

{ TEndereco }

constructor TEndereco.Create;
begin
  QryTemp := TFDQuery.Create(nil);
  QryTemp := TConexao.GetInstance.Connection.CriarQuery;
  DsCep := TDataSource.Create(nil);
  DsCep := TConexao.GetInstance.Connection.CriarDataSource;
end;

destructor TEndereco.Destroy;
begin
  QryTemp.Free;
  inherited;
end;

procedure TEndereco.CarregarJSON(const JSONString: string);
var
  JSONValue: TJSONValue;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
begin
  JSONValue := TJSONObject.ParseJSONValue(JSONString);
  if Assigned(JSONValue) then
  begin
    if JSONValue is TJSONArray then
    begin
      JSONArray := JSONValue as TJSONArray;
      if JSONArray.Count > 0 then
      begin
        JSONObj := JSONArray.Items[0] as TJSONObject;
      end
      else
        raise Exception.Create('Erro: O array JSON est� vazio.');
    end
    else
    if JSONValue is TJSONObject then
    begin
      JSONObj := JSONValue as TJSONObject;
    end
    else
      raise Exception.Create('Erro: O JSON n�o � um objeto ou array v�lido.');

    try
      Cep := JSONObj.GetValue<string>('cep');
      Logradouro := JSONObj.GetValue<string>('logradouro');
      Complemento := JSONObj.GetValue<string>('complemento');
      Bairro := JSONObj.GetValue<string>('bairro');
      Localidade := JSONObj.GetValue<string>('localidade');
      UF := JSONObj.GetValue<string>('uf');
    finally
      JSONObj.Free;
    end;
  end
  else
    raise Exception.Create('Erro: O objeto retornado n�o � um JSON v�lido');
end;

procedure TEndereco.CarregarXML(const AXMLString: string);
var XMLDoc: IXMLDocument;
    RootNode: IXMLNode;
begin
  XMLDoc := LoadXMLData(AXMLString);
  RootNode := XMLDoc.DocumentElement;
  if Assigned(RootNode) then
  begin
    Cep := GetXMLValueOrDefault(RootNode, 'cep');
    Logradouro := GetXMLValueOrDefault(RootNode, 'logradouro');
    Complemento := GetXMLValueOrDefault(RootNode, 'complemento');
    Bairro := GetXMLValueOrDefault(RootNode, 'bairro');
    Localidade := GetXMLValueOrDefault(RootNode, 'localidade');
    UF := GetXMLValueOrDefault(RootNode, 'uf');
  end
  else
    raise Exception.Create('Erro ao carregar o XML');
end;

function TEndereco.CEPExistente(QryTemp: TFDQuery; CEP: string): Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    SQL.Clear;
    SQL.Add('select * from tab_cep where cep = :cep');
    ParamByName('CEP').AsString := CEP;
    Open();
    if not Eof then
      Result := True;
  end;
end;

function TEndereco.EnderecoExistente(var AQuery: TFDQuery; const ALogradouro, ALocalidade, AUF: string): Boolean;
begin
  AQuery.SQL.Text := 'select * from tab_cep where logradouro like :logradouro and localidade like :localidade and uf = :uf';
  AQuery.ParamByName('LOGRADOURO').AsString := '%' + ALogradouro + '%';
  AQuery.ParamByName('LOCALIDADE').AsString := '%' + ALocalidade + '%';
  AQuery.ParamByName('UF').AsString := AUF;
  AQuery.Open;
  Result := not AQuery.IsEmpty;
end;

function TEndereco.GetXMLValueOrDefault(Node: IXMLNode; const TagName, DefaultValue: string): string;
begin
  if not VarIsNull(Node.ChildValues[TagName]) then
    Result := Node.ChildValues[TagName]
  else
    Result := DefaultValue;
end;

end.
