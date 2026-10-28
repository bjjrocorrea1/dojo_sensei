enum TipoTreino { regular, personal }

class Presenca {
  String id;
  String alunoId;
  DateTime dataTreino; // Data/Hora do treino (pode ser retroativo)
  DateTime dataRegistro; // Carimbo de quando foi lançado
  TipoTreino tipoTreino;

  Presenca({
    required this.id,
    required this.alunoId,
    required this.dataTreino,
    required this.dataRegistro,
    this.tipoTreino = TipoTreino.regular,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'alunoId': alunoId,
        'dataTreino': dataTreino.toIso8601String(),
        'dataRegistro': dataRegistro.toIso8601String(),
        'tipoTreino': tipoTreino.name,
      };

  factory Presenca.fromJson(Map<String, dynamic> json) => Presenca(
        id: json['id'],
        alunoId: json['alunoId'],
        dataTreino: DateTime.parse(json['dataTreino']),
        dataRegistro: DateTime.parse(json['dataRegistro']),
        tipoTreino: json['tipoTreino'] == 'personal'
            ? TipoTreino.personal
            : TipoTreino.regular,
      );
}