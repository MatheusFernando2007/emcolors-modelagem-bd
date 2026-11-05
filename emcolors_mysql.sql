DROP DATABASE IF EXISTS emcolors;

CREATE DATABASE emcolors
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE emcolors;

CREATE TABLE cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(120) NOT NULL,
  telefone   VARCHAR(20)  NOT NULL,
  PRIMARY KEY (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE funcionario (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome           VARCHAR(120) NOT NULL,
  cargo          ENUM('Gerente', 'Administrativo', 'Operador de máquina', 'Expedicionista') NOT NULL,
  PRIMARY KEY (id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fornecedor (
  id_fornecedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(120) NOT NULL,
  telefone      VARCHAR(20)  NOT NULL,
  PRIMARY KEY (id_fornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_produto (
  id_tipo_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome            VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id_tipo_produto),
  UNIQUE KEY uq_tipo_produto_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE produto (
  id_produto      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome            VARCHAR(100) NOT NULL,
  id_tipo_produto INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_produto),
  UNIQUE KEY uq_produto_nome (nome),
  KEY idx_produto_tipo (id_tipo_produto),
  CONSTRAINT fk_produto_tipo FOREIGN KEY (id_tipo_produto)
    REFERENCES tipo_produto (id_tipo_produto) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE insumo (
  id_insumo          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  nome               VARCHAR(100)  NOT NULL,
  quantidade_estoque DECIMAL(12,2) NOT NULL DEFAULT 0,
  id_fornecedor      INT UNSIGNED  NOT NULL,
  PRIMARY KEY (id_insumo),
  UNIQUE KEY uq_insumo_nome (nome),
  KEY idx_insumo_fornecedor (id_fornecedor),
  CONSTRAINT ck_estoque_nao_negativo CHECK (quantidade_estoque >= 0),
  CONSTRAINT fk_insumo_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES fornecedor (id_fornecedor) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedido (
  id_pedido     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  data_pedido   DATE          NOT NULL,
  forma_entrega ENUM('entrega', 'retirada') NOT NULL,
  status        ENUM('orcamento', 'aprovado', 'em_producao', 'pronto', 'entregue')
                NOT NULL DEFAULT 'orcamento',
  valor_total   DECIMAL(12,2) NULL,
  id_cliente                      INT UNSIGNED NOT NULL,
  id_funcionario_gerente_vendedor INT UNSIGNED NOT NULL,
  id_funcionario_aprovador        INT UNSIGNED NULL,
  PRIMARY KEY (id_pedido),
  KEY idx_pedido_cliente   (id_cliente),
  KEY idx_pedido_gerente   (id_funcionario_gerente_vendedor),
  KEY idx_pedido_aprovador (id_funcionario_aprovador),
  CONSTRAINT ck_pedido_valor CHECK (valor_total IS NULL OR valor_total >= 0),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_pedido_gerente FOREIGN KEY (id_funcionario_gerente_vendedor)
    REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_pedido_aprovador FOREIGN KEY (id_funcionario_aprovador)
    REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedido_produto (
  id_pedido          INT UNSIGNED  NOT NULL,
  id_produto         INT UNSIGNED  NOT NULL,
  quantidade_produto DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_pedido, id_produto),
  KEY idx_pedido_produto_produto (id_produto),
  CONSTRAINT ck_quantidade_positiva CHECK (quantidade_produto > 0),
  CONSTRAINT fk_pedido_produto_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_pedido_produto_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE produto_insumo (
  id_produto INT UNSIGNED NOT NULL,
  id_insumo  INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_produto, id_insumo),
  KEY idx_produto_insumo_insumo (id_insumo),
  CONSTRAINT fk_produto_insumo_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_produto_insumo_insumo FOREIGN KEY (id_insumo)
    REFERENCES insumo (id_insumo) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO cliente (id_cliente, nome, telefone) VALUES
  (1, 'João Silva',              '(11) 90000-0001'),
  (2, 'Maria Oliveira',          '(11) 90000-0002'),
  (3, 'Padaria Pão Quente Ltda', '(11) 90000-0003'),
  (4, 'Studio Bella Estética',   '(11) 90000-0004'),
  (5, 'Roberto Lima',            '(11) 90000-0005'),
  (6, 'Ana Paula Costa',         '(11) 90000-0006');

INSERT INTO funcionario (id_funcionario, nome, cargo) VALUES
  (1, 'Marcos Almeida',    'Gerente'),
  (2, 'Patrícia Nogueira', 'Administrativo'),
  (3, 'Renata Souza',      'Administrativo'),
  (4, 'Carlos Souza',      'Operador de máquina'),
  (5, 'Fábio Ramos',       'Operador de máquina'),
  (6, 'Eduardo Pires',     'Expedicionista');

INSERT INTO fornecedor (id_fornecedor, nome, telefone) VALUES
  (1, 'Tintas Paulista Ltda', '(11) 3000-0001'),
  (2, 'Papéis e Bobinas XYZ', '(11) 3000-0002'),
  (3, 'Clichês Rápido',       '(11) 3000-0003');

INSERT INTO tipo_produto (id_tipo_produto, nome) VALUES
  (1, 'Adesivo'), (2, 'Cartão'), (3, 'Etiqueta');

INSERT INTO produto (id_produto, nome, id_tipo_produto) VALUES
  (1, 'Adesivo couché',        1),
  (2, 'Adesivo contracolado',  1),
  (3, 'Cartão de visita',      2),
  (4, 'Etiqueta couché',       3),
  (5, 'Etiqueta contracolado', 3);

INSERT INTO insumo (id_insumo, nome, quantidade_estoque, id_fornecedor) VALUES
  (1, 'Tinta CMYK',                   50,   1),
  (2, 'Bobina de papel couché',       3000, 2),
  (3, 'Bobina de papel contracolado', 2000, 2),
  (4, 'Clichê padrão',                12,   3);

INSERT INTO produto_insumo (id_produto, id_insumo) VALUES
  (1, 1), (1, 2), (1, 4),
  (2, 1), (2, 3), (2, 4),
  (3, 1), (3, 2), (3, 4),
  (4, 1), (4, 2), (4, 4),
  (5, 1), (5, 3), (5, 4);

INSERT INTO pedido (id_pedido, data_pedido, forma_entrega, status, valor_total, id_cliente, id_funcionario_gerente_vendedor, id_funcionario_aprovador) VALUES
  (1, '2026-10-05', 'entrega',  'entregue',    1250.00, 1, 2, 1),
  (2, '2026-10-14', 'retirada', 'pronto',      3400.00, 3, 3, 1),
  (3, '2026-10-22', 'retirada', 'em_producao',  780.00, 2, 2, 1),
  (4, '2026-10-27', 'entrega',  'aprovado',    2150.00, 4, 3, 1),
  (5, '2026-10-28', 'retirada', 'orcamento',   NULL,    5, 2, NULL),
  (6, '2026-10-29', 'entrega',  'orcamento',   NULL,    1, 3, NULL);

INSERT INTO pedido_produto (id_pedido, id_produto, quantidade_produto) VALUES
  (1, 1,  500), (1, 3, 1000),
  (2, 4, 2000),
  (3, 3,  500),
  (4, 5, 1500), (4, 2,  300),
  (5, 3, 2000),
  (6, 4,  800);

SELECT * FROM cliente;
SELECT * FROM funcionario;
SELECT * FROM fornecedor;
SELECT * FROM tipo_produto;
SELECT * FROM produto;
SELECT * FROM insumo;
SELECT * FROM pedido;
SELECT * FROM pedido_produto;
SELECT * FROM produto_insumo;
