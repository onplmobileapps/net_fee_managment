import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/wasooli/wasooli_home_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(storageService),
      child: const NetFeeManagementApp(),
    ),
  );
}

class NetFeeManagementApp extends StatelessWidget {
  const NetFeeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waseem Net Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: Consumer<AppState>(
        builder: (context, appState, child) {
          if (!appState.isLoggedIn) {
            return const LoginScreen();
          }

          if (appState.isAdmin) {
            return const AdminDashboardScreen();
          } else {
            return const WasooliHomeScreen();
          }
        },
      ),
    );
  }
}
