import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  Future<UserCredential> entrar(String email, String senha) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<UserCredential> cadastrar(
      String nome, String email, String senha) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    await credential.user?.updateDisplayName(nome.trim());
    await credential.user?.reload();
    return credential;
  }

  Future<void> sair() => _auth.signOut();

  Future<void> entrarComCredencial(AuthCredential credential) async {
    await _auth.signInWithCredential(credential);
  }
}
