// lib/services/auth_errors.dart
//
// Chuyển mã lỗi FirebaseAuthException sang thông báo thân thiện (vi + en).

import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object e, {bool vi = true}) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-email':
        return vi ? 'Email không hợp lệ' : 'Invalid email';
      case 'user-disabled':
        return vi ? 'Tài khoản đã bị khoá' : 'Account disabled';
      case 'user-not-found':
        return vi ? 'Không tìm thấy tài khoản' : 'Account not found';
      case 'wrong-password':
      case 'invalid-credential':
        return vi ? 'Email hoặc mật khẩu không đúng' : 'Wrong email or password';
      case 'email-already-in-use':
        return vi ? 'Email đã được đăng ký' : 'Email already registered';
      case 'weak-password':
        return vi ? 'Mật khẩu quá yếu (tối thiểu 6 ký tự)' : 'Password too weak (min 6 chars)';
      case 'too-many-requests':
        return vi ? 'Quá nhiều lần thử, vui lòng đợi' : 'Too many attempts, please wait';
      case 'network-request-failed':
        return vi ? 'Lỗi kết nối mạng' : 'Network error';
      case 'operation-not-allowed':
        return vi ? 'Phương thức đăng nhập chưa được bật' : 'Sign-in method not enabled';
      default:
        return vi ? 'Đã xảy ra lỗi: ${e.code}' : 'Error: ${e.code}';
    }
  }
  return vi ? 'Đã xảy ra lỗi, vui lòng thử lại' : 'An error occurred, please try again';
}
