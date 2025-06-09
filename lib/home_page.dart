import 'package:flutter/material.dart';
import 'package:lancheria/lanches_page.dart';
import 'package:lancheria/drinks_page.dart';
import 'package:lancheria/sobremesas_page.dart';
import 'package:lancheria/minha_conta_page.dart';
import 'package:lancheria/avaliar_local_page.dart';
import 'package:lancheria/gerenciamento_pedidos_page.dart'; // Importa a nova página do gerente

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showGarcomSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Garçom chamado! Em breve alguém virá te atender.'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            // Ação opcional ao clicar em OK
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 50),

              _buildOptionButton(
                context,
                'LANCHES',
                () => const LanchesPage(),
                Icons.fastfood,
              ),
              const SizedBox(height: 15),

              _buildOptionButton(
                context,
                'DRINKS',
                () => const DrinksPage(),
                Icons.local_drink,
              ),
              const SizedBox(height: 15),

              _buildOptionButton(
                context,
                'SOBREMESAS',
                () => const SobremesasPage(),
                Icons.cake,
              ),
              const SizedBox(height: 15),

              _buildOptionButton(
                context,
                'AVALIAR LOCAL',
                () => const AvaliarLocalPage(),
                Icons.star_rate,
              ),
              const SizedBox(height: 15),

              _buildOptionButton(
                context,
                'MINHA CONTA',
                () => const MinhaContaPage(),
                Icons.person,
              ),
              const SizedBox(height: 30),

              // NOVO BOTÃO PARA O GERENTE
              _buildOptionButton(
                context,
                'GESTÃO DE PEDIDOS',
                () => const GerenciamentoPedidosPage(),
                Icons.manage_accounts, // Ícone para gestão
              ),
              const SizedBox(height: 30), // Espaçamento adicional

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showGarcomSnackBar(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.notifications_active, color: Colors.white),
                  label: const Text(
                    'CHAMAR GARÇOM',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String text, Widget Function() pageBuilder, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageBuilder()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}