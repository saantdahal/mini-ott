import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({required String password}) {
    return _repository.deleteAccount(password: password);
  }
}
