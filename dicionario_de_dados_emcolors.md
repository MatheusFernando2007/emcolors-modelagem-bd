# Dicionário de Dados: EMColors

Banco: `emcolors` | SGBD: MySQL 8 | Engine: InnoDB | Charset: `utf8mb4` / `utf8mb4_unicode_ci`

---

### Cliente (`cliente`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_cliente` | `INT`, PK, NOT NULL, auto incremento | Código exclusivo que representa o cliente dentro do sistema, usado para diferenciá-lo dos demais mesmo que tenham nome ou telefone parecidos | Obrigatório; gerado automaticamente |
| `nome` | `VARCHAR(150)`, NOT NULL, CHECK (`CHAR_LENGTH(TRIM(nome)) > 0`) | Nome da pessoa ou empresa que faz o pedido, usado no atendimento e no contato direto (ex: "Joao Silva", "Padaria Pao Quente Ltda") | Obrigatório; não pode ser vazio nem conter apenas espaços |
| `telefone` | `VARCHAR(30)`, NOT NULL, CHECK (`CHAR_LENGTH(TRIM(telefone)) > 0`) | Número de contato do cliente, usado para avisar sobre o andamento do pedido, como quando fica pronto para retirada (ex: "(11) 90000-0001") | Obrigatório; não pode ser vazio nem conter apenas espaços |

---

### Funcionário (`funcionario`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_funcionario` | `INT`, PK, NOT NULL, auto incremento | Código exclusivo do funcionário, usado para identificá-lo como vendedor ou aprovador de pedidos | Obrigatório; gerado automaticamente |
| `nome` | `VARCHAR(150)`, NOT NULL, CHECK (`CHAR_LENGTH(TRIM(nome)) > 0`) | Nome completo do funcionário (ex: "Marcos Almeida") | Obrigatório; não pode ser vazio nem conter apenas espaços |
| `cargo` | `VARCHAR(40)`, NOT NULL, CHECK (`cargo IN ('Gerente', 'Administrativo', 'Operador de máquina', 'Expedicionista')`) | Função que o funcionário exerce na gráfica, definindo o papel dele na operação | Obrigatório; aceita somente os quatro cargos listados |

---

### Fornecedor (`fornecedor`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_fornecedor` | `INT`, PK, NOT NULL, auto incremento | Código exclusivo do fornecedor, usado para ligar cada insumo à empresa que o fornece | Obrigatório; gerado automaticamente |
| `nome` | `VARCHAR(150)`, NOT NULL, CHECK (`CHAR_LENGTH(TRIM(nome)) > 0`) | Nome da empresa que fornece insumos à gráfica (ex: "Tintas Paulista Ltda") | Obrigatório; não pode ser vazio nem conter apenas espaços |
| `telefone` | `VARCHAR(30)`, NOT NULL, CHECK (`CHAR_LENGTH(TRIM(telefone)) > 0`) | Telefone de contato do fornecedor, usado para pedir reposição de estoque (ex: "(11) 3000-0001") | Obrigatório; não pode ser vazio nem conter apenas espaços |

---

### Tipo de Produto (`tipo_produto`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_tipo_produto` | `INT`, PK, NOT NULL, auto incremento | Código exclusivo da categoria de produto | Obrigatório; gerado automaticamente |
| `nome` | `VARCHAR(100)`, NOT NULL, UNIQUE (`uq_tipo_produto_nome`), CHECK (`CHAR_LENGTH(TRIM(nome)) > 0`) | Nome da categoria que agrupa produtos semelhantes (ex: "Adesivo", "Cartao", "Etiqueta") | Obrigatório; não pode se repetir nem ser vazio |

---

### Produto (`produto`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_produto` | `INT`, PK, NOT NULL, auto incremento | Código exclusivo do produto que a gráfica fabrica e vende | Obrigatório; gerado automaticamente |
| `nome` | `VARCHAR(150)`, NOT NULL, UNIQUE (`uq_produto_nome`), CHECK (`CHAR_LENGTH(TRIM(nome)) > 0`) | Nome do produto como aparece no catálogo e nos pedidos (ex: "Adesivo couche", "Etiqueta contracolado") | Obrigatório; não pode se repetir nem ser vazio |
| `id_tipo_produto` | `INT`, NOT NULL, FK → `tipo_produto(id_tipo_produto)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Categoria à qual o produto pertence | Obrigatório; todo produto tem exatamente um tipo; não é possível excluir um tipo que tenha produtos; se o código do tipo mudar, o produto acompanha |

---

### Insumo (`insumo`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_insumo` | `INT`, PK, NOT NULL, auto incremento | Código exclusivo do insumo (matéria-prima usada na produção) | Obrigatório; gerado automaticamente |
| `nome` | `VARCHAR(150)`, NOT NULL, UNIQUE (`uq_insumo_nome`), CHECK (`CHAR_LENGTH(TRIM(nome)) > 0`) | Nome da matéria-prima usada na fabricação dos produtos (ex: "Tinta CMYK", "Bobina de papel couche") | Obrigatório; não pode se repetir nem ser vazio |
| `quantidade_estoque` | `DECIMAL(12,2)`, NOT NULL, DEFAULT 0, CHECK (`quantidade_estoque >= 0`) | Quantidade atual disponível do insumo no estoque, usada para decidir se um pedido pode ser aprovado | Obrigatório; assume 0 se não informado; nunca pode ser negativo; insumo com estoque 0 impede a aprovação de pedidos que o utilizem |
| `id_fornecedor` | `INT`, NOT NULL, FK → `fornecedor(id_fornecedor)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Fornecedor responsável por fornecer aquele insumo | Obrigatório; cada insumo tem um único fornecedor; não é possível excluir um fornecedor que tenha insumos |

---

### Pedido (`pedido`)

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_pedido` | `INT`, PK, NOT NULL, auto incremento | Número exclusivo do pedido, usado para acompanhá-lo em todas as etapas | Obrigatório; gerado automaticamente |
| `data_pedido` | `DATE`, NOT NULL | Data em que o pedido (orçamento) foi registrado (ex: "2026-10-05") | Obrigatório |
| `forma_entrega` | `VARCHAR(20)`, NOT NULL, CHECK (`forma_entrega IN ('entrega', 'retirada')`) | Define se o pedido será levado ao cliente ou retirado por ele na gráfica | Obrigatório; aceita somente `entrega` ou `retirada` |
| `status` | `VARCHAR(20)`, NOT NULL, DEFAULT `'orcamento'`, CHECK (`status IN ('orcamento', 'aprovado', 'em_producao', 'pronto', 'entregue')`) | Etapa em que o pedido se encontra no fluxo da gráfica | Obrigatório; todo pedido nasce como `orcamento` (trigger `trg_pedido_nasce_orcamento`); só avança uma etapa por vez, sem voltar (`orcamento` → `aprovado` → `em_producao` → `pronto` → `entregue`); só pode ser excluído enquanto for `orcamento` |
| `valor_total` | `DECIMAL(12,2)`, NULL, CHECK (`valor_total IS NULL OR valor_total >= 0`) | Valor final cobrado do cliente, definido no momento da aprovação (ex: 1250.00) | Opcional em `orcamento`; obrigatório em qualquer status diferente de `orcamento`; não pode ser negativo |
| `id_cliente` | `INT`, NOT NULL, FK → `cliente(id_cliente)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Cliente que solicitou o pedido | Obrigatório; não é possível excluir um cliente que tenha pedidos |
| `id_funcionario_gerente_vendedor` | `INT`, NOT NULL, FK → `funcionario(id_funcionario)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Funcionário que atendeu o cliente e registrou o pedido | Obrigatório; não é possível excluir um funcionário que tenha pedidos atendidos |
| `id_funcionario_aprovador` | `INT`, NULL, FK → `funcionario(id_funcionario)`, `ON DELETE RESTRICT`, `ON UPDATE RESTRICT` | Funcionário que aprovou o orçamento, transformando-o em pedido | Nulo enquanto o pedido está em `orcamento`; obrigatório a partir de `aprovado` (CHECK `ck_aprovado_exige_aprovador_e_valor`); usa `ON UPDATE RESTRICT` porque, no MySQL 8, colunas usadas em CHECK não aceitam `ON UPDATE CASCADE` (erro 3823) |

**Regras adicionais de aprovação** (trigger `trg_pedido_validar_atualizacao`): para passar de `orcamento` para `aprovado`, o pedido precisa ter ao menos um item, todos os produtos precisam ter insumos cadastrados e nenhum insumo envolvido pode estar com estoque menor ou igual a zero.

**Índices:** `idx_pedido_status_data` (`status`, `data_pedido`) e `idx_pedido_data` (`data_pedido`), usados em filtros e ordenações frequentes.

---

### Itens do Pedido (`pedido_produto`)

Tabela associativa que resolve o relacionamento N:N entre pedido e produto.

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_pedido` | `INT`, NOT NULL, PK (composta), FK → `pedido(id_pedido)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Pedido ao qual o item pertence | Obrigatório; itens só podem ser inseridos, alterados ou removidos enquanto o pedido estiver em `orcamento` (triggers `trg_itens_so_em_orcamento_*`) |
| `id_produto` | `INT`, NOT NULL, PK (composta), FK → `produto(id_produto)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Produto solicitado naquele pedido | Obrigatório; o mesmo produto não pode aparecer duas vezes no mesmo pedido (chave composta) |
| `quantidade_produto` | `DECIMAL(10,2)`, NOT NULL, CHECK (`quantidade_produto > 0`) | Quantidade solicitada do produto, em metros (ex: 500, 2000) | Obrigatório; deve ser maior que zero |

---

### Insumos do Produto (`produto_insumo`)

Tabela associativa que resolve o relacionamento N:N entre produto e insumo (a "receita" de cada produto).

| Atributo | Tipo e restrições | Descrição | Regra de negócio associada |
|---|---|---|---|
| `id_produto` | `INT`, NOT NULL, PK (composta), FK → `produto(id_produto)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Produto que utiliza o insumo | Obrigatório; não é possível excluir um produto que tenha insumos vinculados |
| `id_insumo` | `INT`, NOT NULL, PK (composta), FK → `insumo(id_insumo)`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE` | Insumo necessário para fabricar o produto | Obrigatório; o mesmo insumo não se repete no mesmo produto; um produto sem insumo cadastrado impede a aprovação do pedido |

---

## Resumo dos relacionamentos

| Tabela pai | Tabela filha | Cardinalidade | Chave estrangeira |
|---|---|---|---|
| `tipo_produto` | `produto` | 1:N | `produto.id_tipo_produto` |
| `fornecedor` | `insumo` | 1:N | `insumo.id_fornecedor` |
| `cliente` | `pedido` | 1:N | `pedido.id_cliente` |
| `funcionario` | `pedido` (vendedor) | 1:N | `pedido.id_funcionario_gerente_vendedor` |
| `funcionario` | `pedido` (aprovador) | 1:N | `pedido.id_funcionario_aprovador` |
| `pedido` ↔ `produto` | `pedido_produto` | N:N | `id_pedido`, `id_produto` |
| `produto` ↔ `insumo` | `produto_insumo` | N:N | `id_produto`, `id_insumo` |

## Objetos auxiliares do banco

| Objeto | Tipo | Finalidade |
|---|---|---|
| `trg_pedido_nasce_orcamento` | Trigger (BEFORE INSERT em `pedido`) | Impede criar pedido com status diferente de `orcamento` |
| `trg_pedido_validar_atualizacao` | Trigger (BEFORE UPDATE em `pedido`) | Valida o fluxo de status e as condições de aprovação (itens, insumos e estoque) |
| `trg_pedido_so_apaga_orcamento` | Trigger (BEFORE DELETE em `pedido`) | Só permite excluir pedidos em `orcamento` |
| `trg_itens_so_em_orcamento_insert/update/delete` | Triggers em `pedido_produto` | Bloqueiam alteração de itens quando o pedido não está em `orcamento` |
| `vw_pedidos` | View | Pedido com nome do cliente, telefone, vendedor e aprovador |
| `vw_itens_pedido` | View | Itens de cada pedido com cliente, tipo e produto |
| `vw_estoque_do_pedido` | View | Insumos de cada pedido com fornecedor, saldo e situação (`DISPONIVEL` / `SEM ESTOQUE`) |
| `vw_pendencias` | View | Produtos sem insumo, fornecedores sem insumo e pedidos sem item |
