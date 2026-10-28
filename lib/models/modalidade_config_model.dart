class RequisitoExame {
  String id;
  String titulo;
  int quantidadeNecessaria;
  bool obrigatorio;

  RequisitoExame({required this.id, required this.titulo, required this.quantidadeNecessaria, this.obrigatorio = true});

  Map<String, dynamic> toJson() => {'id': id, 'titulo': titulo, 'quantidadeNecessaria': quantidadeNecessaria, 'obrigatorio': obrigatorio};

  factory RequisitoExame.fromJson(Map<String, dynamic> json) => RequisitoExame(
        id: json['id'] ?? '',
        titulo: json['titulo'] ?? '',
        quantidadeNecessaria: json['quantidadeNecessaria'] ?? 1,
        obrigatorio: json['obrigatorio'] ?? true,
      );
}

class FaixaGraduacao {
  String id;
  String nomeFaixa;
  int mesesMinimosCarencia;
  int frequenciaMinimaPorcentagem;
  List<RequisitoExame> requisitos;

  FaixaGraduacao({
    required this.id,
    required this.nomeFaixa,
    required this.mesesMinimosCarencia,
    required this.frequenciaMinimaPorcentagem,
    required this.requisitos,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomeFaixa': nomeFaixa,
        'mesesMinimosCarencia': mesesMinimosCarencia,
        'frequenciaMinimaPorcentagem': frequenciaMinimaPorcentagem,
        'requisitos': requisitos.map((r) => r.toJson()).toList(),
      };

  factory FaixaGraduacao.fromJson(Map<String, dynamic> json) => FaixaGraduacao(
        id: json['id'] ?? '',
        nomeFaixa: json['nomeFaixa'] ?? '',
        mesesMinimosCarencia: json['mesesMinimosCarencia'] ?? 0,
        frequenciaMinimaPorcentagem: json['frequenciaMinimaPorcentagem'] ?? 70,
        requisitos: (json['requisitos'] as List<dynamic>?)?.map((r) => RequisitoExame.fromJson(r)).toList() ?? [],
      );
}

class ConfiguracaoAcademia {
  String nomeAcademia;
  String modalidade;
  String logoUrl;
  String corFonteNome; // Nova propriedade para a cor do texto do nome da equipe
  List<FaixaGraduacao> faixas;

  ConfiguracaoAcademia({
    required this.nomeAcademia,
    required this.modalidade,
    required this.logoUrl,
    this.corFonteNome = 'Preto',
    required this.faixas,
  });

  Map<String, dynamic> toJson() => {
        'nomeAcademia': nomeAcademia,
        'modalidade': modalidade,
        'logoUrl': logoUrl,
        'corFonteNome': corFonteNome,
        'faixas': faixas.map((f) => f.toJson()).toList(),
      };

  factory ConfiguracaoAcademia.fromJson(Map<String, dynamic> json) => ConfiguracaoAcademia(
        nomeAcademia: json['nomeAcademia'] ?? 'Dojo Sensei',
        modalidade: json['modalidade'] ?? 'Jiu-Jitsu',
        logoUrl: json['logoUrl'] ?? '',
        corFonteNome: json['corFonteNome'] ?? 'Preto',
        faixas: (json['faixas'] as List<dynamic>?)?.map((f) => FaixaGraduacao.fromJson(f)).toList() ?? obterFaixasPadrao('Jiu-Jitsu'),
      );

  static List<FaixaGraduacao> obterFaixasPadrao(String modalidade) {
    final mod = modalidade.toLowerCase();

    if (mod.contains('jiu')) {
      return [
        FaixaGraduacao(id: '1', nomeFaixa: 'Branca (Infantil)', mesesMinimosCarencia: 3, frequenciaMinimaPorcentagem: 60, requisitos: []),
        FaixaGraduacao(id: '2', nomeFaixa: 'Cinza e Branca', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 65, requisitos: []),
        FaixaGraduacao(id: '3', nomeFaixa: 'Cinza', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 65, requisitos: []),
        FaixaGraduacao(id: '4', nomeFaixa: 'Amarela', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: '5', nomeFaixa: 'Laranja', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: '6', nomeFaixa: 'Verde', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: '7', nomeFaixa: 'Faixa Branca (Adulto)', mesesMinimosCarencia: 0, frequenciaMinimaPorcentagem: 0, requisitos: []),
        FaixaGraduacao(id: '8', nomeFaixa: 'Faixa Azul', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 70, requisitos: [
          RequisitoExame(id: 'r1', titulo: 'Armlock da guarda', quantidadeNecessaria: 3),
          RequisitoExame(id: 'r2', titulo: 'Triângulo', quantidadeNecessaria: 3),
        ]),
        FaixaGraduacao(id: '9', nomeFaixa: 'Faixa Roxa', mesesMinimosCarencia: 18, frequenciaMinimaPorcentagem: 75, requisitos: []),
        FaixaGraduacao(id: '10', nomeFaixa: 'Faixa Marrom', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 80, requisitos: []),
        FaixaGraduacao(id: '11', nomeFaixa: 'Faixa Preta', mesesMinimosCarencia: 36, frequenciaMinimaPorcentagem: 80, requisitos: []),
      ];
    } else if (mod.contains('judô') || mod.contains('judo')) {
      return [
        FaixaGraduacao(id: 'j1', nomeFaixa: 'Branca', mesesMinimosCarencia: 3, frequenciaMinimaPorcentagem: 60, requisitos: []),
        FaixaGraduacao(id: 'j2', nomeFaixa: 'Cinza', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 65, requisitos: []),
        FaixaGraduacao(id: 'j3', nomeFaixa: 'Azul', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 65, requisitos: []),
        FaixaGraduacao(id: 'j4', nomeFaixa: 'Amarela', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'j5', nomeFaixa: 'Laranja', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'j6', nomeFaixa: 'Verde', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'j7', nomeFaixa: 'Roxa', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 75, requisitos: []),
        FaixaGraduacao(id: 'j8', nomeFaixa: 'Marrom', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 80, requisitos: []),
        FaixaGraduacao(id: 'j9', nomeFaixa: 'Preta', mesesMinimosCarencia: 36, frequenciaMinimaPorcentagem: 80, requisitos: []),
      ];
    } else if (mod.contains('karatê') || mod.contains('karate')) {
      return [
        FaixaGraduacao(id: 'k1', nomeFaixa: 'Branca', mesesMinimosCarencia: 3, frequenciaMinimaPorcentagem: 60, requisitos: []),
        FaixaGraduacao(id: 'k2', nomeFaixa: 'Amarela', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 65, requisitos: []),
        FaixaGraduacao(id: 'k3', nomeFaixa: 'Vermelha', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 65, requisitos: []),
        FaixaGraduacao(id: 'k4', nomeFaixa: 'Laranja', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'k5', nomeFaixa: 'Verde', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'k6', nomeFaixa: 'Roxa', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'k7', nomeFaixa: 'Marrom', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 75, requisitos: []),
        FaixaGraduacao(id: 'k8', nomeFaixa: 'Preta', mesesMinimosCarencia: 24, frequenciaMinimaPorcentagem: 80, requisitos: []),
      ];
    } else {
      return [
        FaixaGraduacao(id: 'o1', nomeFaixa: 'Iniciante / Branca', mesesMinimosCarencia: 3, frequenciaMinimaPorcentagem: 60, requisitos: []),
        FaixaGraduacao(id: 'o2', nomeFaixa: 'Intermediário', mesesMinimosCarencia: 6, frequenciaMinimaPorcentagem: 70, requisitos: []),
        FaixaGraduacao(id: 'o3', nomeFaixa: 'Avançado', mesesMinimosCarencia: 12, frequenciaMinimaPorcentagem: 75, requisitos: []),
        FaixaGraduacao(id: 'o4', nomeFaixa: 'Graduado / Preto', mesesMinimosCarencia: 24, frequenciaMinimaPorcentagem: 80, requisitos: []),
      ];
    }
  }
}