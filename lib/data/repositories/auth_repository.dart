import 'package:firebase_auth/firebase_auth.dart';
import '../../core/patterns/result.dart';
import '../../domain/models/usuario_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/google_auth_service.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final FirestoreService _firestoreService;
  final LocalStorageService _localStorageService;

  AuthRepository(
    this._authService,
    this._googleAuthService,
    this._firestoreService,
    this._localStorageService,
  );

  bool get estaAutenticado => _authService.usuarioAtual != null;

  Future<Result<UsuarioModel>> entrar(String email, String senha) async {
    try {
      final credential = await _authService.entrar(email, senha);
      final user = credential.user;
      if (user == null) {
        return const Failure('O Firebase não retornou o usuário autenticado.');
      }
      return await _registrarSessao(user);
    } on FirebaseAuthException catch (error) {
      return Failure(_mensagemAuth(error));
    } catch (error) {
      return Failure('Não foi possível entrar: $error');
    }
  }

  Future<Result<UsuarioModel>> entrarComGoogle() async {
    try {
      final credential = await _googleAuthService.entrar();
      if (credential == null) {
        return const Failure('A autenticação com Google foi cancelada.');
      }
      final user = credential.user;
      if (user == null) {
        return const Failure('O Firebase não retornou o usuário autenticado.');
      }
      return await _registrarSessao(user);
    } on FirebaseAuthException catch (error) {
      return Failure(_mensagemAuth(error));
    } catch (error) {
      return Failure('Não foi possível entrar com Google: $error');
    }
  }

  Future<Result<UsuarioModel>> cadastrar(
      String nome, String email, String senha) async {
    try {
      final credential = await _authService.cadastrar(nome, email, senha);
      final user = credential.user;
      if (user == null) {
        return const Failure('O Firebase não retornou o usuário cadastrado.');
      }
      return await _registrarSessao(user);
    } on FirebaseAuthException catch (error) {
      return Failure(_mensagemAuth(error));
    } catch (error) {
      return Failure('Não foi possível criar a conta: $error');
    }
  }

  Future<Result<bool>> sair() async {
    try {
      await _googleAuthService.sair();
      await _authService.sair();
      await _localStorageService.limparUsuario();
      return const Success(true);
    } on FirebaseAuthException catch (error) {
      return Failure(_mensagemAuth(error));
    } catch (error) {
      return Failure('Não foi possível sair da conta: $error');
    }
  }

  Future<Result<UsuarioModel>> _registrarSessao(User user) async {
    final usuario = UsuarioModel(
      uid: user.uid,
      nome: user.displayName ?? '',
      email: user.email ?? '',
    );
    try {
      await _firestoreService.salvar('usuarios', user.uid, usuario.toJson());
      await _localStorageService.salvarUsuario(user.uid);
      return Success(usuario);
    } on FirebaseException catch (error) {
      return Failure(
          'A conta foi autenticada, mas não foi possível salvar o perfil: ${error.message ?? error.code}');
    } catch (error) {
      return Failure(
          'A conta foi autenticada, mas não foi possível salvar a sessão: $error');
    }
  }

  String _mensagemAuth(FirebaseAuthException error) => switch (error.code) {
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'invalid-email' => 'O e-mail informado é inválido.',
        'weak-password' => 'A senha é muito fraca.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'E-mail ou senha incorretos.',
        'user-disabled' => 'Esta conta foi desativada.',
        'network-request-failed' =>
          'Falha de conexão. Verifique sua internet e tente novamente.',
        _ => error.message ?? 'Falha na autenticação (${error.code}).',
      };
}
