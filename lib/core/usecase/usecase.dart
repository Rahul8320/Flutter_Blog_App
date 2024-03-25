import 'package:blog_app/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IUseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}
