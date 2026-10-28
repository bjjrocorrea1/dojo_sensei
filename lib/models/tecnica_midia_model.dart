enum TipoMidia { videoLocal, youtube, pdf }

class TecnicaMidia {
  String id;
  String titulo;
  String descricao;
  String faixaRequerida;
  TipoMidia tipo;
  String urlOuCaminho; // Caminho do arquivo MP4 no dispositivo ou link

  TecnicaMidia({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.faixaRequerida,
    required this.tipo,
    required this.urlOuCaminho,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'faixaRequerida': faixaRequerida,
        'tipo': tipo.name,
        'urlOuCaminho': urlOuCaminho,
      };

  factory TecnicaMidia.fromJson(Map<String, dynamic> json) => TecnicaMidia(
        id: json['id'] ?? '',
        titulo: json['titulo'] ?? '',
        descricao: json['descricao'] ?? '',
        faixaRequerida: json['faixaRequerida'] ?? 'Branca',
        tipo: TipoMidia.values.firstWhere(
          (e) => e.name == (json['tipo'] ?? 'videoLocal'),
          orElse: () => TipoMidia.videoLocal,
        ),
        urlOuCaminho: json['urlOuCaminho'] ?? '',
      );
}