import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/patterns/result.dart';
import '../../data/services/firestore_service.dart';
import '../models/pessoa_model.dart';
import '../models/ranking_item_model.dart';

class RankingFacade {
  final FirestoreService _firestoreService;

  RankingFacade(this._firestoreService);

  factory RankingFacade.create(FirestoreService service) =>
      RankingFacade(service);

  Future<Result<List<RankingItemModel>>> rankingGlobal() async {
    try {
      final pessoas = await _firestoreService.listar(
        FirestoreService.pessoasCollection,
      );
      final avaliacoes = await _firestoreService.listar(
        FirestoreService.avaliacoesCollection,
      );
      final pontuacoes = _somarPontuacoes(avaliacoes);
      final itens = pessoas
          .map(PessoaModel.fromJson)
          .map((pessoa) => RankingItemModel(
                id: pessoa.id,
                nome: pessoa.nome,
                apelido: pessoa.apelido,
                curso: pessoa.curso,
                turmaAno: pessoa.turmaAno,
                nivelLenda: pontuacoes[pessoa.id] ?? 0,
              ))
          .toList()
        ..sort((a, b) {
          final porPontuacao = b.nivelLenda.compareTo(a.nivelLenda);
          return porPontuacao != 0
              ? porPontuacao
              : a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
      return Success(itens);
    } on FirebaseException catch (error) {
      return Failure(
          'Erro ao carregar ranking: ${error.message ?? error.code}');
    } on FormatException catch (error) {
      return Failure('Dados inválidos no ranking: ${error.message}');
    }
  }

  Future<Result<List<RankingItemModel>>> rankingPessoal(String uid) async {
    if (uid.trim().isEmpty) {
      return const Failure('Faça login para consultar seu ranking pessoal.');
    }
    final ranking = await rankingGlobal();
    if (ranking is Failure<List<RankingItemModel>>) return ranking;
    final itens = (ranking as Success<List<RankingItemModel>>).data;
    final usuario = itens.where((item) => item.id == uid).toList();
    if (usuario.isEmpty) {
      return const Success([]);
    }
    return Success(usuario);
  }

  Map<String, int> _somarPontuacoes(List<Map<String, dynamic>> documentos) {
    final totais = <String, int>{};
    for (final documento in documentos) {
      final pessoaId = documento['pessoaId'];
      final total = documento['pontuacaoTotal'];
      if (pessoaId is! String || total is! num) {
        throw const FormatException('Uma avaliação possui dados inválidos.');
      }
      totais.update(
        pessoaId,
        (valorAtual) => valorAtual + total.toInt(),
        ifAbsent: () => total.toInt(),
      );
    }
    return totais;
  }
}
