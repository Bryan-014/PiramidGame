import '../../core/patterns/result.dart';
import '../../data/repositories/auth_repository.dart';
import '../models/usuario_model.dart';

class AuthFacade {
  final AuthRepository _repository;

  AuthFacade(this._repository);

  factory AuthFacade.create(AuthRepository repository) =>
      AuthFacade(repository);

  bool get estaAutenticado => _repository.estaAutenticado;

  Future<Result<UsuarioModel>> login(String email, String senha) =>
      _repository.entrar(email, senha);

  Future<Result<UsuarioModel>> loginComGoogle() =>
      _repository.entrarComGoogle();

  Future<Result<UsuarioModel>> criarConta(
          String nome, String email, String senha) =>
      _repository.cadastrar(nome, email, senha);

  Future<Result<bool>> logout() => _repository.sair();
}
