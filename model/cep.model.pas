unit cep.model;

interface

uses System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TCep = class

  private
    FCodigo: Integer;
    FCep: string;
    FLogradouro: string;
    FComplemento: string;
    FBairro: string;
    FLocalidade: string;
    FUF: string;
    procedure SetCep(const Value: string);

  public
    procedure Pesquisar(TblCep: TFDQuery; sPesquisa, sCampo: string);
    procedure Carregar(QryCep: TFDQuery; FCep: TCep; iCodigo: Integer);
    function Inserir(QryCep: TFDQuery; FCep: TCep; out sErro: string): Boolean;
    function Alterar(QryCep: TFDQuery; FCep: TCep; iCodigo: Integer; out sErro: string): Boolean;
    function Excluir(QryCep: TFDQuery; iCodigo: Integer; out sErro : string): Boolean;

    property Codigo: Integer read FCodigo write FCodigo;
    property Cep: string read FCep write SetCep;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Localidade: string read FLocalidade write FLocalidade;
    property UF: string read FUF write FUF;

  end;

implementation

{ TCep }

procedure TCep.Pesquisar(TblCep: TFDQuery; sPesquisa, sCampo: string);
begin
  with TblCep do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select cep.codigo, ');
    SQL.Add('cep.cep, ');
    SQL.Add('cep.logradouro, ');
    SQL.Add('cep.complemento, ');
    SQL.Add('cep.bairro, ');
    SQL.Add('cep.localidade, ');
    SQL.Add('cep.uf ');
    SQL.Add('from tab_cep cep');
    SQL.Add('where ' + sCampo + ' like :pNOME');
    SQL.Add('order by ' + sCampo);
    ParamByName('PNOME').AsString := sPesquisa;
    Open();
  end;
end;

procedure TCep.Carregar(QryCep: TFDQuery; FCep: TCep; iCodigo: Integer);
begin
  with QryCep do
  begin
    SQL.Clear;
    SQL.Add('select cep.codigo, ');
    SQL.Add('cep.cep, ');
    SQL.Add('cep.logradouro, ');
    SQL.Add('cep.complemento, ');
    SQL.Add('cep.bairro, ');
    SQL.Add('cep.localidade, ');
    SQL.Add('cep.uf ');
    SQL.Add('from tab_cep cep');
    SQL.Add('where codigo = :codigo');
    ParamByName('codigo').AsInteger := iCodigo;
    Open;

    with FCep, QryCep do
    begin
      Codigo := FieldByName('CODIGO').AsInteger;
      Cep := FieldByName('CEP').AsString;
      Logradouro := FieldByName('DES_DESCRICAO').AsString;
      Complemento := FieldByName('COMPLEMENTO').AsString;
      Bairro := FieldByName('BAIRRO').AsString;
      Localidade := FieldByName('LOCALIDADE').AsString;
      UF := FieldByName('UF').AsString;
    end;
  end;
end;

function TCep.Inserir(QryCep: TFDQuery; FCep: TCep; out sErro: string): Boolean;
begin
  with QryCep, FCep do
  begin
    Close;
    SQL.Clear;
    SQL.Add('insert into tab_cep(');
    SQL.Add('cep, ');
    SQL.Add('logradouro, ');
    SQL.Add('complemento, ');
    SQL.Add('bairro, ');
    SQL.Add('localidade, ');
    SQL.Add('uf) ');
    SQL.Add('values (:cep, ');
    SQL.Add(':logradouro, ');
    SQL.Add(':complemento, ');
    SQL.Add(':bairro, ');
    SQL.Add(':localidade, ');
    SQL.Add(':uf)');

    ParamByName('CEP').AsString := Cep;
    ParamByName('LOGRADOURO').AsString := Logradouro;
    ParamByName('COMPLEMENTO').AsString := Complemento;
    ParamByName('BAIRRO').AsString := Bairro;
    ParamByName('LOCALIDADE').AsString := Localidade;
    ParamByName('UF').AsString := UF;

    try
      Prepared := True;
      ExecSQL;
      Result := True;
    except
      on E: Exception do
      begin
        sErro := 'Ocorreu um erro ao inserir um novo CEP!' + sLineBreak + E.Message;
        raise;
      end;
    end;
  end;
end;

function TCep.Alterar(QryCep: TFDQuery; FCep: TCep; iCodigo: Integer; out sErro: string): Boolean;
begin
  with QryCep, FCep do
  begin
    Close;
    SQL.Clear;
    SQL.Add('update tab_cep set ');
    Sql.Add('cep = :cep, ');
    SQL.Add('logradouro = :logradouro, ');
    SQL.Add('complemento = :complemento, ');
    SQL.Add('bairro = :bairro, ');
    SQL.Add('localidade = :localidade, ');
    SQL.Add('uf = :uf');
    SQL.Add('where codigo = :codigo');

    ParamByName('CEP').AsString := Cep;
    ParamByName('LOGRADOURO').AsString := Logradouro;
    ParamByName('COMPLEMENTO').AsString := Complemento;
    ParamByName('BAIRRO').AsString := Bairro;
    ParamByName('LOCALIDADE').AsString := Localidade;
    ParamByName('UF').AsString := UF;

    try
      Prepared := True;
      ExecSQL();
      Result:= True;
    except on E: Exception do
      begin
        sErro := 'Ocorreu um erro ao alterar as informações do CEP!' + sLineBreak + E.Message;
        raise;
      end;
    end;
  end;
end;

function TCep.Excluir(QryCep: TFDQuery; iCodigo: Integer; out sErro: string): Boolean;
begin
  with QryCep do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'delete from tab_cep where codigo = :codigo';
    ParamByName('CODDIGO').AsInteger := iCodigo;

    try
      Prepared := True;
      ExecSQL();
      Result := True;
    except on E: Exception do
      begin
        sErro := 'Ocorreu um erro ao excluir o produto !' + sLineBreak + E.Message;
        raise;
      end;
    end;
  end;
end;

procedure TCep.SetCep(const Value: string);
begin
  if Value = EmptyStr then
    raise EArgumentException.Create('O campo ''CEP'' precisa ser preenchido!');

  FCep := Value;
end;

end.
