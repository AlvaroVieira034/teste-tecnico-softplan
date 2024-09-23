# Projeto de Consulta de Endereços e CEPs

## Desafio técnico - Softplan

## Menu

- [Introdução](#introdução)

- [Arquitetura](#arquitetura)

- [Dicas de Uso](uso)

- [Arquitetura](#arquitetura)

- [Padrões Aplicados](#padroes)

- [Boas Práticas](#boaspraticas)

  



## Introdução

Este projeto é uma aplicação Delphi que consome e retorna endereços e CEPs através da API pública do ViaCEP. Permite consultas por CEP ou endereço completo, exibindo ou atualizando os dados armazenados no banco de dados.

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

 