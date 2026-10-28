class Aluno {
  String id;
  String nome;
  String faixaAtual;
  String telefone;
  String senha;
  bool receberRelatorioWhatsApp;
  bool notificacaoDiaria;
  DateTime dataMatricula;

  Aluno({
    required this.id,
    required this.nome,
    required this.faixaAtual,
    required this.telefone,
    this.senha = '1234',
    this.receberRelatorioWhatsApp = true,
    this.notificacaoDiaria = true,
    DateTime? dataMatricula,
  }) : dataMatricula = dataMatricula ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'faixaAtual': faixaAtual,
        'telefone': telefone,
        'senha': senha,
        'receberRelatorioWhatsApp': receberRelatorioWhatsApp,
        'notificacaoDiaria': notificacaoDiaria,
        'dataMatricula': dataMatricula.toIso8601String(),
      };

  factory Aluno.fromJson(Map<String, dynamic> json) => Aluno(
        id: json['id'] ?? '',
        nome: json['nome'] ?? '',
        faixaAtual: json['faixaAtual'] ?? 'Branca',
        telefone: json['telefone'] ?? '',
        senha: json['senha'] ?? '1234',
        receberRelatorioWhatsApp: json['receberRelatorioWhatsApp'] ?? true,
        notificacaoDiaria: json['notificacaoDiaria'] ?? true,
        dataMatricula: json['dataMatricula'] != null 
            ? DateTime.parse(json['dataMatricula']) 
            : DateTime.now(),
      );
}