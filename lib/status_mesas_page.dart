import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:intl/intl.dart'; // Para formatação de data/hora se necessário

// Modelo simplificado do que esperamos de um pedido para esta tela
class PedidoMesaInfo {
  final String mesaId;
  final Timestamp timestampCriacao; // Quando o pedido foi criado/aberto

  PedidoMesaInfo({required this.mesaId, required this.timestampCriacao});

  factory PedidoMesaInfo.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PedidoMesaInfo(
      mesaId:
          data['mesaId'] ??
          'Desconhecida', // Garanta que 'mesaId' exista no seu doc de pedido
      timestampCriacao:
          data['timestamp'] ??
          Timestamp.now(), // Garanta que 'timestamp' exista
    );
  }
}

class StatusMesasPage extends StatefulWidget {
  final int totalMesas; // Ex: 25

  const StatusMesasPage({super.key, this.totalMesas = 25});

  @override
  State<StatusMesasPage> createState() => _StatusMesasPageState();
}

class _StatusMesasPageState extends State<StatusMesasPage> {
  Stream<Map<String, PedidoMesaInfo?>> _getMesasStatusStream() {
    // Assumindo que seus pedidos têm um campo 'status'
    // e você quer considerar mesas com pedidos 'aberto', 'em_preparacao', etc.
    // Ajuste o filtro de 'status' conforme sua lógica de negócio.
    // Se um pedido finalizado/pago tem um status diferente, filtre-o para não aparecer aqui.
    return FirebaseFirestore.instance
        .collection('pedidos')
        .where(
          'status',
          whereIn: ['aberto', 'em_preparacao', 'servido'],
        ) // Exemplo de status ativos
        .orderBy(
          'timestamp',
          descending: false,
        ) // Pedidos mais antigos primeiro
        .snapshots()
        .map((snapshot) {
          final Map<String, PedidoMesaInfo> pedidosAtivosPorMesa = {};

          for (var doc in snapshot.docs) {
            final pedido = PedidoMesaInfo.fromSnapshot(doc);
            // Se já temos um pedido para esta mesa, mantemos o mais antigo (primeiro a ocupar)
            if (!pedidosAtivosPorMesa.containsKey(pedido.mesaId)) {
              pedidosAtivosPorMesa[pedido.mesaId] = pedido;
            }
          }

          // Mapeia para todas as mesas, indicando null se estiver livre
          final Map<String, PedidoMesaInfo?> statusFinal = {};
          for (int i = 1; i <= widget.totalMesas; i++) {
            String mesaId = i.toString();
            statusFinal[mesaId] = pedidosAtivosPorMesa[mesaId];
          }
          return statusFinal;
        });
  }

  String _formatTempoOcupacao(Timestamp inicioOcupacao) {
    final agora = DateTime.now();
    final inicio = inicioOcupacao.toDate();
    final diferenca = agora.difference(inicio);

    if (diferenca.inHours > 0) {
      return '${diferenca.inHours}h ${diferenca.inMinutes.remainder(60)}min';
    } else if (diferenca.inMinutes > 0) {
      return '${diferenca.inMinutes}min';
    } else {
      return '< 1min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status das Mesas')),
      body: StreamBuilder<Map<String, PedidoMesaInfo?>>(
        stream: _getMesasStatusStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar status: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Isso pode acontecer se a lógica de mapeamento inicial não cobrir todas as mesas
            // ou se não houver pedidos ativos.
            // Vamos renderizar todas as mesas como livres neste caso.
            final Map<String, PedidoMesaInfo?> mesasVazias = {};
            for (int i = 1; i <= widget.totalMesas; i++) {
              mesasVazias[i.toString()] = null;
            }
            return _buildMesasGrid(mesasVazias);
          }

          final mesasStatus = snapshot.data!;
          return _buildMesasGrid(mesasStatus);
        },
      ),
    );
  }

  Widget _buildMesasGrid(Map<String, PedidoMesaInfo?> mesasStatus) {
    // Garante que temos todas as mesas de 1 a totalMesas
    List<String> todasAsChavesDeMesa = List.generate(
      widget.totalMesas,
      (index) => (index + 1).toString(),
    );

    // Ordena as chaves numericamente para exibição correta
    // (se as chaves em mesasStatus não estiverem ordenadas ou completas)
    List<MapEntry<String, PedidoMesaInfo?>> sortedEntries = [];
    for (var key in todasAsChavesDeMesa) {
      sortedEntries.add(MapEntry(key, mesasStatus[key]));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 colunas para 25 mesas (5x5)
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.0, // Para fazer os itens quadrados
        ),
        itemCount: sortedEntries.length,
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final mesaId = entry.key;
          final pedidoInfo = entry.value;
          final isOcupada = pedidoInfo != null;

          return Card(
            color: isOcupada ? Colors.red.shade100 : Colors.green.shade100,
            elevation: 3,
            child: InkWell(
              onTap: () {
                if (isOcupada) {
                  // Poderia navegar para os detalhes do pedido da mesa,
                  // ou mostrar um diálogo com mais informações.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Mesa $mesaId ocupada desde ).format(pedidoInfo.timestampCriacao.toDate())}',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mesa $mesaId está livre.')),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mesa',
                    style: TextStyle(
                      fontSize: 14,
                      color: isOcupada
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                  Text(
                    mesaId,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isOcupada
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                  if (isOcupada)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _formatTempoOcupacao(pedidoInfo.timestampCriacao),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
