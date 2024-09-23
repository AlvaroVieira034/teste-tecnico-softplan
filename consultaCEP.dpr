program consultaCEP;

uses
  Vcl.Forms,
  umain in 'view\umain.pas' {FrmMain},
  connection.model in 'model\connection.model.pas',
  conexao.model in 'model\conexao.model.pas',
  cepservice.model in 'model\cepservice.model.pas',
  endereco.model in 'model\endereco.model.pas',
  enderecorepository.model in 'model\enderecorepository.model.pas',
  uselecionacep in 'view\uselecionacep.pas' {FrmSelecionaCep};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
