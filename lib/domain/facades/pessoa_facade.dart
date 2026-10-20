import '../../core/patterns/result.dart';
import '../../data/repositories/pessoa_repository.dart';
import '../models/pessoa_model.dart';

class PessoaFacade {
  final PessoaRepository _repository;

  PessoaFacade(this._repository);

  factory PessoaFacade.create(PessoaRepository repository) =>
      PessoaFacade(repository);

  Future<Result<List<PessoaModel>>> listar() => _repository.listar();
  Future<Result<PessoaModel?>> buscar(String id) => _repository.buscar(id);
  Future<Result<void>> cadastrar(PessoaModel pessoa) =>
      _repository.cadastrar(pessoa);
  Future<Result<void>> alterar(PessoaModel pessoa) =>
      _repository.alterar(pessoa);
  Future<Result<void>> remover(String id) => _repository.remover(id);
}
