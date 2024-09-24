# Projeto de Consulta de Endereços e CEPs

## Desafio técnico - Softplan

## Menu

- [Introdução](#introdução)
  
- [Configurações Iniciais](#configurações)

- [Arquitetura](#arquitetura)

- [Dicas de Uso](#dicas)

- [Padrões Aplicados](#padrões)

- [Boas Práticas](#boas)

  



## Introdução

Este projeto é uma aplicação Delphi que consome e retorna endereços e CEPs através da API pública do ViaCEP. Possibilita consultas por CEP ou endereço completo, permitindo a navegação entre registros, exibindo ou atualizando os dados armazenados no banco de dados.

![image](https://github.com/user-attachments/assets/80b49ba6-49f7-48e9-b2a6-d09925138137)


## Configurações

Para que seja possível a execução da aplicação, é necessário que seja criado um banco de dados MSSQL Server, cujo script para criação do banco de dados (*script criação de tabelas.sql*)
, criação das tabelas utilizadas na aplicação e população de registros na tabela de CEPs, encontra-se disponível dentro do projeto. 

Na pasta do projeto, encontra-se o arquivo *consultacep.ini* contendo as informações necessárias para que a aplicação conecte com o banco de dados criado anteriormente.

![image](https://github.com/user-attachments/assets/93d27d46-4750-446f-a354-92af05465556)

Com qualquer editor de arquivos TXT (ex: bloco de notas), alterar na ultima linha a informação "Address" com a informação que consta no *"Nome do Servidor"* ao se conectar no SQL Server do seu computador.

## Arquitetura

A arquitetura do projeto segue o padrão MVC (Model-View-Controller), que permite uma separação clara de responsabilidades:

- **Model**: Contém as classes que representam os dados da aplicação e a lógica de negócios (por exemplo, `TEndereco`, `TCEPService`).
- **View**: São os formulários Delphi que apresentam a interface do usuário (por exemplo, `FrmMain`, `FrmSelecionaCep`).
- **Controller**: Realiza a comunicação entre o Model e a View, gerenciando a lógica de interação do usuário.

## Dicas de Uso

![image](https://github.com/user-attachments/assets/3d2ba708-8f40-4a4b-841f-31090fbc32fa)

A interface principal da aplicação é apresenrada contendo os botões de ação (Incluir, Alterar, Excluir, Gravar, Cancelar e Sair), as opções de Pesquisa (por CEP ou por Endereço) e a forma de retorno da pesquisa (arquivo JSON ou arquivo XML). Logo abaixo o serão exibidos o campo a pesquisar, os botões para pesquisar ou limpar os campos, todos os campos a serem preenchidos, além de um grid contendo todos os logradouros e suas respectivas informações (CEP, localidade, bairro, estado e complemento) cadastrados na base de dados. 

### Pesquisa por CEP

![image](https://github.com/user-attachments/assets/8f3f04b6-63c0-460b-b1df-999b20c92417)

Ao Informar o cep a pesquisar e clicar no botão "Pesquisar", será preenchido automaticamente os campos relacionados ao endereço, ficando disponível para o usuário efetuar qualquer alteração nas informações obtidas atraves da API do ViaCep. Nesse momento é habilitado o botão "Inserir" e o botão "Cancelar", ficando desabilidado o grid e os demais botões. Caso deseje inserir o registro, basta clicar no botão "Inserir" que o mesmo será adicionado a base de dados existente, caso contrário, clicar no botão "cancelar" que a interface voltará ao estado inicial dela.

Para alterar ou excluir um registro incluido na base de dados, existe duas formas: efetuando om click duplo no registro escolhido no grid de endereços cadaastrados, nesse caso, será preenchido todos os campos relacionados ao endereço e ficando habilitado os botões "Alterar", "Excluir" e "Sair", conforme mostrado abaixo:

![image](https://github.com/user-attachments/assets/5a96e1d1-b4b8-4412-b19a-d72e366b7054)

Para alterar as informações, clicar no botão "Alterar" e realizar as alterações necessárias. Após efetuar as alterações clicar no botão "Gravar" para que as alterações sejam persistidas no banco de dados, caso contrário, clicar no botão "Cancelar" que as alterações serão desfeitas e a interface volta ao estado inicial dela.

A alteração de registros, pode ser feita também digitando o CEP no campo de pesquisa de CEP.

![image](https://github.com/user-attachments/assets/23b07c29-6fb7-4d9c-8c37-9f3557902047)

Neste caso, será informado ao usuário que foi encontrado um CEP na base de dados e solicitando que efetue a atualização (com base nas informações obtidas pela API ViaCep). Caso o usuário responda sim, serão preenchidos novamente os campos relacionados ao endereço, caso contrario, serão exibidos os campos que estão na base de dados.
A partir desse momento, a rotina permanece igual a anteriormente mencionada, permitindo o usuario alterar ou excluir o registro pesquisado.

### Pesquisa por Endereço

Para que possa ser feita a pesquisa pelo endereço, primeiro precisa alterar a opção de pesquisa para "Endereço". Nesse momento serão exibidos os campos necessários para efetuar a pesquisa.

![image](https://github.com/user-attachments/assets/c829d807-5384-4344-a53f-19c828e51dfc)

Todos os campos para pesquisa por endereço completo são de preenchimento obrigatório. Após preecher o endereço completo, basta clicar no botão "Pesquisar" que será feito o mesmo procedimento como na consulta por cep. No caso de pesquisa por endereço, é possivel quel o mesmo endereço possa existir com CEPs diferentes (logradouros com o mesmo nome em bairros distintos ou logradouro com varios CEPs), nesse caso, será exibida uma mensagem ao usuário informando que existe mais de um CEP para o endereço informado e solicitando se deseja visualiza-los. Caso o usuário escolha "Sim", será exibido uma nova janela mostrando todos os CEPs encontrados para o endereço informado.

![image](https://github.com/user-attachments/assets/160ccd29-9a80-4e2a-abac-c4ae0fe2f674)

Basta o usuário clicar no botão "Selecionar" ou dar um duplo click no registro escolhido no grid que serão preenchidas as informações na interface principal da aplicação.

![image](https://github.com/user-attachments/assets/fb6dee87-faf0-4b3c-82e9-06ecc611d993)

O mesmo procedimento de pesquisar um CEP que já existe na base de dados e que permite atualizar o endereço com as informações obtidas pelo webservice do ViaCep, ocorre também com a pesquisa por endereço completo.

![image](https://github.com/user-attachments/assets/31efa942-8a25-412b-a761-d6be479f15c8)



## Padrões Aplicados

- **Singleton**: Utilizado para a classe `TConnection`, garantindo que apenas uma instância da conexão com o banco de dados seja criada e utilizada.
- **Repository**: A classe `enderecorepository.model` atua como um repositório para realizar operações de CRUD no banco de dados.
- **Service**: A classe `TCEPService` encapsula a lógica de acesso à API ViaCEP, permitindo consultas de forma organizada.

## Boas Práticas

- **Clean Code**: O código foi escrito seguindo princípios de clean code, com nomes de variáveis e métodos claros, funções curtas e bem definidas.
- **Tratamento de Erros**: Implementação de mensagens amigáveis ao usuário para tratamento de erros e validação de dados.
- **Uso de Tabelas Temporárias**: Utilização de tabelas temporárias para armazenar dados intermediários durante as operações de consulta.
- **Configurações Externas**: O uso de um arquivo `consultaCEP.ini` para armazenar configurações do banco de dados, facilitando a manutenção e a portabilidade da aplicação.

