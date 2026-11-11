import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = const [
      'Busca inteligente por restaurante',
      'Lista visual de promoções e cardápios',
      'Reservas e agendamento de horários',
      'Cadastro e gerenciamento dos estabelecimentos',
      'Avaliações com nota e comentários',
      'Experiência moderna e responsiva',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o sistema'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F5),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE1EAE5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Onde Comer',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF163026),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Uma plataforma para descobrir restaurantes, comparar experiências gastronômicas e escolher o lugar ideal com praticidade, beleza e confiança.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Color(0xFF2B443B),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _Pill(label: 'Gastronomia'),
                        _Pill(label: 'Promoções'),
                        _Pill(label: 'Reservas'),
                        _Pill(label: 'Experiência'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'O que o sistema oferece',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF163026),
                ),
              ),
              const SizedBox(height: 14),
              ...features.map(
                (feature) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2EAE6)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2DBE6A),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF234132),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EAE6)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nosso objetivo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF163026),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajuda as pessoas a encontrar lugares gastronômicos perto de onde estão, com melhor organização, visual envolvente e uma experiência simples de navegação para explorar pratos, avaliações e oportunidades do dia.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Color(0xFF234132),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDEF5E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0E5D3D),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
