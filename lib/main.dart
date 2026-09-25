import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gestion_stock/core/config/app_config.dart';
import 'package:gestion_stock/core/di/injection_container.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/presentation/main_shell.dart';
import 'package:gestion_stock/features/auth/presentation/pages/login_page.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_bloc.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init();

  // Initialize Supabase only when running in production mode
  if (AppConfig.isProduction) {
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY are required in production mode.',
      );
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  // Initialize Dependency Injection (chooses mock vs real based on AppConfig)
  await initDependencies();

  runApp(const GestionStockApp());
}

class GestionStockApp extends StatelessWidget {
  const GestionStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Design size based on standard laptop resolution
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ProductBloc>(create: (_) => sl<ProductBloc>()),
            BlocProvider<SaleBloc>(create: (_) => sl<SaleBloc>()),
            BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
            BlocProvider<CategoryBloc>(
              create: (_) =>
                  sl<CategoryBloc>()..add(const LoadCategoriesEvent()),
            ),
          ],
          child: MaterialApp(
            title: 'Gestion Stock - Boutique Moto',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AppRouter(),
          ),
        );
      },
    );
  }
}

/// Root widget that manages login / logged-in state.
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return MainShell(onLogout: () => setState(() => _isLoggedIn = false));
    }
    return LoginPage(onLoginSuccess: () => setState(() => _isLoggedIn = true));
  }
}
