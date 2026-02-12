import 'package:fpdart/fpdart.dart';
import 'package:skill_tube/src/core/error/failure.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultStream<T> = Stream<Either<Failure, T>>;
