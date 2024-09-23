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

Para que seja possível a execução da aplicação, é necessário que seja criado um banco de dados MSSQL Server, cujo script para criação do mesmo (*script criação de tabelas.sql*)
, criação das tabelas das tabelas e população de registros na tabela de CEPs, para que a aplicação fique disponível para uso logo que instalado.

Na pasta do projeto, encontra-se o arquivo *consultacep.ini* contendo as informações necessárias para que a aplicação conecte com o banco de dados criado anteriormente.

![image](https://github.com/user-attachments/assets/93d27d46-4750-446f-a354-92af05465556)

Alterar na ultima linha, a informação "Address" com a informação que consta no "Nome do Servidor" ao conectar ao SQL Server do seu computador.


## Arquitetura

A arquitetura do projeto segue o padrão MVC (Model-View-Controller), que permite uma separação clara de responsabilidades:

- **Model**: Contém as classes que representam os dados da aplicação e a lógica de negócios (por exemplo, `TEndereco`, `TCEPService`).
- **View**: São os formulários Delphi que apresentam a interface do usuário (por exemplo, `FrmMain`, `FrmSelecionaCep`).
- **Controller**: Realiza a comunicação entre o Model e a View, gerenciando a lógica de interação do usuário.

## Padrões Aplicados

- **Singleton**: Utilizado para a classe `TConnection`, garantindo que apenas uma instância da conexão com o banco de dados seja criada e utilizada.
- **Repository**: A classe `enderecorepository.model` atua como um repositório para realizar operações de CRUD no banco de dados.
- **Service**: A classe `TCEPService` encapsula a lógica de acesso à API ViaCEP, permitindo consultas de forma organizada.

## Boas Práticas

- **Clean Code**: O código foi escrito seguindo princípios de clean code, com nomes de variáveis e métodos claros, funções curtas e bem definidas.
- **Tratamento de Erros**: Implementação de mensagens amigáveis ao usuário para tratamento de erros e validação de dados.
- **Uso de Tabelas Temporárias**: Utilização de tabelas temporárias para armazenar dados intermediários durante as operações de consulta.
- **Configurações Externas**: O uso de um arquivo `consultaCEP.ini` para armazenar configurações do banco de dados, facilitando a manutenção e a portabilidade da aplicação.

## Como Executar o Aplicativo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu_usuario/seu_repositorio.git
   cd seu_repositorio

### Dicas Finais
- Certifique-se de adicionar uma seção sobre dependências, se houver, para que os usuários saibam o que instalar.
- Se você tiver um conjunto de testes ou exemplos de uso, considere incluí-los.
- Utilize links relevantes e formatação adequada para facilitar a leitura.

 
