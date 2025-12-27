import 'package:fdsmart/features/auth/viewmodels/language_view_model.dart';
import 'package:fdsmart/core/theme/app_theme.dart';
import 'package:fdsmart/features/auth/views/login_screen.dart';
import 'package:fdsmart/features/admin/views/admin_dashboard_screen.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/auth/views/register_screen.dart';
import 'package:fdsmart/features/menu/viewmodels/menu_view_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:fdsmart/features/home/views/home_screen.dart';
import 'package:fdsmart/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  // await Hive.openBox('settings'); // Example box

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  runApp(const FDSmartApp());
}

class FDSmartApp extends StatelessWidget {
  const FDSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MenuViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
      ],
      child: MaterialApp(
        title: 'FDSmart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _validateUserOnLaunch();
  }

  Future<void> _validateUserOnLaunch() async {
    // The auth state listener in AuthViewModel will handle validation
    // This ensures deleted users are logged out on app launch
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error message if user was deleted
    if (authViewModel.errorMessage != null && 
        authViewModel.errorMessage!.contains("Account not found")) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    }

    if (authViewModel.currentUser != null) {
      if (authViewModel.currentUser?.role == 'admin') {
        return const AdminDashboardScreen();
      }
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
