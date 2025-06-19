import 'package:flutter/material.dart';

class MinhaContaPage extends StatelessWidget {
  const MinhaContaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'), // backgroundColor e foregroundColor virão do tema
      ),
      body: Center( // Mantém o Center para o layout do conteúdo
        child: Text(
          'Aqui você verá seus dados e pedidos!',
          style: TextStyle(fontSize: 20, color: Colors.grey),
          // Para usar a cor do tema: Theme.of(context).textTheme.bodyMedium?.color
        ),
      ),
    );
  }
}