import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../../core/patterns/result.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../domain/facades/auth_facade.dart';
import 'auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    final repo = AuthRepository(
      AuthService(),
      GoogleAuthService(),
      FirestoreService(),
      LocalStorageService(),
    );
    _viewModel = AuthViewModel(AuthFacade.create(repo));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _viewModel.loginCommand
        .execute((email: _emailCtrl.text.trim(), senha: _senhaCtrl.text));
    if (!mounted) return;
    final result = _viewModel.loginCommand.result.value;
    if (result is Success) context.go('/home');
  }

  Future<void> _loginGoogle() async {
    await _viewModel.loginGoogleCommand.execute();
    if (!mounted) return;
    final result = _viewModel.loginGoogleCommand.result.value;
    if (result is Success) context.go('/home');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Watch((context) {
              final carregando = _viewModel.loginCommand.running.value ||
                  _viewModel.loginGoogleCommand.running.value;
              final erro = _viewModel.errorMessage.value;

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 72, color: Color(0xFF1B5E20)),
                    const SizedBox(height: 8),
                    Text(
                      'PiramidGame',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text('IFPR – Campus Paranaguá',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    if (erro != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(erro,
                                    style: const TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o e-mail.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senhaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_senhaVisivel
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                      obscureText: !_senhaVisivel,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe a senha.' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: carregando ? null : _login,
                      icon: carregando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.login),
                      label: const Text('Entrar'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: carregando ? null : _loginGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Entrar com Google'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/cadastro'),
                      child: const Text('Não tem conta? Criar conta'),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
