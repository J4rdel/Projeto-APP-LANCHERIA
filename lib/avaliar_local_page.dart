import 'package:flutter/material.dart';

class AvaliarLocalPage extends StatefulWidget {
  const AvaliarLocalPage({super.key});

  @override
  State<AvaliarLocalPage> createState() => _AvaliarLocalPageState();
}

class _AvaliarLocalPageState extends State<AvaliarLocalPage> {
  // Constants for better readability and maintainability
  static const double _kPagePadding = 20.0;
  static const double _kVerticalSpacing = 30.0;
  static const int _kStarCount = 5;
  static const double _kStarIconSize = 40.0;
  static const int _kFeedbackMaxLines = 4;
  static const double _kBorderRadius = 10.0;
  static const double _kButtonVerticalPadding = 15.0;

  int _rating = 0; // Estado para a avaliação de estrelas
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Local'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(_kPagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Como você avalia nosso local?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _kVerticalSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_kStarCount, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: _kStarIconSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: _kVerticalSpacing),
            TextField(
              controller: _feedbackController,
              maxLines: _kFeedbackMaxLines,
              decoration: InputDecoration(
                hintText: 'Deixe seu feedback (opcional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kBorderRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kBorderRadius),
                  borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: _kVerticalSpacing),
            ElevatedButton(
              onPressed: () {
                if (_rating > 0) {
                  // Aqui você enviaria a avaliação e o feedback para um backend ou salvaria localmente.
                  // Por enquanto, apenas mostraremos um SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Avaliação de $_rating estrelas enviada! Obrigado pelo feedback.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Volta para a tela anterior
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, selecione uma avaliação em estrelas.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: _kButtonVerticalPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kBorderRadius),
                ),
              ),
              child: const Text(
                'Enviar Avaliação',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}