import 'package:chat_app/core/network_info.dart';
import 'package:chat_app/features/auth/domain/usecases/get_users.dart';
import 'package:chat_app/features/chat/data/datasources/chat_local_datasources.dart';
import 'package:chat_app/features/chat/data/datasources/chat_remote_datasources.dart';
import 'package:chat_app/features/chat/data/repository/chat_repo_impl.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repo.dart';
import 'package:chat_app/features/chat/domain/usecases/delete_chat.dart';
import 'package:chat_app/features/chat/domain/usecases/get_all_chats.dart';
import 'package:chat_app/features/chat/domain/usecases/get_chat_messages.dart';
import 'package:chat_app/features/chat/domain/usecases/get_single_chat_usecase.dart';
import 'package:chat_app/features/chat/domain/usecases/initiate_chat.dart';
import 'package:chat_app/features/chat/presentation/bloc/bloc/chat_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/features/auth/data/datasources/local_data_sources.dart';
import 'package:chat_app/features/auth/data/datasources/remote_datasource.dart';
import 'package:chat_app/features/auth/data/repository/auth_repo_impl.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:chat_app/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_app/core/socket/socket_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final connectionChecker = await InternetConnectionChecker.createInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton<InternetConnectionChecker>(() => connectionChecker);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => http.Client());
  


  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl(), sl()));

  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<ChatLocalDataSource>(() => ChatLocalDatasourcesImpl(sl()));

  // Socket service
  sl.registerLazySingleton<SocketService>(() => SocketService(sl()));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(),networkInfo: sl()));

  sl.registerLazySingleton<ChatRepository>(() => ChatRepoImpl(sl(), sl(),sl(), sl()));

  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<SignUpUsecase>(() => SignUpUsecase(sl()));
  sl.registerLazySingleton<GetcurrentUserUsecase>(() => GetcurrentUserUsecase(sl()));
  sl.registerLazySingleton<LogoutUsecase>(() => LogoutUsecase(sl()));
  sl.registerLazySingleton<GetUserUsecase>(() => GetUserUsecase(sl()));

  sl.registerLazySingleton<GetAllChatsUsecase>(()=>GetAllChatsUsecase(sl()));
  sl.registerLazySingleton<GetChatByIdUsecase>(() => GetChatByIdUsecase(sl()));
  sl.registerLazySingleton<DeleteChatUsecase>(() => DeleteChatUsecase(sl()));
  sl.registerLazySingleton<InitiateChat>(() => InitiateChat(sl()));
  sl.registerLazySingleton<GetChatMessages>(() => GetChatMessages(sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc(login: sl(), signUp: sl(), logout: sl(), getCurrentUser: sl(), getUsers: sl()));
  sl.registerFactory<ChatBloc>(()=>ChatBloc(getAllChats: sl()));
}
