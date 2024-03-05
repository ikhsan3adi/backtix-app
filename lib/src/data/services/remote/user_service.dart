import 'dart:io';

import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/models/user/user_with_auth_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_service.g.dart';

@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String? baseUrl}) = _UserService;

  @NoBody()
  @GET('users/my')
  Future<HttpResponse<UserModel>> getMyDetails();

  @MultiPart()
  @PUT('users/my')
  Future<HttpResponse<UserWithAuthModel>> updateUser({
    @Part(name: 'image') File? image,
    @Part() bool? deleteImage,
    @Part() String? username,
    @Part() String? fullname,
    @Part() String? email,
    @Part() String? password,
    @Part() String? location,
    @Part() double? latitude,
    @Part() double? longitude,
  });
}
