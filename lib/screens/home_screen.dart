import 'package:flutter/material.dart';
import '../models/modalidade_config_model.dart';
import '../models/aluno_model.dart';
import '../services/storage_service.dart';
import 'presenca_screen.dart';
import 'alunos_screen.dart';
import 'exame_requisitos_screen.dart';
import 'configuracao_academia_screen.dart';
import 'biblioteca_midia_screen.dart';
import 'login_screen.dart';
import 'ip_rede_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final Aluno? alunoLogado;

  const HomeScreen({super.key, this.isAdmin = true, this.alunoLogado});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _mostrarInfoIP(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IpRedeScreen()),
    );
  }

  void _mostrarDialogoAlterarSenhaAluno(BuildContext context) {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Minha Senha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: senhaAtualController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha Atual', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
            onPressed: () async {
              if (senhaAtualController.text == widget.alunoLogado?.senha) {
                widget.alunoLogado!.senha = novaSenhaController.text.trim();
                await _storageService.saveAluno(widget.alunoLogado!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha alterada com sucesso!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha atual incorreta!')),
                );
              }
            },
            child: const Text('Salvar'),
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

    final nomeDoDojo = _config?.nomeAcademia ?? 'Dojo Sensei';
    final modalidade = _config?.modalidade ?? 'Arte Marcial';
    final corTexto = _converterCor(_config?.corFonteNome ?? 'Preto');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? '$nomeDoDojo (Admin)' : 'Painel de ${widget.alunoLogado?.nome}'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          if (widget.isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.wifi_find),
              tooltip: 'Acesso via Rede Local (IP e PIN)',
              onPressed: () => _mostrarInfoIP(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Configurações',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfiguracaoAcademiaScreen()),
                );
                _carregarConfig();
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Trocar Perfil / Sair',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isAdmin ? '🥋 Painel do Professor / Sensei' : '🥋 Painel do Aluno',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.isAdmin ? nomeDoDojo : (widget.alunoLogado?.nome ?? 'Aluno'),
                    style: TextStyle(color: corTexto == Colors.black87 ? Colors.white : corTexto, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Modalidade: $modalidade ${widget.isAdmin ? "" : "| Faixa: ${widget.alunoLogado?.faixaAtual}"}',
                    style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ações Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  if (widget.isAdmin) ...[
                    _CardMenu(
                      titulo: 'Lançar Presença',
                      icone: Icons.how_to_reg,
                      cor: Colors.green[700]!,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PresencaScreen()));
                      },
                    ),
                    _CardMenu(
                      titulo: 'Gestão de Alunos',
                      icone: Icons.groups,
                      cor: Colors.blue[800]!,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const AlunosScreen()));
                        setState(() {});
                      },
                    ),
                  ],
                  _CardMenu(
                    titulo: widget.isAdmin ? 'Exames & Requisitos' : 'Minha Frequência & Exame',
                    icone: Icons.military_tech,
                    cor: Colors.orange[800]!,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ExameRequisitosScreen()));
                    },
                  ),
                  _CardMenu(
                    titulo: 'Biblioteca de Vídeos & PDFs',
                    icone: Icons.video_library,
                    cor: Colors.red[800]!,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BibliotecaMidiaScreen()));
                    },
                  ),
                  if (!widget.isAdmin)
                    _CardMenu(
                      titulo: 'Alterar Minha Senha',
                      icone: Icons.lock_reset,
                      cor: Colors.blue[800]!,
                      onTap: () => _mostrarDialogoAlterarSenhaAluno(context),
                    ),
                  if (widget.isAdmin)
                    _CardMenu(
                      titulo: 'Configurar Dojo',
                      icone: Icons.admin_panel_settings,
                      cor: Colors.grey[800]!,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracaoAcademiaScreen()));
                        _carregarConfig();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _CardMenu({required this.titulo, required this.icone, required this.cor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          border: Border.all(color: cor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: cor),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cor),
            ),
          ],
        ),
      ),
    );
  }
}