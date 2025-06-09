import 'package:flutter/material.dart';

class DrinksPage extends StatelessWidget {
  const DrinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Drinks'),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Text(
          'Em breve nossos drinks estarão aqui!',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}