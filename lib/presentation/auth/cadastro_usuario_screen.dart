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

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  late final AuthViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
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

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    await _viewModel.cadastrarCommand.execute((
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      senha: _senhaCtrl.text,
    ));
    if (!mounted) return;
    final result = _viewModel.cadastrarCommand.result.value;
    if (result is Success) context.go('/home');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Watch((context) {
          final carregando = _viewModel.cadastrarCommand.running.value;
          final erro = _viewModel.errorMessage.value;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                if (erro != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Text(erro, style: const TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'O nome é obrigatório.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'E-mail *',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'O e-mail é obrigatório.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _senhaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Senha *',
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
                  validator: (v) => v == null || v.length < 6
                      ? 'A senha deve ter ao menos 6 caracteres.'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: carregando ? null : _cadastrar,
                  icon: carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.person_add),
                  label: const Text('Criar Conta'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
