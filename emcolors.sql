-- =====================================================================
--  EMColors · Banco de dados (do DER para o SQL)
--  Motor: SQLite 3  ·  nomes de tabelas e colunas em português, sem acento
--  Este arquivo apaga e recria tudo do zero: pode rodar quantas vezes quiser.
--
--  COMO O DER VIROU TABELAS (a receita)
--    1) cada ENTIDADE              -> uma TABELA
--    2) cada ATRIBUTO              -> uma COLUNA
--    3) identificador (bolinha)    -> PRIMARY KEY
--    4) relacionamento 1:N         -> chave estrangeira (FK) na tabela do lado N
--    5) relacionamento N:N         -> TABELA DE LIGAÇÃO com as duas FKs;
--                                     o atributo do relacionamento vira coluna dela
--    6) mínimo 1 do lado da FK, ex. (1,1)  -> coluna NOT NULL
--    7) mínimo 1 do lado do "n", ex. (1,n) -> o SQL não consegue exigir na criação
--       (o pai nasce antes dos filhos); por isso é conferido na APROVAÇÃO do
--       pedido (triggers) e na view vw_pendencias.
--
--  RELACIONAMENTO DO DER                     ONDE FICOU NO SQL
--    realiza     cliente 1:N pedido           pedido.id_cliente
--    atende      funcionario 1:N pedido       pedido.id_funcionario_gerente_vendedor
--                (losango único no DER)       pedido.id_funcionario_aprovador
--    contém      pedido N:N produto           tabela pedido_produto (+ quantidade_produto)
--    classifica  tipo_produto 1:N produto     produto.id_tipo_produto
--    gera        produto N:N insumo           tabela produto_insumo
--    fornece     fornecedor 1:N insumo        insumo.id_fornecedor
--
--  CONFIRA COM O GRUPO (README x DER). Aqui segui o DER (a imagem):
--    * O README cita operador/expedicionista no pedido, Item_Pedido, Tipo_Papel,
--      quantidade_metros, prazo_entrega e fornecedor.tipo_insumo.
--      Nada disso existe no DER atual, então não está no banco.
--    * O DER não tem preço por produto: valor_total é informado na aprovação
--      (o banco não tem como calcular a soma dos itens).
--    * tipo_produto está sem atributos no DER: criei id_tipo_produto e nome.
--    * quantidade_produto e quantidade_estoque não têm unidade no DER
--      (o README usa metros para a quantidade do pedido).
-- =====================================================================

PRAGMA foreign_keys = ON;   -- SQLite só confere chaves estrangeiras com isto ligado (vale por conexão)


-- ---------------------------------------------------------------------
-- PASSO 0 · LIMPAR (filhos primeiro, pais depois)
-- ---------------------------------------------------------------------
DROP VIEW  IF EXISTS vw_pendencias;
DROP VIEW  IF EXISTS vw_estoque_do_pedido;
DROP VIEW  IF EXISTS vw_itens_pedido;
DROP VIEW  IF EXISTS vw_pedidos;
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
-- PASSO 1 · TABELAS INDEPENDENTES (não dependem de nenhuma outra)
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
  id_cliente INTEGER PRIMARY KEY,
  nome       TEXT NOT NULL CHECK (length(trim(nome)) > 0),
  telefone   TEXT NOT NULL CHECK (length(trim(telefone)) > 0)
);

CREATE TABLE funcionario (
  id_funcionario INTEGER PRIMARY KEY,
  nome   TEXT NOT NULL CHECK (length(trim(nome)) > 0),
  -- cargos da equipe descrita no README (se surgir outro cargo, acrescente aqui)
  cargo  TEXT NOT NULL CONSTRAINT ck_funcionario_cargo
         CHECK (cargo IN ('Gerente', 'Administrativo', 'Operador de máquina', 'Expedicionista'))
);

CREATE TABLE fornecedor (
  id_fornecedor INTEGER PRIMARY KEY,
  nome     TEXT NOT NULL CHECK (length(trim(nome)) > 0),
  telefone TEXT NOT NULL CHECK (length(trim(telefone)) > 0)
);

CREATE TABLE tipo_produto (
  id_tipo_produto INTEGER PRIMARY KEY,
  nome TEXT NOT NULL UNIQUE COLLATE NOCASE CHECK (length(trim(nome)) > 0)
);


-- ---------------------------------------------------------------------
-- PASSO 2 · TABELAS QUE TÊM FK PARA AS DE CIMA
-- ---------------------------------------------------------------------
CREATE TABLE produto (
  id_produto      INTEGER PRIMARY KEY,
  nome            TEXT NOT NULL UNIQUE COLLATE NOCASE CHECK (length(trim(nome)) > 0),
  id_tipo_produto INTEGER NOT NULL,                       -- classifica: produto (1,1)
  FOREIGN KEY (id_tipo_produto) REFERENCES tipo_produto (id_tipo_produto) ON DELETE RESTRICT
);

CREATE TABLE insumo (
  id_insumo          INTEGER PRIMARY KEY,
  nome               TEXT NOT NULL UNIQUE COLLATE NOCASE CHECK (length(trim(nome)) > 0),
  quantidade_estoque NUMERIC(12,2) NOT NULL DEFAULT 0
                     CONSTRAINT ck_estoque_nao_negativo
                     CHECK (typeof(quantidade_estoque) IN ('integer', 'real') AND quantidade_estoque >= 0),
  id_fornecedor      INTEGER NOT NULL,                    -- fornece: insumo (1,1)
  FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor) ON DELETE RESTRICT
);

CREATE TABLE pedido (
  id_pedido     INTEGER PRIMARY KEY,
  data_pedido   TEXT NOT NULL DEFAULT (date('now'))
                CONSTRAINT ck_pedido_data                                          -- só aceita AAAA-MM-DD válido
                CHECK (date(data_pedido) IS NOT NULL AND data_pedido = date(data_pedido)),
  forma_entrega TEXT NOT NULL
                CONSTRAINT ck_pedido_forma_entrega CHECK (forma_entrega IN ('entrega', 'retirada')),
  status        TEXT NOT NULL DEFAULT 'orcamento'
                CONSTRAINT ck_pedido_status
                CHECK (status IN ('orcamento', 'aprovado', 'em_producao', 'pronto', 'entregue')),
  valor_total   NUMERIC(12,2)
                CONSTRAINT ck_pedido_valor
                CHECK (valor_total IS NULL OR (typeof(valor_total) IN ('integer', 'real') AND valor_total >= 0)),
  id_cliente                      INTEGER NOT NULL,       -- realiza: pedido (1,1)
  id_funcionario_gerente_vendedor INTEGER NOT NULL,       -- atende:  pedido (1,1)
  id_funcionario_aprovador        INTEGER,                -- só existe depois da aprovação
  FOREIGN KEY (id_cliente)                      REFERENCES cliente     (id_cliente)     ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario_gerente_vendedor) REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario_aprovador)        REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT,
  -- README: a aprovação acontece junto com o pagamento (valor registrado na aprovação)
  CONSTRAINT ck_aprovado_exige_aprovador_e_valor
    CHECK (status = 'orcamento' OR (id_funcionario_aprovador IS NOT NULL AND valor_total IS NOT NULL))
);


-- ---------------------------------------------------------------------
-- PASSO 3 · TABELAS DE LIGAÇÃO (relacionamentos N:N do DER)
-- ---------------------------------------------------------------------
-- "contém": pedido (1,n) <-> produto (0,n), com o atributo quantidade_produto
CREATE TABLE pedido_produto (
  id_pedido          INTEGER NOT NULL,
  id_produto         INTEGER NOT NULL,
  quantidade_produto NUMERIC(10,2) NOT NULL                -- em metros (README)
                     CONSTRAINT ck_quantidade_positiva
                     CHECK (typeof(quantidade_produto) IN ('integer', 'real') AND quantidade_produto > 0),
  PRIMARY KEY (id_pedido, id_produto),                     -- o mesmo produto não repete no mesmo pedido
  FOREIGN KEY (id_pedido)  REFERENCES pedido  (id_pedido)  ON DELETE RESTRICT,
  FOREIGN KEY (id_produto) REFERENCES produto (id_produto) ON DELETE RESTRICT
);

-- "gera": produto (1,n) <-> insumo (0,n)  (quais insumos cada produto usa)
CREATE TABLE produto_insumo (
  id_produto INTEGER NOT NULL,
  id_insumo  INTEGER NOT NULL,
  PRIMARY KEY (id_produto, id_insumo),
  FOREIGN KEY (id_produto) REFERENCES produto (id_produto) ON DELETE RESTRICT,
  FOREIGN KEY (id_insumo)  REFERENCES insumo  (id_insumo)  ON DELETE RESTRICT
);

-- Índices nas FKs (consultas e conferências de integridade ficam rápidas)
CREATE INDEX idx_pedido_cliente        ON pedido (id_cliente);
CREATE INDEX idx_pedido_gerente        ON pedido (id_funcionario_gerente_vendedor);
CREATE INDEX idx_pedido_aprovador      ON pedido (id_funcionario_aprovador);
CREATE INDEX idx_pedido_status         ON pedido (status);
CREATE INDEX idx_produto_tipo          ON produto (id_tipo_produto);
CREATE INDEX idx_insumo_fornecedor     ON insumo (id_fornecedor);
CREATE INDEX idx_pedido_produto_prod   ON pedido_produto (id_produto);
CREATE INDEX idx_produto_insumo_insumo ON produto_insumo (id_insumo);


-- ---------------------------------------------------------------------
-- PASSO 4 · REGRAS DO NEGÓCIO (triggers = o banco recusa o que não faz sentido)
-- ---------------------------------------------------------------------
-- 4.1 Todo pedido nasce como orçamento (README: o processo começa pelo orçamento)
CREATE TRIGGER trg_pedido_nasce_orcamento
BEFORE INSERT ON pedido
FOR EACH ROW
WHEN NEW.status <> 'orcamento'
BEGIN
  SELECT RAISE(ABORT, 'Todo pedido nasce como orcamento: avance o status depois, uma etapa por vez');
END;

-- 4.2 O status só anda para frente, uma etapa por vez
CREATE TRIGGER trg_pedido_fluxo_status
BEFORE UPDATE OF status ON pedido
FOR EACH ROW
WHEN NEW.status <> OLD.status
BEGIN
  SELECT RAISE(ABORT, 'Fluxo inválido: orcamento > aprovado > em_producao > pronto > entregue (uma etapa por vez, sem voltar)')
  WHERE NOT (   (OLD.status = 'orcamento'   AND NEW.status = 'aprovado')
             OR (OLD.status = 'aprovado'    AND NEW.status = 'em_producao')
             OR (OLD.status = 'em_producao' AND NEW.status = 'pronto')
             OR (OLD.status = 'pronto'      AND NEW.status = 'entregue'));
END;

-- 4.3 Para aprovar: ter itens (1,n), cada produto ter insumo (1,n) e nenhum insumo zerado
--     (README: hoje ninguém confere o estoque antes de fechar o pedido)
CREATE TRIGGER trg_pedido_aprovar
BEFORE UPDATE OF status ON pedido
FOR EACH ROW
WHEN OLD.status = 'orcamento' AND NEW.status = 'aprovado'
BEGIN
  SELECT RAISE(ABORT, 'Pedido sem itens: inclua pelo menos 1 produto antes de aprovar')
  WHERE NOT EXISTS (SELECT 1 FROM pedido_produto WHERE id_pedido = NEW.id_pedido);

  SELECT RAISE(ABORT, 'Há produto sem insumo cadastrado em produto_insumo: não dá para conferir o estoque')
  WHERE EXISTS (SELECT 1
                FROM pedido_produto pp
                WHERE pp.id_pedido = NEW.id_pedido
                  AND NOT EXISTS (SELECT 1 FROM produto_insumo li WHERE li.id_produto = pp.id_produto));

  SELECT RAISE(ABORT, 'Estoque zerado: algum insumo deste pedido está sem saldo (veja vw_estoque_do_pedido)')
  WHERE EXISTS (SELECT 1
                FROM pedido_produto pp
                JOIN produto_insumo li ON li.id_produto = pp.id_produto
                JOIN insumo i          ON i.id_insumo   = li.id_insumo
                WHERE pp.id_pedido = NEW.id_pedido
                  AND i.quantidade_estoque <= 0);
END;

-- 4.4 Só orçamento pode ser apagado (pedido aprovado em diante é histórico)
CREATE TRIGGER trg_pedido_so_apaga_orcamento
BEFORE DELETE ON pedido
FOR EACH ROW
WHEN OLD.status <> 'orcamento'
BEGIN
  SELECT RAISE(ABORT, 'Só é possível excluir pedido em orcamento: o histórico dos demais é mantido');
END;

-- 4.5 Os itens só mudam enquanto o pedido ainda é orçamento
CREATE TRIGGER trg_itens_so_em_orcamento_insert
BEFORE INSERT ON pedido_produto
FOR EACH ROW
WHEN (SELECT status FROM pedido WHERE id_pedido = NEW.id_pedido) <> 'orcamento'
BEGIN
  SELECT RAISE(ABORT, 'Os itens só podem mudar enquanto o pedido está em orçamento');
END;

CREATE TRIGGER trg_itens_so_em_orcamento_update
BEFORE UPDATE ON pedido_produto
FOR EACH ROW
WHEN (SELECT status FROM pedido WHERE id_pedido = OLD.id_pedido) <> 'orcamento'
  OR (SELECT status FROM pedido WHERE id_pedido = NEW.id_pedido) <> 'orcamento'
BEGIN
  SELECT RAISE(ABORT, 'Os itens só podem mudar enquanto o pedido está em orçamento');
END;

CREATE TRIGGER trg_itens_so_em_orcamento_delete
BEFORE DELETE ON pedido_produto
FOR EACH ROW
WHEN (SELECT status FROM pedido WHERE id_pedido = OLD.id_pedido) <> 'orcamento'
BEGIN
  SELECT RAISE(ABORT, 'Os itens só podem mudar enquanto o pedido está em orçamento');
END;


-- ---------------------------------------------------------------------
-- PASSO 5 · CONSULTAS PRONTAS (views: juntam as tabelas para você só ler)
-- ---------------------------------------------------------------------
-- Um pedido por linha, já com cliente e funcionários (em vez de só números de id)
CREATE VIEW vw_pedidos AS
SELECT p.id_pedido,
       p.data_pedido,
       p.status,
       p.forma_entrega,
       p.valor_total,
       c.nome     AS cliente,
       c.telefone AS telefone_cliente,
       gv.nome    AS gerente_vendedor,
       ap.nome    AS aprovador
FROM pedido p
JOIN cliente     c  ON c.id_cliente      = p.id_cliente
JOIN funcionario gv ON gv.id_funcionario = p.id_funcionario_gerente_vendedor
LEFT JOIN funcionario ap ON ap.id_funcionario = p.id_funcionario_aprovador;

-- Um item por linha: o que cada pedido contém
CREATE VIEW vw_itens_pedido AS
SELECT pp.id_pedido,
       c.nome  AS cliente,
       p.status,
       tp.nome AS tipo,
       pr.nome AS produto,
       pp.quantidade_produto
FROM pedido_produto pp
JOIN pedido       p  ON p.id_pedido        = pp.id_pedido
JOIN cliente      c  ON c.id_cliente       = p.id_cliente
JOIN produto      pr ON pr.id_produto      = pp.id_produto
JOIN tipo_produto tp ON tp.id_tipo_produto = pr.id_tipo_produto;

-- README: "consultar a quantidade disponível de insumo antes de fechar o pedido"
CREATE VIEW vw_estoque_do_pedido AS
SELECT DISTINCT
       pp.id_pedido,
       p.status,
       i.nome AS insumo,
       f.nome AS fornecedor,
       i.quantidade_estoque,
       CASE WHEN i.quantidade_estoque > 0 THEN 'OK' ELSE 'SEM ESTOQUE' END AS situacao
FROM pedido_produto pp
JOIN pedido         p  ON p.id_pedido     = pp.id_pedido
JOIN produto_insumo li ON li.id_produto   = pp.id_produto
JOIN insumo         i  ON i.id_insumo     = li.id_insumo
JOIN fornecedor     f  ON f.id_fornecedor = i.id_fornecedor;

-- Cardinalidades mínimas (1,n) que o SQL não exige sozinho. Vazio = tudo certo.
CREATE VIEW vw_pendencias AS
SELECT 'Produto sem insumo' AS problema, nome AS registro
  FROM produto WHERE id_produto NOT IN (SELECT id_produto FROM produto_insumo)
UNION ALL
SELECT 'Fornecedor sem insumo', nome
  FROM fornecedor WHERE id_fornecedor NOT IN (SELECT id_fornecedor FROM insumo)
UNION ALL
SELECT 'Pedido sem item', 'Pedido #' || id_pedido
  FROM pedido WHERE id_pedido NOT IN (SELECT id_pedido FROM pedido_produto);


-- ---------------------------------------------------------------------
-- PASSO 6 · DADOS DE EXEMPLO (fictícios, só para testar; troque pelos reais)
--   A carga passa pelas mesmas regras do PASSO 4: se rodar sem erro, as regras
--   permitem o caminho certo (orçamento > aprovado > produção > pronto > entregue).
-- ---------------------------------------------------------------------
INSERT INTO cliente (id_cliente, nome, telefone) VALUES
  (1, 'João Silva',              '(11) 90000-0001'),
  (2, 'Maria Oliveira',          '(11) 90000-0002'),
  (3, 'Padaria Pão Quente Ltda', '(11) 90000-0003'),
  (4, 'Studio Bella Estética',   '(11) 90000-0004'),
  (5, 'Roberto Lima',            '(11) 90000-0005'),
  (6, 'Ana Paula Costa',         '(11) 90000-0006');   -- ainda sem pedidos: cliente (0,n)

INSERT INTO funcionario (id_funcionario, nome, cargo) VALUES
  (1, 'Marcos Almeida',  'Gerente'),
  (2, 'Patrícia Nogueira', 'Administrativo'),
  (3, 'Renata Souza',    'Administrativo'),
  (4, 'Carlos Souza',    'Operador de máquina'),
  (5, 'Fábio Ramos',     'Operador de máquina'),
  (6, 'Eduardo Pires',   'Expedicionista');

INSERT INTO fornecedor (id_fornecedor, nome, telefone) VALUES
  (1, 'Tintas Paulista Ltda',  '(11) 3000-0001'),
  (2, 'Papéis e Bobinas XYZ',  '(11) 3000-0002'),
  (3, 'Clichês Rápido',        '(11) 3000-0003');

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

-- quais insumos cada produto usa ("gera")
INSERT INTO produto_insumo (id_produto, id_insumo) VALUES
  (1, 1), (1, 2), (1, 4),     -- Adesivo couché        : tinta + bobina couché + clichê
  (2, 1), (2, 3), (2, 4),     -- Adesivo contracolado  : tinta + bobina contracolado + clichê
  (3, 1), (3, 2), (3, 4),     -- Cartão de visita
  (4, 1), (4, 2), (4, 4),     -- Etiqueta couché
  (5, 1), (5, 3), (5, 4);     -- Etiqueta contracolado

-- 6 pedidos nascem como orçamento...
INSERT INTO pedido (id_pedido, data_pedido, forma_entrega, id_cliente, id_funcionario_gerente_vendedor) VALUES
  (1, '2026-10-05', 'entrega',  1, 2),
  (2, '2026-10-14', 'retirada', 3, 3),
  (3, '2026-10-22', 'retirada', 2, 2),
  (4, '2026-10-27', 'entrega',  4, 3),
  (5, '2026-10-28', 'retirada', 5, 2),
  (6, '2026-10-29', 'entrega',  1, 3);

-- ...recebem itens (quantidade em metros)...
INSERT INTO pedido_produto (id_pedido, id_produto, quantidade_produto) VALUES
  (1, 1,  500), (1, 3, 1000),
  (2, 4, 2000),
  (3, 3,  500),
  (4, 5, 1500), (4, 2,  300),
  (5, 3, 2000),
  (6, 4,  800);

-- ...e os pedidos 1 a 4 são aprovados (aprovador + valor pago + status no mesmo UPDATE)
UPDATE pedido SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 1250.00 WHERE id_pedido = 1;
UPDATE pedido SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 3400.00 WHERE id_pedido = 2;
UPDATE pedido SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total =  780.00 WHERE id_pedido = 3;
UPDATE pedido SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 2150.00 WHERE id_pedido = 4;
-- avançam as etapas, uma de cada vez
UPDATE pedido SET status = 'em_producao' WHERE id_pedido IN (1, 2, 3);
UPDATE pedido SET status = 'pronto'      WHERE id_pedido IN (1, 2);
UPDATE pedido SET status = 'entregue'    WHERE id_pedido = 1;
-- resultado: 1 entregue · 2 pronto · 3 em produção · 4 aprovado · 5 e 6 ainda orçamento


-- ---------------------------------------------------------------------
-- PASSO 7A · CONSULTAS DE DEMONSTRAÇÃO (selecione uma e execute só a seleção)
-- ---------------------------------------------------------------------
-- Todos os pedidos, com cliente e funcionários
SELECT * FROM vw_pedidos ORDER BY id_pedido;

-- O que o pedido 4 contém
SELECT * FROM vw_itens_pedido WHERE id_pedido = 4;

-- Antes de aprovar o pedido 5: os insumos dele têm saldo?
SELECT * FROM vw_estoque_do_pedido WHERE id_pedido = 5;

-- Histórico por cliente (o README diz que hoje a gráfica não tem isso)
SELECT c.nome AS cliente,
       COUNT(p.id_pedido)           AS pedidos,
       COALESCE(SUM(p.valor_total), 0) AS total_aprovado
FROM cliente c
LEFT JOIN pedido p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente
ORDER BY total_aprovado DESC;

-- Estoque atual de cada insumo, com o fornecedor
SELECT i.nome AS insumo, i.quantidade_estoque, f.nome AS fornecedor
FROM insumo i JOIN fornecedor f ON f.id_fornecedor = i.id_fornecedor
ORDER BY i.quantidade_estoque;

-- Pendências de cardinalidade mínima (deve vir vazio)
SELECT * FROM vw_pendencias;

-- Registrar a entrada de insumo (chegou mercadoria do fornecedor): some ao saldo
--   UPDATE insumo SET quantidade_estoque = quantidade_estoque + 20 WHERE id_insumo = 1;


-- ---------------------------------------------------------------------
-- PASSO 7B · TESTES: cada comando abaixo DEVE DAR ERRO (é o banco defendendo a lógica)
--   Como usar: tire o "-- " do começo da linha, execute SÓ essa linha e leia o erro.
--   Se algum teste mexer nos dados, rode o script inteiro de novo para recriar o banco.
-- ---------------------------------------------------------------------
-- T1  pedido de um cliente que não existe:
--   INSERT INTO pedido (forma_entrega, id_cliente, id_funcionario_gerente_vendedor) VALUES ('entrega', 999, 2);
-- T2  status fora da lista:
--   UPDATE pedido SET status = 'finalizado' WHERE id_pedido = 5;
-- T3  pular etapa (orçamento direto para pronto):
--   UPDATE pedido SET status = 'pronto' WHERE id_pedido = 5;
-- T4  voltar etapa (em produção volta para aprovado):
--   UPDATE pedido SET status = 'aprovado' WHERE id_pedido = 3;
-- T5  aprovar sem aprovador e sem valor:
--   UPDATE pedido SET status = 'aprovado' WHERE id_pedido = 5;
-- T6  aprovar pedido sem nenhum item (rode uma linha de cada vez; 7 = pedido recém-criado):
--   INSERT INTO pedido (forma_entrega, id_cliente, id_funcionario_gerente_vendedor) VALUES ('retirada', 6, 2);
--   UPDATE pedido SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 100 WHERE id_pedido = 7;
-- T7  aprovar com insumo zerado (rode as 3 linhas, uma de cada vez; a 3ª devolve o estoque):
--   UPDATE insumo SET quantidade_estoque = 0 WHERE id_insumo = 1;
--   UPDATE pedido SET status = 'aprovado', id_funcionario_aprovador = 1, valor_total = 500 WHERE id_pedido = 5;
--   UPDATE insumo SET quantidade_estoque = 50 WHERE id_insumo = 1;
-- T8  mexer nos itens de um pedido já aprovado:
--   INSERT INTO pedido_produto (id_pedido, id_produto, quantidade_produto) VALUES (4, 1, 100);
-- T9  apagar pedido que já passou de orçamento:
--   DELETE FROM pedido WHERE id_pedido = 1;
-- T10 apagar cliente que tem pedidos:
--   DELETE FROM cliente WHERE id_cliente = 1;
-- T11 quantidade negativa:
--   INSERT INTO pedido_produto (id_pedido, id_produto, quantidade_produto) VALUES (5, 1, -10);
-- T12 mesmo produto duas vezes no mesmo pedido:
--   INSERT INTO pedido_produto (id_pedido, id_produto, quantidade_produto) VALUES (5, 3, 100);
-- T13 pedido já nascendo "entregue":
--   INSERT INTO pedido (forma_entrega, status, id_cliente, id_funcionario_gerente_vendedor) VALUES ('entrega', 'entregue', 1, 2);
-- T14 estoque negativo:
--   UPDATE insumo SET quantidade_estoque = -5 WHERE id_insumo = 1;
