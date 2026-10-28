import 'package:flutter/material.dart';
import '../models/aluno_model.dart';
import '../models/presenca_model.dart';
import '../models/modalidade_config_model.dart';
import '../services/storage_service.dart';
import '../services/whatsapp_service.dart';

class ExameRequisitosScreen extends StatefulWidget {
  const ExameRequisitosScreen({super.key});

  @override
  State<ExameRequisitosScreen> createState() => _ExameRequisitosScreenState();
}

class _ExameRequisitosScreenState extends State<ExameRequisitosScreen> {
  final StorageService _storageService = StorageService();
  List<Aluno> _alunos = [];
  List<Presenca> _presencas = [];
  ConfiguracaoAcademia? _config;
  bool _isLoading = true;

  Aluno? _alunoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    final alunos = await _storageService.getAlunos();
    final presencas = await _storageService.getPresencas();
    final config = await _storageService.getConfiguracao();
    setState(() {
      _alunos = alunos;
      _presencas = presencas;
      _config = config;
      if (_alunos.isNotEmpty) {
        _alunoSelecionado = _alunos.first;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filtra presenças do aluno selecionado
    final presencasAluno = _alunoSelecionado == null 
        ? <Presenca>[] 
        : _presencas.where((p) => p.alunoId == _alunoSelecionado!.id).toList();

    // Encontra a configuração de faixa atual do aluno
    FaixaGraduacao? faixaAtualConfig;
    if (_config != null && _alunoSelecionado != null) {
      try {
        faixaAtualConfig = _config!.faixas.firstWhere((f) => f.nomeFaixa == _alunoSelecionado!.faixaAtual);
      } catch (_) {
        faixaAtualConfig = _config!.faixas.isNotEmpty ? _config!.faixas.first : null;
      }
    }

    // Calcula total de treinos no mês atual
    final agora = DateTime.now();
    final treinosNoMes = presencasAluno.where((p) => p.dataTreino.month == agora.month && p.dataTreino.year == agora.year).length;
    
    // Cálculo simples de porcentagem de frequência (baseado em 20 treinos esperados no mês)
    double porcentagemFrequencia = (treinosNoMes / 20) * 100;
    if (porcentagemFrequencia > 100) porcentagemFrequencia = 100;

    bool aptoExame = faixaAtualConfig != null && porcentagemFrequencia >= faixaAtualConfig.frequenciaMinimaPorcentagem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exame & Requisitos de Faixa'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _alunos.isEmpty
          ? const Center(child: Text('Nenhum aluno cadastrado.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Selecionar Aluno:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Aluno>(
                    value: _alunoSelecionado,
                    decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_search)),
                    items: _alunos.map((aluno) {
                      return DropdownMenuItem(value: aluno, child: Text('${aluno.nome} (${aluno.faixaAtual})'));
                    }).toList(),
                    onChanged: (val) => setState(() => _alunoSelecionado = val),
                  ),
                  const SizedBox(height: 20),

                  // Card de Resumo de Frequência e Prontidão
                  Card(
                    elevation: 3,
                    color: aptoExame ? Colors.green[50] : Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status de Graduação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          const Divider(),
                          Text('Treinos este mês: $treinosNoMes', style: const TextStyle(fontSize: 15)),
                          Text('Taxa de Frequência: ${porcentagemFrequencia.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 15)),
                          Text('Mínimo Exigido: ${faixaAtualConfig?.frequenciaMinimaPorcentagem ?? 0}%', style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: aptoExame ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              aptoExame ? '⭐ PRONTO PARA O EXAME!' : '📈 AINDA EM DESENVOLVIMENTO',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Técnicas e Requisitos para a Próxima Faixa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  if (faixaAtualConfig == null || faixaAtualConfig.requisitos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum requisito cadastrado para esta faixa nas configurações do Dojo.'),
                    )
                  else
                    ...faixaAtualConfig.requisitos.map((req) {
                      return CheckboxListTile(
                        title: Text(req.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Quantidade necessária: ${req.quantidadeNecessaria}'),
                        value: true, // Aqui você pode salvar o progresso individual futuramente
                        onChanged: (val) {},
                      );
                    }),
                  
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_alunoSelecionado != null && _config != null) {
                        await WhatsappService.enviarRelatorioMensal(
                          telefone: _alunoSelecionado!.telefone,
                          nomeAluno: _alunoSelecionado!.nome,
                          nomeAcademia: _config!.nomeAcademia,
                          mes: agora.month,
                          ano: agora.year,
                          totalPresencas: treinosNoMes,
                          porcentagemFrequencia: porcentagemFrequencia,
                          faixaAtual: _alunoSelecionado!.faixaAtual,
                          aptoParaExame: aptoExame,
                        );
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Enviar Relatório Mensal via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}