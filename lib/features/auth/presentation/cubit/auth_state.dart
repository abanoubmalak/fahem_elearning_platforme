
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOTPSent extends AuthState {
  final String uid;
  final String email;
  AuthOTPSent({required this.uid, required this.email});
}

class AuthSuccess extends AuthState {
  final String? role; 
  AuthSuccess({this.role});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}


class AuthForgotOTPSent extends AuthState {
  final String email;
  AuthForgotOTPSent(this.email);
}
class AuthForgotOTPVerified extends AuthState {}
class AuthResetPasswordSuccess extends AuthState {}