class UsuarioModel {
  final String uid;
  final String nome;
  final String email;

  const UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nome': nome,
        'email': email,
      };

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        uid: json['uid'] as String? ?? '',
        nome: json['nome'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}
