[README (1).md](https://github.com/user-attachments/files/32312554/README.1.md)
# EMColors — Modelagem de Banco de Dados
diogo mariano frnça da silva
Modelagem conceitual de banco de dados para a gráfica EMColors, desenvolvida como Entrega 1 (Modelo Conceitual / DER) do trabalho acadêmico.

---

## Introdução

A gestão de pequenas empresas gráficas costuma acontecer no improviso: pedidos anotados em papel, estoque controlado "de olho" e clientes que somem do radar assim que a entrega é feita. Foi exatamente esse cenário que encontramos ao visitar a EMColors, uma gráfica especializada em adesivos, cartões e etiquetas, que atende de 5 a 8 pedidos por dia mas ainda não conta com nenhum sistema de gestão.

O problema que motivou este trabalho é bem concreto: a empresa tem dificuldade real no controle de estoque de insumos (tinta, papel e clichê) e não mantém nenhum cadastro de cliente depois que o pedido é entregue. Na prática, isso significa que a gráfica só percebe que está sem material quando o pedido já foi fechado, e precisa comprar às pressas — e que não existe histórico de quem já comprou o quê.

O objetivo deste trabalho é propor um modelo conceitual de banco de dados capaz de organizar essas informações: pedidos, itens, clientes, funcionários, produtos, fornecedores e insumos. A modelagem foi construída a partir de uma pesquisa de campo real, feita por meio de visita e entrevista com o gerente da EMColors, e está delimitada à etapa conceitual do projeto — ou seja, ao levantamento de requisitos, regras de negócio e ao Diagrama Entidade-Relacionamento (DER), sem entrar ainda na implementação física do banco de dados.

---

## Caracterização da Organização

- **Nome e natureza da organização:** EMColors, uma gráfica com fins lucrativos.
- **Contexto e porte:** empresa de pequeno/médio porte, com equipe de 5 operadores de máquina, 1 expedicionista, o gerente e duas colaboradoras no administrativo. Atende, em média, de 5 a 8 pedidos por dia.
- **Problemas e necessidades identificados:** dificuldade real no controle de estoque de insumos (tinta, papel/bobina e clichê) e ausência de cadastro de clientes após a conclusão da entrega — hoje os dados do cliente só são mantidos durante o andamento do pedido.
- **Justificativa da escolha:** a EMColors fica perto do local de trabalho de um dos integrantes do grupo, que possui conhecidos que trabalham na empresa, o que garantiu acesso facilitado para a pesquisa de campo.
- **Evidências da organização:** site oficial (https://emcolors.com.br/) e registro fotográfico da visita realizada com o gerente da empresa.

---

## Processos de Negócio

Principais processos mapeados: solicitação de orçamento, aprovação do orçamento com pagamento, produção do pedido, finalização e entrega ou retirada.

### Fluxograma do processo de pedido

<!-- Inserir aqui a imagem do fluxograma -->
<!-- ![Fluxograma do processo de pedido da EMColors](caminho/para/fluxograma.png) -->

O fluxo observado na visita segue a sequência: o cliente solicita um orçamento (feito em papel) → o orçamento é aprovado junto com o pagamento → o pedido entra em produção, sob responsabilidade de um operador de máquina → o pedido fica pronto → ocorre a entrega ou retirada, fechada pelo expedicionista responsável.

---

## Requisitos do Sistema

### Requisitos Funcionais

1. O sistema deve permitir registrar um orçamento vinculado a um cliente.
2. O sistema deve permitir registrar a aprovação do orçamento junto com o pagamento.
3. O sistema deve permitir registrar um pedido com um ou mais itens (produto + tipo de papel + quantidade em metros).
4. O sistema deve permitir atribuir um funcionário expedicionista responsável por fechar o pedido.
5. O sistema deve permitir atribuir um operador de máquina responsável pela produção do pedido.
6. O sistema deve permitir consultar a quantidade disponível de insumo (tinta, papel/bobina, clichê) antes de fechar um pedido.
7. O sistema deve permitir registrar entrada de insumos vinculada a um fornecedor.
8. O sistema deve permitir atualizar o status do pedido (orçamento, aprovado, em produção, pronto, entregue).

### Requisitos Não Funcionais

1. **Usabilidade:** interface simples, já que a operação é feita por poucos funcionários sem perfil técnico.
2. **Confiabilidade:** o controle de estoque deve refletir o saldo real dos insumos para evitar as faltas identificadas na pesquisa de campo.
3. **Desempenho:** consultas de estoque e cadastro de pedido devem responder de forma imediata durante o atendimento ao cliente.
4. **Disponibilidade:** o sistema deve estar acessível durante o horário de funcionamento da gráfica.

---

## Regras de Negócio

### Regras operacionais

- Um pedido pode conter um ou mais itens, cada um com produto, tipo de papel e quantidade em metros.
- A aprovação do orçamento ocorre junto com o pagamento (etapa única).
- Cada pedido tem um único operador responsável pela produção e um único expedicionista responsável pelo fechamento.
- Cada fornecedor está associado a apenas um tipo de insumo (tinta, papel/bobina ou clichê).

### Restrições organizacionais

- Atualmente não há verificação de estoque no fechamento do pedido, o que gera compras emergenciais — ponto identificado como problema central da organização.
- Dados do cliente não são mantidos após a entrega, o que hoje impede qualquer histórico de pedidos por cliente.
- O prazo de entrega varia conforme o pedido e não segue um padrão fixo.

---

## Dicionário de Dados Conceitual (Preliminar)

### Cliente

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_cliente | Identificador é o código exclusivo que representa aquele cliente dentro do sistema, servindo para diferenciá-lo dos demais mesmo que tenham nome ou telefone parecidos | Obrigatório |
| nome | Nome é o dado que identifica quem é a pessoa (ou empresa) que fez o pedido, usado no atendimento e no contato direto com o cliente (ex: "João Silva") | Obrigatório |
| telefone | Telefone é o número de contato do cliente, usado pela gráfica para avisar sobre o andamento do pedido, como quando ele fica pronto para retirada (ex: "(11) 90000-0000") | Obrigatório |

### Pedido

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_pedido | Identificador é o código exclusivo que representa aquele pedido específico, permitindo acompanhar seu andamento desde o orçamento até a entrega | Obrigatório |
| data_pedido | Data do pedido é o dia em que o cliente solicitou o orçamento pela primeira vez, usada como referência de quando o processo começou | Obrigatório |
| prazo_entrega | Prazo de entrega é a data combinada em que o pedido deve estar pronto para ser entregue ou retirado pelo cliente | Varia conforme o pedido |
| status | Status é a etapa em que o pedido se encontra dentro do fluxo de produção da gráfica, indicando se ele ainda está em orçamento, já foi aprovado, está em produção, está pronto ou já foi entregue | Obrigatório |
| valor_total | Valor total é a soma de todos os itens que compõem o pedido, correspondente à quantia que o cliente aprovou e pagou no momento da aprovação do orçamento | Registrado na aprovação |

### Item_Pedido

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_item | Identificador é o código exclusivo que representa cada item dentro de um pedido, permitindo que um mesmo pedido tenha mais de um produto diferente | Obrigatório |
| quantidade_metros | Quantidade é o conjunto de valor que informa quantos metros daquele produto foram solicitados pelo cliente, usado para calcular o consumo de papel e o preço do item (ex: 1000) | Obrigatório, sempre em metros |

### Produto

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_produto | Identificador é o código exclusivo que representa cada tipo de produto que a gráfica oferece | Obrigatório |
| nome | Nome é o dado que indica qual tipo de item a gráfica produz, ou seja, o que está sendo fabricado naquele pedido (ex: "Adesivo", "Cartão", "Etiqueta") | Obrigatório |

### Tipo_Papel

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_tipo_papel | Identificador é o código exclusivo que representa cada tipo de papel usado na produção | Obrigatório |
| nome | Nome é o dado que indica qual material de papel será usado na fabricação do item, influenciando o custo e o acabamento do produto final (ex: "Couché", "Contracolado") | Obrigatório |

### Funcionário

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_funcionario | Identificador é o código exclusivo que representa cada funcionário da gráfica | Obrigatório |
| nome | Nome é o dado que identifica a pessoa que trabalha na gráfica (ex: "Carlos Souza") | Obrigatório |
| cargo | Cargo é a função que o funcionário exerce dentro da gráfica, definindo qual responsabilidade ele tem no processo do pedido, como produzir ou fechar a entrega (ex: "Operador de máquina", "Expedicionista", "Gerente", "Administrativo") | Obrigatório |

### Fornecedor

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_fornecedor | Identificador é o código exclusivo que representa cada empresa que fornece insumos para a gráfica | Obrigatório |
| nome | Nome é o dado que identifica a empresa responsável por abastecer a gráfica com determinado insumo (ex: "Fornecedora XYZ Papéis") | Obrigatório |
| tipo_insumo | Tipo de insumo é a categoria do material que aquele fornecedor entrega para a gráfica, como tinta, papel ou clichê | Cada fornecedor fornece apenas um tipo |

### Insumo

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_insumo | Identificador é o código exclusivo que representa cada insumo utilizado na produção | Obrigatório |
| nome | Nome é o dado que identifica o material usado na fabricação dos produtos da gráfica (ex: "Tinta CMYK", "Bobina de papel couché") | Obrigatório |
| quantidade_estoque | Quantidade é o conjunto de valor que representa quanto daquele insumo existe fisicamente guardado no momento, usado para saber se há material suficiente antes de fechar um novo pedido | Hoje sem controle formal (problema identificado) |

---

## Modelagem Conceitual (Entidades, Atributos, Relacionamentos)

### Entidades reconhecidas

- **Cliente** — quem solicita o orçamento e o pedido.
- **Pedido** — o registro central do processo, do orçamento até a entrega.
- **Item_Pedido** — entidade associativa que representa cada produto solicitado dentro de um pedido.
- **Produto** — os tipos de item que a gráfica produz (adesivo, cartão, etiqueta).
- **Tipo_Papel** — os tipos de papel utilizados na produção (couché, contracolado).
- **Funcionário** — a equipe da EMColors, com diferentes cargos.
- **Fornecedor** — quem abastece a gráfica com insumos.
- **Insumo** — os materiais usados na produção (tinta, papel/bobina, clichê).

### Relacionamentos pertinentes

- Cliente (1) — (N) Pedido
- Funcionário (1) — (N) Pedido, na função de expedicionista (fecha o pedido)
- Funcionário (1) — (N) Pedido, na função de operador (produz o pedido)
- Pedido (1) — (N) Item_Pedido
- Produto (1) — (N) Item_Pedido
- Tipo_Papel (1) — (N) Item_Pedido
- Fornecedor (1) — (N) Insumo

**Restrições e políticas organizacionais aplicadas ao modelo:** cada fornecedor está limitado a um único tipo de insumo; cada pedido tem exatamente um operador e um expedicionista responsáveis; não existe, no processo atual, uma regra que impeça o fechamento do pedido sem estoque suficiente — essa limitação foi registrada como requisito funcional a ser implementado no sistema proposto.

---

## Diagrama Entidade-Relacionamento (DER)

<img width="1541" height="1020" alt="Diagrama de relacionamento" src="https://github.com/user-attachments/assets/058ddc88-6a85-4517-9fef-1e839207b752" />

O diagrama representa as oito entidades identificadas, seus atributos, os relacionamentos entre elas e as respectivas cardinalidades, conforme detalhado na seção de Modelagem Conceitual.

---

## Justificativa Técnica

**Por que essas entidades e não outras:** cada entidade corresponde a um objeto identificado diretamente na pesquisa de campo, não a uma abstração teórica. Cliente, Pedido, Funcionário e Fornecedor representam os atores e documentos que já existem no processo real da EMColors. Produto e Tipo_Papel foram separados em vez de uma única entidade "item genérico" porque a gráfica combina esses dois atributos de forma independente (um mesmo produto, como "Etiqueta", pode ser feito em diferentes papéis) — juntar os dois em um único campo obrigaria a repetir combinações e dificultaria consultas futuras, como calcular consumo de determinado papel.

**Por que Item_Pedido como entidade associativa:** a alternativa mais simples seria colocar produto e papel como atributos diretos do Pedido, mas isso impediria um pedido ter mais de um item — o que a entrevista confirmou ser real (ex: adesivos e cartões no mesmo pedido). Item_Pedido resolve o relacionamento N:N entre Pedido e Produto/Tipo_Papel, mantendo a granularidade de quantidade por item.

**Por que duas ligações entre Funcionário e Pedido:** optamos por representar separadamente quem fecha o pedido (expedicionista) e quem produz (operador), em vez de um único campo "funcionário responsável", porque são papéis funcionalmente distintos na organização real, com atribuições diferentes.

**Por que Fornecedor 1:N Insumo, e não Fornecedor:Insumo N:N:** a entrevista revelou que cada fornecedor está associado a exatamente um tipo de insumo (tinta, papel ou clichê). Um relacionamento N:N adicionaria complexidade sem espelhar a realidade observada, e poderia ser revisto futuramente caso a empresa passe a ter fornecedores múltiplos por insumo.

**Por que Cliente 1:N Pedido apesar do processo atual ser isolado:** embora hoje a EMColors não mantenha vínculo entre um cliente e seus pedidos anteriores, modelamos essa cardinalidade como 1:N porque é justamente uma das crises operacionais identificadas: a ausência de histórico do cliente. O modelo conceitual antecipa essa correção, demonstrando potencial de escalabilidade sem alterar o processo observado em campo.

**Por que não travamos o pedido por estoque no modelo atual:** a ausência de uma regra formal de verificação de estoque no fechamento do pedido reflete fielmente o que foi observado — é um problema real da organização, não uma omissão do modelo. Essa lacuna foi registrada como requisito funcional (verificação de estoque antes do fechamento) para a próxima etapa do sistema, e não como regra já implementada hoje.

---

## Uso de Inteligência Artificial

| Item | Descrição |
|---|---|
| **Ferramenta e etapa** | Utilizamos o Claude (Anthropic) durante praticamente todo o processo de elaboração deste README: organização do levantamento de requisitos feito na visita à EMColors, estruturação dos processos de negócio, elaboração do fluxograma e do Diagrama Entidade-Relacionamento (DER), e redação das seções de requisitos, regras de negócio, dicionário de dados e justificativa técnica. |
| **Motivação** | Após a pesquisa de campo, o grupo tinha as informações da entrevista de forma desorganizada. Recorremos à IA para nos ajudar a transformar essas respostas em uma estrutura conceitual coerente (entidades, atributos, relacionamentos e cardinalidades), além de gerar os diagramas exigidos pela entrega. |
| **Prompt(s) utilizados** | O grupo conduziu uma entrevista guiada, respondendo perguntas feitas pela IA sobre a organização (EMColors), seus processos, regras de negócio, produtos e equipe, uma pergunta por vez. Também foram feitos pedidos diretos como "monte o fluxograma do processo de pedido" e "monte o DER com base nessas respostas". |
| **Resposta recebida** | A IA propôs uma modelagem inicial com oito entidades (Cliente, Pedido, Item_Pedido, Produto, Tipo_Papel, Funcionário, Fornecedor e Insumo), suas cardinalidades, o fluxograma do processo de pedido e um rascunho de requisitos funcionais, não funcionais e regras de negócio. |
| **Fontes consultadas e verificadas** | Não houve consulta a fontes externas nesta etapa, já que o conteúdo teve como base exclusivamente as respostas fornecidas pelo grupo a partir da pesquisa de campo na EMColors. |
| **Trechos rejeitados ou corrigidos** | Corrigimos alguns pontos ao longo da conversa, como o cargo correto de quem fecha o pedido (expedicionista, e não atendente) e a forma como o pagamento se relaciona com a aprovação do orçamento (etapa única, em vez de duas etapas separadas). |
| **Justificativa da escolha final** | Mantivemos a estrutura de entidades proposta por refletir fielmente o que foi observado na visita, especialmente a separação entre Produto e Tipo_Papel e a entidade associativa Item_Pedido, que representa corretamente a possibilidade de um pedido conter mais de um item. |
| **Reflexão crítica** | A IA depende inteiramente das informações fornecidas pelo grupo, então qualquer imprecisão na entrevista de campo se refletiria diretamente na modelagem — por isso revisamos cada resposta antes de seguir adiante. Também identificamos que a primeira versão do DER, gerada em HTML, teve um problema de contraste de cores que dificultava a leitura, sendo necessário solicitar um ajuste visual. |

---

## Conclusão

Esse trabalho mostrou, na prática, uma coisa que a gente só entende de verdade quando sai da teoria: modelar um banco de dados não é sentar e desenhar caixinhas, é primeiro entender como a empresa realmente funciona no dia a dia. Boa parte do tempo foi gasto conversando com o gerente da EMColors e entendendo detalhes que pareciam pequenos — como o fato de o pagamento acontecer junto com a aprovação do orçamento, ou de existir um fornecedor específico para cada tipo de insumo — mas que mudam completamente como as entidades e os relacionamentos deveriam ser desenhados.

A principal contribuição deste projeto foi transformar dois problemas concretos da gráfica — a falta de controle de estoque e a ausência de histórico de clientes — em decisões de modelagem justificadas, como a entidade Item_Pedido (que permite um pedido ter vários produtos) e o relacionamento entre Cliente e Pedido pensado para já suportar histórico, mesmo que hoje a empresa não use isso na prática.

Como aprendizado, o grupo percebeu como é fácil modelar "no achismo" quando não se tem contato direto com quem opera o negócio, e como pequenos detalhes da entrevista (como a diferença entre o expedicionista e o operador) fazem toda a diferença na hora de definir cardinalidades corretas. Como trabalho futuro, o modelo pode evoluir para incluir controle mais detalhado de estoque com alertas de reposição, histórico de pedidos por cliente e regras que impeçam o fechamento de um pedido sem insumo suficiente — resolvendo de fato o problema que deu origem a este projeto.

---

## Referências Bibliográficas

Este trabalho não se baseou em bibliografia externa. O conteúdo foi construído a partir de duas fontes principais:

Pesquisa de campo: visita presencial e entrevista com o gerente da EMColors, que forneceu as informações sobre processos, regras de negócio, equipe e estoque utilizadas na modelagem.
Apoio de Inteligência Artificial: uso do Claude (Anthropic) para organizar as respostas da entrevista em uma estrutura conceitual, conforme detalhado na seção "Uso de Inteligência Artificial".

Site institucional consultado como evidência da organização: https://emcolors.com.br/
