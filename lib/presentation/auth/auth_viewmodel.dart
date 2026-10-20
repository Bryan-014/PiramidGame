import 'package:signals/signals.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/facades/auth_facade.dart';
import '../../domain/models/usuario_model.dart';

class AuthViewModel {
  final AuthFacade _facade;

  AuthViewModel(this._facade) {
    loginCommand = Command1(_login);
    loginGoogleCommand = Command0(_loginGoogle);
    cadastrarCommand = Command1(_cadastrar);
    logoutCommand = Command0(_logout);
  }

  final usuarioAtual = signal<UsuarioModel?>(null);
  final errorMessage = signal<String?>(null);

  late final Command1<UsuarioModel, ({String email, String senha})>
      loginCommand;
  late final Command0<UsuarioModel> loginGoogleCommand;
  late final Command1<UsuarioModel, ({String nome, String email, String senha})>
      cadastrarCommand;
  late final Command0<bool> logoutCommand;

  bool get estaAutenticado => _facade.estaAutenticado;

  Future<Result<UsuarioModel>> _login(
      ({String email, String senha}) args) async {
    final result = await _facade.login(args.email, args.senha);
    if (result is Success) {
      usuarioAtual.value = (result as Success<UsuarioModel>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<UsuarioModel>> _loginGoogle() async {
    final result = await _facade.loginComGoogle();
    if (result is Success) {
      usuarioAtual.value = (result as Success<UsuarioModel>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<UsuarioModel>> _cadastrar(
      ({String nome, String email, String senha}) args) async {
    final result = await _facade.criarConta(args.nome, args.email, args.senha);
    if (result is Success) {
      usuarioAtual.value = (result as Success<UsuarioModel>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<bool>> _logout() async {
    final result = await _facade.logout();
    if (result is Success) usuarioAtual.value = null;
    return result;
  }
}
