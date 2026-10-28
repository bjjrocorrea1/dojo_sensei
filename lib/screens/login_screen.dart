import 'package:flutter/material.dart';
import '../models/aluno_model.dart';
import '../models/modalidade_config_model.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final StorageService _storageService = StorageService();
  ConfiguracaoAcademia? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarConfig();
  }

  Future<void> _carregarConfig() async {
    final config = await _storageService.getConfiguracao();
    setState(() {
      _config = config;
      _isLoading = false;
    });
  }

  void _mostrarDialogoAdmin(BuildContext context) {
    final senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso do Professor (Admin)'),
        content: SingleChildScrollView(
          child: TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha de Administrador', border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
            onPressed: () async {
              String senhaSalva = await _storageService.getSenhaAdmin();
              if (senhaController.text == senhaSalva) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen(isAdmin: true)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha incorreta!')),
                );
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAluno(BuildContext context) {
    final nomeController = TextEditingController();
    final senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso do Aluno'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Seu Nome Completo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Sua Senha Pessoal', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
            onPressed: () async {
              Aluno? aluno = await _storageService.autenticarAluno(nomeController.text.trim(), senhaController.text.trim());
              if (aluno != null) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(isAdmin: false, alunoLogado: aluno)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aluno não encontrado ou senha incorreta!')),
                );
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  Color _converterCor(String corStr) {
    switch (corStr.toLowerCase()) {
      case 'vermelho': return Colors.red;
      case 'azul': return Colors.blue;
      case 'verde': return Colors.green;
      case 'amarelo': return Colors.amber;
      case 'laranja': return Colors.orange;
      case 'roxo': return Colors.purple;
      case 'branco': return Colors.white;
      case 'preto': default: return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final corTexto = _converterCor(_config?.corFonteNome ?? 'Preto');

    return Scaffold(
      appBar: AppBar(
        title: Text(_config?.nomeAcademia ?? 'Dojo Sensei'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _config?.logoUrl != null && _config!.logoUrl.isNotEmpty
                  ? Image.network(_config!.logoUrl, height: 100, errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_martial_arts, size: 80, color: Colors.black87))
                  : const Icon(Icons.sports_martial_arts, size: 80, color: Colors.black87),
              const SizedBox(height: 16),
              Text(
                _config?.nomeAcademia ?? 'Dojo Sensei',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: corTexto),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Modalidade: ${_config?.modalidade}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoAdmin(context),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Entrar como Professor / Sensei', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _mostrarDialogoAluno(context),
                  icon: const Icon(Icons.person),
                  label: const Text('Entrar como Aluno', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[800],
                    side: BorderSide(color: Colors.blue.shade800, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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