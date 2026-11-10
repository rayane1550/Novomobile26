import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o sistema'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: const [
              Text(
                'Onde Comer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5EFEA),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'O sistema foi pensado para ajudar pessoas a descobrir restaurantes, pratos especiais e experiências gastronômicas perto de onde estão. Ele reúne opções em uma interface simples, moderna e fácil de navegar, com foco em sabor, variedade e rapidez na escolha do lugar ideal.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Color(0xFFE7DED7),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Funcionalidades',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF5EFEA),
                ),
              ),
              SizedBox(height: 12),
              Text(
                '• Visualização de restaurantes e promoções\n• Lista com imagens, descrições e valores\n• Favoritar itens\n• Carrinho de pedidos\n• Cadastro, edição e exclusão de promoções\n• Tela dedicada para informações do sistema',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Color(0xFFE7DED7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
