-- Script para criar o banco de dados bdteste e a tabela tab_cep

-- Cria o banco de dados
CREATE DATABASE bdteste;
GO

-- Usa o banco de dados criado
USE bdteste;
GO

-- Cria a tabela tab_cep
CREATE TABLE tab_cep (
   codigo INT IDENTITY(1,1) PRIMARY KEY,
   cep VARCHAR(10),
   logradouro VARCHAR(150),
   complemento VARCHAR(100),
   bairro VARCHAR(100),
   localidade VARCHAR(100),
   uf VARCHAR(2)
);
GO

-- Insere dados na tabela tab_cep
INSERT INTO dbo.tab_cep (cep, logradouro, complemento, bairro, localidade, uf) VALUES 
('34004-645', 'RUA MANOEL MOREIRA DA SILVA, 70', 'APTO 202 - BLOCO 2', 'PAU POMBO', 'NOVA LIMA', 'MG'),
('34004-739', 'ALAMEDA DAS TAMAREIRAS, 36', '', 'OURO VELHO', 'NOVA LIMA', 'MG'),
('30112-010', 'RUA ANTONIO DE ALBUQUERQUE', 'ATE NRO 539/540', 'SAVASSI', 'BELO HORIZONTE', 'MG');
GO
