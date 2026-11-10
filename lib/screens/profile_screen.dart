import 'package:flutter/material.dart';
import 'package:onde_comer/services/local_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = LocalStorageService();
  final _nameController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reservationController = TextEditingController();
  bool _loading = true;
  String _displayName = 'Cliente';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customer = await _storage.getCustomer();
    final savedName = customer['name'] ?? '';
    _nameController.text = savedName;
    _cepController.text = customer['cep'] ?? '';
    _addressController.text = customer['address'] ?? '';
    _phoneController.text = customer['phone'] ?? '';
    _reservationController.text = customer['reservationTime'] ?? '';
    _displayName = savedName.trim().isNotEmpty ? savedName : 'Cliente';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selectReservationDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final formatted =
        '${selectedDateTime.day.toString().padLeft(2, '0')}/${selectedDateTime.month.toString().padLeft(2, '0')}/${selectedDateTime.year} • ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

    _reservationController.text = formatted;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final cep = _cepController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    final reservationTime = _reservationController.text.trim();

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o seu nome completo.')),
      );
      return;
    }

    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(cep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um CEP válido.')),
      );
      return;
    }

    if (address.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um endereço válido.')),
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um telefone válido.')),
      );
      return;
    }

    await _storage.saveProfile(
      name: name,
      cep: cep,
      address: address,
      phone: phone,
      reservationTime: reservationTime,
    );

    setState(() => _displayName = name);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo neste dispositivo')),
    );
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar dados locais?'),
        content: const Text(
          'O nome, CEP, endereço, telefone e horário serão removidos deste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _storage.clearCustomer();
    _nameController.clear();
    _cepController.clear();
    _addressController.clear();
    _phoneController.clear();
    _reservationController.clear();
    setState(() => _displayName = 'Cliente');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados locais removidos')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _reservationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: const Color(0xFF2DBE6A),
                        child: const Icon(
                          Icons.person_outline,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF4FBF7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dados do cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Preencha seu perfil com nome, endereço, CEP e horário para uma experiência mais rápida.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cepController,
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    prefixIcon: Icon(Icons.pin_drop_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reservationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Horário para reserva',
                    prefixIcon: const Icon(Icons.schedule_outlined),
                    suffixIcon: IconButton(
                      onPressed: _selectReservationDateTime,
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar perfil'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Apagar dados locais'),
                ),
              ],
            ),
    );
  }
}
