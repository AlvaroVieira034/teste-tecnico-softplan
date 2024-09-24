unit uselecionacep;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, FireDAC.Comp.Client, System.JSON;

type
  TFrmSelecionaCep = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    GridSelecionaEnderecos: TDBGrid;
    BtnSelecionar: TSpeedButton;
    procedure GridSelecionaEnderecosDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BtnSelecionarClick(Sender: TObject);
  private


  public
    QryTemp: TFDQuery;
    QryEnderecos: TFDQuery;
    DsCep: TDataSource;
    procedure CriarTabelaTemporaria(QryTemp: TFDQuery);
    procedure InserirCeps(QryTemp: TFDQuery; JSONArray: TJSONArray);
    procedure CarregarDbGrid(QryTemp: TFDQuery; DSCep: TDataSource);
    procedure ExibirCeps(JSONArray: TJSONArray);
    procedure SelecionarCep;
    procedure CarregarEnderecosDoBanco(AQuery, QryEnderecos: TFDQuery; const ALogradouro, ALocalidade, AUF: string);

  end;

var
  FrmSelecionaCep: TFrmSelecionaCep;

implementation

{$R *.dfm}

uses umain, conexao.model, endereco.model;


procedure TFrmSelecionaCep.FormCreate(Sender: TObject);
begin
  QryTemp := TFDQuery.Create(nil);
  QryTemp := TConexao.GetInstance.Connection.CriarQuery;
  QryEnderecos := TFDQuery.Create(nil);
  QryEnderecos := TConexao.GetInstance.Connection.CriarQuery;
  DsCep := TDataSource.Create(nil);
  DsCep := TConexao.GetInstance.Connection.CriarDataSource;
end;

procedure TFrmSelecionaCep.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FrmSelecionaCep.Free;
end;

procedure TFrmSelecionaCep.ExibirCeps(JSONArray: TJSONArray);
begin
  CriarTabelaTemporaria(QryTemp);
  InserirCeps(QryTemp, JSONArray);
  CarregarDbGrid(QryTemp, DSCep);
end;

procedure TFrmSelecionaCep.CriarTabelaTemporaria(QryTemp: TFDQuery);
begin
  with QryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('IF OBJECT_ID(''tempdb..#TempCEPs'') IS NOT NULL');
    SQL.Add('  DROP TABLE #TempCEPs;');

    SQL.Add('CREATE TABLE #TempCEPs (');
    SQL.Add('Cep VARCHAR(10),');
    SQL.Add('Logradouro VARCHAR(255),');
    SQL.Add('Complemento VARCHAR(255),');
    SQL.Add('Bairro VARCHAR(255),');
    SQL.Add('Localidade VARCHAR(255),');
    SQL.Add('UF VARCHAR(2))');
    ExecSQL;
  end;
end;

procedure TFrmSelecionaCep.InserirCeps(QryTemp: TFDQuery; JSONArray: TJSONArray);
var I: Integer;
    JSONObj: TJSONObject;
begin
  for I := 0 to JSONArray.Count - 1 do
  begin
    JSONObj := JSONArray.Items[I] as TJSONObject;
    QryTemp.Close;
    QryTemp.SQL.Clear;
    QryTemp.SQL.Add('INSERT INTO #TempCEPs (Cep, Logradouro, Complemento, Bairro, Localidade, UF) VALUES (:Cep, :Logradouro, :Complemento, :Bairro, :Localidade, :UF)');

    QryTemp.ParamByName('Cep').AsString := JSONObj.GetValue<string>('cep');
    QryTemp.ParamByName('Logradouro').AsString := JSONObj.GetValue<string>('logradouro');
    QryTemp.ParamByName('Complemento').AsString := JSONObj.GetValue<string>('complemento');
    QryTemp.ParamByName('Bairro').AsString := JSONObj.GetValue<string>('bairro');
    QryTemp.ParamByName('Localidade').AsString := JSONObj.GetValue<string>('localidade');
    QryTemp.ParamByName('UF').AsString := JSONObj.GetValue<string>('uf');

    QryTemp.ExecSQL;
  end;
end;

procedure TFrmSelecionaCep.CarregarDbGrid(QryTemp: TFDQuery; DSCep: TDataSource);
begin
  // Carrega os dados da tabela temporária para o DBGrid
  QryTemp.Close;
  QryTemp.SQL.Clear;
  QryTemp.SQL.Add('SELECT * FROM #TempCEPs');
  QryTemp.Open;

  DSCep.DataSet := QryTemp;
  GridSelecionaEnderecos.DataSource := DSCep;
end;

procedure TFrmSelecionaCep.GridSelecionaEnderecosDblClick(Sender: TObject);
begin
  SelecionarCep();
end;

procedure TFrmSelecionaCep.BtnSelecionarClick(Sender: TObject);
begin
  SelecionarCep();
end;

procedure TFrmSelecionaCep.SelecionarCep;
var FEndereco: TEndereco;
begin
  FEndereco := TEndereco.Create;
  try
    if not QryTemp.IsEmpty then
    begin
      FEndereco.Cep := QryTemp.FieldByName('CEP').AsString;
      FEndereco.Logradouro := QryTemp.FieldByName('LOGRADOURO').AsString;
      FEndereco.Complemento := QryTemp.FieldByName('COMPLEMENTO').AsString;
      FEndereco.Bairro := QryTemp.FieldByName('BAIRRO').AsString;
      FEndereco.Localidade := QryTemp.FieldByName('LOCALIDADE').AsString;
      FEndereco.UF := QryTemp.FieldByName('UF').AsString;
      ModalResult := mrOk;
    end
    else
      ShowMessage('Por favor, selecione um CEP.');
  finally
    FreeAndNil(FEndereco);
  end;
end;

procedure TFrmSelecionaCep.CarregarEnderecosDoBanco(AQuery, QryEnderecos : TFDQuery; const ALogradouro, ALocalidade, AUF: string);
var I: Integer;
begin
  QryEnderecos.SQL := AQuery.SQL;
  QryEnderecos.ParamByName('LOGRADOURO').AsString := '%' + ALogradouro + '%';
  QryEnderecos.ParamByName('LOCALIDADE').AsString := '%' + ALocalidade + '%';
  QryEnderecos.ParamByName('UF').AsString := AUF;
  QryEnderecos.Open;

  CriarTabelaTemporaria(QryTemp);

  for I := 0 to QryEnderecos.RecordCount - 1 do
  begin
    QryTemp.SQL.Clear;
    QryTemp.SQL.Add('INSERT INTO #TempCEPs (Cep, Logradouro, Complemento, Bairro, Localidade, UF) VALUES (:Cep, :Logradouro, :Complemento, :Bairro, :Localidade, :UF)');

    QryTemp.ParamByName('Cep').AsString := QryEnderecos.FieldByName('CEP').AsString;
    QryTemp.ParamByName('Logradouro').AsString := QryEnderecos.FieldByName('LOGRADOURO').AsString;
    QryTemp.ParamByName('Complemento').AsString := QryEnderecos.FieldByName('COMPLEMENTO').AsString;
    QryTemp.ParamByName('Bairro').AsString := QryEnderecos.FieldByName('BAIRRO').AsString;
    QryTemp.ParamByName('Localidade').AsString := QryEnderecos.FieldByName('LOCALIDADE').AsString;
    QryTemp.ParamByName('UF').AsString := QryEnderecos.FieldByName('UF').AsString;

    QryTemp.ExecSQL;
    QryEnderecos.Next;
  end;

  CarregarDbGrid(QryTemp, DSCep);
end;

end.
