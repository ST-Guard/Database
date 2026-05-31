DROP DATABASE IF EXISTS smartData;
CREATE DATABASE smartData;
USE smartData;
 
CREATE TABLE empresa (
    idEmpresa        INT          PRIMARY KEY AUTO_INCREMENT,
    razaoSocial      VARCHAR(100) NOT NULL,
    cnpj             CHAR(14)     NOT NULL,
    telefoneEmpresa  CHAR(11)     NOT NULL,
    tokenEmpresa     CHAR(8)      NOT NULL
);

CREATE TABLE papel (
    idPapel    INT PRIMARY KEY AUTO_INCREMENT,
    nivel      VARCHAR(45),
    descricao  VARCHAR(80),
    fkEmpresa  INT,
    CONSTRAINT fkPapelEmpresa
        FOREIGN KEY (fkEmpresa)
        REFERENCES empresa(idEmpresa)
);
 
CREATE TABLE usuario (
    idUsuario  INT          PRIMARY KEY AUTO_INCREMENT,
    nome       VARCHAR(100),
    imagem     VARCHAR(255),
    email      VARCHAR(200),
    cpf        CHAR(11),
    telefone   CHAR(15),
    senha      VARCHAR(50),
    status     VARCHAR(20)  DEFAULT 'Ativo',
    sla_mttr   INT          DEFAULT NULL COMMENT 'Média de MTTR em minutos, atualizada pelo Java',
    fkPapel    INT,
    CONSTRAINT fkUsuarioPapel
        FOREIGN KEY (fkPapel)
        REFERENCES papel(idPapel)
);
 
CREATE TABLE datacenter (
    idDataCenter          INT         PRIMARY KEY AUTO_INCREMENT,
    nome                  VARCHAR(45),
    capacidadeServidores  INT
);

CREATE TABLE datacenters_gestores (
    fk_usuario     INT      NOT NULL,
    fk_datacenter  INT      NOT NULL,
    atribuido_em   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo          TINYINT(1) NOT NULL DEFAULT 1,
 
    PRIMARY KEY (fk_usuario, fk_datacenter),
 
    CONSTRAINT fk_dg_usuario
        FOREIGN KEY (fk_usuario)
        REFERENCES usuario(idUsuario)
        ON DELETE CASCADE,
 
    CONSTRAINT fk_dg_datacenter
        FOREIGN KEY (fk_datacenter)
        REFERENCES datacenter(idDataCenter)
        ON DELETE CASCADE
);

CREATE TABLE zona (
    idZona      INT PRIMARY KEY AUTO_INCREMENT,
    nome        ENUM('Zona A', 'Zona B', 'Zona C') NOT NULL,
    fkDataCenter INT,
    CONSTRAINT fkZonaDataCenter
        FOREIGN KEY (fkDataCenter)
        REFERENCES datacenter(idDataCenter)
);
 
CREATE TABLE analista_zona (
    usuario_id   INT      NOT NULL,
    zona_id      INT      NOT NULL,
    atribuido_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo        TINYINT(1) NOT NULL DEFAULT 1,
 
    PRIMARY KEY (usuario_id, zona_id),
 
    CONSTRAINT fk_az_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(idUsuario)
        ON DELETE CASCADE,
 
    CONSTRAINT fk_az_zona
        FOREIGN KEY (zona_id)
        REFERENCES zona(idZona)
        ON DELETE CASCADE
);

CREATE TABLE regiao (
    idRegiao            INT PRIMARY KEY AUTO_INCREMENT,
    cep                 CHAR(8),
    numero              VARCHAR(45),
    uf         CHAR(2),
    estado              VARCHAR(45),
    fkRegiaoEmpresa     INT,
    CONSTRAINT fkRegiaoEmpresa
        FOREIGN KEY (fkRegiaoEmpresa)
        REFERENCES empresa(idEmpresa),
    fkRegiaoDataCenter  INT,
    CONSTRAINT fkRegiaoDataCenter
        FOREIGN KEY (fkRegiaoDataCenter)
        REFERENCES datacenter(idDataCenter)
);


CREATE TABLE servidor (
    idServidor  INT         PRIMARY KEY AUTO_INCREMENT,
    nome        VARCHAR(45),
    tipo        VARCHAR(100),
    estado      VARCHAR(10) CHECK (estado IN ('Ativo', 'Inativo')),
    fkZona      INT,
    CONSTRAINT fkServidorZona
        FOREIGN KEY (fkZona)
        REFERENCES zona(idZona)
);

CREATE TABLE componentes (
    idComponente    INT PRIMARY KEY AUTO_INCREMENT,
    nome            VARCHAR(50),
    tipo            VARCHAR(45),
    unidadeMedida   VARCHAR(45),
    capacidadeMaxima FLOAT
);

CREATE TABLE componentes_servidores (
    idComponenteServidor  INT AUTO_INCREMENT,
    limite                FLOAT,
    fkServidor            INT,
    fkComponentes         INT,
 
    PRIMARY KEY (idComponenteServidor, fkServidor, fkComponentes),
 
    CONSTRAINT fkCSServidor
        FOREIGN KEY (fkServidor)
        REFERENCES servidor(idServidor),
 
    CONSTRAINT fkCSComponentes
        FOREIGN KEY (fkComponentes)
        REFERENCES componentes(idComponente)
);

CREATE TABLE registros_alertas (
    idRegistro          INT          PRIMARY KEY AUTO_INCREMENT,
    dataHora            DATETIME,
    valor               FLOAT,
    threshold_momento   FLOAT        COMMENT 'Limite vigente no momento do alerta — não muda mesmo se o limite for alterado depois',
    severidade          ENUM('baixo', 'medio', 'critico'),
    issue_key           VARCHAR(20)  DEFAULT NULL COMMENT 'Preenchido pelo Java após abrir chamado no Jira',
    aberto_em           DATETIME     DEFAULT NULL,
    resolvido_em        DATETIME     DEFAULT NULL,
    mttr_minutos        INT          DEFAULT NULL,
    sla_ok              TINYINT(1)   DEFAULT NULL COMMENT '1 = dentro do prazo, 0 = fora do prazo',
 
    fkRegistroServidor  INT,
    CONSTRAINT fkRAServidor
        FOREIGN KEY (fkRegistroServidor)
        REFERENCES servidor(idServidor),
 
    fkRegistroComponente INT,
    CONSTRAINT fkRAComponente
        FOREIGN KEY (fkRegistroComponente)
        REFERENCES componentes(idComponente),
 
    fk_responsavel      INT,
    CONSTRAINT fkRAResponsavel
        FOREIGN KEY (fk_responsavel)
        REFERENCES usuario(idUsuario)
);

CREATE TABLE contato_inicial (
    idContato_inicial  INT PRIMARY KEY AUTO_INCREMENT,
    nome_usuario       VARCHAR(45),
    email_usuario      VARCHAR(45),
    mensagem_usuario   VARCHAR(45)
);

INSERT INTO empresa (razaoSocial, cnpj, telefoneEmpresa, tokenEmpresa) VALUES
    ('Steam', '12345678910119', '11123456789', 'STE12345');
 

/*
INSERT INTO papel (nivel, descricao, fkEmpresa) VALUES
    ('Gestor',   'Acesso total ao sistema',      1),
    ('Analista', 'Monitoramento de servidores',  1);
 
INSERT INTO usuario (nome, email, cpf, telefone, senha, status, fkPapel) VALUES
    ('Maria Gestora', 'maria@gmail.com', '12345678910', '(11) 9999-8888', '123456', 'Ativo', 1);
 
INSERT INTO datacenter (nome, capacidadeServidores) VALUES
    ('DC-SP-01', 100),
	('DC-RJ-01', 100),
    ('DC-BH-01', 100);

INSERT INTO datacenters_gestores (fk_usuario, fk_datacenter) VALUES
    (1, 1);
 
INSERT INTO zona (nome, fkDataCenter) VALUES
    ('Zona A', 1),
    ('Zona B', 1),
    ('Zona C', 1);
 

INSERT INTO usuario (nome, email, cpf, telefone, senha, status, fkPapel) VALUES
    ('Erick Analista',  'erick@gmail.com',  '10987654321', '(11) 9999-7777', '123456', 'Ativo', 2),
    ('Miguel Analista', 'miguel@gmail.com', '14985559347', '(11) 9999-6666', '123456', 'Ativo', 2);
 
INSERT INTO analista_zona (usuario_id, zona_id) VALUES
    (2, 1),
    (3, 1);
 
INSERT INTO regiao (cep, numero, uf, estado, fkRegiaoEmpresa, fkRegiaoDataCenter) VALUES
    ('12345678', '9101', 'SP', 'São Paulo', 1, 1),
	('12345678', '9101', 'RJ', 'Rio de Janeiro', 1, 2),
    ('12345678', '9101', 'BH', 'Belo Horizonte', 1, 3);

 
INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
    ('SRV-DC01-WEB-05', 'Web', 'Ativo', 1),
    ('SRV-DC01-DB-12',  'DB',  'Ativo', 1),
    ('SRV-FK02-GM-02',  'GM',  'Ativo', 1),
    ('SRV-DC01-WEB-08', 'WEB', 'Ativo', 1);
 
INSERT INTO componentes (nome, tipo, unidadeMedida, capacidadeMaxima) VALUES
    ('CPU',  'Processador',    '%',    100),
    ('RAM',  'Memoria',        'GB',    20),
    ('DISCO','Armazenamento',  'GB',   512),
    ('REDE', 'Latencia',       'MBps',  50);
 
INSERT INTO componentes_servidores (limite, fkServidor, fkComponentes) VALUES
    (90, 1, 1), (90, 1, 2), (80, 1, 3), (40, 1, 4),
    (90, 2, 1), (85, 2, 2), (90, 2, 3), (40, 2, 4),
    (90, 3, 1), (65, 3, 2), (65, 3, 3), (40, 3, 4),
    (90, 4, 1), (75, 4, 2), (70, 4, 3), (40, 4, 4);
*/

CREATE VIEW vwBuscarDados AS
    SELECT
        u.idUsuario,
        u.nome          AS nomePessoa,
        u.imagem,
        u.telefone,
        u.email,
        u.cpf,
        u.sla_mttr,
        p.nivel         AS cargo,
        p.descricao     AS bio,
        d.nome          AS nomeDataCenter,
        z.idZona        AS idZona,
        z.nome          AS nomeZona
    FROM usuario u
    JOIN papel p ON p.idPapel = u.fkPapel
    LEFT JOIN analista_zona az ON az.usuario_id = u.idUsuario AND az.ativo = 1
    LEFT JOIN zona z ON z.idZona = az.zona_id
    LEFT JOIN datacenters_gestores dg ON dg.fk_usuario = u.idUsuario AND dg.ativo = 1
    LEFT JOIN datacenter d ON (
        (p.nivel = 'Analista' AND d.idDataCenter = z.fkDataCenter)
        OR
        (p.nivel = 'Gestor'   AND d.idDataCenter = dg.fk_datacenter)
    );
    
    
#lista datacenters que o user tem acesso 
 SELECT DISTINCT
    r.estado, r.idRegiao
FROM
    usuario AS u
        JOIN
    datacenters_gestores AS dg ON dg.fk_usuario = u.idUsuario
        JOIN
    datacenter AS d ON dg.fk_datacenter = d.idDataCenter
        JOIN
    regiao AS r ON fkRegiaoDataCenter = d.idDataCenter
WHERE
    u.fkPapel = 1 AND dg.fk_usuario = 1;
                
                
    #lista as regioes dos datacenters que o user tem acesso
SELECT 
    d.nome, fk_datacenter
FROM
    usuario AS u
        JOIN
    datacenters_gestores AS dg ON dg.fk_usuario = u.idUsuario
        JOIN
    datacenter AS d ON dg.fk_datacenter = d.idDataCenter
        JOIN
    regiao AS r ON fkRegiaoDataCenter = d.idDataCenter
WHERE
    u.fkPapel = 1 AND dg.fk_usuario = 1
        AND r.idRegiao = 1;
        
        
INSERT INTO papel (nivel, descricao, fkEmpresa) VALUES
('Gestor',   'Acesso total ao sistema',     1),
('Analista', 'Monitoramento de servidores', 1);
 
INSERT INTO usuario (nome, email, cpf, telefone, senha, status, fkPapel) VALUES
('Maria Gestora', 'maria@smartdata.com', '11122233344', '(11) 9999-0001', '123456', 'Ativo', 1);
 
INSERT INTO usuario (nome, email, cpf, telefone, senha, status, fkPapel) VALUES
('Erick Analista',   'erick@smartdata.com',   '22233344455', '(11) 9999-0002', '123456', 'Ativo', 2),
('Miguel Analista',  'miguel@smartdata.com',  '33344455566', '(11) 9999-0003', '123456', 'Ativo', 2),
('Joana Analista',   'joana@smartdata.com',   '44455566677', '(21) 9999-0004', '123456', 'Ativo', 2),
('Carlos Analista',  'carlos@smartdata.com',  '55566677788', '(21) 9999-0005', '123456', 'Ativo', 2),
('Fernanda Analista','fernanda@smartdata.com','66677788899', '(51) 9999-0006', '123456', 'Ativo', 2),
('Rafael Analista',  'rafael@smartdata.com',  '77788899900', '(51) 9999-0007', '123456', 'Ativo', 2);

INSERT INTO datacenter (nome, capacidadeServidores) VALUES
('SP', 100),
('RJ', 100),
('RS', 100);

INSERT INTO datacenters_gestores (fk_usuario, fk_datacenter) VALUES
(1, 1), (1, 2), (1, 3);

INSERT INTO regiao (cep, numero, estado, fkRegiaoEmpresa, fkRegiaoDataCenter) VALUES
('01310100', '1000', 'DC São Paulo',     1, 1),
('20040020', '500',  'DC Rio de Janeiro', 1, 2),
('90010280', '200',  'DC Porto Alegre',  1, 3);
 
INSERT INTO zona (nome, fkDataCenter) VALUES
('Zona A', 1), ('Zona B', 1), ('Zona C', 1);

INSERT INTO zona (nome, fkDataCenter) VALUES
('Zona A', 2), ('Zona B', 2), ('Zona C', 2);

INSERT INTO zona (nome, fkDataCenter) VALUES
('Zona A', 3), ('Zona B', 3), ('Zona C', 3);
 
INSERT INTO analista_zona (usuario_id, zona_id) VALUES
(2, 1), (2, 2), (3, 3);

INSERT INTO analista_zona (usuario_id, zona_id) VALUES
(4, 4), (4, 5), (5, 6);

INSERT INTO analista_zona (usuario_id, zona_id) VALUES
(6, 7), (6, 8), (7, 9);
 
INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-SP-01', 'Web', 'Ativo', 1),
('SERVIDOR-SP-02', 'DB',  'Ativo', 1),
('SERVIDOR-SP-03', 'App', 'Ativo', 1);

INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-SP-04', 'Web', 'Ativo', 2),
('SERVIDOR-SP-05', 'DB',  'Ativo', 2),
('SERVIDOR-SP-06', 'App', 'Ativo', 2);

INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-SP-07', 'Web', 'Ativo', 3),
('SERVIDOR-SP-08', 'DB',  'Ativo', 3),
('SERVIDOR-SP-09', 'App', 'Ativo', 3);

INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-RJ-01', 'Web', 'Ativo', 4),
('SERVIDOR-RJ-02', 'DB',  'Ativo', 4),
('SERVIDOR-RJ-03', 'App', 'Ativo', 4);
 
INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-RJ-04', 'Web', 'Ativo', 5),
('SERVIDOR-RJ-05', 'DB',  'Ativo', 5),
('SERVIDOR-RJ-06', 'App', 'Ativo', 5);

INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-RJ-07', 'Web', 'Ativo', 6),
('SERVIDOR-RJ-08', 'DB',  'Ativo', 6),
('SERVIDOR-RJ-09', 'App', 'Ativo', 6);

INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-RS-01', 'Web', 'Ativo', 7),
('SERVIDOR-RS-02', 'DB',  'Ativo', 7),
('SERVIDOR-RS-03', 'App', 'Ativo', 7);
 
INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-RS-04', 'Web', 'Ativo', 8),
('SERVIDOR-RS-05', 'DB',  'Ativo', 8),
('SERVIDOR-RS-06', 'App', 'Ativo', 8);

INSERT INTO servidor (nome, tipo, estado, fkZona) VALUES
('SERVIDOR-RS-07', 'Web', 'Ativo', 9),
('SERVIDOR-RS-08', 'DB',  'Ativo', 9),
('SERVIDOR-RS-09', 'App', 'Ativo', 9);
 
INSERT INTO componentes (nome, tipo, unidadeMedida, capacidadeMaxima) VALUES
('CPU',   'Processador',   '%',    100),
('RAM',   'Memoria',       'GB',    20),
('DISCO', 'Armazenamento', 'GB',   512),
('REDE',  'Latencia',      'MBps',  50);
 
INSERT INTO componentes_servidores (limite, fkServidor, fkComponentes) VALUES
(80, 1,1),(16,1,2),(450,1,3),(40,1,4),
(80, 2,1),(16,2,2),(450,2,3),(40,2,4),
(80, 3,1),(16,3,2),(450,3,3),(40,3,4),
(80, 4,1),(16,4,2),(450,4,3),(40,4,4),
(80, 5,1),(16,5,2),(450,5,3),(40,5,4),
(80, 6,1),(16,6,2),(450,6,3),(40,6,4),
(80, 7,1),(16,7,2),(450,7,3),(40,7,4),
(80, 8,1),(16,8,2),(450,8,3),(40,8,4),
(80, 9,1),(16,9,2),(450,9,3),(40,9,4),
(80,10,1),(16,10,2),(450,10,3),(40,10,4),
(80,11,1),(16,11,2),(450,11,3),(40,11,4),
(80,12,1),(16,12,2),(450,12,3),(40,12,4),
(80,13,1),(16,13,2),(450,13,3),(40,13,4),
(80,14,1),(16,14,2),(450,14,3),(40,14,4),
(80,15,1),(16,15,2),(450,15,3),(40,15,4),
(80,16,1),(16,16,2),(450,16,3),(40,16,4),
(80,17,1),(16,17,2),(450,17,3),(40,17,4),
(80,18,1),(16,18,2),(450,18,3),(40,18,4),
(80,19,1),(16,19,2),(450,19,3),(40,19,4),
(80,20,1),(16,20,2),(450,20,3),(40,20,4),
(80,21,1),(16,21,2),(450,21,3),(40,21,4),
(80,22,1),(16,22,2),(450,22,3),(40,22,4),
(80,23,1),(16,23,2),(450,23,3),(40,23,4),
(80,24,1),(16,24,2),(450,24,3),(40,24,4),
(80,25,1),(16,25,2),(450,25,3),(40,25,4),
(80,26,1),(16,26,2),(450,26,3),(40,26,4),
(80,27,1),(16,27,2),(450,27,3),(40,27,4);

ALTER TABLE registros_alertas
ADD COLUMN datacenter VARCHAR(45) DEFAULT NULL,
ADD COLUMN data_hora  DATETIME    DEFAULT NULL;
 
INSERT INTO registros_alertas (valor,threshold_momento,severidade,issue_key,aberto_em,resolvido_em,mttr_minutos,sla_ok,fkRegistroServidor,fkRegistroComponente,fk_responsavel,datacenter,data_hora) VALUES

(95,80,'critico','KAN-H01','2026-04-28 08:00:00','2026-04-28 08:45:00',45,1,1,1,2,'SP','2026-04-28 08:00:00'),
(18,16,'medio',  'KAN-H02','2026-04-28 09:00:00','2026-04-28 12:00:00',180,1,1,2,2,'SP','2026-04-28 09:00:00'),
(470,450,'baixo','KAN-H03','2026-04-29 10:00:00','2026-04-30 08:00:00',1320,1,2,3,2,'SP','2026-04-29 10:00:00'),
(92,80,'critico','KAN-H04','2026-04-29 14:00:00','2026-04-29 14:50:00',50,1,2,1,2,'SP','2026-04-29 14:00:00'),
(47,40,'medio',  'KAN-H05','2026-04-30 11:00:00','2026-04-30 14:30:00',210,1,3,4,3,'SP','2026-04-30 11:00:00'),
(97,80,'critico','KAN-H06','2026-04-30 15:00:00','2026-04-30 16:30:00',90,0,4,1,3,'SP','2026-04-30 15:00:00'),

(94,80,'critico','KAN-H07','2026-05-05 07:00:00','2026-05-05 07:55:00',55,1,1,1,2,'SP','2026-05-05 07:00:00'),
(19,16,'critico','KAN-H08','2026-05-05 08:00:00','2026-05-05 09:30:00',90,0,4,2,3,'SP','2026-05-05 08:00:00'),
(88,80,'medio',  'KAN-H09','2026-05-06 10:00:00','2026-05-06 13:00:00',180,1,3,1,3,'SP','2026-05-06 10:00:00'),
(472,450,'baixo','KAN-H10','2026-05-07 09:00:00','2026-05-08 07:00:00',1320,1,5,3,2,'SP','2026-05-07 09:00:00'),
(91,80,'critico','KAN-H11','2026-05-08 13:00:00','2026-05-08 14:30:00',90,0,2,1,2,'SP','2026-05-08 13:00:00'),
(17,16,'medio',  'KAN-H12','2026-05-09 16:00:00','2026-05-09 19:00:00',180,1,6,2,3,'SP','2026-05-09 16:00:00'),

(96,80,'critico','KAN-H13','2026-05-12 08:30:00','2026-05-12 09:00:00',30,1,1,1,2,'SP','2026-05-12 08:30:00'),
(93,80,'critico','KAN-H14','2026-05-12 10:00:00','2026-05-12 11:30:00',90,0,4,1,3,'SP','2026-05-12 10:00:00'),
(19,16,'critico','KAN-H15','2026-05-13 09:00:00','2026-05-13 10:10:00',70,0,1,2,2,'SP','2026-05-13 09:00:00'),
(48,40,'medio',  'KAN-H16','2026-05-14 14:00:00','2026-05-14 17:00:00',180,1,3,4,3,'SP','2026-05-14 14:00:00'),
(475,450,'baixo','KAN-H17','2026-05-15 08:00:00','2026-05-16 06:00:00',1320,1,7,3,2,'SP','2026-05-15 08:00:00'),
(90,80,'critico','KAN-H18','2026-05-16 11:00:00','2026-05-16 12:30:00',90,0,2,1,2,'SP','2026-05-16 11:00:00'),

(91,80,'critico','KAN-H19','2026-05-19 07:30:00','2026-05-19 08:20:00',50,1,1,1,2,'SP','2026-05-19 07:30:00'),
(85,80,'medio',  'KAN-H20','2026-05-20 10:00:00','2026-05-20 13:30:00',210,1,3,1,3,'SP','2026-05-20 10:00:00'),
(18,16,'medio',  'KAN-H21','2026-05-21 09:00:00','2026-05-21 12:00:00',180,1,4,2,3,'SP','2026-05-21 09:00:00'),
(468,450,'baixo','KAN-H22','2026-05-22 08:00:00','2026-05-23 06:00:00',1320,1,8,3,2,'SP','2026-05-22 08:00:00'),
 
(93,80,'critico','KAN-H23','2026-04-28 09:00:00','2026-04-28 09:50:00',50,1,10,1,4,'RJ','2026-04-28 09:00:00'),
(17,16,'medio',  'KAN-H24','2026-04-29 10:00:00','2026-04-29 13:00:00',180,1,11,2,4,'RJ','2026-04-29 10:00:00'),
(471,450,'baixo','KAN-H25','2026-04-30 08:00:00','2026-05-01 07:00:00',1380,0,12,3,5,'RJ','2026-04-30 08:00:00'),
(95,80,'critico','KAN-H26','2026-04-30 14:00:00','2026-04-30 16:00:00',120,0,13,1,5,'RJ','2026-04-30 14:00:00'),

(92,80,'critico','KAN-H27','2026-05-05 08:00:00','2026-05-05 08:50:00',50,1,10,1,4,'RJ','2026-05-05 08:00:00'),
(46,40,'medio',  'KAN-H28','2026-05-06 11:00:00','2026-05-06 14:00:00',180,1,11,4,4,'RJ','2026-05-06 11:00:00'),
(19,16,'critico','KAN-H29','2026-05-07 09:00:00','2026-05-07 11:00:00',120,0,13,2,5,'RJ','2026-05-07 09:00:00'),
(473,450,'baixo','KAN-H30','2026-05-08 08:00:00','2026-05-09 07:00:00',1380,0,14,3,5,'RJ','2026-05-08 08:00:00'),

(97,80,'critico','KAN-H31','2026-05-12 07:00:00','2026-05-12 07:45:00',45,1,10,1,4,'RJ','2026-05-12 07:00:00'),
(94,80,'critico','KAN-H32','2026-05-13 09:00:00','2026-05-13 10:30:00',90,0,13,1,5,'RJ','2026-05-13 09:00:00'),
(18,16,'medio',  'KAN-H33','2026-05-14 10:00:00','2026-05-14 13:00:00',180,1,11,2,4,'RJ','2026-05-14 10:00:00'),
(476,450,'baixo','KAN-H34','2026-05-15 09:00:00','2026-05-16 08:00:00',1380,0,15,3,5,'RJ','2026-05-15 09:00:00'),

(90,80,'critico','KAN-H35','2026-05-19 08:00:00','2026-05-19 08:55:00',55,1,10,1,4,'RJ','2026-05-19 08:00:00'),
(47,40,'medio',  'KAN-H36','2026-05-20 11:00:00','2026-05-20 14:30:00',210,1,12,4,4,'RJ','2026-05-20 11:00:00'),
(469,450,'baixo','KAN-H37','2026-05-21 08:00:00','2026-05-22 07:00:00',1380,0,14,3,5,'RJ','2026-05-21 08:00:00'),
 
(91,80,'critico','KAN-H38','2026-04-28 10:00:00','2026-04-28 10:55:00',55,1,19,1,6,'RS','2026-04-28 10:00:00'),
(17,16,'medio',  'KAN-H39','2026-04-29 09:00:00','2026-04-29 12:30:00',210,1,20,2,6,'RS','2026-04-29 09:00:00'),
(472,450,'baixo','KAN-H40','2026-04-30 07:00:00','2026-05-01 06:00:00',1380,0,21,3,7,'RS','2026-04-30 07:00:00'),
(94,80,'critico','KAN-H41','2026-04-30 13:00:00','2026-04-30 15:00:00',120,0,22,1,7,'RS','2026-04-30 13:00:00'),

(93,80,'critico','KAN-H42','2026-05-05 09:00:00','2026-05-05 09:58:00',58,1,19,1,6,'RS','2026-05-05 09:00:00'),
(48,40,'medio',  'KAN-H43','2026-05-06 10:00:00','2026-05-06 13:30:00',210,1,20,4,6,'RS','2026-05-06 10:00:00'),
(19,16,'critico','KAN-H44','2026-05-07 08:00:00','2026-05-07 09:30:00',90,0,22,2,7,'RS','2026-05-07 08:00:00'),
(474,450,'baixo','KAN-H45','2026-05-08 07:00:00','2026-05-09 06:00:00',1380,0,23,3,7,'RS','2026-05-08 07:00:00'),

(96,80,'critico','KAN-H46','2026-05-12 08:00:00','2026-05-12 08:50:00',50,1,19,1,6,'RS','2026-05-12 08:00:00'),
(92,80,'critico','KAN-H47','2026-05-13 10:00:00','2026-05-13 11:30:00',90,0,22,1,7,'RS','2026-05-13 10:00:00'),
(18,16,'medio',  'KAN-H48','2026-05-14 09:00:00','2026-05-14 12:00:00',180,1,20,2,6,'RS','2026-05-14 09:00:00'),
(477,450,'baixo','KAN-H49','2026-05-15 08:00:00','2026-05-16 07:00:00',1380,0,24,3,7,'RS','2026-05-15 08:00:00'),

(95,80,'critico','KAN-H50','2026-05-19 09:00:00','2026-05-19 09:52:00',52,1,19,1,6,'RS','2026-05-19 09:00:00'),
(46,40,'medio',  'KAN-H51','2026-05-20 10:00:00','2026-05-20 13:30:00',210,1,21,4,6,'RS','2026-05-20 10:00:00'),
(470,450,'baixo','KAN-H52','2026-05-21 07:00:00','2026-05-22 06:00:00',1380,0,23,3,7,'RS','2026-05-21 07:00:00');

UPDATE usuario SET sla_mttr = (SELECT CAST(AVG(r.mttr_minutos) AS UNSIGNED) FROM registros_alertas r WHERE r.fk_responsavel = 2 AND r.resolvido_em IS NOT NULL) WHERE idUsuario = 2;
UPDATE usuario SET sla_mttr = (SELECT CAST(AVG(r.mttr_minutos) AS UNSIGNED) FROM registros_alertas r WHERE r.fk_responsavel = 3 AND r.resolvido_em IS NOT NULL) WHERE idUsuario = 3;
UPDATE usuario SET sla_mttr = (SELECT CAST(AVG(r.mttr_minutos) AS UNSIGNED) FROM registros_alertas r WHERE r.fk_responsavel = 4 AND r.resolvido_em IS NOT NULL) WHERE idUsuario = 4;
UPDATE usuario SET sla_mttr = (SELECT CAST(AVG(r.mttr_minutos) AS UNSIGNED) FROM registros_alertas r WHERE r.fk_responsavel = 5 AND r.resolvido_em IS NOT NULL) WHERE idUsuario = 5;
UPDATE usuario SET sla_mttr = (SELECT CAST(AVG(r.mttr_minutos) AS UNSIGNED) FROM registros_alertas r WHERE r.fk_responsavel = 6 AND r.resolvido_em IS NOT NULL) WHERE idUsuario = 6;
UPDATE usuario SET sla_mttr = (SELECT CAST(AVG(r.mttr_minutos) AS UNSIGNED) FROM registros_alertas r WHERE r.fk_responsavel = 7 AND r.resolvido_em IS NOT NULL) WHERE idUsuario = 7;
    