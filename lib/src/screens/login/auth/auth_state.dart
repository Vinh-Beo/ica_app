// Auth States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String email;
  AuthSuccess(this.email);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}