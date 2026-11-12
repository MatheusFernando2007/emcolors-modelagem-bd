# EMColors — Modelagem e Implementação de Banco de Dados
https://youtu.be/n-cc9KNv9PM?is=KC4YSATMIqmq-Ust

**Projeto acadêmico — Entrega 2: Modelo Lógico, Implementação SQL e Apresentação Final**

## Integrantes

| Nome completo | RGM | Usuário do GitHub |
|---|---|---|
| Diogo Mariano França da Silva | 46875336 | Diogocopd |
| Gabriel Rocha de Melo | 47687479 | bielg3r |
| Matheus Fernando Garcia de Oliveira | 46864075 | MatheusFernando2007 |

---

# 1. Introdução

A gestão de pequenas empresas gráficas costuma acontecer no improviso: pedidos anotados em papel, estoque controlado "de olho" e clientes que deixam de fazer parte dos registros assim que a entrega é realizada. Foi exatamente esse cenário que encontramos ao visitar a EMColors, uma gráfica especializada em adesivos, cartões e etiquetas, que atende de 5 a 8 pedidos por dia, mas ainda não conta com um sistema de gestão integrado.

O problema que motivou este trabalho é concreto: a empresa apresenta dificuldades no controle de estoque de insumos, como tinta, papel e clichê, e não mantém um cadastro permanente de clientes após a conclusão dos pedidos. Na prática, isso significa que a gráfica pode identificar a falta de determinado material somente depois que um pedido já foi fechado, necessitando realizar compras emergenciais. Além disso, a ausência de um histórico persistente dificulta a identificação de clientes que já realizaram compras anteriormente.

O objetivo deste projeto é desenvolver uma estrutura de banco de dados capaz de organizar as informações da EMColors, abrangendo clientes, funcionários, fornecedores, tipos de produto, produtos, insumos, pedidos e os relacionamentos existentes entre esses elementos.

A modelagem foi construída a partir de uma pesquisa de campo realizada por meio de visita e entrevista com o gerente da EMColors. Inicialmente, o trabalho concentrou-se no levantamento de requisitos, regras de negócio e desenvolvimento do Diagrama Entidade-Relacionamento (DER). Nesta segunda etapa, o projeto evolui para a conversão do modelo conceitual em modelo lógico, implementação SQL, análise de normalização e elaboração de consultas para apoiar a gestão da organização.

# 2. Caracterização da Organização

- **Nome e natureza da organização:** EMColors, uma gráfica com fins lucrativos.
- **Contexto e porte:** empresa de pequeno/médio porte, com equipe composta por 5 operadores de máquina, 1 expedicionista, 1 gerente e 2 colaboradoras no administrativo. Atende, em média, de 5 a 8 pedidos por dia.
- **Problemas e necessidades identificados:** dificuldade no controle de estoque de insumos, como tinta, papel/bobina e clichê, e ausência de cadastro permanente de clientes após a conclusão da entrega.
- **Justificativa da escolha:** a EMColors fica próxima ao local de trabalho de um dos integrantes do grupo, que possui conhecidos que trabalham na empresa, o que garantiu acesso facilitado para a pesquisa de campo.
- **Evidências da organização:** site institucional [EMColors](https://emcolors.com.br/) e registro fotográfico da visita realizada com o gerente da empresa.

## 2.1 Problemas identificados

Para orientar o desenvolvimento do banco de dados, os problemas encontrados foram organizados em códigos.

| Código | Problema | Consequência para a organização |
|---|---|---|
| P01 | Controle insuficiente do estoque de insumos. | Dificuldade para identificar a disponibilidade de materiais e possibilidade de compras emergenciais durante o atendimento dos pedidos. |
| P02 | Ausência de cadastro permanente e histórico de clientes. | Dificuldade para consultar pedidos anteriores e identificar o relacionamento comercial com clientes recorrentes. |

O banco de dados proposto busca atender aos dois problemas por meio da organização das informações de estoque e da manutenção dos registros de clientes e pedidos. A seção 13 indica quais partes do script SQL atendem a cada problema.

## 2.2 Escopo do Sistema

O sistema proposto contempla a organização das informações relacionadas aos principais processos operacionais identificados na EMColors:

- Cadastro e identificação de clientes.
- Registro de orçamentos e pedidos, com a forma de entrega (entrega ou retirada).
- Associação de produtos aos pedidos, com a quantidade de cada item.
- Identificação do funcionário que atendeu e do funcionário que aprovou cada pedido.
- Cadastro de produtos e de seus tipos (adesivo, cartão e etiqueta).
- Cadastro de fornecedores e insumos, e relação entre os produtos e os insumos usados na fabricação.
- Consulta das quantidades disponíveis em estoque.
- Acompanhamento dos status dos pedidos.
- Consulta do histórico de pedidos por cliente.

O escopo está concentrado na gestão das informações relacionadas à operação da gráfica. A implementação representa os processos efetivamente identificados no levantamento de campo, sem incluir funcionalidades que não tenham relação com a realidade da organização.

# 3. Levantamento e Processos de Negócio

A pesquisa de campo permitiu identificar os principais processos realizados pela EMColors, desde a solicitação de orçamento até a entrega ou retirada do pedido.

## 3.1 Processos mapeados

Cada processo possui um código (PN), usado na seção 13 para indicar qual parte do script SQL o atende.

| Código | Processo | Descrição | No banco de dados |
|---|---|---|---|
| PN01 | Solicitação de orçamento | O cliente solicita um orçamento para a produção de um ou mais produtos. Atualmente, essa etapa é realizada em papel. | O pedido é criado com status `orcamento`, ligado a um cliente, e seus itens ficam em `pedido_produto`. |
| PN02 | Aprovação do orçamento | O orçamento é aprovado juntamente com o pagamento, caracterizando uma única etapa no processo observado. | O status passa a `aprovado`, com o funcionário aprovador e o valor total. Um trigger confere produtos, insumos e estoque. |
| PN03 | Produção do pedido | Após a aprovação, o pedido é encaminhado para produção, sob responsabilidade de um operador de máquina. | Status `em_producao`. |
| PN04 | Finalização | Após a produção, o pedido passa a aguardar a entrega ou retirada. | Status `pronto`. |
| PN05 | Entrega ou retirada | O pedido é entregue ao cliente ou retirado por ele, com fechamento realizado pelo expedicionista responsável. | Status `entregue`; a forma de entrega (`entrega` ou `retirada`) fica em `pedido.forma_entrega`. |
| PN06 | Controle de insumos | A gráfica utiliza tinta, papel/bobina e clichês na fabricação dos produtos. A ausência de controle formal do estoque foi identificada como uma dificuldade operacional. | `insumo.quantidade_estoque`, relação `produto_insumo`, view `vw_estoque_do_pedido` e consultas de estoque. |

## 3.2 Fluxo do processo de pedido

O fluxo observado durante a visita segue a sequência abaixo. A última coluna mostra o status correspondente no banco de dados.

| Etapa | Descrição | Processo | Status no banco |
|---|---|---|---|
| 1 | O cliente solicita um orçamento. | PN01 | — |
| 2 | O orçamento é elaborado e registrado em papel. | PN01 | `orcamento` |
| 3 | O cliente aprova o orçamento e realiza o pagamento. | PN02 | `aprovado` |
| 4 | O pedido é encaminhado para produção, sob responsabilidade de um operador de máquina. | PN03 | `em_producao` |
| 5 | Após a produção, o pedido fica pronto. | PN04 | `pronto` |
| 6 | O expedicionista realiza o fechamento e a entrega ou retirada do pedido. | PN05 | `entregue` |

O controle de insumos (PN06) acompanha todo o fluxo e é conferido no momento da aprovação.

**Fluxograma do processo de pedido:**

<!-- Inserir o fluxograma definitivo nesta seção quando o arquivo estiver disponível no repositório. -->

## 3.3 Relato da entrevista e levantamento de campo

O levantamento de informações foi realizado por meio de visita presencial à EMColors e entrevista com o gerente da organização.

Durante a pesquisa, foram identificados os processos de orçamento, aprovação, produção e entrega, além das dificuldades relacionadas ao controle de estoque e à ausência de histórico permanente de clientes.

O levantamento também permitiu identificar a composição da equipe, o volume médio de pedidos e os tipos de produtos e insumos utilizados pela gráfica.

**Informações da entrevista:**

| Informação | Registro |
|---|---|
| Organização | EMColors |
| Entrevistado | Gerente da EMColors |
| Função | Gerente |
| Data da entrevista | A preencher com a data correta |
| Local | Dependências da EMColors |
| Integrantes participantes | A preencher com os nomes dos participantes |
| Evidência fotográfica | Inserir fotografia JPG ou PNG no repositório |

O relatório completo do levantamento deve ser consultado no arquivo [Relatório da Entrevista](./relatório%20da%20entrevista.md).

**Observação:** as informações de data, participantes e evidência fotográfica devem ser conferidas e complementadas pelo grupo. A documentação da entrevista deve diferenciar os fatos observados presencialmente das informações fornecidas pelo entrevistado.

# 4. Requisitos do Sistema

Os requisitos foram organizados considerando os processos identificados durante a pesquisa de campo e as necessidades de gestão da EMColors. Cada requisito possui um código, usado na seção 13 para indicar qual parte do script SQL o atende.

## 4.1 Requisitos Funcionais

| Código | Requisito funcional |
|---|---|
| RF01 | O sistema deve permitir registrar um orçamento vinculado a um cliente. |
| RF02 | O sistema deve permitir registrar o funcionário (gerente/vendedor) que atendeu o pedido. |
| RF03 | O sistema deve permitir registrar um pedido com um ou mais itens, contendo o produto e a quantidade em metros. |
| RF04 | O sistema deve permitir registrar a aprovação do orçamento, com o funcionário aprovador e o valor total, junto com o pagamento. |
| RF05 | O sistema deve permitir atualizar o status do pedido, contemplando orçamento, aprovado, em produção, pronto e entregue. |
| RF06 | O sistema deve permitir registrar se o pedido será entregue ao cliente ou retirado por ele. |
| RF07 | O sistema deve permitir cadastrar produtos e suas respectivas classificações (tipos de produto). |
| RF08 | O sistema deve permitir cadastrar fornecedores e registrar insumos vinculados a eles, com a quantidade em estoque. |
| RF09 | O sistema deve permitir relacionar os insumos utilizados na fabricação de cada produto. |
| RF10 | O sistema deve permitir consultar a quantidade disponível de insumos, inclusive os necessários para cada pedido, antes de aprová-lo. |
| RF11 | O sistema deve impedir a aprovação de um pedido sem produtos, com produto sem insumo cadastrado ou com insumo sem estoque. |
| RF12 | O sistema deve manter os dados dos clientes após a conclusão dos pedidos. |
| RF13 | O sistema deve permitir consultar os pedidos anteriores associados a determinado cliente. |
| RF14 | O sistema deve permitir consultar indicadores gerenciais, como pedidos por status, valores aprovados, produtos mais solicitados e pedidos por funcionário. |
| RF15 | O sistema deve permitir identificar pendências de cadastro: produto sem insumo, fornecedor sem insumo e pedido sem item. |

## 4.2 Requisitos Não Funcionais

| Código | Categoria | Requisito não funcional |
|---|---|---|
| RNF01 | Confiabilidade | O controle de estoque deve representar adequadamente as quantidades disponíveis de insumos, sem permitir saldo negativo. |
| RNF02 | Desempenho | As consultas de pedidos por status e por data devem apresentar respostas adequadas durante o atendimento ao cliente. |
| RNF03 | Integridade | O banco de dados deve utilizar chaves primárias, chaves estrangeiras, restrições de integridade e triggers para evitar registros inconsistentes. |
| RNF04 | Compatibilidade | O script deve ser executado por inteiro no MySQL 8.0.16 ou superior, com codificação `utf8mb4`. |

# 5. Regras de Negócio

As regras de negócio representam as condições identificadas no funcionamento da EMColors e as regras que o banco de dados aplica automaticamente. Cada regra possui um código (RN), usado na seção 13.

## 5.1 Regras operacionais

| Código | Regra |
|---|---|
| RN01 | Um pedido pode conter um ou mais itens. Cada item liga o pedido a um produto, com a quantidade em metros, e o mesmo produto não pode aparecer duas vezes no mesmo pedido. |
| RN02 | A quantidade de cada item deve ser maior que zero. |
| RN03 | Todo pedido nasce como orçamento (status `orcamento`). |
| RN04 | O status do pedido segue a ordem `orcamento` → `aprovado` → `em_producao` → `pronto` → `entregue`, avançando uma etapa por vez e sem voltar. |
| RN05 | A aprovação do orçamento ocorre junto com o pagamento, em uma única etapa. Todo pedido já aprovado possui funcionário aprovador e valor total (maior ou igual a zero). |
| RN06 | Um pedido sem produtos não pode ser aprovado. |
| RN07 | Um pedido com produto sem insumo cadastrado não pode ser aprovado, pois o estoque não pode ser conferido. |
| RN08 | Um pedido cujos produtos usam algum insumo sem estoque (quantidade igual ou menor que zero) não pode ser aprovado. |
| RN09 | Os itens de um pedido só podem ser incluídos, alterados ou removidos enquanto o pedido estiver em orçamento. |
| RN10 | Somente pedidos em orçamento podem ser excluídos. |
| RN11 | Cada insumo pertence a um único fornecedor e possui quantidade em estoque registrada, que nunca é negativa (o valor inicial é zero). |
| RN12 | Cada produto pertence a um único tipo de produto (adesivo, cartão ou etiqueta); os insumos de cada produto são registrados na relação entre produto e insumo. |
| RN13 | Cliente, funcionário, fornecedor, tipo de produto, produto, insumo e pedido não podem ser excluídos enquanto outros registros dependerem deles; assim, o histórico dos clientes e dos pedidos é preservado. |
| RN14 | Nomes (e telefones, quando existem) são obrigatórios e não podem ficar em branco; nomes de tipo de produto, produto e insumo não se repetem; o cargo do funcionário é Gerente, Administrativo, Operador de máquina ou Expedicionista; a forma de entrega é `entrega` ou `retirada`. |

## 5.2 Restrições e políticas organizacionais

- Hoje, a EMColors não faz verificação formal de estoque no fechamento do pedido, o que pode gerar compras emergenciais. Essa situação foi identificada como um dos problemas centrais da organização (P01). No banco de dados proposto, a verificação acontece na aprovação do orçamento (RN06 a RN08).
- Os dados dos clientes não são mantidos após a entrega, o que impede a consulta de um histórico de pedidos no processo atual (P02). No banco de dados proposto, clientes e pedidos são mantidos (RN13).
- O prazo de entrega varia conforme o pedido e não segue um padrão fixo.
- Cada fornecedor fornece apenas um tipo de insumo (tinta, papel/bobina ou clichê), conforme o levantamento realizado. No banco de dados, cada insumo possui um único fornecedor (RN11).

**Importante:** as regras RN06 a RN08 (bloqueio da aprovação por falta de estoque) são uma proposta deste projeto para resolver o problema P01. Elas não existem hoje na rotina da EMColors.

# 6. Revisão do Modelo Conceitual

O modelo conceitual foi desenvolvido com base nos dados levantados durante a visita à EMColors. Nesta entrega, ele foi conferido com o script SQL (`emcolors.sql`), que é a referência para as entidades, os relacionamentos e as regras descritos a seguir.

## 6.1 Entidades reconhecidas

| Entidade | Tabela | Descrição |
|---|---|---|
| Cliente | `cliente` | Pessoa ou empresa que solicita o orçamento e realiza o pedido. |
| Funcionário | `funcionario` | Colaboradores da EMColors e seus cargos: Gerente, Administrativo, Operador de máquina e Expedicionista. |
| Fornecedor | `fornecedor` | Empresa responsável pelo fornecimento de insumos. |
| Tipo de produto | `tipo_produto` | Classificação dos produtos: adesivo, cartão e etiqueta. |
| Produto | `produto` | Item produzido pela gráfica, por exemplo adesivo couchê, cartão de visita e etiqueta contracolado. |
| Insumo | `insumo` | Material utilizado na produção, como tinta, papel/bobina e clichê, com a quantidade em estoque. |
| Pedido | `pedido` | Registro central do processo, desde o orçamento até a entrega. |
| Item do pedido (associativa) | `pedido_produto` | Cada produto solicitado dentro de um pedido, com a quantidade em metros. |
| Insumos do produto (associativa) | `produto_insumo` | Insumos utilizados na fabricação de cada produto. |

## 6.2 Relacionamentos pertinentes

| Relacionamento | Cardinalidade | Descrição |
|---|---|---|
| Cliente — Pedido | 1:N | Um cliente pode possuir vários pedidos; todo pedido pertence a um cliente. |
| Funcionário — Pedido (atendimento) | 1:N | Um funcionário pode atender vários pedidos; todo pedido registra o funcionário que o atendeu (gerente/vendedor). |
| Funcionário — Pedido (aprovação) | 1:N | Um funcionário pode aprovar vários pedidos; o aprovador é registrado quando o pedido deixa de ser orçamento. |
| Pedido — Produto | N:N | Um pedido pode conter vários produtos e um produto pode estar em vários pedidos, por meio de `pedido_produto`, que guarda a quantidade. |
| Produto — Insumo | N:N | Um produto usa vários insumos e um insumo pode ser usado em vários produtos, por meio de `produto_insumo`. |
| Fornecedor — Insumo | 1:N | Um fornecedor pode fornecer diferentes insumos; cada insumo possui um único fornecedor. |
| Tipo de produto — Produto | 1:N | Um tipo de produto classifica vários produtos; cada produto possui um único tipo. |

## 6.3 Diagrama Entidade-Relacionamento (DER)

O DER representa as entidades identificadas, seus atributos, relacionamentos e cardinalidades.

<img width="2400" height="1275" alt="DER conceitual da EMColors" src="https://github.com/user-attachments/assets/6a179ee8-4f41-4235-9eb8-e5aa127d56a2" />

**Software utilizado:** modelo elaborado com apoio do brModelo e dos recursos de modelagem utilizados pelo grupo. Confirmar a ferramenta efetivamente utilizada para a versão final do diagrama.

# 7. Conversão do Modelo Conceitual para o Modelo Lógico

A conversão do modelo conceitual para o modelo lógico consiste em transformar as entidades em tabelas relacionais, seus atributos em colunas e os relacionamentos em referências por meio de chaves primárias e estrangeiras.

O script SQL cria as seguintes tabelas:

| Tabela | Origem conceitual |
|---|---|
| `cliente` | Entidade Cliente: dados dos clientes. |
| `funcionario` | Entidade Funcionário: funcionários e seus cargos. |
| `fornecedor` | Entidade Fornecedor: fornecedores de insumos. |
| `tipo_produto` | Entidade Tipo de produto: classificação dos produtos. |
| `produto` | Entidade Produto: produtos fabricados pela gráfica. |
| `insumo` | Entidade Insumo: insumos e suas quantidades em estoque. |
| `pedido` | Entidade Pedido: datas, formas de entrega, status e valores. |
| `pedido_produto` | Associação Pedido — Produto: itens do pedido e suas quantidades. |
| `produto_insumo` | Associação Produto — Insumo: insumos utilizados na produção. |

## 7.1 Conversão de entidades em tabelas

As entidades independentes (cliente, funcionário, fornecedor, tipo de produto, produto, insumo e pedido) foram transformadas em tabelas específicas, mantendo seus identificadores como chaves primárias numéricas (`INT` com `AUTO_INCREMENT`).

Os relacionamentos muitos-para-muitos foram transformados em tabelas associativas com chave primária composta: `pedido_produto`, formada por `id_pedido` e `id_produto`, que guarda a quantidade de cada item; e `produto_insumo`, formada por `id_produto` e `id_insumo`.

O tipo de papel (couchê ou contracolado) não possui tabela própria: ele é identificado pelo nome do produto e do insumo.

## 7.2 Conversão dos relacionamentos

| Relacionamento conceitual | Representação relacional |
|---|---|
| Cliente 1:N Pedido | Chave estrangeira `id_cliente` em `pedido` (`fk_pedido_cliente`). |
| Funcionário 1:N Pedido (atendimento) | Chave estrangeira `id_funcionario_gerente_vendedor` em `pedido` (`fk_pedido_vendedor`), obrigatória. |
| Funcionário 1:N Pedido (aprovação) | Chave estrangeira `id_funcionario_aprovador` em `pedido` (`fk_pedido_aprovador`), opcional: fica vazia enquanto o pedido é orçamento. |
| Pedido N:N Produto | Tabela associativa `pedido_produto`. |
| Produto N:N Insumo | Tabela associativa `produto_insumo`. |
| Fornecedor 1:N Insumo | Chave estrangeira `id_fornecedor` em `insumo` (`fk_insumo_fornecedor`). |
| Tipo de produto 1:N Produto | Chave estrangeira `id_tipo_produto` em `produto` (`fk_produto_tipo`). |

# 8. Definição de Chaves Primárias e Estrangeiras

As chaves primárias identificam exclusivamente cada registro das tabelas. As chaves estrangeiras estabelecem os relacionamentos entre as tabelas e garantem a integridade referencial.

As tabelas abaixo descrevem as chaves presentes no script SQL.

## 8.1 Chaves Primárias

| Tabela | Chave primária |
|---|---|
| `cliente` | `id_cliente` |
| `funcionario` | `id_funcionario` |
| `fornecedor` | `id_fornecedor` |
| `tipo_produto` | `id_tipo_produto` |
| `produto` | `id_produto` |
| `insumo` | `id_insumo` |
| `pedido` | `id_pedido` |
| `pedido_produto` | `id_pedido` + `id_produto` |
| `produto_insumo` | `id_produto` + `id_insumo` |

## 8.2 Chaves Estrangeiras

| Tabela de origem | Coluna | Tabela referenciada | Restrição | `ON DELETE` / `ON UPDATE` |
|---|---|---|---|---|
| `produto` | `id_tipo_produto` | `tipo_produto` | `fk_produto_tipo` | `RESTRICT` / `CASCADE` |
| `insumo` | `id_fornecedor` | `fornecedor` | `fk_insumo_fornecedor` | `RESTRICT` / `CASCADE` |
| `pedido` | `id_cliente` | `cliente` | `fk_pedido_cliente` | `RESTRICT` / `CASCADE` |
| `pedido` | `id_funcionario_gerente_vendedor` | `funcionario` | `fk_pedido_vendedor` | `RESTRICT` / `CASCADE` |
| `pedido` | `id_funcionario_aprovador` | `funcionario` | `fk_pedido_aprovador` | `RESTRICT` / `RESTRICT` |
| `pedido_produto` | `id_pedido` | `pedido` | `fk_pedido_produto_pedido` | `RESTRICT` / `CASCADE` |
| `pedido_produto` | `id_produto` | `produto` | `fk_pedido_produto_produto` | `RESTRICT` / `CASCADE` |
| `produto_insumo` | `id_produto` | `produto` | `fk_produto_insumo_produto` | `RESTRICT` / `CASCADE` |
| `produto_insumo` | `id_insumo` | `insumo` | `fk_produto_insumo_insumo` | `RESTRICT` / `CASCADE` |

**Observação:** a chave `fk_pedido_aprovador` usa `ON UPDATE RESTRICT` porque a coluna `id_funcionario_aprovador` também é usada em um `CHECK`. No MySQL 8, essa combinação com `ON UPDATE CASCADE` gera o erro 3823.

# 9. Processo de Normalização

A normalização tem como finalidade organizar as informações em estruturas relacionais, reduzindo redundâncias e evitando anomalias de inserção, atualização e exclusão.

A análise a seguir considera a organização das tabelas implementadas no script SQL.

## 9.1 Primeira Forma Normal (1FN)

A Primeira Forma Normal estabelece que cada coluna deve armazenar valores atômicos, sem grupos repetitivos ou listas de valores em uma única célula.

Na implementação, os dados de clientes, funcionários, fornecedores, tipos de produto, produtos, insumos e pedidos estão separados em tabelas próprias.

Os produtos associados aos pedidos são armazenados na tabela `pedido_produto`, enquanto os insumos associados aos produtos são armazenados na tabela `produto_insumo`.

Essa separação evita armazenar vários produtos ou insumos em uma única coluna.

## 9.2 Segunda Forma Normal (2FN)

A Segunda Forma Normal exige que a tabela esteja na 1FN e que todos os atributos não-chave dependam integralmente da chave primária.

As tabelas associativas `pedido_produto` e `produto_insumo` utilizam chaves primárias compostas. A tabela `pedido_produto` utiliza a combinação de `id_pedido` e `id_produto`, e seu único atributo não-chave, `quantidade_produto`, depende da combinação completa das duas colunas, pois representa a quantidade de um produto em um pedido específico. A tabela `produto_insumo` utiliza `id_produto` e `id_insumo` e não possui atributos não-chave.

As demais tabelas possuem chave primária de uma única coluna, portanto não há dependências parciais.

## 9.3 Terceira Forma Normal (3FN)

A Terceira Forma Normal exige que a tabela esteja na 2FN e que seus atributos não-chave não dependam transitivamente da chave primária.

A estrutura separa informações de clientes, funcionários, fornecedores, produtos, tipos de produtos e insumos em tabelas específicas.

Por exemplo, os dados do fornecedor não são repetidos diretamente na tabela `insumo`. Em vez disso, a tabela utiliza `id_fornecedor` como chave estrangeira. Da mesma forma, a tabela `pedido` guarda apenas os identificadores do cliente e dos funcionários que atendem e aprovam o pedido, sem repetir seus nomes ou cargos.

A classificação do produto é mantida na tabela `tipo_produto`, sendo referenciada pela tabela `produto`.

Essa organização reduz a repetição de informações e facilita a manutenção dos registros.

## 9.4 Considerações sobre a normalização

A estrutura atual apresenta separação de entidades e relacionamentos compatível com os princípios das três formas normais.

O valor total do pedido (`valor_total`) é informado no momento da aprovação e não é calculado a partir de outras colunas do banco, portanto não cria dependência transitiva.

# 10. Justificativas Técnicas das Decisões

## 10.1 Separação entre Cliente e Pedido

A separação entre as tabelas `cliente` e `pedido` permite que um mesmo cliente possua vários pedidos associados ao seu identificador.

Essa decisão contribui diretamente para solucionar a ausência de histórico de clientes identificada durante a pesquisa de campo (P02).

## 10.2 Utilização de Tabelas Associativas

As tabelas `pedido_produto` e `produto_insumo` foram utilizadas para representar relacionamentos muitos-para-muitos.

Essa abordagem permite que um pedido contenha diferentes produtos e que um produto esteja presente em vários pedidos.

Da mesma forma, permite que um produto utilize diferentes insumos e que um mesmo insumo esteja associado a diferentes produtos.

## 10.3 Separação entre Produto e Tipo de Produto

A tabela `tipo_produto` permite classificar os produtos da gráfica, evitando que a classificação seja repetida diretamente em todos os registros de produtos.

Essa separação facilita a manutenção das classificações e a realização de consultas por categoria.

## 10.4 Utilização de Tipos de Dados Específicos

Foram utilizados tipos de dados como `INT`, `VARCHAR`, `DATE` e `DECIMAL`, de acordo com a natureza das informações armazenadas. Os identificadores são `INT` com `AUTO_INCREMENT`.

O tipo `DECIMAL` é utilizado para valores monetários (`valor_total`) e para quantidades que podem exigir casas decimais (`quantidade_estoque` e `quantidade_produto`). O tipo `DATE` armazena as datas dos pedidos.

Campos com valores fixos, como cargo, status e forma de entrega, são `VARCHAR` com uma restrição `CHECK ... IN (...)`, que limita os valores às opções previamente definidas.

## 10.5 Integridade Referencial

As chaves estrangeiras garantem que os relacionamentos entre as tabelas façam referência a registros existentes. Todas usam `ON DELETE RESTRICT`, o que impede excluir um registro que ainda é usado por outro, e `ON UPDATE CASCADE`, exceto `fk_pedido_aprovador`, que usa `ON UPDATE RESTRICT` (seção 8.2).

As restrições de integridade também contribuem para evitar valores inválidos, como quantidades negativas de estoque e quantidades não positivas nos itens dos pedidos.

## 10.6 Restrições Implementadas

O script utiliza restrições como:

| Restrição | Aplicação |
|---|---|
| `PRIMARY KEY` | Identificação exclusiva dos registros. |
| `FOREIGN KEY` | Integridade dos relacionamentos entre tabelas. |
| `NOT NULL` | Impede a ausência de valores em campos obrigatórios. |
| `UNIQUE` | Evita duplicidade de nomes em `tipo_produto`, `produto` e `insumo`. |
| `CHECK` | Impede nomes e telefones em branco, cargos e formas de entrega fora da lista, status inválido, `valor_total` negativo, estoque negativo, quantidade de item menor ou igual a zero e pedido aprovado sem aprovador ou sem valor total. |
| `DEFAULT` | Define valores iniciais: estoque zero em `insumo.quantidade_estoque` e status `orcamento` em `pedido.status`. |
| `AUTO_INCREMENT` | Gera os identificadores das tabelas principais. |
| `TRIGGER` | Aplica regras automáticas sobre os pedidos e seus itens (seção 13.4). |

O detalhamento por coluna fica no Dicionário de Dados (seção 15).

## 10.7 Simplificações adotadas

- **Tipo de papel:** não possui tabela própria. O tipo de papel (couchê ou contracolado) aparece no nome do produto e no nome do insumo.
- **Itens do pedido:** são representados pela tabela `pedido_produto`, com chave primária composta, sem uma tabela de item separada.
- **Funcionários no pedido:** o pedido registra quem atendeu (`id_funcionario_gerente_vendedor`) e quem aprovou (`id_funcionario_aprovador`). Operadores de máquina e expedicionistas são cadastrados como funcionários, mas não são vinculados ao pedido.
- **Estoque:** o saldo atual fica em `insumo.quantidade_estoque`. Não há baixa automática, registro de entradas e saídas, estoque mínimo nem quantidade de insumo por produto, e a aprovação do pedido apenas verifica se o saldo de cada insumo é maior que zero.

# 11. Estratégia de Business Intelligence e Análise Gerencial

A utilização dos dados armazenados no banco de dados pode auxiliar a gestão da EMColors na identificação de padrões de pedidos, acompanhamento do estoque e análise do relacionamento com os clientes.

A proposta de análise gerencial utiliza consultas SQL para transformar os registros operacionais em informações úteis para a tomada de decisão.

## 11.1 Indicadores de Desempenho (KPIs)

Os indicadores propostos estão relacionados aos problemas identificados durante a pesquisa de campo e às informações armazenadas no banco de dados.

| Código | Indicador | Objetivo | Dados necessários |
|---|---|---|---|
| KPI01 | Pedidos aprovados por mês | Acompanhar o volume mensal de pedidos aprovados. | `pedido.data_pedido` e `pedido.status` |
| KPI02 | Faturamento aprovado por mês | Acompanhar os valores dos pedidos aprovados e o valor médio por pedido. | `pedido.valor_total`, `pedido.status` e `pedido.data_pedido` |
| KPI03 | Produtos mais solicitados | Identificar os produtos com maior demanda. | `pedido_produto` e `produto` |
| KPI04 | Clientes recorrentes | Identificar clientes que realizam mais de um pedido. | `cliente` e `pedido` |
| KPI05 | Distribuição de pedidos por status | Acompanhar a quantidade de pedidos em cada etapa. | `pedido.status` |
| KPI06 | Quantidade disponível de insumos | Acompanhar os níveis atuais de estoque. | `insumo.quantidade_estoque` |

**Observação:** cada indicador é calculado por consultas do script SQL, indicadas na seção 11.5.

## 11.2 Relação entre Problemas e Indicadores

| Problema | Indicadores relacionados | Benefício esperado |
|---|---|---|
| P01 — Controle insuficiente de estoque | KPI06 | Melhor acompanhamento das quantidades disponíveis de insumos e apoio ao planejamento de reposição. |
| P02 — Ausência de histórico de clientes | KPI04 e KPI01 | Identificação de clientes recorrentes e acompanhamento do histórico de pedidos. |

## 11.3 Potencial para Business Intelligence

A estrutura de dados proposta pode servir como base para relatórios e painéis gerenciais, permitindo acompanhar informações importantes para a rotina da gráfica.

Entre as possibilidades estão:

- Relatórios de pedidos aprovados por mês.
- Acompanhamento do valor total registrado em pedidos.
- Identificação dos produtos com maior procura.
- Consulta de clientes com maior frequência de pedidos.
- Acompanhamento dos pedidos por status.
- Visualização das quantidades disponíveis de insumos.

Essas informações podem ser utilizadas futuramente em ferramentas de Business Intelligence para facilitar a visualização dos dados e apoiar decisões administrativas.

## 11.4 Potencial para Inteligência Artificial

A organização dos dados também pode permitir futuras aplicações de Inteligência Artificial, desde que exista volume e qualidade suficientes de registros.

Entre as possibilidades de evolução estão:

- Análise de padrões de demanda por produtos.
- Estimativa de consumo de insumos com base no histórico de pedidos.
- Apoio à previsão de necessidade de reposição de materiais.
- Identificação de padrões de recorrência de clientes.
- Apoio ao planejamento da produção em períodos de maior demanda.

Essas aplicações representam possibilidades futuras. Não estão implementadas no banco de dados atual e dependem de dados históricos consistentes e validação pela organização.

## 11.5 Tabela de Rastreabilidade

A tabela abaixo relaciona os problemas e indicadores às tabelas que fornecem os dados necessários e às consultas do script SQL que os calculam. Os números das consultas seguem a numeração dos comentários do script (seção 6 do arquivo).

| Problema ou KPI | Tabelas envolvidas | Consultas no script |
|---|---|---|
| P01 — Controle insuficiente de estoque | `insumo`, `produto_insumo`, `pedido_produto`, `fornecedor` | 6.3, 6.4, 6.5, 6.13 e 6.25 (e view `vw_estoque_do_pedido`) |
| P02 — Ausência de histórico de clientes | `cliente`, `pedido` | 6.1, 6.8, 6.9 e 6.26 (e view `vw_pedidos`) |
| KPI01 — Pedidos aprovados por mês | `pedido` | 6.20 |
| KPI02 — Faturamento aprovado por mês | `pedido` | 6.20 |
| KPI03 — Produtos mais solicitados | `pedido_produto`, `produto`, `tipo_produto` | 6.11 e 6.12 |
| KPI04 — Clientes recorrentes | `cliente`, `pedido` | 6.8, 6.10 e 6.26 |
| KPI05 — Pedidos por status | `pedido` | 6.6 e 6.22 |
| KPI06 — Quantidade disponível de insumos | `insumo` | 6.13 |

# 12. Modelo Lógico Relacional

O modelo lógico representa a estrutura relacional do banco de dados: as 9 tabelas, seus atributos, tipos de dados, chaves primárias, chaves estrangeiras e cardinalidades. As tabelas e as chaves estão descritas nas seções 7 e 8, e as colunas e os tipos de dados, no Dicionário de Dados (seção 15).

O diagrama deve ser desenvolvido no brModelo, seguindo a notação exigida para o modelo lógico.

**Arquivo do modelo lógico:** a inserir após a elaboração e validação do diagrama no brModelo.

<!-- Inserir aqui o link do modelo lógico definitivo. -->

# 13. Implementação SQL

A implementação física do banco de dados foi desenvolvida no MySQL 8 (recomendado 8.0.16 ou superior, para que as restrições `CHECK` sejam aplicadas). O script `emcolors.sql` cria o banco `emcolors` com codificação `utf8mb4`.

**Atenção:** o script apaga e recria as tabelas do banco `emcolors`. Ele deve ser executado inteiro, de uma só vez, em uma conexão MySQL, pois os comandos `DELIMITER` usados na criação dos triggers impedem a execução de trechos isolados.

## 13.1 Estrutura do script

| Bloco | Conteúdo | Códigos |
|---|---|---|
| 1. Limpeza | `DROP ... IF EXISTS` de views, triggers e tabelas, para que o script possa ser executado mais de uma vez. | RNF04 |
| 2. Tabelas | 9 tabelas (`InnoDB`, `utf8mb4`) e 2 índices. | RNF03, RNF04 |
| 3. Triggers | 6 triggers com as regras automáticas dos pedidos e de seus itens. | RNF03 |
| 4. Views | 4 views (consultas salvas). | — |
| 5. Dados de exemplo | `INSERT` dos cadastros e dos pedidos, e `UPDATE` que aprova e avança alguns pedidos. | — |
| 6. Consultas SELECT | 26 consultas de relatórios e verificações, numeradas de 6.1 a 6.26. | — |

## 13.2 Rastreabilidade entre o script e os códigos

As tabelas das seções 13.3 a 13.7 mostram quais códigos cada parte do script atende:

| Prefixo | Significado | Onde está definido |
|---|---|---|
| P | Problema identificado | Seção 2.1 |
| PN | Processo mapeado | Seção 3.1 |
| RF | Requisito funcional | Seção 4.1 |
| RNF | Requisito não funcional | Seção 4.2 |
| RN | Regra de negócio | Seção 5.1 |

No arquivo `emcolors.sql`, cada parte do script traz comentários `CODIGOS` e `RESOLVE` com esses mesmos códigos. Para achar as partes que atendem a um código, basta procurá-lo no arquivo (por exemplo, `RN08`).

## 13.3 Tabelas e índices

| Tabela | Responsabilidade | Códigos |
|---|---|---|
| `cliente` | Cadastro dos clientes (nome e telefone). | PN01, RF01, RF12, RN13, RN14, P02 |
| `funcionario` | Cadastro dos funcionários e cargos. | PN01, PN02, RF02, RF04, RN14 |
| `fornecedor` | Cadastro dos fornecedores (nome e telefone). | PN06, RF08, RN11, RN14 |
| `tipo_produto` | Classificação dos produtos. | RF07, RN12, RN14 |
| `produto` | Cadastro dos produtos fabricados, cada um com seu tipo. | RF07, RN12, RN14 |
| `insumo` | Cadastro dos insumos, com fornecedor e quantidade atual em estoque. | PN06, RF08, RNF01, RN11, RN14, P01 |
| `pedido` | Registro dos pedidos: data, forma de entrega, status, valor total, cliente, funcionário que atendeu e funcionário que aprovou. | PN01, PN02, PN03, PN04, PN05, RF01, RF02, RF04, RF05, RF06, RN03, RN04, RN05, RN13, RN14, P02 |
| `pedido_produto` | Itens do pedido: produto e quantidade em metros. | PN01, RF03, RN01, RN02, RN13 |
| `produto_insumo` | Insumos usados na fabricação de cada produto. | PN06, RF09, RN12, RN13 |

| Índice | Colunas | Códigos |
|---|---|---|
| `idx_pedido_status_data` | `pedido (status, data_pedido)` | RNF02 |
| `idx_pedido_data` | `pedido (data_pedido)` | RNF02 |

## 13.4 Triggers

| Trigger | Quando dispara | O que faz | Códigos |
|---|---|---|---|
| `trg_pedido_nasce_orcamento` | Antes de inserir em `pedido` | Impede criar um pedido com status diferente de `orcamento`. | PN01, RF01, RN03 |
| `trg_pedido_validar_atualizacao` | Antes de atualizar `pedido` | Valida a mudança de status e a aprovação do pedido (blocos detalhados abaixo). | PN02, PN03, PN04, PN05, RF05, RF11, RN04, RN06, RN07, RN08, P01 |
| `trg_pedido_so_apaga_orcamento` | Antes de excluir de `pedido` | Só permite excluir pedidos em orçamento. | RN10, P02 |
| `trg_itens_so_em_orcamento_insert` | Antes de inserir em `pedido_produto` | Só permite incluir item se o pedido estiver em orçamento. | PN01, RF03, RN09 |
| `trg_itens_so_em_orcamento_update` | Antes de atualizar `pedido_produto` | Só permite alterar item se o pedido estiver em orçamento. | PN01, RF03, RN09 |
| `trg_itens_so_em_orcamento_delete` | Antes de excluir de `pedido_produto` | Só permite remover item se o pedido estiver em orçamento. | PN01, RF03, RN09 |

O trigger `trg_pedido_validar_atualizacao` concentra a validação em um único trigger, para não depender da ordem de execução de dois triggers `BEFORE UPDATE`. Ele é dividido em quatro blocos:

| Bloco | Verificação | Códigos |
|---|---|---|
| 1. Fluxo de status | Aceita apenas `orcamento` → `aprovado` → `em_producao` → `pronto` → `entregue`, uma etapa por vez. | PN02, PN03, PN04, PN05, RF05, RN04 |
| 2. Pedido sem produtos | Na aprovação, exige pelo menos um item em `pedido_produto`. | PN02, RF11, RN06 |
| 3. Produto sem insumo | Na aprovação, exige que todo produto do pedido tenha insumo em `produto_insumo`. | PN02, PN06, RF11, RN07 |
| 4. Insumo sem estoque | Na aprovação, bloqueia o pedido se algum insumo dos seus produtos tiver `quantidade_estoque` menor ou igual a zero. | PN02, PN06, RF11, RN08, P01 |

A exigência de funcionário aprovador e de valor total em pedidos aprovados (RN05) é garantida pela restrição `ck_aprovado_exige_aprovador_e_valor`, na tabela `pedido`.

## 13.5 Views

| View | O que mostra | Códigos |
|---|---|---|
| `vw_pedidos` | Pedidos com cliente, telefone, funcionário que atendeu e aprovador. | RF02, RF04, RF05, RF13, P02 |
| `vw_itens_pedido` | Itens de cada pedido, com cliente, status, tipo de produto, produto e quantidade. | RF03, RF13 |
| `vw_estoque_do_pedido` | Insumos usados em cada pedido, com fornecedor, saldo e situação (`SEM ESTOQUE` ou `DISPONIVEL`). | PN06, RF10, P01 |
| `vw_pendencias` | Produtos sem insumo, fornecedores sem insumo e pedidos sem item. | RF15, RN06, RN07 |

## 13.6 Dados de exemplo

| Trecho do script | O que faz | Códigos |
|---|---|---|
| `INSERT` de `cliente`, `funcionario`, `fornecedor`, `tipo_produto`, `produto`, `insumo` e `produto_insumo` | Cadastros iniciais. | PN06, RF07, RF08, RF09 |
| `INSERT` de `pedido` e `pedido_produto` | 6 pedidos em orçamento e seus 8 itens. | PN01, RF01, RF02, RF03, RF06, RN03 |
| `UPDATE` dos pedidos 1 a 4 | Aprova os pedidos, informando aprovador e valor total. | PN02, RF04, RF11, RN05 |
| `UPDATE` de status | Avança os pedidos 1, 2 e 3 para `em_producao`, os pedidos 1 e 2 para `pronto` e o pedido 1 para `entregue`. | PN03, PN04, PN05, RF05, RN04 |

## 13.7 Consultas SELECT

| Consulta | O que responde | Códigos |
|---|---|---|
| 6.1 | Lista geral de pedidos, com cliente, status, valor, funcionário que atendeu e aprovador (usa `vw_pedidos`). | RF05, RF13, P02 |
| 6.2 | Produtos de um pedido específico (exemplo: pedido 4). | PN01, RF03 |
| 6.3 | Confere os insumos dos pedidos em orçamento: com saldo, sem saldo e produtos sem insumo. | PN02, PN06, RF10, RN07, RN08, P01 |
| 6.4 | Detalha estoque e fornecedor dos insumos dos pedidos em orçamento, com diagnóstico. | PN06, RF10, RN08, P01 |
| 6.5 | Lista os insumos sem estoque nos pedidos em orçamento. | PN06, RF10, RN08, P01 |
| 6.6 | Quantidade e valor dos pedidos por status. | RF05, RF14 |
| 6.7 | Pedidos ainda não entregues e dias desde a data do pedido. | PN03, PN04, PN05, RF05 |
| 6.8 | Histórico e valor aprovado por cliente. | RF13, P02 |
| 6.9 | Clientes que ainda não fizeram pedidos. | RF12, RF13, P02 |
| 6.10 | Dez clientes com maior valor em pedidos aprovados. | RF14 |
| 6.11 | Produtos mais solicitados. | RF14 |
| 6.12 | Pedidos e quantidades por tipo de produto. | RF07, RF14 |
| 6.13 | Situação atual dos insumos, com fornecedor e telefone. | PN06, RF08, RF10, P01 |
| 6.14 | Quantidade de insumos por fornecedor. | PN06, RF08 |
| 6.15 | Fornecedores sem insumos cadastrados. | RF08, RF15 |
| 6.16 | Insumos utilizados por produto. | PN06, RF09 |
| 6.17 | Produtos sem insumos cadastrados. | RF09, RF15, RN07 |
| 6.18 | Pedidos atendidos por funcionário. | RF02, RF14 |
| 6.19 | Pedidos aprovados por funcionário aprovador. | RF04, RF14 |
| 6.20 | Resumo mensal dos pedidos aprovados: quantidade, faturamento e valor médio. | RF14 |
| 6.21 | Pedidos por forma de entrega. | PN05, RF06 |
| 6.22 | Painel geral de pedidos por status e valor aprovado. | RF05, RF14 |
| 6.23 | Pendências encontradas pelas views (usa `vw_pendencias`). | RF15 |
| 6.24 | Itens de todos os pedidos (usa `vw_itens_pedido`). | RF03 |
| 6.25 | Estoque dos insumos ligados aos pedidos (usa `vw_estoque_do_pedido`). | PN06, RF10, P01 |
| 6.26 | Último pedido e total de pedidos por cliente. | RF13, P02 |

## 13.8 Comandos SQL utilizados

O script utiliza:

- `CREATE DATABASE`, `USE` e `SET NAMES`, para criar e selecionar o banco.
- `DROP VIEW`, `DROP TRIGGER` e `DROP TABLE`, sempre com `IF EXISTS`.
- `CREATE TABLE`, com `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT` e `AUTO_INCREMENT`.
- `CREATE INDEX`.
- `CREATE TRIGGER` (`BEFORE INSERT`, `BEFORE UPDATE` e `BEFORE DELETE`), com `DELIMITER`, `IF ... THEN`, `EXISTS` e `SIGNAL SQLSTATE`.
- `CREATE VIEW`, com `JOIN`, `LEFT JOIN`, `UNION ALL` e `CASE`.
- `INSERT INTO` e `UPDATE`, para os dados de exemplo e para a aprovação e o avanço de status dos pedidos.
- `SELECT` com `JOIN`, `LEFT JOIN`, `WHERE`, `GROUP BY`, `ORDER BY` e `LIMIT`, e funções como `COUNT`, `SUM`, `AVG`, `MAX`, `COALESCE`, `CASE`, `GROUP_CONCAT`, `DATE_FORMAT`, `DATEDIFF` e `FIELD`.

O script não traz um comando `DELETE` de exemplo. A exclusão de registros é controlada pelos triggers (RN09 e RN10) e pelas chaves estrangeiras com `ON DELETE RESTRICT` (RN13).

## 13.9 Arquivo do Script SQL

O script de implementação está disponível no repositório:

[**emcolors.sql — Script SQL**](./emcolors.sql)

O arquivo reúne a criação do banco, das tabelas, dos triggers e das views, os dados de exemplo e as consultas descritas nesta seção.

# 14. Massa de Dados

A massa de dados utilizada no projeto é fictícia, preservando a privacidade de clientes, funcionários e fornecedores da organização.

## 14.1 Dados cadastrados

O script `emcolors.sql` insere os seguintes registros de exemplo:

| Tabela | Quantidade de registros |
|---|---:|
| `cliente` | 6 |
| `funcionario` | 6 |
| `fornecedor` | 3 |
| `tipo_produto` | 3 |
| `produto` | 5 |
| `insumo` | 4 |
| `pedido` | 6 |
| `pedido_produto` | 8 |
| `produto_insumo` | 15 |

Depois dos `UPDATE` do script, os seis pedidos ficam nos seguintes status: `entregue` (1), `pronto` (1), `em_producao` (1), `aprovado` (1) e `orcamento` (2).

## 14.2 Justificativa da massa de dados

O contexto levantado informa que a EMColors atende, em média, de 5 a 8 pedidos por dia. A massa de exemplo é bem menor que esse volume: ela serve para demonstrar os relacionamentos, as regras automáticas e as consultas, e não para reproduzir a operação diária.

Mesmo sendo pequena, a massa cobre:

- Um cliente com mais de um pedido e um cliente cadastrado que ainda não fez pedidos.
- Pedidos em todas as etapas do processo, do orçamento à entrega.
- Pedidos concluídos e pedidos ainda em andamento.
- As duas formas de entrega (`entrega` e `retirada`).
- Produtos com diferentes níveis de procura.
- Insumos com quantidades variadas em estoque.

## 14.3 Integridade da Massa de Dados

Todos os registros respeitam os relacionamentos e as restrições definidas no banco de dados: os pedidos referenciam clientes e funcionários existentes, os itens referenciam pedidos e produtos existentes e os insumos estão associados a fornecedores cadastrados.

Como a massa de exemplo não tem insumo sem estoque, fornecedor sem insumo, produto sem insumo nem pedido sem item, as consultas de verificação 6.5, 6.15, 6.17 e 6.23 não retornam linhas.

# 15. Dicionário de Dados

O dicionário de dados documenta a estrutura do banco de dados, descrevendo cada tabela, suas colunas, tipos de dados e restrições de integridade.

O dicionário conceitual preliminar desenvolvido na Entrega 1 serviu como referência para a identificação dos atributos e suas finalidades.

Para a Entrega 2, será necessário atualizar esse documento com a estrutura física do script `emcolors.sql`, contemplando:

- Nome da tabela.
- Nome de cada coluna.
- Descrição e finalidade do atributo.
- Tipo de dado.
- Chave primária ou estrangeira.
- Obrigatoriedade (`NOT NULL`).
- Unicidade (`UNIQUE`).
- Valores permitidos (`CHECK`).
- Valor padrão (`DEFAULT`).
- Relacionamentos e referências.

**Arquivo do Dicionário de Dados:** inserir o link do arquivo HTML definitivo ou, caso a turma utilize a exceção prevista para GTI, o arquivo Markdown separado.

# 16. Repositório e Organização dos Artefatos

O projeto está disponível no GitHub:

[**EMColors — Modelagem de Banco de Dados**](https://github.com/MatheusFernando2007/emcolors-modelagem-bd)

O repositório reúne a documentação, os diagramas, o levantamento de campo e o script de implementação.

## 16.1 Arquivos disponíveis

| Arquivo ou pasta | Descrição |
|---|---|
| `README.md` | Relatório técnico principal do projeto. |
| `emcolors.sql` | Script SQL do banco de dados (MySQL 8). |
| `relatório da entrevista.md` | Documento com o registro do levantamento realizado. |
| `img/` | Pasta destinada aos materiais visuais do projeto. |

## 16.2 Histórico de Desenvolvimento

O desenvolvimento do projeto deve ser documentado por meio de commits realizados ao longo das etapas de trabalho.

O histórico deve demonstrar a evolução dos diagramas, documentação, implementação SQL e demais artefatos.

A participação dos integrantes deve ser identificável por meio das respectivas contas do GitHub, mantendo uma distribuição equilibrada de contribuições entre os membros do grupo.

# 17. Uso de Inteligência Artificial

O grupo utilizou ferramentas de Inteligência Artificial como apoio à organização das informações levantadas em campo e à elaboração da modelagem conceitual.

A documentação do uso de IA é mantida para registrar as ferramentas utilizadas, os objetivos, os prompts, as respostas recebidas e as revisões realizadas pelo grupo.

## 17.1 Uso de IA na Entrega 1

| Item | Descrição |
|---|---|
| Ferramenta e etapa | Claude (Anthropic), utilizado durante a elaboração do README, organização do levantamento de requisitos, estruturação dos processos de negócio, elaboração do fluxograma, DER, requisitos, regras de negócio, dicionário de dados e justificativas técnicas. |
| Motivação | Organizar as informações obtidas na entrevista e transformá-las em uma estrutura conceitual coerente. |
| Prompts utilizados | O grupo conduziu uma entrevista guiada, respondendo perguntas feitas pela IA sobre a organização, seus processos, regras de negócio, produtos e equipe. Também foram utilizados pedidos como "monte o fluxograma do processo de pedido" e "monte o DER com base nessas respostas". |
| Resposta recebida | A IA propôs uma modelagem inicial com oito entidades, suas cardinalidades, o fluxograma do processo de pedido e um rascunho de requisitos funcionais, não funcionais e regras de negócio. |
| Fontes consultadas e verificadas | Não houve consulta a fontes externas nessa etapa. O conteúdo teve como base as respostas fornecidas pelo grupo a partir da pesquisa de campo na EMColors. |
| Trechos rejeitados ou corrigidos | Foram corrigidos pontos como o cargo correto de quem fecha o pedido (expedicionista, e não atendente) e a relação entre o pagamento e a aprovação do orçamento, que ocorre em uma única etapa. |
| Justificativa da escolha final | A estrutura foi mantida por refletir as informações levantadas na visita, especialmente a separação entre Produto e Tipo_Papel e a entidade associativa Item_Pedido. |
| Reflexão crítica | A IA depende das informações fornecidas pelo grupo. Por isso, as respostas foram revisadas para evitar que imprecisões do levantamento fossem incorporadas à modelagem. Também foi identificado um problema de contraste na primeira versão visual do DER, que precisou ser corrigido. |

## 17.2 Uso de IA na Entrega 2

| Item | Descrição |
|---|---|
| Ferramenta e etapa | ChatGPT, utilizado como apoio à análise do repositório GitHub, comparação com os requisitos da Entrega 2 e organização da documentação técnica. |
| Motivação | Identificar os conteúdos que precisavam ser complementados no relatório e analisar a compatibilidade entre o modelo conceitual, a implementação SQL e as exigências da entrega. |
| Prompts utilizados | "Analise esses dois arquivos, e me pontue o que eu preciso adicionar no meu trabalho." |
| Resposta recebida | Foram propostas complementações para conversão do modelo lógico, chaves primárias e estrangeiras, normalização, justificativas técnicas, indicadores gerenciais, rastreabilidade e organização do repositório. |
| Fontes consultadas e verificadas | Repositório GitHub do projeto EMColors, script SQL existente e documento de orientação da Entrega 2. |
| Trechos rejeitados ou corrigidos | As sugestões que não estavam comprovadas pelos documentos foram identificadas como pendências, especialmente as divergências entre o DER e o SQL, além das informações de entrevista que precisam ser complementadas pelo grupo. |
| Justificativa da escolha final | O conteúdo foi organizado considerando as informações existentes no projeto e as exigências do documento de orientação. As sugestões devem ser revisadas pelos integrantes antes de serem consideradas definitivas. |
| Reflexão crítica | A IA pode auxiliar na organização e análise da documentação, mas não possui acesso a informações internas da organização que não foram fornecidas. Portanto, as decisões sobre processos, regras de negócio e alterações estruturais precisam ser verificadas pelo grupo e, quando necessário, pelo responsável da EMColors. |

**Observação:** este registro documenta os usos descritos nesta etapa. Caso o grupo utilize outras ferramentas de IA para gerar dados, elaborar consultas SQL, revisar diagramas ou preparar a apresentação, esses usos também deverão ser documentados, incluindo os prompts e as correções realizadas.

# 18. Conclusão

Este trabalho permitiu compreender, na prática, a importância de analisar o funcionamento de uma organização antes de desenvolver uma estrutura de banco de dados.

A pesquisa de campo realizada na EMColors possibilitou identificar detalhes importantes do processo operacional, como a aprovação do orçamento junto ao pagamento, a divisão de responsabilidades entre operador de máquina e expedicionista e a relação entre fornecedores e insumos utilizados na produção.

A partir dessas informações, foi desenvolvido um modelo conceitual voltado à organização dos dados da gráfica, com foco em dois problemas principais: a dificuldade de controle do estoque e a ausência de histórico permanente de clientes.

Na segunda etapa, o projeto evoluiu para a estrutura relacional e sua implementação em MySQL, utilizando tabelas específicas, chaves primárias, chaves estrangeiras, restrições de integridade, triggers e views. O banco impede a aprovação de pedidos sem produtos, com produto sem insumo ou com insumo sem estoque, e mantém os clientes e seus pedidos para consulta posterior. A organização das informações busca reduzir redundâncias, manter a consistência dos registros e permitir consultas que apoiem o acompanhamento da operação.

O script traz 26 consultas de relatórios e verificações, que permitem acompanhar pedidos, produtos, clientes e quantidades de insumos. Com o amadurecimento da base de dados, essas informações poderão apoiar relatórios, indicadores e futuras aplicações de Business Intelligence e Inteligência Artificial.

Como evolução do projeto, o modelo pode passar a registrar entradas e saídas de estoque, a quantidade de insumo usada em cada produto e os funcionários responsáveis pela produção e pela entrega de cada pedido.

Dessa forma, o projeto busca transformar necessidades identificadas na rotina da EMColors em uma estrutura organizada de informações, capaz de apoiar a gestão e contribuir para decisões mais consistentes.

# 19. Referências

Este trabalho foi desenvolvido com base nas seguintes fontes:

- **Pesquisa de campo:** visita presencial e entrevista com o gerente da EMColors, utilizadas para identificar processos, regras de negócio, equipe, produtos e dificuldades relacionadas ao estoque e ao cadastro de clientes.
- **Documentação do projeto:** modelo conceitual, DER, requisitos, regras de negócio e script SQL desenvolvidos pelo grupo.
- **Apoio de Inteligência Artificial:** utilização do Claude (Anthropic) e do ChatGPT para organização das informações, apoio à modelagem e revisão da documentação, conforme detalhado na seção 17.
- **Site institucional:** [EMColors](https://emcolors.com.br/).
- **Orientações acadêmicas:** documento de referência da Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final.
