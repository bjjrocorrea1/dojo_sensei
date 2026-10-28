import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tecnica_midia_model.dart';
import '../services/storage_service.dart';
import 'player_video_screen.dart';

class BibliotecaMidiaScreen extends StatefulWidget {
  const BibliotecaMidiaScreen({super.key});

  @override
  State<BibliotecaMidiaScreen> createState() => _BibliotecaMidiaScreenState();
}

class _BibliotecaMidiaScreenState extends State<BibliotecaMidiaScreen> {
  final StorageService _storageService = StorageService();
  List<TecnicaMidia> _midias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMidias();
  }

  Future<void> _carregarMidias() async {
    final m = await _storageService.getMidias();
    setState(() {
      _midias = m;
      _isLoading = false;
    });
  }

  Future<void> _selecionarArquivoEAdicionar(BuildContext context) async {
    final tituloController = TextEditingController();
    final descController = TextEditingController();
    String faixaSelecionada = 'Faixa Branca';
    TipoMidia tipoSelecionado = TipoMidia.videoLocal;
    String caminhoArquivo = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar Vídeo ou PDF'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Título da Técnica / Posição', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Descrição / Detalhes', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TipoMidia>(
                      value: tipoSelecionado,
                      decoration: const InputDecoration(labelText: 'Tipo de Mídia', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: TipoMidia.videoLocal, child: Text('Vídeo MP4 (Do Aparelho)')),
                        DropdownMenuItem(value: TipoMidia.pdf, child: Text('Manual em PDF')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => tipoSelecionado = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: tipoSelecionado == TipoMidia.videoLocal ? ['mp4', 'mov', 'avi'] : ['pdf'],
                              );

                              if (result != null && result.files.single.path != null) {
                                setDialogState(() {
                                  caminhoArquivo = result.files.single.path!;
                                });
                              }
                            },
                            icon: const Icon(Icons.folder_open),
                            label: Text(caminhoArquivo.isEmpty ? 'Selecionar Arquivo' : 'Arquivo Selecionado ✓'),
                          ),
                        ),
                      ],
                    ),
                    if (caminhoArquivo.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Caminho: ...${caminhoArquivo.split(RegExp(r'[/\\]')).last}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                    if (tituloController.text.trim().isEmpty || caminhoArquivo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha o título e selecione o arquivo!')),
                      );
                      return;
                    }

                    final novaMidia = TecnicaMidia(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      titulo: tituloController.text.trim(),
                      descricao: descController.text.trim(),
                      faixaRequerida: faixaSelecionada,
                      tipo: tipoSelecionado,
                      urlOuCaminho: caminhoArquivo,
                    );

                    await _storageService.saveMidia(novaMidia);
                    Navigator.pop(context);
                    _carregarMidias();
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
        title: const Text('Biblioteca de Vídeos & PDFs'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _midias.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nenhuma técnica ou vídeo cadastrado.\nToque no botão + para adicionar vídeos em MP4 ou PDFs do seu aparelho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _midias.length,
              itemBuilder: (context, index) {
                final midia = _midias[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: midia.tipo == TipoMidia.videoLocal ? Colors.red[800] : Colors.blue[800],
                      foregroundColor: Colors.white,
                      child: Icon(midia.tipo == TipoMidia.videoLocal ? Icons.play_arrow : Icons.picture_as_pdf),
                    ),
                    title: Text(midia.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${midia.descricao}\nRequisito: ${midia.faixaRequerida}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () async {
                        if (midia.tipo == TipoMidia.videoLocal) {
                          // Abre o player de vídeo local em MP4
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerVideoScreen(
                                caminhoArquivo: midia.urlOuCaminho,
                                titulo: midia.titulo,
                              ),
                            ),
                          );
                        } else {
                          // Abre o PDF externamente ou via leitor
                          final uri = Uri.parse(midia.urlOuCaminho);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selecionarArquivoEAdicionar(context),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}