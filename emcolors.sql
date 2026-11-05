-- =====================================================================
-- EMColors | Banco de dados para MySQL 8
-- Recomendado: MySQL 8.0.16 ou superior (CHECK constraints ativos)
--
-- ATENCAO: este script apaga e recria as tabelas do banco emcolors.
-- Execute o arquivo inteiro em uma conexao MySQL. Nao execute apenas
-- trechos isolados, pois os DELIMITER sao usados na criacao dos triggers.
--
-- CORRECAO (erro 3823): no MySQL 8, uma coluna usada em CHECK nao pode
-- participar de uma chave estrangeira com ON UPDATE CASCADE / SET NULL.
-- Por isso a FK fk_pedido_aprovador usa ON UPDATE RESTRICT.
-- =====================================================================

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS emcolors
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE emcolors;

-- ---------------------------------------------------------------------
-- 1. LIMPEZA: primeiro views e triggers, depois tabelas dependentes
-- ---------------------------------------------------------------------

DROP VIEW IF EXISTS vw_pendencias;
DROP VIEW IF EXISTS vw_estoque_do_pedido;
DROP VIEW IF EXISTS vw_itens_pedido;
DROP VIEW IF EXISTS vw_pedidos;

DROP TRIGGER IF EXISTS trg_pedido_nasce_orcamento;
DROP TRIGGER IF EXISTS trg_pedido_fluxo_status;
DROP TRIGGER IF EXISTS trg_pedido_aprovar;
DROP TRIGGER IF EXISTS trg_pedido_validar_atualizacao;
DROP TRIGGER IF EXISTS trg_pedido_so_apaga_orcamento;
DROP TRIGGER IF EXISTS trg_itens_so_em_orcamento_insert;
DROP TRIGGER IF EXISTS trg_itens_so_em_orcamento_update;
DROP TRIGGER IF EXISTS trg_itens_so_em_orcamento_delete;

DROP TABLE IF EXISTS produto_insumo;
DROP TABLE IF EXISTS pedido_produto;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS insumo;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS tipo_produto;
DROP TABLE IF EXISTS fornecedor;
DROP TABLE IF EXISTS funcionario;
DROP TABLE IF EXISTS cliente;

-- ---------------------------------------------------------------------
-- 2. TABELAS
-- ---------------------------------------------------------------------

CREATE TABLE cliente (
  id_cliente INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  telefone VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_cliente),
  CONSTRAINT ck_cliente_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_cliente_telefone CHECK (CHAR_LENGTH(TRIM(telefone)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE funcionario (
  id_funcionario INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  cargo VARCHAR(40) NOT NULL,
  PRIMARY KEY (id_funcionario),
  CONSTRAINT ck_funcionario_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_funcionario_cargo CHECK (
    cargo IN ('Gerente', 'Administrativo', 'Operador de máquina', 'Expedicionista')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fornecedor (
  id_fornecedor INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  telefone VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_fornecedor),
  CONSTRAINT ck_fornecedor_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_fornecedor_telefone CHECK (CHAR_LENGTH(TRIM(telefone)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_produto (
  id_tipo_produto INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_tipo_produto),
  CONSTRAINT uq_tipo_produto_nome UNIQUE (nome),
  CONSTRAINT ck_tipo_produto_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE produto (
  id_produto INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  id_tipo_produto INT NOT NULL,
  PRIMARY KEY (id_produto),
  CONSTRAINT uq_produto_nome UNIQUE (nome),
  CONSTRAINT ck_produto_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT fk_produto_tipo FOREIGN KEY (id_tipo_produto)
    REFERENCES tipo_produto (id_tipo_produto)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE insumo (
  id_insumo INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  quantidade_estoque DECIMAL(12,2) NOT NULL DEFAULT 0,
  id_fornecedor INT NOT NULL,
  PRIMARY KEY (id_insumo),
  CONSTRAINT uq_insumo_nome UNIQUE (nome),
  CONSTRAINT ck_insumo_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_estoque_nao_negativo CHECK (quantidade_estoque >= 0),
  CONSTRAINT fk_insumo_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES fornecedor (id_fornecedor)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedido (
  id_pedido INT NOT NULL AUTO_INCREMENT,
  data_pedido DATE NOT NULL,
  forma_entrega VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'orcamento',
  valor_total DECIMAL(12,2) NULL,
  id_cliente INT NOT NULL,
  id_funcionario_gerente_vendedor INT NOT NULL,
  id_funcionario_aprovador INT NULL,
  PRIMARY KEY (id_pedido),
  CONSTRAINT ck_pedido_forma_entrega CHECK (forma_entrega IN ('entrega', 'retirada')),
  CONSTRAINT ck_pedido_status CHECK (
    status IN ('orcamento', 'aprovado', 'em_producao', 'pronto', 'entregue')
  ),
  CONSTRAINT ck_pedido_valor CHECK (valor_total IS NULL OR valor_total >= 0),
  CONSTRAINT ck_aprovado_exige_aprovador_e_valor CHECK (
    status = 'orcamento'
    OR (id_funcionario_aprovador IS NOT NULL AND valor_total IS NOT NULL)
  ),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_vendedor FOREIGN KEY (id_funcionario_gerente_vendedor)
    REFERENCES funcionario (id_funcionario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  -- IMPORTANTE: id_funcionario_aprovador e usado no CHECK acima, entao a FK
  -- NAO pode ter ON UPDATE CASCADE (erro 3823 no MySQL 8).
  CONSTRAINT fk_pedido_aprovador FOREIGN KEY (id_funcionario_aprovador)
    REFERENCES funcionario (id_funcionario)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedido_produto (
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade_produto DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_pedido, id_produto),
  CONSTRAINT ck_quantidade_positiva CHECK (quantidade_produto > 0),
  CONSTRAINT fk_pedido_produto_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_produto_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE produto_insumo (
  id_produto INT NOT NULL,
  id_insumo INT NOT NULL,
  PRIMARY KEY (id_produto, id_insumo),
  CONSTRAINT fk_produto_insumo_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_produto_insumo_insumo FOREIGN KEY (id_insumo)
    REFERENCES insumo (id_insumo)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices para filtros e ordenacoes frequentes.
-- O InnoDB cria automaticamente indices de apoio para as chaves estrangeiras.
CREATE INDEX idx_pedido_status_data ON pedido (status, data_pedido);
CREATE INDEX idx_pedido_data ON pedido (data_pedido);

-- ---------------------------------------------------------------------
-- 3. TRIGGERS (regras automaticas do banco)
-- ---------------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER trg_pedido_nasce_orcamento
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN
  IF NEW.status <> 'orcamento' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Todo pedido deve ser criado como orcamento.';
  END IF;
END$$

-- Um unico trigger valida o fluxo e a aprovacao, evitando depender
-- da ordem em que dois triggers BEFORE UPDATE seriam executados.
CREATE TRIGGER trg_pedido_validar_atualizacao
BEFORE UPDATE ON pedido
FOR EACH ROW
BEGIN
  IF NEW.status <> OLD.status THEN
    IF NOT (
         (OLD.status = 'orcamento' AND NEW.status = 'aprovado')
      OR (OLD.status = 'aprovado' AND NEW.status = 'em_producao')
      OR (OLD.status = 'em_producao' AND NEW.status = 'pronto')
      OR (OLD.status = 'pronto' AND NEW.status = 'entregue')
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fluxo invalido. Avance uma etapa por vez e nao volte o status.';
    END IF;
  END IF;

  IF OLD.status = 'orcamento' AND NEW.status = 'aprovado' THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pedido_produto
      WHERE id_pedido = NEW.id_pedido
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pedido sem produtos. Inclua pelo menos um item antes de aprovar.';
    END IF;

    IF EXISTS (
      SELECT 1
      FROM pedido_produto pp
      WHERE pp.id_pedido = NEW.id_pedido
        AND NOT EXISTS (
          SELECT 1
          FROM produto_insumo pi
          WHERE pi.id_produto = pp.id_produto
        )
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Existe produto sem insumo cadastrado. Nao e possivel conferir o estoque.';
    END IF;

    IF EXISTS (
      SELECT 1
      FROM pedido_produto pp
      JOIN produto_insumo pi ON pi.id_produto = pp.id_produto
      JOIN insumo i ON i.id_insumo = pi.id_insumo
      WHERE pp.id_pedido = NEW.id_pedido
        AND i.quantidade_estoque <= 0
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Existe insumo sem estoque. Consulte a view vw_estoque_do_pedido.';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_pedido_so_apaga_orcamento
BEFORE DELETE ON pedido
FOR EACH ROW
BEGIN
  IF OLD.status <> 'orcamento' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Somente pedidos em orcamento podem ser excluidos.';
  END IF;
END$$

CREATE TRIGGER trg_itens_so_em_orcamento_insert
BEFORE INSERT ON pedido_produto
FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(20) DEFAULT NULL;

  SELECT status
    INTO v_status
    FROM pedido
   WHERE id_pedido = NEW.id_pedido;

  IF v_status IS NULL OR v_status <> 'orcamento' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Os itens so podem ser adicionados enquanto o pedido estiver em orcamento.';
  END IF;
END$$

CREATE TRIGGER trg_itens_so_em_orcamento_update
BEFORE UPDATE ON pedido_produto
FOR EACH ROW
BEGIN
  DECLARE v_status_antigo VARCHAR(20) DEFAULT NULL;
  DECLARE v_status_novo VARCHAR(20) DEFAULT NULL;

  SELECT status
    INTO v_status_antigo
    FROM pedido
   WHERE id_pedido = OLD.id_pedido;

  SELECT status
    INTO v_status_novo
    FROM pedido
   WHERE id_pedido = NEW.id_pedido;

  IF v_status_antigo IS NULL OR v_status_antigo <> 'orcamento'
     OR v_status_novo IS NULL OR v_status_novo <> 'orcamento' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Os itens so podem ser alterados enquanto o pedido estiver em orcamento.';
  END IF;
END$$

CREATE TRIGGER trg_itens_so_em_orcamento_delete
BEFORE DELETE ON pedido_produto
FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(20) DEFAULT NULL;

  SELECT status
    INTO v_status
    FROM pedido
   WHERE id_pedido = OLD.id_pedido;

  IF v_status IS NULL OR v_status <> 'orcamento' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Os itens so podem ser removidos enquanto o pedido estiver em orcamento.';
  END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 4. VIEWS (consultas salvas)
-- ---------------------------------------------------------------------

CREATE VIEW vw_pedidos AS
SELECT
  p.id_pedido,
  p.data_pedido,
  p.status,
  p.forma_entrega,
  p.valor_total,
  c.nome AS cliente,
  c.telefone AS telefone_cliente,
  gv.nome AS gerente_vendedor,
  ap.nome AS aprovador
FROM pedido p
JOIN cliente c
  ON c.id_cliente = p.id_cliente
JOIN funcionario gv
  ON gv.id_funcionario = p.id_funcionario_gerente_vendedor
LEFT JOIN funcionario ap
  ON ap.id_funcionario = p.id_funcionario_aprovador;

CREATE VIEW vw_itens_pedido AS
SELECT
  pp.id_pedido,
  c.nome AS cliente,
  p.data_pedido,
  p.status,
  tp.nome AS tipo_produto,
  pr.nome AS produto,
  pp.quantidade_produto
FROM pedido_produto pp
JOIN pedido p
  ON p.id_pedido = pp.id_pedido
JOIN cliente c
  ON c.id_cliente = p.id_cliente
JOIN produto pr
  ON pr.id_produto = pp.id_produto
JOIN tipo_produto tp
  ON tp.id_tipo_produto = pr.id_tipo_produto;

CREATE VIEW vw_estoque_do_pedido AS
SELECT DISTINCT
  pp.id_pedido,
  p.status,
  i.id_insumo,
  i.nome AS insumo,
  f.nome AS fornecedor,
  i.quantidade_estoque,
  CASE
    WHEN i.quantidade_estoque <= 0 THEN 'SEM ESTOQUE'
    ELSE 'DISPONIVEL'
  END AS situacao
FROM pedido_produto pp
JOIN pedido p
  ON p.id_pedido = pp.id_pedido
JOIN produto_insumo pi
  ON pi.id_produto = pp.id_produto
JOIN insumo i
  ON i.id_insumo = pi.id_insumo
JOIN fornecedor f
  ON f.id_fornecedor = i.id_fornecedor;

CREATE VIEW vw_pendencias AS
SELECT
  'Produto sem insumo' AS problema,
  pr.nome AS registro
FROM produto pr
LEFT JOIN produto_insumo pi
  ON pi.id_produto = pr.id_produto
WHERE pi.id_insumo IS NULL

UNION ALL

SELECT
  'Fornecedor sem insumo' AS problema,
  f.nome AS registro
FROM fornecedor f
LEFT JOIN insumo i
  ON i.id_fornecedor = f.id_fornecedor
WHERE i.id_insumo IS NULL

UNION ALL

SELECT
  'Pedido sem item' AS problema,
  CONCAT('Pedido #', p.id_pedido) AS registro
FROM pedido p
LEFT JOIN pedido_produto pp
  ON pp.id_pedido = p.id_pedido
WHERE pp.id_produto IS NULL;

-- ---------------------------------------------------------------------
-- 5. DADOS DE EXEMPLO
-- ---------------------------------------------------------------------

INSERT INTO cliente (id_cliente, nome, telefone) VALUES
  (1, 'Joao Silva', '(11) 90000-0001'),
  (2, 'Maria Oliveira', '(11) 90000-0002'),
  (3, 'Padaria Pao Quente Ltda', '(11) 90000-0003'),
  (4, 'Studio Bella Estetica', '(11) 90000-0004'),
  (5, 'Roberto Lima', '(11) 90000-0005'),
  (6, 'Ana Paula Costa', '(11) 90000-0006');

INSERT INTO funcionario (id_funcionario, nome, cargo) VALUES
  (1, 'Marcos Almeida', 'Gerente'),
  (2, 'Patricia Nogueira', 'Administrativo'),
  (3, 'Renata Souza', 'Administrativo'),
  (4, 'Carlos Souza', 'Operador de máquina'),
  (5, 'Fabio Ramos', 'Operador de máquina'),
  (6, 'Eduardo Pires', 'Expedicionista');

INSERT INTO fornecedor (id_fornecedor, nome, telefone) VALUES
  (1, 'Tintas Paulista Ltda', '(11) 3000-0001'),
  (2, 'Papeis e Bobinas XYZ', '(11) 3000-0002'),
  (3, 'Cliches Rapido', '(11) 3000-0003');

INSERT INTO tipo_produto (id_tipo_produto, nome) VALUES
  (1, 'Adesivo'),
  (2, 'Cartao'),
  (3, 'Etiqueta');

INSERT INTO produto (id_produto, nome, id_tipo_produto) VALUES
  (1, 'Adesivo couche', 1),
  (2, 'Adesivo contracolado', 1),
  (3, 'Cartao de visita', 2),
  (4, 'Etiqueta couche', 3),
  (5, 'Etiqueta contracolado', 3);

INSERT INTO insumo (id_insumo, nome, quantidade_estoque, id_fornecedor) VALUES
  (1, 'Tinta CMYK', 50, 1),
  (2, 'Bobina de papel couche', 3000, 2),
  (3, 'Bobina de papel contracolado', 2000, 2),
  (4, 'Cliche padrao', 12, 3);

INSERT INTO produto_insumo (id_produto, id_insumo) VALUES
  (1, 1), (1, 2), (1, 4),
  (2, 1), (2, 3), (2, 4),
  (3, 1), (3, 2), (3, 4),
  (4, 1), (4, 2), (4, 4),
  (5, 1), (5, 3), (5, 4);

INSERT INTO pedido
  (id_pedido, data_pedido, forma_entrega, id_cliente, id_funcionario_gerente_vendedor)
VALUES
  (1, '2026-10-05', 'entrega', 1, 2),
  (2, '2026-10-14', 'retirada', 3, 3),
  (3, '2026-10-22', 'retirada', 2, 2),
  (4, '2026-10-27', 'entrega', 4, 3),
  (5, '2026-10-28', 'retirada', 5, 2),
  (6, '2026-10-29', 'entrega', 1, 3);

INSERT INTO pedido_produto (id_pedido, id_produto, quantidade_produto) VALUES
  (1, 1, 500), (1, 3, 1000),
  (2, 4, 2000),
  (3, 3, 500),
  (4, 5, 1500), (4, 2, 300),
  (5, 3, 2000),
  (6, 4, 800);

-- Aprova os pedidos que possuem itens e insumos com saldo positivo.
UPDATE pedido
SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 1250.00
WHERE id_pedido = 1;

UPDATE pedido
SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 3400.00
WHERE id_pedido = 2;

UPDATE pedido
SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 780.00
WHERE id_pedido = 3;

UPDATE pedido
SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 2150.00
WHERE id_pedido = 4;

-- Avanca alguns pedidos nas etapas seguintes para demonstracao.
UPDATE pedido SET status = 'em_producao' WHERE id_pedido IN (1, 2, 3);
UPDATE pedido SET status = 'pronto' WHERE id_pedido IN (1, 2);
UPDATE pedido SET status = 'entregue' WHERE id_pedido = 1;

-- ---------------------------------------------------------------------
-- 6. CONSULTAS SELECT (relatorios e verificacoes)
-- ---------------------------------------------------------------------

-- 6.1 Lista geral de pedidos
SELECT
  id_pedido,
  data_pedido,
  cliente,
  telefone_cliente,
  status,
  forma_entrega,
  valor_total,
  gerente_vendedor,
  aprovador
FROM vw_pedidos
ORDER BY data_pedido DESC, id_pedido DESC;

-- 6.2 Produtos de um pedido especifico (exemplo: pedido 4)
SELECT
  p.id_pedido,
  c.nome AS cliente,
  p.status,
  pr.nome AS produto,
  tp.nome AS categoria,
  pp.quantidade_produto AS quantidade_metros
FROM pedido p
JOIN cliente c ON c.id_cliente = p.id_cliente
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto pr ON pr.id_produto = pp.id_produto
JOIN tipo_produto tp ON tp.id_tipo_produto = pr.id_tipo_produto
WHERE p.id_pedido = 4
ORDER BY pr.nome;

-- 6.3 Confere os insumos dos pedidos que ainda estao em orcamento
SELECT
  p.id_pedido,
  c.nome AS cliente,
  COUNT(DISTINCT i.id_insumo) AS total_insumos_cadastrados,
  COUNT(DISTINCT CASE WHEN i.id_insumo IS NOT NULL AND i.quantidade_estoque > 0 THEN i.id_insumo END) AS insumos_com_saldo,
  COUNT(DISTINCT CASE WHEN i.id_insumo IS NOT NULL AND i.quantidade_estoque <= 0 THEN i.id_insumo END) AS insumos_sem_saldo,
  COUNT(DISTINCT CASE WHEN i.id_insumo IS NULL THEN pr.id_produto END) AS produtos_sem_insumo_cadastrado,
  CASE
    WHEN COUNT(DISTINCT CASE WHEN i.id_insumo IS NULL THEN pr.id_produto END) = 0
     AND COUNT(DISTINCT CASE WHEN i.id_insumo IS NOT NULL AND i.quantidade_estoque <= 0 THEN i.id_insumo END) = 0
    THEN 'PODE SEGUIR PARA CONFERENCIA DE APROVACAO'
    ELSE 'RESOLVER PENDENCIAS ANTES DE APROVAR'
  END AS resultado_conferencia
FROM pedido p
JOIN cliente c ON c.id_cliente = p.id_cliente
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto pr ON pr.id_produto = pp.id_produto
LEFT JOIN produto_insumo pi ON pi.id_produto = pr.id_produto
LEFT JOIN insumo i ON i.id_insumo = pi.id_insumo
WHERE p.status = 'orcamento'
GROUP BY p.id_pedido, c.nome
ORDER BY p.id_pedido;

-- 6.4 Detalha estoque e fornecedor dos pedidos em orcamento
SELECT
  p.id_pedido,
  c.nome AS cliente,
  p.data_pedido,
  p.status,
  i.nome AS insumo,
  f.nome AS fornecedor,
  i.quantidade_estoque,
  CASE
    WHEN i.quantidade_estoque <= 0 THEN 'NAO APROVAR: SEM ESTOQUE'
    ELSE 'ESTOQUE DISPONIVEL'
  END AS diagnostico
FROM pedido p
JOIN cliente c ON c.id_cliente = p.id_cliente
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto_insumo pi ON pi.id_produto = pp.id_produto
JOIN insumo i ON i.id_insumo = pi.id_insumo
JOIN fornecedor f ON f.id_fornecedor = i.id_fornecedor
WHERE p.status = 'orcamento'
ORDER BY p.id_pedido, i.nome;

-- 6.5 Lista insumos sem estoque nos pedidos em orcamento
SELECT
  p.id_pedido,
  c.nome AS cliente,
  COUNT(DISTINCT i.id_insumo) AS total_insumos_sem_estoque,
  GROUP_CONCAT(DISTINCT i.nome ORDER BY i.nome SEPARATOR ', ') AS insumos_em_falta
FROM pedido p
JOIN cliente c ON c.id_cliente = p.id_cliente
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto_insumo pi ON pi.id_produto = pp.id_produto
JOIN insumo i ON i.id_insumo = pi.id_insumo
WHERE p.status = 'orcamento'
  AND i.quantidade_estoque <= 0
GROUP BY p.id_pedido, c.nome
ORDER BY p.id_pedido;

-- 6.6 Quantidade e valor de pedidos por status
SELECT
  status,
  COUNT(*) AS quantidade_pedidos,
  COALESCE(SUM(valor_total), 0) AS valor_total_dos_pedidos
FROM pedido
GROUP BY status
ORDER BY FIELD(status, 'orcamento', 'aprovado', 'em_producao', 'pronto', 'entregue');

-- 6.7 Pedidos ainda nao entregues e tempo desde a criacao
SELECT
  p.id_pedido,
  c.nome AS cliente,
  p.data_pedido,
  p.status,
  DATEDIFF(CURRENT_DATE(), p.data_pedido) AS dias_desde_o_pedido,
  p.forma_entrega
FROM pedido p
JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE p.status IN ('orcamento', 'aprovado', 'em_producao', 'pronto')
ORDER BY dias_desde_o_pedido DESC;

-- 6.8 Historico e valor aprovado por cliente
SELECT
  c.id_cliente,
  c.nome AS cliente,
  c.telefone,
  COUNT(p.id_pedido) AS quantidade_pedidos,
  COALESCE(SUM(CASE WHEN p.status <> 'orcamento' THEN p.valor_total ELSE 0 END), 0) AS valor_em_pedidos_aprovados
FROM cliente c
LEFT JOIN pedido p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome, c.telefone
ORDER BY quantidade_pedidos DESC, valor_em_pedidos_aprovados DESC;

-- 6.9 Clientes que ainda nao fizeram pedidos
SELECT
  c.nome AS cliente,
  c.telefone
FROM cliente c
LEFT JOIN pedido p ON p.id_cliente = c.id_cliente
WHERE p.id_pedido IS NULL
ORDER BY c.nome;

-- 6.10 Dez clientes com maior valor em pedidos aprovados
SELECT
  c.nome AS cliente,
  COUNT(p.id_pedido) AS total_pedidos,
  COALESCE(SUM(p.valor_total), 0) AS total_gasto
FROM cliente c
JOIN pedido p ON p.id_cliente = c.id_cliente
WHERE p.status IN ('aprovado', 'em_producao', 'pronto', 'entregue')
GROUP BY c.id_cliente, c.nome
ORDER BY total_gasto DESC
LIMIT 10;

-- 6.11 Produtos mais solicitados
SELECT
  pr.id_produto,
  pr.nome AS produto,
  tp.nome AS categoria,
  COALESCE(SUM(pp.quantidade_produto), 0) AS quantidade_total_solicitada,
  COUNT(DISTINCT pp.id_pedido) AS quantidade_de_pedidos
FROM produto pr
JOIN tipo_produto tp ON tp.id_tipo_produto = pr.id_tipo_produto
LEFT JOIN pedido_produto pp ON pp.id_produto = pr.id_produto
GROUP BY pr.id_produto, pr.nome, tp.nome
ORDER BY quantidade_total_solicitada DESC;

-- 6.12 Pedidos e quantidades por categoria
SELECT
  tp.nome AS categoria,
  COUNT(DISTINCT pr.id_produto) AS total_produtos,
  COUNT(DISTINCT pp.id_pedido) AS total_pedidos,
  COALESCE(SUM(pp.quantidade_produto), 0) AS quantidade_solicitada
FROM tipo_produto tp
LEFT JOIN produto pr ON pr.id_tipo_produto = tp.id_tipo_produto
LEFT JOIN pedido_produto pp ON pp.id_produto = pr.id_produto
GROUP BY tp.id_tipo_produto, tp.nome
ORDER BY total_pedidos DESC;

-- 6.13 Situacao atual dos insumos
SELECT
  i.id_insumo,
  i.nome AS insumo,
  i.quantidade_estoque,
  f.nome AS fornecedor,
  f.telefone AS telefone_fornecedor,
  CASE
    WHEN i.quantidade_estoque <= 0 THEN 'REPOR IMEDIATAMENTE'
    ELSE 'ESTOQUE COM SALDO'
  END AS situacao_estoque
FROM insumo i
JOIN fornecedor f ON f.id_fornecedor = i.id_fornecedor
ORDER BY i.quantidade_estoque ASC, i.nome;

-- 6.14 Quantidade de insumos por fornecedor
SELECT
  f.id_fornecedor,
  f.nome AS fornecedor,
  f.telefone,
  COUNT(i.id_insumo) AS quantidade_de_insumos_fornecidos
FROM fornecedor f
LEFT JOIN insumo i ON i.id_fornecedor = f.id_fornecedor
GROUP BY f.id_fornecedor, f.nome, f.telefone
ORDER BY quantidade_de_insumos_fornecidos DESC;

-- 6.15 Fornecedores sem insumos cadastrados
SELECT
  f.nome AS fornecedor,
  f.telefone
FROM fornecedor f
LEFT JOIN insumo i ON i.id_fornecedor = f.id_fornecedor
WHERE i.id_insumo IS NULL
ORDER BY f.nome;

-- 6.16 Insumos utilizados por produto
SELECT
  pr.nome AS produto,
  tp.nome AS categoria,
  i.nome AS insumo_utilizado,
  i.quantidade_estoque AS estoque_atual,
  f.nome AS fornecedor
FROM produto pr
JOIN tipo_produto tp ON tp.id_tipo_produto = pr.id_tipo_produto
LEFT JOIN produto_insumo pi ON pi.id_produto = pr.id_produto
LEFT JOIN insumo i ON i.id_insumo = pi.id_insumo
LEFT JOIN fornecedor f ON f.id_fornecedor = i.id_fornecedor
ORDER BY pr.nome, i.nome;

-- 6.17 Produtos sem insumos cadastrados
SELECT
  pr.id_produto,
  pr.nome AS produto,
  tp.nome AS categoria
FROM produto pr
JOIN tipo_produto tp ON tp.id_tipo_produto = pr.id_tipo_produto
LEFT JOIN produto_insumo pi ON pi.id_produto = pr.id_produto
WHERE pi.id_insumo IS NULL
ORDER BY pr.nome;

-- 6.18 Pedidos atendidos por vendedor/funcionario
SELECT
  fu.id_funcionario,
  fu.nome AS funcionario,
  fu.cargo,
  COUNT(p.id_pedido) AS pedidos_atendidos,
  COALESCE(SUM(CASE WHEN p.status <> 'orcamento' THEN p.valor_total ELSE 0 END), 0) AS valor_total_dos_pedidos
FROM funcionario fu
LEFT JOIN pedido p
  ON p.id_funcionario_gerente_vendedor = fu.id_funcionario
GROUP BY fu.id_funcionario, fu.nome, fu.cargo
ORDER BY pedidos_atendidos DESC, valor_total_dos_pedidos DESC;

-- 6.19 Pedidos aprovados por funcionario aprovador
SELECT
  fu.nome AS aprovador,
  fu.cargo,
  COUNT(p.id_pedido) AS pedidos_aprovados,
  COALESCE(SUM(p.valor_total), 0) AS valor_aprovado
FROM funcionario fu
LEFT JOIN pedido p
  ON p.id_funcionario_aprovador = fu.id_funcionario
GROUP BY fu.id_funcionario, fu.nome, fu.cargo
ORDER BY pedidos_aprovados DESC;

-- 6.20 Resumo mensal dos pedidos aprovados
SELECT
  DATE_FORMAT(data_pedido, '%Y-%m') AS mes,
  COUNT(*) AS pedidos_aprovados,
  SUM(valor_total) AS faturamento_aprovado,
  AVG(valor_total) AS valor_medio_pedido
FROM pedido
WHERE status IN ('aprovado', 'em_producao', 'pronto', 'entregue')
GROUP BY DATE_FORMAT(data_pedido, '%Y-%m')
ORDER BY mes;

-- 6.21 Pedidos por forma de entrega
SELECT
  forma_entrega,
  COUNT(*) AS quantidade_pedidos,
  COALESCE(SUM(CASE WHEN status <> 'orcamento' THEN valor_total ELSE 0 END), 0) AS valor_total
FROM pedido
GROUP BY forma_entrega;

-- 6.22 Painel geral de pedidos
SELECT
  COUNT(*) AS total_pedidos,
  SUM(CASE WHEN status = 'orcamento' THEN 1 ELSE 0 END) AS em_orcamento,
  SUM(CASE WHEN status = 'aprovado' THEN 1 ELSE 0 END) AS aprovados,
  SUM(CASE WHEN status = 'em_producao' THEN 1 ELSE 0 END) AS em_producao,
  SUM(CASE WHEN status = 'pronto' THEN 1 ELSE 0 END) AS prontos,
  SUM(CASE WHEN status = 'entregue' THEN 1 ELSE 0 END) AS entregues,
  COALESCE(SUM(CASE WHEN status <> 'orcamento' THEN valor_total ELSE 0 END), 0) AS valor_total_aprovado
FROM pedido;

-- 6.23 Pendencias encontradas pelas views
SELECT
  problema,
  registro
FROM vw_pendencias
ORDER BY problema, registro;

-- 6.24 Itens de todos os pedidos
SELECT
  id_pedido,
  cliente,
  data_pedido,
  status,
  tipo_produto,
  produto,
  quantidade_produto
FROM vw_itens_pedido
ORDER BY id_pedido, produto;

-- 6.25 Estoque dos insumos ligados aos pedidos
SELECT
  id_pedido,
  status,
  insumo,
  fornecedor,
  quantidade_estoque,
  situacao
FROM vw_estoque_do_pedido
ORDER BY id_pedido, insumo;

-- 6.26 Ultimo pedido e total de pedidos por cliente
SELECT
  c.nome AS cliente,
  COUNT(DISTINCT p.id_pedido) AS quantidade_pedidos,
  COALESCE(SUM(p.valor_total), 0) AS total_em_pedidos,
  MAX(p.data_pedido) AS data_ultimo_pedido
FROM cliente c
LEFT JOIN pedido p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY data_ultimo_pedido DESC;
