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
    complemento         VARCHAR(45),
    estado              CHAR(2),
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
 
INSERT INTO papel (nivel, descricao, fkEmpresa) VALUES
    ('Gestor',   'Acesso total ao sistema',      1),
    ('Analista', 'Monitoramento de servidores',  1);
 

INSERT INTO usuario (nome, email, cpf, telefone, senha, status, fkPapel) VALUES
    ('Maria Gestora', 'maria@gmail.com', '12345678910', '(11) 9999-8888', '123456', 'Ativo', 1);
 
INSERT INTO datacenter (nome, capacidadeServidores) VALUES
    ('ST-SP-01', 100);
 
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
 
INSERT INTO regiao (cep, numero, complemento, estado, fkRegiaoEmpresa, fkRegiaoDataCenter) VALUES
    ('12345678', '9101', 'Steam Sp', 'SP', 1, 1);
 
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
    (90, 1, 1), (16, 1, 2), (450, 1, 3), (40, 1, 4),
    (90, 2, 1), (16, 2, 2), (450, 2, 3), (40, 2, 4),
    (90, 3, 1), (16, 3, 2), (450, 3, 3), (40, 3, 4),
    (90, 4, 1), (16, 4, 2), (450, 4, 3), (40, 4, 4);
 
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