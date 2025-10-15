// Auth Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String userName;
  final String password;
  LoginRequested(this.userName, this.password);
}
class LogoutRequested extends AuthEvent {}