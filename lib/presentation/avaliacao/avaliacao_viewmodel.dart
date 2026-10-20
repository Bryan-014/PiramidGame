import 'package:signals/signals.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/facades/avaliacao_facade.dart';
import '../../domain/models/avaliacao_model.dart';

class AvaliacaoViewModel {
  final AvaliacaoFacade _facade;

  AvaliacaoViewModel(this._facade) {
    avaliarCommand = Command1(_avaliar);
    carregarAvaliacaoCommand = Command1(_carregarAvaliacao);
  }

  final avaliacaoAtual = signal<AvaliacaoModel?>(null);
  final errorMessage = signal<String?>(null);

  late final Command1<void, AvaliacaoModel> avaliarCommand;
  late final Command1<AvaliacaoModel?, ({String uid, String pessoaId})>
      carregarAvaliacaoCommand;

  bool ehAutoavaliacao(String uid, String pessoaId) =>
      _facade.ehAutoavaliacao(uid, pessoaId);

  Future<Result<void>> _avaliar(AvaliacaoModel avaliacao) async {
    final result = await _facade.avaliar(avaliacao);
    if (result is Failure) {
      errorMessage.value = (result as Failure).message;
    } else {
      errorMessage.value = null;
    }
    return result;
  }

  Future<Result<AvaliacaoModel?>> _carregarAvaliacao(
      ({String uid, String pessoaId}) args) async {
    final result = await _facade.consultarAvaliacao(args.uid, args.pessoaId);
    if (result is Success) {
      avaliacaoAtual.value = (result as Success<AvaliacaoModel?>).data;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }
}
