import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_service.g.dart';

@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String? baseUrl}) = _UserService;

  @NoBody()
  @GET('user/my')
  Future<HttpResponse<UserModel>> getMyDetails();
}
