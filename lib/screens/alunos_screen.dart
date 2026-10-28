import 'package:flutter/material.dart';
import '../models/aluno_model.dart';
import '../models/modalidade_config_model.dart';
import '../services/storage_service.dart';

class AlunosScreen extends StatefulWidget {
  const AlunosScreen({super.key});

  @override
  State<AlunosScreen> createState() => _AlunosScreenState();
}

class _AlunosScreenState extends State<AlunosScreen> {
  final StorageService _storageService = StorageService();
  List<Aluno> _alunos = [];
  ConfiguracaoAcademia? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final alunos = await _storageService.getAlunos();
    final config = await _storageService.getConfiguracao();
    setState(() {
      _alunos = alunos;
      _config = config;
      _isLoading = false;
    });
  }

  void _abrirModalCadastro([Aluno? alunoExistente]) {
    final nomeController = TextEditingController(text: alunoExistente?.nome ?? '');
    final telefoneController = TextEditingController(text: alunoExistente?.telefone ?? '');
    String faixaSelecionada = alunoExistente?.faixaAtual ?? (_config?.faixas.first.nomeFaixa ?? 'Branca');
    bool notificacaoDiaria = alunoExistente?.notificacaoDiaria ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(alunoExistente == null ? 'Novo Aluno' : 'Editar Aluno'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'WhatsApp (com DDD)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _config?.faixas.any((f) => f.nomeFaixa == faixaSelecionada) == true 
                          ? faixaSelecionada 
                          : _config?.faixas.first.nomeFaixa,
                      decoration: const InputDecoration(labelText: 'Faixa Atual', border: OutlineInputBorder()),
                      items: _config?.faixas.map((f) {
                        return DropdownMenuItem(value: f.nomeFaixa, child: Text(f.nomeFaixa));
                      }).toList() ?? [],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => faixaSelecionada = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('WhatsApp Diário?'),
                      subtitle: Text(notificacaoDiaria ? 'Envia após cada treino' : 'Acumula para relatório mensal'),
                      value: notificacaoDiaria,
                      onChanged: (val) {
                        setDialogState(() => notificacaoDiaria = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.trim().isEmpty) return;

                    final novoAluno = Aluno(
                      id: alunoExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      nome: nomeController.text.trim(),
                      telefone: telefoneController.text.trim(),
                      faixaAtual: faixaSelecionada,
                      dataMatricula: alunoExistente?.dataMatricula ?? DateTime.now(),
                      notificacaoDiaria: notificacaoDiaria,
                    );

                    await _storageService.saveAluno(novoAluno);
                    Navigator.pop(context);
                    _carregarDados();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Alunos'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _alunos.isEmpty
          ? const Center(child: Text('Nenhum aluno cadastrado. Toque em + para adicionar.'))
          : ListView.builder(
              itemCount: _alunos.length,
              itemBuilder: (context, index) {
                final aluno = _alunos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      child: Text(aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : 'A'),
                    ),
                    title: Text(aluno.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Faixa: ${aluno.faixaAtual} | Tel: ${aluno.telefone}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _abrirModalCadastro(aluno),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirModalCadastro(),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}