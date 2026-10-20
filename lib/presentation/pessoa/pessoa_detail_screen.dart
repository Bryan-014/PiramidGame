import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/pessoa_repository.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/facades/pessoa_facade.dart';
import '../../domain/models/pessoa_model.dart';
import 'pessoa_viewmodel.dart';

class PessoaDetailScreen extends StatefulWidget {
  final String pessoaId;
  const PessoaDetailScreen({super.key, required this.pessoaId});

  @override
  State<PessoaDetailScreen> createState() => _PessoaDetailScreenState();
}

class _PessoaDetailScreenState extends State<PessoaDetailScreen> {
  late final PessoaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PessoaViewModel(
        PessoaFacade.create(PessoaRepository(FirestoreService())));
    _viewModel.buscarPorIdCommand.execute(widget.pessoaId);
  }

  void _confirmarRemocao(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover pessoa'),
        content: const Text('Deseja realmente remover esta pessoa?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _viewModel.removerCommand.execute(id);
              if (mounted) context.pop();
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uidAtual = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: Watch((context) {
        final carregando = _viewModel.buscarPorIdCommand.running.value;
        if (carregando) {
          return const Center(child: CircularProgressIndicator());
        }

        final pessoa = _viewModel.pessoaSelecionada.value;
        if (pessoa == null) {
          return const Center(child: Text('Pessoa não encontrada.'));
        }

        final ehMinhaCriacao = pessoa.criadoPor == uidAtual;
        final ehAutoavaliacao = pessoa.id == uidAtual;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          pessoa.nome[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(pessoa.nome,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if (pessoa.apelido.isNotEmpty)
                        Text('"${pessoa.apelido}"',
                            style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(pessoa.curso)),
                          Chip(label: Text('${pessoa.turmaAno}')),
                          Chip(
                            label: Text(DateFormat('dd/MM/yyyy')
                                .format(pessoa.dataNascimento)),
                            avatar: const Icon(Icons.cake, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: ehAutoavaliacao
                          ? null
                          : () => context.push('/avaliacao', extra: pessoa.id),
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Avaliar'),
                    ),
                  ),
                  if (ehMinhaCriacao) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context
                            .push('/pessoa/editar', extra: pessoa.id)
                            .then((_) => _viewModel.buscarPorIdCommand
                                .execute(widget.pessoaId)),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmarRemocao(pessoa.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ],
              ),
              if (ehAutoavaliacao)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Você não pode avaliar a si próprio.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
