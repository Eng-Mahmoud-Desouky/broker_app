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
import '../../features/authentication/domain/usecases/update_profile.dart';
import '../../features/authentication/domain/usecases/verify_otp.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/registration_bloc.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/get_unread_count.dart';
import '../../features/notifications/domain/usecases/mark_all_read.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';

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

// Support chat
import '../../features/support_chat/data/datasources/support_chat_remote_ds.dart';
import '../../features/support_chat/data/repositories/support_chat_repo_impl.dart';
import '../../features/support_chat/domain/repositories/support_chat_repository.dart';
import '../../features/support_chat/domain/usecases/create_or_get_thread.dart';
import '../../features/support_chat/domain/usecases/subscribe_messages.dart';
import '../../features/support_chat/domain/usecases/send_message.dart';
import '../../features/support_chat/domain/usecases/list_threads.dart';
import '../../features/support_chat/domain/usecases/close_thread.dart';
import '../../features/support_chat/presentation/bloc/thread/chat_thread_bloc.dart';
import '../../features/support_chat/presentation/bloc/list/chat_list_bloc.dart';

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

// Wallet feature imports
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_balance.dart';
import '../../features/wallet/domain/usecases/get_transaction_history.dart';
import '../../features/wallet/domain/usecases/create_topup_transaction.dart';
import '../../features/wallet/domain/usecases/get_transaction_by_id.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

// Order feature imports
import '../../features/order/data/datasources/order_remote_data_source.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/domain/usecases/create_order.dart';
import '../../features/order/domain/usecases/get_user_orders.dart';
import '../../features/order/domain/usecases/get_order_by_id.dart';
import '../../features/order/presentation/bloc/order_bloc.dart';

// Address feature imports
import '../../features/address/data/datasources/address_remote_data_source.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/domain/usecases/get_user_addresses.dart';
import '../../features/address/domain/usecases/add_address.dart';
import '../../features/address/domain/usecases/set_default_address.dart';
import '../../features/address/domain/usecases/delete_address.dart';
import '../../features/address/presentation/bloc/address_bloc.dart';

// Pricing feature imports
import '../../features/pricing/data/datasources/pricing_remote_data_source.dart';
import '../../features/pricing/data/repositories/pricing_repository_impl.dart';
import '../../features/pricing/domain/repositories/pricing_repository.dart';
import '../../features/pricing/domain/usecases/get_pricing_settings.dart';
import '../../features/pricing/presentation/cubit/pricing_cubit.dart';

// Search feature imports
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/get_search_url_usecase.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';

// Content feature imports
import '../../features/home/data/datasources/content_remote_data_source.dart';
import '../../features/home/data/repositories/content_repository_impl.dart';
import '../../features/home/domain/repositories/content_repository.dart';
import '../../features/home/domain/usecases/get_app_content.dart';
import '../../features/home/presentation/bloc/content_cubit.dart';

import '../network/network_info.dart';
import '../services/notifications_service.dart';
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

  //! Features - Wallet
  await _initWallet();

  //! Features - Order
  await _initOrder();

  //! Features - Address
  await _initAddress();

  //! Features - Support Chat
  await _initSupportChat();

  //! Features - Pricing
  await _initPricing();

  //! Features - Search
  await _initSearch();

  //! Features - App Notifications
  await _initAppNotifications();

  //! Core
  await _initCore();

  //! Features - Content
  await _initContent();

  //! External
  await _initExternal();
}

Future<void> _initContent() async {
  // Cubit
  sl.registerFactory(() => ContentCubit(getAppContent: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetAppContent(sl()));

  // Repository
  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(supabaseClient: sl()),
  );
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
      updateProfile: sl(),
      notificationsService: sl(),
    ),
  );

  sl.registerFactory(
    () => RegistrationBloc(
      completeRegistration: sl(),
      notificationsService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => BypassOtpVerification(sl()));
  sl.registerLazySingleton(() => GetCurrentSession(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
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

Future<void> _initSupportChat() async {
  // Use cases
  sl.registerLazySingleton(() => CreateOrGetThread(sl()));
  sl.registerLazySingleton(() => SubscribeMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => ListThreads(sl()));
  sl.registerLazySingleton(() => CloseThread(sl()));

  // Repository
  sl.registerLazySingleton<SupportChatRepository>(
    () => SupportChatRepositoryImpl(remote: sl()),
  );

  // Data source
  sl.registerLazySingleton<SupportChatRemoteDataSource>(
    () =>
        SupportChatRemoteDataSource(sl()), // Supabase client already registered
  );

  // Blocs
  sl.registerFactory(
    () => ChatThreadBloc(
      createOrGetThread: sl(),
      subscribeMessages: sl(),
      sendMessage: sl(),
      closeThread: sl(),
    ),
  );

  sl.registerFactory(() => ChatListBloc(listThreads: sl()));
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

  // Notifications
  sl.registerLazySingleton(() => NotificationsService());
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

Future<void> _initWallet() async {
  // Bloc
  sl.registerFactory(
    () => WalletBloc(
      getWalletBalance: sl(),
      getTransactionHistory: sl(),
      createTopUpTransaction: sl(),
      getTransactionById: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWalletBalance(sl()));
  sl.registerLazySingleton(() => GetTransactionHistory(sl()));
  sl.registerLazySingleton(() => CreateTopUpTransaction(sl()));
  sl.registerLazySingleton(() => GetTransactionById(sl()));

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(supabaseClient: sl()),
  );
}

Future<void> _initOrder() async {
  // Bloc
  sl.registerFactory(
    () => OrderBloc(createOrder: sl(), getUserOrders: sl(), getOrderById: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => GetUserOrders(sl()));
  sl.registerLazySingleton(() => GetOrderById(sl()));

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl(), supabaseClient: sl()),
  );

  // Data sources
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(supabaseClient: sl()),
  );
}

Future<void> _initAddress() async {
  // Bloc
  sl.registerFactory(
    () => AddressBloc(
      getUserAddresses: sl(),
      addAddress: sl(),
      setDefaultAddress: sl(),
      deleteAddress: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserAddresses(sl()));
  sl.registerLazySingleton(() => AddAddress(sl()));
  sl.registerLazySingleton(() => SetDefaultAddress(sl()));
  sl.registerLazySingleton(() => DeleteAddress(sl()));

  // Repository
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: sl(), supabaseClient: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(supabaseClient: sl()),
  );
}

Future<void> _initPricing() async {
  // Cubit
  sl.registerFactory(
    () => PricingCubit(getPricingSettings: sl(), pricingRepository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPricingSettings(sl()));

  // Repository
  sl.registerLazySingleton<PricingRepository>(
    () => PricingRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PricingRemoteDataSource>(
    () => PricingRemoteDataSourceImpl(supabaseClient: sl()),
  );
}

Future<void> _initAppNotifications() async {
  // Cubit
  sl.registerFactory(
    () => NotificationsCubit(
      getNotifications: sl(),
      getUnreadCount: sl(),
      markAllAsRead: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationsCount(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsRead(sl()));

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () =>
        NotificationsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data source
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(sl()),
  );
}

Future<void> _initSearch() async {
  // Cubit
  sl.registerFactory(() => SearchCubit(getSearchUrlUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetSearchUrlUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
