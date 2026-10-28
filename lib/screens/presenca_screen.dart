import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/aluno_model.dart';
import '../models/presenca_model.dart';
import '../models/modalidade_config_model.dart';
import '../services/storage_service.dart';
import '../services/whatsapp_service.dart';

class PresencaScreen extends StatefulWidget {
  const PresencaScreen({super.key});

  @override
  State<PresencaScreen> createState() => _PresencaScreenState();
}

class _PresencaScreenState extends State<PresencaScreen> {
  final StorageService _storageService = StorageService();

  List<Aluno> _alunos = [];
  ConfiguracaoAcademia? _config;
  bool _isLoading = true;

  Aluno? _alunoSelecionado;
  TipoTreino _tipoTreinoSelecionado = TipoTreino.regular;
  DateTime _dataTreinoSelecionada = DateTime.now();
  TimeOfDay _horaTreinoSelecionada = TimeOfDay.now();

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
      if (_alunos.isNotEmpty) {
        _alunoSelecionado = _alunos.first;
      }
      _isLoading = false;
    });
  }

  // Seletor de Data Retroativa
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataTreinoSelecionada,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataTreinoSelecionada) {
      setState(() {
        _dataTreinoSelecionada = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _horaTreinoSelecionada.hour,
          _horaTreinoSelecionada.minute,
        );
      });
    }
  }

  // Seletor de Horário
  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaTreinoSelecionada,
    );
    if (picked != null && picked != _horaTreinoSelecionada) {
      setState(() {
        _horaTreinoSelecionada = picked;
        _dataTreinoSelecionada = DateTime(
          _dataTreinoSelecionada.year,
          _dataTreinoSelecionada.month,
          _dataTreinoSelecionada.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _salvarPresenca() async {
    if (_alunoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um aluno primeiro!')),
      );
      return;
    }

    final novaPresenca = Presenca(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      alunoId: _alunoSelecionado!.id,
      dataTreino: _dataTreinoSelecionada,
      dataRegistro: DateTime.now(), // Carimbo de quando foi lançado
      tipoTreino: _tipoTreinoSelecionado,
    );

    await _storageService.registrarPresenca(novaPresenca);

// Verifica se o aluno prefere notificação diária via WhatsApp
    if (_alunoSelecionado!.notificacaoDiaria) {
      await WhatsappService.enviarComprovantePresenca(
        telefone: _alunoSelecionado!.telefone,
        nomeAluno: _alunoSelecionado!.nome,
        nomeAcademia: _config?.nomeAcademia ?? 'Dojo Sensei',
        dataTreino: _dataTreinoSelecionada,
        tipoTreino: _tipoTreinoSelecionado == TipoTreino.regular ? 'Treino Regular' : 'Personal Training',
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presença de ${_alunoSelecionado!.nome} lançada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Reseta para a data atual
      setState(() {
        _dataTreinoSelecionada = DateTime.now();
        _horaTreinoSelecionada = TimeOfDay.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final formatoData = DateFormat('dd/MM/yyyy').format(_dataTreinoSelecionada);
    final formatoHora = _horaTreinoSelecionada.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançar Presença no Tatame'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _alunos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nenhum aluno cadastrado ainda.\nCadastre alunos na tela inicial para começar a registrar presenças.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Seleção de Aluno
                  const Text('Aluno:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Aluno>(
                    value: _alunoSelecionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: _alunos.map((aluno) {
                      return DropdownMenuItem(
                        value: aluno,
                        child: Text('${aluno.nome} (${aluno.faixaAtual})'),
                      );
                    }).toList(),
                    onChanged: (Aluno? novoAluno) {
                      setState(() {
                        _alunoSelecionado = novoAluno;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Filtro do Tipo de Treino
                  const Text('Tipo de Treino:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  SegmentedButton<TipoTreino>(
                    segments: const [
                      ButtonSegment(
                        value: TipoTreino.regular,
                        label: Text('Treino Regular'),
                        icon: Icon(Icons.groups),
                      ),
                      ButtonSegment(
                        value: TipoTreino.personal,
                        label: Text('Personal Training'),
                        icon: Icon(Icons.fitness_center),
                      ),
                    ],
                    selected: {_tipoTreinoSelecionado},
                    onSelectionChanged: (Set<TipoTreino> novaSelecao) {
                      setState(() {
                        _tipoTreinoSelecionado = novaSelecao.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Seleção de Data e Hora (Suporta Retroativo)
                  const Text('Data e Hora do Treino:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selecionarData(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(formatoData),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selecionarHora(context),
                          icon: const Icon(Icons.access_time),
                          label: Text(formatoHora),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '* Caso tenha esquecido de marcar no dia, basta alterar a data/hora acima. O sistema registrará a data real do treino.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Botão de Confirmação
                  ElevatedButton.icon(
                    onPressed: _salvarPresenca,
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: const Text('Confirmar Presença & Enviar WhatsApp', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
