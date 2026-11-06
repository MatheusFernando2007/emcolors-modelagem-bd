# EMColors — Modelagem e Implementação de Banco de Dados

**Projeto acadêmico — Entrega 2: Modelo Lógico, Implementação SQL e Apresentação Final**

## Integrantes

| Nome completo | RGM | Usuário do GitHub |
|---|---|---|
| Diogo Mariano França da Silva | A preencher | A preencher |
| Gabriel Rocha de Melo | A preencher | A preencher |
| Matheus Fernando Garcia de Oliveira | A preencher | MatheusFernando2007 |

---

# 1. Introdução

A gestão de pequenas empresas gráficas costuma acontecer no improviso: pedidos anotados em papel, estoque controlado "de olho" e clientes que deixam de fazer parte dos registros assim que a entrega é realizada. Foi exatamente esse cenário que encontramos ao visitar a EMColors, uma gráfica especializada em adesivos, cartões e etiquetas, que atende de 5 a 8 pedidos por dia, mas ainda não conta com um sistema de gestão integrado.

O problema que motivou este trabalho é concreto: a empresa apresenta dificuldades no controle de estoque de insumos, como tinta, papel e clichê, e não mantém um cadastro permanente de clientes após a conclusão dos pedidos. Na prática, isso significa que a gráfica pode identificar a falta de determinado material somente depois que um pedido já foi fechado, necessitando realizar compras emergenciais. Além disso, a ausência de um histórico persistente dificulta a identificação de clientes que já realizaram compras anteriormente.

O objetivo deste projeto é desenvolver uma estrutura de banco de dados capaz de organizar as informações da EMColors, abrangendo clientes, funcionários, fornecedores, produtos, insumos, pedidos e os relacionamentos existentes entre esses elementos.

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

O banco de dados proposto busca atender aos dois problemas por meio da organização das informações de estoque e da manutenção dos registros de clientes e pedidos.

## 2.2 Escopo do Sistema

O sistema proposto contempla a organização das informações relacionadas aos principais processos operacionais identificados na EMColors:

- Cadastro e identificação de clientes.
- Registro de orçamentos e pedidos.
- Associação de produtos aos pedidos.
- Identificação dos funcionários envolvidos na produção e no fechamento dos pedidos.
- Cadastro de produtos e tipos de materiais utilizados.
- Cadastro de fornecedores e insumos.
- Consulta das quantidades disponíveis em estoque.
- Acompanhamento dos status dos pedidos.
- Consulta do histórico de pedidos por cliente.

O escopo está concentrado na gestão das informações relacionadas à operação da gráfica. A implementação deve representar os processos efetivamente identificados no levantamento de campo, sem incluir funcionalidades que não tenham relação com a realidade da organização.

# 3. Levantamento e Processos de Negócio

A pesquisa de campo permitiu identificar os principais processos realizados pela EMColors, desde a solicitação de orçamento até a entrega ou retirada do pedido.

## 3.1 Processos mapeados

| Processo | Descrição |
|---|---|
| Solicitação de orçamento | O cliente solicita um orçamento para a produção de um ou mais produtos. Atualmente, essa etapa é realizada em papel. |
| Aprovação do orçamento | O orçamento é aprovado juntamente com o pagamento, caracterizando uma única etapa no processo observado. |
| Produção do pedido | Após a aprovação, o pedido é encaminhado para produção, sob responsabilidade de um operador de máquina. |
| Finalização | Após a produção, o pedido passa a aguardar a entrega ou retirada. |
| Entrega ou retirada | O pedido é entregue ao cliente ou retirado por ele, com fechamento realizado pelo expedicionista responsável. |
| Controle de insumos | A gráfica utiliza tinta, papel/bobina e clichês na fabricação dos produtos. A ausência de controle formal do estoque foi identificada como uma dificuldade operacional. |

## 3.2 Fluxo do processo de pedido

O fluxo observado durante a visita segue a sequência:

1. O cliente solicita um orçamento.
2. O orçamento é elaborado e registrado em papel.
3. O cliente aprova o orçamento e realiza o pagamento.
4. O pedido é encaminhado para produção, sob responsabilidade de um operador de máquina.
5. Após a produção, o pedido fica pronto.
6. O expedicionista realiza o fechamento e a entrega ou retirada do pedido.

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

Os requisitos foram organizados considerando os processos identificados durante a pesquisa de campo e as necessidades de gestão da EMColors.

## 4.1 Requisitos Funcionais

| Código | Requisito funcional |
|---|---|
| RF01 | O sistema deve permitir registrar um orçamento vinculado a um cliente. |
| RF02 | O sistema deve permitir registrar a aprovação do orçamento junto com o pagamento. |
| RF03 | O sistema deve permitir registrar um pedido com um ou mais itens, contendo produto, tipo de papel e quantidade em metros. |
| RF04 | O sistema deve permitir atribuir um funcionário expedicionista responsável pelo fechamento do pedido. |
| RF05 | O sistema deve permitir atribuir um operador de máquina responsável pela produção do pedido. |
| RF06 | O sistema deve permitir consultar a quantidade disponível de insumos, como tinta, papel/bobina e clichê, antes do fechamento de um pedido. |
| RF07 | O sistema deve permitir registrar insumos vinculados a fornecedores. |
| RF08 | O sistema deve permitir atualizar o status do pedido, contemplando orçamento, aprovado, em produção, pronto e entregue. |
| RF09 | O sistema deve manter os dados dos clientes após a conclusão dos pedidos. |
| RF10 | O sistema deve permitir consultar os pedidos anteriores associados a determinado cliente. |
| RF11 | O sistema deve permitir cadastrar produtos e suas respectivas classificações. |
| RF12 | O sistema deve permitir relacionar os insumos utilizados na fabricação de cada produto. |

## 4.2 Requisitos Não Funcionais

| Código | Categoria | Requisito não funcional |
|---|---|---|
| RNF01 | Usabilidade | O sistema deve apresentar uma interface simples, considerando que a operação é realizada por funcionários sem perfil técnico especializado. |
| RNF02 | Confiabilidade | O controle de estoque deve representar adequadamente as quantidades disponíveis de insumos. |
| RNF03 | Desempenho | As consultas de estoque e o cadastro de pedidos devem apresentar respostas adequadas durante o atendimento ao cliente. |
| RNF04 | Disponibilidade | O sistema deve estar acessível durante o horário de funcionamento da gráfica. |
| RNF05 | Integridade | O banco de dados deve utilizar chaves primárias, chaves estrangeiras e restrições de integridade para evitar registros inconsistentes. |
| RNF06 | Segurança | O acesso às informações deve respeitar as responsabilidades dos funcionários e preservar os dados armazenados. |

# 5. Regras de Negócio

As regras de negócio representam as condições identificadas no funcionamento da EMColors e orientam a estruturação do banco de dados.

## 5.1 Regras operacionais

| Código | Regra |
|---|---|
| RN01 | Um pedido pode conter um ou mais itens, cada um associado a um produto, tipo de papel e quantidade em metros. |
| RN02 | A aprovação do orçamento ocorre junto com o pagamento, caracterizando uma única etapa no processo observado. |
| RN03 | Cada pedido possui um único operador responsável pela produção e um único expedicionista responsável pelo fechamento. |
| RN04 | Cada fornecedor está associado a apenas um tipo de insumo, conforme o levantamento realizado. |
| RN05 | Os pedidos devem possuir um status que represente sua etapa no processo operacional. |
| RN06 | Os dados dos clientes devem ser mantidos para permitir consultas de pedidos anteriores. |
| RN07 | Os insumos utilizados na produção devem possuir quantidades de estoque registradas. |

## 5.2 Restrições e políticas organizacionais

- Atualmente, não há verificação formal de estoque no fechamento do pedido, o que pode gerar compras emergenciais. Essa situação foi identificada como um dos problemas centrais da organização.
- Os dados dos clientes não são mantidos após a entrega, o que impede a consulta de um histórico de pedidos no processo atual.
- O prazo de entrega varia conforme o pedido e não segue um padrão fixo.
- Cada pedido possui um operador responsável pela produção e um expedicionista responsável pelo fechamento.

**Importante:** as regras representam o processo observado e as necessidades identificadas. A implementação de mecanismos de controle, como alertas de estoque mínimo ou bloqueios de pedidos sem disponibilidade de insumos, deve ser validada com a organização antes de ser considerada uma regra operacional vigente.

# 6. Revisão do Modelo Conceitual

O modelo conceitual foi desenvolvido com base nos dados levantados durante a visita à EMColors. Para a Entrega 2, sua revisão considera a necessidade de manter a correspondência entre os processos, requisitos, regras de negócio, modelo lógico e implementação SQL.

## 6.1 Entidades reconhecidas

| Entidade | Descrição |
|---|---|
| Cliente | Pessoa ou empresa que solicita o orçamento e realiza o pedido. |
| Pedido | Registro central do processo, desde o orçamento até a entrega. |
| Item_Pedido | Entidade associativa que representa cada produto solicitado dentro de um pedido. |
| Produto | Tipo de item produzido pela gráfica, como adesivo, cartão ou etiqueta. |
| Tipo_Papel | Tipo de papel utilizado na produção dos itens. |
| Funcionário | Representa os colaboradores da EMColors e seus diferentes cargos. |
| Fornecedor | Empresa responsável pelo fornecimento de insumos. |
| Insumo | Material utilizado na produção, como tinta, papel/bobina e clichê. |

## 6.2 Relacionamentos pertinentes

| Relacionamento | Cardinalidade | Descrição |
|---|---|---|
| Cliente — Pedido | 1:N | Um cliente pode possuir vários pedidos. |
| Funcionário — Pedido | 1:N | Um funcionário pode atuar como expedicionista em vários pedidos. |
| Funcionário — Pedido | 1:N | Um funcionário pode atuar como operador em vários pedidos. |
| Pedido — Item_Pedido | 1:N | Um pedido pode conter vários itens. |
| Produto — Item_Pedido | 1:N | Um produto pode aparecer em diferentes itens de pedidos. |
| Tipo_Papel — Item_Pedido | 1:N | Um tipo de papel pode ser utilizado em diferentes itens. |
| Fornecedor — Insumo | 1:N | Um fornecedor pode estar associado a diferentes insumos. |

## 6.3 Diagrama Entidade-Relacionamento (DER)

O DER representa as entidades identificadas, seus atributos, relacionamentos e cardinalidades.

<img width="2400" height="1275" alt="DER conceitual da EMColors" src="https://github.com/user-attachments/assets/6a179ee8-4f41-4235-9eb8-e5aa127d56a2" />

**Software utilizado:** modelo elaborado com apoio do brModelo e dos recursos de modelagem utilizados pelo grupo. Confirmar a ferramenta efetivamente utilizada para a versão final do diagrama.

## 6.4 Ajustes e compatibilidade do modelo

Durante a análise da implementação SQL, foram identificadas diferenças entre o modelo conceitual e a estrutura física atual.

| Elemento | Modelo conceitual | Implementação SQL atual | Ajuste necessário |
|---|---|---|---|
| Funcionários no pedido | Operador e expedicionista | Gerente/vendedor e aprovador | Revisar as referências de funcionários para representar os responsáveis definidos no processo. |
| Tipo de papel | Entidade `Tipo_Papel` | Não existe tabela correspondente | Definir sua inclusão na estrutura relacional. |
| Item do pedido | Produto, tipo de papel e quantidade em metros | Produto e quantidade_produto | Avaliar a inclusão do tipo de papel e confirmar a unidade da quantidade. |
| Relação produto-insumo | Associação entre produtos e insumos | Tabela associativa `produto_insumo` | Avaliar a inclusão da quantidade de insumo necessária por produto. |
| Estoque | Quantidade disponível de insumos | Campo `quantidade_estoque` na tabela `insumo` | Avaliar o registro de entradas e saídas de estoque e a definição de estoque mínimo. |

Esses ajustes devem ser realizados no modelo lógico e no script SQL para garantir que a implementação represente corretamente os processos levantados.

# 7. Conversão do Modelo Conceitual para o Modelo Lógico

A conversão do modelo conceitual para o modelo lógico consiste em transformar as entidades em tabelas relacionais, seus atributos em colunas e os relacionamentos em referências por meio de chaves primárias e estrangeiras.

A estrutura SQL atual utiliza as seguintes tabelas:

| Tabela | Origem conceitual ou finalidade |
|---|---|
| `cliente` | Armazena os dados dos clientes. |
| `funcionario` | Armazena os funcionários e seus cargos. |
| `fornecedor` | Armazena os fornecedores de insumos. |
| `tipo_produto` | Classifica os tipos de produtos. |
| `produto` | Armazena os produtos fabricados pela gráfica. |
| `insumo` | Armazena os insumos e suas quantidades em estoque. |
| `pedido` | Registra os pedidos, datas, formas de entrega, status e valores. |
| `pedido_produto` | Relaciona os produtos aos pedidos. |
| `produto_insumo` | Relaciona os produtos aos insumos utilizados na produção. |

## 7.1 Conversão de entidades em tabelas

As entidades independentes foram transformadas em tabelas específicas, mantendo seus identificadores como chaves primárias.

A entidade associativa `Item_Pedido` foi representada na implementação atual pela tabela `pedido_produto`, que utiliza uma chave primária composta por `id_pedido` e `id_produto`.

O relacionamento entre produtos e insumos foi representado pela tabela `produto_insumo`, também com chave primária composta.

A entidade conceitual `Tipo_Papel`, entretanto, ainda não possui tabela correspondente na implementação atual e precisa ser considerada na revisão do modelo lógico.

## 7.2 Conversão dos relacionamentos

| Relacionamento conceitual | Representação relacional |
|---|---|
| Cliente 1:N Pedido | Chave estrangeira `id_cliente` em `pedido`. |
| Pedido N:N Produto | Tabela associativa `pedido_produto`. |
| Produto N:N Insumo | Tabela associativa `produto_insumo`. |
| Fornecedor 1:N Insumo | Chave estrangeira `id_fornecedor` em `insumo`. |
| Funcionário 1:N Pedido | Referências à tabela `funcionario` na tabela `pedido`, atualmente com os campos de gerente/vendedor e aprovador. |

A representação dos funcionários precisa ser revisada para corresponder às funções de operador e expedicionista descritas no modelo conceitual.

## 7.3 Modelo Lógico Relacional

O modelo lógico definitivo deverá apresentar todas as tabelas, colunas, tipos de dados, chaves primárias, chaves estrangeiras e cardinalidades convertidas.

**Arquivo do modelo lógico:** a inserir após a elaboração e validação do diagrama no brModelo.

<!-- Inserir aqui o link do modelo lógico definitivo. -->

# 8. Definição de Chaves Primárias e Estrangeiras

As chaves primárias identificam exclusivamente cada registro das tabelas. As chaves estrangeiras estabelecem os relacionamentos entre as tabelas e garantem a integridade referencial.

A tabela abaixo descreve as chaves presentes na implementação SQL atual.

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

| Tabela de origem | Coluna | Tabela referenciada |
|---|---|---|
| `produto` | `id_tipo_produto` | `tipo_produto` |
| `insumo` | `id_fornecedor` | `fornecedor` |
| `pedido` | `id_cliente` | `cliente` |
| `pedido` | `id_funcionario_gerente_vendedor` | `funcionario` |
| `pedido` | `id_funcionario_aprovador` | `funcionario` |
| `pedido_produto` | `id_pedido` | `pedido` |
| `pedido_produto` | `id_produto` | `produto` |
| `produto_insumo` | `id_produto` | `produto` |
| `produto_insumo` | `id_insumo` | `insumo` |

**Observação:** as chaves listadas correspondem ao script SQL atual. A relação de chaves deverá ser atualizada depois da revisão do modelo lógico, especialmente em relação a operador, expedicionista e tipo de papel.

# 9. Processo de Normalização

A normalização tem como finalidade organizar as informações em estruturas relacionais, reduzindo redundâncias e evitando anomalias de inserção, atualização e exclusão.

A análise a seguir considera a organização das tabelas atualmente implementadas no script SQL.

## 9.1 Primeira Forma Normal (1FN)

A Primeira Forma Normal estabelece que cada coluna deve armazenar valores atômicos, sem grupos repetitivos ou listas de valores em uma única célula.

Na implementação, os dados de clientes, funcionários, fornecedores, produtos, insumos e pedidos estão separados em tabelas próprias.

Os produtos associados aos pedidos são armazenados na tabela `pedido_produto`, enquanto os insumos associados aos produtos são armazenados na tabela `produto_insumo`.

Essa separação evita armazenar vários produtos ou insumos em uma única coluna.

## 9.2 Segunda Forma Normal (2FN)

A Segunda Forma Normal exige que a tabela esteja na 1FN e que todos os atributos não-chave dependam integralmente da chave primária.

Na estrutura atual, as tabelas associativas `pedido_produto` e `produto_insumo` utilizam chaves primárias compostas.

A tabela `pedido_produto` utiliza a combinação de `id_pedido` e `id_produto`. A tabela `produto_insumo` utiliza `id_produto` e `id_insumo`.

Como essas tabelas não possuem outros atributos não-chave na implementação atual, não há dependências parciais desses atributos a serem eliminadas.

## 9.3 Terceira Forma Normal (3FN)

A Terceira Forma Normal exige que a tabela esteja na 2FN e que seus atributos não-chave não dependam transitivamente da chave primária.

A estrutura separa informações de clientes, funcionários, fornecedores, produtos, tipos de produtos e insumos em tabelas específicas.

Por exemplo, os dados do fornecedor não são repetidos diretamente na tabela `insumo`. Em vez disso, a tabela utiliza `id_fornecedor` como chave estrangeira.

Da mesma forma, a classificação do produto é mantida na tabela `tipo_produto`, sendo referenciada pela tabela `produto`.

Essa organização reduz a repetição de informações e facilita a manutenção dos registros.

## 9.4 Considerações sobre a normalização

A estrutura atual apresenta separação de entidades e relacionamentos compatível com os princípios das três formas normais.

Entretanto, a validação definitiva depende da revisão do modelo lógico, da definição dos atributos que ainda serão adicionados e da análise das dependências funcionais.

A inclusão de atributos como quantidade consumida de insumos, tipo de papel e identificação dos responsáveis deverá ser analisada para evitar dependências inadequadas e repetição de dados.

# 10. Justificativas Técnicas das Decisões

## 10.1 Separação entre Cliente e Pedido

A separação entre as tabelas `cliente` e `pedido` permite que um mesmo cliente possua vários pedidos associados ao seu identificador.

Essa decisão contribui diretamente para solucionar a ausência de histórico de clientes identificada durante a pesquisa de campo.

## 10.2 Utilização de Tabelas Associativas

As tabelas `pedido_produto` e `produto_insumo` foram utilizadas para representar relacionamentos muitos-para-muitos.

Essa abordagem permite que um pedido contenha diferentes produtos e que um produto esteja presente em vários pedidos.

Da mesma forma, permite que um produto utilize diferentes insumos e que um mesmo insumo esteja associado a diferentes produtos.

## 10.3 Separação entre Produto e Tipo de Produto

A tabela `tipo_produto` permite classificar os produtos da gráfica, evitando que a classificação seja repetida diretamente em todos os registros de produtos.

Essa separação facilita a manutenção das classificações e a realização de consultas por categoria.

## 10.4 Utilização de Tipos de Dados Específicos

Foram utilizados tipos de dados como `INT`, `VARCHAR`, `DATE`, `DECIMAL` e `ENUM`, de acordo com a natureza das informações armazenadas.

O tipo `DECIMAL` é utilizado para valores monetários e quantidades numéricas que podem exigir casas decimais. O tipo `DATE` armazena as datas dos pedidos.

O tipo `ENUM` é utilizado em campos como cargo, status e forma de entrega, restringindo os valores possíveis a opções previamente definidas.

## 10.5 Integridade Referencial

As chaves estrangeiras garantem que os relacionamentos entre as tabelas façam referência a registros existentes.

As restrições de integridade também contribuem para evitar valores inválidos, como quantidades negativas de estoque e quantidades não positivas nos itens dos pedidos.

## 10.6 Restrições Implementadas

O script atual utiliza restrições como:

| Restrição | Aplicação |
|---|---|
| `PRIMARY KEY` | Identificação exclusiva dos registros. |
| `FOREIGN KEY` | Integridade dos relacionamentos entre tabelas. |
| `NOT NULL` | Impede a ausência de valores em campos obrigatórios. |
| `UNIQUE` | Evita duplicidade de determinados valores, como nomes de produtos e tipos de produtos. |
| `CHECK` | Impede valores inválidos em quantidades e valores monetários. |
| `DEFAULT` | Define valores iniciais quando não é informado outro valor, como o estoque inicial e o status do pedido. |
| `ENUM` | Restringe determinados campos a valores previamente definidos. |

As restrições específicas de cada coluna devem ser detalhadas no Dicionário de Dados.

# 11. Estratégia de Business Intelligence e Análise Gerencial

A utilização dos dados armazenados no banco de dados pode auxiliar a gestão da EMColors na identificação de padrões de pedidos, acompanhamento do estoque e análise do relacionamento com os clientes.

A proposta de análise gerencial utiliza consultas SQL para transformar os registros operacionais em informações úteis para a tomada de decisão.

## 11.1 Indicadores de Desempenho (KPIs)

Os indicadores propostos estão relacionados aos problemas identificados durante a pesquisa de campo e às informações atualmente armazenadas no banco de dados.

| Código | Indicador | Objetivo | Dados necessários |
|---|---|---|---|
| KPI01 | Quantidade de pedidos por período | Acompanhar o volume de pedidos realizados. | `pedido.data_pedido` |
| KPI02 | Valor total dos pedidos por período | Acompanhar os valores registrados nos pedidos. | `pedido.valor_total`, `pedido.status` e `pedido.data_pedido` |
| KPI03 | Produtos mais solicitados | Identificar os produtos com maior demanda. | `pedido_produto` e `produto` |
| KPI04 | Clientes recorrentes | Identificar clientes que realizam mais de um pedido. | `cliente` e `pedido` |
| KPI05 | Distribuição de pedidos por status | Acompanhar a quantidade de pedidos em cada etapa. | `pedido.status` |
| KPI06 | Quantidade disponível de insumos | Acompanhar os níveis atuais de estoque. | `insumo.quantidade_estoque` |

**Observação:** os indicadores são propostas de análise. Sua utilização como KPIs definitivos depende da implementação e validação das consultas correspondentes no script SQL.

## 11.2 Relação entre Problemas e Indicadores

| Problema | Indicadores relacionados | Benefício esperado |
|---|---|---|
| P01 — Controle insuficiente de estoque | KPI06 | Melhor acompanhamento das quantidades disponíveis de insumos e apoio ao planejamento de reposição. |
| P02 — Ausência de histórico de clientes | KPI04 e KPI01 | Identificação de clientes recorrentes e acompanhamento do histórico de pedidos. |

## 11.3 Potencial para Business Intelligence

A estrutura de dados proposta pode servir como base para relatórios e painéis gerenciais, permitindo acompanhar informações importantes para a rotina da gráfica.

Entre as possibilidades estão:

- Relatórios de pedidos realizados por período.
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

A tabela abaixo relaciona os problemas e indicadores às tabelas que fornecem os dados necessários e às consultas gerenciais que deverão ser implementadas no script SQL.

| Problema ou KPI | Tabelas envolvidas | Consulta prevista |
|---|---|---|
| P01 — Controle insuficiente de estoque | `insumo` | G06 |
| P02 — Ausência de histórico de clientes | `cliente`, `pedido` | G04 |
| KPI01 — Quantidade de pedidos por período | `pedido` | G01 |
| KPI02 — Valor total dos pedidos por período | `pedido` | G02 |
| KPI03 — Produtos mais solicitados | `pedido_produto`, `produto` | G03 |
| KPI04 — Clientes recorrentes | `cliente`, `pedido` | G04 |
| KPI05 — Pedidos por status | `pedido` | G05 |
| KPI06 — Quantidade disponível de insumos | `insumo` | G06 |

**Importante:** os códigos G01 a G06 representam a organização proposta para as consultas. Eles somente poderão ser considerados concluídos depois que as consultas correspondentes forem implementadas, testadas e incluídas no script SQL.

# 12. Modelo Lógico Relacional

O modelo lógico representa a estrutura relacional do banco de dados, apresentando tabelas, atributos, tipos de dados, chaves primárias, chaves estrangeiras e cardinalidades.

O diagrama deve ser desenvolvido no brModelo, seguindo a notação exigida para o modelo lógico.

O modelo lógico definitivo deverá refletir as decisões tomadas na revisão conceitual, especialmente:

- Representação dos funcionários responsáveis pela produção e pelo fechamento dos pedidos.
- Inclusão ou justificativa da ausência da entidade `Tipo_Papel`.
- Definição da unidade de medida dos itens dos pedidos.
- Representação da quantidade de insumos consumida por produto, caso seja validada pelo grupo.
- Coerência entre as tabelas associativas e os relacionamentos do DER.

**Arquivo:** inserir o link do diagrama lógico após sua elaboração e validação.

# 13. Implementação SQL

A implementação física do banco de dados foi desenvolvida utilizando o Sistema Gerenciador de Banco de Dados MySQL.

O script atual contempla a criação do banco de dados, criação das tabelas, definição de chaves primárias e estrangeiras, restrições de integridade e inserção de dados fictícios para testes.

## 13.1 Estrutura implementada

| Tabela | Responsabilidade |
|---|---|
| `cliente` | Cadastro dos clientes. |
| `funcionario` | Cadastro dos funcionários e cargos. |
| `fornecedor` | Cadastro dos fornecedores. |
| `tipo_produto` | Classificação dos produtos. |
| `produto` | Cadastro dos produtos fabricados. |
| `insumo` | Cadastro e controle da quantidade atual de insumos. |
| `pedido` | Registro dos pedidos e seus dados principais. |
| `pedido_produto` | Associação entre pedidos e produtos. |
| `produto_insumo` | Associação entre produtos e insumos. |

## 13.2 Recursos SQL utilizados

A implementação atual utiliza:

- `CREATE DATABASE` para criação do banco de dados.
- `CREATE TABLE` para criação das tabelas.
- `PRIMARY KEY` para definição das chaves primárias.
- `FOREIGN KEY` para definição dos relacionamentos.
- `NOT NULL`, `UNIQUE`, `CHECK` e `DEFAULT` para restrições de integridade.
- `INSERT INTO` para inserção dos dados fictícios.
- `SELECT` para consulta e visualização dos registros.

## 13.3 Operações e consultas previstas para a entrega

De acordo com os requisitos da Entrega 2, o script deverá contemplar também:

| Recurso | Finalidade | Situação |
|---|---|---|
| `SELECT` com `JOIN` | Consultar informações relacionadas entre diferentes tabelas. | A implementar. |
| `UPDATE` | Atualizar registros existentes. | A implementar. |
| `DELETE` | Remover registros de teste ou registros permitidos pelas regras de integridade. | A implementar. |
| Consultas gerenciais G01–G06 | Responder às perguntas gerenciais e calcular os indicadores propostos. | A implementar. |
| Consultas de auditoria A01+ | Verificar regras de negócio e consistência dos dados. | A implementar. |

## 13.4 Consultas de Auditoria Propostas

As consultas de auditoria devem verificar a consistência dos dados e a aplicação das regras de negócio.

| Código | Verificação | Regra relacionada |
|---|---|---|
| A01 | Verificar se existem pedidos sem cliente associado. | RN05 e integridade referencial. |
| A02 | Verificar se existem pedidos sem itens associados. | RN01. |
| A03 | Verificar se existem registros de estoque com quantidade negativa. | RN07. |
| A04 | Verificar se existem pedidos aprovados sem valor total registrado. | RN02. |
| A05 | Verificar se os funcionários relacionados aos pedidos possuem os cargos compatíveis com suas responsabilidades. | RN03. |

As consultas devem ser implementadas e testadas no MySQL antes de serem consideradas concluídas.

## 13.5 Arquivo do Script SQL

O script de implementação está disponível no repositório:

[**emcolors_for_mysql.sql — Script SQL**](./emcolors_for_mysql.sql)

O arquivo deverá ser atualizado para refletir a versão definitiva do modelo lógico e conter todas as operações e consultas exigidas na Entrega 2.

# 14. Massa de Dados

A massa de dados utilizada no projeto deve ser fictícia, preservando a privacidade de clientes, funcionários e fornecedores da organização.

O contexto levantado informa que a EMColors atende aproximadamente de 5 a 8 pedidos por dia. Esse volume deve ser considerado como referência para construir uma massa de dados representativa da operação da gráfica.

## 14.1 Dados atualmente cadastrados

A implementação SQL atual contém os seguintes registros de exemplo:

| Tabela | Quantidade atual de registros |
|---|---:|
| `cliente` | 6 |
| `funcionario` | 6 |
| `fornecedor` | 3 |
| `tipo_produto` | 3 |
| `produto` | 5 |
| `insumo` | 4 |
| `pedido` | 6 |
| `pedido_produto` | 7 |
| `produto_insumo` | 15 |

## 14.2 Justificativa e evolução da massa de dados

A massa atual é inicial e permite verificar os relacionamentos básicos entre as tabelas. Entretanto, o volume de pedidos ainda é pequeno quando comparado à operação informada durante a pesquisa de campo.

Considerando a média de 5 a 8 pedidos por dia, será necessário ampliar os registros para contemplar diferentes períodos e situações operacionais.

A ampliação deverá considerar:

- Clientes que realizaram vários pedidos.
- Clientes cadastrados que ainda não possuem pedidos.
- Pedidos em diferentes etapas do processo.
- Pedidos concluídos e pedidos ainda em andamento.
- Diferentes formas de entrega.
- Produtos com diferentes níveis de procura.
- Insumos com quantidades variadas em estoque.
- Registros distribuídos em diferentes períodos.

A quantidade definitiva de registros deverá ser coerente com o volume de operação da EMColors, evitando tanto uma quantidade insuficiente para as consultas quanto uma massa artificialmente grande.

## 14.3 Integridade da Massa de Dados

Todos os registros devem respeitar os relacionamentos e as restrições definidas no banco de dados.

Os pedidos devem referenciar clientes existentes, os itens devem referenciar pedidos e produtos existentes e os insumos devem estar associados a fornecedores cadastrados.

Os dados devem permitir que as consultas gerenciais e de auditoria apresentem resultados úteis para a demonstração do sistema.

# 15. Dicionário de Dados

O dicionário de dados documenta a estrutura do banco de dados, descrevendo cada tabela, suas colunas, tipos de dados e restrições de integridade.

O dicionário conceitual preliminar desenvolvido na Entrega 1 serviu como referência para a identificação dos atributos e suas finalidades.

Para a Entrega 2, será necessário atualizar esse documento com a estrutura física definitiva, contemplando:

- Nome da tabela.
- Nome de cada coluna.
- Descrição e finalidade do atributo.
- Tipo de dado.
- Chave primária ou estrangeira.
- Obrigatoriedade (`NOT NULL`).
- Unicidade (`UNIQUE`).
- Valores permitidos (`ENUM` ou `CHECK`).
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
| `emcolors_for_mysql.sql` | Script SQL atual do banco de dados. |
| `relatório da entrevista.md` | Documento com o registro do levantamento realizado. |
| `img/` | Pasta destinada aos materiais visuais do projeto. |

## 16.2 Organização prevista para a entrega final

Para facilitar a avaliação e a localização dos documentos, recomenda-se organizar o repositório da seguinte maneira:

```text
emcolors-modelagem-bd/
│
├── README.md
│
├── img/
│   ├── der_conceitual.png
│   ├── modelo_logico.png
│   └── fluxograma_pedido.png
│
├── docs/
│   ├── emcolors_for_mysql.sql
│   └── dicionario_dados.html
│
├── levantamento/
│   ├── levantamento.md
│   ├── entrevista.jpg
│   └── visita_emcolors.jpg
│
└── apresentacao/
    ├── apresentacao_final.pptx
    └── apresentacao_final.pdf
```

A estrutura acima representa a organização recomendada para a entrega final. Os arquivos devem ser adicionados ao repositório antes que seus respectivos links sejam considerados definitivos.

## 16.3 Histórico de Desenvolvimento

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
| Prompts utilizados | "Analise esses dois trabalhos, e me pontue o que eu preciso adicionar no meu que é o do GitHub." Em seguida: "Faça as partes que você consegue fazer com esses documentos que já tem, para eu alterar no README do GitHub." Também foi solicitado um README completo, preservando as partes corretas e incorporando as alterações sugeridas. |
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

Na segunda etapa, o projeto evolui para a estrutura relacional e sua implementação em MySQL, utilizando tabelas específicas, chaves primárias, chaves estrangeiras e restrições de integridade. A organização das informações busca reduzir redundâncias, manter a consistência dos registros e permitir consultas que apoiem o acompanhamento da operação.

A implementação também apresenta possibilidades de evolução para análises gerenciais, permitindo acompanhar pedidos, produtos, clientes e quantidades de insumos. Com o amadurecimento da base de dados, essas informações poderão apoiar relatórios, indicadores e futuras aplicações de Business Intelligence e Inteligência Artificial.

Como evolução do projeto, destacam-se a revisão da compatibilidade entre o modelo conceitual e o SQL, a ampliação da massa de dados, a implementação das consultas gerenciais e de auditoria e a atualização do dicionário de dados.

Dessa forma, o projeto busca transformar necessidades identificadas na rotina da EMColors em uma estrutura organizada de informações, capaz de apoiar a gestão e contribuir para decisões mais consistentes.

# 19. Referências

Este trabalho foi desenvolvido com base nas seguintes fontes:

- **Pesquisa de campo:** visita presencial e entrevista com o gerente da EMColors, utilizadas para identificar processos, regras de negócio, equipe, produtos e dificuldades relacionadas ao estoque e ao cadastro de clientes.
- **Documentação do projeto:** modelo conceitual, DER, requisitos, regras de negócio e script SQL desenvolvidos pelo grupo.
- **Apoio de Inteligência Artificial:** utilização do Claude (Anthropic) e do ChatGPT para organização das informações, apoio à modelagem e revisão da documentação, conforme detalhado na seção 17.
- **Site institucional:** [EMColors](https://emcolors.com.br/).
- **Orientações acadêmicas:** documento de referência da Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final.
