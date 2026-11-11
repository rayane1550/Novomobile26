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
  bool _loading = true;
  bool _profileSaved = false;
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
    _displayName = savedName.trim().isNotEmpty ? savedName : 'Cliente';
    _profileSaved = _hasAnySavedData();
    if (mounted) setState(() => _loading = false);
  }

  bool _hasAnySavedData() {
    return _nameController.text.trim().isNotEmpty ||
        _cepController.text.trim().isNotEmpty ||
        _addressController.text.trim().isNotEmpty ||
        _phoneController.text.trim().isNotEmpty;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final cep = _cepController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9+]'), '');

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
      reservationTime: '',
    );

    setState(() {
      _displayName = name;
      _profileSaved = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos. Você pode editar ou excluir quando quiser.')),
    );
  }

  Future<void> _editSavedProfile() async {
    final customer = await _storage.getCustomer();
    _nameController.text = customer['name'] ?? '';
    _cepController.text = customer['cep'] ?? '';
    _addressController.text = customer['address'] ?? '';
    _phoneController.text = customer['phone'] ?? '';
    setState(() => _profileSaved = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados carregados para edição.')),
    );
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir informações salvas?'),
        content: const Text(
          'Seu nome, CEP, endereço e telefone serão removidos deste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
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
    setState(() {
      _displayName = 'Cliente';
      _profileSaved = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informações removidas')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _savedProfileCard() {
    final name = _nameController.text.trim();
    final cep = _cepController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_profileSaved || name.isEmpty && cep.isEmpty && address.isEmpty && phone.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(top: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.person_pin_rounded, color: Color(0xFF2DBE6A)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dados salvos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(label: 'Nome', value: name.isEmpty ? '—' : name),
            _InfoRow(label: 'CEP', value: cep.isEmpty ? '—' : cep),
            _InfoRow(label: 'Endereço', value: address.isEmpty ? '—' : address),
            _InfoRow(label: 'Telefone', value: phone.isEmpty ? '—' : phone),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _editSavedProfile,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                          color: Color(0xFF163026),
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
                  'Preencha seu perfil e salve seus dados para editar ou excluir depois.',
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
                _savedProfileCard(),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7F78),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF163026),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
