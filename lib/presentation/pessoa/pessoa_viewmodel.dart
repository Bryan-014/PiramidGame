import 'package:signals/signals.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/facades/pessoa_facade.dart';
import '../../domain/models/pessoa_model.dart';

class PessoaViewModel {
  final PessoaFacade _facade;

  PessoaViewModel(this._facade) {
    carregarCommand = Command0(_carregar);
    cadastrarCommand = Command1(_cadastrar);
    alterarCommand = Command1(_alterar);
    removerCommand = Command1(_remover);
    buscarPorIdCommand = Command1(_buscarPorId);
  }

  final pessoas = signal<List<PessoaModel>>([]);
  final pessoaSelecionada = signal<PessoaModel?>(null);
  final errorMessage = signal<String?>(null);

  late final Command0<List<PessoaModel>> carregarCommand;
  late final Command1<void, PessoaModel> cadastrarCommand;
  late final Command1<void, PessoaModel> alterarCommand;
  late final Command1<void, String> removerCommand;
  late final Command1<PessoaModel?, String> buscarPorIdCommand;

  Future<Result<List<PessoaModel>>> _carregar() async {
    final result = await _facade.listar();
    if (result is Success) {
      pessoas.value = (result as Success<List<PessoaModel>>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<void>> _cadastrar(PessoaModel pessoa) async {
    final result = await _facade.cadastrar(pessoa);
    if (result is Failure) errorMessage.value = (result as Failure).message;
    return result;
  }

  Future<Result<void>> _alterar(PessoaModel pessoa) async {
    final result = await _facade.alterar(pessoa);
    if (result is Failure) errorMessage.value = (result as Failure).message;
    return result;
  }

  Future<Result<void>> _remover(String id) async {
    final result = await _facade.remover(id);
    if (result is Failure) {
      errorMessage.value = (result as Failure).message;
    } else {
      await _carregar();
    }
    return result;
  }

  Future<Result<PessoaModel?>> _buscarPorId(String id) async {
    final result = await _facade.buscar(id);
    if (result is Success) {
      pessoaSelecionada.value = (result as Success<PessoaModel?>).data;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }
}
