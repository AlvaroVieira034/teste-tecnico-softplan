unit umain;

interface

{$REGION 'Uses'}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.Buttons, Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, endereco.model,
  cepservice.model, enderecorepository.model, conexao.model, uselecionacep;

{$ENDREGION}

type
  TOperacao = (opInicio, opNovo, opEditar, opNavegar);
  TFrmMain = class(TForm)

{$REGION 'Componentes'}
    PnlTopo: TPanel;
    BtnInserir: TSpeedButton;
    BtnAlterar: TSpeedButton;
    BtnExcluir: TSpeedButton;
    BtnGravar: TSpeedButton;
    BtnCancelar: TSpeedButton;
    BtnSair: TSpeedButton;
    PnlGrid: TPanel;
    GrbGrid: TGroupBox;
    PnlDados: TPanel;
    GrbDados: TGroupBox;
    GridEnderecos: TDBGrid;
    PnlPesquisar: TPanel;
    BtnPesquisar: TSpeedButton;
    Label3: TLabel;
    EdtCep: TEdit;
    Label2: TLabel;
    EdtLogradouro: TEdit;
    Label4: TLabel;
    EdtComplemento: TEdit;
    Label5: TLabel;
    EdtBairro: TEdit;
    Label6: TLabel;
    EdtLocalidade: TEdit;
    Label7: TLabel;
    EdtUF: TEdit;
    RdgOpcoes: TRadioGroup;
    RdgRetorno: TRadioGroup;
    BtnLimpar: TSpeedButton;
    LblTotRegistros: TLabel;
    EdtPesqLogradouro: TEdit;
    EdtPesqCidade: TEdit;
    Label1: TLabel;
    EdtPesqUF: TEdit;
    LblLocalidade: TLabel;
    LblUF: TLabel;
    EdtPesqCep: TEdit;

{$ENDREGION}

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RdgOpcoesClick(Sender: TObject);
    procedure BtnPesquisarClick(Sender: TObject);
    procedure BtnLimparClick(Sender: TObject);
    procedure GridEnderecosDblClick(Sender: TObject);
    procedure BtnInserirClick(Sender: TObject);
    procedure BtnAlterarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnGravarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdtPesqCepKeyPress(Sender: TObject; var Key: Char);
    procedure EdtPesqCepChange(Sender: TObject);

  private
    ValoresOriginais: array of string;
    DsCep: TDataSource;
    TblCep: TFDQuery;
    QryCep, QryTemp, QryEnderecos: TFDQuery;

    procedure PreencheGrid;
    procedure CarregarCampos;
    procedure GravarDados;
    function ValidarDados(AValidar: string): Boolean;
    procedure LimpaCampos;
    procedure VerificaBotoes(FOperacao: TOperacao);
    procedure FormataCep;
    procedure SelecionarCep;

  public
    FOperacao: TOperacao;
    sCampo: string;
    IsCepSelected: Boolean;
    codigoCep: Integer;
    pesquisaCep: Boolean;
    FEndereco: TEndereco;
    FEnderecoRepo: TEnderecoRepository;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FrmMain: TFrmMain;

implementation

uses System.JSON;

{$R *.dfm}

constructor TFrmMain.Create(AOwner: TComponent);
begin
  inherited;
  DsCep := TDataSource.Create(nil);
  TblCep := TFDQuery.Create(nil);
  QryCep := TFDQuery.Create(nil);
  QryTemp := TFDQuery.Create(nil);
  QryEnderecos := TFDQuery.Create(nil);
end;

destructor TFrmMain.Destroy;
begin
  DsCep.Free;
  TblCep.Free;
  QryCep.Free;
  QryTemp.Free;
  inherited;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  TblCep := TConexao.GetInstance.Connection.CriarQuery;
  QryCep := TConexao.GetInstance.Connection.CriarQuery;
  QryTemp := TConexao.GetInstance.Connection.CriarQuery;
  QryEnderecos := TConexao.GetInstance.Connection.CriarQuery;
  DsCep := TConexao.GetInstance.Connection.CriarDataSource;
  DsCep := TDataSource.Create(nil);
  DsCep.DataSet := TblCep;
  GridEnderecos.DataSource := DsCep;
  sCampo := 'cep';
  IsCepSelected := RdgOpcoes.ItemIndex = 0;
  FEndereco := TEndereco.Create;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  EdtPesqCep.Visible := True;
  EdtPesqLogradouro.Visible := False;
  EdtPesqCep.BringToFront;
  EdtPesqLogradouro.SendToBack;
  PreencheGrid();
  FOperacao := opInicio;
  VerificaBotoes(FOperacao);
  if EdtPesqCep.CanFocus then
    EdtPesqCep.SetFocus;
end;

procedure TFrmMain.PreencheGrid;
begin
  FEnderecoRepo := TEnderecoRepository.Create;
  try
    FEnderecoRepo.PreencheGrid(TblCep, Trim(EdtPesqCep.Text) + '%', sCampo);
    LblTotRegistros.Caption := 'Registros: ' + InttoStr(DsCep.DataSet.RecordCount);
  finally
    FEnderecoRepo.Free;
  end;
end;

procedure TFrmMain.CarregarCampos;
begin
  FEndereco := TEndereco.Create;
  FEnderecoRepo := TEnderecoRepository.Create;
  try
    FEnderecoRepo.CarregarCampos(QryCep, FEndereco, DsCep.DataSet.FieldByName('CODIGO').AsInteger);
    with FEndereco do
    begin
      EdtCep.Text := Cep;
      EdtLogradouro.Text := Logradouro;
      EdtComplemento.Text := Complemento;
      EdtBairro.Text := Bairro;
      EdtLocalidade.Text := Localidade;
      EdtUF.Text := UF;
    end;
  finally
    FreeAndNil(FEnderecoRepo);
  end;

end;

procedure TFrmMain.GravarDados;
var sErro: string;
begin
  FEndereco := TEndereco.Create;
  FEnderecoRepo := TEnderecoRepository.Create;
  try
    with FEndereco do
    begin
      Cep := Trim(EdtCep.Text);
      Logradouro := Trim(EdtLogradouro.Text);
      Complemento := Trim(EdtComplemento.Text);
      Bairro := Trim(EdtBairro.Text);
      Localidade := Trim(EdtLocalidade.Text);
      UF := Trim(EdtUF.Text);

      if FOperacao = opNovo then
      begin
        if FEnderecoRepo.Inserir(QryCep, FEndereco, sErro) = False then
          raise Exception.Create(sErro)
        else
        begin
          MessageDlg('Registro inclu�do com sucesso!', mtInformation, [mbOk], 0);
          FOperacao := opNavegar
        end;
      end;

      if FOperacao = opEditar then
      begin
        if FEnderecoRepo.Alterar(QryCep, FEndereco, DsCep.DataSet.FieldByName('CODIGO').AsInteger, sErro) = False then
          raise Exception.Create(sErro)
        else
        begin
          MessageDlg('Registro alterado com sucesso!', mtInformation, [mbOk], 0);
          FOperacao := opInicio
        end;
      end;
    end;
  finally
    FreeAndNil(FEndereco);
    FreeAndNil(FEnderecoRepo);
  end;
end;

function TFrmMain.ValidarDados(AValidar: string): Boolean;
begin
  Result := False;
  if AValidar = 'CEP' then
  begin
    if EdtPesqCep.Text = EmptyStr then
    begin
      MessageDlg('O CEP a pesquisar deve ser preenchido!', mtInformation, [mbOK], 0);
      Exit;
    end;
  end;

  if AValidar = 'CAMPOS' then
  begin
    if EdtCep.Text = EmptyStr then
    begin
      MessageDlg('O CEP do logradouro deve ser preenchido!', mtInformation, [mbOK], 0);
      EdtCep.SetFocus;
      Exit;
    end;

    if EdtLogradouro.Text = EmptyStr then
    begin
      MessageDlg('O campo Logradouro deve ser preenchido!', mtInformation, [mbOK], 0);
      EdtLogradouro.SetFocus;
      Exit;
    end;

    if EdtBairro.Text = EmptyStr then
    begin
      MessageDlg('O campo Bairro deve ser preenchido!', mtInformation, [mbOK], 0);
      EdtBairro.SetFocus;
      Exit;
    end;

    if EdtLocalidade.Text = EmptyStr then
    begin
      MessageDlg('O campo Localidade deve ser preenchido!', mtInformation, [mbOK], 0);
      EdtLocalidade.SetFocus;
      Exit;
    end;

    if EdtUF.Text = EmptyStr then
    begin
      MessageDlg('O campo UF deve ser preenchido!', mtInformation, [mbOK], 0);
      EdtUF.SetFocus;
      Exit;
    end;
  end;
  Result := True;
end;

procedure TFrmMain.LimpaCampos;
begin
  EdtPesqCep.Text := EmptyStr;
  EdtCep.Text := EmptyStr;
  EdtLogradouro.Text := EmptyStr;
  EdtComplemento.Text := EmptyStr;
  EdtBairro.Text := EmptyStr;
  EdtLocalidade.Text := EmptyStr;
  EdtUF.Text := EmptyStr;

  EdtPesqLogradouro.Text := EmptyStr;
  EdtPesqCidade.Text := EmptyStr;
  EdtPesqUF.Text := EmptyStr;
end;

procedure TFrmMain.VerificaBotoes(FOperacao: TOperacao);
begin
  if FOperacao = opInicio then
  begin
    BtnInserir.Enabled := False;
    BtnAlterar.Enabled := False;
    BtnExcluir.Enabled := False;
    BtnGravar.Enabled := False;
    BtnCancelar.Enabled := False;
    BtnSair.Enabled := True;
    BtnLimpar.Enabled := False;
    GrbDados.Enabled := False;
    GrbGrid.Enabled := True;
    GridEnderecos.Enabled := True;
    PnlPesquisar.Enabled := True;
  end;

  if FOperacao = opNovo then
  begin
    BtnInserir.Enabled := True;
    BtnAlterar.Enabled := False;
    BtnExcluir.Enabled := False;
    BtnGravar.Enabled := False;
    BtnCancelar.Enabled := True;
    BtnSair.Enabled := False;
    GridEnderecos.Enabled := False;
    GrbGrid.Enabled := False;
    GrbDados.Enabled := True;
    PnlPesquisar.Enabled := False;
    //EdtPesqCep.SetFocus;
  end;

  if FOperacao = opEditar then
  begin
    BtnInserir.Enabled := False;
    BtnAlterar.Enabled := False;
    BtnExcluir.Enabled := False;
    BtnGravar.Enabled := True;
    BtnCancelar.Enabled := True;
    BtnSair.Enabled := False;
    BtnLimpar.Enabled := True;
    GridEnderecos.Enabled := False;
    GrbGrid.Enabled := False;
    GrbDados.Enabled := True;
    PnlPesquisar.Enabled := False;
    EdtCep.SetFocus;
  end;

  if FOperacao = opNavegar then
  begin
    BtnInserir.Enabled := False;
    BtnAlterar.Enabled := True;
    BtnExcluir.Enabled := True;
    BtnGravar.Enabled := False;
    BtnCancelar.Enabled := False;
    BtnSair.Enabled := True;
    BtnLimpar.Enabled := False;
    GridEnderecos.Enabled := True;
    GrbGrid.Enabled := True;
    GrbDados.Enabled := False;
    PnlPesquisar.Enabled := True;
    GridEnderecos.Refresh;
  end;
end;

procedure TFrmMain.GridEnderecosDblClick(Sender: TObject);
begin
  GrbDados.Enabled := True;
  GrbGrid.Enabled := False;
  CarregarCampos();
  VerificaBotoes(opNavegar);
end;

procedure TFrmMain.RdgOpcoesClick(Sender: TObject);
begin
  IsCepSelected := RdgOpcoes.ItemIndex = 0;
  EdtPesqCep.Visible := IsCepSelected;
  EdtPesqLogradouro.Visible := not IsCepSelected;
  LblLocalidade.Visible := not IsCepSelected;
  EdtPesqCidade.Visible := not IsCepSelected;
  LblUF.Visible := not IsCepSelected;
  EdtPesqUF.Visible := not IsCepSelected;

  if RdgOpcoes.ItemIndex = 0 then
  begin
    EdtPesqCep.BringToFront;
    EdtPesqLogradouro.SendToBack;
    Label1.Caption := 'CEP';
    sCampo := 'cep';
    if EdtPesqCep.CanFocus then
      EdtPesqCep.SetFocus;
  end;

  if RdgOpcoes.ItemIndex = 1 then
  begin
    EdtPesqCep.SendToBack;
    EdtPesqLogradouro.BringToFront;
    Label1.Caption := 'Logradouro';
    sCampo := 'logradouro';
    if EdtPesqLogradouro.CanFocus then
      EdtPesqLogradouro.SetFocus;
  end;
end;



procedure TFrmMain.BtnAlterarClick(Sender: TObject);
begin
  FOperacao := opEditar;
  VerificaBotoes(FOperacao);
  EdtCep.SetFocus;
end;

procedure TFrmMain.BtnCancelarClick(Sender: TObject);
begin
  if FOperacao = opNovo then
  begin
    LimpaCampos;
    FOperacao := opInicio;
  end;

  if FOperacao = opEditar then
  begin
    FOperacao := opNavegar;
  end;

  VerificaBotoes(FOperacao);
end;

procedure TFrmMain.BtnExcluirClick(Sender: TObject);
var FEnderecoRepo: TEnderecoRepository;
    sErro : string;
begin
  FEnderecoRepo := TEnderecoRepository.Create;
  try
    if MessageDlg('Deseja realmente excluir o CEP selecionado?',mtConfirmation, [mbYes, mbNo],0) = mrYes then
       if FEnderecoRepo.Excluir(QryCep, DsCep.DataSet.FieldByName('CODIGO').AsInteger, sErro) = False then
          raise Exception.Create(sErro);
  finally
    FreeAndNil(FEnderecoRepo);
  end;
  begin
    LimpaCampos();
    FOperacao := opInicio;
    VerificaBotoes(FOperacao);
    PreencheGrid();
  end;
end;

procedure TFrmMain.BtnGravarClick(Sender: TObject);
begin
  if not ValidarDados('CAMPOS') then
  begin
    Exit;
  end
  else
  begin
    GravarDados();
    LimpaCampos();
    PreencheGrid();
    VerificaBotoes(FOperacao);
  end;
end;

procedure TFrmMain.BtnInserirClick(Sender: TObject);
begin
  if not ValidarDados('CAMPOS') then
  begin
    Exit;
  end
  else
  begin
    GravarDados();
    LimpaCampos();
    FOperacao := opInicio;
    VerificaBotoes(FOperacao);
    PreencheGrid();
  end;
end;

procedure TFrmMain.BtnPesquisarClick(Sender: TObject);
var FEndereco: TEndereco;
    FCepService: TCEPService;
    LResultado, LCep, LLogradouro, LCidade, LEstado: string;
    LFormatoJSON, encerrarConsulta: Boolean;
    JSONArray: TJSONArray;
    frmSelecionaCep: TFrmSelecionaCep;
begin
  encerrarConsulta := False;
  FCepService := TCEPService.Create;
  FEndereco := TEndereco.Create;
  try
    LFormatoJSON := RdgRetorno.ItemIndex = 0;
    if RdgOpcoes.ItemIndex = 0 then  // Pesquisa por Cep
    begin
      FOperacao := OpNovo;
      LCep := EdtPesqCep.Text;
      if not ValidarDados('CEP') then
      begin
         EdtPesqCep.SetFocus;
         Exit;
      end;

      if FEndereco.CEPExistente(QryTemp, EdtPesqCep.Text) then
      begin
        if MessageDlg(Format('Foi encontrado um endere�o para o CEP %s na base de dados.' + #13 + 'Deseja atualizar as informa��es?', [LCEP]), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        begin
          EdtCep.Text := DsCep.DataSet.FieldByName('CEP').AsString;
          EdtLogradouro.Text := DsCep.DataSet.FieldByName('LOGRADOURO').AsString;
          EdtComplemento.Text := DsCep.DataSet.FieldByName('COMPLEMENTO').AsString;
          EdtBairro.Text := DsCep.DataSet.FieldByName('BAIRRO').AsString;
          EdtLocalidade.Text := DsCep.DataSet.FieldByName('LOCALIDADE').AsString;
          EdtUF.Text := DsCep.DataSet.FieldByName('UF').AsString;
          FOperacao := opNavegar;
          VerificaBotoes(FOperacao);
          Exit;
        end
      end;

      LResultado := FCepService.ConsultaCep(LCep, LFormatoJSON);
      if LResultado = '' then
      begin
        MessageDlg('Nenhum dado encontrado para o cep informado!', mtInformation, [mbOK], 0);
        Exit;
      end;

      if LFormatoJSON then
        FEndereco.CarregarJSON(LResultado)
      else
        FEndereco.CarregarXML(LResultado);

      with FEndereco do
      begin
        EdtCep.Text := Cep;
        EdtLogradouro.Text := Logradouro;
        EdtComplemento.Text := Complemento;
        EdtBairro.Text := Bairro;
        EdtLocalidade.Text := Localidade;
        EdtUF.Text := UF;
      end;
      VerificaBotoes(FOperacao);
    end;

    if RdgOpcoes.ItemIndex = 1 then // Pesquisa por Endere�o
    begin
      LLogradouro := EdtPesqLogradouro.Text;
      LCidade := EdtPesqCidade.Text;
      LEstado := EdtPesqUF.Text;
      if (Length(LLogradouro) < 3) or (Length(LCidade) < 3) or (Length(LEstado) < 2) then
      begin
        MessageDlg('Preencha todos os campos corretamente!', mtWarning, [mbOK], 0);
        Exit;
      end;

      // Busca os endere�os na base
      if FEndereco.EnderecoExistente(QryTemp, LLogradouro, LCidade, LEstado) then
      begin
        if MessageDlg('Foram encontrados na base de dados, mais de um registro para o endere�o informado. Deseja visualiza-los?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          // Abre o formul�rio de sele��o de CEPs, mas agora com os endere�os do banco
          FrmSelecionaCep := TFrmSelecionaCep.Create(nil);
          try
            FrmSelecionaCep.CarregarEnderecosDoBanco(QryTemp, QryEnderecos, LLogradouro, LCidade, LEstado); // M�todo que carrega os dados da Query no Grid
            if FrmSelecionaCep.ShowModal = mrOk then
            begin
              FEndereco.Cep := frmSelecionaCep.QryTemp.FieldByName('CEP').AsString;
              FEndereco.Logradouro := frmSelecionaCep.QryTemp.FieldByName('LOGRADOURO').AsString;
              FEndereco.Complemento := frmSelecionaCep.QryTemp.FieldByName('COMPLEMENTO').AsString;
              FEndereco.Bairro := frmSelecionaCep.QryTemp.FieldByName('BAIRRO').AsString;
              FEndereco.Localidade := frmSelecionaCep.QryTemp.FieldByName('LOCALIDADE').AsString;
              FEndereco.UF := frmSelecionaCep.QryTemp.FieldByName('UF').AsString;
              with FEndereco do
              begin
                EdtCep.Text := Cep;
                EdtLogradouro.Text := Logradouro;
                EdtComplemento.Text := Complemento;
                EdtBairro.Text := Bairro;
                EdtLocalidade.Text := Localidade;
                EdtUF.Text := UF;
              end;
              FOperacao := opNavegar;
              VerificaBotoes(FOperacao);
            end;
          finally
            encerrarConsulta := True;
            FrmSelecionaCep.Free;
          end;
        end
        else
          Exit;
      end;

      if encerrarConsulta then
        Exit;

      try
        LResultado := FCepService.ConsultaEndereco(LLogradouro, LCidade, LEstado, LFormatoJSON);
        if LResultado = '' then
        begin
          MessageDlg('Nenhum dado encontrado para o endere�o informado!', mtInformation, [mbOK], 0);
          Exit;
        end;

        if LFormatoJSON then
        begin
          FEndereco.CarregarJSON(LResultado);
          JSONArray := TJSONObject.ParseJSONValue(LResultado) as TJSONArray;
          if Assigned(JSONArray) and (JSONArray.Count > 1) then
          begin
            if MessageDlg('Foram encontrados mais de um CEP para o endere�o informado. Deseja visualiza-los?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
            begin
              // Exibe o form para selecionar a pesquisa do CEP
              frmSelecionaCep := TfrmSelecionaCep.Create(nil);
              try
                frmSelecionaCep.ExibirCeps(JSONArray);
                if frmSelecionaCep.ShowModal = mrOk then
                begin
                  FEndereco.Cep := frmSelecionaCep.QryTemp.FieldByName('CEP').AsString;
                  FEndereco.Logradouro := frmSelecionaCep.QryTemp.FieldByName('LOGRADOURO').AsString;
                  FEndereco.Complemento := frmSelecionaCep.QryTemp.FieldByName('COMPLEMENTO').AsString;
                  FEndereco.Bairro := frmSelecionaCep.QryTemp.FieldByName('BAIRRO').AsString;
                  FEndereco.Localidade := frmSelecionaCep.QryTemp.FieldByName('LOCALIDADE').AsString;
                  FEndereco.UF := frmSelecionaCep.QryTemp.FieldByName('UF').AsString;
                end;
              finally
                frmSelecionaCep.Free;
              end;
            end
            else
            begin
              LimpaCampos();
              EdtPesqLogradouro.SetFocus;
              Exit;
            end;
          end;
        end
        else
          FEndereco.CarregarXML(LResultado);

        with FEndereco do
        begin
          EdtCep.Text := Cep;
          EdtLogradouro.Text := Logradouro;
          EdtComplemento.Text := Complemento;
          EdtBairro.Text := Bairro;
          EdtLocalidade.Text := Localidade;
          EdtUF.Text := UF;
        end;
        FOperacao := OpNovo;
        VerificaBotoes(FOperacao);
      except on E: Exception do
        ShowMessage('Erro ao consulta o endere�o: ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(FEndereco);
    FreeAndNil(FCepService);
  end;
end;

procedure TFrmMain.BtnLimparClick(Sender: TObject);
begin
  EdtPesqCep.Text := EmptyStr;
  EdtCep.Text := EmptyStr;
  EdtLogradouro.Text := EmptyStr;
  EdtComplemento.Text := EmptyStr;
  EdtBairro.Text := EmptyStr;
  EdtLocalidade.Text := EmptyStr;
  EdtUF.Text := EmptyStr;
  if EdtPesqCep.CanFocus then
    EdtPesqCep.SetFocus;
end;

procedure TFrmMain.FormataCep;
var
  OriginalText: string;
begin
  OriginalText := EdtPesqCep.Text;
  OriginalText := StringReplace(OriginalText, '-', '', [rfReplaceAll]);

  if Length(OriginalText) = 8 then
  begin
    EdtPesqCep.Text := Copy(OriginalText, 1, 5) + '-' + Copy(OriginalText, 6, 3);
    EdtPesqCep.SelStart := Length(EdtPesqCep.Text); // Move o cursor para o final
  end;
end;

procedure TFrmMain.SelecionarCep;
begin
  FrmSelecionaCep := TFrmSelecionaCep.Create(Self);
  try
    if FrmSelecionaCep.ShowModal = mrOk then
    begin
      EdtCep.Text := FEndereco.Cep;
      EdtLogradouro.Text := FEndereco.Logradouro;
      EdtBairro.Text := FEndereco.Bairro;
      EdtLocalidade.Text := FEndereco.Localidade;
      EdtUF.Text := FEndereco.UF;
    end;
  finally
    FrmSelecionaCep.Free;

  end;
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    perform(WM_NEXTDLGCTL,0,0)
end;

procedure TFrmMain.EdtPesqCepChange(Sender: TObject);
begin
  FormataCep();
end;

procedure TFrmMain.EdtPesqCepKeyPress(Sender: TObject; var Key: Char);
var CurrentText: string;
begin
  if not (CharInSet(Key, ['0'..'9', '-', #8])) then
  begin
    Key := #0;
    Exit;
  end;

  if (Key = '-') and (Pos('-', EdtPesqCep.Text) > 0) then
  begin
    Key := #0;
    Exit;
  end;

end;

procedure TFrmMain.BtnSairClick(Sender: TObject);
begin
  Close;
end;

end.
