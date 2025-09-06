import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/authentication/data/datasources/auth_local_data_source.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/get_current_session.dart';
import '../../features/authentication/domain/usecases/send_otp.dart';
import '../../features/authentication/domain/usecases/sign_out.dart';
import '../../features/authentication/domain/usecases/verify_otp.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../network/network_info.dart';
import '../utils/constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  await _initAuth();

  //! Core
  await _initCore();

  //! External
  await _initExternal();
}

Future<void> _initAuth() async {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      sendOtp: sl(),
      verifyOtp: sl(),
      getCurrentSession: sl(),
      signOut: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => GetCurrentSession(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()),
  );
}

Future<void> _initCore() async {
  // Network info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}

Future<void> _initExternal() async {
  // Shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Secure storage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  sl.registerLazySingleton(() => secureStorage);

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());

  // Dio
  final dio = Dio();
  dio.options.connectTimeout = Duration(
    milliseconds: AppConstants.connectionTimeout,
  );
  dio.options.receiveTimeout = Duration(
    milliseconds: AppConstants.receiveTimeout,
  );
  sl.registerLazySingleton(() => dio);

  // Supabase client
  sl.registerLazySingleton(() => Supabase.instance.client);
}
