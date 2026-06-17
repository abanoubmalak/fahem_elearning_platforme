// abstract class AuthState {}
// class AuthInitial extends AuthState {}
// class AuthLoading extends AuthState {}
// class AuthOTPSent extends AuthState {
//   final String uid;
//   final String email;
//   AuthOTPSent({required this.uid, required this.email});
// }
// class AuthSuccess extends AuthState {}
// class AuthFailure extends AuthState {
//   final String error;
//   AuthFailure(this.error);
// }


// abstract class AuthState {}
// class AuthInitial extends AuthState {}
// class AuthLoading extends AuthState {}
// class AuthOTPSent extends AuthState {
//   final String uid;
//   final String email;
//   AuthOTPSent({required this.uid, required this.email});
// }
// class AuthSuccess extends AuthState {
//   final String? role; // 👈 تمرير الدور هنا لدعم شاشة تسجيل الدخول
//   AuthSuccess({this.role});
// }
// class AuthFailure extends AuthState {
//   final String error;
//   AuthFailure(this.error);
// }


// lib/features/auth/presentation/cubit/auth_state.dart
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOTPSent extends AuthState {
  final String uid;
  final String email;
  AuthOTPSent({required this.uid, required this.email});
}

class AuthSuccess extends AuthState {
  final String? role; // استقبال وتمرير نوع الحساب (طالب، ولي أمر، مدرس، أدمن)
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