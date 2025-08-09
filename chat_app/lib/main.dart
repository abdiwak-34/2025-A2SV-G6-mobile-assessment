import 'package:chat_app/core/usecase/base_usecase.dart';
import 'package:chat_app/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/page/login_page.dart';
import 'package:chat_app/features/auth/presentation/page/signup_page.dart';
import 'package:chat_app/features/auth/presentation/page/splash_screen.dart';
import 'package:chat_app/features/chat/domain/usecases/get_all_chats.dart';
import 'package:chat_app/features/chat/presentation/bloc/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_app/dependency_injection.dart' as di;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => di.sl<ChatBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/authwrapper': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/chat': (context) => const ChatHomePage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return ChatHomePage();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}