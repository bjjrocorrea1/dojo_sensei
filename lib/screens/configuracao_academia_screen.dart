import 'package:flutter/material.dart';
import '../models/modalidade_config_model.dart';
import '../services/storage_service.dart';

class ConfiguracaoAcademiaScreen extends StatefulWidget {
  const ConfiguracaoAcademiaScreen({super.key});

  @override
  State<ConfiguracaoAcademiaScreen> createState() => _ConfiguracaoAcademiaScreenState();
}

class _ConfiguracaoAcademiaScreenState extends State<ConfiguracaoAcademiaScreen> {
  final StorageService _storageService = StorageService();
  final _nomeController = TextEditingController();
  final _logoController = TextEditingController();
  final _novaSenhaAdminController = TextEditingController();
  
  String _modalidadeSelecionada = 'Jiu-Jitsu';
  String _corSelecionada = 'Preto';
  bool _isLoading = true;

  final List<String> _modalidades = ['Jiu-Jitsu', 'Judô', 'Karatê', 'Muay Thai', 'Taekwondo', 'Outras'];
  final List<String> _cores = ['Preto', 'Vermelho', 'Azul', 'Verde', 'Amarelo', 'Laranja', 'Roxo'];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final config = await _storageService.getConfiguracao();
    setState(() {
      _nomeController.text = config.nomeAcademia;
      _logoController.text = config.logoUrl;
      _modalidadeSelecionada = config.modalidade;
      _corSelecionada = config.corFonteNome;
      _isLoading = false;
    });
  }

  Future<void> _salvarConfiguracoes() async {
    if (_novaSenhaAdminController.text.trim().isNotEmpty) {
      await _storageService.setSenhaAdmin(_novaSenhaAdminController.text.trim());
    }

    final configAtual = await _storageService.getConfiguracao();
    final novaConfig = ConfiguracaoAcademia(
      nomeAcademia: _nomeController.text.trim().isEmpty ? 'Dojo Sensei' : _nomeController.text.trim(),
      modalidade: _modalidadeSelecionada,
      logoUrl: _logoController.text.trim(),
      corFonteNome: _corSelecionada,
      faixas: configAtual.faixas,
    );

    await _storageService.saveConfiguracao(novaConfig);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas com sucesso!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Dojo'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Identidade da Equipe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Academia / Equipe', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _logoController,
              decoration: const InputDecoration(labelText: 'URL da Imagem da Logo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _corSelecionada,
              decoration: const InputDecoration(labelText: 'Cor da Fonte do Nome da Equipe', border: OutlineInputBorder()),
              items: _cores.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _corSelecionada = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _modalidadeSelecionada,
              decoration: const InputDecoration(labelText: 'Modalidade Principal', border: OutlineInputBorder()),
              items: _modalidades.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _modalidadeSelecionada = val!),
            ),
            const SizedBox(height: 32),
            const Text('Segurança do Administrador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _novaSenhaAdminController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova Senha do Professor', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _salvarConfiguracoes,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Alterações', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 48),
            const Divider(color: Colors.red),
            const Text('Zona de Perigo / Limpeza', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                bool confirmar = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Zerar Frequências?'),
                        content: const Text('Deseja apagar todos os registros de presença lançados? Esta ação não pode ser desfeita.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sim, apagar tudo'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirmar) {
                  await _storageService.limparTodasPresencas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todos os registros de presença foram limpos!')),
                  );
                }
              },
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              label: const Text('Limpar Todos os Lançamentos de Presença', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}