import 'package:blog_app/core/error/failures.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
}
