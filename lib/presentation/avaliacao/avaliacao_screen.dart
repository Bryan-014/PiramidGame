import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/patterns/result.dart';
import '../../data/repositories/avaliacao_repository.dart';
import '../../data/repositories/pessoa_repository.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/facades/avaliacao_facade.dart';
import '../../domain/facades/pessoa_facade.dart';
import '../../domain/models/avaliacao_model.dart';
import '../../domain/models/pessoa_model.dart';
import '../avaliacao/avaliacao_viewmodel.dart';
import '../pessoa/pessoa_viewmodel.dart';

class AvaliacaoScreen extends StatefulWidget {
  final String pessoaId;
  const AvaliacaoScreen({super.key, required this.pessoaId});

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  late final AvaliacaoViewModel _avaliacaoViewModel;
  late final PessoaViewModel _pessoaViewModel;
  final Map<String, int> _notas = AvaliacaoModel.notasIniciais();
  bool _carregandoAvaliacao = true;

  String get _uidAtual => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    final firestoreService = FirestoreService();
    _avaliacaoViewModel = AvaliacaoViewModel(
        AvaliacaoFacade.create(AvaliacaoRepository(firestoreService)));
    _pessoaViewModel = PessoaViewModel(
        PessoaFacade.create(PessoaRepository(firestoreService)));

    _pessoaViewModel.buscarPorIdCommand.execute(widget.pessoaId);
    _carregarAvaliacaoExistente();
  }

  Future<void> _carregarAvaliacaoExistente() async {
    await _avaliacaoViewModel.carregarAvaliacaoCommand
        .execute((uid: _uidAtual, pessoaId: widget.pessoaId));
    final avaliacao = _avaliacaoViewModel.avaliacaoAtual.value;
    if (avaliacao != null) {
      setState(() {
        avaliacao.notas.forEach((k, v) => _notas[k] = v);
      });
    }
    setState(() => _carregandoAvaliacao = false);
  }

  Future<void> _salvar() async {
    final avaliacao = AvaliacaoModel(
      id: _avaliacaoViewModel.avaliacaoAtual.value?.id ?? '',
      avaliadorUid: _uidAtual,
      pessoaId: widget.pessoaId,
      notas: Map.from(_notas),
      pontuacaoTotal: _notas.values.fold(0, (s, v) => s + v),
      dataAvaliacao: DateTime.now(),
    );
    await _avaliacaoViewModel.avaliarCommand.execute(avaliacao);
    if (!mounted) return;
    final result = _avaliacaoViewModel.avaliarCommand.result.value;
    if (result is Failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text((result as Failure).message),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Avaliação salva!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  Widget _buildStarRating(String key) {
    final label = PessoaModel.criteriosLabels[key] ?? key;
    final nota = _notas[key] ?? 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(label, style: const TextStyle(fontSize: 13))),
          Row(
            children: List.generate(5, (i) {
              final estrela = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _notas[key] = estrela),
                child: Icon(
                  estrela <= nota ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar Pessoa')),
      body: Watch((context) {
        final pessoa = _pessoaViewModel.pessoaSelecionada.value;
        final carregando = _avaliacaoViewModel.avaliarCommand.running.value;

        if (_carregandoAvaliacao) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pessoa != null)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(pessoa.nome[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(pessoa.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${pessoa.curso} ${pessoa.turmaAno}'),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Critérios de Popularidade',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            ...PessoaModel.criteriosKeys.map(_buildStarRating),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Nível Lenda: ${_notas.values.fold(0, (s, v) => s + v)} pts',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: carregando ? null : _salvar,
              icon: carregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(
                _avaliacaoViewModel.avaliacaoAtual.value != null
                    ? 'Atualizar Avaliação'
                    : 'Salvar Avaliação',
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }
}
