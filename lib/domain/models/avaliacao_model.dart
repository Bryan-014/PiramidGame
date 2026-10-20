import 'package:cloud_firestore/cloud_firestore.dart';
import 'pessoa_model.dart';

class AvaliacaoModel {
  final String id;
  final String avaliadorUid;
  final String pessoaId;
  final Map<String, int> notas;
  final int pontuacaoTotal;
  final DateTime dataAvaliacao;

  const AvaliacaoModel({
    required this.id,
    required this.avaliadorUid,
    required this.pessoaId,
    required this.notas,
    required this.pontuacaoTotal,
    required this.dataAvaliacao,
  });

  static Map<String, int> notasIniciais() => PessoaModel.notasIniciais();

  Map<String, dynamic> toJson() => {
        'avaliadorUid': avaliadorUid,
        'pessoaId': pessoaId,
        'notas': notas,
        'pontuacaoTotal': pontuacaoTotal,
        'dataAvaliacao': dataAvaliacao,
      };

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    final rawNotas = json['notas'];
    if (rawNotas is! Map) {
      throw const FormatException('Notas da avaliação inválidas.');
    }

    final data = json['dataAvaliacao'];
    final DateTime dataAvaliacao;
    if (data is DateTime) {
      dataAvaliacao = data;
    } else if (data is String) {
      dataAvaliacao = DateTime.parse(data);
    } else if (data is Timestamp) {
      dataAvaliacao = data.toDate();
    } else {
      throw const FormatException('Data da avaliação inválida.');
    }

    final notas = rawNotas.map<String, int>((key, value) {
      if (key is! String || value is! num) {
        throw const FormatException('Critério de avaliação inválido.');
      }
      return MapEntry(key, value.toInt());
    });

    return AvaliacaoModel(
      id: json['id'] as String? ?? '',
      avaliadorUid: json['avaliadorUid'] as String? ?? '',
      pessoaId: json['pessoaId'] as String? ?? '',
      notas: notas,
      pontuacaoTotal: (json['pontuacaoTotal'] as num?)?.toInt() ??
          notas.values.fold(0, (total, nota) => total + nota),
      dataAvaliacao: dataAvaliacao,
    );
  }

  String? validar() {
    if (avaliadorUid.trim().isEmpty || pessoaId.trim().isEmpty) {
      return 'A pessoa avaliadora e a pessoa avaliada são obrigatórias.';
    }
    if (avaliadorUid == pessoaId) {
      return 'Você não pode avaliar a si próprio.';
    }
    if (notas.length != PessoaModel.criteriosKeys.length ||
        !notas.keys.toSet().containsAll(PessoaModel.criteriosKeys)) {
      return 'A avaliação deve conter todos os critérios.';
    }
    if (notas.values.any((nota) => nota < 1 || nota > 5)) {
      return 'As notas devem estar entre 1 e 5.';
    }
    final totalCalculado = notas.values.fold(0, (total, nota) => total + nota);
    if (pontuacaoTotal != totalCalculado) {
      return 'A pontuação total não corresponde às notas informadas.';
    }
    return null;
  }
}
