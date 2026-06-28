import 'package:signals/signals.dart';
import 'result.dart';

class Command0<T> {
  final Future<Result<T>> Function() _action;
  final running = signal<bool>(false);
  final result = signal<Result<T>?>(null);

  Command0(this._action);

  Future<void> execute() async {
    if (running.value) return;
    running.value = true;
    result.value = null;
    try {
      result.value = await _action();
    } catch (e) {
      result.value = Failure<T>('Erro inesperado: ${e.toString()}');
    } finally {
      running.value = false;
    }
  }
}

class Command1<T, A> {
  final Future<Result<T>> Function(A) _action;
  final running = signal<bool>(false);
  final result = signal<Result<T>?>(null);

  Command1(this._action);

  Future<void> execute(A arg) async {
    if (running.value) return;
    running.value = true;
    result.value = null;
    try {
      result.value = await _action(arg);
    } catch (e) {
      result.value = Failure<T>('Erro inesperado: ${e.toString()}');
    } finally {
      running.value = false;
    }
  }
}
