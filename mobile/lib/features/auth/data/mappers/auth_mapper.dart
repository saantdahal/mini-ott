import '../../domain/entities/user.dart';
import '../models/user_model.dart';

extension UserModelMapper on UserModel {
  User toEntity() {
    return User(id: id, email: email, name: name);
  }
}
