// lib/features/parent/presentation/cubit/parent_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentState {
  final List<Map<String, dynamic>> children;
  ParentState({required this.children});
}

class ParentCubit extends Cubit<ParentState> {
  ParentCubit() : super(ParentState(children: [
    // بيانات افتراضية للتجربة أمام اللجنة
    {
      'id': 'CH-1',
      'name': 'أحمد علي',
      'stage': 'الصف الأول الإعدادي',
      'overallPerformance': 0.82,
      'isPaid': true,
    },
    {
      'id': 'CH-2',
      'name': 'مينا كيرلس',
      'stage': 'الصف الرابع الابتدائي',
      'overallPerformance': 0.54,
      'isPaid': false,
    },
  ]));

  // دالة ربط ابن جديد باستخدام الكود العشوائي
  void linkChild(String code) {
    final newChild = {
      'id': 'CH-${DateTime.now().millisecondsSinceEpoch}',
      'name': 'طالب تم ربطه (كود: $code)', // محاكاة لاسم الطالب العائد من السيرفر
      'stage': 'المرحلة مجهولة',
      'overallPerformance': 0.0,
      'isPaid': false, // يضاف كغير مسدد افتراضياً
    };
    
    final updatedList = List<Map<String, dynamic>>.from(state.children)..add(newChild);
    emit(ParentState(children: updatedList));
  }

  // دالة دفع الاشتراك وتحديث الحالة حياً
  void paySubscription(String childId) {
    final updatedList = state.children.map((child) {
      if (child['id'] == childId) {
        return {...child, 'isPaid': true}; // تغيير حالة الدفع
      }
      return child;
    }).toList();
    emit(ParentState(children: updatedList));
  }

  // دالة إلغاء الربط
  void removeChild(String childId) {
    final updatedList = state.children.where((child) => child['id'] != childId).toList();
    emit(ParentState(children: updatedList));
  }
}