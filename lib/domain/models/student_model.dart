class Student {
  final String id;
  final String name;
  final String nickname;
  final String course;
  final int classYear;
  final DateTime birthDate;
  final Map<String, int> scores;

  Student({
    required this.id,
    required this.name,
    required this.nickname,
    required this.course,
    required this.classYear,
    required this.birthDate,
    required this.scores,
  });

  int get legendLevel => scores.values.fold(0, (sum, score) => sum + score);

  static const List<String> criteriaKeys = [
    'fun',
    'vip_presence',
    'aura',
    'partner_mode',
    'natural_charisma',
    'million_dollar_humor',
    'group_energy',
    'chaotic_creativity',
    'athlete_mode',
    'stage_talent',
    'school_drip',
    'drama_heart',
    'teachers_favorite',
    'turbo_brain',
    'controlled_chaos',
  ];

  static const Map<String, String> criteriaLabels = {
    'fun': 'Resenha',
    'vip_presence': 'Presença VIP',
    'aura': 'Aura',
    'partner_mode': 'Modo Parceiro',
    'natural_charisma': 'Carisma Natural',
    'million_dollar_humor': 'Humor de Milhões',
    'group_energy': 'Energia de Grupo',
    'chaotic_creativity': 'Criatividade Caótica',
    'athlete_mode': 'Modo Atleta',
    'stage_talent': 'Talento de Palco',
    'school_drip': 'Drip Escolar',
    'drama_heart': 'Coração de Dorama',
    'teachers_favorite': 'Queridinho dos Professores',
    'turbo_brain': 'Cérebro Turbo',
    'controlled_chaos': 'Caos Controlado',
  };

  static const Map<String, String> _legacyCriteriaKeyMap = {
    'resenha': 'fun',
    'presenca_vip': 'vip_presence',
    'aura': 'aura',
    'modo_parceiro': 'partner_mode',
    'carisma_natural': 'natural_charisma',
    'humor_de_milhoes': 'million_dollar_humor',
    'energia_de_grupo': 'group_energy',
    'criatividade_caotica': 'chaotic_creativity',
    'modo_atleta': 'athlete_mode',
    'talento_de_palco': 'stage_talent',
    'drip_escolar': 'school_drip',
    'coracao_de_dorama': 'drama_heart',
    'queridinho_professores': 'teachers_favorite',
    'cerebro_turbo': 'turbo_brain',
    'caos_controlado': 'controlled_chaos',
  };

  static Map<String, int> initialScores() {
    return {for (final key in criteriaKeys) key: 1};
  }

  Student copyWith({
    String? id,
    String? name,
    String? nickname,
    String? course,
    int? classYear,
    DateTime? birthDate,
    Map<String, int>? scores,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      course: course ?? this.course,
      classYear: classYear ?? this.classYear,
      birthDate: birthDate ?? this.birthDate,
      scores: scores ?? this.scores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'course': course,
      'classYear': classYear,
      'birthDate': birthDate.toIso8601String(),
      'scores': scores,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['nome'] ?? ''}',
      nickname: '${json['nickname'] ?? json['apelido'] ?? ''}',
      course: '${json['course'] ?? json['curso'] ?? ''}',
      classYear: _parseInt(json['classYear'] ?? json['turmaAno']),
      birthDate: DateTime.parse(
        '${json['birthDate'] ?? json['dataNascimento'] ?? DateTime.now().toIso8601String()}',
      ),
      scores: _parseScores(json['scores'] ?? json['notas']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static Map<String, int> _parseScores(dynamic value) {
    final normalized = initialScores();

    if (value is! Map) return normalized;

    for (final entry in value.entries) {
      final rawKey = '${entry.key}';
      final key = _legacyCriteriaKeyMap[rawKey] ?? rawKey;

      if (!normalized.containsKey(key)) continue;

      normalized[key] = _parseInt(entry.value).clamp(1, 5);
    }

    return normalized;
  }
}
