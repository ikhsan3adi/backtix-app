import 'package:backtix_app/src/data/models/user/update_user_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/models/user/user_with_auth_model.dart';
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

  Future<Either<DioException, UserWithAuthModel>> updateUser(
    UpdateUserModel updatedUser,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _userService.updateUser(
          image: updatedUser.image,
          deleteImage: updatedUser.deleteImage,
          username: updatedUser.username,
          fullname: updatedUser.fullname,
          email: updatedUser.email,
          password: updatedUser.password,
          location: updatedUser.location,
          latitude: updatedUser.latitude,
          longitude: updatedUser.longitude,
        );

        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, UserModel>> updateUserPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _userService.updateUserPassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, String?>> requestPasswordReset() async {
    return await TaskEither.tryCatch(
      () async => (await _userService.requestPasswordReset()).data['message'],
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, UserModel>> passwordReset({
    required String resetCode,
    required String newPassword,
  }) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _userService.passwordReset(
          resetCode: resetCode,
          newPassword: newPassword,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }
}
