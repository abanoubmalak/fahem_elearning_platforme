// lib/core/services/email_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class EmailService {
  // ⚠️ خطوة قفل المشروع: ضع المعرفات الحقيقية الخاصة بك هنا من الموقع
  final String _serviceId = 'service_8acgvp6';   
  final String _templateId = 'template_o2zju0c'; 
  final String _publicKey = 'G0F-IFEQTDP7LeUwZ';   

  Future<bool> sendOTPEmail({
    required String targetEmail,
    required String userName,
    required String otpCode,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    try {
      print('=== [EmailService] جاري إرسال طلب الـ HTTP ===');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'user_name': userName, 
            'email': targetEmail,  // يطابق {{email}} في الـ Template تماماً
            'otp_code': otpCode,   
          }
        }),
      ).timeout(const Duration(seconds: 7));

      // 👈 طباعة الاستجابة التفصيلية لمعرفة داء التعليق فوراً
      print('=== [EmailService] كود استجابة السيرفر: ${response.statusCode} ===');
      print('=== [EmailService] نص رد السيرفر الصريح: ${response.body} ===');
      
      return response.statusCode == 200;
    } on TimeoutException {
      print('=== [EmailService] ⚠️ انتهت مهلة الاتصال (Timeout) ===');
      return false; 
    } catch (e) {
      print('=== [EmailService] حدث استثناء غير متوقع: $e ===');
      return false;
    }
  }
}