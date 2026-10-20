import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pessoa_viewmodel.dart';
import '../../core/patterns/result.dart';

class PessoasListScreen extends StatelessWidget {
  final PessoaViewModel pessoaViewModel;
  const PessoasListScreen({super.key, required this.pessoaViewModel});

  void _confirmarRemocao(BuildContext context, String id) {
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
            onPressed: () {
              Navigator.pop(context);
              pessoaViewModel.removerCommand.execute(id);
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

    return Watch((context) {
      final carregando = pessoaViewModel.carregarCommand.running.value;
      final lista = pessoaViewModel.pessoas.value;

      if (carregando) {
        return const Center(child: CircularProgressIndicator());
      }

      if (lista.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 72, color: Colors.grey),
              SizedBox(height: 16),
              Text('Nenhuma pessoa cadastrada ainda.',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: lista.length,
        itemBuilder: (_, i) {
          final pessoa = lista[i];
          final ehMinhaCriacao = pessoa.criadoPor == uidAtual;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  pessoa.nome[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(pessoa.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${pessoa.apelido.isNotEmpty ? '"${pessoa.apelido}" • ' : ''}${pessoa.curso} ${pessoa.turmaAno}'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'ver') {
                    context
                        .push('/pessoa/detalhe', extra: pessoa.id)
                        .then((_) => pessoaViewModel.carregarCommand.execute());
                  } else if (v == 'avaliar') {
                    if (pessoa.id == uidAtual) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Você não pode avaliar a si próprio.')),
                      );
                      return;
                    }
                    context.push('/avaliacao', extra: pessoa.id);
                  } else if (v == 'editar') {
                    context
                        .push('/pessoa/editar', extra: pessoa.id)
                        .then((_) => pessoaViewModel.carregarCommand.execute());
                  } else if (v == 'remover') {
                    _confirmarRemocao(context, pessoa.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'ver', child: Text('Ver detalhes')),
                  const PopupMenuItem(value: 'avaliar', child: Text('Avaliar')),
                  if (ehMinhaCriacao) ...[
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(
                        value: 'remover',
                        child: Text('Remover',
                            style: TextStyle(color: Colors.red))),
                  ],
                ],
              ),
              onTap: () => context
                  .push('/pessoa/detalhe', extra: pessoa.id)
                  .then((_) => pessoaViewModel.carregarCommand.execute()),
            ),
          );
        },
      );
    });
  }
}
