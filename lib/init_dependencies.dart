import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/network/network_checker.dart';
import 'package:blog_app/core/secrets/app_secrets.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_app/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/upload_blog.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/blog/presentation/bloc/blog_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );

  // Box setup
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  // supabase client
  serviceLocator.registerLazySingleton(() => supabase.client);

  // hive box
  serviceLocator.registerLazySingleton(
    () => Hive.box(name: "blogs"),
  );

  // internet connection
  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<IConnectionChecker>(
      () => ConnectionChecker(serviceLocator()));
}

void _initAuth() {
  serviceLocator
    // Data sources
    ..registerFactory<IAuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        serviceLocator<SupabaseClient>(),
      ),
    )
    // Repositories
    ..registerFactory<IAuthRepository>(
      () => AuthRepository(
        serviceLocator<IAuthRemoteDataSource>(),
        serviceLocator<IConnectionChecker>(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator<IAuthRepository>(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator<IAuthRepository>(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator<IAuthRepository>(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator<UserSignUp>(),
        userLogin: serviceLocator<UserLogin>(),
        currentUser: serviceLocator<CurrentUser>(),
        appUserCubit: serviceLocator<AppUserCubit>(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    // Data sources
    ..registerFactory<IBlogRemoteDataSource>(
      () => BlogRemoteDataSource(
        serviceLocator<SupabaseClient>(),
      ),
    )
    ..registerFactory<IBlogLocalDataSource>(
      () => BlogLocalDataSource(
        serviceLocator<Box>(),
      ),
    )
    // Repositories
    ..registerFactory<IBlogRepository>(
      () => BlogRepository(
        serviceLocator<IBlogRemoteDataSource>(),
        serviceLocator<IBlogLocalDataSource>(),
        serviceLocator<IConnectionChecker>(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UploadBlog(
        serviceLocator<IBlogRepository>(),
      ),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator<IBlogRepository>(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator<UploadBlog>(),
        getAllBlogs: serviceLocator<GetAllBlogs>(),
      ),
    );
}
