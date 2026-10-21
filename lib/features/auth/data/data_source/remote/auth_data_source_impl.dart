import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../../../../../core/service/secure_storage_service.dart';
import '../abstract/auth_data_source.dart';

@LazySingleton(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  AuthDataSourceImpl({
    required this.talker,
    required this.secureStorageService,
  });

  final Talker talker;
  final SecureStorageService secureStorageService;

  @override
  Future<bool> auth(String login, String password) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://geeks.free.beeceptor.com',
        // 4xx не бросают исключение, их обработаем ниже как false
        validateStatus: (status) => status != null && status < 500,
      ),  
    );

    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestData: true,
          printRequestHeaders: false,
          printResponseData: true,
          printResponseMessage: true,
          printResponseHeaders: true,
          printResponseTime: true,
          hiddenHeaders: {'X-Api-Key'},
        ),
      ),
    );

    final response = await dio.post(
      '/auth',
      data: {'login': login, 'password': password},
    );

    if (response.statusCode == 200 && response.data != null) {
      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await secureStorageService.save('accessToken', accessToken);
      await secureStorageService.save('refreshToken', refreshToken);
      return true;
    }
    return false;
  }
}
