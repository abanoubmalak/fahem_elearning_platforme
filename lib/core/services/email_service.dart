import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class EmailService {
  final String _serviceId = '';   
  final String _templateId = ''; 
  final String _publicKey = '';   

  Future<bool> sendOTPEmail({
    required String targetEmail,
    required String userName,
    required String otpCode,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    try {
      
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
            'email': targetEmail, 
            'otp_code': otpCode,   
          }
        }),
      ).timeout(const Duration(seconds: 7));

      
      return response.statusCode == 200;
    } on TimeoutException {
      return false; 
    } catch (e) {
      return false;
    }
  }
}