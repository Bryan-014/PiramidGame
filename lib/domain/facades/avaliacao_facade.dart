import '../../core/patterns/result.dart';
import '../../data/repositories/avaliacao_repository.dart';
import '../models/avaliacao_model.dart';

class AvaliacaoFacade {
  final AvaliacaoRepository _repository;

  AvaliacaoFacade(this._repository);

  factory AvaliacaoFacade.create(AvaliacaoRepository repository) =>
      AvaliacaoFacade(repository);

  Future<Result<void>> avaliar(AvaliacaoModel avaliacao) =>
      _repository.avaliar(avaliacao);

  Future<Result<AvaliacaoModel?>> consultarAvaliacao(
          String avaliadorUid, String pessoaId) =>
      _repository.consultar(avaliadorUid, pessoaId);

  bool ehAutoavaliacao(String avaliadorUid, String pessoaId) =>
      avaliadorUid.isNotEmpty && avaliadorUid == pessoaId;
}
