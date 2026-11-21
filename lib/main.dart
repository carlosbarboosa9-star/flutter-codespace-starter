import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xslvbtgzdwtcgpkxsova.supabase.co',
    publishableKey: 'sb_publishable_jXLumyz8xOFPgC-rqZoxlA_rdZXKfcI',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAVICA ALIMENTOS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC62828),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF5),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String categoriaSelecionada = 'Todos';

  final Map<String, Map<String, dynamic>> carrinho = {};

  final List<String> categorias = [
    'Todos',
    'Arroz, feijão e grãos',
    'Massas e farinhas',
    'Óleos e temperos',
    'Enlatados e conservas',
    'Biscoitos e doces',
    'Bebidas',
    'Higiene pessoal',
    'Limpeza',
    'Outros alimentos',
  ];

  int get totalItens {
    return carrinho.values.fold<int>(
      0,
      (total, item) =>
          total + (item['quantidade'] as int),
    );
  }

  num get valorTotal {
    return carrinho.values.fold<num>(
      0,
      (total, item) =>
          total +
          (item['preco'] as num) *
              (item['quantidade'] as int),
    );
  }
void adicionarProduto(
  String nome,
  num preco,
  num? estoque, {
  required String itemId,
  required String tipo,
}) {
  final chave = '$tipo:$itemId';
  final itemAtual = carrinho[chave];

  final quantidadeAtual = itemAtual == null
      ? 0
      : itemAtual['quantidade'] as int;

  if (estoque != null && quantidadeAtual >= estoque) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Quantidade disponível em estoque atingida.',
        ),
      ),
    );
    return;
  }

  setState(() {
    if (itemAtual == null) {
      carrinho[chave] = {
        'nome': nome,
        'preco': preco,
        'estoque': estoque,
        'quantidade': 1,
        'item_id': itemId,
        'tipo': tipo,
      };
    } else {
      itemAtual['quantidade'] = quantidadeAtual + 1;
    }
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$nome adicionado ao carrinho!'),
      duration: const Duration(seconds: 1),
    ),
  );
}

  void diminuirProduto(String nome) {
    setState(() {
      final item = carrinho[nome];

      if (item == null) return;

      final quantidade = item['quantidade'] as int;

      if (quantidade <= 1) {
        carrinho.remove(nome);
      } else {
        item['quantidade'] = quantidade - 1;
      }
    });
  }

  void removerProduto(String nome) {
    setState(() {
      carrinho.remove(nome);
    });
  }

  void abrirCarrinho() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CartPage(
        carrinho: carrinho,
        onAdd: (chave) {
          final item = carrinho[chave];

          if (item != null) {
            adicionarProduto(
              item['nome'] as String,
              item['preco'] as num,
              item['estoque'] as num?,
              itemId: item['item_id'] as String,
              tipo: item['tipo'] as String,
            );
          }
        },
        onRemove: diminuirProduto,
        onDelete: removerProduto,
      ),
    ),
  ).then((_) {
    if (mounted) {
      setState(() {});
    }
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        title: const Text(
          'MAVICA ALIMENTOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Minha conta',
            onPressed: () {
              final usuario = supabase.auth.currentUser;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => usuario != null
                      ? const AccountPage()
                      : const RegisterPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              size: 27,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Meu carrinho',
              onPressed: abrirCarrinho,
              icon: Badge(
                label: Text('$totalItens'),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 27,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEJA BEM-VINDO!',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Economia e qualidade para sua família.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Conheça nossas cestas básicas e produtos.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Nossos produtos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 14),

            Card(
              color: const Color(0xFFFFF1C2),
              child: ListTile(
                onTap: abrirCarrinho,
                leading: const Icon(
                  Icons.shopping_cart,
                  color: Color(0xFFC62828),
                ),
                title: const Text(
                  'Meu carrinho',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Itens: $totalItens | Total: R\$ ${valorTotal.toStringAsFixed(2)}',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFFC62828),
                ),
              ),
            ),

            const SizedBox(height: 14),

            FutureBuilder(
             future: supabase
    .from('products')
    .select(
      'id, name, sale_price, stock_quantity, category',
    )
    .eq('is_active', true)
    .order('name'),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Erro ao carregar produtos: ${snapshot.error}',
                  );
                }

                final produtos = snapshot.data ?? [];

                if (produtos.isEmpty) {
                  return const Text(
                    'Nenhum produto cadastrado.',
                  );
                }

                final produtosFiltrados =
                    categoriaSelecionada == 'Todos'
                        ? produtos
                        : produtos.where((produto) {
                            return produto['category'] ==
                                categoriaSelecionada;
                          }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categorias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categorias.map((categoria) {
                        final selecionada =
                            categoriaSelecionada == categoria;

                        return ChoiceChip(
                          label: Text(categoria),
                          selected: selecionada,
                          selectedColor:
                              const Color(0xFFC62828),
                          backgroundColor:
                              const Color(0xFFFFF1C2),
                          labelStyle: TextStyle(
                            color: selecionada
                                ? Colors.white
                                : const Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selecionado) {
                            setState(() {
                              categoriaSelecionada = categoria;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      categoriaSelecionada == 'Todos'
                          ? 'Todos os produtos'
                          : categoriaSelecionada,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (produtosFiltrados.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nenhum produto encontrado nesta categoria.',
                        ),
                      ),

                    ...produtosFiltrados.map<Widget>((produto) {
                      final nome =
                          produto['name'] ?? 'Produto';

                      final preco =
                          (produto['sale_price'] as num?) ?? 0;

                      final estoque =
                          (produto['stock_quantity'] as num?) ?? 0;

                      final chave = nome.toString();

                      final quantidadeNoCarrinho =
                          carrinho[chave]?['quantidade'] as int? ?? 0;

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailsPage(
        nome: nome.toString(),
        preco: preco.toDouble(),
        estoque: estoque.toDouble(),
      ),
    ),
  );
},
                          leading: const CircleAvatar(
                            backgroundColor:
                                Color(0xFFFFF1C2),
                            child: Icon(
                              Icons.shopping_basket,
                              color: Color(0xFFC62828),
                            ),
                          ),
                          title: Text(
                            nome.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                         subtitle: Text(
  estoque <= 0
      ? 'INDISPONÍVEL'
      : 'Disponível | No carrinho: $quantidadeNoCarrinho',
  style: TextStyle(
    color: estoque <= 0 ? Colors.red : Colors.grey[700],
    fontWeight:
        estoque <= 0 ? FontWeight.bold : FontWeight.normal,
  ),
),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R\$ ${preco.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC62828),
                                ),
                              ),
                              IconButton(
  tooltip: estoque <= 0
      ? 'Produto indisponível'
      : 'Adicionar ao carrinho',
  icon: Icon(
    estoque <= 0
        ? Icons.remove_shopping_cart
        : Icons.add_shopping_cart,
    color: estoque <= 0
        ? Colors.grey
        : const Color(0xFFC62828),
  ),
  onPressed: estoque <= 0
      ? null
      : () {
          adicionarProduto(
            chave,
            preco,
            estoque,
            itemId: produto['id'].toString(),
            tipo: 'product',
          );
        },
),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            const Text(
              'Nossas cestas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 14),

            FutureBuilder(
              future: supabase
                  .from('baskets')
                  .select('id, name, description, sale_price')
                  .eq('is_active', true)
                  .order('name'),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Erro ao carregar cestas: ${snapshot.error}',
                  );
                }

                final cestas = snapshot.data ?? [];

                if (cestas.isEmpty) {
                  return const Text(
                    'Nenhuma cesta cadastrada.',
                  );
                }

                return Column(
                  children: cestas.map<Widget>((cesta) {
                    final nome = cesta['name'] as String;

                    final preco =
                        (cesta['sale_price'] as num?) ?? 0;

                    final descricaoBanco =
                        cesta['description'] as String?;

                    final descricao =
                        descricaoBanco != null &&
                                descricaoBanco.trim().isNotEmpty
                            ? descricaoBanco
                            : 'Uma opção para sua família.';

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.all(14),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF1C2),
                          child: Icon(
                            Icons.shopping_basket,
                            color: Color(0xFFC62828),
                          ),
                        ),
                        title: Text(
                          nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '$descricao\nR\$ ${preco.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
  tooltip: 'Adicionar cesta ao carrinho',
  icon: const Icon(
    Icons.add_shopping_cart,
    color: Color(0xFFC62828),
  ),
  onPressed: () {
    adicionarProduto(
      nome,
      preco,
      null,
      itemId: cesta['id'].toString(),
      tipo: 'basket',
    );
  },
),
                        ),
                      );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'MAVICA ALIMENTOS',
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ProductDetailsPage extends StatelessWidget {
  final String nome;
  final double preco;
  final double estoque;

  const ProductDetailsPage({
    super.key,
    required this.nome,
    required this.preco,
    required this.estoque,
  });

  @override
  Widget build(BuildContext context) {
    final disponivel = estoque > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      appBar: AppBar(
        title: const Text('Detalhes do produto'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.shopping_basket,
              size: 100,
              color: Color(0xFFC62828),
            ),
            const SizedBox(height: 25),
            Text(
              nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFFC62828),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                disponivel ? 'DISPONÍVEL' : 'INDISPONÍVEL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: disponivel ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'MAVICA ALIMENTOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC62828),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class CartPage extends StatefulWidget {
  
  final Map<String, Map<String, dynamic>> carrinho;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDelete;

  const CartPage({
    super.key,
    required this.carrinho,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void adicionar(String nome) {
    widget.onAdd(nome);
    setState(() {});
  }

  void diminuir(String nome) {
    widget.onRemove(nome);
    setState(() {});
  }

  void excluir(String nome) {
    widget.onDelete(nome);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = widget.carrinho;
    final produtos = carrinho.entries.toList();

    final total = carrinho.values.fold<num>(
      0,
      (soma, item) =>
          soma +
          (item['preco'] as num) *
              (item['quantidade'] as int),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu carrinho',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: carrinho.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Color(0xFFC62828),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seu carrinho está vazio.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Adicione produtos para começar suas compras.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                   itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final entry = produtos[index];
final chave = entry.key;
final item = entry.value;
final nome = item['nome'] as String;
                      final quantidade = item['quantidade'] as int;
                      final preco = item['preco'] as num;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'R\$ ${preco.toStringAsFixed(2)} cada',
                          ),
                          leading: IconButton(
  icon: const Icon(Icons.remove),
  onPressed: () => diminuir(chave),
),
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('$quantidade'),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => adicionar(chave),
    ),
    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => excluir(chave),
    ),
  ],
),
                        ),
                      );
                    },
                  ),
                ),
                
Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Subtotal: R\$ ${total.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          color: Color(0xFFC62828),
        ),
      ),
      const SizedBox(height: 15),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon( 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutPage(
                  carrinho: carrinho,
                ),
              ),
            );
          },
          icon: const Icon(Icons.shopping_bag),
          label: const Text('Finalizar compra'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    ],
  ),
),

              ],
            ),
    );
  }
}


class CheckoutPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> carrinho;

  const CheckoutPage({
    super.key,
    required this.carrinho,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String recebimento = 'entrega';
  String pagamento = 'pix';

  bool carregando = true;
  bool salvando = false;

  Map<String, dynamic>? endereco;

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final bairroController = TextEditingController();
  final referenciaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarEndereco();
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    referenciaController.dispose();
    super.dispose();
  }

  Future<void> carregarEndereco() async {
    final usuario = supabase.auth.currentUser;

    if (usuario == null) {
      setState(() => carregando = false);
      return;
    }

    try {
      final dados = await supabase
          .from('customer_addresses')
          .select()
          .eq('customer_id', usuario.id)
          .maybeSingle();

      if (dados != null) {
        endereco = dados;
        nomeController.text = dados['recipient_name'] ?? '';
        telefoneController.text = dados['phone'] ?? '';
        cepController.text = dados['postal_code'] ?? '';
        ruaController.text = dados['street'] ?? '';
        numeroController.text = dados['number'] ?? '';
        complementoController.text = dados['complement'] ?? '';
        bairroController.text = dados['neighborhood'] ?? '';
        referenciaController.text = dados['reference'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar endereço: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => carregando = false);
    }
  }

  num get subtotal {
    return widget.carrinho.values.fold<num>(
      0,
      (soma, item) =>
          soma +
          (item['preco'] as num) *
              (item['quantidade'] as int),
    );
  }

  num get taxaEntrega => recebimento == 'entrega' ? 3.00 : 0.00;

  num get total => subtotal + taxaEntrega;

  Future<void> finalizarCompra() async {
  final usuario = supabase.auth.currentUser;

  if (usuario == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Faça login para realizar o pedido.'),
      ),
    );
    return;
  }

  if (widget.carrinho.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seu carrinho está vazio.'),
      ),
    );
    return;
  }

  if (recebimento == 'entrega') {
    if (nomeController.text.trim().isEmpty ||
        ruaController.text.trim().isEmpty ||
        numeroController.text.trim().isEmpty ||
        bairroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome, rua, número e bairro.'),
        ),
      );
      return;
    }
  }

  setState(() => salvando = true);

  try {
    String? enderecoId;

    // 1. Salvar ou atualizar o endereço de entrega.
    if (recebimento == 'entrega') {
      final dadosEndereco = {
        'customer_id': usuario.id,
        'recipient_name': nomeController.text.trim(),
        'phone': telefoneController.text.trim(),
        'postal_code': cepController.text.trim(),
        'street': ruaController.text.trim(),
        'number': numeroController.text.trim(),
        'complement': complementoController.text.trim(),
        'neighborhood': bairroController.text.trim(),
        'city': 'Londrina',
        'state': 'PR',
        'reference': referenciaController.text.trim(),
      };

      if (endereco != null) {
        final atualizado = await supabase
            .from('customer_addresses')
            .update(dadosEndereco)
            .eq('id', endereco!['id'])
            .eq('customer_id', usuario.id)
            .select('id')
            .single();

        enderecoId = atualizado['id'].toString();
      } else {
        final cadastrado = await supabase
            .from('customer_addresses')
            .insert(dadosEndereco)
            .select('id')
            .single();

        enderecoId = cadastrado['id'].toString();
      }
    }

    
      // 2. Preparar os itens para a função do Supabase.
      final itens = widget.carrinho.values.map((item) {
        return {
          'item_type': item['tipo'],
          'item_id': item['item_id'],
          'quantity': item['quantidade'],
        };
      }).toList();

      // 3. Registrar o pedido e todos os itens em uma única transação.
      final pedido = await supabase.rpc(
        'create_order_with_items',
        params: {
          'p_fulfillment': recebimento,
          'p_address_id': enderecoId,
          'p_payment_method': pagamento,
          'p_items': itens,
          'p_customer_notes': null,
        },
      );


    if (!mounted) return;

// Limpar o carrinho após salvar o pedido.
widget.carrinho.clear();

// Atualizar a tela principal.
setState(() {});

// 4. Mostrar confirmação.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pedido realizado!'),
        content: Text(
          'Seu pedido nº ${pedido['order_number']} foi registrado com sucesso.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
            child: const Text('Voltar à loja'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível registrar o pedido: $e'),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => salvando = false);
    }
  }
}
  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar compra'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forma de recebimento',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile<String>(
              title: const Text('Entrega — R\$ 3,00'),
              value: 'entrega',
              groupValue: recebimento,
              onChanged: (valor) {
                setState(() => recebimento = valor!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Retirada — Grátis'),
              value: 'retirada',
              groupValue: recebimento,
              onChanged: (valor) {
                setState(() => recebimento = valor!);
              },
            ),
            if (recebimento == 'entrega') ...[
              const Divider(height: 30),
              const Text(
                'Endereço de entrega',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (endereco != null)
                const Text(
                  'Endereço cadastrado. Você pode atualizar os dados abaixo.',
                ),
              campo('Nome do destinatário', nomeController),
              campo('Telefone', telefoneController),
              campo('CEP', cepController),
              campo('Rua', ruaController),
              campo('Número', numeroController),
              campo('Complemento', complementoController),
              campo('Bairro', bairroController),
              campo('Referência', referenciaController),
            ],
            const Divider(height: 30),
            const Text(
              'Forma de pagamento',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile<String>(
              title: const Text('Pix'),
              value: 'pix',
              groupValue: pagamento,
              onChanged: (valor) {
                setState(() => pagamento = valor!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dinheiro'),
              value: 'dinheiro',
              groupValue: pagamento,
              onChanged: (valor) {
                setState(() => pagamento = valor!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Cartão de débito'),
              value: 'debito',
              groupValue: pagamento,
              onChanged: (valor) {
                setState(() => pagamento = valor!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Cartão de crédito'),
              value: 'credito',
              groupValue: pagamento,
              onChanged: (valor) {
                setState(() => pagamento = valor!);
              },
            ),
            const Divider(height: 30),
            const Text(
              'Resumo do pedido',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            resumo('Subtotal', subtotal),
            resumo('Entrega', taxaEntrega),
            const Divider(),
            resumo('TOTAL', total, destaque: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvando ? null : finalizarCompra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Confirmar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campo(String titulo, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget resumo(String titulo, num valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight:
                  destaque ? FontWeight.bold : FontWeight.normal,
              fontSize: destaque ? 21 : 16,
            ),
          ),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight:
                  destaque ? FontWeight.bold : FontWeight.normal,
              fontSize: destaque ? 21 : 16,
              color: destaque ? const Color(0xFFC62828) : null,
            ),
          ),
        ],
      ),
    );
  }
}

// NOVA TELA DE CADASTRO
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;
  bool ocultarSenha = true;

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      final resposta = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: senhaController.text,
        data: {
          'full_name': nomeController.text.trim(),
          'phone': telefoneController.text.trim(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resposta.session != null
                ? "Cadastro realizado com sucesso! Você já pode acessar sua conta."
                : "Cadastro recebido! Se já possui conta, escolha Entrar. Se for novo cadastro, confirme o e-mail caso solicitado.",
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $erro')),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha conta'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.person_add_alt_1,
                size: 70,
                color: Color(0xFFC62828),
              ),
              const SizedBox(height: 16),
              const Text(
                'Criar minha conta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (valor) =>
                    valor == null || valor.trim().isEmpty
                        ? 'Informe seu nome completo'
                        : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (valor) =>
                    valor == null ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                .hasMatch(valor.trim())
                        ? 'Informe um e-mail válido'
                        : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: senhaController,
                obscureText: ocultarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarSenha
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarSenha = !ocultarSenha;
                      });
                    },
                  ),
                ),
                validator: (valor) =>
                    valor == null || valor.length < 6
                        ? 'A senha precisa ter pelo menos 6 caracteres'
                        : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: carregando ? null : cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                  ),
                  child: carregando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "CRIAR CONTA",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  "Já tem uma conta? Entrar",
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;
  bool ocultarSenha = true;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    if (emailController.text.trim().isEmpty ||
        senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o e-mail e a senha.')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );

      Navigator.pop(context);
    } on AuthException catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível entrar: ${erro.message}')),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorreu um erro. Tente novamente.')),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar na MAVICA'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 75,
                  color: Color(0xFFC62828),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo de volta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: senhaController,
                  obscureText: ocultarSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          ocultarSenha = !ocultarSenha;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: carregando ? null : entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                    ),
                    child: carregando
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'ENTRAR',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool carregando = true;
  String nome = '';
String telefone = '';
String email = '';
bool administrador = false;
String? erro;
  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    final usuario = supabase.auth.currentUser;

    if (usuario == null) {
      if (!mounted) return;
      setState(() {
        erro = 'Você precisa entrar na sua conta.';
        carregando = false;
      });
      return;
    }

    try {
      final perfil = await supabase
          .from('profiles')
          .select('full_name, phone, role, is_active')
          .eq('id', usuario.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
  nome = perfil?['full_name'] ?? 'Nome não informado';
  telefone = perfil?['phone'] ?? 'Telefone não informado';
  email = usuario.email ?? 'E-mail não informado';

  final cargo = perfil?['role']?.toString();
  final ativo = perfil?['is_active'] == true;

  administrador = ativo &&
      (cargo == 'admin_geral' || cargo == 'admin_operacional');

  carregando = false;
});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível carregar seus dados.';
        carregando = false;
      });
    }
  }

  
  Future<void> editarDados() async {
    final usuario = supabase.auth.currentUser;

    if (usuario == null) return;

    final nomeController = TextEditingController(text: nome);
    final telefoneController = TextEditingController(
      text: telefone == 'Telefone não informado' ? '' : telefone,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar meus dados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              
              onPressed: () async {
                final novoNome = nomeController.text.trim();
                final novoTelefone = telefoneController.text.trim();

                if (novoNome.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe seu nome completo.'),
                    ),
                  );
                  return;
                }

                try {
                  await supabase.from('profiles').update({
                    'full_name': novoNome,
                    'phone': novoTelefone.isEmpty ? null : novoTelefone,
                  }).eq('id', usuario.id);

                  if (!mounted) return;
                  if (!dialogContext.mounted) return;

                  setState(() {
                    nome = novoNome;
                    telefone = novoTelefone.isEmpty
                        ? 'Telefone não informado'
                        : novoTelefone;
                  });

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados atualizados com sucesso!'),
                    ),
                  );
                } catch (e) {
                  if (!mounted || !dialogContext.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível atualizar os dados.'),
                    ),
                  );
                }
              },

              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );

    nomeController.dispose();
    telefoneController.dispose();
  }

  Future<void> sairDaConta() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você saiu da sua conta.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        title: const Text('Minha conta'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(child: Text(erro!))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 90,
                        color: Color(0xFFC62828),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'MEUS DADOS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Nome completo'),
                        subtitle: Text(nome),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('E-mail'),
                        subtitle: Text(email),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Telefone'),
                        subtitle: Text(telefone),
                      ),

                                           ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrdersPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text('MEUS PEDIDOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 12),
if (administrador) ...[
  ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminPage(),
        ),
      );
    },
    icon: const Icon(Icons.admin_panel_settings),
    label: const Text('PAINEL ADMINISTRATIVO'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF333333),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(16),
    ),
  ),
  const SizedBox(height: 12),
],
                      ElevatedButton.icon(
                        onPressed: editarDados,
                        icon: const Icon(Icons.edit),
                        label: const Text('EDITAR DADOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: sairDaConta,

                        icon: const Icon(Icons.logout),
                        label: const Text('SAIR DA CONTA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool carregando = true;
  String? erro;
  List<Map<String, dynamic>> pedidos = [];String? pedidoConfirmandoId;

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  Future<void> carregarPedidos() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final usuario = supabase.auth.currentUser;

      if (usuario == null) {
        throw Exception('Você precisa entrar na sua conta.');
      }

      final resposta = await supabase
          .from('orders')
          .select(
            'order_number, status, fulfillment, total, payment_status, created_at',
          )
          .eq('customer_id', usuario.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        pedidos = List<Map<String, dynamic>>.from(resposta);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = 'Não foi possível carregar seus pedidos: $e';
        carregando = false;
      });
    }
  }

  String nomeStatus(String? status) {
    const nomes = {
      'aguardando_confirmacao': 'Aguardando confirmação',
      'confirmado': 'Confirmado',
      'em_preparacao': 'Em preparação',
      'pronto_para_retirada': 'Pronto para retirada',
      'saiu_para_entrega': 'Saiu para entrega',
      'concluido': 'Concluído',
      'cancelado': 'Cancelado',
    };

    return nomes[status] ?? status ?? 'Não informado';
  }

  String nomePagamento(String? pagamento) {
    const nomes = {
      'pendente': 'Pendente',
      'pago': 'Pago',
      'estornado': 'Estornado',
      'falhou': 'Falhou',
    };

    return nomes[pagamento] ?? pagamento ?? 'Não informado';
  }

  String nomeEntrega(String? entrega) {
    const nomes = {
      'entrega': 'Entrega',
      'retirada': 'Retirada',
    };

    return nomes[entrega] ?? entrega ?? 'Não informado';
  }

  String formatarData(dynamic data) {
    if (data == null) return 'Data não informada';

    final dataPedido = DateTime.parse(data.toString()).toLocal();

    final dia = dataPedido.day.toString().padLeft(2, '0');
    final mes = dataPedido.month.toString().padLeft(2, '0');
    final ano = dataPedido.year;
    final hora = dataPedido.hour.toString().padLeft(2, '0');
    final minuto = dataPedido.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano às $hora:$minuto';
  }

  String formatarValor(dynamic valor) {
    final numero = num.tryParse(valor.toString()) ?? 0;
    final partes = numero.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        title: const Text('Meus pedidos'),
        actions: [
          IconButton(
            onPressed: carregarPedidos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar pedidos',
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFC62828),
                        ),
                        const SizedBox(height: 12),
                        Text(erro!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: carregarPedidos,
                          child: const Text('TENTAR NOVAMENTE'),
                        ),
                      ],
                    ),
                  ),
                )
              : pedidos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 75,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Você ainda não possui pedidos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Seus pedidos aparecerão aqui quando você realizar uma compra.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: carregarPedidos,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pedido #${pedido['order_number'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formatarData(pedido['created_at']),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  Text(
                                    'Valor total: ${formatarValor(pedido['total'])}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Recebimento: ${nomeEntrega(pedido['fulfillment']?.toString())}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pedido: ${nomeStatus(pedido['status']?.toString())}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pagamento: ${nomePagamento(pedido['payment_status']?.toString())}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}



class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool carregando = true;
  String? erro;
  List<Map<String, dynamic>> pedidos = [];  String? pedidoConfirmandoId;

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  Future<void> carregarPedidos() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resposta = await supabase
          .from('orders')
          .select(
  'id, order_number, customer_id, status, fulfillment, total, '
  'payment_status, payment_method, created_at, '
  'customer:profiles(full_name, phone), '
'address:customer_addresses(recipient_name, phone, postal_code, street, number, complement, neighborhood, city, state, reference), '
'items:order_items(id, item_description, quantity, unit_price, line_total)',
)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        pedidos = List<Map<String, dynamic>>.from(resposta);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = 'Não foi possível carregar os pedidos: $e';
        carregando = false;
      });
    }
  }

  String formatarValor(dynamic valor) {
    final numero = num.tryParse(valor.toString()) ?? 0;
    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

Future<void> confirmarPedido(String pedidoId) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar pedido'),
      content: const Text(
        'Deseja confirmar este pedido? O estoque será verificado '
        'e atualizado automaticamente.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('CONFIRMAR'),
        ),
      ],
    ),
  );

  if (confirmar != true || !mounted) return;

  setState(() {
    pedidoConfirmandoId = pedidoId;
  });

  try {
    await supabase.rpc(
      'confirm_order_with_stock',
      params: {
        'p_order_id': pedidoId,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedido confirmado e estoque atualizado!'),
        backgroundColor: Colors.green,
      ),
    );

    await carregarPedidos();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível confirmar: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        pedidoConfirmandoId = null;
      });
    }
  }
}

  Future<void> atualizarStatusPedido(
    String pedidoId,
    String novoStatus,
  ) async {
    setState(() {
      pedidoConfirmandoId = pedidoId;
    });

    try {
      await supabase
          .from('orders')
          .update({'status': novoStatus})
          .eq('id', pedidoId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status do pedido atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      await carregarPedidos();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível atualizar o status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          pedidoConfirmandoId = null;
        });
      }
    }
  }
  
      String nomeStatus(String? status) {
    const nomes = {
      'aguardando_confirmacao': 'Aguardando confirmação',
      'confirmado': 'Confirmado',
      'em_preparacao': 'Em preparação',
      'pronto_para_retirada': 'Pronto para retirada',
      'saiu_para_entrega': 'Saiu para entrega',
      'concluido': 'Concluído',
      'cancelado': 'Cancelado',
    };

    return nomes[status] ?? status ?? 'Não informado';
  }
String nomePagamento(String? pagamento) {
  const nomes = {
    'pix': 'Pix',
    'dinheiro': 'Dinheiro',
    'debito': 'Cartão de débito',
    'credito': 'Cartão de crédito',
  };

  return nomes[pagamento] ?? pagamento ?? 'Não informado';
}

String nomeRecebimento(String? recebimento) {
  const nomes = {
    'entrega': 'Entrega',
    'retirada': 'Retirada',
  };

  return nomes[recebimento] ?? recebimento ?? 'Não informado';
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel administrativo'),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: carregarPedidos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar pedidos',
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      erro!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : pedidos.isEmpty
                  ? const Center(
                      child: Text('Nenhum pedido encontrado.'),
                    )
                  : RefreshIndicator(
                      onRefresh: carregarPedidos,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pedido #${pedido['order_number'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Total: ${formatarValor(pedido['total'])}',
                                  ),
                                  const SizedBox(height: 10),

Text(
  'Cliente: ${pedido['customer']?['full_name'] ?? 'Não informado'}',
  style: const TextStyle(fontWeight: FontWeight.bold),
),

Text(
  'Telefone: ${pedido['customer']?['phone'] ?? 'Não informado'}',
),
Text(
  'Pagamento: ${nomePagamento(pedido['payment_method']?.toString())}',
),

Text(
  'Recebimento: ${nomeRecebimento(pedido['fulfillment']?.toString())}',
),
if (pedido['fulfillment'] == 'entrega') ...[
  const SizedBox(height: 10),

  const Text(
    'ENDEREÇO DE ENTREGA:',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),

  Text(
    'Destinatário: ${pedido['address']?['recipient_name'] ?? 'Não informado'}',
  ),

  Text(
    'Rua: ${pedido['address']?['street'] ?? ''}, '
    '${pedido['address']?['number'] ?? ''}',
  ),

  Text(
    'Bairro: ${pedido['address']?['neighborhood'] ?? ''}',
  ),

  Text(
    'Cidade: ${pedido['address']?['city'] ?? ''} - '
    '${pedido['address']?['state'] ?? ''}',
  ),

  Text(
    'CEP: ${pedido['address']?['postal_code'] ?? ''}',
  ),

  if ((pedido['address']?['complement'] ?? '').toString().isNotEmpty)
    Text('Complemento: ${pedido['address']?['complement']}'),

  if ((pedido['address']?['reference'] ?? '').toString().isNotEmpty)
    Text('Referência: ${pedido['address']?['reference']}'),
],

const SizedBox(height: 10),

const SizedBox(height: 10),

const Text(
  'ITENS DO PEDIDO:',
  style: TextStyle(fontWeight: FontWeight.bold),
),

...((pedido['items'] as List<dynamic>?) ?? []).map((item) {
  final quantidade = item['quantity'] ?? 0;
  final descricao = item['item_description'] ?? 'Item';
  final totalItem = item['line_total'] ?? 0;

  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      '$quantidade x $descricao — ${formatarValor(totalItem)}',
    ),
  );
}),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Status: ${nomeStatus(pedido['status']?.toString())}',
                                  ),
                                  const SizedBox(height: 12),
                                  if (pedido['status'] ==
                                      'aguardando_confirmacao')
                                    SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: pedidoConfirmandoId != null
        ? null
        : () => confirmarPedido(pedido['id'].toString()),
    icon: const Icon(Icons.check_circle),
    label: const Text('CONFIRMAR PEDIDO'),
  ),
),
// COLE OS NOVOS BOTÕES AQUI
                                ],
                                
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

