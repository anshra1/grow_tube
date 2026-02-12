import 'package:skill_tube/src/core/common/typedef.dart';

abstract class FutureUseCaseWithParams<T, Params> {
  const FutureUseCaseWithParams();

  ResultFuture<T> call(Params params);
}

abstract class FutureUseCaseWithoutParams<T> {
  const FutureUseCaseWithoutParams();

  ResultFuture<T> call();
}
