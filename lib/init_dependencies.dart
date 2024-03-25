import 'package:blog_app/core/secrets/app_secrets.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
}

void _initAuth() {
  serviceLocator.registerFactory<IAuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerFactory<IAuthRepository>(
    () => AuthRepository(
      serviceLocator<IAuthRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserSignUp(
      serviceLocator<IAuthRepository>(),
    ),
  );

  serviceLocator.registerFactory(
        () => UserLogin(
      serviceLocator<IAuthRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator<UserSignUp>(),
      userLogin: serviceLocator<UserLogin>(),
    ),
  );
}
