import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/patterns/result.dart';
import '../../data/repositories/pessoa_repository.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/facades/pessoa_facade.dart';
import '../../domain/models/pessoa_model.dart';
import '../../domain/models/app_constants.dart';
import 'pessoa_viewmodel.dart';

class PessoaFormScreen extends StatefulWidget {
  final String? pessoaId;
  const PessoaFormScreen({super.key, this.pessoaId});

  @override
  State<PessoaFormScreen> createState() => _PessoaFormScreenState();
}

class _PessoaFormScreenState extends State<PessoaFormScreen> {
  late final PessoaViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _apelidoCtrl = TextEditingController();
  String? _cursoSelecionado;
  int? _anoSelecionado;
  DateTime? _dataNascimento;

  bool get _editando => widget.pessoaId != null;

  @override
  void initState() {
    super.initState();
    _viewModel = PessoaViewModel(
        PessoaFacade.create(PessoaRepository(FirestoreService())));
    if (_editando) {
      _viewModel.buscarPorIdCommand.execute(widget.pessoaId!).then((_) {
        final pessoa = _viewModel.pessoaSelecionada.value;
        if (pessoa != null) _preencher(pessoa);
      });
    }
  }

  void _preencher(PessoaModel p) {
    setState(() {
      _nomeCtrl.text = p.nome;
      _apelidoCtrl.text = p.apelido;
      _cursoSelecionado = p.curso;
      _anoSelecionado = p.turmaAno;
      _dataNascimento = p.dataNascimento;
    });
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento.')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final pessoa = PessoaModel(
      id: _editando ? widget.pessoaId! : '',
      nome: _nomeCtrl.text.trim(),
      apelido: _apelidoCtrl.text.trim(),
      curso: _cursoSelecionado!,
      turmaAno: _anoSelecionado!,
      dataNascimento: _dataNascimento!,
      criadoPor: uid,
    );

    if (_editando) {
      await _viewModel.alterarCommand.execute(pessoa);
    } else {
      await _viewModel.cadastrarCommand.execute(pessoa);
    }

    if (!mounted) return;
    final result = _editando
        ? _viewModel.alterarCommand.result.value
        : _viewModel.cadastrarCommand.result.value;

    if (result is Failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text((result as Failure).message),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_editando ? 'Pessoa atualizada!' : 'Pessoa cadastrada!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _apelidoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar Pessoa' : 'Nova Pessoa')),
      body: Watch((context) {
        final carregando = _viewModel.cadastrarCommand.running.value ||
            _viewModel.alterarCommand.running.value;

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Dados da Pessoa',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome *',
                    prefixIcon: Icon(Icons.person_outline)),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'O nome é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apelidoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Apelido',
                    prefixIcon: Icon(Icons.badge_outlined)),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _cursoSelecionado,
                decoration: const InputDecoration(
                    labelText: 'Curso *',
                    prefixIcon: Icon(Icons.school_outlined)),
                items: AppConstants.cursos
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cursoSelecionado = v),
                validator: (v) => v == null ? 'Selecione um curso.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _anoSelecionado,
                decoration: const InputDecoration(
                    labelText: 'Turma/Ano *',
                    prefixIcon: Icon(Icons.calendar_today_outlined)),
                items: AppConstants.turmaAnos.reversed
                    .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                    .toList(),
                onChanged: (v) => setState(() => _anoSelecionado = v),
                validator: (v) => v == null ? 'Selecione o ano.' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Data de Nascimento *',
                      prefixIcon: Icon(Icons.cake_outlined)),
                  child: Text(
                    _dataNascimento != null
                        ? DateFormat('dd/MM/yyyy').format(_dataNascimento!)
                        : 'Toque para selecionar',
                    style: TextStyle(
                        color: _dataNascimento != null ? null : Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: carregando ? null : _salvar,
                icon: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_editando ? 'Salvar' : 'Cadastrar'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
