unit enderecorepository.model;

interface

uses endereco.model, conexao.model, System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TEnderecoRepository = class
  public
    procedure PreencheGrid(TblCep: TFDQuery; sPesquisa, sCampo: string);
    procedure CarregarCampos(QryCep: TFDQuery; FEndereco: TEndereco; iCodigo: Integer);
    function Inserir(QryCep: TFDQuery; FEndereco: TEndereco; out sErro: string): Boolean;
    function Alterar(QryCep: TFDQuery; FEndereco: TEndereco; iCodigo: Integer; out sErro: string): Boolean;
    function Excluir(QryCep: TFDQuery; iCodigo: Integer; out sErro : string): Boolean;

    function GetEnderecoCEP(Cep: string): TEndereco;
    function GetEnderecoDados(Logradouro, Cidade, Estado: string): TEndereco;

  end;

implementation

{ TEnderecoRepository }

procedure TEnderecoRepository.PreencheGrid(TblCep: TFDQuery; sPesquisa, sCampo: string);
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

procedure TEnderecoRepository.CarregarCampos(QryCep: TFDQuery; FEndereco: TEndereco; iCodigo: Integer);
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

    with FEndereco, QryCep do
    begin
      Cep := FieldByName('CEP').AsString;
      Logradouro := FieldByName('LOGRADOURO').AsString;
      Complemento := FieldByName('COMPLEMENTO').AsString;
      Bairro := FieldByName('BAIRRO').AsString;
      Localidade := FieldByName('LOCALIDADE').AsString;
      UF := FieldByName('UF').AsString;
    end;
  end;
end;

function TEnderecoRepository.Inserir(QryCep: TFDQuery; FEndereco: TEndereco; out sErro: string): Boolean;
begin
  with QryCep, FEndereco do
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

function TEnderecoRepository.Alterar(QryCep: TFDQuery; FEndereco: TEndereco; iCodigo: Integer; out sErro: string): Boolean;
begin
  with QryCep, FEndereco do
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
    ParamByName('CODIGO').AsInteger := iCodigo;

    try
      Prepared := True;
      ExecSQL();
      Result:= True;
    except on E: Exception do
      begin
        sErro := 'Ocorreu um erro ao alterar as informa��es do CEP!' + sLineBreak + E.Message;
        raise;
      end;
    end;
  end;
end;

function TEnderecoRepository.Excluir(QryCep: TFDQuery; iCodigo: Integer; out sErro: string): Boolean;
begin
  with QryCep do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'delete from tab_cep where codigo = :codigo';
    ParamByName('CODIGO').AsInteger := iCodigo;

    try
      Prepared := True;
      ExecSQL();
      Result := True;
    except on E: Exception do
      begin
        sErro := 'Ocorreu um erro ao excluir o CEP !' + sLineBreak + E.Message;
        raise;
      end;
    end;
  end;
end;

function TEnderecoRepository.GetEnderecoCEP(Cep: string): TEndereco;
begin
//
end;

function TEnderecoRepository.GetEnderecoDados(Logradouro, Cidade, Estado: string): TEndereco;
begin
//
end;

end.
