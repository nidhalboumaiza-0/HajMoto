import 'package:dio/dio.dart';
import 'package:gestion_stock/core/error/exceptions.dart';

/// Dio HTTP Client configured for Supabase REST API
/// Provides a clean interface for all CRUD operations on Supabase tables.
///
/// Usage:
///   final client = DioClient(supabaseUrl: '...', supabaseAnonKey: '...');
///   final data = await client.getAll('products');
///   final single = await client.getById('products', id);
class DioClient {
  final Dio _dio;
  final String supabaseUrl;
  final String supabaseAnonKey;

  DioClient({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  }) : _dio = Dio(BaseOptions(
          baseUrl: '$supabaseUrl/rest/v1',
          headers: {
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $supabaseAnonKey',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {}, // silent in production, enable for debugging
    ));
  }

  /// GET all rows from a table with optional query parameters.
  ///
  /// [table] - The Supabase table name.
  /// [queryParameters] - PostgREST query params like select, order, filters.
  Future<List<dynamic>> getAll(
    String table, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final params = <String, dynamic>{'select': '*'};
      if (queryParameters != null) params.addAll(queryParameters);

      final response = await _dio.get(
        '/$table',
        queryParameters: params,
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch from $table');
    }
  }

  /// GET a single row by ID.
  ///
  /// Returns the first matching row as a Map.
  Future<Map<String, dynamic>> getById(String table, String id) async {
    try {
      final response = await _dio.get(
        '/$table',
        queryParameters: {'select': '*', 'id': 'eq.$id'},
        options: Options(headers: {
          'Accept': 'application/vnd.pgrst.object+json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Record not found in $table');
    }
  }

  /// GET a single row matching a specific column value.
  Future<Map<String, dynamic>> getByColumn(
    String table,
    String column,
    String value,
  ) async {
    try {
      final response = await _dio.get(
        '/$table',
        queryParameters: {'select': '*', column: 'eq.$value'},
        options: Options(headers: {
          'Accept': 'application/vnd.pgrst.object+json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Record not found in $table where $column = $value');
    }
  }

  /// GET a single row matching a column value, returns null if not found.
  Future<Map<String, dynamic>?> getByColumnOrNull(
    String table,
    String column,
    String value,
  ) async {
    try {
      final response = await _dio.get(
        '/$table',
        queryParameters: {'select': '*', column: 'eq.$value'},
      );
      final data = response.data as List<dynamic>;
      if (data.isEmpty) return null;
      return data.first as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to query $table');
    }
  }

  /// INSERT a new row and return the created record.
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        '/$table',
        data: body,
        options: Options(headers: {
          'Prefer': 'return=representation',
          'Accept': 'application/vnd.pgrst.object+json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to insert into $table');
    }
  }

  /// BULK INSERT multiple rows.
  Future<List<dynamic>> bulkInsert(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    try {
      final response = await _dio.post(
        '/$table',
        data: rows,
        options: Options(headers: {
          'Prefer': 'return=representation',
        }),
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to bulk insert into $table');
    }
  }

  /// UPDATE a row by ID and return the updated record.
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch(
        '/$table',
        data: body,
        queryParameters: {'id': 'eq.$id'},
        options: Options(headers: {
          'Prefer': 'return=representation',
          'Accept': 'application/vnd.pgrst.object+json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to update $table');
    }
  }

  /// DELETE a row by ID.
  Future<void> delete(String table, String id) async {
    try {
      await _dio.delete(
        '/$table',
        queryParameters: {'id': 'eq.$id'},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to delete from $table');
    }
  }

  /// Custom GET with full control over query parameters.
  /// Useful for complex PostgREST queries (or, and, filters).
  Future<List<dynamic>> query(
    String table, {
    Map<String, dynamic>? queryParameters,
    String? rawFilter,
  }) async {
    try {
      final params = <String, dynamic>{'select': '*'};
      if (queryParameters != null) params.addAll(queryParameters);

      final response = await _dio.get('/$table', queryParameters: params);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Query failed on $table');
    }
  }

  /// Convert DioException to our app's ServerException
  ServerException _handleDioError(DioException e, String fallbackMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message = fallbackMessage;
    if (data is Map && data.containsKey('message')) {
      message = data['message'].toString();
    } else if (data is Map && data.containsKey('details')) {
      message = data['details'].toString();
    } else if (e.message != null) {
      message = '$fallbackMessage: ${e.message}';
    }

    return ServerException(message: message, statusCode: statusCode);
  }
}
