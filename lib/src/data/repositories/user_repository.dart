import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/services/remote/user_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class UserRepository {
  final UserService _userService;

  const UserRepository(this._userService);

  Future<Either<DioException, UserModel>> getMyDetails() async {
    return await TaskEither.tryCatch(
      () async => (await _userService.getMyDetails()).data,
      (error, _) => error as DioException,
    ).run();
  }
}
