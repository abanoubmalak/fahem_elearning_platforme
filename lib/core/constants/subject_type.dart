enum SubjectType {
  science('العلوم', 'sci'),
  math('الرياضيات', 'math'),
  arabic('اللغة العربية', 'ara'),
  english('اللغة الإنجليزية', 'eng'),
  socialStudies('الدراسات الاجتماعية', 'soc'),
  unknown('مادة دراسية', 'unknown');

  // المتغيرات الداخلية لكل عنصر
  final String arabicName;
  final String firebasePrefix;

  const SubjectType(this.arabicName, this.firebasePrefix);

  // دالة ذكية لتحويل الـ Document ID القادم من الفايربيز إلى الاسم العربي
  static String fromId(String docId) {
    final lowerId = docId.toLowerCase();
    
    for (var type in SubjectType.values) {
      if (type != SubjectType.unknown && lowerId.contains(type.firebasePrefix)) {
        return type.arabicName;
      }
    }
    return SubjectType.unknown.arabicName; // اسم احتياطي في حال عدم التطابق
  }
}