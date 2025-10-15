// Auth Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String userName;
  final String password;
  final bool   isRemember;
  LoginRequested(this.userName, this.password, this.isRemember);
}
class LogoutRequested extends AuthEvent {}