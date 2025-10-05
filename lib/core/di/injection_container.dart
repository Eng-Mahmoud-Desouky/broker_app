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
import '../../features/authentication/domain/usecases/bypass_otp_verification.dart';
import '../../features/authentication/domain/usecases/complete_registration.dart';
import '../../features/authentication/domain/usecases/get_current_session.dart';
import '../../features/authentication/domain/usecases/send_otp.dart';
import '../../features/authentication/domain/usecases/sign_out.dart';
import '../../features/authentication/domain/usecases/verify_otp.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/registration_bloc.dart';

// Home feature imports
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source_impl.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_featured_offers.dart';
import '../../features/home/domain/usecases/get_platforms.dart';
import '../../features/home/domain/usecases/get_suggested_products.dart';
import '../../features/home/domain/usecases/search_products.dart';
import '../../features/home/domain/usecases/get_products.dart';
import '../../features/home/domain/usecases/get_product_details.dart';
import '../../features/home/domain/usecases/get_categories.dart';
import '../../features/home/domain/usecases/get_products_by_category.dart';
import '../../features/home/domain/usecases/get_similar_products.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/product_list_bloc.dart';
import '../../features/home/presentation/bloc/product_details_bloc.dart';

// WebView imports
import '../../features/webview/data/datasources/webview_local_data_source.dart';
import '../../features/webview/data/repositories/webview_repository_impl.dart';
import '../../features/webview/domain/repositories/webview_repository.dart';
import '../../features/webview/domain/usecases/validate_url.dart';
import '../../features/webview/domain/usecases/save_webview_state.dart';
import '../../features/webview/domain/usecases/get_platform_url.dart';
import '../../features/webview/presentation/bloc/webview_bloc.dart';

// Cart feature imports
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/get_cart_items.dart';
import '../../features/cart/domain/usecases/update_cart_quantity.dart';
import '../../features/cart/domain/usecases/remove_from_cart.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

import '../network/network_info.dart';
import '../utils/constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  await _initAuth();

  //! Features - Home
  await _initHome();

  //! Features - WebView
  await _initWebView();

  //! Features - Cart
  await _initCart();

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
      bypassOtpVerification: sl(),
      getCurrentSession: sl(),
      signOut: sl(),
    ),
  );

  sl.registerFactory(() => RegistrationBloc(completeRegistration: sl()));

  // Use cases
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => BypassOtpVerification(sl()));
  sl.registerLazySingleton(() => GetCurrentSession(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => CompleteRegistration(sl()));

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

Future<void> _initHome() async {
  // Bloc
  sl.registerFactory(
    () => HomeBloc(
      getFeaturedOffers: sl(),
      getPlatforms: sl(),
      getSuggestedProducts: sl(),
      searchProducts: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductListBloc(
      getProducts: sl(),
      getCategories: sl(),
      getProductsByCategory: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductDetailsBloc(getProductDetails: sl(), getSimilarProducts: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFeaturedOffers(sl()));
  sl.registerLazySingleton(() => GetPlatforms(sl()));
  sl.registerLazySingleton(() => GetSuggestedProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetails(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetProductsByCategory(sl()));
  sl.registerLazySingleton(() => GetSimilarProducts(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
}

Future<void> _initWebView() async {
  // Bloc
  sl.registerFactory(
    () => WebViewBloc(
      validateUrl: sl(),
      saveWebViewState: sl(),
      getPlatformUrl: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ValidateUrl(sl()));
  sl.registerLazySingleton(() => SaveWebViewState(sl()));
  sl.registerLazySingleton(() => GetPlatformUrl());

  // Repository
  sl.registerLazySingleton<WebViewRepository>(
    () => WebViewRepositoryImpl(localDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WebViewLocalDataSource>(
    () => WebViewLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

Future<void> _initCart() async {
  // Bloc
  sl.registerFactory(
    () => CartBloc(
      getCartItems: sl(),
      addToCart: sl(),
      updateCartQuantity: sl(),
      removeFromCart: sl(),
      clearCart: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCartItems(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantity(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl(), supabaseClient: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(supabaseClient: sl()),
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
