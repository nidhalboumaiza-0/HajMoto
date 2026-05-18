import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Config
import 'package:gestion_stock/core/config/app_config.dart';

// Network
import 'package:gestion_stock/core/network/dio_client.dart';

// ── Real data sources ──────────────────────────────────────────────────
import 'package:gestion_stock/features/products/data/datasources/product_remote_datasource.dart';
import 'package:gestion_stock/features/sales/data/datasources/sale_remote_datasource.dart';

// ── Mock data sources ──────────────────────────────────────────────────
import 'package:gestion_stock/features/products/data/datasources/product_mock_datasource.dart';
import 'package:gestion_stock/features/sales/data/datasources/sale_mock_datasource.dart';
import 'package:gestion_stock/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:gestion_stock/features/categories/data/repositories/category_mock_repository_impl.dart';

// ── Repositories (interfaces) ──────────────────────────────────────────
import 'package:gestion_stock/features/products/domain/repositories/product_repository.dart';
import 'package:gestion_stock/features/sales/domain/repositories/sale_repository.dart';
import 'package:gestion_stock/features/dashboard/domain/repositories/statistics_repository.dart';
import 'package:gestion_stock/features/categories/domain/repositories/category_repository.dart';

// ── Repository implementations (real) ─────────────────────────────────
import 'package:gestion_stock/features/products/data/repositories/product_repository_impl.dart';
import 'package:gestion_stock/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:gestion_stock/features/dashboard/data/repositories/statistics_repository_impl.dart';

// ── Repository implementations (mock) ─────────────────────────────────
import 'package:gestion_stock/features/products/data/repositories/product_mock_repository_impl.dart';
import 'package:gestion_stock/features/sales/data/repositories/sale_mock_repository_impl.dart';
import 'package:gestion_stock/features/dashboard/data/repositories/statistics_mock_repository.dart';

// Use Cases - Products
import 'package:gestion_stock/features/products/domain/usecases/product_usecases.dart';

// Use Cases - Categories
import 'package:gestion_stock/features/categories/domain/usecases/category_usecases.dart';

// Use Cases - Sales
import 'package:gestion_stock/features/sales/domain/usecases/sale_usecases.dart';

// Use Cases - Dashboard
import 'package:gestion_stock/features/dashboard/domain/usecases/statistics_usecases.dart';

// BLoCs
import 'package:gestion_stock/features/products/presentation/bloc/product_bloc.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_bloc.dart';

/// Service Locator using get_it.
/// In TEST mode  → registers mock repositories (no network / no Supabase).
/// In PRODUCTION → registers real repositories backed by Supabase REST.
final sl = GetIt.instance;

Future<void> initDependencies() async {
  if (AppConfig.isTestMode) {
    // ========================================================
    // TEST MODE — mock data, no Supabase needed
    // ========================================================

    // Mock datasources (singleton so state is shared across the session)
    sl.registerLazySingleton<ProductMockDataSource>(
        () => ProductMockDataSource());
    sl.registerLazySingleton<SaleMockDataSource>(() => SaleMockDataSource());
    sl.registerLazySingleton<CategoryMockDataSource>(
        () => CategoryMockDataSource());

    // Repositories bound to mock implementations
    sl.registerLazySingleton<ProductRepository>(
      () => ProductMockRepositoryImpl(sl<ProductMockDataSource>()),
    );
    sl.registerLazySingleton<SaleRepository>(
      () => SaleMockRepositoryImpl(sl<SaleMockDataSource>()),
    );
    sl.registerLazySingleton<StatisticsRepository>(
      () => MockStatisticsRepository(),
    );
    sl.registerLazySingleton<CategoryRepository>(
      () => CategoryMockRepositoryImpl(sl<CategoryMockDataSource>()),
    );
  } else {
    // ========================================================
    // PRODUCTION MODE — real Supabase backend
    // ========================================================

    final supabase = Supabase.instance;
    sl.registerLazySingleton<DioClient>(
      () => DioClient(
        supabaseUrl: supabase.client.rest.url.replaceAll('/rest/v1', ''),
        supabaseAnonKey: supabase.client.rest.headers['apikey'] ?? '',
      ),
    );

    sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSource(sl<DioClient>()),
    );
    sl.registerLazySingleton<SaleRemoteDataSource>(
      () => SaleRemoteDataSource(sl<DioClient>()),
    );

    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
          remoteDataSource: sl<ProductRemoteDataSource>()),
    );
    sl.registerLazySingleton<SaleRepository>(
      () => SaleRepositoryImpl(remoteDataSource: sl<SaleRemoteDataSource>()),
    );
    sl.registerLazySingleton<StatisticsRepository>(
      () => StatisticsRepositoryImpl(sl<DioClient>()),
    );
  }

  // ==========================================
  // Use Cases - Products
  // ==========================================
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => AddProductUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => ImportProductsCsvUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetProductByReferenceUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetLowStockProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetOutOfStockProductsUseCase(sl<ProductRepository>()));

  // ==========================================
  // Use Cases - Sales
  // ==========================================
  sl.registerLazySingleton(() => CreateSaleUseCase(sl<SaleRepository>()));
  sl.registerLazySingleton(() => GetSalesUseCase(sl<SaleRepository>()));
  sl.registerLazySingleton(() => CreateClientUseCase(sl<SaleRepository>()));
  sl.registerLazySingleton(() => GetClientByCinUseCase(sl<SaleRepository>()));
  sl.registerLazySingleton(() => CreateInvoiceUseCase(sl<SaleRepository>()));
  sl.registerLazySingleton(() => GetAllInvoicesUseCase(sl<SaleRepository>()));
  sl.registerLazySingleton(() => GetInvoicesByClientUseCase(sl<SaleRepository>()));

  // ==========================================
  // Use Cases - Dashboard / Statistics
  // ==========================================
  sl.registerLazySingleton(() => GetOverallStatisticsUseCase(sl<StatisticsRepository>()));
  sl.registerLazySingleton(() => GetDailyStatisticsUseCase(sl<StatisticsRepository>()));
  sl.registerLazySingleton(() => GetMonthlyStatisticsUseCase(sl<StatisticsRepository>()));
  sl.registerLazySingleton(() => GetYearlyStatisticsUseCase(sl<StatisticsRepository>()));
  sl.registerLazySingleton(() => GetStatisticsByDateRangeUseCase(sl<StatisticsRepository>()));
  sl.registerLazySingleton(() => GetStatsForMonthUseCase(sl<StatisticsRepository>()));
  sl.registerLazySingleton(() => GetStatsForLastNDaysUseCase(sl<StatisticsRepository>()));

  // ==========================================
  // Use Cases - Categories
  // ==========================================
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl<CategoryRepository>()));

  // ==========================================
  // BLoCs (Factory = new instance each time)
  // ==========================================
  sl.registerFactory(() => ProductBloc(
        getProductsUseCase: sl(),
        addProductUseCase: sl(),
        updateProductUseCase: sl(),
        deleteProductUseCase: sl(),
        importProductsCsvUseCase: sl(),
        getProductByReferenceUseCase: sl(),
        getLowStockProductsUseCase: sl(),
        getOutOfStockProductsUseCase: sl(),
      ));

  sl.registerFactory(() => SaleBloc(
        createSaleUseCase: sl(),
        getSalesUseCase: sl(),
        createClientUseCase: sl(),
        getClientByCinUseCase: sl(),
        createInvoiceUseCase: sl(),
        getAllInvoicesUseCase: sl(),
        getInvoicesByClientUseCase: sl(),
      ));

  sl.registerFactory(() => DashboardBloc(
        getOverallStatisticsUseCase: sl(),
        getDailyStatisticsUseCase: sl(),
        getMonthlyStatisticsUseCase: sl(),
        getYearlyStatisticsUseCase: sl(),
        getStatisticsByDateRangeUseCase: sl(),
        getStatsForMonthUseCase: sl(),
        getStatsForLastNDaysUseCase: sl(),
      ));

  sl.registerFactory(() => CategoryBloc(
        getCategoriesUseCase: sl(),
        addCategoryUseCase: sl(),
        updateCategoryUseCase: sl(),
        deleteCategoryUseCase: sl(),
      ));
}
