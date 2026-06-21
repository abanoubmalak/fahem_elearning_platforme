class AppValidator {
  
  // 1. الفحص الخاص بالبريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'برجاء إدخال البريد الإلكتروني';
    }
    
    // النمط البرمجي (RegEx) للتحقق من صحة صيغة الإيميل
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'برجاء إدخال بريد إلكتروني صالح';
    }
    
    return null; // المدخل صحيح تماماً
  }

  // 2. الفحص الخاص بكلمة المرور
static String? validatePassword(String? value) {


  
  if (value == null || value.trim().isEmpty) {
    return 'برجاء إدخال كلمة المرور';
  }

  if (value.length < 8) {
    return 'كلمة المرور يجب ألا تقل عن 8 أحرف';
  }

  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
  }

  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';
  }

  if (!RegExp(r'\d').hasMatch(value)) {
    return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
  }

  if (value.contains(' ')) {
  return 'كلمة المرور لا يجب أن تحتوي على مسافات';
}

  return null;
}

  // 3. الفحص الخاص بالاسم بالكامل (Full Name Validation)
static String? validateFullName(String? value) {
  if (value == null || value.isEmpty) {
    return 'برجاء إدخال الاسم بالكامل';
  }

  // تنظيف النص من المسافات الزائدة في البداية والنهاية
  final trimmedValue = value.trim();

  // النمط البرمجي (RegEx): يسمح بالحروف العربية والإنجليزية والمسافات فقط
  final nameRegex = RegExp(r'^[a-zA-Zأ-ي ]+([\s][a-zA-Zأ-ي ]+)+$');

  if (!nameRegex.hasMatch(trimmedValue)) {
    return 'برجاء إدخال الاسم ثنائي أو ثلاثي بشكل صحيح (حروف فقط)';
  }

  // فحص إضافي: التأكد من أن طول الاسم لا يقل عن 6 أحرف كحد أدنى منطقي
  if (trimmedValue.length < 6) {
    return 'الاسم بالكامل يجب ألا يقل عن 6 أحرف';
  }

  return null; // المدخل صحيح تماماً
}
}