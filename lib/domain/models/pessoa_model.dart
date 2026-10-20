import 'package:cloud_firestore/cloud_firestore.dart';
import 'aluno_model.dart';

class PessoaModel {
  final String id;
  final String nome;
  final String apelido;
  final String curso;
  final int turmaAno;
  final DateTime dataNascimento;
  final String criadoPor;

  const PessoaModel({
    required this.id,
    required this.nome,
    required this.apelido,
    required this.curso,
    required this.turmaAno,
    required this.dataNascimento,
    required this.criadoPor,
  });

  static const List<String> criteriosKeys = Aluno.criteriosKeys;
  static const Map<String, String> criteriosLabels = Aluno.criteriosLabels;

  static Map<String, int> notasIniciais() =>
      {for (final key in criteriosKeys) key: 1};

  PessoaModel copyWith({
    String? id,
    String? nome,
    String? apelido,
    String? curso,
    int? turmaAno,
    DateTime? dataNascimento,
    String? criadoPor,
  }) {
    return PessoaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      curso: curso ?? this.curso,
      turmaAno: turmaAno ?? this.turmaAno,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      criadoPor: criadoPor ?? this.criadoPor,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome.trim(),
        'apelido': apelido.trim(),
        'curso': curso,
        'turmaAno': turmaAno,
        'dataNascimento': dataNascimento,
        'criadoPor': criadoPor,
      };

  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    final data = json['dataNascimento'];
    final DateTime dataNascimento;
    if (data is DateTime) {
      dataNascimento = data;
    } else if (data is String) {
      dataNascimento = DateTime.parse(data);
    } else if (data is Timestamp) {
      dataNascimento = data.toDate();
    } else {
      throw const FormatException('Data de nascimento inválida.');
    }

    return PessoaModel(
      id: json['id'] as String? ?? '',
      nome: json['nome'] as String? ?? '',
      apelido: json['apelido'] as String? ?? '',
      curso: json['curso'] as String? ?? '',
      turmaAno: (json['turmaAno'] as num?)?.toInt() ?? 0,
      dataNascimento: dataNascimento,
      criadoPor: json['criadoPor'] as String? ?? '',
    );
  }
}
